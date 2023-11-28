# Matrix-specific
alias jobs='squeue -u aswerdlo'
alias cluster='gpu-usage-by-node -p; whoson; /home/aswerdlo/dotfiles/venv/bin/slurm_gpustat --partition kate_reserved'
alias kj='scancel'
alias sb='sbatch.py'
alias mn='matrix_node.py'
alias tailm='tail -f "$(/usr/bin/ls -t ~/logs/*.out | head -n 1)"'
alias bench='sb --gpu_count=0 benchmark_server.py'

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

function normalize() {
  NODE_NAME=$1
  
  if [[ $NODE_NAME =~ ^[0-9]{3}$ ]]; then
    NODE_NAME="matrix-${NODE_NAME:0:1}-${NODE_NAME:1:2}"
  elif [[ $NODE_NAME =~ ^[0-9]{1}-[0-9]{2}$ ]]; then
    NODE_NAME="matrix-$NODE_NAME"
  fi

  if [[ $NODE_NAME =~ ^matrix-[0-9]{1}-[0-9]{2}$ ]]; then
    echo $NODE_NAME
  fi
}

function get_ids(){
  echo "export CUDA_VISIBLE_DEVICES=$(grep -F -f <(nvidia-smi --query-gpu=uuid --format=csv,noheader) ~/perm/scripts/gpu_data/uuids.txt | cut -d, -f1 | paste -sd,)"
}