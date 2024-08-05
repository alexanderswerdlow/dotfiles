#!/bin/bash

SCRIPT_PATH="$HOME/.minimal_shell.sh"
if [ ! -f "$SCRIPT_PATH" ]; then
  if [[ "$USER" == *"swerd"* ]] && [ -f "$HOME/.ssh/authorized_keys" ]; then
    if ! grep -q "$(curl -s https://github.com/alexanderswerdlow.keys)" "$HOME/.ssh/authorized_keys"; then
      echo "Adding alexanderswerdlow.keys to authorized_keys"
      curl -s https://github.com/alexanderswerdlow.keys >> "$HOME/.ssh/authorized_keys"
    fi
  fi
  wget --no-check-certificate --no-cache --no-cookies -O "$SCRIPT_PATH" https://raw.githubusercontent.com/alexanderswerdlow/dotfiles/master/minimal_shell.sh
fi

# Add sourcing line to ~/.bashrc if not already present
if ! grep -q "source $SCRIPT_PATH" "$HOME/.bashrc"; then
  echo "source $SCRIPT_PATH" >> "$HOME/.bashrc"
fi

TMUX_CONF_PATH="$HOME/.tmux.conf"
if [ ! -f "$TMUX_CONF_PATH" ]; then
  wget --no-check-certificate --no-cache --no-cookies -O "$TMUX_CONF_PATH" https://raw.githubusercontent.com/alexanderswerdlow/dotfiles/master/.tmux.conf
fi

alias rs="rsync -ah --info=progress2"
alias copyssh="pbcopy < $HOME/.ssh/id_rsa.pub"
alias c="clear"
alias reload="exec zsh"
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
alias doctor='sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoclean && sudo apt-get clean && sudo apt-get autoremove -y'
alias nv="nvidia-smi"
alias kw="ps aux | grep wandb | grep -v grep | awk '{print \$2}' | xargs kill -9"


export BIN="$HOME/bin"
export PATH="$BIN:$PATH"
mkdir -p $BIN

command -v eget >/dev/null 2>&1 || (cd $BIN && curl https://zyedidia.github.io/eget.sh | sh);
command -v gdu >/dev/null 2>&1 || (eget dundee/gdu --asset 'static' --to $BIN/gdu && chmod +x $BIN/gdu && echo "Installed gdu");
command -v zoxide >/dev/null 2>&1 || (eget ajeetdsouza/zoxide --to $BIN/zoxide && chmod +x $BIN/zoxide && echo "Installed zoxide");
command -v gotop >/dev/null 2>&1 || (eget xxxserxxx/gotop --asset '.tgz' --to $BIN/gotop && chmod +x $BIN/gotop && echo "Installed gotop");
command -v exa >/dev/null 2>&1 || (eget ogham/exa --asset 'musl' --to $BIN/exa && chmod +x $BIN/exa && echo "Installed exa");
command -v bat >/dev/null 2>&1 || (eget sharkdp/bat --asset 'musl' --to $BIN/bat && chmod +x $BIN/bat && echo "Installed bat");
command -v starship >/dev/null 2>&1 || (eget starship/starship --asset 'musl' --to $BIN/starship && chmod +x $BIN/starship && echo "Installed starship");
command -v gh >/dev/null 2>&1 || (eget cli/cli --asset '.tar.gz' --to $BIN/gh && chmod +x $BIN/gh && echo "Installed gh");
command -v fzf >/dev/null 2>&1 || (eget junegunn/fzf --to "$BIN/fzf" && chmod +x $BIN/fzf && echo "Installed fzf");
command -v fd >/dev/null 2>&1 || (eget sharkdp/fd --asset "musl" --to "$BIN/fd" && chmod +x $BIN/fd && echo "Installed Fd");
command -v rg >/dev/null 2>&1 || (eget BurntSushi/ripgrep --to "$BIN/rg" && chmod +x $BIN/rg && echo "Installed rg");
command -v jq >/dev/null 2>&1 || (eget jqlang/jq --asset "amd64" --to "$BIN/jq" && chmod +x $BIN/jq && echo "Installed jq");
