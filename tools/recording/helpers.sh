#!/usr/bin/env bash

# Resolve repo root dynamically (2 levels up from tools/recording/)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RECORDINGS_DIR="$REPO_DIR/asciinema_recordings"

# Helper: Ensure ssh-agent is running and shared across terminal sessions
_ensure_ssh_agent() {
    if [ -z "$SSH_AUTH_SOCK" ] || ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
        if [ -f "$HOME/.ssh/agent.env" ]; then
            source "$HOME/.ssh/agent.env" >/dev/null 2>&1
        fi
        if [ -z "$SSH_AUTH_SOCK" ] || ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
            eval "$(ssh-agent -s)" >/dev/null 2>&1
            echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" > "$HOME/.ssh/agent.env"
            echo "export SSH_AGENT_PID=$SSH_AGENT_PID" >> "$HOME/.ssh/agent.env"
        fi
    fi

    # Check if id_ed25519 key is registered in agent
    if ! ssh-add -l 2>/dev/null | grep -q "id_ed25519"; then
        if [ -f "$HOME/.ssh/id_ed25519" ]; then
            echo "Authenticating SSH key for GitHub..."
            ssh-add "$HOME/.ssh/id_ed25519" || {
                echo "Warning: SSH key not unlocked. Pushing or pulling via SSH may require authentication."
            }
        fi
    fi
}

# 1. Feature Branch Command
feature() {
    if [ -z "$1" ]; then
        echo "Usage: feature <branch-name> (or: feat <branch-name>)"
        return 1
    fi
    cd "$REPO_DIR" || return 1
    local dev_user
    dev_user="$(git config user.name 2>/dev/null || echo "$USER")"
    dev_user="${dev_user// /-}"
    local branch_name="${dev_user}/$1"
    git checkout -b "$branch_name"
    echo "Switched to new feature branch: $branch_name"
}
alias feat='feature'

# 2. Recording Command (with Auto-Watermark)
rec() {
    mkdir -p "$RECORDINGS_DIR"
    read -rp "Enter recording name: " name
    name="${name:-session_$(date +%Y%m%d_%H%M%S)}"
    name="${name%.cast}"
    
    local dev_user
    dev_user="$(git config user.name 2>/dev/null || echo "$USER")"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    echo "Saving to: $RECORDINGS_DIR/$name.cast"
    echo "Press Ctrl+D or type 'exit' when done."
    
    local watermark_cmd="echo -e '\033[36m======================================================\n\033[33mAssignee: $dev_user  |  Session: $name  |  Date: $timestamp\n\033[36m======================================================\033[0m'; exec bash"
    asciinema rec -i 1.5 -c "$watermark_cmd" "$RECORDINGS_DIR/$name.cast"
}

# 3. Playback Command
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
alias play='playrec'

# 4. Interactive Git Sync (SSH-Ready)
sync() {
    cd "$REPO_DIR" || { echo "Error: Cannot enter repo $REPO_DIR"; return 1; }
    
    _ensure_ssh_agent

    local current_branch
    current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    if [ -z "$current_branch" ]; then
        echo "Error: Not a valid git repository or detached HEAD."
        return 1
    fi

    echo ""
    echo -e "\033[1;32mCurrent Active Branch: $current_branch\033[0m"
    echo "Choose sync mode:"
    echo "1) Save to MY BRANCH (work in progress / testing)"
    echo "2) Publish to MAIN (share finished work with team)"
    read -rp "Select [1/2] (default 1): " mode
    mode="${mode:-1}"

    read -rp "Enter commit message (default 'update'): " msg
    msg="${msg:-update}"

    if [ "$mode" = "2" ]; then
        echo "--> Publishing $current_branch to MAIN..."
        git add .
        if ! git diff --cached --quiet; then
            git commit -m "$msg"
        fi

        if [ "$current_branch" = "main" ]; then
            echo "--> Already on main. Pulling and pushing updates..."
            git pull --rebase origin main
            git push origin main
            echo "Successfully synced MAIN."
        else
            echo "--> Switching to main to merge..."
            git checkout main
            git pull origin main
            echo "--> Merging $current_branch into main..."
            git merge "$current_branch" -m "Merge $current_branch into main: $msg"
            git push origin main
            git checkout "$current_branch"
            echo "Successfully published $current_branch to MAIN and returned to $current_branch."
        fi
    else
        echo "--> Syncing privately to branch: $current_branch..."
        if git ls-remote --exit-code --heads origin "$current_branch" >/dev/null 2>&1; then
            git pull origin "$current_branch"
        fi
        git add .
        if ! git diff --cached --quiet; then
            git commit -m "$msg"
        else
            echo "No local changes to commit."
        fi
        git push --set-upstream origin "$current_branch"
        echo "Successfully synced to $current_branch."
    fi
}

# 5. Virtual Environment Activation
alp() {
    if [ -f "$HOME/alp-env/bin/activate" ]; then
        source "$HOME/alp-env/bin/activate"
        echo "ALP virtual environment activated."
    else
        echo "Error: Virtual environment not found at $HOME/alp-env/bin/activate"
        return 1
    fi
}
alias activate-alp='alp'

# 6. Workspace Synchronization (Windows Documents <-> Linux WSL)
move() {
    local src_repo="$REPO_DIR"
    local src_rec="$RECORDINGS_DIR"
    local win_dest="/mnt/c/Users/michael/Documents/nomvula_agri_finance"

    mkdir -p "$win_dest"
    echo "Syncing repository from Linux to Windows Documents..."
    if [ -d "$src_repo" ]; then
        # Uses --delete so files deleted or moved in Git are purged from Windows, preventing ghost file resurrection
        rsync -rtv --delete --exclude=".git" --exclude="asciinema_recordings" "$src_repo/" "$win_dest/"
    fi
    if [ -d "$src_rec" ]; then
        mkdir -p "$win_dest/asciinema_recordings"
        rsync -rtv --update "$src_rec/" "$win_dest/asciinema_recordings/"
    fi
    echo "Done. Windows Documents now matches your Linux workspace."
}

update() {
    local win_src="/mnt/c/Users/michael/Documents/nomvula_agri_finance"
    local dest_repo="$REPO_DIR"
    local dest_rec="$RECORDINGS_DIR"

    if [ ! -d "$win_src" ]; then
        echo "Error: Windows Documents folder not found at $win_src"
        return 1
    fi

    echo "Retrieving changes from Windows Documents to Linux..."
    if [ -d "$dest_repo" ]; then
        # Preserves Linux permissions and ignores Windows metadata to prevent dirty Git index
        rsync -rtv --update --no-perms --no-owner --no-group --exclude=".git" --exclude="asciinema_recordings" "$win_src/" "$dest_repo/"
    fi
    if [ -d "$win_src/asciinema_recordings" ]; then
        mkdir -p "$dest_rec"
        rsync -rtv --update "$win_src/asciinema_recordings/" "$dest_rec/"
    fi
    echo "Done. Linux workspace updated with Windows edits."
}

alias move-nomvula='move'
alias update-nomvula='update'
