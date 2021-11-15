#!/bin/sh

set -e

brew autoupdate start

# Symlink the Mackup config file to the home directory
ln -s "$DOTFILES/.mackup.cfg" "$HOME/.mackup.cfg"

# Set macOS preferences
# We will run this last because this will reload the shell
if [ -z "${CI}" ]; then
  echo "Setting macOS Preferences"
  
  # Block OCSP Responder
  sudo sh -c 'echo "0.0.0.0  ocsp.apple.com" >> /etc/hosts'
  
  . "$DOTFILES/.macos"
  
  mkdir -p ~/bin
else
  echo "In Testing, not setting macOS Preferences"
fi

echo "Done!"