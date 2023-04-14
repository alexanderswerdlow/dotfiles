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
    export NVM_DIR="$HOME/.nvm"

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
            "$HOME/go/bin"
            "$HOME/.bun/bin:$PATH"
            "$HOME/.nvm/versions/node/v16.20.0/bin"
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

    if [[ $(hostname) =~ gpu[0-9]{2} ]]; then
        export TMPDIR=$HOME/tmp
        export NUSCENES_DATA_DIR=/data/datasets/nuscenes
        export ARGOVERSE_DATA_DIR=/data/datasets/av2
        export WAYMO_DATA_DIR=/data1/datasets/waymo_open_dataset_v_1_4_2
        export SAVE_DATA_DIR=/data/datasets
        export TORCH_CUDNN_V8_API_ENABLED=1
        export NCCL_P2P_DISABLE=1
    fi
fi

export PATH
