# Module 10 — Plan Mode vs Spec Kit & the SDD Landscape

Copilot Plan Mode and GitHub Spec Kit are easy to mention together, but they solve different planning problems. This module puts them side by side and adds a brief look at the broader Spec-Driven Development (SDD) tooling landscape so the team knows what they are choosing between.

## 1. Plan Mode and `/speckit.plan` are not the same thing

Copilot **Plan Mode** is a built-in chat agent in VS Code (`/plan` or the agent picker). It is for single-conversation planning of a single change. The plan is saved to ephemeral session memory (`/memories/session/plan.md`) and is discarded when the chat ends. Source: [VS Code planning agent docs](https://code.visualstudio.com/docs/copilot/agents/planning).

Spec Kit **`/speckit.plan`** is a slash command that runs **after** `/speckit.specify` (and ideally `/speckit.clarify`). It writes a persistent `plan.md` (plus `data-model.md`, `contracts/`, `research.md`) into `.specify/specs/<feature>/` on disk, versioned in Git, reviewable in a PR, and consumed by `/speckit.tasks` and `/speckit.implement`. Source: [github/spec-kit README](https://github.com/github/spec-kit).

Side by side:

| Property | Copilot Plan Mode (`/plan`) | Spec Kit `/speckit.plan` |
|---|---|---|
| Trigger | Built-in chat agent, no install | Slash command installed by `specify init` |
| Inputs | One prompt + workspace context | A reviewed `spec.md` (and ideally `clarify` answers) and a `constitution.md` |
| Output | Markdown plan in chat + session-memory file | Files on disk under `.specify/specs/<id>/` |
| Persistence | Ephemeral (session memory cleared at end) | Versioned in Git |
| Review surface | Read in chat, optionally save | Pull request |
| Hand-off | "Start Implementation" button or follow-up prompt | `/speckit.tasks` then `/speckit.implement` |
| Tool restrictions | Inherited from chat | Configured via SpecKit prompt files / hooks |
| Best for | XS / S work, one PR, one head | M / L work, multi-PR, multi-author |
| Cost surface | One conversation | Multiple agent runs across the lifecycle |

Rule of thumb:

- **Plan Mode** = "plan this one PR before I let Agent Mode touch files."
- **Spec Kit** = "we are doing a real feature with multiple PRs across several days; the spec, the plan, and the task list deserve to live in Git."

Both can coexist on the same team and even the same person. For S work, Plan Mode is faster. For M/L work, the Git-versioned artifacts that Spec Kit produces pay off in review and onboarding.

## 2. The Spec Kit lifecycle, in one page

```
/speckit.constitution    →  .specify/memory/constitution.md       (project principles, written once)
/speckit.specify         →  .specify/specs/NNN-<name>/spec.md     (what + why, user stories, acceptance)
/speckit.clarify         →  updates spec.md with answered Qs       (recommended before plan)
/speckit.plan            →  plan.md + data-model.md + contracts/  (how, tech stack, architecture)
/speckit.tasks           →  tasks.md                              (dependency-ordered, parallel-marked)
/speckit.taskstoissues   →  GitHub issues                         (optional, for Cloud Agent / tracking)
/speckit.analyze         →  consistency report                    (run after tasks, before implement)
/speckit.implement       →  code, tests, edits                    (executes tasks.md)
/speckit.checklist       →  quality checklist                     ("unit tests for English")
```

Notes for our program:

- **Constitution = `.github/copilot-instructions.md` for SDD.** Treat it the same way: write once, reuse everywhere, edit rarely.
- `/speckit.clarify` is the cheapest quality gate in the flow. Skipping it is the #1 cause of bad plans.
- `/speckit.analyze` before `/speckit.implement` catches inconsistencies between `spec`, `plan`, and `tasks`. Use it on every M/L spec.
- The output lives under `.specify/`. Add it to your repo's review checklist — these files **are** the spec.

## 3. The wider SDD landscape (Q2 2026)

| Tool | Form factor | How it stores the spec | Strengths | Weaknesses | When to consider |
|---|---|---|---|---|---|
| **GitHub Spec Kit** | CLI + slash commands in any of 30+ AI agents | `.specify/` in Git | Open source (MIT), tool-agnostic, integrates with Copilot / Claude / Codex / Gemini / Cursor / others, 100K+ stars | CLI-first, manual setup, no visual UI | Default choice for this program |
| **Copilot Plan Mode** | Built-in VS Code agent | Ephemeral session memory | Zero install, fast, no ceremony | Not persistent, not shareable, no task graph | Single-PR planning |
| **Kiro IDE** (AWS) | Standalone IDE | `.kiro/specs/<feature>/{requirements,design,tasks}.md` | Visual spec + task UI, EARS-format requirements, file-save hooks | Separate IDE, vendor lock-in, smaller ecosystem | Greenfield, single-vendor shops |
| **Cursor "Composer / Specs"** | Cursor IDE | Project rules + chat-driven spec docs | Tight loop with Cursor's edit model | Cursor-only | Teams already on Cursor |
| **Aider** | Terminal | Git-tracked markdown specs (convention) | Strong git integration, model-agnostic | DIY workflow, no formal SDD commands | Solo or small teams who live in the terminal |
| **Anthropic Skills + Claude Code** | CLI + skills | `SKILL.md` bundles | Skills standard now shared with Copilot | Less prescriptive on the spec → plan → tasks split | Teams already invested in Claude Code |
| **In-house templates only** | Markdown in `specs/` | Git | Zero new tooling | No tool support for `/specify` / `/plan` / `/tasks` lifecycle | Pilots, training, very small teams |

### Trends to flag for the team

1. **Convergence around `.github/{prompts,agents,skills,hooks}` and `SKILL.md`.** Copilot, Claude Code, and Codex now share the same on-disk shape. Skills are portable across them. Lock to that shape — it survives tool changes.
2. **Plans and specs are becoming Git-tracked artifacts.** Both Spec Kit and Kiro write to disk; Plan Mode is the outlier with ephemeral plans. Treat ephemeral plans as drafts and persist anything that survives review.
3. **Constitutions / steering docs are now a first-class concept.** Spec Kit's `constitution.md` and Kiro's `.kiro/steering/` are the same idea: write principles once, let every command reference them. Our `copilot-instructions.md` is the prior art.
4. **Slash commands and skills are becoming installable units.** Spec Kit ships its commands as installable presets / extensions. Skills are packaged as plugins. The trend is: **share workflows like libraries**, not like documentation.
5. **Multi-agent (sub-agent) orchestration is moving from research to default.** See [Module 7 — Sub-agents & Orchestration Patterns](07-subagents-and-orchestration.md). SpecKit's "planner → architect → implementer → reviewer" pattern is the same coordinator/worker shape now standardized in VS Code subagents.

## 4. Recommendation for this program

- Default tool: **GitHub Spec Kit + Copilot in VS Code**.
- Use **Plan Mode** for XS/S work to keep the friction low.
- Treat Kiro and others as "good to know, don't depend on" unless the team chooses to standardize on one.
- Keep the lightweight `specs/templates/*` for the cases where Spec Kit's ceremony is more cost than value (bugfixes, small refactors).

## 5. See also

- [08-spec-driven-development.md](08-spec-driven-development.md) — lightweight spec flow
- [09-roles-and-spec-sizing.md](09-roles-and-spec-sizing.md) — who writes specs and how big they should be
- [github/spec-kit](https://github.com/github/spec-kit) — official Spec Kit repo
- [VS Code Plan agent docs](https://code.visualstudio.com/docs/copilot/agents/planning)

---

> **Next:** [Module 11 — Agent Mode Adoption Checklist](11-agent-mode-checklist.md)
> **Back:** [Module 9 — Roles, RACI & Spec Sizing](09-roles-and-spec-sizing.md)
