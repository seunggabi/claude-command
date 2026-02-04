# Release - Create Version Tag and GitHub Release

Creates a version tag and GitHub release with changelog.

## Workflow

1. **Check main branch**: Ensure on main and up-to-date
2. **Determine version**: Calculate next version (semver)
3. **Generate changelog**: List changes since last release
4. **Create tag**: Create annotated git tag
5. **Create release**: Create GitHub release with notes

## Version Format

Semantic Versioning: `vMAJOR.MINOR.PATCH`
- MAJOR: Breaking changes
- MINOR: New features (backwards compatible)
- PATCH: Bug fixes (backwards compatible)

## Execution Steps

### Step 1: Ensure on main and up-to-date
```bash
git checkout main
git pull origin main
```

### Step 2: Get latest tag
```bash
git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0"
```

### Step 3: Determine version bump type
Analyze commits since last tag:
- `feat:` → MINOR bump
- `fix:` → PATCH bump
- `BREAKING CHANGE` or `!:` → MAJOR bump

### Step 4: Generate changelog
```bash
# Get commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline --pretty=format:"- %s"
```

### Step 5: Create annotated tag
```bash
git tag -a v{VERSION} -m "Release v{VERSION}"
git push origin v{VERSION}
```

### Step 6: Create GitHub release
```bash
gh release create v{VERSION} --title "v{VERSION}" --notes "## What's Changed

### Features
- feat commits...

### Bug Fixes
- fix commits...

### Other Changes
- other commits...

**Full Changelog**: https://github.com/{owner}/{repo}/compare/v{PREV}...v{VERSION}"
```

## Guidelines

1. Always release from main branch
2. Ensure all tests pass before releasing
3. Use semantic versioning strictly
4. Include meaningful release notes
5. Link to full changelog for details
6. Consider pre-release tags (v1.0.0-beta.1) for testing
7. **All release notes and outputs must be written in the user's configured language** (check CLAUDE.md or system settings for language preference)
