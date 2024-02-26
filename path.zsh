export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_AUTO_UPDATE_SECS="604800"
export SECRETS="$HOME/Documents/Programs/secrets.ini"
export PYTHONSTARTUP=$DOTFILES/scripts/pythonrc.py
export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES
export EINX_WARN_ON_RETRACE=25

# Remove duplicates
typeset -U path PATH
typeset -U cpath CPATH
typeset -U ld_library_path LD_LIBRARY_PATH

join() {
    local IFS="$1"
    shift
    echo "$*"
}

# Global macOS exports/paths here
if [[ "$OS" == "macos" ]]; then
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
            "$HOME/.bun/bin"
            "$HOME/.nvm/versions/node/v16.20.0/bin"
            $path)

elif [[ "$OS" == "linux" ]]; then
    if [[ -v MATRIX_NODE ]]; then
        # export CUDA_HOME="/projects/katefgroup/cuda_home/cuda/12.3"
        export CUDA_HOME="/opt/cuda/11.8"
    else
        export CUDA_HOME="/usr/local/cuda"

        # For MuJoCo:
        # export MUJOCO_PY_MUJOCO_PATH="$HOME/.mujoco/mujoco210"
        # export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$MUJOCO_PY_MUJOCO_PATH/bin"
        # export LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libGLEW.so"

        ld_library_path=(
            "$CUDA_HOME/lib64"
            "/usr/lib/nvidia"
            $ld_library_path
        )

    fi

    export CPATH="$CUDA_HOME/include:$CPATH"
    export CONDA_AUTO_ACTIVATE_BASE=false
    export NUSCENES_DATA_DIR="$HOME/datasets/nuscenes"

    if [[ $(hostname) =~ gpu[0-9]{2} ]]; then
        export TMPDIR=$HOME/tmp
        export NUSCENES_DATA_DIR=/data/datasets/nuscenes
        export ARGOVERSE_DATA_DIR=/data/datasets/av2
        export WAYMO_DATA_DIR=/data1/datasets/waymo_open_dataset_v_1_4_2
        export SAVE_DATA_DIR=/data/datasets
        export TORCH_CUDNN_V8_API_ENABLED=1
        export NCCL_P2P_DISABLE=1
    fi

    if [[ -v MATRIX_NODE ]]; then
        path=(  
            "/opt/git/2.30/bin"
            "/opt/gcc/9.2.0/bin"
            "$HOME/bin/node/bin"
            "$HOME/bin/cmake/bin"
            "$HOME/.local/bin"
            "$HOME/.npm-packages"
            "$HOME/.pyenv/bin"
            "$CUDA_HOME/bin"
            "$DOTFILES/scripts/matrix"
            "$DOTFILES/scripts/matrix/disk_utils"
            "$HOME/.npm-packages/bin"
            "$HOME/local/bin"
            $path
        )

        ld_library_path=(
            "$CUDA_HOME/lib64"
            "$HOME/lib"
            "/opt/git/2.30/lib"
            "/opt/gcc/9.2.0/lib64"
            "/opt/gcc/9.2.0/lib"
            "$HOME/local/lib"
            $ld_library_path
        )

        export CFLAGS="-I$HOME/include $CFLAGS"
        export CPPFLAGS="-I$HOME/include $CPPFLAGS"
        export LDFLAGS="-L$HOME/lib $LDFLAGS"

        export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man:/opt/gcc/9.2.0/share/man:$HOME/local/share/man"
        
        export TORCH_CUDA_ARCH_LIST="6.1;7.0;7.5;8.0;8.6"
        # export CUDA_VISIBLE_DEVICES=$(cudavisibledevices)

        export DETECTRON2_DATASETS="/projects/katefgroup/language_grounding/SEMSEG_100k"
        export OMP_NUM_THREADS=8

        export HOMEBREW_RELOCATE_BUILD_PREFIX='/home/aswerdlo/perm/homebrew'
        export HOMEBREW_CURL_PATH='/home/aswerdlo/bin/curl'
        export HOMEBREW_GIT_PATH='/opt/git/2.30/bin/git'
        export HOMEBREW_CURLRC=1
        
        export PYENV_ROOT="$HOME/.pyenv"
        export ZSH_PYENV_LAZY_VIRTUALENV=true
        export TERMINFO_DIRS=/etc/terminfo:/usr/share/terminfo

        alias python3.8="$HOME/perm/compiled/python-3.8.17/install/bin/python3.8"
        alias python3.9="$HOME/perm/compiled/python-3.9.18/install/bin/python3.9"
        alias python3.10="$HOME/perm/compiled/python-3.10.13/install/bin/python3.10"
        alias python3.11="$HOME/perm/compiled/python-3.11.5/install/bin/python3.11"
        export NGROK_AUTHTOKEN='2WNZUQfQnTnUQLqmMZtXBB4vbMs_7g7sqAewsnz86V5koxTZH'
    else
        path=(        
            "/home/linuxbrew/.linuxbrew/bin"
            $path
        )
    fi

    path=(  
        "$DOTFILES/scripts"
        "$HOME/bin"
        "$HOME/bin/cluster-scripts"
        "$CUDA_HOME/bin"
        "$HOME/.local/bin"
        # "/home/linuxbrew/.linuxbrew/bin"
        # "$HOME/anaconda3/bin"
        $path
    )

    LD_LIBRARY_PATH=$(join ':' "${ld_library_path[@]}")
fi

export PATH
export CPATH
export LD_LIBRARY_PATH