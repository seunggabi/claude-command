# /strategy — Repo Strategy & Next-Step Planner

You are Claude Code running an end-to-end repository analysis to produce an actionable strategy for what to do next.

## Mission

Analyze this repository with a multi-agent approach and output a concrete, evidence-backed plan:
- What the repo is and how it works
- What is missing / risky
- What to do next (prioritized roadmap, backlog, and PR plan)

**Hard Requirements**
- Create `./strategy/` directory (relative to repo root) before writing any outputs
- All analysis outputs MUST be written under `./strategy/`
- Do not hallucinate. Every factual claim must reference specific file paths, code locations, configs, or commands you actually inspected
- If uncertain, label it **Unknown** and propose exactly how to verify
- Prefer minimal viable changes and PR-sliced execution over "big rewrite" suggestions

---

## Phase 0 — Repo Intake (Mandatory)

**You MUST complete this phase before any analysis.**

### Step 0.1: Setup Output Directory
```bash
mkdir -p ./strategy
echo "Strategy analysis started: $(date)" > ./strategy/.timestamp
```

### Step 0.2: Print Repository Context
```bash
echo "=== Repository Context ==="
echo "Working Directory: $(pwd)"
echo "Repository: $(basename $(pwd))"
echo ""
git status --short 2>/dev/null || echo "Not a git repository"
git branch --show-current 2>/dev/null || echo "No branch info"
git remote -v 2>/dev/null | head -2 || echo "No remotes configured"
echo ""
echo "Default branch:"
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "Unknown (check manually)"
```

### Step 0.3: Generate Repo Map
```bash
echo "=== Directory Structure (depth 4) ==="
find . -type d \( -name "node_modules" -o -name ".git" -o -name "vendor" -o -name "__pycache__" -o -name ".venv" -o -name "dist" -o -name "build" -o -name "strategy" \) -prune -o -type f -print 2>/dev/null | head -200

echo ""
echo "=== Top-Level Contents ==="
ls -la
```

### Step 0.4: Identify and Read Key Files

Scan for these files. READ each one that exists:

| Category | Files to Check |
|----------|----------------|
| Documentation | `README.md`, `README`, `docs/`, `CONTRIBUTING.md`, `CHANGELOG.md` |
| Package/Build | `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `pom.xml`, `build.gradle`, `Makefile`, `CMakeLists.txt` |
| Config | `.env.example`, `config/`, `settings/`, `*.config.js`, `*.config.ts` |
| Docker | `Dockerfile`, `docker-compose.yml`, `.dockerignore` |
| CI/CD | `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `.circleci/`, `azure-pipelines.yml` |
| IaC | `terraform/`, `pulumi/`, `cloudformation/`, `k8s/`, `helm/` |
| Database | `migrations/`, `schema.sql`, `prisma/`, `alembic/`, `db/` |
| Entry Points | `main.*`, `index.*`, `app.*`, `server.*`, `cli.*`, `src/main.*`, `src/index.*` |
| Tests | `test/`, `tests/`, `__tests__/`, `spec/`, `*_test.*`, `*.spec.*` |
| Security | `.env`, `secrets/`, `credentials/`, `.npmrc`, `.pypirc` |

### Step 0.5: Write Phase 0 Artifacts

**Write `./strategy/repo-map.md`**:
```markdown
# Repository Map

## Basic Info
- **Name**: {repo name}
- **Path**: {absolute path}
- **Git Status**: {branch, clean/dirty}
- **Default Branch**: {main/master/unknown}

## Directory Tree
```
{tree output, depth 4, excluding node_modules/.git/etc}
```

## Key Files Identified
| Category | File | Status |
|----------|------|--------|
| README | README.md | Found |
| Package | package.json | Found |
| Docker | Dockerfile | Not Found |
...
```

**Write `./strategy/inspected-files.md`**:
```markdown
# Inspected Files

Files read during analysis (Phase 0 + Phase 1):

## Phase 0 - Intake
- [x] `./README.md`
- [x] `./package.json`
- [ ] `./Dockerfile` (not found)
...

## Phase 1 - Agent Analysis
(Updated by each agent)
```

