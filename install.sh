#!/bin/sh

set -e

if uname | grep -q 'darwin'; then
    echo 'Running on macOS. Rethinking life'
    exit 1
fi

sudo apt-get update

sudo apt-get install -y zsh fzf wget unzip curl sudo git

export DOTFILES=$HOME/dotfiles

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa

git clone --recurse-submodules https://github.com/alexanderswerdlow/dotfiles.git $DOTFILES && cd $DOTFILES

# Brew
brew update
brew install zoxide starship gcc pyenv pyenv-virtualenv

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i --force-depends google-chrome-stable_current_amd64.deb

sudo sed s/required/sufficient/g -i /etc/pam.d/chsh

sudo chsh -s $(which zsh) $USER

mv $HOME/.zshrc $HOME/.zshrc_default

ln -s $HOME/dotfiles/.zshrc $HOME/.zshrc

cp $HOME/.bashrc $HOME/.bashrc_default

echo 'exec zsh' > $HOME/.bashrc

mkdir $HOME/.zsh

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

sudo apt-get autoremove -y