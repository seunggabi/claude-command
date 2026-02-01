# Status - Project Status Overview

Shows comprehensive project status including git, issues, and PRs.

## Workflow

1. **Git status**: Current branch, changes, commits
2. **Open issues**: List open GitHub issues
3. **Open PRs**: List open pull requests
4. **Recent activity**: Recent commits and merges

## Execution Steps

### Step 1: Git status
```bash
echo "=== Git Status ==="
git branch --show-current
git status --short
git log --oneline -5
```

### Step 2: Unpushed commits
```bash
echo "=== Unpushed Commits ==="
git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null || echo "No upstream branch"
```

### Step 3: Open issues
```bash
echo "=== Open Issues ==="
gh issue list --state open --limit 10
```

### Step 4: Open PRs
```bash
echo "=== Open Pull Requests ==="
gh pr list --state open --limit 10
```

### Step 5: My PRs and issues
```bash
echo "=== My Open PRs ==="
gh pr list --author @me --state open

echo "=== Issues Assigned to Me ==="
gh issue list --assignee @me --state open
```

### Step 6: Recent merges
```bash
echo "=== Recent Merges to Main ==="
git log main --oneline --merges -5
```

## Output Format

Display results in a clean, organized format:
- Current branch and status
- Pending changes count
- Open issues count with titles
- Open PRs count with titles
- Any blocked/stale items

## Guidelines

1. Show summary counts first, then details
2. Highlight items that need attention
3. Show age of issues/PRs if stale (>7 days)
4. Indicate CI status for open PRs
