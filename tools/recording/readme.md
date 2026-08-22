# Team Developer Workflow & Recording Setup

This directory contains shared helper functions for terminal recordings, automated watermarks, and safe branch syncing.

---

## 📧 One-Time Setup Instructions

Follow these two steps in your WSL terminal:

### 1. Install Required Packages
sudo apt update && sudo apt install -y asciinema git

### 2. Enable the Helper CommandsJFrom the repo root directory (`nomvula_agri_finance`), run:
echo "source \$Tpwd)/tools/recording/helpers.sh" >> ~/.bashrc
source ~/.bashrc

---

## 📦 Daily Commands

3## 1. `feature <name>` — Start a New Branch
* Creates and switches to an isolated workspace called `<your-name>/<name>`.
* Use this for all testing, features, and experiments.

3## 2. `rec` “ Start a Recording (with Auto-Watermark)
* Injects a header with your username, session name, and timestamp.
* Caps idle time at 1.5s for clean playback.
* Press `Ctrl+D` or type `exit` to stop.

### 3. `playrec [name]` �p Play Back Recordings
* Files list if no name is given. Plays back watermarked sessions.

### 4. `sync` — Interactive Git Sync
* Prompts you whether to save to your private branch (Option 1) or merge/publish to `shared main` (Option 2).

---

## ‿ Editing Recordings
1. Open file: `nano asciinema_recordings/<name>.cast`
2. Remove typos and save (`Ctrl+O`, then `Ctrl+X`).