---

## Phase 1 — Multi-Agent Analysis

Run ALL agents below. Each agent MUST:
1. List files/directories it inspected (with paths)
2. Report findings with evidence citations (file:line)
3. Provide risks (with severity) and recommendations
4. Write its report to the specified file

---

### Agent A — Architect (System & Code Structure)

**Inspect**: Entry points, module directories, dependency files, import graphs

**Analyze**:
- Architecture style (monolith, microservices, modular monolith, serverless)
- Module boundaries and responsibilities
- Dependency graph (external deps, internal module deps)
- Layering violations (presentation → business → data)
- Coupling hotspots (files with many imports)
- Tech debt concentration areas
- Unclear ownership zones

**Write `./strategy/agent-architect.md`**:
```markdown
# Agent A: Architect Report

## Files Inspected
- `./src/index.ts`
- `./src/modules/`
...

## Architecture Style
**Type**: {monolith/microservices/etc.}
**Evidence**: {path:line or description}

## Module Map
| Module | Path | Responsibility | Key Dependencies |
|--------|------|----------------|------------------|

## Dependency Analysis
### External Dependencies
{count} dependencies — Evidence: {package.json/etc.}

### Internal Coupling
| File | Imports | Imported By | Coupling Score |
|------|---------|-------------|----------------|

## Layering Assessment
- Presentation Layer: {path}
- Business Layer: {path}
- Data Layer: {path}
- Violations: {list or "None found"}

## Tech Debt Hotspots
| Location | Issue | Severity | Evidence |
|----------|-------|----------|----------|

## Recommendations
1. {recommendation} — Priority: {High/Med/Low}
...

## Risks Identified
| Risk | Impact | Likelihood | Evidence |
|------|--------|------------|----------|
```

---

### Agent B — Product/UX (Value, Use Cases, Docs)

**Inspect**: README, docs/, examples/, API docs, CLI help, UI components

**Analyze**:
- Problem statement and target users
- Primary use cases and user journeys
- How to run locally (documented vs actual)
- Documentation completeness
- Missing product artifacts (examples, screenshots, tutorials)

**Write `./strategy/agent-product.md`**:
```markdown
# Agent B: Product Report

## Files Inspected
- `./README.md`
- `./docs/`
...

## Product Overview
**Problem Solved**: {description}
**Evidence**: {path} or **Unknown**

**Target Users**: {audience}
**Evidence**: {path} or **Unknown**

## Use Cases
| Use Case | Documented | Evidence |
|----------|------------|----------|
| {use case 1} | Yes/No | {path} |

## Local Run Instructions
**Documented**: Yes/No/Partial — {path}
**Verified Steps**:
```bash
{actual commands that work}
```
**Gaps**: {what's missing or wrong}

## Documentation Assessment
| Document | Status | Quality | Gap |
|----------|--------|---------|-----|
| README | Present | Good | Missing install steps |
| API Docs | Missing | - | Create OpenAPI spec |

## Missing Artifacts
- [ ] Example usage code
- [ ] Screenshots/demos
- [ ] API documentation
- [ ] Tutorials

## Recommendations
1. {recommendation}
...
```

---

### Agent C — Security (Threats, Secrets, AuthZ/AuthN)

**Inspect**: .env*, config files, auth modules, API routes, dependencies, lockfiles

**Analyze**:
- Secrets in repo (API keys, passwords, tokens)
- Unsafe configurations (debug mode, permissive CORS)
- Dependency vulnerabilities
- Authentication implementation
- Authorization/permission boundaries
- OWASP Top 10 risk areas

