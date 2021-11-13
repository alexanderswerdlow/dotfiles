# Global macOS exports/paths here
if [[ "$OS" == "macOS" ]]; then
    export ZSH_PYENV_LAZY_VIRTUALENV=true
    export SECRETS="$HOME/Documents/Programs/secrets.ini"
    export HOMEBREW_NO_ANALYTICS=1
    export HOMEBREW_NO_INSECURE_REDIRECT=1
    export HOMEBREW_CASK_OPTS=--require-sha
    export HOMEBREW_AUTO_UPDATE_SECS="604800"
    export MUJOCO_PY_MUJOCO_PATH="$HOME/.mujoco/mujoco210"
    export PAGER="col -b  | open -a /Applications/Google\ Chrome.app -f"
    export PYENV_ROOT="$HOME/.pyenv"
    export STREET_VIEW_DATA_DIR="/Volumes/GoogleDrive/Shared drives/EE209AS/data"
    # export HOMEBREW_NO_AUTO_UPDATE="1"

    # Remove duplicates
    typeset -U path

    path=(  "$DOTFILES/scripts"
            "$HOME/bin"
            "$HOME/Documents/Programs/bin"
            "$HOME/.local/bin"
            "$HOME/Library/Python/3.8/bin"
            "$HOME/Library/Python/3.9/bin"
            "$BREWPREFIX/opt/python/libexec/bin"
            "$BREWPREFIX/sbin"
            "$BREWPREFIX/bin"
            "node_modules/.bin:vendor/bin"
            "/usr/bin"
            "/bin"
            "/usr/sbin"
            "/sbin"
            $path)

    # "$BREWPREFIX/coreutils/libexec/gnubin"
    # "$BREWPREFIX/opt/grep/libexec/gnubin"
    # "$BREWPREFIX/opt/gnu-tar/libexec/gnubin"
    # "$BREWPREFIX/opt/make/libexec/gnubin"
fi

# Machine specific exports
if [[ "$MACHINE" == "X86" ]]; then
    path+=("$HOME/go/bin")
    path+=("$MUJOCO_PY_MUJOCO_PATH/bin")

elif [[ "$MACHINE" == "ARM64" ]]; then

    path+=( "$INTEL_BREW_PREFIX/opt/python@3.9/libexec/bin"
            "$INTEL_BREW_PREFIX/bin"
            "$INTEL_BREW_PREFIX/sbin"
            "$HOME/.node/bin" )
    
    export GEM_HOME="$HOME/.gem"
    export ZPYI_IMPORTS="requests numpy"
fi

export PATH

