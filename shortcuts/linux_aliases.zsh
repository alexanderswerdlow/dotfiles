
alias doctor='sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoclean && sudo apt-get clean && sudo apt-get autoremove -y'
alias code-ssh="$DOTFILES/scripts/code_connect.py"

alias enableconda='export PATH="/home/aswerdlo/anaconda3/bin:$PATH" && source ~/anaconda3/etc/profile.d/conda.sh'
alias dl="$HOME/.iterm2/it2dl"
alias psi='ps -u -p'

# Deep learning
alias dash='gotop --nvidia'
alias nv="nvidia-smi"
alias kw='lsof -t "/proc/$$/fd/1" | xargs -I {} ps -u -f {} | grep "$USER" | grep "wandb-service" | grep -v grep | awk '\''{print $2}'\'' | xargs kill -9'
alias kp='pkill -f -u $(whoami) "python"'
alias kcode='ps aux | grep .cursor-server | awk '\''{print $2}'\'' | xargs kill'

alias sizee='nice -n 19 ionice -c 3 duc index . -p --database=$LOCAL_HOME/.duc.db'
alias sizeee='duc ls -Fg . --database=$LOCAL_HOME/.duc.db'

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  alias code='localcode'
fi

# Simple find command
function find_files {
  if [ -x $(command -v fd) ]; then
		fd --type f $1
  else
    find . -name "*$1*" -print
	fi
}

function find_folders {
  fd --type d $1
}

# Kills stubborn processes. Will kill processes on all GPUs

function ggs() {
  if [ -z "$2" ]; then
    lsof -t "/dev/nvidia${1}" | xargs -I {} ps -u -f {}
  else
    lsof -t "/dev/nvidia${1}" | xargs -I {} ps -u -f {} | pgrep -f "$2" | xargs -I {} ps -u -p {}
  fi
}

function kgs() {
  ggs $1 $2 | grep -v PID | awk '{print $2}' | xargs -I {} kill {}
}


function kga(){
  for i ($argv) lsof -t "/dev/nvidia$i" | xargs -I {} kill -9 {}
}

function kgga() {
  local user=$(whoami)
  for i ($argv); do
    lsof -t "/dev/nvidia$i" | xargs -I {} ps -u $user -p {} | grep -v PID | awk '{print $1}' | xargs -r kill -9
  done
}

function kg(){
  lsof -t "/dev/nvidia$1" | xargs -I {} kill -9 {}
}

function kgg() {
  local user=$(whoami)
  lsof -t "/dev/nvidia$1" | xargs -I {} ps -u $user -p {} | grep -v PID | awk '{print $1}' | xargs -r kill -9
}

# Lists all processes running on all GPUs and relevant info
function pp(){
  # Get the PIDs of all GPU processes
  pids=($(nvidia-smi --query-compute-apps=pid --format=csv,noheader))
  
  # Loop through each PID and get the username and process command
  for pid in $pids
  do
      # Get the process information using ps
      info=$(ps -p $pid -o user,%cpu,%mem,cmd --no-headers)
      # Print the process information
      echo "$pid $info"
  done
}

# cv 0123 -> export CUDA_VISIBLE_DEVICES=0,1,2,3
cv() {
  if [ -z "$1" ]; then
    unset CUDA_VISIBLE_DEVICES
  else
    export CUDA_VISIBLE_DEVICES=$(echo $1 | sed 's/./&,/g' | sed 's/,$//')
  fi
}

