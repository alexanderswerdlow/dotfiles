# Shortcuts
alias copyssh="pbcopy < $HOME/.ssh/id_rsa.pub"
alias reloadshell="source $HOME/.zshrc"
alias reloaddns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
alias ll="/usr/local/opt/coreutils/libexec/gnubin/ls -AhlFo --color --group-directories-first"
alias phpstorm='open -a /Applications/PhpStorm.app "`pwd`"'
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
alias c="clear"
alias reload="exec zsh"

# Directories
alias dotfiles="cd $DOTFILES"
alias library="cd $HOME/Library"

# JS
alias nfresh="rm -rf node_modules/ package-lock.json && npm install"
alias watch="npm run watch"

# Vagrant
alias v="vagrant global-status"
alias vup="vagrant up"
alias vhalt="vagrant halt"
alias vssh="vagrant ssh"
alias vreload="vagrant reload"
alias vrebuild="vagrant destroy --force && vagrant up"

# Docker
alias docker-composer="docker-compose"

# Git
alias gst="git status"
alias gb="git branch"
alias gc="git checkout"
alias gl="git log --oneline --decorate --color"
alias amend="git add . && git commit --amend --no-edit"
alias commit="git add . && git commit -m"
alias diff="git diff"
alias force="git push --force"
alias nuke="git clean -df && git reset --hard"
alias pop="git stash pop"
alias pull="git pull"
alias push="git push"
alias resolve="git add . && git commit --no-edit"
alias stash="git stash -u"
alias unstage="git restore --staged ."
alias wip="commit wip"

# Python
alias venv="python3 -m venv"
alias act="source ./bin/activate"
alias deact="deactivate"

alias seas="ssh swerdlow@lnxsrv09.seas.ucla.edu"
alias edit="subl ~/.zshrc"
alias untar="tar -xvzf"

alias torguard="sudo wg-quick up wg0 >/dev/null 2>&1"
alias algo="sudo wg-quick up wg1 >/dev/null 2>&1"
alias off="sudo wg-quick down wg0 >/dev/null 2>&1; sudo wg-quick down wg1 >/dev/null 2>&1"
alias wireguard="sudo wg"
alias run_rsync='rsync -azP --exclude ".*/" --exclude ".*"'

function abspath() {
    # generate absolute path from relative path
    # $1     : relative filename
    # return : absolute path
    # From http://stackoverflow.com/a/23002317/514210
    if [[ -d "$1" ]]; then
        # dir
        (cd "$1"; pwd)
    elif [[ -f "$1" ]]; then
        # file
        if [[ $1 == */* ]]; then
            echo "$(cd "${1%/*}"; pwd)/${1##*/}"
        else
            echo "$(pwd)/$1"
        fi
    fi
}

function ucla() {
	remote="/u/cs/ugrad/swerdlow/$(abspath $1 | sed 's/^.*aswerdlow\///')/"
	local="$(abspath $1)/"
	server="swerdlow@lnxsrv09.seas.ucla.edu"
	run_rsync "$local" "$server:$remote"; fswatch -o . | while read f; do run_rsync "$local" "$server:$remote"; done
}
