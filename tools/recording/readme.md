# Developer Workflow and Recording Tools

This directory provides helper commands for Git branching, terminal session recording, and synchronization between WSL and Windows Documents.

## One-Time Setup

To activate these commands in your shell, run this command from the repository root:

```bash
bash tools/recording/install.sh
```

Then restart your terminal or run:

```bash
source ~/.bashrc
```

## Available Commands

### Git Branching
- feature <name>: Creates and switches to a new feature branch named your-username/name.
- feat <name>: Shorter shortcut for feature.

### Terminal Recording
- rec: Starts an asciinema terminal recording with an automated watermark header containing your username, session name, and date. Recordings are automatically saved into your personal folder (`asciinema_recordings/<username>/`). To stop recording, press Ctrl+D or type exit.
- playrec [name]: Plays back a recording from your user folder or repository, or lists all available recordings grouped by user if no name is given.
- play [name]: Shorter shortcut for playrec.

### Git Syncing
- sync: Starts an interactive Git synchronization with automated SSH authentication.
  - Option 1 saves and pushes your work in progress to your private branch.
  - Option 2 pulls and merges the latest team changes from main into your branch.
  - Option 3 merges your completed branch into main and publishes to GitHub.

### Environment Activation
- alp: Activates the Python virtual environment in ~/alp-env.
- activate-alp: Alternative alias for alp.

### Windows and Linux Synchronization
- move: Copies the repository from Linux WSL to Windows Documents. It uses delete mirroring so that any files deleted or moved in Git are also cleaned up from Windows, preventing ghost files.
- update: Copies files edited on Windows back into Linux WSL without altering Linux file permissions or dirtying Git tracking.
- move-nomvula: Alias for move.
- update-nomvula: Alias for update.

### GitHub Issues
- issues: Lists all open GitHub issues for the repository directly in your terminal. You can also run issues closed or issues all.
- issue <number>: Displays the full details, author, date, and description for a specific issue (e.g., issue 1).
- iss <number>: Shorter shortcut for issue.

## Recommended Workflow

1. Check assigned issues: issues
2. Start a task branch: feat my-task
3. Record your session: rec
4. Sync to GitHub: sync
5. Sync to Windows for review: move
6. Retrieve Windows edits: update

