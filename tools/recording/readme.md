# Developer Workflow and Recording Tools

This directory provides helper commands for terminal session recording, Git collaboration, issue tracking, and synchronization between Linux WSL and Windows Documents.

## Setup

To load these commands into your shell, run this once from the repository root:

```bash
bash tools/recording/install.sh
source ~/.bashrc
```

Whenever updates are made to the helpers, reload your current shell with:

```bash
source ~/.bashrc
```

---

## Available Commands

### 1. Terminal Recording (`rec` & `play`)

- `rec`: Starts an Asciinema terminal session with an automated watermark header containing your Git username, session name, and timestamp.
  - Automatically saves the recording to your dedicated portfolio directory: `evidence/<username>/`.
  - Automatically sweeps and organizes loose `.cast` files into each team member's respective folder by reading the watermark or terminal prompt signature (`user@hostname`).
  - Never misattributes files: if a recording's author cannot be confirmed, it is left untouched.
  - To stop recording, press `Ctrl+D` or type `exit`.

- `play [name]` (alias: `playrec`): Plays back a terminal recording using Asciinema.
  - Run without arguments (`play`) to list all recordings across all team members in `evidence/`.
  - Run with a filename or path (e.g., `play session1` or `play michael/session1`) to play that recording.

### 2. Git Feature Branching (`feat` & `feature`)

- `feat <name>` (alias: `feature <name>`): Creates and switches to a new feature branch prefixed with your username (e.g., `michael/my-feature`).
  - Helps comply with team Git rules: one task, one feature branch, one person.

### 3. Context-Aware Git Synchronization & Merging (`sync`)

- `sync`: Context-aware Git workflow manager with automatic SSH agent authentication.
  - **When on a Feature Branch (`michael/<task>`):**
    - **1) Save and Push**: Prompts for a commit message, stages and commits local changes, and pushes directly to `origin/$current_branch` with zero extra prompts.
    - **2) Pull Updates**: Pulls latest updates for your active branch from GitHub.
    - **3) Update with Main**: Fetches and merges latest `origin/main` into your feature branch to prevent merge conflicts early.
    - **4) Finish & Merge into Main**: Commits remaining changes, switches to `main`, pulls latest `origin/main`, merges your feature branch, pushes `main` to GitHub, and offers to safely delete the finished branch (locally and on GitHub).
    - **5) Switch to Main**: Saves your work in progress and switches back to `main`.
  - **When on `main`:**
    - **1) Start a New Feature Branch**: Prompts for task name, creates and switches to `michael/<name>`, and pushes the new branch to GitHub.
    - **2) Switch to an Existing Branch**: Numbered selector of branches on GitHub; switches your folder to the chosen branch.
    - **3) Pull Latest Main**: Pulls latest updates from `origin/main`.
    - **4) Save and Push Main**: Directly saves and pushes changes made on `main` to GitHub.
### 4. GitHub Issue Tracking (`issues` & `issue`)

- `issues`: Lists all open GitHub issues for the repository directly in the terminal.
  - Optional filters: `issues closed` or `issues all`.
- `issue <number>` (alias: `iss <number>`): Displays the full details, title, author, date, and description of a specific issue (e.g., `issue 1` or `iss 2`).

### 5. Windows and Linux Synchronization (`move` & `update`)

- `move`: Copies the entire repository from Linux WSL to `C:\Users\michael\Documents\nomvula_agri_finance`.
  - Uses mirror deletion (`--delete`) so files deleted or moved in Git are also cleaned up on Windows, preventing ghost files.
- `update`: Copies files edited in Windows Documents back into Linux WSL.
  - Preserves Linux file permissions and skips Windows metadata to keep Git status clean.
- `move-nomvula`: Alias for `move`.
- `update-nomvula`: Alias for `update`.

### 6. Python Environment (`alp`)

- `alp` (alias: `activate-alp`): Activates the Python virtual environment located at `~/alp-env`.

---

## Recommended Daily Workflow

1. Review pending issues: `issues`
2. Start a new feature branch: `feat task-description`
3. Update branch with latest team work: `sync` (Option 2)
4. Record your work session: `rec`
5. Push your progress: `sync` (Option 1)
6. Copy changes to Windows for local review: `move`
7. When work is approved and ready to merge: `sync` (Option 3)
