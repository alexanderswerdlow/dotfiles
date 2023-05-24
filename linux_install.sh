#!/bin/sh

set -e

test -r "$HOME/.bash_profile" && cp "$HOME/.bash_profile" "$HOME/.bash_profile_default"

if ! ${NON_ROOT_INSTALL:-false}; then
    sudo apt-get update
    sudo apt-get install -y zsh wget unzip curl sudo git gcc g++ cmake build-essential
    sudo apt-get autoclean
    sudo apt-get clean
    sudo apt-get autoremove -y

    sudo sed s/required/sufficient/g -i /etc/pam.d/chsh
    sudo chsh -s "$(which zsh)" "$USER"
else
    # In cases we don't have sudo access (e.g. on a cluster) we can use eget to install binaries
    mkdir -p "$HOME/bin" && cd "$HOME/bin";
    export PATH="$HOME/bin:$PATH";
    test ! -r eget && curl https://zyedidia.github.io/eget.sh | sh;
    test ! -r gdu && eget dundee/gdu --to gdu && chmod +x gdu;
    test ! -r zoxide && eget ajeetdsouza/zoxide --to zoxide && chmod +x zoxide;
    test ! -r gotop && eget xxxserxxx/gotop --asset '.tar.gz' --to gotop && chmod +x gotop;
    test ! -r exa && eget ogham/exa --to exa && chmod +x exa;
    test ! -r bat && eget sharkdp/bat --to bat && chmod +x bat;
    test ! -r starship && eget starship/starship --to starship && chmod +x starship;
    test ! -r gh && eget cli/cli --asset '.tar.gz' --to gh && chmod +x gh;
    test ! -r fzf && eget junegunn/fzf --to fzf && chmod +x fzf;
    command -v zsh >/dev/null 2>&1 || eget romkatv/zsh-bin --asset '^.asc' --file 'bin/zsh' --to zsh && chmod +x zsh;

    # Load zsh. TODO: Use a real multiline string that doesn't break things
    echo 'export SHELL=$(which zsh)' >> ~/.profile
    echo 'if [ -x "$ZSH_PATH" ]; then' >> ~/.profile
    echo '    ZSH_PATH=$SHELL' >> ~/.profile
    echo '    exec "$ZSH_PATH" -l' >> ~/.profile
    echo 'fi' >> ~/.profile
fi

exec zsh