# Module 6 — Spec-Driven Development

Once Agent Mode and prompt files are habit, the next jump in code quality comes from a quieter change: writing down what you want *before* you ask Copilot to build it.

Without a spec, an Agent Mode session looks like this:

```text
vague intent → model's interpretation → 30 tool calls → PR → late review surprise
```

Because Copilot generates code five to ten times faster than people, the cost of clarifying things *after* the agent has already written them keeps going up. The fix is older than AI: write a short spec, review it, then implement against it. With AI in the loop, that habit pays off twice — once because the spec keeps you honest, and again because the agent executes it without you babysitting every turn.

This module covers two flavors of spec-driven development:

- **Lightweight specs.** A one-page Markdown file under `specs/`, written by hand or drafted with Plan Mode. Good for ~80% of work.
- **GitHub Spec Kit.** A formal CLI workflow — `constitution → specify → clarify → plan → tasks → analyze → implement` — with versioned artifacts. Good for greenfield features, big refactors, or anything that needs an audit trail.

The demo project ships with a starter spec at `specs/api-health-observability.spec.md`. The customer-safe scenario for the module is:

> Improve the existing `copilot-ml` API observability baseline without increasing Azure cost or adding live production dependencies.

The request is intentionally vague. The spec work is to make it reviewable.

Official references:

