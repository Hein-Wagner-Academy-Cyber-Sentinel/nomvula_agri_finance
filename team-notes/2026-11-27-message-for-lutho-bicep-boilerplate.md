# 2026-11-27 — Message for Lutho: Bicep boilerplate

**From:** Michael
**To:** Lutho

Hi Lutho,

The Bicep boilerplate is **in progress** and is now **in `main`**.

## Where it is

- `architecture/bicep/main.bicep` — entry point
- `architecture/bicep/modules/` — `keyvault.bicep`, `storage.bicep`, `vnet.bicep`
- `architecture/compiled/main.json` — compiled ARM output
- `tools/bicep_env/` — setup script and README for the Bicep environment

## Status

It is a starting point, not finished. Expect the modules and parameters to change. Please don't build on it as final yet. If you want to change any of these files, let me know first so we don't edit the same lines.

## What you need to do

```bash
git checkout main
git pull
```

Then start your own work on a new branch with `feat <task>`. The old `feature-branch` has been deleted.

— Michael
