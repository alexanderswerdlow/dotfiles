#!/bin/sh

if uname | grep -q 'darwin'; then
    echo 'Running on macOS. Rethinking life'
    exit 1
fi

sudo apt-get install -y zsh fzf wget unzip curl sudo git

curl -fsSL https://starship.rs/install.sh | bash -s -- -y

chsh -s /usr/bin/zsh $USERNAME

mv $HOME/.zshrc $HOME/.zshrc_default

ln -s $HOME/dotfiles/.zshrc $HOME/.zshrc

mkdir $HOME/.zsh

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/master/install.sh | sh

sudo apt-get autoremove -y