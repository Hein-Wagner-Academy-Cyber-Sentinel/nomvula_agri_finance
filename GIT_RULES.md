# Team Git & Collaboration Rules

This document outlines our team's mandatory collaboration standards. To guarantee full compliance with organizational rules and keep the repository organized, all team members use the automated workflow suite in [`tools/recording/`](tools/recording/readme.md).

---

## 4 Core Rules

1. **Never Push Directly to `main`**
   `main` is strictly reserved for stable, verified, and working code. All new work, testing, and implementation must occur inside an isolated feature branch.

2. **One Task = One Feature Branch = One Person**
   Never write code directly on another developer's active branch. Feature branches must be named with your username prefix (e.g., `michael/loan-calculator`).

3. **Separate File Ownership**
   Divide modules and functions beforehand so collaborators do not edit the exact same lines simultaneously.

4. **Pull Before Starting & Sync Often**
   Always begin your workday with the latest `main`. Use `sync` to push your isolated branch to GitHub after every working session.

---

## Tool Compliance & Automated Organization

The helper suite in [`tools/recording/helpers.sh`](tools/recording/readme.md) automatically enforces our organizational standards:

- **Branch Isolation Compliance (`feat <name>` or `sync` Option 1 on `main`)**:
  Automatically pulls the newest `main`, creates your isolated branch prefixed with your username (`<username>/<task>`), and switches your workspace so `main` remains untouched.
- **Evidence & Watermarking Compliance (`rec` & `play`)**:
  Automatically adds the required session watermark (author, session name, and timestamp) and organizes terminal recordings into dedicated folders: `evidence/<username>/`.
- **Merge & Repository Cleanliness Compliance (`sync` Option 4 on a branch)**:
  Merges your feature branch into `main`, publishes it to GitHub, and automatically prompts to delete the finished branch locally and on GitHub to prevent branch bloat.
- **Visual Status Check (4 vs. 5 Options in `sync`)**:
  - **4 Options Displayed:** You are on `main` (no active feature branch).
  - **5 Options Displayed:** You are on an active feature branch. All changes you make and push are isolated to GitHub without touching `main`.

---

## 3 Daily Alignment Questions

Before starting or merging, communicate with your team:
1. *"Which files or functions are you modifying today?"*
2. *"Are you ready for me to merge my feature branch into main?"*
3. *"Can we review this work together before publishing?"*

---

## Standard Daily Workflow

To load the tools into your shell, run `source ~/.bashrc` (or `source tools/recording/helpers.sh`).

1. **Start a New Task:**
   ```bash
   feat loan-calculator
   ```
   *(Or run `sync` while on `main` and choose Option 1).*

2. **Record Your Session (Evidence):**
   ```bash
   rec
   ```
   *(Press `Ctrl+D` or type `exit` when done recording).*

3. **Save & Push In-Progress Work:**
   ```bash
   sync
   ```
   *(While on your feature branch, choose Option 1 to push directly to GitHub).*

4. **Finish, Merge, and Clean Up:**
   ```bash
   sync
   ```
   *(Choose Option 4 to merge into `main`, publish to GitHub, and delete the finished branch).*

---

For complete details on all recording, synchronization, and issue commands, see the [Recording & Workflow Readme](tools/recording/readme.md).
