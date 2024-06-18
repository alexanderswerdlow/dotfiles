#!/bin/zsh
export PROFILE_ZSHRC=0

if [[ "$PROFILE_ZSHRC" -eq 1 ]]; then
  zmodload zsh/zprof
fi

export HOMEDIR="$HOME/aswerdlo"
export DOTFILES="$HOMEDIR/dotfiles"

if [[ -v MATRIX_NODE ]]; then
  export STARSHIP_CONFIG="$DOTFILES/misc/starship_matrix.toml"
else
  export STARSHIP_CONFIG="$DOTFILES/misc/starship.toml"
fi

export ENABLE_ITERM2_SHELL_INTEGRATION=1

. $DOTFILES/constants.sh

source $DOTFILES/path.zsh
source $DOTFILES/shortcuts/aliases.zsh

# File for temporary definitions on a per-machine basis
if [[ -f "$DOTFILES/local.zsh" ]]; then
  source "$DOTFILES/local.zsh"
fi

# We load our secrets from a toml format
if [[ -f "$SECRETS" ]]; then
    export $(awk '{print $0}' $SECRETS | grep -E '^\w' | sed 's/ = /=/')
fi

# Random
if [[ "$OS" == "macos" ]]; then
elif [[ "$OS" == "linux" ]]; then
  HISTFILE=~/.zsh_history
  HISTSIZE=10000
  SAVEHIST=10000
  setopt appendhistory
  if [[ ! -v FAST_PROMPT ]]; then
    source $DOTFILES/idempotent_install.zsh
  fi
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  if [[ "$MACHINE" == "ARM64" ]]; then
    export EDITOR='subl -w'
  else
    export EDITOR='subl -w'
  fi
fi

if [[ $MACHINE_NAME =~ gpu[0-9]{2} ]]; then
  if [ $SSH_TTY ];then 
    echo "SSH"
  fi
fi


if [[ -v MATRIX_NODE ]]; then
    source "$DOTFILES/shortcuts/matrix.zsh"

    if [[ -v MATRIX_COMPUTE_NODE ]]; then
      # [[ ! -n "${TMUX+1}" ]] && [[ ! -n "${STY+1}" ]];
      if [[ -v SLURM_JOB_ID ]] && [[ ! -v SUBMITIT ]] then
        ids=$(get_ids)
        echo "export CUDA_VISIBLE_DEVICES=$ids"
        echo "This is not actually set"
        if [[ ! -v FAST_PROMPT ]]; then
          job_database.py add_job "$SLURM_JOB_ID" "$MACHINE_NAME" "$ids"
        fi
      elif [[ ! -v SUBMITIT ]] && [[ ! -v FAST_PROMPT ]]; then
        devs=$(job_database.py get_gpus "$MACHINE_NAME")
        echo "Setting CUDA_VISIBLE_DEVICES=$devs"
        export CUDA_VISIBLE_DEVICES=$devs
      else
          export CUDA_VISIBLE_DEVICES=8
      fi
    fi

    alias xserver="Xorg -noreset +extension GLX +extension RANDR +extension RENDER &"
    export PATH="/home/aswerdlo/anaconda3/bin:$PATH"
fi

# To install copilot: npm install -g @githubnext/github-copilot-cli; github-copilot-cli auth
# Warning, this adds 200ms to shell startup
# command -v github-copilot-cli >/dev/null 2>&1 && eval "$(github-copilot-cli alias -- "$0")"

if [[ ! -v FAST_PROMPT ]]; then
  # Znap
  [[ -r "$DOTFILES/local/zsh-snap/znap.zsh" ]] ||
      git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git "$DOTFILES/local/zsh-snap"
fi

source "$DOTFILES/local/zsh-snap/znap.zsh"

znap install zsh-users/zsh-completions

if [[ ! -v FAST_PROMPT ]]; then
  if [[ "$ENABLE_ITERM2_SHELL_INTEGRATION" -eq 1 ]]; then
    znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'
    source ~/.iterm2_shell_integration.zsh
    unalias imgcat
  fi

  # # To clear cache: rm -rf ${XDG_CACHE_HOME:-$HOME/.cache}/zsh-snap/eval
  znap eval starship 'starship init zsh --print-full-init'

  ZSH_AUTOSUGGEST_STRATEGY=( history )
  znap source zsh-users/zsh-autosuggestions

  # This is a hack to enable the localcode function to work properly
  if [[ -n $SSH_CONNECTION ]]; then
    +autocomplete:recent-directories() {
      reply=( [] )
    }
  fi

  # START marlonrichert/zsh-autocomplete
  source $DOTFILES/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

  # For reference, see: https://github.com/marlonrichert/zsh-autocomplete
  # Limit the number of lines shown
  zstyle -e ':autocomplete:*' list-lines 'reply=( $(( LINES / 3 )) )'

  # Make Tab go straight to the menu and cycle there
  bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
  bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete

  # First insert the common substring
  zstyle ':autocomplete:*complete*:*' insert-unambiguous yes

  # Make Enter submit the command line straight from the menu
  bindkey -M menuselect '\r' .accept-line

  # Reset history key bindings to Zsh default
  () {
    local -a prefix=( '\e'{\[,O} )
    local -a up=( ${^prefix}A ) down=( ${^prefix}B )
    local key=
    for key in $up[@]; do
        bindkey "$key" up-line-or-history
    done
    for key in $down[@]; do
        bindkey "$key" down-line-or-history
    done
  }
  # END marlonrichert/zsh-autocomplete
fi

ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
znap source zsh-users/zsh-syntax-highlighting

znap function _pip_completion pip       'eval "$( pip completion --zsh )"'
compctl -K    _pip_completion pip

znap eval zoxide 'zoxide init zsh'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [[ "$OS" == "linux" ]]; then
  if [[ "$MACHINE_NAME" != "pop-os" ]]; then
    source "$DOTFILES/shortcuts/conda.zsh"
  fi
fi

if [[ -v MATRIX_NODE ]]; then
  source "$DOTFILES/shortcuts/completions.zsh"
fi

if [[ "$PROFILE_ZSHRC" -eq 1 ]]; then
  zprof
fi