- [GitHub Spec Kit](https://github.com/github/spec-kit)
- [Get started with spec-driven development and GitHub Spec Kit (Microsoft Learn)](https://learn.microsoft.com/en-us/training/modules/spec-driven-development-github-spec-kit-greenfield-intro/)

---

## Why specs matter with Copilot

The shift is small but important:

| Without a spec | With a spec |
|---|---|
| The agent interprets a one-line prompt | The agent executes against agreed acceptance criteria |
| Scope drifts mid-session ("while I was there, I also…") | Scope drift gets caught at spec review, not PR review |
| Reviewers reconstruct intent from the diff | Reviewers compare the diff to the spec |
| "It works" means the tests the agent invented passed | "It works" means the criteria *you* wrote are met |

A short demonstration of the problem, using the demo project:

```text
We need better observability for this API. What is missing from this request before implementation?
Use app/main.py, tests/test_main.py, infra/bicep/main.bicep, and specs/api-health-observability.spec.md as context.
Do not edit files.
```

Expected response: "better observability" is not testable; the desired endpoint or alert behavior is unclear; cost guardrails must be preserved; Azure deployment must stay human-approved; rollback and cleanup are not stated. That list *is* the start of a spec.

---

## The lightweight spec workflow

Use lightweight specs for work that fits in one sprint and reviews in one Markdown file. Specs live in:

`specs/<topic>.spec.md`

The lifecycle is short:

```text
   Draft           Reviewed        Built          Archived
     │                │              │                │
 author +        peer reviewer   Agent Mode      optional:
 Plan Mode      approves         executes        move to
 together                                        docs/done/
```

Each stage is intentionally cheap:

1. **Draft.** The author opens Plan Mode with the spec template attached and iterates until the plan reads as reviewable.
2. **Reviewed.** A peer reads the spec — not the code yet — and asks whether the scope makes sense, whether the acceptance criteria are testable, whether the open questions are answered.
3. **Built.** The spec and the resulting plan get handed to Agent Mode (or to the asynchronous Cloud Agent in [Module 8](08-github-cloud-agent.md)). The PR description links back to the spec.
4. **Archived.** After merge, move the file under `specs/done/` or, if it represents a long-lived design decision, promote it to an ADR.

### What goes in a spec

A spec does not need to be long. It needs to be specific. These sections matter:

| Section | Purpose |
|---|---|
| **Goal** | The single sentence that justifies the work. |
| **Background** | Why now; what already exists. |
| **In scope** | What this work will deliver. |
| **Out of scope** | What it will *not* deliver — the most important section. |
| **Acceptance criteria** | Testable statements; if X then Y. |
| **Operational impact** | What changes for deploy, monitoring, support. |
| **Blast radius** | The maximum impact if the change fails. |
| **Rollback** | The exact way a human undoes the change. |
| **Verification** | Local commands or review evidence that prove it works. |
| **Open questions** | Things to resolve before or during build. |

A spec without "Out of scope" is incomplete — it is the single most effective way to keep AI agents from drifting. A spec without "Blast radius" or "Rollback" is not ready to plan.

### A reusable template

```markdown
# Spec — <short title>

## Goal
What outcome should this change produce?

## Background
Why is this needed now? What files or current behavior matter?

## In scope
What should change?

## Out of scope
What must not change?

## Acceptance criteria
What observable checks prove the change works?

## Operational impact
What changes for deployment, monitoring, support, or cost?

## Blast radius
What is the maximum impact if this fails?

## Rollback
How does a human undo the change?

## Verification
What local command or review evidence is required?

## Open questions
What must be clarified before implementation?
```

### Drafting a spec with Plan Mode

The most reliable way to author a lightweight spec is to ask Plan Mode for one. It reads the relevant files, asks clarifying questions, and produces something close to the template:

```text
/plan I need a spec for improving the copilot-ml observability baseline.
Use specs/api-health-observability.spec.md as the structural reference.
Inspect app/main.py, tests/test_main.py, infra/bicep/main.bicep.

The spec must include:
- testable acceptance criteria for /healthz, /readyz, and any synthetic alert evidence
- the constraint that Azure Container Apps stays low-cost (minReplicas: 0, maxReplicas: 1)
- no new database, cache, queue, or live external dependency
- operational impact, blast radius, rollback, verification, and open questions

Do not propose implementation yet. Ask clarifying questions where the scope is ambiguous.
```

When the plan reads cleanly, click **Open in Editor** and save the result under `specs/`. Once you have done this two or three times, save the prompt as a `.prompt.md` file (see [Module 4](04-customize-instructions-prompts-and-hooks.md)) — `draft-api-spec.prompt.md` is already in the demo project.

### Reviewing the spec

Before implementation, walk through five gates. Reject the spec if any one fails:

| Gate | Question | Demo answer |
|---|---|---|
| Scope | Is the change small enough? | Yes — only health/readiness/alert behavior, not auth or databases. |
| Cost | Does it preserve low-cost Azure settings? | `minReplicas: 0`, `maxReplicas: 1`, GHCR default. |
| Tests | Can acceptance be verified locally? | `pytest` covers endpoint behavior. |
| Operations | Is rollback or cleanup clear? | Revert the PR, or manually delete the demo resource group. |
| Safety | Are live writes blocked? | No autonomous Azure deployment or deletion. |

A useful drill is to deliberately reject a polished-but-incomplete spec:

```text
Review this spec against the five gates: scope, cost, tests, operations, and safety.
Find at least three issues or risks.
Then propose a revised version of the weakest section.
```

The point is to build the team's muscle for saying "almost — fix this section first."

---

## Specs and Plan Mode together

A reviewed spec makes Plan Mode much better. The spec supplies the intent; Plan Mode supplies the execution order. The clean flow is:

```text
1. Draft and review the spec under specs/.
2. /plan against the approved spec.
3. Save the plan under specs/ or docs/plans/.
4. [Start Implementation] hands off to Agent Mode.
5. Review the diff against the spec's acceptance criteria, not the agent's claims.
6. Merge; archive the spec; capture reusable patterns as prompt files.
```

Two artifacts get committed: the spec and the plan. The PR description links to both.

A concrete prompt that turns the demo spec into a plan:

```text
Create an implementation plan for specs/api-health-observability.spec.md.

Use only this demo project. Read app/main.py, app/models.py, tests/test_main.py,
infra/bicep/main.bicep, and README.md.

The plan must include:
- files likely to change
- exact test command (pytest)
- Azure deployment review steps
- rollback and cleanup
- out-of-scope items

Do not implement.
```

Expected sections: goal, files inspected, ordered implementation steps, verification, rollback/cleanup, open questions.

---

## Specs and the Cloud Agent

If you delegate work to the asynchronous Cloud Agent ([Module 8](08-github-cloud-agent.md)), the spec becomes *the* delivery mechanism. Write the spec, commit it, open an issue that links to the spec, and assign it to `@copilot`. The agent reads the issue plus the linked spec plus the repo and opens a draft PR.

The cleaner the spec, the better the result. In particular:

- **Acceptance criteria** become the agent's self-test target.
- **Out of scope** prevents the agent from over-delivering.
- **References** to existing patterns (file paths in `app/`, prior prompt files) prevent invention.

This is GitHub's WRAP rule for delegating work to AI: *Write* the issue clearly, *Refine* with detail, *Anchor* to repo conventions, *Plan* for review.

---

## When to graduate to GitHub Spec Kit

[Spec Kit](https://github.com/github/spec-kit) is GitHub's open-source toolkit for formal spec-driven development. It installs a set of `/speckit.*` slash commands and templates that take you from a one-line idea through a fully versioned set of artifacts — constitution, spec, plan, tasks — ready for implementation by Copilot, Claude, or any compatible agent.

Use Spec Kit when the work is bigger than one sprint, when multiple teams need to review, or when the audit trail itself is the point.

| Use a lightweight spec when… | Use Spec Kit when… |
|---|---|
| The work fits in one Markdown file | The work spans multiple documents, contracts, and tasks |
| One team owns the decision | Multiple roles must review |
| The approach is obvious | The approach itself is what needs validation |
| Internal demo or refactor | Customer-facing feature or audited rollout |

### Installing and initializing

Spec Kit is a Python CLI distributed through `uv`. Install once per machine; for workshops and pilots, pin to a released version.

```bash
# replace vX.Y.Z with the release selected for the workshop
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@vX.Y.Z

specify version
specify integration list
```

To initialize in an existing repo:

```bash
specify init --here --integration copilot --script sh   # Linux/macOS
specify init --here --integration copilot --script ps   # Windows PowerShell
```

This typically creates `.specify/memory/constitution.md`, `.specify/templates/`, scripts under `.specify/scripts/<shell>/`, and routing files under `.github/prompts/` and `.github/agents/` so the `/speckit.*` commands appear in Copilot Chat.

> Do not run installation commands during a customer-facing lab unless the environment owner has approved them. If Spec Kit is not available, do the lightweight spec workflow instead — the discipline is what matters, not the tool.

### The Spec Kit flow

Each command produces a versioned artifact under `specs/<feature>/`. Human review is the gate between steps.

```text
Constitution    /speckit.constitution    repo-wide principles
       │
Specify         /speckit.specify         what & why (user-facing)
       │
Clarify         /speckit.clarify         resolve ambiguity (recommended)
       │
Plan            /speckit.plan            architecture, contracts
       │
Tasks           /speckit.tasks           ordered implementation checklist
       │
Analyze         /speckit.analyze         consistency across spec/plan/tasks
       │
Implement       /speckit.implement       execute a scoped task range
```

`/speckit.constitution` only runs once per repo — it captures the non-negotiables (test coverage, observability, no live infrastructure mutation without approval). `/speckit.clarify` and `/speckit.checklist` are optional but recommended before any customer-facing or operationally risky work. `/speckit.analyze` catches contradictions between the spec, plan, and tasks before code is generated.

### Quality gates

Spec Kit's value comes from pausing between phases. Do not skip the gates.

| Gate | Inspect | Ask |
|---|---|---|
| Constitution | `.specify/memory/constitution.md` | Are principles specific and enforceable? |
| Spec | `spec.md` | Does it describe *what* and *why* — not implementation? Are scenarios testable? |
| Clarify | Generated answers | Did the agent surface assumptions about owners, data, deploy environments? |
| Plan | `plan.md`, `research.md`, `contracts/` | Does the approach follow existing repo patterns? Are observability and rollback designed in? |
| Tasks | `tasks.md` | Are tasks small enough for PR review? Does every requirement map to a task? |
| Analyze | `/speckit.analyze` output | Any orphan tasks, missing tests, or contradictions? |
| Implement | Diff, tests, PR description | Did implementation stay within the task range? Did a human rerun the tests? |

For a customer workshop, require participants to reject at least one generated artifact and ask Copilot to revise it. The exercise is not to make Copilot look perfect — it is to build the team's review reflex.

### Picking models per phase

A cost-conscious default (see [Module 3](03-pick-the-right-model.md) for the full discussion):

| Phase | Suggested model class | Why |
|---|---|---|
| `specify`, `clarify` | Strong reasoning model | The text it produces is read many times downstream. |
| `plan` | Strong reasoning model | Architecture and contracts need depth. |
| `tasks` | Mid-tier model | Structured decomposition; mostly mechanical. |
| `implement` | Agentic coding model | High tool-call volume; reserve top-tier for the hard parts. |
| `analyze` | Strong long-context model | Reading across spec/plan/tasks at once. |

---

## Anti-patterns

| Anti-pattern | Symptom | Fix |
|---|---|---|
| **Spec written after the code** | The spec is generated to "document" what was already built | Specs must be approved *before* implementation. Otherwise they are just changelogs. |
| **No "out of scope" section** | The spec keeps growing; the agent keeps drifting | Always include out-of-scope. Be specific. |
| **Untestable acceptance criteria** | "The system should be fast" | Make them concrete: "p95 < 200 ms at 100 RPS". |
| **Single-developer SDD** | One person writes specs nobody reads | Specs are reviewed before they are built. Make peer review part of the cycle. |
| **Spec Kit on a one-line change** | Full Constitution → Specify → Plan → Tasks for a typo fix | Reserve Spec Kit for multi-sprint work. Use the lightweight template otherwise. |
| **Forgotten artifacts** | `specs/` directory full of merged-and-abandoned files | Archive periodically under `done/` or fold into ADRs. |
| **Spec replaces conversation** | The team stops talking because "it's in the spec" | A spec is a starting point for discussion, not a substitute. Schedule a 15-minute spec walk before kickoff. |

---

## Summary

Spec-driven development is the lowest-tech way to make Copilot reliably useful. A short Markdown spec — goal, scope, out of scope, acceptance criteria, rollback — turns Agent Mode from a guessing game into a predictable execution step. Plan Mode produces the spec; humans review it; Agent Mode (or the Cloud Agent) executes against it. For bigger work, GitHub Spec Kit adds versioned artifacts and named review gates without changing the underlying habit. Either way, the discipline is the same: write down the intent, then build.

For the hands-on labs, see [Module 9](09-workshop-and-labs.md#lab-3--author-a-spec).

---

> **Next:** [Module 7 — GitHub Copilot CLI](07-copilot-cli.md)
> **Back:** [Module 5 — Custom Agents, Skills & MCP](05-customize-agents-skills-mcp.md)
