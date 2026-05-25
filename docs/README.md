# Copilot Training — Module Index

This folder is the full curriculum for the **copilot-ml** training program. It is delivered around a small FastAPI + Azure Container Apps demo, with a parallel data-engineering track in [Module 14](14-data-engineering-track.md) for DE audiences.

Each module is one Markdown file, ~20–60 minutes of reading, paired with a hands-on lab in [Module 15](15-workshop-and-labs.md).

---

## Reading order at a glance

```text
Part A — Foundations
  00 Prerequisites           01 Day 1 with Copilot

Part B — Core mental models
  02 The Three Modes         03 Pick the Right Model

Part C — Customize Copilot
  04 Instructions, Prompts & Hooks    05 Agents, Skills & MCP
  06 Skills Portfolio & Packaging     07 Sub-agents & Orchestration

Part D — Spec-Driven Development
  08 Spec-Driven Development          09 Roles, RACI & Spec Sizing
  10 Plan Mode vs Spec Kit & Landscape

Part E — Working safely with Agent Mode
  11 Agent Mode Adoption Checklist

Part F — Other Copilot surfaces
  12 Copilot CLI             13 GitHub Cloud Agent

Part G — Audience track
  14 Data Engineering Track  (use instead of / alongside the FastAPI demo)

Part H — Delivery
  15 Workshop & Labs
```

---

## Full module map

### Part A — Foundations

| # | Module | Read | Why it's here |
|---|---|---|---|
| 00 | [Prerequisites](00-prerequisites.md) | 10 min | Get the demo running, sign in, confirm Copilot works. |
| 01 | [Day 1 with Copilot](01-day-1-with-copilot.md) | 20 min | Inline suggestions and the chat panel — the bare minimum to be productive on day one. |

### Part B — Core mental models

| # | Module | Read | Why it's here |
|---|---|---|---|
| 02 | [The Three Modes](02-three-modes.md) | 25 min | Ask vs Plan vs Agent — choosing the right mode is the single biggest quality lever. |
| 03 | [Pick the Right Model](03-pick-the-right-model.md) | 25 min | Cost / capability trade-offs across model families. |

### Part C — Customize Copilot

| # | Module | Read | Why it's here |
|---|---|---|---|
| 04 | [Instructions, Prompt Files & Hooks](04-customize-instructions-prompts-and-hooks.md) | 35 min | The lightweight customizations every repo should have. Starts with a one-page anatomy of `.github/`. |
| 05 | [Custom Agents, Skills & MCP](05-customize-agents-skills-mcp.md) | 45 min | The heavier customizations — personas, multi-step capabilities, external systems. |
| 06 | [Skills Portfolio, Packaging & Sharing](06-skills-and-plugins.md) | 25 min | The skills inventory in this repo, plus `plugin.json` packaging, marketplaces, Git-URL installs, and local-path trials. |
| 07 | [Sub-agents & Orchestration Patterns](07-subagents-and-orchestration.md) | 25 min | Coordinator/worker, multi-perspective review, planner→implementer→reviewer, recursive divide-and-conquer. |

### Part D — Spec-Driven Development

| # | Module | Read | Why it's here |
|---|---|---|---|
| 08 | [Spec-Driven Development](08-spec-driven-development.md) | 40 min | Lightweight specs + GitHub Spec Kit. The biggest quality jump after Agent Mode itself. |
| 09 | [Roles, RACI & Spec Sizing](09-roles-and-spec-sizing.md) | 15 min | Who writes the spec, who reviews, and how to pick XS / S / M / L. |
| 10 | [Plan Mode vs Spec Kit & the SDD Landscape](10-plan-mode-vs-speckit-and-landscape.md) | 20 min | Plan Mode and `/speckit.plan` are not the same thing. Plus a tour of Kiro, Cursor, Aider, and the wider landscape. |

### Part E — Working safely with Agent Mode

| # | Module | Read | Why it's here |
|---|---|---|---|
| 11 | [Agent Mode Adoption Checklist](11-agent-mode-checklist.md) | 10 min | Print-and-pin checklist for any Agent Mode session that will merge code. |

### Part F — Other Copilot surfaces

| # | Module | Read | Why it's here |
|---|---|---|---|
| 12 | [Copilot CLI](12-copilot-cli.md) | 30 min | The terminal binary — same agents and skills, scriptable, schedulable. |
| 13 | [GitHub Cloud Agent](13-github-cloud-agent.md) | 30 min | Async issue-to-PR and report-only workflows. |

### Part G — Audience track

| # | Module | Read | Why it's here |
|---|---|---|---|
| 14 | [Data Engineering Track](14-data-engineering-track.md) | 30 min | Stack swap and lab re-skin for dbt / PySpark / Airflow / warehouse SQL audiences. |

### Part H — Delivery

| # | Module | Read | Why it's here |
|---|---|---|---|
| 15 | [Workshop & Labs](15-workshop-and-labs.md) | hands-on | 13 labs mapped to the modules above. |

---

## Two-day workshop reading guide

| Slot | Modules | Lab |
|---|---|---|
| Day 1 morning | 00, 01, 02 | Lab 1 — Project orientation; Lab 2 — Ask, Plan, Agent |
| Day 1 afternoon | 03, 04, 05 | Lab 4 — Custom agent; Lab 5 — Native-first escalation |
| Day 2 morning | 06, 07, 08, 09 | Lab 6 — Skill review; Lab 3 / 3B — Spec authoring |
| Day 2 afternoon | 10, 11, 12, 13 | Lab 12 — CLI; Lab 8 — Cloud Agent; Lab 13 — Report-only |
| Wrap | 14 (if DE audience), 15 | Lab 10 — Pilot planning |

---

## Self-study reading guide

If you have ~2 hours, read 02, 04, 05, 08, 11 — the highest-leverage modules.

If you have ~1 day, add 03, 06, 07, 09, 10, 12.

Reserve the full ~2 days for the workshop or before running a customer pilot.

---

## Conventions

- Each module ends with a **Next / Back** pair so you can read end-to-end.
- All links inside `docs/` are relative; safe to render on GitHub or in any Markdown viewer.
- The demo project lives at the repo root (`app/`, `tests/`, `infra/`, `.github/`); modules reference real files there rather than abstract examples.
- The DE track in Module 14 swaps the FastAPI examples for dbt / PySpark / warehouse examples — the Copilot pattern is identical; only the artifact changes.

For the higher-level pitch and roadmap, see the top-level [README.md](../README.md).
