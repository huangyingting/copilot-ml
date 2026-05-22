# Module 9 — Roles, RACI & Spec Sizing

Two questions the requirement list called out and the original curriculum did not formally answer:

1. **Who writes the spec?** For this program the answer is: **the data engineer drives `/speckit.specify` (or the lightweight spec). The tech lead reviews. No agent ships code from an un-reviewed spec.**
2. **How big should a spec be?** Use the sizing table in §2 to choose between a lightweight markdown spec and a full Spec Kit `/speckit.*` flow.

---

## 1. RACI for spec-driven work

Use this as the default. Replace role names with your team's actual titles.

| Activity | Data engineer (DE) | Tech lead / reviewer | SRE / on-call | Product / analyst | Copilot |
|---|---|---|---|---|---|
| Frame the problem (one-liner) | **R** | C | I | C | — |
| Draft the spec (`/speckit.specify` or `specs/templates/*`) | **R / A** | C | C | C | assist |
| Clarify (`/speckit.clarify`) | **R** | A | C | C | assist |
| Approve spec → `reviewed` | C | **R / A** | C | I | — |
| Plan the implementation (Plan Mode or `/speckit.plan`) | **R** | A | C | I | assist |
| Approve plan → start work | C | **R / A** | I | I | — |
| Implement (Agent Mode / `/speckit.implement` / Cloud Agent) | **R** | C | I | I | execute |
| Code review | C | **R / A** | C | I | assist |
| Deployment / promotion | C | A | **R** | I | — |
| Runbook / alert updates | C | C | **R / A** | I | assist |
| Post-merge verification | **R** | C | A | I | — |
| Archive spec → `built` | **R** | C | I | I | — |

**R** = Responsible, **A** = Accountable, **C** = Consulted, **I** = Informed.

Key rules:

- The DE owns the spec. They are closest to the data, the pipeline, and the consumers. Asking a non-DE to write the spec for a DE task wastes the AI's most valuable input.
- The tech lead is the **only** gate from `draft` → `reviewed`. Without that gate, Agent Mode and Cloud Agent will happily implement an ambiguous spec.
- SRE owns runbook and alert changes even when the spec is DE-authored.
- Copilot never owns a row. It assists at every "R" cell.

## 2. Spec sizing — XS / S / M / L

Use a t-shirt size in the spec header. The size picks the workflow.

| Size | Effort | Files touched | Workflow |
|---|---|---|---|
| **XS** | ≤ ½ day | 1–2 | Inline chat or Ask Mode, no spec file required. A PR description is the spec. |
| **S** | ½ – 2 days | ≤ 5 | Lightweight markdown spec (`specs/templates/*`) + Plan Mode + Agent Mode |
| **M** | 2 – 5 days | 5 – 15 | Lightweight spec **or** Spec Kit `/speckit.specify → clarify → plan → tasks → implement` if work spans multiple modules / models |
| **L** | > 5 days, or > 1 sprint, or > 15 files | many | **Always** use Spec Kit. Add `/speckit.constitution` for the project, `/speckit.analyze` before `/speckit.implement`, and split into multiple S/M specs that each ship independently. |

Heuristics:

- If you can't list the in-scope files in your spec, it is too big. Split.
- If the spec has more than 3 open questions, it is not ready. Send back for clarification before planning.
- If the implementation plan is more than ~10 numbered steps, split the spec.
- A refactor spec that needs more than one PR to ship is an **L** by definition.

## 3. Who picks the tool

| Situation | Tool | Driver |
|---|---|---|
| Quick fact-find about the codebase | Ask Mode | DE |
| Single-PR change with non-trivial design | Plan Mode → Agent Mode | DE |
| Multi-PR feature, several models / DAGs / endpoints | Spec Kit `/speckit.*` | DE drives, lead reviews |
| Issue suitable for async work, well-bounded | Cloud Agent (GitHub-hosted) | DE drafts the issue, lead approves |
| Deployment / promotion to prod | Human + workflow | SRE |

## 4. Spec lifecycle

`draft` → `reviewed` → `built` → `archived`

- Status lives in the spec header.
- A `draft` spec is invisible to agents — link it manually if you want feedback.
- A `reviewed` spec can be referenced from prompts and Cloud Agent issues.
- A `built` spec is moved to the matching PR description and stays in `specs/<area>/` as history.
- An `archived` spec moves under `specs/archive/<year>/` so the live folder stays small.

## 5. Anti-patterns

- DE writes the spec, lead "rubber-stamps" without reading. The lead's approval is the safety gate; treat it that way.
- Spec written by the product analyst, handed to DE with no clarification round. Always run `/speckit.clarify` (or a 10-min review) before planning.
- Agent Mode invoked against a `draft` spec to "see what it comes up with". This is how scope creep starts. Move to `reviewed` first.
- L-sized work jammed into a single lightweight spec. Always split.
- Bug spec missing the reproduction step. Don't let an agent guess the root cause.

## 6. See also

- [08-spec-driven-development.md](08-spec-driven-development.md) — lightweight spec flow
- [10-plan-mode-vs-speckit-and-landscape.md](10-plan-mode-vs-speckit-and-landscape.md) — when to use which planning surface
- [../specs/templates/](../specs/templates/) — copy-ready feature / bugfix / refactor templates

---

> **Next:** [Module 10 — Plan Mode vs Spec Kit & the SDD Landscape](10-plan-mode-vs-speckit-and-landscape.md)
> **Back:** [Module 8 — Spec-Driven Development](08-spec-driven-development.md)
