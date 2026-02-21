# Claude Commands

Custom commands for Claude Code CLI.

## Model

```shell
./model.sh opus
```

```shell
./model.sh sonnet
```

```shell
./model.sh haiku
```

## Prerequisites

The following tools must be installed:

| Tool                                                              | Min Version | Verify             | Install                                                         |
| ----------------------------------------------------------------- | ----------- | ------------------ | --------------------------------------------------------------- |
| [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) | -           | `claude --version` | [Official Docs](https://docs.anthropic.com/en/docs/claude-code) |
| [Git](https://git-scm.com/)                                       | 2.0+        | `git --version`    | `brew install git`                                              |
| [GitHub CLI](https://cli.github.com/)                             | 2.0+        | `gh --version`     | `brew install gh`                                               |
| [Node.js](https://nodejs.org/) (for skills)                       | 16.0+       | `node --version`   | `brew install node`                                             |

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

Installs commands, CLAUDE.md rules, and settings globally:

```bash
git clone https://github.com/seunggabi/claude-command.git /tmp/claude-command && /tmp/claude-command/install.sh --global && rm -rf /tmp/claude-command
```

This installs:
- Commands → `~/.claude/commands/`
- Skills → Claude Code Skills (obra/superpowers, blader/humanizer, nextlevelbuilder/ui-ux-pro-max-skill, vercel-labs/skills)
- Settings → `~/.claude/settings.json`
- Rules → `~/.claude/CLAUDE.md`

### Project-specific Installation

Installs commands, settings, and rules to the current project only:

```bash
git clone https://github.com/seunggabi/claude-command.git /tmp/claude-command && /tmp/claude-command/install.sh && rm -rf /tmp/claude-command
```

This installs:
- Commands → `.claude/commands/`
- Skills → Claude Code Skills (obra/superpowers, blader/humanizer, nextlevelbuilder/ui-ux-pro-max-skill, vercel-labs/skills)
- Settings → `.claude/settings.json`
- Rules → `.claude/CLAUDE.md`

### Update

Re-run the install command. The installer is idempotent — it replaces the managed block and overwrites commands without affecting other content.

### Uninstall

```bash
# Remove rules block (preserves other content)
./install.sh --uninstall
```

**Note:** The installer automatically adds Claude Code skills (superpowers, humanizer, ui-ux-pro-max, vercel-labs). If `npx` is not available, manual installation instructions will be displayed.

## Settings

Session logs are automatically saved to `.claude/logs/{session_id}.jsonl` via `UserPromptSubmit` hook.

## Commands

| Command           | Description                                    |
| ----------------- | ---------------------------------------------- |
| `/commit-push-pr` | Create issue → branch → commit → push → PR            |
| `/done`           | Merge PR → close issue → cleanup                      |
| `/cppdt`          | Full release cycle: PR → merge → tag (with 3x retry)  |
| `/sync`           | Rebase current branch with main                       |
| `/cleanup`        | Remove merged local/remote branches                   |
| `/status`         | Show project status (git, issues, PRs)                |
| `/tag`            | Smart version tag with auto semver bump               |
| `/release`        | Create version tag and GitHub release                 |
| `/changelog`      | Generate changelog from commits                       |
| `/strategy`       | Multi-agent repo analysis & next-step planning        |

### `/commit-push-pr`

Analyzes changes → creates issue → creates branch → commits → pushes → creates PR.

Format: `{type}/#{issue_number}_{alias}` → `(#{issue_number}) {type}: {description}`

### `/done`

Merges PR (squash) → closes issue → cleans up local branch.

### `/cppdt`

Full release cycle: `/commit-push-pr` → `/done` → `/tag`.

Each phase retries up to 3 times on failure.

**Usage:** `/cppdt` | `/cppdt major` | `/cppdt v2.0.0`

### `/sync`

Rebases current branch with main (stash → fetch → rebase → restore → force push).

### `/cleanup`

Removes merged local and remote branches (with confirmation).

### `/status`

Shows git status, recent commits, open issues/PRs, and assigned items.

### `/tag`

Auto version bump from commits or explicit version.

**Usage:** `/tag` | `/tag v2.0.0` | `/tag patch|minor|major`

**Auto-detection:** `feat` → MINOR, `fix/chore` → PATCH, `BREAKING` → MAJOR

### `/release`

Creates annotated tag and GitHub release with generated changelog.

### `/changelog`

Generates markdown changelog grouped by commit type.

### `/strategy`

Multi-agent repo analysis with 7 specialized agents.

Outputs to `./strategy/` with strategy, backlog, and roadmap.

**Flags:** `--quick` | `--security` | `--deep`

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
