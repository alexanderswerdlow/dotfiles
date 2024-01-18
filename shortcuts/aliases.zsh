# Shortcuts
alias copyssh="pbcopy < $HOME/.ssh/id_rsa.pub"
alias ll="/usr/local/opt/coreutils/libexec/gnubin/ls -AhlFo --color --group-directories-first"
alias c="clear"
alias reload="exec zsh"

# Directories
alias library="cd $HOME/Library"
alias dotfiles="code $DOTFILES"
alias notes="code $HOME/Documents/Notes"
alias aliases="subl $DOTFILES/aliases.zsh"
alias paths="subl $DOTFILES/path.zsh"
alias '..'="cd .."
alias '...'="cd ../../"
alias size='gdu'
alias ssize='du -h -d 1 | sort -h'

# Files
alias untar="tar -xvzf"
alias ls='exa -lam --group-directories-first'
alias cat='bat --paging=never --plain'
alias st='subl'

alias home="cd ~/"
alias search="rga --rga-cache-max-blob-len=50000000 --no-messages --rga-adapters=-decompress,zip,tar"
alias ssearch="rga --rga-adapters=+pdfpages,tesseract --no-messages"
export FZF_DEFAULT_COMMAND='fd --type file -E "*.jpg" -E "*.html" -E "*.htm" -E "*.txt"'

# Python
alias act="source ./venv/bin/activate"
alias dact="deactivate"
alias rpy="pyenv uninstall"
alias cpy="pyenv virtualenv"
alias spy="pyenv shell"

## Conda
alias ca='conda activate'
alias condad='conda deactivate'
alias ce='conda env list'


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
alias pull="git pull"
alias push="git push"
alias resolve="git add . && git commit --no-edit"
alias stash="git stash -u"
alias unstage="git restore --staged ."
alias wip="commit wip"

alias tn='tmux new -s'
alias r='tmux attach -t'
alias ts='tmux ls'
alias tk='tmux kill-session -t'
alias trn='tmux rename-session -t'

alias s1='ssh $S1_HOSTNAME'
alias s2='ssh $S2_HOSTNAME'
alias s3='ssh $S3_HOSTNAME'
alias s4='ssh $S4_HOSTNAME'
alias sp='ssh pop-os'
alias work="ssh home"

alias rs="rsync -ah --info=progress2"
alias nv="nvidia-smi"

source $DOTFILES/shortcuts/functions.zsh

if [[ "$OS" == "macos" ]]; then
  source $DOTFILES/shortcuts/mac_aliases.zsh
elif [[ "$OS" == "linux" ]]; then
  source $DOTFILES/shortcuts/linux_aliases.zsh
fi
