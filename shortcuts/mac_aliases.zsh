# Brew
alias brewd="brew doctor"
alias brewi="brew install"
alias brewr="brew uninstall --zap"
alias brews="brew search"
alias brewu="brew update && brew upgrade && brew cleanup"
alias ibrewu="ibrew update && ibrew upgrade && ibrew cleanup"

alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"

# Python
alias spython="/usr/bin/python3"
alias spip="/usr/bin/python3 -m pip"

alias bpython="$BREWPREFIX/bin/python3"
alias bpip="$BREWPREFIX/bin/python3 -m pip"

alias intelpython="$INTEL_BREW_PREFIX/bin/python3"
alias intelpip="$INTEL_BREW_PREFIX/bin/python3 -m pip"

alias bgcc="$BREWPREFIX/bin/gcc-11"

export PYENV_VIRTUALENV_DISABLE_PROMPT=1

# Java
export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
export JAVA_17_HOME=$(/usr/libexec/java_home -v17)

alias java8='export JAVA_HOME=$JAVA_8_HOME && java -version'
alias java17='export JAVA_HOME=$JAVA_17_HOME && java -version'

# Chrome
export CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
export PROFILE_BASE="$HOME/Profiles"

alias ccchrome='chrome-private.sh --name temp --delete'
alias cchrome="chrome-private.sh --root-profile $PROFILE_BASE/fresh --name temp --delete"
alias chrome="chrome-private.sh --root-profile $PROFILE_BASE/base --name temp --delete"
alias echrome="chrome-private.sh --profile $PROFILE_BASE/base"

# Network
alias startsc="sudo launchctl load -w /Library/LaunchAgents/Safe.Connect.client.plist; open -a '/Applications/SafeConnect.app/Contents/MacOS/scClient'"
alias quitsc="osascript -e 'tell application \"SafeConnect.app\" to quit';sudo launchctl unload -w /Library/LaunchAgents/Safe.Connect.client.plist"
alias dns="networksetup -setdnsservers 'Wi-Fi' 1.1.1.1 8.8.8.8"
alias cleardns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"

alias wifi="/usr/bin/python3 $DOTFILES/scripts/func.py change_network_order 'Wi-Fi'"
alias ethernet="/usr/bin/python3 $DOTFILES/scripts/func.py change_network_order 'Ethernet'"
alias local-ip="ipconfig getifaddr en0"
alias pop="ssh 192.168.88.254"

# VPN
alias qvpn="launchctl unload ~/Library/LaunchAgents/local.vpn.plist && networksetup -disconnectpppoeservice 'TorGuard Dedicated' && dns"
alias vpn="launchctl load ~/Library/LaunchAgents/local.vpn.plist && dns"

# System
alias o='a -e open' # quick opening files with xdg-open
alias awake='caffeinate -d -i -s -u'

# Random
alias carbon="carbon-now -h -c"
alias ffind='mdfind -onlyin . -name'

if [[ "$MACHINE" == "X86" ]]; then
    alias unifi='JAVA_VERSION=1.8 java -jar /Applications/UniFi.app/Contents/Resources/lib/ace.jar ui'
    alias matlab="/Applications/MATLAB_R2020b.app/bin/matlab"
elif [[ "$MACHINE" == "ARM64" ]]; then
    # Brew
    alias abrew="arch -arm64 /opt/homebrew/bin/brew"
    alias ibrew="arch -x86_64 /usr/local/bin/brew"
    alias brew=abrew

    alias intel='arch -x86_64'
    alias arm='arch -arm64'
    alias matlabb="/Applications/MATLAB_R2021a.app/bin/matlab"
    alias matlab="matlabb -nodisplay -nosplash -nodesktop"
else
    # Do Nothing
fi

function touchid() {
    # unset -f sudo
    if [[ "$(uname)" == 'Darwin' ]] && ! grep 'pam_tid.so' /etc/pam.d/sudo --silent; then
      sudo sed -i -e '1s;^;auth       sufficient     pam_tid.so\n;' /etc/pam.d/sudo
    fi
    # sudo "$@"
}

function encodeuri {
  local string="${@}"
  local strlen=${#string}
  local encoded=""

  for (( pos = 0; pos < strlen; pos ++ )); do
    c=${string:$pos:1}
    case "$c" in
      [-_.~a-zA-Z0-9]) o="${c}" ;;
      *) printf -v o '%%%02x' "'$c"
    esac
    encoded+="${o}"
  done
  echo "${encoded}"
}

function manfunc {
  if [[ (-d /Applications/Dash.app || -d /Applications/Setapp/Dash.app) && -d "$HOME/Library/Application Support/Dash/DocSets/Man_Pages" ]]; then
    query=`encodeuri ${@}`
    /usr/bin/open "dash-plugin://keys=manpages&query=$query"
  else
    $(whereis -b -q man) ${@}
  fi
}
alias man=manfunc

# UCLA Specific
alias seas="ssh -R 52698:localhost:52698 swerdlow@lnxsrv09.seas.ucla.edu"
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
    remote="/u/cs/ugrad/swerdlow/$(abspath $1 | sed 's/^.*Documents\///')/"
    local="$(abspath $1)/"
    server="swerdlow@lnxsrv09.seas.ucla.edu"
    echo $remote
    echo $local
    run_rsync "$local" "$server:$remote"; fswatch -o . | while read f; do run_rsync "$local" "$server:$remote"; done
}