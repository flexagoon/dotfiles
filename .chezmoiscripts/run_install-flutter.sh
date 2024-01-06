#!/bin/sh

FLUTTER_PATH="$HOME/.local/share/flutter"

if [ ! -d $FLUTTER_PATH ]; then
    echo "Flutter not found"
    LATEST_VERSION=$(curl -s 'https://api.github.com/repos/flutter/flutter/git/refs/tags' | jq -r '.[].ref' | grep -v 'pre' | tail -n 1 | cut -d '/' -f 3)
    echo "Downloading Flutter $LATEST_VERSION"
    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_$LATEST_VERSION-stable.tar.xz"
    mkdir -p $FLUTTER_PATH
    curl $FLUTTER_URL | tar -xJ -C $FLUTTER_PATH --strip-components=1
fi
