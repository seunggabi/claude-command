# Commit, Push, PR, Merge, and Tag

Sequentially executes `/commit-push-pr` → `/done` → `/tag` to complete the full release cycle in one command.

## Workflow

1. **Phase 1 - Commit, Push, PR**: Create issue, branch, commit, push, and PR (`/commit-push-pr`)
2. **Phase 2 - Done**: Merge PR and close issue (`/done`)
3. **Phase 3 - Tag**: Create version tag and GitHub release (`/tag`)

## Execution Steps

### Phase 1: Commit, Push, PR

Execute the full `/commit-push-pr` workflow:

1. Check current branch and changes
2. Analyze changes and determine semantic commit type
3. Create GitHub issue (if on main branch)
4. Create branch: `{type}/#{issue_number}_{alias}`
5. Commit: `(#{issue_number}) {type}: {description}`
6. Push and create PR with `Closes #{issue_number}`

**Gate**: Verify PR was created successfully before proceeding.

```bash
gh pr view --json number,state,url
```

### Phase 2: Done (PR Merge)

Execute the full `/done` workflow:

1. Check PR status and mergeability
2. Merge PR with squash: `gh pr merge --squash --delete-branch`
3. Close issue if not auto-closed
4. Local cleanup: checkout main, pull, delete local branch

**Gate**: Verify merge completed and now on main branch.

```bash
git branch --show-current  # Should be "main"
git log -1 --oneline       # Should show squashed commit
```

### Phase 3: Tag and Release

Execute the full `/tag` workflow:

1. Ensure on main branch with clean working tree
2. Get last tag and commits since then
3. Auto-determine version bump from commit messages
4. Generate release notes grouped by type
5. Create annotated tag and push
6. Create GitHub release

**Gate**: Verify tag and release were created.

```bash
git tag -l --sort=-v:refname | head -1  # Should show new tag
gh release view --json tagName,url
```

## Retry Policy

Each phase has up to **3 attempts** before aborting.

### Rules

1. If a phase fails, analyze the error, fix the cause, and retry (up to 3 times)
2. Each retry must attempt to resolve the root cause, not just repeat the same command blindly
3. After 3 consecutive failures on the same phase, abort entirely and report all 3 errors to the user
4. Retry count resets when moving to the next phase

### Retry Flow

```
Phase N: Attempt 1
  ├─ Success → Proceed to Phase N+1
  └─ Fail → Analyze error, fix cause
       Phase N: Attempt 2
         ├─ Success → Proceed to Phase N+1
         └─ Fail → Analyze error, fix cause
              Phase N: Attempt 3
                ├─ Success → Proceed to Phase N+1
                └─ Fail → ABORT (report all errors)
```

### Retry Examples

| Phase | Error | Retry Action |
|-------|-------|-------------|
| Phase 1 | Push rejected | `git pull --rebase` then retry push |
| Phase 1 | Branch already exists | Delete old branch or use a different name |
| Phase 2 | PR not mergeable (CI pending) | Wait 30 seconds, check CI status, retry |
| Phase 2 | Merge conflict | Attempt auto-resolve or inform user |
| Phase 3 | Tag already exists | Bump to next version and retry |
| Phase 3 | Push tag rejected | `git fetch --tags` and retry |

## Guidelines

1. Each phase must complete successfully before moving to the next
2. Always retry up to 3 times before giving up on any phase
3. If PR is not mergeable (CI failing, review needed), retry with appropriate fix
4. Follow all conventions from individual commands (commit format, branch naming, etc.)
5. The `/tag` argument can be passed to this command to override auto-detection (e.g., `/commit-push-pr_done_tag major`)
6. **All outputs must be written in English**

## Error Handling

| Phase | Possible Error | Action |
|-------|---------------|--------|
| Phase 1 | No changes to commit | Abort entirely (no retry) |
| Phase 1 | PR creation fails | Fix and retry (up to 3x) |
| Phase 2 | PR not mergeable | Fix and retry (up to 3x) |
| Phase 2 | Merge fails | Fix and retry (up to 3x) |
| Phase 3 | Not on main branch | Checkout main and retry (up to 3x) |
| Phase 3 | No new commits since last tag | Skip tag creation, inform user (no retry) |

## Examples

```bash
# Full cycle with auto-detection
/commit-push-pr_done_tag

# Full cycle with forced major version bump
/commit-push-pr_done_tag major

# Full cycle with explicit version
/commit-push-pr_done_tag v2.0.0
```
