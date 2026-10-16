#!/usr/bin/env bash

# Resolve repo root dynamically (2 levels up from tools/recording/)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RECORDINGS_DIR="$REPO_DIR/asciinema_recordings"

# Clear any conflicting aliases so function definitions are never corrupted
unalias alp activate-alp feature feat rec playrec play sync move update move-nomvula update-nomvula issues issue iss 2>/dev/null || true

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
    dev_user="$(git -C "$REPO_DIR" config user.name 2>/dev/null || echo "$USER")"
    dev_user="$(echo "$dev_user" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
    local branch_name="${dev_user}/$1"
    git checkout -b "$branch_name"
    echo "Switched to new feature branch: $branch_name"
}
alias feat='feature'

# 2. Recording Command (with Auto-Watermark & Per-User Folder)
rec() {
    local dev_user
    dev_user="$(git -C "$REPO_DIR" config user.name 2>/dev/null || echo "$USER")"
    dev_user="$(echo "$dev_user" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
    local user_rec_dir="$RECORDINGS_DIR/$dev_user"
    mkdir -p "$user_rec_dir"

    read -rp "Enter recording name: " name
    name="${name:-session_$(date +%Y%m%d_%H%M%S)}"
    name="${name%.cast}"
    
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    echo "Saving to: $user_rec_dir/$name.cast"
    echo "Press Ctrl+D or type 'exit' when done."
    
    local watermark_cmd="echo -e '\033[36m======================================================\n\033[33mAssignee: $dev_user  |  Session: $name  |  Date: $timestamp\n\033[36m======================================================\033[0m'; exec bash"
    asciinema rec -i 1.5 -c "$watermark_cmd" "$user_rec_dir/$name.cast"
}

