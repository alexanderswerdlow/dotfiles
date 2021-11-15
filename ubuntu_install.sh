#!/bin/sh

set -e

sudo apt-get update
sudo apt-get install -y zsh fzf wget unzip curl sudo git gcc g++ cmake build-essential

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

test -r $HOME/.bash_profile && cp $HOME/.bash_profile $HOME/.bash_profile_default

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