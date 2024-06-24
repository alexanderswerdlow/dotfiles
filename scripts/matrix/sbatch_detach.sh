#!/bin/bash

# Check if tmux server is running
if tmux ls &>/dev/null; then
    # Check if the session named "main" exists
    if ! tmux has-session -t main 2>/dev/null; then
        tmux new-session -d -s main
    else
        # Create a session with SLURM_JOB_ID if "main" session exists
        tmux new-session -d -s $SLURM_JOB_ID
        echo "Here 4, $SLURM_JOB_ID"
    fi
else
    # Create a session named "main" if tmux server is not running
    tmux new-session -d -s main
fi

sleep 345600