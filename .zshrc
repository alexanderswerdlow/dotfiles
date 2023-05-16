#!/bin/zsh

export DOTFILES=$HOME/dotfiles

[[ -r "$DOTFILES/local/zsh-snap/znap.zsh" ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git "$DOTFILES/local/zsh-snap"

source "$DOTFILES/local/zsh-snap/znap.zsh"


# Determine what type of machine we're running on
# This affects what we source, put on our path, and which aliases we use
if [[ "$(uname)" == "Darwin" ]]; then
  export OS='macOS'
  cpu_str=$(sysctl -a | grep 'machdep.cpu.brand_string')
  arm64_cpu="Apple M1"
  if [[ "$cpu_str" == *"$arm64_cpu"* ]]; then
    export MACHINE='ARM64'
    export BREWPREFIX='/opt/homebrew'
  else
    export MACHINE='X86'
    export BREWPREFIX='/usr/local'
  fi
else
  export OS='Linux'
  export MACHINE='Other'
fi

export ARM_BREW_PREFIX='/opt/homebrew'
export LINUX_BREW_PREFIX='/home/linuxbrew/.linuxbrew'
export INTEL_BREW_PREFIX='/usr/local' # Rarely used but here just in case

source $DOTFILES/path.zsh
source $DOTFILES/shortcuts/aliases.zsh

# We load our secrets from a toml format
if [[ -f "$SECRETS" ]]; then
    export $(awk '{print $0}' $SECRETS | grep -E '^\w' | sed 's/ = /=/')
fi

# Random
if [[ "$OS" == "macOS" ]]; then
  source $DOTFILES/plugins/pyenv-lazy/pyenv-lazy.plugin.zsh
  # [ -s "/Users/aswerdlow/.bun/_bun" ] && source "/Users/aswerdlow/.bun/_bun" # bun completions
  # [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  # [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  eval "$(github-copilot-cli alias -- "$0")"

elif [[ "$OS" == "Linux" ]]; then
  HISTFILE=~/.zsh_history
  HISTSIZE=10000
  SAVEHIST=10000
  setopt appendhistory
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

if [[ $(hostname) =~ gpu[0-9]{2} ]]; then
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/home/aswerdlow/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/home/aswerdlow/anaconda3/etc/profile.d/conda.sh" ]; then
            . "/home/aswerdlow/anaconda3/etc/profile.d/conda.sh"
        else
            export PATH="/home/aswerdlow/anaconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<

    if [ $SSH_TTY ];then 
    cd ~/github/multi_view_generation
    conda activate ips
    fi
fi

# Znap
znap eval starship 'starship init zsh --print-full-init'
znap prompt

znap install zsh-users/zsh-completions

ZSH_AUTOSUGGEST_STRATEGY=( history )
znap source zsh-users/zsh-autosuggestions

ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
znap source zsh-users/zsh-syntax-highlighting

znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'

znap function _pyenv pyenv              'eval "$( pyenv init - --no-rehash )"'
compctl -K    _pyenv pyenv

znap function _pip_completion pip       'eval "$( pip completion --zsh )"'
compctl -K    _pip_completion pip

eval "$(zoxide init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source $DOTFILES/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# This is a hack to enable the localcode function to work properly
if [[ -n $SSH_CONNECTION ]]; then
  +autocomplete:recent-directories() {
    reply=( [] )
  }
fi

# For reference, see: https://github.com/marlonrichert/zsh-autocomplete
# Limit the number of lines shown
zstyle -e ':autocomplete:*' list-lines 'reply=( $(( LINES / 3 )) )'

# Make Tab go straight to the menu and cycle there
bindkey '\t' menu-select "$terminfo[kcbt]" menu-select
bindkey -M menuselect '\t' menu-complete "$terminfo[kcbt]" reverse-menu-complete

# First insert the common substring
zstyle ':autocomplete:*complete*:*' insert-unambiguous yes

# Make Enter submit the command line straight from the menu
# bindkey -M menuselect '\r' .accept-line

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