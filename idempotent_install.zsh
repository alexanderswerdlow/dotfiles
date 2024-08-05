export BIN="$HOMEDIR/bin"

command -v eget >/dev/null 2>&1 || curl https://zyedidia.github.io/eget.sh | sh;
command -v gdu >/dev/null 2>&1 || (eget dundee/gdu --asset 'static' --to $BIN/gdu && chmod +x $BIN/gdu && echo "Installed gdu");
command -v zoxide >/dev/null 2>&1 || (eget ajeetdsouza/zoxide --to $BIN/zoxide && chmod +x $BIN/zoxide && echo "Installed zoxide");
command -v gotop >/dev/null 2>&1 || (eget xxxserxxx/gotop --asset '.tgz' --to $BIN/gotop && chmod +x $BIN/gotop && echo "Installed gotop");
command -v exa >/dev/null 2>&1 || (eget ogham/exa --asset 'musl' --to $BIN/exa && chmod +x $BIN/exa && echo "Installed exa");
command -v bat >/dev/null 2>&1 || (eget sharkdp/bat --asset 'musl' --to $BIN/bat && chmod +x $BIN/bat && echo "Installed bat");
command -v starship >/dev/null 2>&1 || (eget starship/starship --asset 'musl' --to $BIN/starship && chmod +x $BIN/starship && echo "Installed starship");
command -v gh >/dev/null 2>&1 || (eget cli/cli --asset '.tar.gz' --to $BIN/gh && chmod +x $BIN/gh && echo "Installed gh");
command -v fzf >/dev/null 2>&1 || (eget junegunn/fzf --to "$BIN/fzf" && chmod +x $BIN/fzf && echo "Installed fzf");
command -v fd >/dev/null 2>&1 || (eget sharkdp/fd --to "$BIN/fd" && chmod +x $BIN/fd && echo "Installed Fd");
command -v hyperfine >/dev/null 2>&1 || (eget sharkdp/hyperfine --to "$BIN/hyperfine" && chmod +x $BIN/hyperfine && echo "Installed hyperfine");
command -v rg >/dev/null 2>&1 || (eget BurntSushi/ripgrep --to "$BIN/rg" && chmod +x $BIN/rg && echo "Installed rg");
command -v micro >/dev/null 2>&1 || (eget zyedidia/micro --tag nightly --asset "static" --to "$BIN/micro" && chmod +x $BIN/micro && echo "Installed micro");
command -v parquet-tools >/dev/null 2>&1 || (eget hangxie/parquet-tools --to "$BIN/parquet-tools" && chmod +x $BIN/parquet-tools && echo "Installed parquet-tools");
command -v jq >/dev/null 2>&1 || (eget jqlang/jq --asset "amd64" --to "$BIN/jq" && chmod +x $BIN/jq && echo "Installed jq");
