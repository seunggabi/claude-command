# Strategy - Multi-Agent Repository Analysis & Next-Step Planner

Comprehensive repository analysis using 7 specialized agents to produce an actionable strategy with prioritized roadmap, backlog, and PR plan.

## Workflow

1. **Repo Intake**: Scan structure, identify key files, create output directory
2. **Multi-Agent Analysis**: Run 7 agents (Architect, Product, Security, Ops, Performance, Quality, DX)
3. **Synthesis**: Combine findings into strategy, backlog, and roadmap documents
4. **Output**: Write 12 structured reports to `./strategy/` directory

## Execution Steps

### Step 1: Setup Output Directory

~~~bash
mkdir -p ./strategy
echo "Strategy analysis started: $(date)" > ./strategy/.timestamp
~~~

### Step 2: Print Repository Context

~~~bash
echo "=== Repository Context ==="
echo "Working Directory: $(pwd)"
echo "Repository: $(basename $(pwd))"
echo ""
git status --short 2>/dev/null || echo "Not a git repository"
git branch --show-current 2>/dev/null || echo "No branch info"
git remote -v 2>/dev/null | head -2 || echo "No remotes configured"
echo ""
echo "Default branch:"
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || git remote show origin 2>/dev/null | grep 'HEAD branch' | cut -d: -f2 | tr -d ' ' || echo "Unknown"
~~~

### Step 3: Generate Repo Map

~~~bash
echo "=== Directory Structure ==="
if command -v tree &> /dev/null; then
  tree -L 4 -I 'node_modules|.git|vendor|__pycache__|.venv|dist|build|strategy' --dirsfirst 2>/dev/null || find . -type d \( -name "node_modules" -o -name ".git" -o -name "vendor" -o -name "__pycache__" -o -name ".venv" -o -name "dist" -o -name "build" -o -name "strategy" \) -prune -o -print 2>/dev/null | head -100
else
  find . -type d \( -name "node_modules" -o -name ".git" -o -name "vendor" -o -name "__pycache__" -o -name ".venv" -o -name "dist" -o -name "build" -o -name "strategy" \) -prune -o -print 2>/dev/null | head -100
fi

echo ""
echo "=== Top-Level Contents ==="
ls -la
~~~

### Step 4: Identify and Read Key Files

Scan for and READ each file that exists. Mark missing files as "Not Found":

| Category | Files to Check |
|----------|----------------|
| Documentation | README.md, README, docs/, CONTRIBUTING.md, CHANGELOG.md |
| Package/Build | package.json, pyproject.toml, Cargo.toml, go.mod, pom.xml, build.gradle, Makefile |
| Config | .env.example, config/, settings/, *.config.js, *.config.ts |
| Docker | Dockerfile, docker-compose.yml, .dockerignore |
| CI/CD | .github/workflows/, .gitlab-ci.yml, Jenkinsfile, .circleci/ |
| IaC | terraform/, pulumi/, k8s/, helm/ |
| Database | migrations/, schema.sql, prisma/, alembic/ |
| Entry Points | main.*, index.*, app.*, server.*, src/main.*, src/index.* |
| Tests | test/, tests/, __tests__/, spec/ |

**For repos with minimal files**: If README.md is missing, check for any .md file. If no package manifest exists, infer stack from file extensions.

### Step 5: Write repo-map.md

Use the Write tool to create `./strategy/repo-map.md`:

~~~
# Repository Map

## Basic Info
- **Name**: {{repo_name}}
- **Path**: {{absolute_path}}
- **Git Status**: {{branch}}, {{clean_or_dirty}}
- **Default Branch**: {{main_or_master_or_unknown}}

## Directory Tree
{{tree_output}}

## Key Files Identified
| Category | File | Status |
|----------|------|--------|
| README | README.md | Found/Not Found |
| Package | package.json | Found/Not Found |
...
~~~

### Step 6: Write inspected-files.md

