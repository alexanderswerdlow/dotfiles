# Shortcuts
alias copyssh="pbcopy < $HOME/.ssh/id_rsa.pub"
alias ll="/usr/local/opt/coreutils/libexec/gnubin/ls -AhlFo --color --group-directories-first"
alias c="clear"
alias reload="exec zsh"

# Directories
alias library="cd $HOME/Library"
alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"
alias dotfiles="code $DOTFILES"
alias aliases="subl $DOTFILES/aliases.zsh"
alias paths="subl $DOTFILES/path.zsh"
alias '..'="cd .."
alias '...'="cd ../../"

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
alias venv="python3 -m venv"
alias act="source ./bin/activate"
alias deact="deactivate"

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
fi
