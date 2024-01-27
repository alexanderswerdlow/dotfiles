# Matrix-specific
export PARTITION='kate_reserved'

# https://github.com/cdt-data-science/cluster-scripts
alias jobs='squeue -o "%.18i %.9P %.35j %.8u %.2t %.10M %.6D %C %m %b %R" -u aswerdlo'
alias cluster='gpu-usage-by-node -p; whoson -g; $DOTFILES/venv/bin/slurm_gpustat --partition $PARTITION'
alias kj='scancel'
alias kjn='scancel --name'
alias sb='sbatch.py'
alias mn='matrix_node.py'
alias tailm='tail -f "$(/usr/bin/ls -t ~/logs/*.out | head -n 1)"'
alias bench='sb --gpu_count=0 benchmark_server.py'
alias jn='getjobsonnode'

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