Use the Write tool to create `./strategy/inspected-files.md`:

~~~
# Inspected Files

## Phase 0 - Intake
- [x] ./README.md
- [x] ./package.json
- [ ] ./Dockerfile (not found)
...

## Phase 1 - Agent Analysis
(Each agent appends files it inspected)
~~~

### Step 7: Run Agent A - Architect

Analyze system and code structure. Focus on:
- Architecture style (monolith, microservices, modular monolith, serverless)
- Module boundaries and responsibilities
- Dependency graph (external and internal)
- Layering violations (presentation → business → data)
- Coupling hotspots
- Tech debt concentration

Write findings to `./strategy/agent-architect.md` with this structure:

~~~
# Agent A: Architect Report

## Files Inspected
- {{path1}}
- {{path2}}

## Architecture Style
**Type**: {{style}}
**Evidence**: {{path:line}}

## Module Map
| Module | Path | Responsibility | Dependencies |
|--------|------|----------------|--------------|

## Tech Debt Hotspots
| Location | Issue | Severity | Evidence |
|----------|-------|----------|----------|

## Recommendations
1. {{recommendation}} — Priority: High/Med/Low

## Risks
| Risk | Impact | Likelihood | Evidence |
|------|--------|------------|----------|
~~~

### Step 8: Run Agent B - Product

Analyze value proposition and documentation. Focus on:
- Problem statement and target users
- Primary use cases
- Local run instructions (documented vs actual)
- Documentation gaps
- Missing artifacts (examples, screenshots, tutorials)

Write findings to `./strategy/agent-product.md`.

### Step 9: Run Agent C - Security

Analyze security posture. Focus on:
- Secrets in repo (scan for API keys, passwords, tokens)
- Unsafe configurations
- Dependency vulnerabilities (run npm audit / pip-audit / cargo audit if applicable)
- Auth implementation
- OWASP Top 10 risk areas

Write findings to `./strategy/agent-security.md`.

### Step 10: Run Agent D - Operations

Analyze deployability and observability. Focus on:
- Deployment method and environments
- Configuration management
- Logging, metrics, tracing
- Health checks
- Failure modes
- Runbooks

Write findings to `./strategy/agent-ops.md`.

### Step 11: Run Agent E - Performance

Analyze bottlenecks and scalability. Focus on:
- Hot paths
- Database patterns (N+1, missing indexes)
- Caching strategy
- Async usage
- Resource usage

Write findings to `./strategy/agent-performance.md`.

### Step 12: Run Agent F - Quality

Analyze testing and CI. Focus on:
- Test coverage and types (unit/integration/e2e)
- CI pipeline completeness
- Static analysis configuration
- Release process
- Versioning strategy

Write findings to `./strategy/agent-quality.md`.

### Step 13: Run Agent G - DX

Analyze developer experience. Focus on:
- Setup friction (steps to first run)
- Available scripts
- Development tooling
- Consistency enforcement (lint, format, hooks)
- Onboarding time estimate

Write findings to `./strategy/agent-dx.md`.

### Step 14: Synthesize strategy.md

Combine all agent findings. Use the Write tool to create `./strategy/strategy.md`:

~~~
# Strategy Report

**Repository**: {{name}}
**Generated**: {{timestamp}}

## 1. Repo Snapshot
**Purpose**: {{description}} — Evidence: {{path}}
**Stack**: {{languages, frameworks}} — Evidence: {{path}}
**Run Locally**: {{commands}}
**Deployment**: {{method}} — Evidence: {{path}} or **Unknown**

## 2. Key Risks & Gaps (Top 10)
| # | Risk | Impact | Likelihood | Evidence | Fix |
|---|------|--------|------------|----------|-----|

## 3. Opportunities
### Quick Wins (≤2 days)
| Opportunity | Outcome | Effort | Files |
|-------------|---------|--------|-------|

