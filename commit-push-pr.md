# Commit, Push, and Create PR

Automatically creates issue, branch, commit, push, and PR.

## Conventions Reference

### Semantic Commit Types
| Type | Description |
|------|-------------|
| `feat` | New feature for users |
| `fix` | Bug fix for users |
| `docs` | Documentation changes |
| `style` | Formatting (no code change) |
| `refactor` | Code restructuring (no feature/fix) |
| `test` | Adding/modifying tests |
| `chore` | Maintenance, dependencies |
| `build` | Build system changes |
| `ci` | CI configuration changes |
| `perf` | Performance improvements |

### Branch Naming Format
```
{type}/#{issue_number}_{alias}
```
- Type: `feat`, `fix`, `refactor`, `chore`, etc.
- Issue number: GitHub issue number with `#` prefix
- Alias: Short kebab-case identifier (use `-` internally)
- Separator: `_` between issue number and alias

### Commit Message Format
```
(#{issue_number}) {type}: {description}
```

### PR Title Format
```
(#{issue_number}) {type}: {description}
```

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
Analyze changes and select appropriate type from the table above.

### Step 3: Create issue (if on main branch)
```bash
gh issue create --title "{issue title}" --body "{changes summary}"
```

### Step 4: Create branch
```bash
git checkout -b {type}/#{issue_number}_{alias}
```

Examples:
- `feat/#123_add-login`
- `fix/#124_fix-auth-bug`
- `refactor/#125_cleanup-code`
- `chore/#126_update-deps`

### Step 5: Commit
```bash
git add -A
git commit -m "(#{issue_number}) {type}: {description}"
```

Examples:
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

## Guidelines

1. Do not execute if there are no changes
2. Keep issue and PR titles concise
3. Alias should be a short English kebab-case identifier
4. If not on main branch, skip issue creation and proceed with commit/push/PR on current branch
5. Use present tense for commit messages ("add" not "added")

## References
- [Semantic Commit Messages](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716)
- [Branch Naming Convention](https://gist.github.com/seunggabi/87f8c722d35cd07deb3f649d45a31082)

> **Last Updated**: 2025-02-01 - Conventions embedded from referenced gists
