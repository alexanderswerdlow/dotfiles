#!/bin/bash
# This file simply wraps srun so that we can exit the tmux session when the job finishes
echo "Running command: $@"
srun "$@"
tmux kill-session -t $(tmux display-message -p '#S')