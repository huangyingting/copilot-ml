---
marp: true
title: GitHub Copilot for Data Engineers — Workshop
theme: default
paginate: true
size: 16:9
---

<!-- Render with: `npx @marp-team/marp-cli@latest workshop-deck.md --pdf` -->
<!-- See docs/ for the long-form material; this deck is the speaker's spine. -->

# GitHub Copilot for Data Engineers
## A one-day, spec-first, safety-first workshop

<small>Maintained alongside the `copilot-ml` training repo</small>

---

# Why we're here

- Move data engineers from "Copilot completes my SQL" to **Copilot drives a reviewed spec, a planned change, and a safe PR**.
- Same tools, very different blast radius from app code: **warehouses, jobs, data**.
- One day. Six modules. One pilot task per learner by 16:00.

---

# Agenda

1. The three modes — Ask / Plan / Agent
2. Picking the right model (and the right cost)
3. Customizing Copilot in `.github/` and `AGENTS.md`
4. Spec-driven development — lightweight specs + Spec Kit
5. Agents, skills, sub-agents
6. From pilot to playbook

---

# Module 1 — The three modes

| Mode | When | Output |
|---|---|---|
| **Ask** | "What does this query do?" | Explanation in chat |
| **Plan** | "How should I add late-arriving handling to fct_orders?" | A plan, no files touched |
| **Agent** | "Implement the reviewed plan" | Files changed, tests run |

**Rule.** Never skip Plan for anything that touches more than one file.

→ see [`docs/02-three-modes.md`](../docs/02-three-modes.md)

---

# Module 1 — Mode anti-patterns

- "Just go" in Agent Mode for an unbounded task → ⚠️ 40-file diff
- Ask Mode used to write code → use Inline Chat or Agent
- Plan Mode used as a chat journal → save the plan to a spec, then move on
- Agent Mode against an unreviewed `draft` spec → scope creep

---

# Module 2 — Picking the right model

- Cheap models: cleanups, renames, f-strings, `EXPLAIN` summaries
- Mid models: SQL rewrites, dbt model authoring, test design
- Premium reasoning: refactors, long notebooks, plan-of-record specs

**Rule of thumb.** Premium models pay for themselves when blast radius is high.

→ see [`docs/03-pick-the-right-model.md`](../docs/03-pick-the-right-model.md)

---

# Module 3 — Customizing Copilot

| Folder | What it does |
|---|---|
| `copilot-instructions.md` / `AGENTS.md` | Always-on rules |
| `.github/instructions/` | File-scoped rules (`applyTo`) |
| `.github/prompts/` | Slash commands for tasks |
| `.github/agents/` | Personas + tool restrictions |
| `.github/skills/` | Portable, multi-file capabilities |
| `.github/hooks/` | Lifecycle scripts |

→ see [`docs/04-customize-instructions-prompts-and-hooks.md`](../docs/04-customize-instructions-prompts-and-hooks.md)

---

# Module 3 — The decision flow

- Project-wide rule? → `copilot-instructions.md` / `AGENTS.md`
- File-scoped rule? → `*.instructions.md` with `applyTo`
- One-shot task? → `*.prompt.md`
- Persistent persona with handoffs? → `*.agent.md`
- Reusable capability with scripts/refs? → `SKILL.md`
- Lifecycle gate? → `hooks/hooks.json`

---

# Module 4 — Spec-driven development

Lightweight spec → reviewed → plan → implement → verify.

| Size | Tool |
|---|---|
| XS (≤ ½ day, 1–2 files) | Inline / Ask Mode, no spec |
| S (1 PR) | Lightweight template + Plan Mode |
| M (multi-day) | Lightweight or Spec Kit |
| L (multi-PR) | **Always** Spec Kit |

→ see [`docs/09-roles-and-spec-sizing.md`](../docs/09-roles-and-spec-sizing.md)

---

# Module 4 — Plan Mode vs Spec Kit

| | Plan Mode | Spec Kit |
|---|---|---|
| Install | built-in | `uv tool install specify-cli` |
| Output | session memory | files in `.specify/` |
| Persistence | ephemeral | versioned in Git |
| Best for | one-PR work | multi-PR features |

