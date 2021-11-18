#!/bin/sh

set -e

sudo apt-get update
sudo apt-get install -y zsh fzf wget unzip curl sudo git gcc g++ cmake build-essential
sudo apt-get autoclean
sudo apt-get clean
sudo apt-get autoremove -y

sudo sed s/required/sufficient/g -i /etc/pam.d/chsh
sudo chsh -s "$(which zsh)" "$USER"

test -r "$HOME/.bash_profile" && cp "$HOME/.bash_profile" "$HOME/.bash_profile_default"

mkdir -p "$HOME/.zsh"
test -d "$HOME/.zsh/zsh-autosuggestions" && rm -rf "$HOME/.zsh/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"

exec zsh

