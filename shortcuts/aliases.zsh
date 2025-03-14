# Shortcuts
alias copyssh="pbcopy < $HOME/.ssh/id_rsa.pub"
alias ll="/usr/local/opt/coreutils/libexec/gnubin/ls -AhlFo --color --group-directories-first"
alias c="clear"
alias reload="exec zsh"

# Directories
alias library="cd $HOME/Library"
alias dotfiles="$IDE $DOTFILES"
alias sshconfig="subl -w ~/.ssh/config"
alias notes="$IDE $HOME/Documents/Notes"
alias aliases="subl $DOTFILES/aliases.zsh"
alias paths="subl $DOTFILES/path.zsh"
alias '..'="cd .."
alias '...'="cd ../../"
alias size='gdu'
alias ssize='du -h -d 1 | sort -h'

# Files
alias untar="tar --extract --verbose --file"
alias ls='exa -lam --group-directories-first'
alias cat='bat --paging=never --plain'
alias st='subl'
alias sth='st ~/.ssh/config'

alias home="cd ~/"
alias search="rga --rga-cache-max-blob-len=50000000 --no-messages --rga-adapters=-decompress,zip,tar"
alias ssearch="rga --rga-adapters=+pdfpages,tesseract --no-messages"
# export FZF_DEFAULT_COMMAND='fd --type file -E "*.jpg" -E "*.html" -E "*.htm" -E "*.txt"'
export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git --color=always'
export FZF_DEFAULT_OPTS="--ansi"

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
alias grao="git remote set-url origin https://github.com/alexanderswerdlow/${PWD##*/}.git"
alias gcl="git config user.name 'Alexander Swerdlow' && git config user.email 'aswerdlow1@gmail.com' && git config url.'ssh://git@github.com'.insteadOf 'https://github.com'"
alias mgit="git -c core.sshCommand='ssh -i /home/aswerdlo/.ssh/other'"

if [[ -n $GROGU_NODE ]]; then
  alias tmux='tmux -L aswerdlo -f "$DOTFILES/.tmux.conf"'
fi

alias tn='tmux new -s'
alias ts='tmux ls'
alias tk='tmux kill-session -t'
alias trn='tmux rename-session -t'

alias s1='ssh $S1_HOSTNAME'
alias s2='ssh $S2_HOSTNAME'
alias s3='ssh $S3_HOSTNAME'
alias s4='ssh $S4_HOSTNAME'
alias sp='et $HOME_HOSTNAME'
alias work="ssh home"

# Docker
alias dcu="docker compose up -d && docker compose logs -f"
alias dcd="docker compose down"
alias dcr="docker compose restart && docker compose logs -f"
alias dcl="docker compose logs -f"
alias dcrr="docker compose down && docker compose up -d && docker compose logs -f"
alias dcf="docker compose down && docker compose pull && docker compose up --force-recreate --build -d && docker compose logs -f"
alias dc="docker compose" # Who uses /bin/dc anyway

# Tmux
alias rr='tmux -CC attach -t'

# Other
alias rs="rsync --archive --human-readable --verbose --info=progress2"


source $DOTFILES/shortcuts/functions.zsh

if [[ "$OS" == "macos" ]]; then
  source $DOTFILES/shortcuts/mac_aliases.zsh
elif [[ "$OS" == "linux" ]]; then
  source $DOTFILES/shortcuts/linux_aliases.zsh
fi
