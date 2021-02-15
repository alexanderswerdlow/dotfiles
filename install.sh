#!/bin/sh

if uname | grep -q 'darwin'; then
    echo 'Running on macOS. Rethinking life'
    exit 1
fi

curl -fsSL https://starship.rs/install.sh | bash -s -- -y