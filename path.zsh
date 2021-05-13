if [[ "$MACHINE" == "X86" ]]; then
    path=(  "$HOME/bin"
            "$HOME/.local/bin"
            "$HOME/go/bin"
            "$HOME/.node/bin"
            "$HOME/Library/Python/3.9/lib/python/site-packages"
            "$HOME/Library/Python/3.8/bin"
            "/usr/local/Homebrew/bin"
            "/usr/local/sbin"
            "/usr/local/opt/coreutils/libexec/gnubin"
            "/usr/local/opt/gnu-tar/libexec/gnubin"
            "/usr/local/lib/python3.9/site-packages"
            "node_modules/.bin:vendor/bin"
            $path)

    export PATH

    # export PAGER="col -b  | open -a /Applications/Google\ Chrome.app -f"
    export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
    export JAVA_HOME="$JAVA_8_HOME"
elif [[ "$MACHINE" == "ARM64" ]]; then

    # Remove duplicates
    typeset -U path

    path=(  "$HOME/.node/bin"
            "$HOME/.local/bin"
            "$HOME/bin"
            "$HOME/Library/Python/3.9/bin"
            "$HOME/Library/Python/3.8/bin"
            "/opt/homebrew/opt/openssl@1.1/bin"
            "/opt/homebrew/opt/python@3.9/libexec/bin"
            "/opt/homebrew/sbin"
            "/opt/homebrew/bin"
            "/usr/local/bin"
            "/usr/bin"
            "/bin"
            "/usr/sbin"
            "/sbin"
            "/usr/local/sbin"
            "node_modules/.bin:vendor/bin"
            $path)

    
    # "/opt/homebrew/opt/coreutils/libexec/gnubin"

    export PYENV_ROOT="$HOME/.pyenv"
    export GEM_HOME="$HOME/.gem"
    export ZPYI_IMPORTS=requests
    # export PAGER="col -b  | open -a /Applications/Sublime\ Text.app -f"
    # export PAGER="col -b  | open -a /Applications/Google\ Chrome\ Beta.app -f"
else
    # Do Nothing
fi


if [[ "$OS" == "macOS" ]]; then
    ZSH_PYENV_LAZY_VIRTUALENV=true
    export SECRETS="$HOME/Documents/Programs/secrets.ini"
    path=("$DOTFILES/scripts:$PATH" $path)
fi

export PATH