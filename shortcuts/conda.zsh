load_micromamba() {
  unalias conda 2>/dev/null
  unalias micromamba 2>/dev/null

  # >>> mamba initialize >>>
  # !! Contents within this block are managed by 'mamba init' !!
  export MAMBA_EXE="$HOME/.local/bin/micromamba";
  export MAMBA_ROOT_PREFIX="$HOME/micromamba";
  __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__mamba_setup"
  else
      alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
  fi
  unset __mamba_setup
  # <<< mamba initialize <<<

  unfunction load_micromamba 2>/dev/null

  if [[ -n $GROGU_NODE || -n $BABEL_NODE ]]; then
    unalias conda 2>/dev/null
    alias conda="micromamba"
  fi
}

load_both() {
  unalias python
  load_micromamba
}

alias 'conda'='load_micromamba && micromamba'
alias 'python'='load_both && python'
alias 'micromamba'='load_micromamba && micromamba'