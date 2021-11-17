#!/bin/sh

set -e

# Determine what type of machine we're running on
if [ "$(uname)" = "Darwin" ]; then
  export SETUP_OS="macos"
else
  export SETUP_OS="ubuntu"
  sudo apt-get update && sudo apt-get install curl git
fi

sudo echo "Setting up your $OS machine..."

export DOTFILES="$HOME/dotfiles"
export GITHUB="$HOME/github"

# Check for Homebrew and install if we don't have it
if test ! "$(which brew)"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
    eval "$(ssh-agent -s)"
    echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_rsa" | tee ~/.ssh/config
    ssh-add ~/.ssh/id_rsa
fi

if [ -d "$DOTFILES" ]; then
    rm -rf "$DOTFILES"
fi

git clone --recurse-submodules https://github.com/alexanderswerdlow/dotfiles.git "$DOTFILES"

test -r "$HOME/.zshrc" && mv "$HOME/.zshrc" "$HOME/.zshrc_default" # Preserve .zshrc is previously existed
ln -s "$DOTFILES/.zshrc" "$HOME/.zshrc"

echo "Cloning repositories..."
mkdir -p "$GITHUB"
git clone https://github.com/alexanderswerdlow/f1tenth.git "$GITHUB/f1tenth" # Personal

brew update # Update Homebrew recipes
brew tap homebrew/bundle 
brew bundle --file="${DOTFILES}/${SETUP_OS}_brewfile" # Install all our dependencies with bundle

sh "${DOTFILES}/${SETUP_OS}_install.sh"

cat ~/.ssh/id_rsa.pub