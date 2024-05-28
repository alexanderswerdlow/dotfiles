#!/bin/sh

trigger_vscode_remote_editing() (
    # Tell zsh to use bash-style arrays
    setopt ksh_arrays 2> /dev/null || true

    # The git extension runs 'git status -z -u' on the remote machine,
    # which takes a very long time if the remote directory is a git repo
    # with a lot of untracked files.
    # That can be fixed if you configure .gitignore appropriately,
    # but for my purposes it's easier to just disable git support when editing remote files.
    # If you want git support when using remote SSH, then comment out this line.
    # See: https://github.com/microsoft/vscode-remote-release/issues/4073
    #  --disable-extension vscode.git --disable-extension vscode.github --disable-extension waderyan.gitblame
    VSCODE=$(which $IDE)
    VSCODE="${VSCODE}"
    LOGFILE=/tmp/iterm-vscode-trigger.log
    FTYPE=$1
    MACHINE=$2
    FILEPATHS=( "$@" )
    FILEPATHS=( "${FILEPATHS[@]:2}" )

    TS="["$(date "+%Y-%m-%d %H:%M:%S")"]"
    echo "${TS} Triggered: ""$@" >> ${LOGFILE}

    # https://github.com/microsoft/vscode-remote-release/issues/585#issuecomment-536580102
    if [[ "${FTYPE}" == "directory" ]]; then
        CMD="${VSCODE} --remote ssh-remote+${MACHINE} ${FILEPATHS[@]}"
        echo "${TS} ${CMD}" >> ${LOGFILE}
        ${CMD}
    elif [[ "${FTYPE}" == "file" ]]; then
        for FN in ${FILEPATHS[@]}; do
            CMD="${VSCODE} --file-uri vscode-remote://ssh-remote+${MACHINE}${FN}"
            echo "${TS} ${CMD}" >> ${LOGFILE}
            ${CMD}
        done
    else
        echo "${TS} Error: Bad arguments." >> ${LOGFILE}
        exit 1
    fi
)

trigger_vscode_remote_editing "$@"