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

The `sync` command automatically detects whether you are sitting on `main` or on an active feature branch. You can immediately tell your current state by the number of menu options displayed:

- **4 Options Displayed (Main Mode):** No feature branch is active. You are on `main`.
- **5 Options Displayed (Branch Mode):** An isolated feature branch is active (e.g. `michael/loan-calculator`). Any changes you save and push live strictly inside this branch on GitHub, keeping `main` untouched until you choose to merge.

---

#### When No Feature Branch Is Active (4 Options on `main`)

1. **Option 1: Start a new feature branch (`feat <name>`)**
   - Prompts you for a new task or feature name (e.g. `loan-calculator`).
   - Automatically pulls the latest `main` first so you begin from fresh code.
   - Creates and switches your workspace to `michael/<name>`, then pushes the branch to GitHub immediately.
   - Once created, your active branch changes and running `sync` will present the 5-option branch menu.

2. **Option 2: Switch to an existing branch on GitHub**
   - Displays a numbered list of all branches available on GitHub.
   - Switches your workspace files to match the selected branch so you can resume work or review team tasks.
   - Safely preserves any uncommitted working edits or in-progress recording logs before switching.

3. **Option 3: Pull latest updates from GitHub main**
   - Downloads and merges the newest changes that teammates have pushed to `origin/main` into your local `main`.
   - Run this regularly to keep your base workspace fully up to date.

4. **Option 4: Save and push direct changes on main to GitHub**
   - For quick administrative fixes directly on `main` (when you do not need an isolated feature branch).
   - Prompts for a commit message, stages your edits, commits them, and pushes directly to `origin/main`.

---

#### When a Feature Branch Is Active (5 Options on `michael/<task>`)

When you see 5 options, your workspace is isolated on your feature branch. Any changes you make and push live strictly inside this branch on GitHub:

1. **Option 1: Save and Push (Work in Progress)**
   - Saves your progress as you work.
   - Prompts for a commit message (default: `'WIP on <branch>'`), stages all new and modified files, commits them, and pushes directly to your branch on GitHub (`origin/$current_branch`) with zero extra branch questions.

2. **Option 2: Pull latest updates for this branch from GitHub**
   - Pulls newer commits pushed to this specific feature branch from GitHub.
   - Use this if you or a collaborator pushed updates to this branch from another machine.

3. **Option 3: Update this branch with latest changes from main**
   - Fetches the newest commits from `origin/main` and merges them into your active feature branch.
   - Keeps your feature branch aligned with the rest of the team without overwriting your feature code, preventing surprises or massive merge conflicts later.

4. **Option 4: Finish & Merge this branch into main (Publish & Cleanup)**
   - The final step when your task is complete and approved.
   - Prompts for **one single merge message** (default: `'Merge branch <branch> into main'`).
   - Automatically commits any leftover working edits in the background.
   - Uses the **Automated Stash Safeguard** to temporarily stash active Asciinema keystroke logs so `git checkout` is never blocked.
   - Switches to `main`, pulls the latest remote `main`, merges your feature branch into `main`, and pushes the published work to GitHub.
   - Prompts you: *"Delete finished branch from local and GitHub? [Y/n]"*. Selecting Yes cleanly deletes the completed branch so GitHub remains tidy.
   - Returns your workspace to `main`.

5. **Option 5: Switch back to main (Without Merging)**
   - Use this if you need to pause work on this feature and return to `main`.
   - Automatically commits your work in progress to the feature branch and pushes it to GitHub so your progress is never lost.
   - Safely switches your workspace back to `main`.
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
