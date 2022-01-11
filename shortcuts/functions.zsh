function rga-fzf() {
	RG_PREFIX="rga --files-with-matches"
	local file
	file="$(
		FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
			fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
				--phony -q "$1" \
				--bind "change:reload:$RG_PREFIX {q}" \
				--preview-window="70%:wrap"
	)" &&
	echo "opening $file" &&
	subl "$file"
}

function rg-fzf(){
  INITIAL_QUERY=$1
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
    fzf --bind "change:reload:$RG_PREFIX {q} || true" \
        --ansi --disabled --query "$INITIAL_QUERY" \
        --height=50% --layout=reverse
}

function jdk() {
    version=$1
    export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
    java -version
}

function timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

function gcd() {
  git clone "$1" && cd "$(basename "$1" .git)"
}

function upgrade() {
    $1 -m pip install --upgrade pip
}

function sman() {
    man $1 | col -b | subl
}

function take() {
  mkdir $1 && cd $1
}

function encodeuri {
  local string="${@}"
  local strlen=${#string}
  local encoded=""

  for (( pos = 0; pos < strlen; pos ++ )); do
    c=${string:$pos:1}
    case "$c" in
      [-_.~a-zA-Z0-9]) o="${c}" ;;
      *) printf -v o '%%%02x' "'$c"
    esac
    encoded+="${o}"
  done
  echo "${encoded}"
}

# Example Usage: matlabr script.m
function matlabr {
  matlabb -nodisplay -nosplash -nodesktop -r "run('$1');"
}

function ffind {
  find . -name "*$1*" -print
}

function venv {
  $1 -m venv venv
}