# This initiates an iTerm2 Trigger on the Server Side
# The client (iTerm2) then calls $DOTFILES/scripts/trigger_vscode.sh
# iTerm2 uses the following regular expression:
# .*ITERM-TRIGGER-open-with-local-vscode-remote ([^ ]+) ([^ ]+) (([^ ]+ ?)+)
# and then calls ->
# ~/dotfiles/scripts/trigger_vscode.sh \1 \2 \3
function localcode() (
    # Tell zsh to use bash-style arrays
    setopt ksh_arrays 2> /dev/null || true

    CMD=ITERM-TRIGGER-open-with-local-vscode-remote
    SSH_IP=$(echo $SSH_CLIENT | awk '{ print $1}')
    if [[ "$(hostname)" == *"babel"* ]]; then
      GPU_JOB_NAME="gpu"
      DATA_JOB_NAME="data"
      LOCALCODE_MACHINE="$(whoami)@$(hostname | sed 's/\.eth$//')"
      if sacct --user=$USER --name=$GPU_JOB_NAME --state=RUNNING --node=$(hostname) --format=JobID --noheader 2>/dev/null | grep -q .; then
        echo "Found job with name $GPU_JOB_NAME on node $(hostname)"
        LOCALCODE_MACHINE="$GPU_JOB_NAME"
      elif sacct --user=$USER --name=$DATA_JOB_NAME --state=RUNNING --node=$(hostname) --format=JobID --noheader 2>/dev/null | grep -q .; then
        echo "Found job with name $DATA_JOB_NAME on node $(hostname)"
        LOCALCODE_MACHINE="$DATA_JOB_NAME"
      fi
    elif [[ "$SSH_IP" == "::1" ]]; then
        LOCALCODE_MACHINE='ssh.aswerdlow.com'
    else
        LOCALCODE_MACHINE="$(whoami)@$(hostname | sed 's/\.eth$//')"
    fi
    MACHINE=${LOCALCODE_MACHINE-submit}
    FILENAMES=( "$@" )

    if [[ ${#FILENAMES[@]} == 0 ]]; then
        FILENAMES=.
    fi

    if [[ ${#FILENAMES[@]} == 1 && -d ${FILENAMES[0]} ]]; then
            FILENAMES[0]=$(cd ${FILENAMES[0]}; pwd)
            FTYPE=directory
            if [[ -n $SLURM_NODE ]]; then
              FILENAMES[0]=$(realpath ${FILENAMES[0]})
              echo "On a slurm node, using realpath: ${FILENAMES[0]}"
            fi
    else
        # Convert filenames to abspaths
        for (( i=0; i < ${#FILENAMES[@]}; i++ )); do
            FN=${FILENAMES[i]}
            if [[ -f ${FN} ]]; then
                DIRNAME=$(cd $(dirname ${FN}); pwd)
                FILENAMES[i]=${DIRNAME}/$(basename ${FN})
                FTYPE=file
            else
                1>&2 echo "Not a valid file: ${FN}"
                exit 1
            fi
        done
    fi

    echo ${CMD} ${FTYPE} ${MACHINE} ${FILENAMES[@]}
)

# Auto-activates a local venv if present
function cd() {
  builtin cd "$@"

  if [[ ! -z "$VIRTUAL_ENV" ]] ; then
    # If the current directory is not contained
    # within the venv parent directory -> deactivate the venv.
    cur_dir=$(pwd -P)
    venv_dir="$(dirname "$VIRTUAL_ENV")"
    if [[ "$cur_dir"/ != "$venv_dir"/* ]] ; then
      deactivate
    fi
  fi

  # Check for .python_version file
  if [[ -f ".python_version" ]] ; then
    venv_dir=$(<.python_version)
    if [[ -d "$venv_dir" ]] ; then
      source "${venv_dir}/bin/activate"
      return
    fi
  fi

  if [[ -z "$VIRTUAL_ENV" ]] ; then
    # If config file is found -> activate the vitual environment
    venv_cfg_filepath=$(find . -maxdepth 2 -type f -name 'pyvenv.cfg' 2> /dev/null)
    if [[ -z "$venv_cfg_filepath" ]]; then
      return # no config file found
    fi

    venv_filepath=$(cut -d '/' -f -2 <<< ${venv_cfg_filepath})
    if [[ -d "$venv_filepath" ]] ; then
      source "${venv_filepath}"/bin/activate
    fi
  fi
}

if [[ -n $SSH_CONNECTION ]]; then
  alias cat='cat_func'
  iterm2check_path="$HOME/.iterm2/it2check"
  iterm2imgcat_path="$HOME/.iterm2/imgcat"
  function cat_func() {
    # Check if iterm2
    if test -e $iterm2check_path && $iterm2check_path && test -e ; then
      # Check if the first argument is a file and an image
      if [[ -f "$1" && "$(file --mime-type -b "$1")" == image/* ]]; then
        $iterm2imgcat_path "$1"
        return
      fi
    fi
    # Fallback to bat if not iterm2 or not an image file
    bat --paging=never --plain "$@"
  }
fi