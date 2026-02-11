# Sync - Rebase Current Branch with Main

Synchronizes current branch with the latest main branch using rebase.

## Workflow

1. **Stash changes**: Save uncommitted work
2. **Fetch latest**: Get latest from remote
3. **Rebase on main**: Rebase current branch onto main
4. **Restore stash**: Restore uncommitted work

## Execution Steps

### Step 1: Check current status

```bash
git branch --show-current
git status
```

### Step 2: Stash uncommitted changes (if any)

```bash
git stash push -m "sync-temp-stash"
```

### Step 3: Fetch and rebase

```bash
git fetch origin main
git rebase origin/main
```

### Step 4: Handle conflicts (if any)

If conflicts occur:

```bash
# After resolving conflicts manually
git add .
git rebase --continue
```

To abort rebase:

```bash
git rebase --abort
```

### Step 5: Restore stashed changes

```bash
git stash pop
```

### Step 6: Force push (if needed)

```bash
git push --force-with-lease
```

## Guidelines

1. Always use `--force-with-lease` instead of `--force` for safety
2. If on main branch, just pull instead of rebase
3. Resolve conflicts carefully before continuing rebase
4. Stash is only created if there are uncommitted changes
5. **All outputs and status messages must be written in English**
