#!/bin/sh

set -e

if uname | grep -q 'darwin'; then
    echo 'Running on macOS. Rethinking life'
    exit 1
fi

sudo echo "I must be run with root permissions (not as root though!)"

sudo apt-get update
sudo apt-get install -y zsh fzf wget unzip curl sudo git gcc g++ cmake build-essential

export DOTFILES=$HOME/dotfiles

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
fi

if [ -d "$HOME/dotfiles" ]; then
    rm -rf $HOME/dotfiles
fi

git clone --recurse-submodules https://github.com/alexanderswerdlow/dotfiles.git $DOTFILES

# Brew
brew update
brew install zoxide starship gcc pyenv pyenv-virtualenv bat exa

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i --force-depends google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

sudo sed s/required/sufficient/g -i /etc/pam.d/chsh
sudo chsh -s $(which zsh) $USER

test -r $HOME/.zshrc && mv $HOME/.zshrc $HOME/.zshrc_default
test -r $HOME/.bash_profile && cp $HOME/.bash_profile $HOME/.bash_profile_default
ln -s $DOTFILES/.zshrc $HOME/.zshrc

mkdir -p $HOME/.zsh
test -d ~/.zsh/zsh-autosuggestions && rm -rf ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

sudo apt-get autoclean
sudo apt-get clean
sudo apt-get autoremove -y

exec zsh

PYTHON_VERSION="3.10.0"
pyenv install $PYTHON_VERSION
pyenv global $PYTHON_VERSION
upgrade python