#!/bin/bash
# This file simply wraps srun so that we can exit the tmux session when the job finishes
echo "Running command: $@"
srun "$@"

exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo "Command exited with non-zero status. Sleeping for 120 seconds."
    sleep 120
else
    echo "Command completed successfully."
fi

tmux kill-session -t $(tmux display-message -p '#S')