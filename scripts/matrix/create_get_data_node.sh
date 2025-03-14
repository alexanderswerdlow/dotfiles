#!/bin/bash
set -euo pipefail

USE_TMUX=1
NUM_GPUS=0
VERIFY_SSH=1
JOB_NAME="data"
TOTAL_JOB_DAYS=4
JOB_EXPIRE_DAYS=3
TIMEOUT=120
MAX_RETRIES=5
PARTITION="preempt"

# Process command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --gpu)
            NUM_GPUS=1
            JOB_NAME="gpu"
            shift
            ;;
        --type=*)
            JOB_NAME="${1#*=}"
            if [[ "$JOB_NAME" =~ ^gpu([0-9]*)$ ]]; then
                # Extract number after "gpu", default to 1 if no number
                NUM_GPUS="${BASH_REMATCH[1]:-1}"
                [[ -z "$NUM_GPUS" ]] && NUM_GPUS=1
            else
                NUM_GPUS=0
            fi
            shift
            ;;
        --partition=*)
            PARTITION="${1#*=}"
            shift
            ;;
        --verify-ssh)
            VERIFY_SSH=1
            shift
            ;;
        --max-retries=*)
            MAX_RETRIES="${1#*=}"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

GPU_JOB_ARGS=(
    --partition="${PARTITION}"
    --time="${TOTAL_JOB_DAYS}-00:00:00"
    --job-name="${JOB_NAME}"
    --cpus-per-gpu=10
    --mem-per-gpu=72G
    --gres="gpu:${NUM_GPUS}"
    --constraint="A100_40GB|A100_80GB|L40S|H100"
)
DATA_JOB_ARGS=(
    --partition="${PARTITION}"
    --time="${TOTAL_JOB_DAYS}-00:00:00"
    --job-name="${JOB_NAME}"
    --cpus-per-task=12
    --mem=64G
)

SACCT_ARGS=(
    --user="${USER}"
    --name="${JOB_NAME}"
    --starttime="now-${TOTAL_JOB_DAYS}days"
    --json
)

JQ_FILTER='.jobs | map(select(
    ((.state.current[0] == "RUNNING" or .state.current[0] == "PENDING") or .state.current[0] == null) and
    (.time.elapsed | tonumber) <= '"$(( JOB_EXPIRE_DAYS * 86400 ))"'
)) | sort_by(.submit_time) | reverse'

TMUX_CMD=$(cat <<'EOF'
# Check if tmux server is running
if tmux ls &>/dev/null; then
    # Check if the session named "main" exists
    if ! tmux has-session -t main 2>/dev/null; then
        echo "Session main does not exist, creating"
        tmux new-session -d -s main
    else
        # Create a session with SLURM_JOB_ID if "main" session exists
        echo "Session main exists, creating $SLURM_JOB_ID"
        tmux new-session -d -s $SLURM_JOB_ID
    fi
else
    # Create a session named "main" if tmux server is not running
    echo "Creating session main"
    tmux new-session -d -s main
fi

echo "Sleeping for infinity"
sleep infinity
EOF
)

SLEEP_CMD="sleep infinity"
WRAP_CMD=$([[ "$USE_TMUX" -eq 1 ]] && echo "$TMUX_CMD" || echo "$SLEEP_CMD")

# Submit a new job and return its job id.
submit_job() {
    local jobid
    if [[ "$NUM_GPUS" -gt 0 ]]; then
        jobid=$(sbatch "${GPU_JOB_ARGS[@]}" --output=/dev/null --error=/dev/null --wrap="$WRAP_CMD" | grep -o '[0-9]\+')
    else
        jobid=$(sbatch "${DATA_JOB_ARGS[@]}" --output=/dev/null --error=/dev/null --wrap="$WRAP_CMD" | grep -o '[0-9]\+')
    fi
    echo "Submitted new job $jobid, waiting 0.25 seconds" >&2
    sleep 0.25
    echo "$jobid"
}

