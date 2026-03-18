# Strategy - Multi-Agent Repository Analysis

> Full implementation lives in the `strategy` skill (`~/.claude/skills/strategy/SKILL.md`).
> This command invokes the same workflow.

Comprehensive repository analysis using 7 specialist agents run in parallel, producing 12 structured reports in `./strategy/`.

## What It Produces

| File | Content |
|------|---------|
| repo-map.md | Repository structure and key files |
| inspected-files.md | All files read during analysis |
| agent-architect.md | Architecture and tech debt |
| agent-product.md | Product value and doc gaps |
| agent-security.md | Security vulnerabilities and risks |
| agent-ops.md | Deployment and observability |
| agent-performance.md | Bottlenecks and scalability |
| agent-quality.md | Testing and CI/CD |
| agent-dx.md | Developer experience |
| strategy.md | Integrated strategy report |
| backlog.md | Prioritized backlog with scoring |
| roadmap.md | 2-week and 6-week plans |

## Execution

Follow the `strategy` skill instructions exactly:
1. Setup output directory and gather repo context
2. Spawn all 7 agents **in parallel** (Architect, Product, Security, Ops, Performance, Quality, DX)
3. After all agents complete, synthesize into strategy.md, backlog.md, roadmap.md

## Guidelines

1. Every claim must cite `path:line`
2. Mark unverifiable items as **Unknown**
3. Prefer small PRs over big rewrites
4. All outputs in English
