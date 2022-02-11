alias dash='gotop --nvidia'
alias doctor='sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get autoclean && sudo apt-get clean && sudo apt-get autoremove -y'
alias code-ssh="$DOTFILES/scripts/code_connect.py"

function ffind {
  find . -name "*$1*" -print
}

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  alias code='localcode'
fi

function localcode() (
    # Tell zsh to use bash-style arrays
    setopt ksh_arrays 2> /dev/null || true

    CMD=ITERM-TRIGGER-open-with-local-vscode-remote
    SSH_IP=$(echo $SSH_CLIENT | awk '{ print $1}')
    if [[ $SSH_IP == '::1']]; then
        LOCALCODE_MACHINE='ssh.aswerdlow.com'
    else
        LOCALCODE_MACHINE=$(echo $SSH_CONNECTION | awk '{print $3}')
    fi
    MACHINE=${LOCALCODE_MACHINE-submit}
    FILENAMES=( "$@" )

    if [[ ${#FILENAMES[@]} == 0 ]]; then
        FILENAMES=.
    fi

    if [[ ${#FILENAMES[@]} == 1 && -d ${FILENAMES[0]} ]]; then
            FILENAMES[0]=$(cd ${FILENAMES[0]}; pwd)
            FTYPE=directory
    else
        # Convert filenames to abspaths
        for (( i=0; i < ${#FILENAMES[@]}; i++ )); do
            FN=${FILENAMES[i]}
            if [[ -f ${FN} ]]; then
                DIRNAME=$(cd $(dirname ${FN}); pwd)
                FILENAMES[i]=${DIRNAME}/$(basename ${FN})
                FTYPE=file
            else
                1>&2 echo "Not a valid file: ${FN}"
                exit 1
            fi
        done
    fi

    echo ${CMD} ${FTYPE} ${MACHINE} ${FILENAMES[@]}
)