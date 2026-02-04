# Troubleshooting Guide

## Common Issues

### 1. `gh: command not found`

**Symptom**: `gh: command not found` error when running commands

**Cause**: GitHub CLI is not installed

**Solution**:

```bash
# macOS
brew install gh

# Ubuntu/Debian
sudo apt install gh

# Verify installation
gh --version
```

---

### 2. `gh auth login` required

**Symptom**: `error: gh: Not logged in` or authentication-related errors

**Cause**: GitHub CLI is not authenticated

**Solution**:
```bash
# Start authentication
gh auth login

# Verify authentication status
gh auth status
```

---

### 3. Command not recognized

**Symptom**: Commands like `/commit-push-pr` are not recognized

**Cause**: Command files are not in the correct location

**Solution**:
```bash
# Check installation location
ls -la ~/.claude/commands/

# Reinstall
git clone https://github.com/seunggabi/claude-command.git /tmp/claude-command
cp -f /tmp/claude-command/*.md ~/.claude/commands/
cp -rf /tmp/claude-command/.claude/commands/* ~/.claude/commands/
rm -rf /tmp/claude-command

# Restart Claude Code
```

---

### 4. PR creation failed

**Symptom**: Error when running `gh pr create`

**Possible causes**:
- Branch not pushed to remote
- PR already exists for this branch
- Insufficient permissions

**Solution**:
```bash
# Ensure branch is pushed
git push -u origin $(git branch --show-current)

# Check for existing PR
gh pr list --head $(git branch --show-current)

# Verify permissions
gh auth status
```

---

### 5. Rebase conflicts

**Symptom**: Conflicts occur during `/sync`

**Solution**:
```bash
# Check conflicting files
git status

# After resolving conflicts
git add .
git rebase --continue

# To abort rebase
git rebase --abort
```

---

### 6. Force push failed

**Symptom**: `git push --force-with-lease` fails

**Cause**: Remote branch is ahead of local (someone else pushed)

**Solution**:
```bash
# Check remote changes
git fetch origin
git log HEAD..origin/$(git branch --show-current) --oneline

# To include remote changes
git pull --rebase origin $(git branch --show-current)
git push --force-with-lease
```

---

### 7. Branch deletion failed

**Symptom**: Branch deletion fails in `/cleanup` or `/done`

**Cause**: Branch is not fully merged

**Solution**:
```bash
# Check merge status
git branch --merged main

# Force delete (caution: may lose data)
git branch -D {branch_name}
```

---

## Debugging Tips

### Check current status
```bash
# Git status
git status
git branch -vv
git log --oneline -5

# GitHub CLI status
gh auth status
gh pr status
gh issue list --state open
```

### Check logs
Review the output messages when running commands in Claude Code.

## Additional Help

If the issue persists:
1. Open an issue at [GitHub Issues](https://github.com/seunggabi/claude-command/issues)
2. Include error messages and environment information
