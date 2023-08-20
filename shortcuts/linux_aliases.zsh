alias dash='gotop --nvidia'
alias doctor='sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoclean && sudo apt-get clean && sudo apt-get autoremove -y'
alias code-ssh="$DOTFILES/scripts/code_connect.py"

alias tn='tmux new -s'
alias tr='tmux attach -t'
alias trr='tmux -CC attach -t'
alias ts='tmux ls'
alias tk='tmux kill-session -t'
alias gdu='gdu-go'

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  alias code='localcode'
fi

# Simple find command
function ffind {
  find . -name "*$1*" -print
}

# Kills stubborn processes. Will kill processes on all GPUs
function kg(){
  for i ($argv) lsof -t "/dev/nvidia$i" | xargs -I {} kill -9 {}
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
    if [[ "$SSH_IP" == "::1" ]]; then
        LOCALCODE_MACHINE='ssh.aswerdlow.com'
    else
        LOCALCODE_MACHINE="$(whoami)@$(echo $SSH_CONNECTION | awk '{print $3}')"
    fi
    MACHINE=${LOCALCODE_MACHINE-submit}
    FILENAMES=( "$@" )

    if [[ ${#FILENAMES[@]} == 0 ]]; then
        FILENAMES=.
    fi

    if [[ ${#FILENAMES[@]} == 1 && -d ${FILENAMES[0]} ]]; then
            FILENAMES[0]=$(cd ${FILENAMES[0]}; pwd)
            FTYPE=directory
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