#!/bin/bash

JOB_NAME="data"

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
    jobid=$(sbatch -p general --job-name="$JOB_NAME" --time=2-00:00:00 -c12 --mem=32g --output=/dev/null --error=/dev/null --wrap="sleep infinity" | grep -o '[0-9]\+')
    echo "Did not find existing job, submitted job $jobid"
    wait_for_job "$jobid"
fi