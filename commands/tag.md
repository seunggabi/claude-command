# Tag - Smart Version Tag and Release

Creates a version tag with automatic semver bump detection and GitHub release.

## Usage

```
/tag              # Auto-determine version bump from commits
/tag v2.0.0       # Explicit version override
/tag patch        # Force patch bump
/tag minor        # Force minor bump
/tag major        # Force major bump
```

## Workflow

1. **Validate**: Ensure on main branch and up-to-date
2. **Analyze**: Collect commits since last tag
3. **Determine version**: Auto-detect bump type from commit messages
4. **Create tag**: Annotated tag with grouped changelog
5. **Release**: Push tag and create GitHub release

## Execution Steps

### Step 1: Validate state

```bash
git checkout main
git pull origin main
git fetch --tags
```

Abort if:
- Not on main branch
- Uncommitted changes exist
- No new commits since last tag

### Step 2: Get last tag and commits

```bash
LAST_TAG=$(git tag -l 'v*' --sort=-v:refname | head -1)
# If no tags exist, use initial commit
if [ -z "$LAST_TAG" ]; then
  RANGE="HEAD"
  LAST_TAG="v0.0.0"
else
  RANGE="${LAST_TAG}..HEAD"
fi

git log $RANGE --oneline
```

### Step 3: Determine version bump

Parse the argument to decide bump type:

| Argument | Action |
|----------|--------|
| `v1.2.3` (explicit semver) | Use as-is, skip auto-detection |
| `major` | Force MAJOR bump |
| `minor` | Force MINOR bump |
| `patch` | Force PATCH bump |
| _(none)_ | Auto-detect from commits |

#### Auto-detection Rules

Scan commit messages in `$RANGE` and apply the **highest applicable** bump:

| Priority | Condition | Bump | Example |
|----------|-----------|------|---------|
| 1 | Message contains `BREAKING CHANGE` or type ends with `!` | MAJOR | `feat!: redesign API` |
| 2 | Type is `feat` | MINOR | `(#10) feat: add search` |
| 3 | Everything else (`fix`, `chore`, `refactor`, `docs`, etc.) | PATCH | `(#11) chore: cleanup` |

#### Version Calculation

```
Given LAST_TAG = vX.Y.Z

MAJOR bump → v(X+1).0.0
MINOR bump → vX.(Y+1).0
PATCH bump → vX.Y.(Z+1)
```

### Step 4: Generate release notes

Group commits by type. Only include sections that have commits.

```markdown
## What's Changed

### Features
- (#10) feat: add search (abc1234)

### Bug Fixes
- (#12) fix: resolve timeout (def5678)

### Other Changes
- (#11) chore: cleanup hooks (ghi9012)

**Full Changelog**: https://github.com/{owner}/{repo}/compare/{LAST_TAG}...{NEW_TAG}
```

**Type grouping:**

| Section | Commit Types |
|---------|-------------|
| Features | `feat` |
| Bug Fixes | `fix` |
| Performance | `perf` |
| Refactoring | `refactor` |
| Documentation | `docs` |
| Other Changes | `chore`, `build`, `ci`, `style`, `test`, and any unmatched |

### Step 5: Create tag and release

```bash
# Create annotated tag
git tag -a {NEW_TAG} -m "{NEW_TAG}

{release_notes}"

# Push tag
git push origin {NEW_TAG}

# Create GitHub release
gh release create {NEW_TAG} --title "{NEW_TAG}" --notes "{release_notes}"
```

## Guidelines

1. Always tag from main branch with a clean working tree
2. Never overwrite existing tags (abort if tag already exists)
3. When no argument is given, auto-detection MUST be used
4. When an explicit version is given, validate it is greater than the last tag
5. Merge commits (e.g., `Merge pull request #N`) should be excluded from changelog entries
6. Release notes should group commits cleanly with no empty sections
7. Include the full changelog comparison link at the bottom
8. **All release notes and outputs must be written in the user's configured language** (check CLAUDE.md or system settings for language preference)

## Examples

```bash
# Commits since v1.3.0:
#   (#11) chore: remove context-monitor hook
#   feat: add UserPromptSubmit hook
#
# /tag         → v1.4.0 (feat detected → MINOR bump)
# /tag patch   → v1.3.1 (forced PATCH)
# /tag v2.0.0  → v2.0.0 (explicit)

# Commits since v1.4.0:
#   (#15) chore: remove hooks from settings
#   (#13) chore: cleanup install.sh
#
# /tag         → v1.4.1 (no feat → PATCH bump)
```

## References

- [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
