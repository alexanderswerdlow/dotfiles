#!/bin/sh

set -e

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone https://github.com/alexanderswerdlow/dotfiles.git ~/.dotfiles && cd ~/.dotfiles

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle

# Create a Sites directory
# This is a default directory for macOS user accounts but doesn't comes pre-installed
mkdir $HOME/Github

# Clone Github repositories
./clone.sh

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

git clone https://github.com/djui/alias-tips.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/alias-tips

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf $HOME/.zshrc
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc

# Symlink the Mackup config file to the home directory
ln -s $HOME/.dotfiles/.mackup.cfg $HOME/.mackup.cfg

# Set macOS preferences
# We will run this last because this will reload the shell
if [ -z "${CI}" ]
then
  echo "Setting macOS Preferences"
  
  # Block OCSP Responder
  sudo sh -c 'echo "0.0.0.0  ocsp.apple.com" >> /etc/hosts'
  
  source .macos
  
  curl -L --url https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf --output ~/Library/Fonts/"MesloLGS NF Regular.ttf"
  curl -L --url https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf --output ~/Library/Fonts/"MesloLGS NF Bold.ttf"
  curl -L --url https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf --output ~/Library/Fonts/"MesloLGS NF Italic.ttf"
  curl -L --url https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf --output ~/Library/Fonts/"MesloLGS NF Bold Italic.ttf"
  mkdir -p ~/bin
else
  echo "In Testing, not setting macOS Preferences"
fi

ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl

cat ~/.ssh/id_rsa.pub

echo "Done!"
