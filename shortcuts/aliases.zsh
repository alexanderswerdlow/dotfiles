# Shortcuts
alias copyssh="pbcopy < $HOME/.ssh/id_rsa.pub"
alias ll="/usr/local/opt/coreutils/libexec/gnubin/ls -AhlFo --color --group-directories-first"
alias c="clear"
alias reload="exec zsh"

# Directories
alias library="cd $HOME/Library"
alias dotfiles="code $DOTFILES"
alias aliases="subl $DOTFILES/aliases.zsh"
alias paths="subl $DOTFILES/path.zsh"
alias '..'="cd .."
alias '...'="cd ../../"
alias size='du -h -d 1'

# Files
alias untar="tar -xvzf"
alias ls='exa'
alias cat='bat --paging=never'
alias st='subl'

alias home="cd ~/"
alias search="rga --no-messages"
alias ssearch="rga --rga-adapters=+pdfpages,tesseract --no-messages"
alias findf='mdfind -onlyin . -name'
export FZF_DEFAULT_COMMAND='fd --type file -E "*.jpg" -E "*.html" -E "*.htm" -E "*.txt"'

# Python
alias act="source ./venv/bin/activate"
alias dact="deactivate"
alias rpy="pyenv uninstall"
alias cpy="pyenv virtualenv"
alias spy="pyenv shell"


alias torguard="sudo wg-quick up wg0 >/dev/null 2>&1"
alias off="sudo wg-quick down wg0 >/dev/null 2>&1"
alias wireguard="sudo wg"

# JS
alias nfresh="rm -rf node_modules/ package-lock.json && npm install"

# Git
alias gp="git peek"
alias gst="git status"
alias gb="git branch"
alias gc="git clone"
alias gl="git log --oneline --decorate --color"
alias amend="git add . && git commit --amend --no-edit"
alias commit="git add . && git commit -m"
alias force="git push --force"
alias nuke="git clean -df && git reset --hard"
alias pop="git stash pop"
alias pull="git pull"
alias push="git push"
alias resolve="git add . && git commit --no-edit"
alias stash="git stash -u"
alias unstage="git restore --staged ."
alias wip="commit wip"

source $DOTFILES/shortcuts/functions.zsh

if [[ "$OS" == "macOS" ]]; then
  source $DOTFILES/shortcuts/mac_aliases.zsh
elif [[ "$OS" == "Linux" ]]; then
  source $DOTFILES/shortcuts/ubuntu_aliases.zsh
fi
