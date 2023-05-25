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
    test ! -r gdu && eget dundee/gdu --asset 'static' --to gdu && chmod +x gdu;
    test ! -r zoxide && eget ajeetdsouza/zoxide --to zoxide && chmod +x zoxide;
    test ! -r gotop && eget xxxserxxx/gotop --asset '.tgz' --to gotop && chmod +x gotop;
    test ! -r exa && eget ogham/exa --asset 'musl' --to exa && chmod +x exa;
    test ! -r bat && eget sharkdp/bat --asset 'musl' --to bat && chmod +x bat;
    test ! -r starship && eget starship/starship --asset 'musl' --to starship && chmod +x starship;
    test ! -r gh && eget cli/cli --asset '.tar.gz' --to gh && chmod +x gh;
    test ! -r fzf && eget junegunn/fzf --to fzf && chmod +x fzf;
    if ! command -v zsh > /dev/null 2>&1; then
        eget romkatv/zsh-bin --asset '^.asc' --file 'bin/zsh' --to zsh && chmod +x zsh
    fi

    cd "$HOME"

    # Load zsh. TODO: Use a real multiline string that doesn't break things
    # Check if the commands are already in the .profile
    if [ ! -f ~/.profile ] || ! grep -qF "exec" ~/.profile; then
        echo "Adding to ~/.profile"
        cat <<- EOF >> ~/.profile
		if [ -n "\$ZSH_VERSION" ]; then
		    : 
		elif [ -x "\$(command -v zsh)" ]; then
		    export SHELL=\$(which zsh)
		    exec \$SHELL
		fi
		EOF
    fi

fi