**Write `./strategy/agent-security.md`**:
```markdown
# Agent C: Security Report

## Files Inspected
- `./config/`
- `./.env.example`
- `./src/auth/`
...

## Secrets Scan
| Finding | File | Line | Severity | Action Required |
|---------|------|------|----------|-----------------|
| Hardcoded API key | config.js | 42 | Critical | Remove + rotate |
| .env in repo | .env | - | Critical | Add to .gitignore |

## Dependency Vulnerabilities
**Scan Command**: `npm audit` / `pip-audit` / `cargo audit`
**Results**:
| Package | Vulnerability | Severity | Fix |
|---------|---------------|----------|-----|

## Authentication Assessment
**Method**: {JWT/session/OAuth/API key/none}
**Evidence**: {path:line}
**Issues**:
- {issue 1}

## Authorization Assessment
**Model**: {RBAC/ABAC/none}
**Evidence**: {path}
**Issues**:
- {issue 1}

## OWASP Top 10 Check
| Risk | Status | Evidence | Mitigation |
|------|--------|----------|------------|
| A01 Broken Access Control | At Risk | {path} | Add middleware |
| A02 Cryptographic Failures | OK | - | - |
| A03 Injection | Unknown | - | Review inputs |
...

## Recommendations
1. {recommendation} — Severity: {Critical/High/Med/Low}
...
```

---

### Agent D — Reliability/Operations (Deployability & Observability)

**Inspect**: Dockerfile, CI configs, deployment scripts, logging, health endpoints

**Analyze**:
- Deployment method and environments
- Configuration management
- Logging, metrics, tracing
- Health checks
- Failure modes and recovery
- Runbooks existence

**Write `./strategy/agent-ops.md`**:
```markdown
# Agent D: Operations Report

## Files Inspected
- `./Dockerfile`
- `./.github/workflows/`
- `./docker-compose.yml`
...

## Deployment
**Method**: {Docker/K8s/serverless/manual/Unknown}
**Evidence**: {path}

**Environments**:
| Environment | Configured | Evidence |
|-------------|------------|----------|
| Development | Yes | docker-compose.yml |
| Staging | Unknown | - |
| Production | Unknown | - |

## Configuration Management
**Method**: {env vars/config files/secrets manager}
**Evidence**: {path}
**Issues**:
- {issue}

## Observability
| Aspect | Status | Evidence | Gap |
|--------|--------|----------|-----|
| Structured Logging | No | src/logger.ts | Add JSON format |
| Metrics | Missing | - | Add Prometheus |
| Tracing | Missing | - | Add OpenTelemetry |
| Error Tracking | Missing | - | Add Sentry |

## Health Checks
**Endpoint**: {/health or Missing}
**Evidence**: {path}

## Failure Modes
| Scenario | Handled | Evidence | Recommendation |
|----------|---------|----------|----------------|
| DB connection lost | No | - | Add retry logic |
| Memory exhaustion | No | - | Add limits |

## Runbooks
**Status**: {Present/Missing}
**Location**: {path or "Create ./docs/runbooks/"}

## Recommendations
1. {recommendation}
...
```

---

### Agent E — Performance (Bottlenecks & Scalability)

**Inspect**: Database queries, API handlers, data processing, caching, async patterns

**Analyze**:
- Hot paths identification
- Database access patterns (N+1, missing indexes)
- Caching strategy
- Async/concurrent usage
- Resource usage hints

**Write `./strategy/agent-performance.md`**:
```markdown
# Agent E: Performance Report

## Files Inspected
- `./src/api/`
- `./src/db/`
...

## Hot Paths
| Path | Location | Frequency | Complexity | Risk |
|------|----------|-----------|------------|------|
| User lookup | api/users.ts:45 | High | O(1) | Low |
| Report generation | api/reports.ts:120 | Medium | O(n²) | High |

## Database Patterns
| Pattern | Location | Issue | Fix |
|---------|----------|-------|-----|
| N+1 Query | api/orders.ts:67 | Loop fetches | Use JOIN/batch |
| Missing Index | - | Unknown | Run EXPLAIN |
| No Connection Pool | db/index.ts | Single conn | Add pooling |

## Caching Assessment
**Current Strategy**: {none/in-memory/Redis/CDN}
**Evidence**: {path}
**Gaps**:
- {gap 1}

## Async Usage
**Pattern**: {callbacks/promises/async-await}
**Issues**:
| Location | Issue | Fix |
|----------|-------|-----|
| api/sync.ts:34 | Blocking call | Make async |

## Resource Usage
| Resource | Current | Recommendation |
|----------|---------|----------------|
| Memory | Unknown | Add monitoring |
| CPU | Unknown | Profile hot paths |
| Connections | Unbounded | Add limits |

## Benchmarks to Run
```bash
# Load test
{command}

