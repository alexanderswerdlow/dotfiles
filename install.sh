#!/bin/sh

set -e

# Pre-requisites are git and curl

export DOTFILES=$HOME/dotfiles

echo "Setting up your machine..."

if [ ! -d "$DOTFILES" ]; then
  echo "Cloning dotfiles to $DOTFILES"
  git clone --recurse-submodules "https://github.com/alexanderswerdlow/dotfiles" "$DOTFILES"
else
  git -C $DOTFILES fetch origin
  git -C $DOTFILES reset --hard origin/master
fi

. "$DOTFILES/constants.sh"

echo "Running on $OS"

# Copy .zshrc if it previously existed and isn't a softlink
if [ -e "$HOME/.zshrc" ] && [ ! -h "$HOME/.zshrc" ]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc_default"
fi

# Softlink .zshrc to dotfiles
ln -sf "$DOTFILES/.zshrc" "$HOME/.zshrc"

if sudo -v >/dev/null 2>&1 && !( [ "$(uname -m)" = "aarch64" ] && [ "$OS" = "linux" ] ); then
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

  eval "$($BREWPREFIX/bin/brew shellenv)"
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

if [ ! -d "$DOTFILES/plugins/zsh-autocomplete" ]; then
  cd "$DOTFILES/plugins" && git clone --depth 2 -- 'https://github.com/marlonrichert/zsh-autocomplete.git'
  cd "$DOTFILES/plugins/zsh-autocomplete" && git checkout '86ffb11c7186664a71fd36742f3148628c4b85cb'
  echo "skip_global_compinit=1" > ~/.zshenv && cd $HOME
fi

mkdir -p "$HOME/bin"

sh "$DOTFILES/${OS}_install.sh"

cat "$HOME/.ssh/id_rsa.pub"

ln -sf "$DOTFILES/misc/ipython_config.py" "$HOME/.ipython/profile_default/ipython_config.py"
ln -sf "$DOTFILES/misc/ipython_patch_history_command.py" "$HOME/.ipython/profile_default/startup/ipython_patch_history_command.py"
ln -sf "$DOTFILES/misc/ipython_startup_commands.ipy" "$HOME/.ipython/profile_default/startup/ipython_startup_commands.ipy"

echo "Done!"