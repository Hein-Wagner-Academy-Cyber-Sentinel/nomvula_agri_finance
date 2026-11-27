# 2026-11-27 — Bicep work merged into main

**From:** Michael

## What happened

- A Linux → Windows sync (`move`) ran while `main` was checked out. `main` did not contain the Bicep work yet, so the Windows copy lost those files.
- Nothing was lost from git: the files were all on `feature-branch`.

## What was done

- `feature-branch` was merged into `main` (bicep modules, `tools/bicep_env/`, background-research tests, bicep evidence casts, sync helper updates).
- `main` was pushed to GitHub and `feature-branch` was deleted locally and on GitHub.
- New `team-notes/` folder created for messages and notes like this one.
- Root `README.md` updated to list `tools/` and `team-notes/`.

## For Lutho

- Pull the latest `main` before starting: `git checkout main && git pull`.
- Start new work on a fresh branch with `feat <task>`. `feature-branch` no longer exists.
- Evidence for this session: `evidence/michael/merge bicep into main and add team notes.cast`.