# Profile hot path
{command}
```

## Recommendations
1. {recommendation}
...
```

---

### Agent F — Quality (Testing, CI, Release)

**Inspect**: Test directories, CI configs, coverage reports, linting config

**Analyze**:
- Test coverage and types
- CI pipeline completeness
- Static analysis configuration
- Release process
- Versioning strategy

**Write `./strategy/agent-quality.md`**:
```markdown
# Agent F: Quality Report

## Files Inspected
- `./tests/`
- `./.github/workflows/`
- `./.eslintrc`
...

## Test Coverage
| Type | Present | Location | Coverage | Quality |
|------|---------|----------|----------|---------|
| Unit | Yes/No | tests/unit/ | ~60% | Good |
| Integration | Yes/No | tests/integration/ | 0% | - |
| E2E | Yes/No | tests/e2e/ | 0% | - |

**Coverage Report**: {path or "Not configured"}

## CI Pipeline
**Platform**: {GitHub Actions/GitLab CI/Jenkins/None}
**Evidence**: {path}

| Stage | Configured | Evidence |
|-------|------------|----------|
| Lint | Yes/No | {path} |
| Type Check | Yes/No | {path} |
| Unit Tests | Yes/No | {path} |
| Integration Tests | Yes/No | {path} |
| Build | Yes/No | {path} |
| Deploy | Yes/No | {path} |

## Static Analysis
| Tool | Configured | Evidence | Issues |
|------|------------|----------|--------|
| ESLint/Pylint | Yes/No | {path} | {count} |
| TypeScript | Yes/No | tsconfig.json | strict: false |
| Prettier | Yes/No | {path} | - |

## Release Process
**Method**: {manual/CI automated/semantic-release}
**Evidence**: {path}

**Versioning**: {semver/calver/none}
**Evidence**: {package.json version field}

**Changelog**: {manual/auto-generated/missing}
**Evidence**: {CHANGELOG.md}

## Recommendations
1. {recommendation}
...
```

---

### Agent G — DX (Developer Experience)

**Inspect**: Setup scripts, package scripts, Makefile, devcontainer, IDE configs

**Analyze**:
- Local setup friction
- Available scripts and commands
- Development tooling
- Consistency enforcement
- Onboarding experience

**Write `./strategy/agent-dx.md`**:
```markdown
# Agent G: DX Report

## Files Inspected
- `./package.json` (scripts)
- `./Makefile`
- `./.vscode/`
...

## Setup Friction
**Steps to First Run**: {count}
**Prerequisites**: {list}
**Estimated Onboarding Time**: {X minutes/hours}

**Actual Setup Commands**:
```bash
{verified steps}
```

**Pain Points**:
- {pain point 1}

## Available Scripts
| Script | Command | Purpose | Works |
|--------|---------|---------|-------|
| dev | npm run dev | Start dev server | Yes |
| test | npm test | Run tests | Yes |
| build | npm run build | Production build | Yes |

## Development Tooling
| Tool | Present | Evidence | Gap |
|------|---------|----------|-----|
| Hot Reload | Yes/No | {path} | - |
| Debugging | Yes/No | .vscode/launch.json | Missing |
| DevContainer | Yes/No | .devcontainer/ | Missing |

## Consistency Enforcement
| Check | When | Evidence |
|-------|------|----------|
| Lint | CI only | .github/workflows |
| Format | Pre-commit | .husky/pre-commit |
| Type Check | CI only | - |

## IDE Configuration
| IDE | Config Present | Evidence |
|-----|----------------|----------|
| VS Code | Yes/No | .vscode/ |
| JetBrains | Yes/No | .idea/ |

## Recommendations
1. {recommendation}
...
```

