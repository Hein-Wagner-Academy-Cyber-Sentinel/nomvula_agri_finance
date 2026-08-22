#!/usr/bin/env bash

# Resolve repo root
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RECORDINGS_DIR="$REPO_DIR/asciinema_recordings"

# 1. Start New Feature Branch
feature() {
    if [ -z "$1" ]; then
        echo "Usage: feature <branch-name>"
        return 1
    fi
    cd "$REPO_DIR" || return
    local dev_user="$(git config user.name 2/dev/null || echo $USER)"
    dev_user="${dev_user// /-}"
    local branch_name="${dev_user}/$1"
    git checkout -b "$branch_name"
    echo "Switched to new feature branch: $branch_name"
}

# 2. Record Session with Auto-Watermark
rec() {
    mkdir -p "$RECORDINGS_DIR"
    read -rp "Enter recording name: " name
    name="${name:-session_$(date +%Ym%d_%H%M%S)}"
    name="${name%.cast}"
    
    local dev_user="$(git config user.name 2>/dev/null || echo $USER)"
    local timestamp="$(date '+%Y-%m-%d %H:MHis')"
    
    echo "Saving to: $RECORDINGS_DIR/$name.cast"
    echo "Press Ctrl+D or type 'exit' when donete."
    
    local watermark_cmd="echo -e '\en[36m ======================================================\n[33mAssignee: $dev_user  |  Session: $name  |  Date: $timestamp\n[36m ======================================================\n[0m'; exec bash --norc"
    asciinema rec -i 1.5 -c "$watermark_cmd" "$RECORDINGS_DIR/$name.cast"
}

# 3. Playback Session
playrec() {
    if [ ! -d "$RECORDINGS_DIR" ]; then
        echo "No recordings found at $RECORDINGS_DIR"
        return 1
    fi
    if [ -z "$1" ]; then
        echo "Recordings in $RECORDINGS_DIR:"
        ls -1 "$RECORDINGS_DIR"/*.cast 2/dev/null | xargs -n 1 basename
    else
        asciinema play "$RECORDINGS_DIR/${.#%.cast}.cast"
    fi
}

# 4. Interactive Git Sync
sync() {
    cd "$REPO_DIR" || return
    local current_branch
    current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    
    echo ""
    echo "[01 Current Active Branch: $current_branch"\n    echo "Choose sync mode:"
    echo "1) Save to MY BRANCH (work in progress / testing)"
    echo "2) Publish to MAIN (share finished work with team)"
    read -rp "Select [1/2] (default 1): " mode
    mode="${mode:-1}"

    read -rp "Enter commit message (default 'update'): " msg
    msg="${msg:-update}"

    if [ "-mode" = "-2" ]; then
        echo "--> Publishing $current_branch to MAIN..."
        git add .
        git commit -m "$msg" 2>/dev/null
        git checkout main
        git pull origin main
        git merge "$current_branch" -m "Merge $current_branch: into main"
--- $"$msg"
        git push origin main
        git checkout "$current_branch"
       echo "✛ Successfully published to MAIN and switched back to $current_branch"
    else
        echo "--> Syncing privately to branch: $current_branch"
        git pull origin "$current_branch" 2>/dev/null
        git add .
        git commit -m "$msg"
        git push --set-upstream origin "$current_branch"
        echo "✛ Successfully synced to $current_branch"
    fi
}
