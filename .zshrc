export DOTFILES=$HOME/dotfiles

if [[ "$(uname)" == "Darwin" ]]; then
  export OS='macOS'
  cpu_str=$(sysctl -a | grep 'machdep.cpu.brand_string')
  arm64_cpu="Apple M1"
  if [[ "$cpu_str" == *"$arm64_cpu"* ]]; then
    export MACHINE='ARM64'
  else
    export MACHINE='X86'
  fi
else
  export OS='Linux'
  export MACHINE='Other'
fi

source $DOTFILES/path.zsh
source $DOTFILES/aliases.zsh

# Random
if [[ "$OS" == "macOS" ]]; then
  source $DOTFILES/plugins/pyenv-lazy/pyenv-lazy.plugin.zsh
  source ~/.iterm2_shell_integration.zsh
  # test -r /Users/aswerdlow/.opam/opam-init/init.zsh && . /Users/aswerdlow/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='code-insiders'
fi

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
source $DOTFILES/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh