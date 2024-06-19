export DOTFILES=$HOMEDIR/dotfiles
export GITHUB="$HOMEDIR/github"
export ARM_BREW_PREFIX='/opt/homebrew'
export LINUX_BREW_PREFIX='/home/linuxbrew/.linuxbrew'
export INTEL_BREW_PREFIX='/usr/local' # Rarely used but here just in case
export IDE='code'

# Determine what type of machine we're running on
# This affects what we source, put on our path, and which aliases we use
if [ "$(uname)" = "Darwin" ]; then
  export OS='macos'
  cpu_str=$(sysctl -a | grep 'machdep.cpu.brand_string')
  arm64_cpu="Apple M1"
  if [[ "$cpu_str" == *"$arm64_cpu"* ]]; then
    export MACHINE='ARM64'
    export BREWPREFIX=$ARM_BREW_PREFIX
  else
    export MACHINE='X86'
    export BREWPREFIX=$INTEL_BREW_PREFIX
  fi
else
  export OS='linux'
  export MACHINE='Other'
  export BREWPREFIX=$LINUX_BREW_PREFIX
fi


