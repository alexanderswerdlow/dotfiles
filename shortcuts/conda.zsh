
lazy_conda_aliases=('conda')
lazy_micromamba_aliases=('micromamba')
lazy_both_aliases=('python' 'source')

load_both() {
  for lazy_both_alias in $lazy_both_aliases
  do
    unalias $lazy_both_alias
  done
  load_conda
  load_micromamba
}

load_conda() {
  for lazy_conda_alias in $lazy_conda_aliases
  do
    unalias $lazy_conda_alias
  done

  __conda_prefix="$HOME/anaconda3" # Set your conda Location

  # >>> conda initialize >>>
  __conda_setup="$("$__conda_prefix/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  else
      if [ -f "$__conda_prefix/etc/profile.d/conda.sh" ]; then
          . "$__conda_prefix/etc/profile.d/conda.sh"
      else
          export PATH="$__conda_prefix/bin:$PATH"
      fi
  fi
  unset __conda_setup
  # <<< conda initialize <<<

  unset __conda_prefix
  unfunction load_conda
}


load_micromamba() {
  for lazy_micromamba_alias in $lazy_micromamba_aliases
  do
    unalias $lazy_micromamba_alias
  done

  # >>> mamba initialize >>>
  # !! Contents within this block are managed by 'mamba init' !!
  export MAMBA_EXE='/home/aswerdlo/.local/bin/micromamba';
  export MAMBA_ROOT_PREFIX='/home/aswerdlo/micromamba';
  __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__mamba_setup"
  else
      alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
  fi
  unset __mamba_setup
  # <<< mamba initialize <<<

  unfunction load_micromamba
}

for lazy_conda_alias in $lazy_conda_aliases
do
  alias $lazy_conda_alias="load_conda && $lazy_conda_alias"
done

for lazy_micromamba_alias in $lazy_micromamba_aliases
do
  alias $lazy_micromamba_alias="load_micromamba && $lazy_micromamba_alias"
done

# for lazy_both_alias in $lazy_both_aliases
# do
#   alias $lazy_both_alias="load_both && $lazy_both_alias"
# done
