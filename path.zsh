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