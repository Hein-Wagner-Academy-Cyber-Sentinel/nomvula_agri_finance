#!/usr/bin/env bash

# Resolve repo root dynamically (2 levels up from tools/recording/)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RECORDINGS_DIR="$REPO_DIR/asciinema_recordings"

# 1. Record session
rec() {
    mkdir -p "$RECORDINGS_DIR"
    
    read -rp "Enter recording name: " name
    name="${name:-session_$(date +%Y%m%d_%H%M%S)}"
    name="${name%.cast}"
    
    echo "Saving to: $RECORDINGS_DIR/$name.cast"
    echo "Press Ctrl+D or type 'exit' when done."
    
    asciinema rec -i 1.5 "$RECORDINGS_DIR/$name.cast"
}

# 2. Playback session
playrec() {
    if [ ! -d "$RECORDINGS_DIR" ]; then
        echo "No recordings found at $RECORDINGS_DIR"
        return 1
    fi

    if [ -z "$1" ]; then
        echo "Recordings in $RECORDINGS_DIR:"
        ls -1 "$RECORDINGS_DIR"/*.cast 2>/dev/null | xargs -n 1 basename
    else
        asciinema play "$RECORDINGS_DIR/${1%.cast}.cast"
    fi
}

# 3. Git Sync
sync() {
    cd "$REPO_DIR" || return
    git pull
    git add .
    if [ -z "$1" ]; then
        git commit -m "update"
    else
        git commit -m "$1"
    fi
    git push
}
