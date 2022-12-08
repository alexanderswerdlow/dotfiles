export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_AUTO_UPDATE_SECS="604800"
export SECRETS="$HOME/Documents/Programs/secrets.ini"

# Remove duplicates
typeset -U path

# Global macOS exports/paths here
if [[ "$OS" == "macOS" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export ZSH_PYENV_LAZY_VIRTUALENV=true
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
            "$HOME/.cargo/bin"
            $path)

elif [[ "$OS" == "Linux" ]]; then
    export MUJOCO_PY_MUJOCO_PATH="$HOME/.mujoco/mujoco210"
    export CUDA_HOME="/usr/local/cuda-11"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$MUJOCO_PY_MUJOCO_PATH/bin"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib/nvidia"
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$CUDA_HOME/lib64"
    # export LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libGLEW.so"
    export CPATH="$CUDA_HOME/include:$CPATH"
    export CONDA_AUTO_ACTIVATE_BASE=false
    path=( "$MUJOCO_PY_MUJOCO_PATH/bin"
            "$DOTFILES/scripts"
            "$HOME/bin"
            "$CUDA_HOME/bin"
            "/home/aswerdlow/.local/bin"
            "/home/linuxbrew/.linuxbrew/bin"
            $path
            "$HOME/anaconda3/bin"
        )
    
fi

export PATH