---

## Phase 2 — Synthesis

After all agents complete, produce the integrated strategy documents.

---

### Write `./strategy/strategy.md`

```markdown
# Strategy Report

**Repository**: {name}
**Generated**: {timestamp}
**Analyzed By**: Claude Code Multi-Agent Strategy

---

## 1. Repo Snapshot

**Purpose**: {one-line description}
**Evidence**: {README.md path}

**Primary Stack**:
- Language: {language}
- Framework: {framework}
- Evidence: {package.json/etc.}

**How to Run Locally**:
```bash
{verified commands}
```

**Deployment**: {method} — Evidence: {path} or **Unknown**

**Architecture Overview**:
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   {Layer}   │ ──▶ │   {Layer}   │ ──▶ │   {Layer}   │
└─────────────┘     └─────────────┘     └─────────────┘
```

**Module Map**:
| Module | Path | Responsibility |
|--------|------|----------------|

---

## 2. Key Risks & Gaps (Top 10)

| # | Risk | Impact | Likelihood | Evidence | Suggested Fix |
|---|------|--------|------------|----------|---------------|
| 1 | {risk} | High | High | {path:line} | {fix} |
| 2 | {risk} | High | Medium | {path} | {fix} |
...

---

## 3. Opportunities

### Quick Wins (≤2 days each)
| Opportunity | Outcome | Effort | Files |
|-------------|---------|--------|-------|

### Medium Bets (≤2 weeks)
| Opportunity | Outcome | Effort | Tradeoffs |
|-------------|---------|--------|-----------|

### Big Bets (Multi-week)
| Opportunity | Outcome | Effort | Risks |
|-------------|---------|--------|-------|

---

## 4. Roadmap

See `./strategy/roadmap.md` for detailed plans.

### 2-Week Summary
- Week 1: {theme}
- Week 2: {theme}

### 6-Week Summary
- Weeks 1-2: {milestone}
- Weeks 3-4: {milestone}
- Weeks 5-6: {milestone}

---

## 5. Prioritized Backlog

See `./strategy/backlog.md` for full backlog.

**Top 5 Items**:
| # | Item | Priority Score |
|---|------|----------------|
| 1 | {item} | 2.5 |
...

---

## 6. Concrete Next Actions

### Commands to Run Now
```bash
# 1. {description}
{command}

# 2. {description}
{command}
```

### Files to Edit First
1. `{path}` — {reason}
2. `{path}` — {reason}

### First 3 PRs

**PR 1: {Title}**
- Scope: {description}
- Files: {list}
- DoD: {criteria}

**PR 2: {Title}**
- Scope: {description}
- Files: {list}
- DoD: {criteria}

**PR 3: {Title}**
- Scope: {description}
- Files: {list}
- DoD: {criteria}

---

## 7. Questions & Assumptions

### Questions to Confirm
1. {question}
   - Why: {impact}
   - Assumption if unanswered: {default}

### Standing Assumptions
1. {assumption}
2. {assumption}

---

## Agent Reports

| Agent | Report | Key Finding |
|-------|--------|-------------|
| Architect | [agent-architect.md](./agent-architect.md) | {finding} |
| Product | [agent-product.md](./agent-product.md) | {finding} |
| Security | [agent-security.md](./agent-security.md) | {finding} |
| Operations | [agent-ops.md](./agent-ops.md) | {finding} |
| Performance | [agent-performance.md](./agent-performance.md) | {finding} |
| Quality | [agent-quality.md](./agent-quality.md) | {finding} |
| DX | [agent-dx.md](./agent-dx.md) | {finding} |
```

---

### Write `./strategy/backlog.md`

```markdown
# Prioritized Backlog

**Generated**: {timestamp}

