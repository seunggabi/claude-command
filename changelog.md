# Changelog - Generate Changelog from Commits

Generates a formatted changelog from git commits.

## Workflow

1. **Determine range**: From last tag or specific commit
2. **Collect commits**: Group by type
3. **Format output**: Generate markdown changelog

## Execution Steps

### Step 1: Get commit range
```bash
# From last tag to HEAD
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -n "$LAST_TAG" ]; then
  RANGE="$LAST_TAG..HEAD"
else
  RANGE="HEAD"
fi
```

### Step 2: Collect commits by type
```bash
echo "## Features"
git log $RANGE --oneline --grep="^feat" --pretty=format:"- %s (%h)"

echo "## Bug Fixes"
git log $RANGE --oneline --grep="^fix" --pretty=format:"- %s (%h)"

echo "## Refactoring"
git log $RANGE --oneline --grep="^refactor" --pretty=format:"- %s (%h)"

echo "## Documentation"
git log $RANGE --oneline --grep="^docs" --pretty=format:"- %s (%h)"

echo "## Chores"
git log $RANGE --oneline --grep="^chore" --pretty=format:"- %s (%h)"
```

### Step 3: Format output

Generate markdown format:

```markdown
# Changelog

## [Unreleased]

### Features
- feat: add new feature (#123) (abc1234)

### Bug Fixes
- fix: resolve issue (#124) (def5678)

### Refactoring
- refactor: improve performance (ghi9012)

## [v1.0.0] - 2025-01-15

### Features
- Initial release
```

### Step 4: Output options

**To console:**

```bash
# Just print to stdout
```

**To file:**

```bash
# Append to CHANGELOG.md
```

## Changelog Format

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
```

## Guidelines

1. Group commits by semantic type
2. Include issue/PR references
3. Include commit hash for traceability
4. Order: Features, Fixes, Refactoring, Docs, Chores
5. Use [Keep a Changelog](https://keepachangelog.com) format
6. Date format: YYYY-MM-DD
7. **All outputs and summaries must be written in the user's configured language** (check CLAUDE.md or system settings for language preference)
