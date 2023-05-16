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

# Copy .zshrc if it previously existed
test -r "$HOME/.zshrc" && mv "$HOME/.zshrc" "$HOME/.zshrc_default"

# Softlink .zshrc to dotfiles
ln -s "$DOTFILES/.zshrc" "$HOME/.zshrc"

if sudo -v >/dev/null 2>&1; then
  export NON_ROOT_INSTALL=false
  echo "We have sudo!"
else
  export NON_ROOT_INSTALL=true
  echo "We don't appear to have sudo."
fi

if ! $NON_ROOT_INSTALL; then
  echo "Root permissions...Installing homebrew"

  # Check for Homebrew and install if we don't have it
  if test ! "$(which brew)"; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi

  # Init homebrew on linux
  if [ "$SETUP_OS" = "ubuntu" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi

  brew update # Update Homebrew recipes
  brew tap homebrew/bundle
  brew bundle --file="${SETUP_OS}_brewfile" # Install all our dependencies with bundle
  brew cleanup
fi

# Generate SSH Keys
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
    eval "$(ssh-agent -s)"
    echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_rsa" | tee ~/.ssh/config
    ssh-add ~/.ssh/id_rsa
fi

echo "Cloning repositories..."
test -d "$GITHUB" || mkdir "$GITHUB"
test -d "$GITHUB/f1tenth" || git clone https://github.com/alexanderswerdlow/f1tenth.git "$GITHUB/f1tenth" # Personal

cd $DOTFILES/plugins && git clone --depth 2 -- https://github.com/marlonrichert/zsh-autocomplete.git
cd $DOTFILES/plugins/zsh-autocomplete && git checkout 86ffb11c7186664a71fd36742f3148628c4b85cb
echo "skip_global_compinit=1" > ~/.zshenv && cd $DOTFILES

sh "${SETUP_OS}_install.sh"

cat ~/.ssh/id_rsa.pub