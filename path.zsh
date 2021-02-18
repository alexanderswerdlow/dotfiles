if [[ "$MACHINE" == "X86" ]]; then
    # Load Node global installed binaries
    export PATH="$HOME/.node/bin:$PATH"

    # Use project specific binaries before global ones
    export PATH="node_modules/.bin:vendor/bin:$PATH"

    export PATH="$HOME/Library/Python/3.8/bin:$PATH" # System Python
    export PATH="$HOME/Library/Python/3.9/bin:$PATH"
    export PATH="$HOME/Library/Python/3.9/lib/python/site-packages:$PATH" # Brew Python3 User Packages
    export PATH="$/usr/local/lib/python3.9/site-packages:$PATH" # Brew Python3 Packages
    export PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

    export PATH="$PATH:/Users/aswerdlow/.local/bin"
    export PATH="/usr/local/sbin:$PATH"
    export PATH="$HOME/bin:$PATH"
    export PATH="/usr/local/Homebrew/bin:$PATH"
    export PAGER="col -b  | open -a /Applications/Google\ Chrome.app -f"
elif [[ "$MACHINE" == "ARM64" ]]; then
    # Python (System Pip)
    export PATH="/Users/aswerdlow/Library/Python/3.8/bin:$PATH"
    export PATH="/Users/aswerdlow/Library/Python/3.9/bin:$PATH"

    # Other
    export PATH="node_modules/.bin:vendor/bin:$PATH" # Use project specific binaries before global ones

    # Sytem
    export PATH="/usr/local/opt/qt/bin:$PATH"

    # Homebrew
    export PATH="/opt/homebrew/bin:$PATH"
    export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
    export PATH="/opt/homebrew/opt/python@3.9/libexec/bin:$PATH"

    # User
    export PATH="/usr/local/sbin:$PATH"
    export PATH="/Users/aswerdlow/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/.node/bin:$PATH"


    # Flags
    export PYENV_ROOT="$HOME/.pyenv"
    export GEM_HOME="$HOME/.gem"
    export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib -L/usr/local/opt/readline/lib -L/usr/local/opt/sqlite/lib -L/usr/local/opt/zlib/lib"
    export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include -I/usr/local/opt/readline/include -I/usr/local/opt/sqlite/include -I/usr/local/opt/zlib/include"

    export ZPYI_IMPORTS=requests
    # export PAGER="col -b  | open -a /Applications/Sublime\ Text.app -f"
    export PAGER="col -b  | open -a /Applications/Google\ Chrome\ Dev.app -f"
else
    # Do Nothing
fi


if [[ "$OS" == "macOS" ]]; then
    ZSH_PYENV_LAZY_VIRTUALENV=true
    export SECRETS="$HOME/Documents/Programs/secrets.ini"
fi