# 3. Playback Command
playrec() {
    if [ ! -d "$RECORDINGS_DIR" ]; then
        echo "No recordings found at $RECORDINGS_DIR"
        return 1
    fi
    local dev_user
    dev_user="$(git -C "$REPO_DIR" config user.name 2>/dev/null || echo "$USER")"
    dev_user="$(echo "$dev_user" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"

    if [ -z "$1" ]; then
        echo "Recordings in $RECORDINGS_DIR:"
        find "$RECORDINGS_DIR" -type f -name "*.cast" | sort | while read -r filepath; do
            echo "  ${filepath#$RECORDINGS_DIR/}"
        done
        echo ""
        echo "Usage: play <name-or-path> (e.g. play $dev_user/session1 or play session1)"
    else
        local target="$1"
        target="${target%.cast}"
        local file_to_play=""

        if [ -f "$RECORDINGS_DIR/$target.cast" ]; then
            file_to_play="$RECORDINGS_DIR/$target.cast"
        elif [ -f "$RECORDINGS_DIR/$dev_user/$target.cast" ]; then
            file_to_play="$RECORDINGS_DIR/$dev_user/$target.cast"
        else
            local found
            found="$(find "$RECORDINGS_DIR" -type f -name "${target##*/}.cast" | head -n 1)"
            if [ -n "$found" ] && [ -f "$found" ]; then
                file_to_play="$found"
            fi
        fi

        if [ -n "$file_to_play" ]; then
            asciinema play "$file_to_play"
        else
            echo "Error: Recording '$target.cast' not found in $RECORDINGS_DIR"
            return 1
        fi
    fi
}
alias play='playrec'

# 4. Interactive Git Sync (SSH-Ready with Explicit Merge Options)
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
    echo "1) Save to MY BRANCH (commit and push work in progress)"
    echo "2) Pull latest MAIN into my branch (update branch with team work)"
    echo "3) Merge MY BRANCH into MAIN and publish (share finished work)"
    read -rp "Select [1/2/3] (default 1): " mode
    mode="${mode:-1}"

    if [ "$mode" = "2" ]; then
        echo "--> Staging local changes on $current_branch before pulling main..."
        git add .
        if ! git diff --cached --quiet; then
            read -rp "Enter commit message for local changes (default 'WIP before updating from main'): " wip_msg
            wip_msg="${wip_msg:-WIP before updating from main}"
            git commit -m "$wip_msg"
        fi

        echo "--> Fetching latest updates from origin/main..."
        git fetch origin main
        echo "--> Merging origin/main into $current_branch..."
        if git merge origin/main --no-edit; then
            echo "Successfully updated $current_branch with latest changes from MAIN."
        else
            echo "Merge conflict detected while merging main into $current_branch!"
            echo "Resolve conflicts with 'git status' and commit, or run 'git merge --abort'."
            return 1
        fi
    elif [ "$mode" = "3" ]; then
        read -rp "Enter merge commit message (default 'Merge $current_branch into main'): " msg
        msg="${msg:-Merge $current_branch into main}"

        echo "--> Staging local changes on $current_branch..."
        git add .
        if ! git diff --cached --quiet; then
            git commit -m "WIP before merging into main: $msg"
        fi

        if [ "$current_branch" = "main" ]; then
            echo "--> Already on main. Pulling and pushing updates..."
            git pull --rebase origin main
            git push origin main
            echo "Successfully synced MAIN."
        else
            echo "--> Switching to main..."
            git checkout main
            git pull origin main
            echo "--> Merging $current_branch into main..."
            if git merge "$current_branch" -m "$msg"; then
                git push origin main
                git checkout "$current_branch"
                echo "Successfully merged $current_branch into MAIN and returned to $current_branch."
            else
                echo "Merge conflict detected while merging $current_branch into main!"
                echo "Please resolve conflicts, or run 'git merge --abort' and return to $current_branch."
                return 1
            fi
        fi
    else
        read -rp "Enter commit message (default 'update'): " msg
        msg="${msg:-update}"
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
function alp() {
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

# 7. GitHub Issues Commands
issues() {
    python3 -c "
import urllib.request, json, os, re, subprocess, sys

repo_dir = sys.argv[1]
arg = sys.argv[2] if len(sys.argv) > 2 else 'open'
state = arg if arg in ['all', 'closed', 'open'] else 'open'

try:
    url = subprocess.check_output(['git', 'remote', 'get-url', 'origin'], cwd=repo_dir, text=True, stderr=subprocess.DEVNULL).strip()
    repo = re.sub(r'^(git@github\.com:|https://[^/]+//?)', '', url).removesuffix('.git')
except Exception:
    repo = 'Hein-Wagner-Academy-Cyber-Sentinel/nomvula_agri_finance'

token = ''
cred = os.path.expanduser('~/.git-credentials')
if os.path.exists(cred):
    with open(cred) as f:
        for l in f:
            m = re.search(r':(gh[pousr]_[A-Za-z0-9_]+)@', l)
            if m:
                token = m.group(1)
                break

headers = {'Accept': 'application/vnd.github.v3+json', 'User-Agent': 'NomvulaTools'}
if token:
    headers['Authorization'] = f'Bearer {token}'

req = urllib.request.Request(f'https://api.github.com/repos/{repo}/issues?state={state}', headers=headers)
try:
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode())
        issues = [i for i in data if 'pull_request' not in i]
        if not issues:
            print(f'No {state} issues found for {repo}.')
        else:
            print(f'GitHub Issues ({state.capitalize()}) for {repo}:\n')
            for i in issues:
                print(f\"  #{i['number']}: {i['title']}\")
            print('\nRun \"issue <number>\" to view details.')
except Exception as e:
    print(f'Error fetching issues: {e}')
" "$REPO_DIR" "$1"
}

issue() {
    if [ -z "$1" ]; then
        echo "Usage: issue <issue-number>  (e.g., issue 1)"
        return 1
    fi

    python3 -c "
import urllib.request, json, os, re, subprocess, sys

repo_dir = sys.argv[1]
issue_num = sys.argv[2]

try:
    url = subprocess.check_output(['git', 'remote', 'get-url', 'origin'], cwd=repo_dir, text=True, stderr=subprocess.DEVNULL).strip()
    repo = re.sub(r'^(git@github\.com:|https://[^/]+//?)', '', url).removesuffix('.git')
except Exception:
    repo = 'Hein-Wagner-Academy-Cyber-Sentinel/nomvula_agri_finance'

token = ''
cred = os.path.expanduser('~/.git-credentials')
if os.path.exists(cred):
    with open(cred) as f:
        for l in f:
            m = re.search(r':(gh[pousr]_[A-Za-z0-9_]+)@', l)
            if m:
                token = m.group(1)
                break

headers = {'Accept': 'application/vnd.github.v3+json', 'User-Agent': 'NomvulaTools'}
if token:
    headers['Authorization'] = f'Bearer {token}'

req = urllib.request.Request(f'https://api.github.com/repos/{repo}/issues/{issue_num}', headers=headers)
try:
    with urllib.request.urlopen(req) as resp:
        i = json.loads(resp.read().decode())
        print(f\"Issue #{i.get('number', '')}: {i.get('title', '')}\")
        print(f\"State: {i.get('state', '').upper()} | Author: {i.get('user', {}).get('login', 'Unknown')} | Created: {i.get('created_at', '')[:10]}\")
        print('--------------------------------------------------')
        body = i.get('body') or 'No description provided.'
        print(body)
except Exception as e:
    print(f'Error fetching issue #{issue_num}: {e}')
" "$REPO_DIR" "$1"
}

alias iss='issue'