### Medium Bets (≤2 weeks)
| Opportunity | Outcome | Effort | Tradeoffs |
|-------------|---------|--------|-----------|

### Big Bets (Multi-week)
| Opportunity | Outcome | Effort | Risks |
|-------------|---------|--------|-------|

## 4. Roadmap Summary
See ./strategy/roadmap.md for details.
- Week 1: {{theme}}
- Week 2: {{theme}}
- Weeks 3-6: {{milestones}}

## 5. Backlog Summary
See ./strategy/backlog.md for full list.
| # | Item | Priority |
|---|------|----------|

## 6. Next Actions
### Commands to Run
1. {{command}} — {{reason}}

### Files to Edit
1. {{path}} — {{reason}}

### First 3 PRs
**PR 1**: {{title}}
- Scope: {{description}}
- Files: {{list}}

## 7. Questions & Assumptions
1. {{question}}
   - Why: {{impact}}
   - Assumption if unanswered: {{default}}

## Agent Reports
| Agent | Report | Key Finding |
|-------|--------|-------------|
~~~

### Step 15: Write backlog.md

Use the Write tool to create `./strategy/backlog.md`:

~~~
# Prioritized Backlog

**Scoring**: Priority = Impact / Effort (higher = do first)

| # | Item | Impact (1-5) | Effort (1-5) | Priority | Deps | Owner | Evidence |
|---|------|--------------|--------------|----------|------|-------|----------|

## By Owner
### Security
- [ ] #N: {{item}}

### Quality
- [ ] #N: {{item}}
~~~

### Step 16: Write roadmap.md

Use the Write tool to create `./strategy/roadmap.md`:

~~~
# Roadmap

## 2-Week Plan

### Week 1: {{Theme}}
**Milestone**: {{description}}
**Deliverables**:
- [ ] {{item}}

**PR Slicing**:
| PR | Title | Files | Depends On |
|----|-------|-------|------------|

### Week 2: {{Theme}}
...

## 6-Week Plan

| Week | Phase | Milestone | Deliverables | Dependencies |
|------|-------|-----------|--------------|--------------|
| 1-2 | Foundation | {{milestone}} | {{items}} | None |
| 3-4 | Hardening | {{milestone}} | {{items}} | Foundation |
| 5-6 | Scale | {{milestone}} | {{items}} | Hardening |
~~~

### Step 17: Print Summary

~~~bash
echo ""
echo "=== Strategy Analysis Complete ==="
echo "Generated files:"
ls -la ./strategy/
echo ""
echo "Start with: cat ./strategy/strategy.md"
~~~

## Output Files

| File | Content |
|------|---------|
| repo-map.md | Repository structure and key files |
| inspected-files.md | List of all files read during analysis |
| agent-architect.md | Architecture and tech debt analysis |
| agent-product.md | Product value and documentation gaps |
| agent-security.md | Security vulnerabilities and risks |
| agent-ops.md | Deployment and observability |
| agent-performance.md | Bottlenecks and scalability |
| agent-quality.md | Testing and CI/CD |
| agent-dx.md | Developer experience |
| strategy.md | Integrated strategy report |
| backlog.md | Prioritized backlog with scoring |
| roadmap.md | 2-week and 6-week plans |

## Guidelines

1. Every factual claim must reference a specific file path (e.g., `src/auth.ts:42`)
2. If something cannot be verified, mark it as **Unknown** and propose how to verify
3. Prefer minimal viable changes over "big rewrite" suggestions
4. Use PR-sliced execution (small, reviewable PRs)
5. For sparse repos with few files, focus on what exists rather than leaving sections empty
6. Run agents in parallel where possible for efficiency
7. Always create `./strategy/` directory before writing any files
8. **All analysis reports and outputs must be written in the user's configured language** (check CLAUDE.md or system settings for language preference)

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Semantic Versioning](https://semver.org/)
- [12 Factor App](https://12factor.net/)
