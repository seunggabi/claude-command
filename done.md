# Done - PR Merge and Issue Close

Merges PR and closes related issue.

## Workflow

1. **Check current branch**: Extract issue number from branch name
2. **Check PR status**: Verify PR for current branch
3. **Merge PR**: Perform squash merge
4. **Local cleanup**: Checkout main, pull, delete branch

## Execution Steps

### Step 1: Check current status

```bash
git branch --show-current
gh pr status
```

Extract issue number from branch name:

- `feat/#123_add-login` → `123`
- `fix/#124_fix-bug` → `124`

### Step 2: Check and merge PR

```bash
gh pr view --json number,state,mergeable
gh pr merge --squash --delete-branch
```

PR merge options:

- `--squash`: Squash commits into one
- `--delete-branch`: Delete remote branch after merge

### Step 3: Close issue (if not auto-closed by PR)

```bash
gh issue close {issue_number}
```

### Step 4: Local cleanup

```bash
git checkout main
git pull origin main
git branch -d {branch_name}
```

## Guidelines

1. Do not execute if there is no PR
2. Verify PR is in mergeable state (review approved, CI passed, etc.)
3. Resolve merge conflicts first if any
4. If PR body contains `Closes #123` format, issue will be auto-closed
5. Manually close issue only if auto-close didn't work
6. **All outputs and status messages must be written in the user's configured language** (check CLAUDE.md or system settings for language preference)
