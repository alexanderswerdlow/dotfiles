#!/bin/sh

set -e

export DOTFILES=$HOME/dotfiles

# Determine what type of machine we're running on
if [ "$OS" = "linux" ]; then
  sudo apt-get update && sudo apt-get install -y curl git
fi

sudo echo "Setting up your $OS machine..."

if [ ! -d "$DOTFILES" ]; then
  echo "Cloning dotfiles to $DOTFILES"
  git clone --recurse-submodules "https://github.com/alexanderswerdlow/dotfiles" "$DOTFILES"
fi

source "$DOTFILES/constants.sh"

# Copy .zshrc if it previously existed
test -r "$HOME/.zshrc" && mv "$HOME/.zshrc" "$HOME/.zshrc_default"

# Softlink .zshrc to dotfiles
ln -s "$DOTFILES/.zshrc" "$HOME/.zshrc"

if sudo -v >/dev/null 2>&1; then
  export NON_ROOT_INSTALL=false
else
  export NON_ROOT_INSTALL=true
fi

echo "Performing Non-Root Install: $NON_ROOT_INSTALL"

if ! $NON_ROOT_INSTALL; then
  # Check for Homebrew and install if we don't have it
  if test ! "$(which brew)"; then
    echo "Brew not found... Installing"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi

  # Init homebrew on linux
  if [ "$OS" = "ubuntu" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  echo "Installing and Updating from Brewfile"
  brew update # Update Homebrew recipes
  brew tap homebrew/bundle
  brew bundle --file="$DOTFILES/${OS}_brewfile" # Install all our dependencies with bundle
  brew cleanup
fi

# Generate SSH Keys
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "Generating SSH Keys..."
    ssh-keygen -t rsa -b 4096 -N "" -f "$HOME/.ssh/id_rsa"
    eval "$(ssh-agent -s)"
    echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile $HOME/.ssh/id_rsa" | tee "$HOME/.ssh/config"
    ssh-add "$HOME/.ssh/id_rsa"
fi

echo "Cloning repositories..."

if [ ! -d "$HOME/Documents/github" ]; then
  test -d "$GITHUB" || mkdir "$GITHUB"
  test -d "$GITHUB/f1tenth" || git clone https://github.com/alexanderswerdlow/f1tenth.git "$GITHUB/f1tenth" # Personal
else
  ln -sf "$HOME/Documents/github" "$GITHUB"
fi

if [[ ! -d "$DOTFILES/plugins/zsh-autocomplete" ]]; then
  cd "$DOTFILES/plugins" && git clone --depth 2 -- 'https://github.com/marlonrichert/zsh-autocomplete.git'
  cd "$DOTFILES/plugins/zsh-autocomplete" && git checkout '86ffb11c7186664a71fd36742f3148628c4b85cb'
  echo "skip_global_compinit=1" > ~/.zshenv && cd $HOME
fi

mkdir -p "$HOME/bin"

sh "$DOTFILES/${OS}_install.sh"

cat "$HOME/.ssh/id_rsa.pub"