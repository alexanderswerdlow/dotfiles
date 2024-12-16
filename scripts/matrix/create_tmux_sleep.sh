#!/bin/bash

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