## Scoring
- **Impact**: 1 (Low) to 5 (Critical)
- **Effort**: 1 (Hours) to 5 (Weeks)
- **Priority**: Impact / Effort (higher = do first)

## Backlog

| # | Item | Impact | Effort | Priority | Deps | Owner | Evidence |
|---|------|--------|--------|----------|------|-------|----------|
| 1 | {item} | 5 | 2 | 2.50 | - | Security | {path} |
| 2 | {item} | 4 | 2 | 2.00 | - | Quality | {path} |
| 3 | {item} | 4 | 3 | 1.33 | #1 | Architect | {path} |
...

## By Owner Role

### Security
- [ ] #{n}: {item}

### Quality
- [ ] #{n}: {item}

### Architect
- [ ] #{n}: {item}

### Operations
- [ ] #{n}: {item}

### DX
- [ ] #{n}: {item}
```

---

### Write `./strategy/roadmap.md`

```markdown
# Roadmap

**Generated**: {timestamp}

---

## 2-Week Plan (Execution-Ready)

### Week 1: {Theme}

**Milestone**: {description}

**Deliverables**:
- [ ] {deliverable 1}
- [ ] {deliverable 2}

**PR Slicing**:
| PR | Title | Scope | Files | Depends On |
|----|-------|-------|-------|------------|
| 1 | {title} | {scope} | {files} | - |
| 2 | {title} | {scope} | {files} | PR 1 |

**Acceptance Criteria**:
- [ ] {criterion}
- [ ] {criterion}

---

### Week 2: {Theme}

**Milestone**: {description}

**Deliverables**:
- [ ] {deliverable 1}
- [ ] {deliverable 2}

**PR Slicing**:
| PR | Title | Scope | Files | Depends On |
|----|-------|-------|-------|------------|

**Acceptance Criteria**:
- [ ] {criterion}

---

## 6-Week Plan (Staged Evolution)

| Week | Phase | Milestone | Key Deliverables | Dependencies | Risk Addressed |
|------|-------|-----------|------------------|--------------|----------------|
| 1-2 | Foundation | {milestone} | {deliverables} | None | Quality |
| 3-4 | Hardening | {milestone} | {deliverables} | Foundation | Security |
| 5-6 | Scale | {milestone} | {deliverables} | Hardening | Performance |

### Phase Details

#### Weeks 1-2: Foundation
{description}

#### Weeks 3-4: Hardening
{description}

#### Weeks 5-6: Scale
{description}

---

## Risk Burndown

| Week | Risks Remaining | Key Risk Addressed |
|------|-----------------|-------------------|
| 0 | 10 | - |
| 2 | 7 | {risk} |
| 4 | 4 | {risk} |
| 6 | 2 | {risk} |
```

---

## Final Step — Print Index

After writing all files, print:

```bash
echo ""
echo "=== Strategy Analysis Complete ==="
echo "Generated files:"
ls -la ./strategy/
echo ""
echo "Start with: cat ./strategy/strategy.md"
```

**Expected Output**:
```
./strategy/
├── .timestamp
├── repo-map.md
├── inspected-files.md
├── agent-architect.md
├── agent-product.md
├── agent-security.md
├── agent-ops.md
├── agent-performance.md
├── agent-quality.md
├── agent-dx.md
├── strategy.md
├── backlog.md
└── roadmap.md
```

---

## Execution Flags (Optional)

| Flag | Behavior |
|------|----------|
| `--quick` | Phase 0 + Agents A,F,G only |
| `--security` | Full Phase 0-1, prioritize Agent C |
| `--dx` | Full Phase 0-1, prioritize Agent G |
| `--deep` | Extended analysis, all agents with opus |

Default: Standard (all agents, balanced depth)

---

## Start Now

1. Run **Phase 0** — create `./strategy/`, gather repo context
2. Run **Phase 1** — execute all 7 agents, write individual reports
3. Run **Phase 2** — synthesize into strategy.md, backlog.md, roadmap.md
4. Print file index

Begin Phase 0 immediately.
