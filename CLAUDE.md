<!-- CLAUDE-COMMAND:BEGIN -->
# Claude Command - Project Rules

## Safe Deletion Protocol

**NEVER execute `rm -rf` directly.** All recursive forced deletions must be replaced with a safe move operation.

### Rules

1. When `rm -rf <path>` is requested, **move** the target to `/tmp/<original_absolute_path>` instead of deleting.
2. Preserve the full directory structure under `/tmp/` so the origin is traceable.
3. If the destination already exists in `/tmp/`, append a timestamp suffix to avoid collisions.
4. After moving, confirm the move was successful before proceeding.

### Examples

```bash
# WRONG - never do this
rm -rf /Users/me/project/dist

# CORRECT - move to /tmp mirror path
mkdir -p /tmp/Users/me/project
mv /Users/me/project/dist /tmp/Users/me/project/dist

# CORRECT - with collision handling
mv /Users/me/project/dist /tmp/Users/me/project/dist_20250206_143022
```

### Applies To

- `rm -rf`
- `rm -r` (recursive without force)
- Any shell command that recursively removes directories or files

### Exceptions

- Ephemeral build artifacts explicitly created in the current session (e.g., `node_modules` after a fresh `npm install`)
- Files already located under `/tmp/`

## Context Limit Prevention

When delegating to sub-agents or running multi-step workflows, proactively manage context window usage to avoid hitting limits mid-task.

### Rules

1. **Minimize context per agent**: When spawning sub-agents (Task tool), provide only the essential information needed for that specific subtask. Do not pass the entire conversation history or full file contents unless required.
2. **Prefer targeted reads**: Read only relevant sections of files (`offset`/`limit` parameters) instead of entire large files.
3. **Summarize before delegating**: When passing results between agents, summarize findings into concise bullet points rather than forwarding raw output.
4. **Chunk large tasks**: If a task involves analyzing more than 5 files or 500 lines of code, split it into multiple smaller agent calls rather than one large one.
5. **Limit search results**: Always use `head_limit` in Grep/Glob calls. Prefer `files_with_matches` output mode over `content` when file paths are sufficient.
6. **Avoid redundant reads**: Never read the same file twice in one agent session. Cache key information in your response instead.
7. **Early termination**: If an agent detects it has consumed significant context (e.g., multiple large file reads), it should output its current findings immediately rather than continuing to accumulate more context.
<!-- CLAUDE-COMMAND:END -->
