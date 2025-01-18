#!/bin/bash

# Check for --gpu flag
USE_GPU=false
if [[ "$1" == "--gpu" ]]; then
    USE_GPU=true
    JOB_NAME="gpu"
else
    JOB_NAME="data"
fi

# SB_CMD="--wrap 'sleep infinity'"
SB_CMD="/home/aswerdlo/dotfiles/scripts/matrix/create_tmux_sleep.sh"

SACCT_ARGS="--user=$USER --name=$JOB_NAME --starttime=now-2days --json"
JQ_FILTER='.jobs | map(select(
    (.state.current[0] == "RUNNING" or .state.current[0] == "PENDING") and
    (.time.elapsed | tonumber) <= 43200
))'

# Check if a recent job exists (either running or pending)
check_job_exists() {
    sacct $SACCT_ARGS 2>/dev/null | \
    jq -e "${JQ_FILTER} | length > 0" > /dev/null
}

wait_for_job() {
    local jobid=$1
    while true; do
        job_info=$(sacct $SACCT_ARGS -j "$jobid" 2>/dev/null)
        if [[ $? -ne 0 ]]; then
            echo "Job $jobid not found in sacct"
            exit 1
        fi
        state=$(echo "$job_info" | jq -r '.jobs[0].state.current[0]')
        case "$state" in
            "RUNNING")
                node_name=$(squeue -j "$jobid" -h -o "%N")
                echo "$node_name"
                exit 0
                ;;
            "PENDING")
                sleep 0.5
                ;;
            "FAILED"|"CANCELLED"|"TIMEOUT")
                echo "Job $jobid failed, state: $state"
                exit 1
                ;;
        esac
    done
}

if check_job_exists; then
    # First try to get a running job, if none exist, get the most recent pending job
    jobid=$(sacct $SACCT_ARGS 2>/dev/null | \
            jq -r "${JQ_FILTER} | 
                sort_by(.submit_time) | reverse | 
                (map(select(.state.current[0] == \"RUNNING\"))[0] // map(select(.state.current[0] == \"PENDING\"))[0]).job_id")
    echo "Found job $jobid"
    wait_for_job "$jobid"
else
    # Submit a job and wait for it
    # --partition=debug --time=6:00:00
    # --partition=array --array=0-0%1 --time=2-00:00:00
    if $USE_GPU; then
        jobid=$(sbatch --partition=debug --time=6:00:00 --job-name=$JOB_NAME --constraint="A100_40GB|A100_80GB|L40S" --gres=gpu:1 -c12 --mem=64G --output=/dev/null --error=/dev/null $SB_CMD | grep -o '[0-9]\+')
    else
        jobid=$(sbatch --partition=general --time=2-00:00:00 --job-name=$JOB_NAME -c12 --mem=32G --output=/dev/null --error=/dev/null $SB_CMD | grep -o '[0-9]\+')
    fi
    echo "Did not find existing job, submitted job $jobid"
    wait_for_job "$jobid"
fi