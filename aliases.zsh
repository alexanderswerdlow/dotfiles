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
alias gc="git clone"
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

alias system_pip="/usr/bin/pip3"
alias system_python="/usr/bin/python3"
alias upgrade="pip install --upgrade pip"

alias seas="ssh -R 52698:localhost:52698 swerdlow@lnxsrv09.seas.ucla.edu"
alias edit="subl ~/.zshrc"
alias aliases="subl ~/.dotfiles/aliases.zsh"
alias untar="tar -xvzf"

alias torguard="sudo wg-quick up wg0 >/dev/null 2>&1"
alias algo="sudo wg-quick up wg1 >/dev/null 2>&1"
alias off="sudo wg-quick down wg0 >/dev/null 2>&1; sudo wg-quick down wg1 >/dev/null 2>&1"
alias wireguard="sudo wg"
alias run_rsync='rsync -azP --exclude ".*/" --exclude ".*"'

alias st='subl'
alias o='a -e open' # quick opening files with xdg-open
alias awake='caffeinate -d -i -s -u'

alias startsc="sudo launchctl load -w /Library/LaunchAgents/Safe.Connect.client.plist; open -a '/Applications/SafeConnect.app/Contents/MacOS/scClient'"
alias quitsc="osascript -e 'tell application \"SafeConnect.app\" to quit';sudo launchctl unload -w /Library/LaunchAgents/Safe.Connect.client.plist"
alias home="cd ~/"

cpu_str=$(sysctl -a | grep 'machdep.cpu.brand_string')
arm64_cpu="Apple M1"

if [[ "$cpu_str" == *"$arm64_cpu"* ]]; then
    # Brew
    alias armbrew="arch -arm64 /opt/homebrew/bin/brew"
    alias abrew=armbrew
    alias intelbrew="arch -x86_64 /usr/local/bin/brew"
    alias ibrew=intelbrew
    alias brew=ibrew

    # Python
    alias ipython3="/usr/local/bin/python3"
    alias ipython="ipython3"
    alias ipip3="/usr/local/bin/pip3"
    alias ipip="ipip3"

    alias apython3="/opt/homebrew/bin/python3"
    alias apython="apython3"
    alias apip3="/opt/homebrew/bin/pip3"
    alias apip="apip3"

    alias intel='arch -x86_64'
else
    echo "Strings are not equal."
fi

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
	remote="/u/cs/ugrad/swerdlow/$(abspath $1 | sed 's/^.*Documents\///')/"
	local="$(abspath $1)/"
	server="swerdlow@lnxsrv09.seas.ucla.edu"
	echo $remote
	echo $local
	run_rsync "$local" "$server:$remote"; fswatch -o . | while read f; do run_rsync "$local" "$server:$remote"; done
}


rga-fzf() {
	RG_PREFIX="rga --files-with-matches"
	local file
	file="$(
		FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
			fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
				--phony -q "$1" \
				--bind "change:reload:$RG_PREFIX {q}" \
				--preview-window="70%:wrap"
	)" &&
	echo "opening $file" &&
	open "$file"
}

function sman() {
    man $1 > /tmp/man && subl /tmp/man
}


function pman() {
	man -t $1 | open -f -a PDF\ Expert
}

function hman() {
    MANWIDTH=80 MANPAGER='col -bx' man $@ | open -b com.sublimetext.3
}

jdk() {
    version=$1
    export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
    java -version
}

timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}
