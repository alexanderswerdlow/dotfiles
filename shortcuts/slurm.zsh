# Matrix-specific
if [[ ${GROGU_NODE:-0} -eq 1 ]]; then
  export PARTITION='deepaklong'
  export SLURM_USER='mprabhud'
elif [[ ${BABEL_NODE:-0} -eq 1 ]]; then
  export PARTITION='general'
  export SLURM_USER=$USER
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

if [[ ${GROGU_NODE:-0} -eq 1 ]]; then
  export gpu_env='/home/mprabhud/micromamba/envs/sedd/bin/gpustat --watch'
else
  export gpu_env='~/anaconda3/envs/sedd/bin/gpustat --watch'
fi

alias wnv="$gpu_env"
alias wnvv="$gpu_env --show-pid --show-user --show-power"
alias wnvvv='watch -n2 -x nvidia-smi'

if [[ ${GROGU_NODE:-0} -eq 1 ]]; then
  alias jobs='squeue -o "%.10i %3P %.18j %.2t %.10M %.2C %.3m %.5b %.11R %.5k" -u $SLURM_USER'
else
  alias jobs='squeue -o "%.14i %8P %.18j %.2t %.10M %.3C %.4m %.12b %.12R" -u $SLURM_USER'
fi

alias jobss='sacct -X -j' # --format=JobID,JobName,Partition,State,ExitCode,Start,End,Elapsed,AllocCPUS,ReqMem,Timelimit,NodeList,AveRSS,AveVMSize,MaxRSS,MaxVMSize,User 
alias wjobs='watchx5 jobs'
alias wcluster='watchx60 cluster'

export DOTFILES_PYTHON_BIN="$DOTFILES/venv/bin"

alias cl="$DOTFILES_PYTHON_BIN/slurm_gpustat"
alias cluster="$DOTFILES_PYTHON_BIN/python /home/aswerdlo/dotfiles/scripts/matrix/gpu.py --verbose"
alias clusterr="$DOTFILES_PYTHON_BIN/python /opt/cluster_tools/babel_contrib/tir_tool/gpu.py"
alias clusterrr='$DOTFILES/scripts/matrix/lib/gpu-usage-by-node -p'
alias cluster_all="$DOTFILES_PYTHON_BIN/python /home/aswerdlo/dotfiles/scripts/matrix/gpu.py --verbose; $DOTFILES/scripts/matrix/lib/whoson -g; $DOTFILES/scripts/matrix/lib/gpu-usage-by-node -p;"

if [[ ${GROGU_NODE:-0} -eq 1 ]]; then
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

alias g='ssh gpu'
alias g1='ssh gpu1'
alias g2='ssh gpu2'
alias g3='ssh gpu3'
alias g4='ssh gpu4'
alias g5='ssh gpu5'
alias g6='ssh gpu6'
alias g7='ssh gpu7'
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
alias nv='uvx nvitop'
alias nvv='uvx gpustat --watch --show-pid --show-cmd'
alias nf='nfsflush .'

alias jobs='squeue -o "%.14i %8P %.18j %.2t %.10M %.3C %.4m %.12b %.12R" -u $SLURM_USER'
alias gjj='sacct --long --yaml -j'
alias sd='ssh data'

function nfw() {
  watch -n5 'zsh -c "source /home/aswerdlo/dotfiles/shortcuts/functions.zsh; nfsflush_all ."'
}

function tf() { 
  tail -f -n100 $1
}

function pythoninfo() {
    python -c "import sys, site, platform, os; print(platform.processor(), os.uname(), sys.version, sys.executable, sys.path, site.getsitepackages())"
}

function nodee() {
  local jobid=$(sbatch --time=7-00:00 --partition=preempt -c12 --mem=128G $(get_exclude_nodes "L40|L40S|A100_40GB|A100_80GB|6000Ada") --gres=gpu:1 --wrap="sleep infinity" | grep -o '[0-9]\+')
  echo "Waiting for job $jobid to start..."
  while true; do
    local state=$(scontrol show job $jobid | grep JobState | grep -o 'RUNNING')
    if [[ $state == "RUNNING" ]]; then
      local nodename=$(scontrol show job $jobid | grep BatchHost | cut -d'=' -f2)
      echo "Job is running on node $nodename"
      ssh $nodename
      break
    fi
    sleep 1
  done
}

