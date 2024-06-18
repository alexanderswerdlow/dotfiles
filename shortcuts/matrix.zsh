# Matrix-specific
export PARTITION='kate_reserved'

# https://github.com/cdt-data-science/cluster-scripts
alias watchh='watch '
alias watchx='watch -x '
alias watchx5='watch -n5 -x '
alias watchx10='watch -n10 -x '
alias watchx60='watch -n60 -x '
alias wnv='~/anaconda3/envs/sedd/bin/gpustat --watch'
alias wnvv='~/anaconda3/envs/sedd/bin/gpustat --watch --show-pid --show-user --show-power'
alias wnvvv='watch -n2 -x nvidia-smi'
alias jobs='squeue -o "%.10i %3P %.18j %.2t %.10M %.2C %.3m %.5b %.11R" -u aswerdlo'
alias jobss='sacct -X -j' # --format=JobID,JobName,Partition,State,ExitCode,Start,End,Elapsed,AllocCPUS,ReqMem,Timelimit,NodeList,AveRSS,AveVMSize,MaxRSS,MaxVMSize,User 
alias wjobs='watchx10 jobs'
alias wcluster='watchx60 cluster'
alias cluster='$DOTFILES/scripts/matrix/lib/gpu-usage-by-node -p'
alias cluster_all='$DOTFILES/venv/bin/slurm_gpustat --partition $PARTITION; $DOTFILES/scripts/matrix/lib/whoson -g; $DOTFILES/scripts/matrix/lib/gpu-usage-by-node -p'
alias kj='scancel'
alias kjn='scancel --name'
alias sb='sbatch.py'
alias mn='matrix_node.py'
alias tailm='tail -f "$(/usr/bin/ls -t ~/logs/*.out | head -n 1)"'
alias bench='sb --gpu_count=0 benchmark_server.py'
alias gjn='getjobsonnode'
alias gj='scontrol show job'

alias nfs='nfsiostat 2 /home/aswerdlo /projects/katefgroup'
alias nfsa='watch -n1 nfsiostat'

alias kjp='squeue -u aswerdlo --state=PENDING -h -o "%i %t" | awk '\''$2=="PD"{print $1}'\'' | xargs -I {} scancel {}'

alias sizee='nice -n 19 ionice -c 3 duc index . -p --database=$LOCAL_HOME/.duc.db'
alias sizeee='duc ls -Fg . --database=$LOCAL_HOME/.duc.db'

# sinline -n matrix-1-24 -c 'echo "It'\''s so convenient!"'

function getjobsonnode() {
  matrixname=$(matrix_normalize $1)
  for job in $(squeue -w $matrixname -o %i -h); 
    do scontrol show job $job | egrep 'JobId|UserId|JobState|EndTime|TRES';
    echo;
  done
}

function getjobid(){
  jobid=$(squeue -u aswerdlo -w "$MACHINE_NAME" --Format='JobID' | sed -n '2p' | /bin/tr -d '[:space:]')
  echo "$jobid"
}

function cudavisibledevices() {
  if [[ -v MATRIX_HEAD_NODE ]]; then
    gpu_ids=""
  elif [ -n "$SLURM_JOB_ID" ]; then
    gpu_ids=$(nvidia-smi --query-gpu=gpu_name --format=csv,noheader,nounits | awk '{print NR-1}' | /bin/tr '\n' ',' | sed 's/,$//')
  else
    gpu_ids=$(scontrol show job -d $(getjobid) | grep -oP 'GRES=gpu\(IDX:\K[^)]+')
  fi
  echo "$gpu_ids"
}

function get_ids(){
  echo "$(grep -F -f <(nvidia-smi --query-gpu=uuid --format=csv,noheader) $HOME/perm/scripts/gpu_data/uuids.txt | cut -d, -f1 | paste -sd,)"
}