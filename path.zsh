if [[ "$OS" == "macOS" ]]; then
    ZSH_PYENV_LAZY_VIRTUALENV=true
    export SECRETS="$HOME/Documents/Programs/secrets.ini"
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_INSECURE_REDIRECT=1
    export HOMEBREW_CASK_OPTS=--require-sha
    export HOMEBREW_AUTO_UPDATE_SECS="604800"
    # export HOMEBREW_NO_AUTO_UPDATE="1"
    # export PAGER="col -b  | open -a /Applications/Google\ Chrome.app -f"

    # Remove duplicates
    typeset -U path

    path=(  "$DOTFILES/scripts"
            "$HOME/bin"
            "$HOME/Documents/Programs/bin"
            "$HOME/.local/bin"
            "$HOME/.node/bin"
            "$HOME/Library/Python/3.8/bin"
            "$HOME/Library/Python/3.9/bin"
            "$BREWPREFIX/opt/python/libexec/bin"
            "$BREWPREFIX/sbin"
            "$BREWPREFIX/bin"
            "$BREWPREFIX/coreutils/libexec/gnubin"
            "$BREWPREFIX/opt/gnu-tar/libexec/gnubin"
            "node_modules/.bin:vendor/bin"
            "/usr/bin"
            "/bin"
            "/usr/sbin"
            "/sbin"
            $path)
fi


if [[ "$MACHINE" == "X86" ]]; then
    path+=("$HOME/go/bin")

    # "$BREWPREFIX/lib/python3.9/site-packages"
    # "$HOME/Library/Python/3.9/lib/python/site-packages"
elif [[ "$MACHINE" == "ARM64" ]]; then

    path+=( "$ARM_BREW_PREFIX/opt/openssl@1.1/bin"
            "$INTEL_BREW_PREFIX/bin"
            "$INTEL_BREW_PREFIX/sbin")

    export PYENV_ROOT="$HOME/.pyenv"
    export GEM_HOME="$HOME/.gem"
    export ZPYI_IMPORTS=requests
fi

export PATH