function node() {
  local partition="debug"
  local gpus=1
  local cpus=12
  local mem="128G"
  local exclude="$BAD_NODES"
  local constraint="L40|L40S|A100_40GB|A100_80GB|6000Ada"
  local time="6:00:00"
 
  local ARGS=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p=*|--partition=*) partition="${1#*=}"; shift ;;
      -p|--partition) partition="$2"; shift 2 ;;
      -c=*|--cpus=*) cpus="${1#*=}"; shift ;;
      -c*) cpus="${1#-c}"; shift ;;  # Handle -c8 format
      -c|--cpus) cpus="$2"; shift 2 ;;
      -m=*|--mem=*) mem="${1#*=}"; shift ;;
      -m|--mem) mem="$2"; shift 2 ;;
      -g=*|--gres=*) gpus="${1#*=}"; shift ;;
      -g|--gres) gpus="$2"; shift 2 ;;
      -t=*|--time=*) time="${1#*=}"; shift ;;
      -t|--time) time="$2"; shift 2 ;;
      --constraint=*) constraint="${1#*=}"; shift ;;
      --constraint) constraint="$2"; shift 2 ;;
      -e=*|--exclude=*) exclude="${1#*=}"; shift ;;
      -e|--exclude) exclude="$2"; shift 2 ;;
      *) ARGS+=("$1"); shift ;;
    esac
  done

  echo "--time=$time --partition=$partition --cpus-per-task=$cpus --hint=nomultithread --mem=$mem --exclude=$exclude --constraint=\"$constraint\" --gres=gpu:$gpus"
  if [[ "$partition" == "preempt" ]]; then
    jobid=$(sbatch --time=$time --partition=$partition --cpus-per-task=$cpus --hint=nomultithread --mem=$mem --exclude=$exclude --constraint="$constraint" --gres=gpu:$gpus --wrap="sleep infinity" | grep -o '[0-9]\+')
    echo "Waiting for job $jobid to start..."
    while true; do
      local state=$(scontrol show job $jobid | grep JobState | grep -o 'RUNNING')
      if [[ $state == "RUNNING" ]]; then
        local nodename=$(scontrol show job $jobid | grep BatchHost | cut -d'=' -f2)
        echo "Job is running on node $nodename"
        ssh $nodename
        break
      fi
      sleep 1
    done
  else
    srun --time=$time --partition=$partition --cpus-per-task=$cpus --hint=nomultithread --mem=$mem --exclude=$exclude --constraint="$constraint" --gres=gpu:$gpus --pty $SHELL "${ARGS[@]}"
  fi
}

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

# Finds the job stdout file and tails the last 100 lines (by default). Uses sacct so it works even for inactive jobs.
function sj() {
  local n_arg="-n 100"
  local jobid=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n*) n_arg="-n ${1#-n}"; shift ;;
      *) jobid="$1"; shift ;;
    esac
  done

  if [[ -z "$jobid" ]]; then
    echo "Error: Job ID is required"
    return 1
  fi

  while true; do
    job_info=$(sacct --user=$USER --long --json -j $jobid 2>/dev/null)
    if [[ $? -ne 0 ]]; then
      echo "Error: Failed to get job info"
      return 1
    fi
    
    stdout_pattern=$(echo "$job_info" | jq -r '.jobs[0].stdout')
    stdout_path=$(echo "$job_info" | jq -r '.jobs[0].stdout_expanded')
    elapsed=$(echo "$job_info" | jq -r '.jobs[0].time.elapsed')

    # For some reason, sacct does the expansion of %A wrong and puts the job id (not the master array id) in the stdout_pattern
    if [[ "$stdout_pattern" == *"%A"* && ! "$stdout_pattern" =~ "%[^Aaj]" ]]; then
      master_job_id=$(echo "$job_info" | jq -r '.jobs[0].array.job_id')
      job_id=$(echo "$job_info" | jq -r '.jobs[0].job_id')
      task_id=$(echo "$job_info" | jq -r '.jobs[0].array.task_id.number')
      final_stdout=$(echo "$stdout_pattern" | sed "s/%A/$master_job_id/g" | sed "s/%a/$task_id/g" | sed "s/%j/$job_id/g")
    else
      final_stdout="$stdout_path"
    fi

    if [[ -f "$final_stdout" ]]; then
      echo "Following $final_stdout"
      tail -f $n_arg "$final_stdout"
      break
    elif [[ $elapsed -gt 100 ]]; then
      echo "Job completed but output file $final_stdout does not exist"
      break
    else
      state=$(echo "$job_info" | jq -r '.jobs[0].state.current[0]')
      echo "Waiting for job output file to be created... Current state: $state"
      sleep 5
    fi
  done
}

function sjj() {
  local jobid=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      *) jobid="$1"; shift ;;
    esac
  done

  if [[ -z "$jobid" ]]; then
    echo "Error: Job ID is required"
    return 1
  fi

  while true; do
    job_info=$(sacct --user=$USER --long --json -j $jobid 2>/dev/null)
    if [[ $? -ne 0 ]]; then
      echo "Error: Failed to get job info"
      return 1
    fi
    
    stdout_path=$(echo "$job_info" | jq -r '.jobs[0].stdout_expanded')
    elapsed=$(echo "$job_info" | jq -r '.jobs[0].time.elapsed')
    if [[ -f "$stdout_path" ]]; then
      echo "$stdout_path"
      break
    else
      state=$(echo "$job_info" | jq -r '.jobs[0].state.current[0]')
      echo "Waiting for job output file to be created... Current state: $state"
      sleep 5
    fi
  done
}

