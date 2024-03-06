#!/bin/bash
echo "SSHing...."
ssh -f "$SLURM_NODELIST" 'LD_LIBRARY_PATH=$HOME/local/lib $HOME/local/bin/tmux new-session -d -s del'
echo "Creating new Tmux..."
tmux new-session -d -s "$SLURM_JOB_ID"
sleep 259200
