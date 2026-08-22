# Team Developer Workflow & Recording Setup

This directory contains shared helper functions to automate terminal recordings using asciinema, insert developer watermarks, and streamline Git syncing.

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

### `rec` — Start a Recording (with Auto-Watermark)
* Prompts for a session name.
* Automatically inserts a watermark banner with your Git/WSL username, session title, and date at the start of the recording.
* Caps idle pauses to 1.5 seconds to keep videos fast and clean.
* Saves files to `nomvula_agri_finance/asciinema_recordings/`.
* Press `Ctrl+D` or type `exit` to stop recording.

### `playrec [name]` �p Play Back Recordings
* Run `playrec` without arguments to list all saved recordings.
* Run `playrec <name>`! to play back a specific session (including its watermark).

3## `sync [message]` “ Git Sync (Pull, Add, Commit, Push)
* Runs `git pull`, `git add .`, `git commit -m "message"`, and `git push` directly from any folder.
* Usage: `sync "fixed database connection"` (defaults to `"update"` if left blank).

---

## ◿ Editing Mistakes in Recordings

Recordings are plain text JSON files. If you make a typo or want to remove sensitive text:
1. Open the file: `nano asciinema_recordings/<name>.cast`
2. Delete the unwanted lines (keep the first watermark lines intact).
3. Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).
