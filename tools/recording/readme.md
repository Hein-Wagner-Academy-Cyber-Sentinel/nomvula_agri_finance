# Team Developer Workflow & Recording Setup

This directory contains shared helper functions to automate terminal recordings using asciinema and streamline Git syncing.

---

## 📧 One-Time Setup Instructions

Follow these two steps in your WSL terminal:

### 1. Install Required Packages
sudo apt update && sudo apt install -y asciinema git

### 2. Enable the Helper Commands
From the repo root directory (`nomvula_agri_finance`), run:
echo "source \$(pwd)/tools/recording/helpers.sh" >> ~/.bashrc
source ~/.bashrc

---

## 🙩 Available Commands

### `rec` — Start a Recording
* Prompts for a session name.
* Automatically caps idle pauses to 1.5 seconds (ai cleanup).
* Saves all recordings to `nomvula_agri_finance/asciinema_recordings/`.
* Press `Ctrl+D` or type `exit` to stop recording.

### `playrec [name]` “ Play Back Recordings
* Run `playrec` without arguments to list all saved recordings.
* Run `playrec <name>`! to play back a specific session.

### `sync [message]` “ Git Sync (Pull, Add, Commit, Push)
* Runs `git pull`, `git add .`, `git commit -m "message"`, and `git push` in one shot.
* Usage: `sync "fixed database connection"` (defaults to `"update"` if left blank).

---

## ◿ Editing Mistakes in Recordings

Recordings are plain text JSON files. If you make a typo or want to remove sensitive text:
1. Open the file: `nano asciinema_recordings/<name>.cast`
2. Delete the unwanted lines.
3. Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).
