#!/usr/bin/env bash

# Resolve repo root dynamically (2 levels up from tools/recording/)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RECORDINGS_DIR="$REPO_DIR/evidence"

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

# Helper: Safely organize loose .cast files into evidence/<author>/ based on watermark or shell prompt
_organize_recordings() {
    python3 -c "
import os, re, glob, shutil

repo_dir = '$REPO_DIR'
evidence_dir = os.path.join(repo_dir, 'evidence')
os.makedirs(evidence_dir, exist_ok=True)

def detect_cast_author(filepath):
    try:
        with open(filepath, 'r', errors='ignore') as f:
            for _ in range(40):
                line = f.readline()
                if not line:
                    break
                # Check for watermark: Assignee: <name>
                m = re.search(r'Assignee:\s*([A-Za-z0-9_-]+)', line, re.IGNORECASE)
                if m:
                    return m.group(1).lower()
                # Check for shell prompt: <username>@<hostname>
                m = re.search(r'([a-zA-Z0-9_-]+)@[A-Za-z0-9_-]+', line)
                if m:
                    uname = m.group(1).lower()
                    if uname not in ['root', 'daemon', 'nobody']:
                        return uname
    except Exception:
        pass
    return None

candidates = []
for f in glob.glob(os.path.join(repo_dir, '*.cast')):
    candidates.append(f)

rec_dir = os.path.join(repo_dir, 'asciinema_recordings')
if os.path.isdir(rec_dir):
    for root, _, files in os.walk(rec_dir):
        for f in files:
            if f.endswith('.cast'):
                candidates.append(os.path.join(root, f))

for filepath in candidates:
    author = detect_cast_author(filepath)
    if author:
        dest_dir = os.path.join(evidence_dir, author)
        os.makedirs(dest_dir, exist_ok=True)
        dest_file = os.path.join(dest_dir, os.path.basename(filepath))
        if os.path.abspath(filepath) != os.path.abspath(dest_file):
            shutil.move(filepath, dest_file)
            print(f'Organized: {os.path.basename(filepath)} -> evidence/{author}/')
    else:
        # Prevent misattribution: do not move files without verified author
        pass

if os.path.isdir(rec_dir):
    for root, dirs, _ in os.walk(rec_dir, topdown=False):
        for d in dirs:
            dirpath = os.path.join(root, d)
            if not os.listdir(dirpath):
                try: os.rmdir(dirpath)
                except Exception: pass
" 2>/dev/null
}

# 1. Feature Branch Command
feature() {
    cd "$REPO_DIR" || return 1
    _ensure_ssh_agent
    
    local dev_user
    dev_user="$(git -C "$REPO_DIR" config user.name 2>/dev/null || echo "$USER")"
    dev_user="$(echo "$dev_user" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
    
    local task_name="$1"
    if [ -z "$task_name" ]; then
        read -rp "Enter new task/feature name (e.g. loan-calc): " task_name
    fi
    task_name="$(echo "$task_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
    if [ -z "$task_name" ]; then
        echo "Error: Task name cannot be empty."
        return 1
    fi
    
    local branch_name="$task_name"
    if [[ "$task_name" != *"$dev_user/"* ]]; then
        branch_name="${dev_user}/$task_name"
    fi

    # Ensure local main is up to date before branching
    local cur_b
    cur_b="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    if [ "$cur_b" = "main" ]; then
        echo "Updating main before creating new branch..."
        git pull origin main >/dev/null 2>&1
    fi

    if git checkout -b "$branch_name"; then
        echo -e "\033[1;32mSwitched to new feature branch: $branch_name\033[0m"
        echo "Pushing new branch to GitHub..."
        git push -u origin "$branch_name" 2>/dev/null || true
        echo "Ready to work! Run 'sync' anytime to save and push your progress."
    else
        echo "Error: Could not create branch $branch_name."
        return 1
    fi
}
alias feat='feature'

