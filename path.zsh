export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_AUTO_UPDATE_SECS="604800"

# Remove duplicates
typeset -U path

# Global macOS exports/paths here
if [[ "$OS" == "macOS" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export ZSH_PYENV_LAZY_VIRTUALENV=true
    export SECRETS="$HOME/Documents/Programs/secrets.ini"
    export PAGER="col -b  | open -a /Applications/Google\ Chrome.app -f"

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
            "/opt/homebrew/anaconda3/bin"
            "$HOME/.node/bin"
            "$PYENV_ROOT/bin"
            $path)

elif [[ "$OS" == "Linux" ]]; then
    export SECRETS="$HOME/Documents/Programs/secrets.ini"
    # export LD_LIBRARY_PATH=$LD_LIBRARY_PATH/usr/local/cuda-11.5/lib64
    export MUJOCO_PY_MUJOCO_PATH="$HOME/.mujoco/mujoco210"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$MUJOCO_PY_MUJOCO_PATH/bin"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib/nvidia"
    export LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libGLEW.so"
    path+=( "$MUJOCO_PY_MUJOCO_PATH/bin"
            "$DOTFILES/scripts"
            "$HOME/bin"
            # "/usr/local/cuda-11.5/bin"
            "/home/aswerdlow/.local/bin"
        )
fi

export PATH
