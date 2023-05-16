cat <<'EOF' >> ~/.profile
export SHELL=$(which zsh)
if [ -x "$ZSH_PATH" ]; then
    ZSH_PATH=$SHELL
    exec "$ZSH_PATH" -l
fi
EOF