function rga-fzf() {
	RG_PREFIX="rga --files-with-matches --rga-cache-max-blob-len=50000000 --rga-adapters=-decompress,zip,tar"
	local file
	file="$(
		FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
			fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
				--phony -q "$1" \
				--bind "change:reload:$RG_PREFIX {q}" \
				--preview-window="70%:wrap"
	)" &&
	echo "opening $file" &&
	subl "$file"
}

function rg-fzf(){
  INITIAL_QUERY=$1
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
    fzf --bind "change:reload:$RG_PREFIX {q} || true" \
        --ansi --disabled --query "$INITIAL_QUERY" \
        --height=50% --layout=reverse
}

function jdk() {
    version=$1
    export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
    java -version
}

function timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

function gcd() {
  git clone "$1" && cd "$(basename "$1" .git)"
}

function upgrade() {
    $1 -m pip install --upgrade pip
}

function sman() {
    unset PAGER
    man $1 | col -b | subl
}

function take() {
  mkdir $1 && cd $1
}

# Example Usage: matlabr script.m
function matlabr {
  matlabb -nodisplay -nosplash -nodesktop -r "run('$1');"
}

function venv {
  $1 -m venv venv
}

# function code () {
#   local script=$(echo ~/.vscode-server/bin/*/bin/code(*ocNY1)) 
#   if [[ -z ${script} ]]
#   then
#       echo "VSCode remote script not found"
#       exit 1
#   fi
#   local socket=$(echo /run/user/$UID/vscode-ipc-*.sock(=ocNY1))
#   if [[ -z ${socket} ]]
#   then
#       echo "VSCode IPC socket not found"
#       exit 1
#   fi
#   export VSCODE_IPC_HOOK_CLI=${socket}
#   ${script} $*
#  }


