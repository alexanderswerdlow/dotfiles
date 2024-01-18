#!/bin/bash
srun "$@"
tmux kill-session -t $(tmux display-message -p '#S') 
