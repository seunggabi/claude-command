# Commit, Push, and Create PR

Automatically creates issue, branch, commit, push, and PR.

## Workflow

1. **Check current branch**: Verify if on main branch
2. **Analyze changes**: Review git diff to understand changes
3. **Create issue**: Register GitHub issue (if on main branch)
4. **Create branch**: `{type}/#{issue_number}_{alias}` format
5. **Commit**: `(#{issue_number}) {type}: {description}` format
6. **Push & Create PR**

## Execution Steps

### Step 1: Check current status
```bash
git status
git branch --show-current
git diff --staged --stat
git diff --stat
```

### Step 2: Analyze changes and determine type
Analyze changes and select appropriate type:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring (no feature change)
- `chore`: Maintenance, config changes, dependency updates

### Step 3: Create issue (if on main branch)
```bash
gh issue create --title "{issue title}" --body "{changes summary}"
```

### Step 4: Create branch
```bash
git checkout -b {type}/#{issue_number}_{alias}
```

Branch naming convention:
- `feat/#123_add-login`
- `fix/#124_fix-auth-bug`
- `refactor/#125_cleanup-code`
- `chore/#126_update-deps`

### Step 5: Commit
```bash
git add -A
git commit -m "(#{issue_number}) {type}: {description}"
```

Commit message format:
- `(#123) feat: add login feature`
- `(#124) fix: fix authentication bug`
- `(#125) refactor: cleanup code`

### Step 6: Push and create PR
```bash
git push -u origin {branch_name}
gh pr create --title "(#{issue_number}) {type}: {PR title}" --body "Closes #{issue_number}

## Changes
{changes summary}
"
```

PR title format:
- `(#123) feat: add login feature`
- `(#124) fix: fix authentication bug`

## Guidelines

1. Do not execute if there are no changes
2. Keep issue and PR titles concise
3. Alias should be a short English identifier for changes (kebab-case)
4. If not on main branch, skip issue creation and proceed with commit/push/PR on current branch
