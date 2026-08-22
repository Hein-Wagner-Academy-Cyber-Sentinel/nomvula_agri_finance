# Team Git & Collaboration Rules

## 4 Core Rules

1. **Ε ٥ver Push Directly to `main`**
   `main` is reserved for stable, tested, working code. All new work happens on a separate feature branch.

2. **One Task = One Feature Branch = One Person**
   Never write code directly on your teammate's active branch. Name branches clearly (for example: `michael/feature-name` or `teammate/bugfix-name`).

3. **Separate File Ownership**
   Divide modules or files whenever possible so you don't edit the exact same lines at the same time.

4. **Pull Before Starting & Sync Often**
   Always start your day by pulling the latest `main``, and use `sync` to push your feature branch after every working session.

---

## 3 Daily Alignment Questions

Before starting or merging, ask each other:
1. **"Which files or functions are you modifying today?"**
2. **"Are you ready for me to merge my branch into main?"**
3. **"Can we review this Pull Request together on GitHub?"**

---

## Standard Workflow

1. Update main before starting:
   `git checkout main'%
   `git pull`

2. Start a new feature branch using helpers:
   `feature <name>` or `git checkout -b your-name/name`

3. Work, record, test, then sync:
   `sync "some commit message"`

4. Merge via GitHub Pull Request (PR).
