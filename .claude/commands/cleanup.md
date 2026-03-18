# Cleanup - Remove Merged Branches

Removes merged local and remote branches to keep the repository clean.

## Workflow

1. **Fetch and prune**: Update remote references
2. **List merged branches**: Identify branches merged to main
3. **Delete local branches**: Remove merged local branches
4. **Delete remote branches**: Remove merged remote branches (optional)

## Execution Steps

### Step 1: Switch to main and update

```bash
git checkout main
git pull origin main
```

### Step 2: Fetch and prune remote

```bash
git fetch --prune
```

### Step 3: List merged branches

```bash
# Local merged branches (excluding main)
git branch --merged main | grep -v "main\|master\|\*"

# Remote merged branches
git branch -r --merged main | grep -v "main\|master\|HEAD"
```

### Step 4: Delete local merged branches

```bash
git branch --merged main | grep -v "main\|master\|\*" | xargs -r git branch -d
```

### Step 5: Delete remote merged branches (optional, confirm first)

```bash
# List remote branches to delete
git branch -r --merged main | grep -v "main\|master\|HEAD" | sed 's/origin\///'

# Delete each remote branch
git push origin --delete {branch_name}
```

### Step 6: Verify cleanup

```bash
git branch -a
```

## Handling [gone] Branches

Branches where the remote was deleted but local still exists won't appear in `--merged`. Clean them separately:

```bash
# List [gone] branches
git branch -vv | grep '\[gone\]'

# Delete all [gone] branches
git branch -vv | grep '\[gone\]' | awk '{print $1}' | xargs -r git branch -d
```

Or use `commit-commands:clean_gone` skill which handles this automatically (including worktree cleanup).

## Guidelines

1. Always confirm before deleting remote branches
2. Never delete main/master branches
3. Run `git fetch --prune` first to sync remote state
4. Use `-d` (safe delete) not `-D` (force delete) for local branches
5. Protected branches on GitHub won't be deleted remotely
6. **All outputs and confirmations must be written in English**
