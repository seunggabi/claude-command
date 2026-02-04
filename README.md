# Claude Commands

Custom commands for Claude Code CLI.

## Prerequisites

The following tools must be installed:

| Tool | Min Version | Verify | Install |
|------|-------------|--------|---------|
| [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) | - | `claude --version` | [Official Docs](https://docs.anthropic.com/en/docs/claude-code) |
| [Git](https://git-scm.com/) | 2.0+ | `git --version` | `brew install git` |
| [GitHub CLI](https://cli.github.com/) | 2.0+ | `gh --version` | `brew install gh` |

### GitHub CLI Authentication

After installing GitHub CLI, authentication is required:

```bash
gh auth login
```

Verify authentication status:

```bash
gh auth status
```

## Installation

### Global Installation (Available in all projects)

```bash
# Clone and install globally
git clone https://github.com/seunggabi/claude-command.git
cd claude-command
mkdir -p ~/.claude/commands
cp -f changelog.md cleanup.md commit-push-pr.md done.md release.md status.md sync.md ~/.claude/commands/
cp -rf .claude/commands/* ~/.claude/commands/
```

**One-liner:**
```bash
git clone https://github.com/seunggabi/claude-command.git /tmp/claude-command && mkdir -p ~/.claude/commands && cp -f /tmp/claude-command/{changelog,cleanup,commit-push-pr,done,release,status,sync}.md ~/.claude/commands/ && cp -rf /tmp/claude-command/.claude/commands/* ~/.claude/commands/ && rm -rf /tmp/claude-command
```

### Project-specific Installation

```bash
mkdir -p .claude/commands
cd .claude/commands
curl -O https://raw.githubusercontent.com/seunggabi/claude-command/main/commit-push-pr.md
curl -O https://raw.githubusercontent.com/seunggabi/claude-command/main/done.md
curl -O https://raw.githubusercontent.com/seunggabi/claude-command/main/sync.md
curl -O https://raw.githubusercontent.com/seunggabi/claude-command/main/strategy.md
curl -O https://raw.githubusercontent.com/seunggabi/claude-command/main/cleanup.md
curl -O https://raw.githubusercontent.com/seunggabi/claude-command/main/status.md
curl -O https://raw.githubusercontent.com/seunggabi/claude-command/main/release.md
curl -O https://raw.githubusercontent.com/seunggabi/claude-command/main/changelog.md
cd -
```

### Update

```bash
git clone https://github.com/seunggabi/claude-command.git /tmp/claude-command && cp -f /tmp/claude-command/{changelog,cleanup,commit-push-pr,done,release,status,sync}.md ~/.claude/commands/ && rm -rf /tmp/claude-command
```

## Commands

| Command | Description |
|---------|-------------|
| `/commit-push-pr` | Create issue → branch → commit → push → PR |
| `/done` | Merge PR → close issue → cleanup |
| `/sync` | Rebase current branch with main |
| `/cleanup` | Remove merged local/remote branches |
| `/status` | Show project status (git, issues, PRs) |
| `/release` | Create version tag and GitHub release |
| `/changelog` | Generate changelog from commits |
| `/strategy` | Multi-agent repo analysis & next-step planning |

### `/commit-push-pr`

Automatically creates issue, branch, commit, push, and PR.

**Workflow:**

1. Check current branch (if on main)
2. Analyze changes and determine type (feat/fix/refactor/chore)
3. Create GitHub issue
4. Create branch: `{type}/#{issue_number}_{alias}`
5. Commit: `(#{issue_number}) {type}: {description}`
6. Push and create PR

### `/done`

Merges PR and closes related issue.

**Workflow:**

1. Extract issue number from current branch
2. Squash merge PR
3. Close issue (if not auto-closed)
4. Checkout main, pull, delete local branch

### `/sync`

Synchronizes current branch with the latest main branch using rebase.

**Workflow:**

1. Stash uncommitted changes
2. Fetch latest and rebase on main
3. Handle conflicts if any
4. Restore stash and force push

### `/cleanup`

Removes merged local and remote branches.

**Workflow:**

1. Switch to main and update
2. Fetch and prune remote
3. Delete local merged branches
4. Delete remote merged branches (with confirmation)

### `/status`

Shows comprehensive project status.

**Displays:**

- Git status and recent commits
- Open issues and PRs
- Assigned items
- Recent merges

### `/release`

Creates a version tag and GitHub release.

**Workflow:**

1. Ensure on main and up-to-date
2. Determine version bump (semver)
3. Generate changelog
4. Create annotated tag
5. Create GitHub release with notes

### `/changelog`

Generates a formatted changelog from git commits.

**Workflow:**

1. Determine commit range (from last tag)
2. Group commits by type
3. Format as markdown changelog

### `/strategy`

Comprehensive multi-agent repository analysis that produces an actionable strategy for next steps.

**Features:**

- 7 specialized agents (Architect, Product, Security, Ops, Performance, Quality, DX)
- Evidence-backed analysis with file path citations
- Outputs to `./strategy/` directory with 12 structured reports

**Workflow:**

1. **Phase 0 - Intake**: Scan repo structure, identify key files
2. **Phase 1 - Analysis**: Run all 7 agents in parallel
3. **Phase 2 - Synthesis**: Generate strategy, backlog, and roadmap

**Outputs:**

- `./strategy/strategy.md` - Main strategy report
- `./strategy/backlog.md` - Prioritized backlog with impact/effort scores
- `./strategy/roadmap.md` - 2-week and 6-week execution plans
- `./strategy/agent-*.md` - Individual agent reports

**Flags:**

- `--quick` - Fast scan (Architect, Quality, DX only)
- `--security` - Security-focused analysis
- `--deep` - Extended analysis with all agents

## Conventions

### Branch Naming

```text
{type}/#{issue_number}_{alias}
```

Examples:
- `feat/#123_add-login`
- `fix/#124_fix-auth-bug`
- `refactor/#125_cleanup-code`
- `chore/#126_update-deps`

### Commit Message Format

```text
(#{issue_number}) {type}: {description}
```

Examples:
- `(#123) feat: add login feature`
- `(#124) fix: fix authentication bug`

### PR Title Format

```text
(#{issue_number}) {type}: {description}
```

## References

- [Semantic Commit Messages](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716)
- [Branch Naming Convention](https://gist.github.com/seunggabi/87f8c722d35cd07deb3f649d45a31082)