# 2. Recording Command (with Auto-Organization & Watermark)
rec() {
    _organize_recordings

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

# Helper: Resolve branch to a valid git ref (origin/branch or local branch)
_resolve_branch_ref() {
    local b="$1"
    b="${b#origin/}"
    if git rev-parse --verify --quiet "refs/remotes/origin/$b" >/dev/null 2>&1; then
        echo "origin/$b"
    elif git rev-parse --verify --quiet "refs/heads/$b" >/dev/null 2>&1; then
        echo "$b"
    elif git ls-remote --exit-code --heads origin "$b" >/dev/null 2>&1; then
        echo "origin/$b"
    else
        echo ""
    fi
}

# Helper: Interactive numbered branch selector
_select_branch() {
    local default_branch="$1"
    local prompt_text="$2"
    local exclude_branch="$3"
    local allow_custom="$4"
    SELECTED_BRANCH=""

    echo "Fetching latest remote branches from GitHub..."
    git fetch origin >/dev/null 2>&1

    local raw_branches=()
    # 1. Collect remote tracking branches from origin (excluding HEAD)
    while IFS= read -r b; do
        b="${b#origin/}"
        b="$(echo "$b" | tr -d '[:space:]')"
        [ -n "$b" ] && raw_branches+=("$b")
    done < <(git branch -r 2>/dev/null | grep -v 'HEAD' | sed 's/^[[:space:]]*//')

    # 2. Collect local branches
    while IFS= read -r b; do
        b="${b#\* }"
        b="$(echo "$b" | tr -d '[:space:]')"
        [ -n "$b" ] && raw_branches+=("$b")
    done < <(git branch 2>/dev/null)

    local branches=()
    while IFS= read -r b; do
        [ -n "$b" ] && [ "$b" != "$exclude_branch" ] && branches+=("$b")
    done < <(printf "%s\n" "${raw_branches[@]}" | sort -u)

    if [ "${#branches[@]}" -eq 0 ]; then
        if [ -n "$default_branch" ]; then
            SELECTED_BRANCH="$default_branch"
            return 0
        elif [ "$allow_custom" = "true" ]; then
            read -rp "Enter branch name: " custom_choice
            SELECTED_BRANCH="$(echo "$custom_choice" | tr -d '[:space:]')"
            return 0
        else
            echo "Error: No branches found on GitHub."
            return 1
        fi
    fi

    echo ""
    echo "Available branches on GitHub:"
    for i in "${!branches[@]}"; do
        local num=$((i + 1))
        if [ -n "$default_branch" ] && [ "${branches[i]}" = "$default_branch" ]; then
            echo "  $num) ${branches[i]} (default)"
        else
            echo "  $num) ${branches[i]}"
        fi
    done

    local prompt_label="$prompt_text [1-${#branches[@]}]"
    if [ -n "$default_branch" ]; then
        prompt_label="$prompt_label (default '$default_branch'): "
    else
        prompt_label="$prompt_label: "
    fi

    while true; do
        echo ""
        local choice=""
        read -rp "$prompt_label" choice
        choice="$(echo "$choice" | tr -d '[:space:]')"

        if [ -z "$choice" ]; then
            if [ -n "$default_branch" ]; then
                SELECTED_BRANCH="$default_branch"
                break
            else
                echo "Please select a number between 1 and ${#branches[@]}."
                continue
            fi
        fi

        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [ "$choice" -ge 1 ] && [ "$choice" -le "${#branches[@]}" ]; then
                SELECTED_BRANCH="${branches[choice-1]}"
                break
            else
                echo "Invalid selection: $choice. Please enter a number between 1 and ${#branches[@]}."
                continue
            fi
        fi

        if [ "$allow_custom" = "true" ]; then
            local clean_choice="${choice#origin/}"
            echo "Using branch name: $clean_choice"
            SELECTED_BRANCH="$clean_choice"
            break
        else
            local clean_choice="${choice#origin/}"
            local matched=""
            for b in "${branches[@]}"; do
                if [ "$b" = "$clean_choice" ]; then
                    matched="$b"
                    break
                fi
            done
            if [ -n "$matched" ]; then
                SELECTED_BRANCH="$matched"
                break
            else
                echo "Branch '$clean_choice' not found. Please enter a number between 1 and ${#branches[@]}."
            fi
        fi
    done
}

# 4. Context-Aware Git Sync (SSH-Ready)
sync() {
    cd "$REPO_DIR" || { echo "Error: Cannot enter repo $REPO_DIR"; return 1; }
    
    _ensure_ssh_agent
    _organize_recordings

    local current_branch
    current_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    if [ -z "$current_branch" ]; then
        echo "Error: Not a valid git repository or detached HEAD."
        return 1
    fi

    echo ""
    echo -e "\033[1;32mCurrent Active Branch: $current_branch\033[0m"

    if [ "$current_branch" != "main" ]; then
        # =========================================================================
        # FEATURE BRANCH WORKFLOW (Work is isolated on this branch)
        # =========================================================================
        echo "Feature Branch Options:"
        echo "1) Save and Push (commit & push work in progress to this branch)"
        echo "2) Pull latest updates for this branch from GitHub"
        echo "3) Update this branch with latest changes from main"
        echo "4) Finish & Merge this branch into main (publish and clean up)"
        echo "5) Switch back to main (save uncommitted work first)"
        read -rp "Select [1-5] (default 1): " mode
        mode="${mode:-1}"

        if [ "$mode" = "1" ]; then
            read -rp "Enter commit message (default 'WIP on $current_branch'): " msg
            msg="${msg:-WIP on $current_branch}"

            git add .
            if ! git diff --cached --quiet; then
                git commit -m "$msg"
            else
                echo "No local changes to commit."
            fi

            echo "--> Pushing to GitHub branch origin/$current_branch..."
            if git push -u origin "$current_branch"; then
                echo "Successfully pushed to origin/$current_branch."
            else
                echo "Error: Failed to push to origin/$current_branch."
                echo "If there are remote changes, try pulling first (Option 2)."
                return 1
            fi

        elif [ "$mode" = "2" ]; then
            echo "--> Pulling latest updates from origin/$current_branch..."
            if git pull origin "$current_branch"; then
                echo "Successfully pulled from origin/$current_branch."
            else
                echo "Error: Pull did not complete cleanly."
                return 1
            fi

        elif [ "$mode" = "3" ]; then
            echo "--> Updating $current_branch with latest changes from origin/main..."
            git fetch origin main >/dev/null 2>&1
            if git merge origin/main -m "Merge branch 'main' into $current_branch"; then
                echo "Successfully updated $current_branch with latest main."
                echo "--> Pushing updated branch to GitHub..."
                git push origin "$current_branch" 2>/dev/null || true
            else
                echo "Merge conflict detected while pulling from main!"
                echo "Resolve conflicts with 'git status', or run 'git merge --abort' to cancel."
                return 1
            fi

        elif [ "$mode" = "4" ]; then
            echo "--> Preparing to merge $current_branch into main..."

            # Exactly ONE merge message prompt
            read -rp "Enter merge message (default 'Merge branch $current_branch into main'): " msg
            msg="${msg:-Merge branch $current_branch into main}"

            # Auto-commit any remaining working changes or active recording logs
            git add .
            if ! git diff --cached --quiet; then
                git commit -m "Finalize $current_branch before merge" --quiet
                echo "--> Pushed final changes to origin/$current_branch."
                git push origin "$current_branch" >/dev/null 2>&1 || true
            fi

            # Automated Stash Safeguard: Stash any trailing keystrokes or background logs
            local has_stash="false"
            if ! git diff --quiet || ! git diff --cached --quiet; then
                git stash push -u -m "temp_sync_recording_stash" >/dev/null 2>&1
                has_stash="true"
            fi

            echo "--> Switching to main..."
            if ! git checkout main 2>/dev/null && ! git checkout -m main 2>/dev/null; then
                echo "Error: Could not switch to main."
                [ "$has_stash" = "true" ] && git stash pop >/dev/null 2>&1 || true
                return 1
            fi

            echo "--> Pulling latest main from GitHub..."
            if ! git pull origin main; then
                echo "Error: Could not pull latest main."
                git checkout "$current_branch" 2>/dev/null || true
                [ "$has_stash" = "true" ] && git stash pop >/dev/null 2>&1 || true
                return 1
            fi

            echo "--> Merging $current_branch into main..."
            if git merge "$current_branch" -m "$msg"; then
                echo "--> Pushing merged main to GitHub..."
                if git push origin main; then
                    echo -e "\033[1;32mSuccessfully merged $current_branch into main and published to GitHub!\033[0m"

                    # Restore in-flight recording logs onto main
                    if [ "$has_stash" = "true" ]; then
                        git stash pop >/dev/null 2>&1 || true
                        git add .
                        if ! git diff --cached --quiet; then
                            git commit -m "Update session recording" >/dev/null 2>&1 || true
                            git push origin main >/dev/null 2>&1 || true
                        fi
                    fi

                    # Prompt for branch cleanup
                    echo ""
                    read -rp "Delete finished branch '$current_branch' from local and GitHub? [Y/n]: " del_choice
                    del_choice="${del_choice:-Y}"
                    if [[ "$del_choice" =~ ^[Yy]$ ]]; then
                        echo "Cleaning up local branch $current_branch..."
                        git branch -d "$current_branch" 2>/dev/null || git branch -D "$current_branch" 2>/dev/null
                        echo "Cleaning up remote branch on GitHub..."
                        git push origin --delete "$current_branch" 2>/dev/null || true
                        echo "Branch $current_branch has been cleaned up. You are now on main."
                    else
                        echo "Branch $current_branch kept. You are now on main."
                    fi
                else
                    echo "Error: Merged locally, but failed to push to GitHub main."
                    [ "$has_stash" = "true" ] && git stash pop >/dev/null 2>&1 || true
                    return 1
                fi
            else
                echo "Merge conflict detected while merging $current_branch into main!"
                echo "Resolve conflicts with 'git status', or run 'git merge --abort' to cancel."
                git checkout "$current_branch" 2>/dev/null || true
                [ "$has_stash" = "true" ] && git stash pop >/dev/null 2>&1 || true
                return 1
            fi

        elif [ "$mode" = "5" ]; then
            git add .
            if ! git diff --cached --quiet; then
                git commit -m "WIP on $current_branch before switching to main" --quiet
                git push origin "$current_branch" >/dev/null 2>&1 || true
            fi
            local has_stash="false"
            if ! git diff --quiet || ! git diff --cached --quiet; then
                git stash push -u -m "temp_sync_switch_stash" >/dev/null 2>&1
                has_stash="true"
            fi
            echo "--> Switching to main..."
            if git checkout main 2>/dev/null || git checkout -m main 2>/dev/null; then
                [ "$has_stash" = "true" ] && git stash pop >/dev/null 2>&1 || true
                echo "Switched to main. Your work on $current_branch is saved."
            else
                echo "Error: Could not switch to main."
                [ "$has_stash" = "true" ] && git stash pop >/dev/null 2>&1 || true
                return 1
            fi
        fi

    else
        # =========================================================================
        # MAIN BRANCH WORKFLOW
        # =========================================================================
        echo "Main Branch Options:"
        echo "1) Start a new feature branch (feat <name>)"
        echo "2) Switch to an existing branch on GitHub"
        echo "3) Pull latest updates from GitHub main"
        echo "4) Save and push direct changes on main to GitHub"
        read -rp "Select [1-4] (default 1): " mode
        mode="${mode:-1}"

        if [ "$mode" = "1" ]; then
            read -rp "Enter new task/feature name (e.g. loan-calc): " feat_name
            if [ -n "$feat_name" ]; then
                feature "$feat_name"
            else
                echo "Task name cannot be empty."
                return 1
            fi

        elif [ "$mode" = "2" ]; then
            _select_branch "" "Select branch to switch to" "main" "false"
            local target_branch="$SELECTED_BRANCH"
            if [ -z "$target_branch" ]; then
                echo "No branch selected."
                return 1
            fi

            git add .
            if ! git diff --cached --quiet; then
                git commit -m "WIP on main before switching" --quiet
            fi

            local has_stash="false"
            if ! git diff --quiet || ! git diff --cached --quiet; then
                git stash push -u -m "temp_sync_switch_stash" >/dev/null 2>&1
                has_stash="true"
            fi

            echo "--> Switching to branch '$target_branch'..."
            if git checkout "$target_branch" 2>/dev/null; then
                echo "Switched to local branch '$target_branch'."
                [ "$has_stash" = "true" ] && git stash pop >/dev/null 2>&1 || true
            elif git checkout -b "$target_branch" "origin/$target_branch" 2>/dev/null; then
                echo "Checked out remote branch '$target_branch' locally."
                [ "$has_stash" = "true" ] && git stash pop >/dev/null 2>&1 || true
            elif git checkout -m "$target_branch" 2>/dev/null; then
                echo "Switched to branch '$target_branch'."
                [ "$has_stash" = "true" ] && git stash pop >/dev/null 2>&1 || true
            else
                echo "Error: Could not switch to branch '$target_branch'."
                [ "$has_stash" = "true" ] && git stash pop >/dev/null 2>&1 || true
                return 1
            fi
        elif [ "$mode" = "3" ]; then
            echo "--> Pulling latest updates from origin/main..."
            if git pull origin main; then
                echo "Successfully pulled latest main."
            else
                echo "Error: Pull did not complete cleanly."
                return 1
            fi

        elif [ "$mode" = "4" ]; then
            read -rp "Enter commit message for main (default 'update main'): " msg
            msg="${msg:-update main}"

            git add .
            if ! git diff --cached --quiet; then
                git commit -m "$msg"
            else
                echo "No local changes to commit."
            fi

            echo "--> Pushing to origin/main..."
            if git push origin main; then
                echo "Successfully pushed to origin/main."
            else
                echo "Error: Failed to push to origin/main."
                return 1
            fi
        fi
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
    local win_dest="/mnt/c/Users/michael/Documents/nomvula_agri_finance"

    mkdir -p "$win_dest"
    echo "Syncing repository from Linux to Windows Documents..."
    if [ -d "$src_repo" ]; then
        # Uses --delete so files deleted or moved in Git are purged from Windows, preventing ghost file resurrection
        rsync -rtv --delete --exclude=".git" "$src_repo/" "$win_dest/"
    fi
    echo "Done. Windows Documents now matches your Linux workspace."
}

update() {
    local win_src="/mnt/c/Users/michael/Documents/nomvula_agri_finance"
    local dest_repo="$REPO_DIR"

    if [ ! -d "$win_src" ]; then
        echo "Error: Windows Documents folder not found at $win_src"
        return 1
    fi

    echo "Retrieving changes from Windows Documents to Linux..."
    if [ -d "$dest_repo" ]; then
        # Preserves Linux permissions and ignores Windows metadata to prevent dirty Git index
        rsync -rtv --update --no-perms --no-owner --no-group --exclude=".git" "$win_src/" "$dest_repo/"
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

