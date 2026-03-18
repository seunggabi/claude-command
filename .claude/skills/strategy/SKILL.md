---
name: strategy
description: Multi-agent repository analysis that produces an actionable strategy with prioritized roadmap, backlog, and PR plan. Use this skill whenever the user asks "what should I work on?", "analyze this repo", "give me a roadmap", "what are the risks?", "project health check", "어디서부터 시작하지?", "다음 뭐 할까?", or wants a comprehensive technical strategy for any codebase.
---

# Strategy - Multi-Agent Repository Analysis

Produces 12 structured reports in `./strategy/` by running 7 specialist agents **in parallel**.

## Step 1: Setup + Repo Context

```bash
mkdir -p ./strategy
echo "Strategy analysis started: $(date)" > ./strategy/.timestamp
echo "=== Repository Context ==="
pwd && basename $(pwd)
git status --short 2>/dev/null
git branch --show-current 2>/dev/null
git remote -v 2>/dev/null | head -2
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "unknown"
```

Read key files that exist (mark missing as "Not Found"):

| Category | Files |
|----------|-------|
| Docs | README.md, CONTRIBUTING.md, CHANGELOG.md |
| Package | package.json, pyproject.toml, Cargo.toml, go.mod |
| Config | .env.example, *.config.js, *.config.ts |
| Docker/CI | Dockerfile, docker-compose.yml, .github/workflows/ |
| DB | migrations/, schema.sql, prisma/ |
| Entry | main.*, index.*, app.*, server.* |
| Tests | test/, tests/, spec/ |

Write `./strategy/repo-map.md` and `./strategy/inspected-files.md` from what you find.

## Step 2: Launch 7 Agents in Parallel

Spawn all 7 agents in a **single message** so they run concurrently. Each agent should:
- Read relevant files independently
- Write its report to `./strategy/agent-{name}.md`
- Reference every claim with `path:line`

### Agent A — Architect
Focus: architecture style, module boundaries, coupling hotspots, layering violations, tech debt.

Output `./strategy/agent-architect.md`:
```
# Agent A: Architect Report
## Files Inspected
## Architecture Style
**Type**: / **Evidence**:
## Module Map
| Module | Path | Responsibility | Dependencies |
## Tech Debt Hotspots
| Location | Issue | Severity | Evidence |
## Recommendations
## Risks
| Risk | Impact | Likelihood | Evidence |
```

### Agent B — Product
Focus: problem statement, target users, use cases, local run instructions, doc gaps.

Output `./strategy/agent-product.md`.

### Agent C — Security
Focus: secrets in repo, unsafe configs, dependency vulnerabilities, auth, OWASP Top 10.

Output `./strategy/agent-security.md`.

### Agent D — Operations
Focus: deployment, config management, logging/metrics/tracing, health checks, failure modes.

Output `./strategy/agent-ops.md`.

### Agent E — Performance
Focus: hot paths, N+1 queries, missing indexes, caching, async usage, resource usage.

Output `./strategy/agent-performance.md`.

### Agent F — Quality
Focus: test coverage + types, CI completeness, static analysis, release process, versioning.

Output `./strategy/agent-quality.md`.

### Agent G — DX
Focus: setup friction, dev scripts, tooling, lint/format/hooks, onboarding time estimate.

Output `./strategy/agent-dx.md`.

## Step 3: Synthesize (after all agents complete)

Write `./strategy/strategy.md`:
```
# Strategy Report
**Repository**: / **Generated**:

## 1. Repo Snapshot
**Purpose**: — Evidence:
**Stack**: — Evidence:
**Run Locally**:
**Deployment**: — Evidence: (or Unknown)

## 2. Key Risks & Gaps (Top 10)
| # | Risk | Impact | Likelihood | Evidence | Fix |

## 3. Opportunities
### Quick Wins (≤2 days)
| Opportunity | Outcome | Effort | Files |
### Medium Bets (≤2 weeks)
| Opportunity | Outcome | Effort | Tradeoffs |
### Big Bets (multi-week)
| Opportunity | Outcome | Effort | Risks |

## 4. Roadmap Summary
- Week 1: {theme}
- Week 2: {theme}
- Weeks 3-6: {milestones}

## 5. Backlog Summary
| # | Item | Priority |

## 6. Next Actions
### Commands to Run
### Files to Edit
### First 3 PRs

## 7. Questions & Assumptions

## Agent Reports
| Agent | Report | Key Finding |
```

Write `./strategy/backlog.md`:
```
# Prioritized Backlog
**Scoring**: Priority = Impact / Effort (higher = do first)
| # | Item | Impact (1-5) | Effort (1-5) | Priority | Deps | Owner | Evidence |
```

Write `./strategy/roadmap.md`:
```
# Roadmap
## 2-Week Plan
### Week 1: {Theme}
**Milestone**: / **Deliverables**: / **PR Slicing**:
| PR | Title | Files | Depends On |

## 6-Week Plan
| Week | Phase | Milestone | Deliverables | Dependencies |
```

## Step 4: Done

```bash
echo "=== Strategy Analysis Complete ==="
ls -la ./strategy/
echo ""
echo "Start with: cat ./strategy/strategy.md"
```

## Guidelines

1. Every factual claim must cite `path:line`
2. If unverifiable, mark **Unknown** and propose how to verify
3. Prefer minimal viable changes over big rewrites
4. Slice work into small, reviewable PRs
5. All outputs in English
6. Agents run in parallel (Step 2) — synthesis waits for all to finish (Step 3)
