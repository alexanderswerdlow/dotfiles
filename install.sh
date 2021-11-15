#!/bin/sh

set -e

sudo echo "Setting up your $OS machine..."

export DOTFILES=$HOME/dotfiles

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
    eval "$(ssh-agent -s)"
    echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_rsa" | tee ~/.ssh/config
    ssh-add -K ~/.ssh/id_rsa
fi

if [ -d "$DOTFILES" ]; then
    rm -rf $DOFILES
fi

git clone --recurse-submodules https://github.com/alexanderswerdlow/dotfiles.git $DOTFILES

test -r $HOME/.zshrc && mv $HOME/.zshrc $HOME/.zshrc_default # Preserve .zshrc is previously existed
ln -s $DOTFILES/.zshrc $HOME/.zshrc

brew update # Update Homebrew recipes

# Determine what type of machine we're running on
if [[ "$(uname)" == "Darwin" ]]; then
  sh $DOTFILES/macos_install.zsh
else
  sh $DOTFILES/ubuntu_install.zsh
fi