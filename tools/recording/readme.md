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

### 3. Interactive Git Synchronization & Merging (`sync`)

- `sync`: Interactive Git workflow manager with automatic SSH agent authentication.
  - **Option 1 (Save to My Branch)**: Stages, commits, and pushes your work in progress to your remote feature branch.
  - **Option 2 (Pull/Merge into My Branch)**: Fetches remote branches, displays all available branches, and allows merging either `main` (default) or any teammate's branch of your choice into your active feature branch.
  - **Option 3 (Merge Branch into Main & Publish)**: Fetches remote branches, displays all available branches, and allows merging your active branch (default) or any chosen branch into `main`, publishing the result to GitHub.

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