function xkcd {
  URL=https://xkcd.com/ 
  if [ $# -gt 0 ]  && [ $1 = "-r" ]
  then
    URL=https://c.xkcd.com/random/comic
  fi

  img=$(curl -s -L $URL | 
  grep 'href= "https://imgs.xkcd.com/comics.*' | 
  cut -d'>' -f2 | 
  cut -d'<' -f1)

  kitty +kitten icat $img
}

function fn {
  find "$1" -type f | wc -l
}

function vpn-up() {
  echo "Starting the vpn ..."
  echo $UCLA_PASSWORD | sudo openconnect --background --passwd-on-stdin --user=$UCLA_USERNAME $UCLA_VPN_URL
}

function vpn-down() {
  sudo kill -2 `pgrep openconnect`
}

function download() {
  wget -i - <<< $1
}

function tl() {
  tmux -CC new -A -s main
}

function t() {
  SSHCMD=$(command -v autossh &> /dev/null && echo autossh || echo ssh)
  $SSHCMD -t $1 'tmux -CC new -A -s main'
}

function tg() {
  if (( $# > 0 )); then
    server=$(cluster_normalize $1 "grogu")
  else
    server="grogu"
  fi

  SSHCMD=$(command -v autossh &> /dev/null && echo autossh || echo ssh)
  LC_MESSAGES="TMUX" $SSHCMD -t $server 'LD_LIBRARY_PATH=$HOME/local/lib $HOME/local/bin/tmux -L aswerdlo -f "/home/mprabhud/aswerdlo/dotfiles/.tmux.conf" -CC new -A -s main'
}

function tt() {
  if (( $# > 0 )); then
    server=$(cluster_normalize $1 "matrix")
  else
    server="matrix.ml.cmu.edu"
  fi
  SSHCMD=$(command -v autossh &> /dev/null && echo autossh || echo ssh)
  $SSHCMD -t $server 'LD_LIBRARY_PATH=$HOME/local/lib $HOME/local/bin/tmux -CC new -A -s main'
}

function tb() {
  if (( $# > 0 )); then
    server=$(cluster_normalize $1 "babel")
  else
    server="babel"
  fi
  SSHCMD=$(command -v autossh &> /dev/null && echo "autossh" || echo ssh)
  $SSHCMD -t $server 'LD_LIBRARY_PATH=$HOME/local/lib $HOME/local/bin/tmux -CC new -A -s main'
}

function tsp() {
  et $HOME_HOSTNAME -c 'tmux -CC new -A -s main'
}

function ttt() {
  ssh $1 -t 'tmux -CC new -A -s main'
}

function sg() {
  if (( $# > 0 )); then
    ssh $(cluster_normalize $1 "grogu")
  else
    ssh grogu
  fi
}

function sm() {
  if (( $# > 0 )); then
    ssh $(cluster_normalize $1 "matrix")
  else
    ssh matrix
  fi
}

function sb() {
  if (( $# > 0 )); then
    ssh $(cluster_normalize $1 "babel")
  else
    ssh babel
  fi
}

function r() {
  if alias tmux &>/dev/null; then
    if (( $# > 0 )); then
      tmux attach -t $1
    else
      tmux attach -t main
    fi
  else
    if (( $# > 0 )); then
      command tmux attach -t $1
    else
      command tmux attach -t main
    fi
  fi
}

function cluster_normalize() {
  NODE_NAME=$1
  
  if (( $# > 1 )); then
    CURRENT_CLUSTER_NAME="${2}-"
  else
    CURRENT_CLUSTER_NAME="${CLUSTER_NAME}-"
  fi
  
  if [[ $NODE_NAME =~ ^[0-9]{3}$ ]]; then
    NODE_NAME="${CURRENT_CLUSTER_NAME}${NODE_NAME:0:1}-${NODE_NAME:1:3}"
  elif [[ $NODE_NAME =~ ^[0-9]{4}$ ]]; then
    NODE_NAME="${CURRENT_CLUSTER_NAME}${NODE_NAME:0:2}-${NODE_NAME:2:4}"
  elif [[ $NODE_NAME =~ ^[0-9]{1}-[0-9]{2}$ ]]; then
    NODE_NAME="${CURRENT_CLUSTER_NAME}$NODE_NAME"
  elif [[ $NODE_NAME =~ ^[0-9]{1}-[0-9]{1}$ ]]; then
    NODE_NAME="${CURRENT_CLUSTER_NAME}$NODE_NAME"
  elif [[ $NODE_NAME =~ ^[0-9]{2}-[0-9]{2}$ ]]; then
    NODE_NAME="${CURRENT_CLUSTER_NAME}$NODE_NAME"
  elif [[ $NODE_NAME =~ ^[0-9]{2}-[0-9]{1}$ ]]; then
    NODE_NAME="${CURRENT_CLUSTER_NAME}$NODE_NAME"
  elif [[ $NODE_NAME =~ ^[0-9]{2}$ ]]; then
    NODE_NAME="${CURRENT_CLUSTER_NAME}${NODE_NAME:0:1}-${NODE_NAME:1:2}"
  fi

  if [[ $NODE_NAME =~ ^${CURRENT_CLUSTER_NAME}[0-9]{1}-[0-9]{2}$ ]]; then
    echo $NODE_NAME
  elif [[ $NODE_NAME =~ ^${CURRENT_CLUSTER_NAME}[0-9]{1}-[0-9]{1}$ ]]; then
    echo $NODE_NAME
  elif [[ $NODE_NAME =~ ^${CURRENT_CLUSTER_NAME}[0-9]{2}-[0-9]{2}$ ]]; then
    echo $NODE_NAME
  elif [[ $NODE_NAME =~ ^${CURRENT_CLUSTER_NAME}[0-9]{2}-[0-9]{1}$ ]]; then
    echo $NODE_NAME
  fi
}

function scratch() {
  take "$HOME/Documents/scratch/$(date +%s)" && code . && ipython
}

function ghcopilotinit() {
  unalias ghe >/dev/null 2>&1
  unalias ghc >/dev/null 2>&1
  unalias ghcs >/dev/null 2>&1
  unalias ghce >/dev/null 2>&1
  eval "$(gh copilot alias -- zsh)"
  alias ghe="ghce"
  alias ghc="ghcs"
}

alias ghe="ghcopilotinit && ghce"
alias ghc="ghcopilotinit && ghcs"

alias ghce="ghcopilotinit && ghce"
alias ghcs="ghcopilotinit && ghcs"


function iterm_notify() {
  if [[ $? -ne 0 ]]; then
    BADEXIT="The program failed with exit code $?."
  fi

  if [ $# -eq 0 ]; then
    if [[ -v BADEXIT ]]; then
      MESSAGE="$BADEXIT"
    else
      MESSAGE="Process Finished"
    fi
  else
    MESSAGE="$@"
  fi

  if [[ -v BADEXIT ]]; then
    echo && echo -en iTerm""NotifyBadExit "$MESSAGE\r" && sleep 1 && echo "     "
  else
    echo && echo -en iTerm""Notify "$MESSAGE\r" && sleep 1 && echo "     "
  fi
}

check_home_usage() {
  local usage=$(df ~ | awk 'NR==2{print substr($5, 1, length($5)-1)}')
  if [[ $usage -ge 95 ]]; then
    echo "Warning: Your home directory is $usage% full!"
  fi
}

function installdeps() {
  pip install 'git+https://github.com/alexanderswerdlow/image_utils.git@wip_v1'
  pip install 'imageio[ffmpeg]>=2.23.0' 'av>=10.0.0' 'lovely-tensors>=0.1.14' 'lovely-numpy>=0.2.8'
  if [[ $OS == "macos" ]]; then
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
  elif [[ $OS == "linux" ]]; then
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
  fi
}

function gsh() {
  gcloud alpha compute tpus tpu-vm ssh aswerdlow@$1 --zone ${ZONE:-us-central2-b} --ssh-flag="-A" "${@:2}" "${@:3}"
}

function gsha() {
  gcloud alpha compute tpus tpu-vm ssh aswerdlow@$1 --zone ${ZONE:-us-central2-b} --ssh-flag="-A" --worker=all --command=$2 "${@:3}"
}

function tgsh() {
  gcloud alpha compute tpus tpu-vm ssh aswerdlow@$1 --zone ${ZONE:-us-central2-b} --ssh-flag="-A" "${@:2}" "${@:3}" --tunnel-through-iap
}

function tgsha() {
  gcloud alpha compute tpus tpu-vm ssh aswerdlow@$1 --zone ${ZONE:-us-central2-b} --ssh-flag="-A" --worker=all --command=$2 "${@:3}" --tunnel-through-iap
}


function tgsho() {
  for i in {0..$(($3-1))}; do
    echo "ssh worker $i"
    gcloud alpha compute tpus tpu-vm ssh aswerdlow@$1 --zone ${ZONE:-us-central2-b} --ssh-flag="-A" --worker=$i --command=$2 --tunnel-through-iap
  done
}

# function gsho() {
#   gcloud alpha compute tpus tpu-vm ssh aswerdlow@$1 --zone ${ZONE:-us-central2-b} --ssh-flag="-A" --worker=0 --command="source ~/.minimal_shell.sh; $2" --verbosity=debug "${@:3}"
# }



# function gshi() {
#   gcloud alpha compute tpus tpu-vm ssh aswerdlow@$1 --zone ${ZONE:-us-central2-b} --ssh-flag="-A" --worker=all --command="source ~/.minimal_shell.sh; $2" "${@:3}"
# }

# function gshii() {
#   gcloud alpha compute tpus tpu-vm ssh aswerdlow@$1 --zone ${ZONE:-us-central2-b} --ssh-flag="-A" --worker=$3 --command="source ~/.minimal_shell.sh; $2" "${@:4}"
# }


function nfsflush_all() {
  FD_PATH="$HOME/bin/fd"
  NFSFLUSH_PATH="$HOME/bin/nfsflush"

  local paths=("$@")

  # If no paths are provided, use the current directory
  if [ ${#paths[@]} -eq 0 ]; then
    paths=(".")
  fi

  # Array to store all directories to flush
  local dirs=()

  # Find directories starting from the specified paths
  for path in "${paths[@]}"; do
    # Use fd to find directories, respecting .gitignore
    while IFS= read -r -d '' dir; do
      dirs+=("$dir")
    done < <($FD_PATH --type d --hidden --follow --exclude .git -0 . "$path")
  done

  # Check if there are too many directories
  if [ ${#dirs[@]} -gt 1000 ]; then
    echo "Error: Too many directories to flush (${#dirs[@]} > 1000)"
    return 1
  fi

  # Flush the NFS attribute cache for each directory found
  if [ ${#dirs[@]} -gt 0 ]; then
    $NFSFLUSH_PATH "${dirs[@]}"
    echo "Flushed ${#dirs[@]} directories..."
  else
    echo "No directories found to flush."
  fi
}


function sshp() {
  local port_to_forward=$2
  local port_to_use=$2

  # Keep incrementing port until we find an unused one
  while nc -z localhost $port_to_use 2>/dev/null; do
    echo "Port $port_to_use is in use, trying next port..."
    ((port_to_use++))
  done

  echo "Forwarding http://0.0.0.0:$port_to_use"
  ssh -L "${port_to_use}:localhost:${port_to_forward}" $1
}