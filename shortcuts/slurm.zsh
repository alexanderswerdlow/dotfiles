# Matrix-specific
if [[ -v GROGU_NODE ]]; then
  export PARTITION='deepaklong'
  export SLURM_USER='mprabhud'
else
  export PARTITION='kate_reserved'
  export SLURM_USER=$USER
fi

# https://github.com/cdt-data-science/cluster-scripts
alias watchh='watch '
alias watchx='watch -x '
alias watchx5='watch -n5 -x '
alias watchx10='watch -n10 -x '
alias watchx60='watch -n60 -x '
if [[ -v GROGU_NODE ]]; then
  export gpu_env='/home/mprabhud/micromamba/envs/sedd/bin/gpustat --watch'
else
  export gpu_env='~/anaconda3/envs/sedd/bin/gpustat --watch'
fi
alias wnv="$gpu_env"
alias wnvv="$gpu_env --show-pid --show-user --show-power"
alias wnvvv='watch -n2 -x nvidia-smi'

if [[ -v GROGU_NODE ]]; then
  alias jobs='squeue -o "%.10i %3P %.18j %.2t %.10M %.2C %.3m %.5b %.11R %.5k" -u $SLURM_USER'
else
  alias jobs='squeue -o "%.10i %3P %.18j %.2t %.10M %.2C %.3m %.5b %.11R" -u $SLURM_USER'
fi

alias jobss='sacct -X -j' # --format=JobID,JobName,Partition,State,ExitCode,Start,End,Elapsed,AllocCPUS,ReqMem,Timelimit,NodeList,AveRSS,AveVMSize,MaxRSS,MaxVMSize,User 
alias wjobs='watchx5 jobs'
alias wcluster='watchx60 cluster'
alias cluster='$DOTFILES/scripts/matrix/lib/gpu-usage-by-node -p'
alias cluster_all='$DOTFILES/venv/bin/slurm_gpustat --partition $PARTITION; $DOTFILES/scripts/matrix/lib/whoson -g; $DOTFILES/scripts/matrix/lib/gpu-usage-by-node -p'

if [[ -v GROGU_NODE ]]; then
  # alias kj='squeue --me --states=RUNNING --Format=jobid,comment --noheader | grep "aswerdlo" | awk '\''{print $1}'\'' | xargs scancel'
  function kj() {
    local job_id=$1
    local required_comment='aswerdlo'
    local job_comment=$(squeue --job=$job_id --Format=jobid,comment --noheader | awk '{print $2}')

    if [[ "$job_comment" == *"$required_comment"* ]]; then
      scancel $job_id
      echo "Job $job_id with comment '$required_comment' has been cancelled."
    else
      echo "WARNING: Job $job_id does not contain the required comment or does not exist."
    fi
  }
else
  alias kj='scancel'
fi

alias kjn='scancel --name'
alias sba='sbatch.py'
alias mn='matrix_node.py'
alias tailm='tail -f "$(/usr/bin/ls -t ~/logs/*.out | head -n 1)"'
alias bench='sb --gpu_count=0 benchmark_server.py'
alias gjn='getjobsonnode'
alias gj='scontrol show job'

alias nfs='nfsiostat 2 $HOME /projects/katefgroup'
alias nfsa='watch -n1 nfsiostat'
alias kjp='squeue -u $SLURM_USER --state=PENDING -h -o "%i %t" | awk '\''$2=="PD"{print $1}'\'' | xargs -I {} scancel {}'

# sinline -n matrix-1-24 -c 'echo "It'\''s so convenient!"'

function wf() {
  local dir
  if [[ -n $1 ]]; then
    if [[ -f $1 ]]; then
      dir=$(dirname "$1")
    elif [[ -d $1 ]]; then
      tail -n +1 -f "$1"/.submitit/**/*.out
      return
    else
      dir=$(scontrol show job $1 | grep -oP "StdOut=\K[^ ]+" | xargs dirname)
    fi
  else
    local jobid=$(squeue -u $USER --sort=-i | awk 'NR==2 {print $1}')
    dir=$(scontrol show job $jobid | grep -oP "StdOut=\K[^ ]+" | xargs dirname)
  fi

  tail -n +1 -f "$dir"/*.out
}


function getjobsonnode() {
  matrixname=$(cluster_normalize $1)
  for job in $(squeue -w $matrixname -o %i -h); 
    do scontrol show job $job | egrep 'JobId|UserId|JobState|EndTime|TRES';
    echo;
  done
}

function getjobid(){
  jobid=$(squeue -u $SLURM_USER -w "$MACHINE_NAME" --Format='JobID' | sed -n '2p' | /bin/tr -d '[:space:]')
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
  echo "$(grep -F -f <(nvidia-smi --query-gpu=uuid --format=csv,noheader) $HOMEDIR/perm/scripts/gpu_data/uuids.txt | cut -d, -f1 | paste -sd,)"
}

function scuda(){
  devs=$(job_database.py get_gpus "$MACHINE_NAME")
  echo "Setting CUDA_VISIBLE_DEVICES=$devs"
  export CUDA_VISIBLE_DEVICES=$devs
}