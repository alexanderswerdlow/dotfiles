#!/bin/bash
# This file simply wraps srun so that we can exit the tmux session when the job finishes
srun "$@"
tmux kill-session -t $(tmux display-message -p '#S')