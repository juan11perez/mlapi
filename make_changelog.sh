#!/bin/bash
if [ -z "$1" ]; then
    TAGVER=`python3 ./mlapi.py --version`
else
        TAGVER=$1
fi
VER="${TAGVER/v/}"
read -p "Future release is v${VER}. Please press any key to confirm..."
github_changelog_generator -u pliablepixels -p mlapi  --future-release v${VER}
#github_changelog_generator  --future-release v${VER}