→ see [`docs/10-plan-mode-vs-speckit-and-landscape.md`](../docs/10-plan-mode-vs-speckit-and-landscape.md)

---

# Module 4 — Spec templates

Three copy-paste templates in [`specs/templates/`](../specs/templates/):

- `feature.spec.template.md`
- `bugfix.spec.template.md`
- `refactor.spec.template.md`

DE-flavored worked examples in [`specs/de/`](../specs/de/).

---

# Module 5 — Agents and skills

- **Custom agents** = personas + tool restrictions + handoffs (`.agent.md`)
- **Skills** = portable capabilities (`SKILL.md`), open standard, shared across tools
- **Sub-agents** = invoke another agent for a bounded task, fresh context

This repo ships:

- `api-platform-reviewer.agent.md` — API reviewer
- `data-pipeline-reviewer.agent.md` — DE reviewer (uses sub-agents)
- `api-observability-review`, `sql-cost-review`, `dq-test-review` skills

---

# Module 5 — Sub-agent patterns

1. **Coordinator / worker** — fan out one sub-agent per model in a big PR
2. **Multi-perspective review** — cost reviewer + DQ reviewer + PII scanner in parallel
3. **Planner → implementer → reviewer** — sequential pipeline
4. **Recursive divide-and-conquer** — sparingly; cost grows fast

→ see [`docs/11-agent-mode-checklist.md`](../docs/11-agent-mode-checklist.md)

---

# Module 5 — Packaging and sharing

- Bundle skills + agents + prompts + hooks + MCP into a **plugin** (`plugin.json`)
- Install from a marketplace, a Git URL, or a local path
- `npx`-style ad-hoc skill install for experiments
- Format is auto-detected — same plugin works in VS Code, Copilot CLI, Claude Code

→ see [`docs/06-skills-and-plugins.md`](../docs/06-skills-and-plugins.md)

---

# Module 6 — Pilot → playbook

- 6 sample pilot tasks for DE (S / M sizes) — late-arriving data, null-fix bugfix, notebook refactor, DQ SLO, freshness alert, top-10 SQL cleanup
- KPIs: PRs per DE per week, review-cycle time, % AI-assisted PRs, # of agent-caused incidents (target: 0)
- Handover: this repo + one team-owned customization repo + a weekly office hour

→ see [`docs/14-data-engineering-track.md`](../docs/14-data-engineering-track.md), [`docs/16-pilot-and-playbook.md`](../docs/16-pilot-and-playbook.md)

---

# Hard rules (read me before you ship)

- No live writes to prod data, prod warehouses, prod control planes.
- No real PII in prompts, fixtures, tests, examples.
- No `--no-verify`, no `git push --force` to shared branches.
- No `materialized: table` on > 1M rows without a stated reason.
- No `DROP`, `TRUNCATE`, `DELETE`-without-`WHERE` from an agent.

---

# Hands-on lab plan

| Time | Lab |
|---|---|
| 09:30 | Lab 1 — Day-1 with Copilot in a dbt project |
| 10:30 | Lab 2 — Source freshness check |
| 11:30 | Lab 3 — Draft a mart-model spec |
| 13:30 | Lab 4 — Add DE safety boundaries + DE prompts |
| 14:30 | Lab 5 — Build `data-pipeline-reviewer` + skills |
| 15:30 | Lab 6 — Spec Kit on a multi-model refactor |
| 16:00 | Each learner ships their pilot PR draft |

---

# What you take home

- A reviewed spec, a Plan Mode plan, and an AI-assisted PR you wrote today.
- A starter `.github/` for your team's repo (copy from this one).
- A pilot task picked from §5 of [`docs/14-data-engineering-track.md`](../docs/14-data-engineering-track.md) for week 1.
- An invitation to the weekly office hour.

---

# Questions

Repo: <`copilot-ml`>
Docs: `docs/`
DE track: [`docs/14-data-engineering-track.md`](../docs/14-data-engineering-track.md)
