export DOTFILES=$HOME/.dotfiles

source ~/.dotfiles/aliases.zsh
source ~/.dotfiles/path.zsh
source /Users/aswerdlow/.zsh/zsh-pyenv-lazy/pyenv-lazy.plugin.zsh

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='code-insiders'
fi

eval "$(starship init zsh)"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

eval "$(zoxide init zsh)"

# Random

source ~/.iterm2_shell_integration.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

ZSH_PYENV_LAZY_VIRTUALENV=true

# opam configuration
# test -r /Users/aswerdlow/.opam/opam-init/init.zsh && . /Users/aswerdlow/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
