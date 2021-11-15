#!/bin/sh

set -e

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle
brew autoupdate start

echo "Cloning repositories..."

GITHUB=$HOME/github

mkdir $GITHUB

# Personal
git clone https://github.com/alexanderswerdlow/f1tenth.git $GITHUB/f1tenth

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