function grepj() { 
  grep $1 $MDLM_ROOT_OUTPUT_DIR/outputs/logs/$2*
}

function getjobsonnode() {
  matrixname=$(cluster_normalize $1)
  for job in $(squeue -w $matrixname -o %i -h); 
    do scontrol show job $job | egrep 'JobId|UserId|JobState|EndTime|TRES';
    echo;
  done
  scontrol show node $matrixname
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

# Not required on babel
function get_ids(){
  echo "$(grep -F -f <(nvidia-smi --query-gpu=uuid --format=csv,noheader) $HOMEDIR/perm/scripts/gpu_data/uuids.txt | cut -d, -f1 | paste -sd,)"
}

# Not required on babel
function scuda(){
  devs=$(job_database.py get_gpus "$MACHINE_NAME")
  echo "Setting CUDA_VISIBLE_DEVICES=$devs"
  export CUDA_VISIBLE_DEVICES=$devs
}

# Not required anymore since we have --constraint
function get_exclude_nodes() {
    # Combine arguments and replace '|' with spaces to handle both formats
    local desired_gpus="${@//|/ }"
    local -a gpu_types
    gpu_types=(${=desired_gpus})

    # Get the sinfo output and skip the header line
    local -a sinfo_output
    sinfo_output=($(sinfo -N -o "%N %G" | tail -n +2))

    local -A node_gpus  # Associative array to map nodes to their GPU types

    # Process sinfo output to populate node_gpus
    local i node gres
    for ((i=1; i<=$#sinfo_output; i+=2)); do
        node=${sinfo_output[i]}
        gres=${sinfo_output[i+1]}
        # Extract the GPU type from the GRES field
        local gpu_type=${${(s/:/)gres}[2]}
        node_gpus[$node]=$gpu_type
    done

    # Build a list of nodes to exclude
    local -a exclude_nodes
    for node in ${(k)node_gpus}; do
        gpu_type=${node_gpus[$node]}
        # Check if the GPU type is not in the desired list
        if (( ! ${gpu_types[(Ie)$gpu_type]} )); then
            exclude_nodes+=$node
        fi
    done

    # Remove any nodes that are in the BAD_NODES list
    if [[ -n "$BAD_NODES" ]]; then
        exclude_nodes+=(${(s:,:)BAD_NODES})
    fi

    # Output the exclude list in the format '--exclude=node1,node2,...'
    if [[ ${#exclude_nodes[@]} -gt 0 ]]; then
        local exclude_list
        exclude_list=$(IFS=,; echo "${exclude_nodes[*]}")
        echo "--exclude=$exclude_list"
    else
        echo ""
    fi
}

# Not required anymore since we have --constraint
function get_exclude_nodes_include_only() {
    # Check if at least one argument is provided
    if [[ $# -lt 1 ]]; then
        echo "Usage: get_exclude_nodes_include_only \"node1,node2,...\""
        return 1
    fi

    # Combine all arguments into a single string and replace commas with spaces
    local include_input="${1//,/ }"
    local -a include_nodes
    include_nodes=(${=include_input})

    # Get the list of all unique nodes using sinfo and skip the header line
    # The '-h' flag omits the header, and 'sort -u' ensures uniqueness
    local -a all_nodes
    all_nodes=($(sinfo -p ${2:-"general"} -h -N -o "%N" | sort -u))

    # Create an associative array for quick lookup of included nodes
    local -A include_map
    for node in "${include_nodes[@]}"; do
        include_map[$node]=1
    done

    # Build the list of nodes to exclude (all nodes not in include_map)
    local -a exclude_nodes
    for node in "${all_nodes[@]}"; do
        if [[ -z "${include_map[$node]}" ]]; then
            exclude_nodes+=("$node")
        fi
    done

    # Remove any potential duplicates in exclude_nodes (extra safety)
    exclude_nodes=("${(@u)exclude_nodes}")

    # Output the exclude list in the format '--exclude=node1,node2,...'
    if [[ ${#exclude_nodes[@]} -gt 0 ]]; then
        local exclude_list
        exclude_list=$(IFS=,; echo "${exclude_nodes[*]}")
        echo "--exclude=$exclude_list"
    else
        # If no nodes to exclude, output an empty string
        echo ""
    fi
}

# Not required anymore since we have --constraint
function get_nodes_by_gpu_type() {
    local gpu_type="$1"

    # Ensure a GPU type is provided
    if [[ -z "$gpu_type" ]]; then
        echo "Usage: get_nodes_by_gpu_type <gpu_type>"
        return 1
    fi

    # Extract node names where the GPU type matches the specified type
    sinfo -N -o "%N %G" | tail -n +2 | awk -v type="$gpu_type" '
    {
        split($2, gres_parts, ":")
        if (gres_parts[2] == type) {
            print $1
        }
    }' | paste -sd "," -
}



