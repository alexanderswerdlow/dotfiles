#!/bin/sh

set -e

echo "Setting up your Mac..."

export DOTFILES=$HOME/dotfiles

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa

git clone --recurse-submodules https://github.com/alexanderswerdlow/dotfiles.git $DOTFILES && cd $DOTFILES

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle
brew autoupdate start

echo "Cloning repositories..."

GITHUB=$HOME/github

mkdir $GITHUB

# Personal
git clone https://github.com/alexanderswerdlow/f1tenth.git $GITHUB/f1tenth

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf $HOME/.zshrc
ln -s $DOTFILES/.zshrc $HOME/.zshrc

# Symlink the Mackup config file to the home directory
ln -s $DOTFILES/.mackup.cfg $HOME/.mackup.cfg

# Set macOS preferences
# We will run this last because this will reload the shell
if [ -z "${CI}" ]
then
  echo "Setting macOS Preferences"
  
  # Block OCSP Responder
  sudo sh -c 'echo "0.0.0.0  ocsp.apple.com" >> /etc/hosts'
  
  source .macos
  
  mkdir -p ~/bin
else
  echo "In Testing, not setting macOS Preferences"
fi

cat ~/.ssh/id_rsa.pub

echo "Done!"