# We need to do this because SSH gets very picky about how we call SSH within itself.
# This script is called inside bash which is called from ProxyCommand in OpenSSH.
verify_ssh_access() {
    local node=$1
    
    # Create a unique named pipe
    local fifo_path="/tmp/ssh_check_$$_$RANDOM"
    mkfifo "$fifo_path" 2>/dev/null
    
    # Run SSH check in background
    {
        ssh -o ConnectTimeout=1 -o BatchMode=yes -o StrictHostKeyChecking=no -T "$node" exit 2>/dev/null 1>/dev/null
        echo $? > "$fifo_path"
    } &
    
    # Read the result with timeout (non-blocking)
    local result
    read -t 1 result < "$fifo_path" || result=1
    
    # Clean up
    rm -f "$fifo_path" 2>/dev/null
    
    return "$result"
}

# Find the most recent job (running or pending) using the filter.
# Returns output in the format: "jobid|state"
get_recent_job() {
    local job_info best_job jobid state
    job_info=$(sacct "${SACCT_ARGS[@]}" 2>/dev/null)
    best_job=$(echo "$job_info" | jq -c "$JQ_FILTER | .[0]" 2>&1)
    if [[ -z "$best_job" || "$best_job" == "null" ]]; then
        echo "No matching jobs found." >&2
        return 1
    fi
    jobid=$(echo "$best_job" | jq -r '.job_id' 2>&1)
    state=$(echo "$best_job" | jq -r '.state.current[0]' 2>&1)
    echo "$jobid|$state"
}

# Wait for a given job to start running, up to TIMEOUT seconds.
wait_for_job_to_start() {
    local jobid=$1
    local start_time
    start_time=$(date +%s)
    local state
    while true; do
        if (( $(date +%s) - start_time > TIMEOUT )); then
            echo "Timeout waiting for job $jobid to start" >&2
            return 1
        fi

        job_info=$(sacct -j "$jobid" --json 2>/dev/null)
        state=$(echo "$job_info" | jq -r '.jobs[0].state.current[0]' 2>/dev/null)
        case "$state" in
            RUNNING)
                echo "Job $jobid is in state: $state. Returning 0." >&2
                return 0
                ;;
            FAILED|CANCELLED|TIMEOUT)
                echo "Job $jobid is in state: $state" >&2
                return 1
                ;;
            *)
                echo "Job $jobid is in state: $state. Sleeping 1.0 seconds..." >&2
                sleep 1.0
                ;;
        esac
    done
}


main() {
    local job_info jobid state node_name
    local just_submitted=0
    local retries=0

    while [[ $retries -lt $MAX_RETRIES ]]; do
        retries=$((retries + 1))
        if [[ $retries -gt 1 ]]; then
            echo "Attempt $retries of $MAX_RETRIES" >&2
        fi
        
        if [[ "$just_submitted" -eq 1 ]]; then
            echo "Using previously submitted job: $jobid" >&2
            just_submitted=0
        elif job_info=$(get_recent_job); then
            IFS="|" read -r jobid state <<< "$job_info"
            echo "Found job: $jobid (state: $state)" >&2
        else
            echo "No job found. Submitting a new job..." >&2
            jobid=$(submit_job | tail -n 1)
            state=""
            just_submitted=1
        fi

        if [ "$state" != "RUNNING" ]; then
            echo "Waiting for job: $jobid to start..." >&2
            if ! wait_for_job_to_start "$jobid"; then
                echo "Job: $jobid did not start in time. Submitting a new job." >&2
                jobid=$(submit_job | tail -n 1)
                state=""
                just_submitted=1
                continue
            fi
        fi

        node_name=$(squeue -j "$jobid" -h -o "%N")
        echo "Job: $jobid is running on node: $node_name"
        if [[ "$VERIFY_SSH" -eq 1 ]]; then
            if verify_ssh_access "$node_name"; then
                echo "SSH access granted on node: $node_name"
                echo "$node_name"
                return 0
            else
                echo "SSH access denied on node: $node_name. Submitting a new job." >&2
                jobid=$(submit_job | tail -n 1)
                just_submitted=1
                continue
            fi
        else
            echo "Not verifying SSH access. Returning node: $node_name" >&2
            echo "$node_name"
            return 0
        fi
    done
    
    echo "Maximum retry attempts ($MAX_RETRIES) reached without finding a suitable node." >&2
    return 1
}

main