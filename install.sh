#!/bin/sh

if [ "$(uname)" == "Darwin" ]; then
    echo 'Running on macOS. Rethinking life'
    exit 1
fi

curl -fsSL https://starship.rs/install.sh | bash