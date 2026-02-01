# Claude Commands

Custom commands for Claude Code CLI.

## Installation

### Global Installation (Available in all projects)

```bash
# Clone and install globally
git clone https://github.com/seunggabi/claude-command.git
cd claude-command
mkdir -p ~/.claude/commands
cp *.md ~/.claude/commands/
```

**One-liner:**
```bash
git clone https://github.com/seunggabi/claude-command.git /tmp/claude-command && mkdir -p ~/.claude/commands && cp /tmp/claude-command/*.md ~/.claude/commands/ && rm -rf /tmp/claude-command
```

### Project-specific Installation

```bash
mkdir -p .claude/commands
curl -O https://raw.githubusercontent.com/seunggabi/claude-command/main/commit-push-pr.md
curl -O https://raw.githubusercontent.com/seunggabi/claude-command/main/done.md
mv *.md .claude/commands/
```

### Update

```bash
git clone https://github.com/seunggabi/claude-command.git /tmp/claude-command && cp /tmp/claude-command/*.md ~/.claude/commands/ && rm -rf /tmp/claude-command
```

## Commands

### `/commit-push-pr`

Automatically creates issue, branch, commit, push, and PR.

**Workflow:**
1. Check current branch (if on main)
2. Analyze changes and determine type (feat/fix/refactor/chore)
3. Create GitHub issue
4. Create branch: `{type}/#{issue_number}-{alias}`
5. Commit: `(#{issue_number}) {type}: {description}`
6. Push and create PR

### `/done`

Merges PR and closes related issue.

**Workflow:**
1. Extract issue number from current branch
2. Squash merge PR
3. Close issue (if not auto-closed)
4. Checkout main, pull, delete local branch

## Conventions

### Branch Naming
```
{type}/#{issue_number}-{alias}
```
Examples:
- `feat/#123-add-login`
- `fix/#124-fix-auth-bug`
- `refactor/#125-cleanup-code`
- `chore/#126-update-deps`

### Commit Message Format
```
(#{issue_number}) {type}: {description}
```
Examples:
- `(#123) feat: add login feature`
- `(#124) fix: fix authentication bug`

### PR Title Format
```
(#{issue_number}) {type}: {description}
```

## References
- [Semantic Commit Messages](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716)
- [Branch Naming Convention](https://gist.github.com/seunggabi/87f8c722d35cd07deb3f649d45a31082)
