# GitHub Copilot Enablement Program

**Audience:** SRE, platform, and development teams learning how to use GitHub Copilot safely across code, tests, deployment review, customization, CLI workflows, and asynchronous PR delegation.

**Primary demo project:** `copilot-ml/` repository root.

This program is customer-facing. It uses one coherent, already-created v1 project so every concept can be demonstrated without external sample apps, production credentials, or customer data.

---

## 1. Program design

The curriculum follows a progressive path:

```text
Understand → Plan → Implement → Customize → Automate → Govern
```

The practical habit underneath that path is:

```text
Spec → Plan → Agent → Review → Measure
```

Use this loop throughout the program:

1. **Spec** — capture goal, scope, acceptance criteria, out-of-scope, operational impact, rollback, and verification.
2. **Plan** — ask Copilot for a read-only execution plan before risky, ambiguous, or multi-file work.
3. **Agent** — allow implementation only after the plan is reviewed and bounded.
4. **Review** — inspect the diff, rerun local proof, and compare output against the spec.
5. **Measure** — record cost, review effort, rework, and which reusable assets were worth keeping.

This is the main idea of the program: Copilot enablement is not a collection of tricks. It is an operating loop that turns AI output into reviewable engineering work.

The same FastAPI v1 demo is used throughout:

- A small API in `app/`.
- Local tests in `tests/`.
- Low-cost Azure Container Apps infrastructure in `infra/bicep/`.
- A guarded Azure/GitHub setup script in `scripts/`.
- Prompt files in `.github/prompts/`.
- A custom agent in `.github/agents/`.
- A skill in `.github/skills/`.
- Specs in `specs/`.
- Formal Spec Kit stakeholder inputs consolidated in [Module 4](04-spec-driven-development.md).
- CLI, Cloud Agent, and report-only workflow guides consolidated in Modules 7–8 and `.github/workflows/`.

### Demo — inspect the program spine

Open this overview and ask Copilot:

```text
Explain how this one v1 demo project supports Modules 1 through 8.
List the asset used by each module and the artifact a learner should produce.
Do not edit files.
```

Expected result: Copilot maps specs, prompts, custom agent, skill, CLI guide, Cloud Agent issue guide, and report-only workflow into one connected learning path.

---

## 2. Module map

| # | Module | Focus | Demo artifact |
|---|---|---|---|
| 1 | [Day 1 with Copilot](01-day-1-with-copilot.md) | First safe explanation and repo orientation | Project orientation note |
| 2 | [The Three Modes](02-three-modes.md) | Ask vs. Plan vs. Agent | Saved plan and small reviewed test diff |
| 3 | [Pick the Right Model](03-pick-the-right-model.md) | Model/cost discipline | Model comparison note |
| 4 | [Spec-Driven Development](04-spec-driven-development.md) | Vague request to reviewed spec | Lightweight spec or formal artifact set |
| 5 | [Instructions & Prompt Files](05-customize-instructions-and-prompts.md) | Repeatable prompts and repo rules | Prompt-file run result |
| 6 | [Custom Agents, Skills & MCP](06-customize-agents-skills-mcp.md) | Role contracts, skills, authority boundaries | Agent review and skill output |
| 7 | [Copilot CLI](07-copilot-cli.md) | Terminal context, sessions, permissions | CLI workflow summary |
| 8 | [Cloud Agent & Report-only Workflows](08-github-cloud-agent.md) | Async PR delegation and safe repository reports | Cloud Agent issue and workflow review |
| 9 | [Hands-on Labs](09-workshop-and-labs.md) | Step-by-step practice | Lab artifacts for Modules 1–8 |
| 10 | [Pilot Playbook & Handover](10-pilot-and-playbook.md) | Team adoption and governance | Pilot plan and owner map |

---

## 2.1 v1 demo map

Use this map to run one existing project through the Copilot enablement curriculum.

The starting point is **not** a blank app. The repository already contains the v1 FastAPI service, tests, Dockerfile, Azure Container Apps Bicep, GitHub Actions deployment workflow, setup script, prompt files, custom agent, skill, Cloud Agent issue template, and report-only workflow artifact.

The teaching pattern is:

```text
understand v1 → write or revise a spec → plan a small change → implement only after review → verify locally → capture reusable Copilot assets
```

| Module | Demo focus | Starting assets | Learner output |
|---|---|---|---|
| Module 1 — Day 1 with Copilot | Understand the existing v1 app safely | `README.md`, `app/main.py`, `tests/test_main.py`, `.github/copilot-instructions.md` | Project orientation note and unsafe-prompt rewrite |
| Module 2 — Ask, Plan, Agent | Move from explanation to a tiny reviewed test change | `app/main.py`, `app/models.py`, `tests/test_main.py` | Reviewed plan, scoped test diff, `pytest` result |
| Module 3 — Model and cost discipline | Compare model output on one read-only review | `infra/bicep/main.bicep`, `.github/workflows/deploy-aca.yml`, `README.md` | Model/cost comparison note |
| Module 4 — Spec-Driven Development | Turn a next-feature idea into a reviewed spec | `specs/api-health-observability.spec.md`, consolidated stakeholder inputs in Module 4 | Lightweight spec or formal artifact set |
| Module 5 — Instructions and prompts | Use existing prompt files before creating new assets | `.github/copilot-instructions.md`, `.github/prompts/` | Prompt-file run result and one proposed improvement |
| Module 6 — Custom agents, Skills, MCP | Escalate from native Copilot to role/procedure/boundary only when useful | `.github/agents/api-platform-reviewer.agent.md`, `.github/skills/api-observability-review/` | Agent review, refusal proof, skill output, MCP decision |
| Module 7 — Copilot CLI | Repeat the same review from a terminal-first workflow | [Module 7 consolidated CLI guide](07-copilot-cli.md#chapter-79--consolidated-cli-demo-guide) | Named CLI session summary and safety evidence |
| Module 8 — Cloud Agent / report-only workflow | Delegate one bounded improvement and review safe automation | [Module 8 issue-to-PR guide](08-github-cloud-agent.md#chapter-87--cloud-agent-issue-to-pr-demo-guide), `.github/ISSUE_TEMPLATE/`, `.github/workflows/daily-api-health-review.md` | Cloud Agent issue/PR review checklist and workflow go/no-go decision |

### Suggested end-to-end storyline

1. **Orient to v1:** "What exists, what is demo-only, and what must stay human-approved?"
2. **Validate locally:** run or review `pytest` and explain what local tests prove.
3. **Choose the right mode:** Ask explains `/readyz`; Plan scopes one test improvement; Agent implements only the approved test change.
4. **Draft the next-feature spec:** use `specs/api-health-observability.spec.md` to propose a small synthetic observability improvement.
5. **Use reusable prompts:** run `/draft-api-spec`, `/investigate-api-alert`, or `/review-azure-deployment` against existing files.
6. **Escalate deliberately:** use native exploration first, then `api-platform-reviewer`, then `api-observability-review` only when the role/procedure adds value.
7. **Review deployment safety:** treat `scripts/setup-github-azure-actions.sh`, Bicep, and GitHub Actions as completed v1 assets that require human approval for live writes.
8. **Delegate a bounded PR:** draft a Cloud Agent issue for one test/spec improvement; review the PR/session log before merge.
9. **Decide what to pilot:** convert the useful artifacts into a customer-owned pilot plan.

### Default next-feature backlog

Use these tasks when the facilitator needs a small live exercise:

| Backlog item | Why it works for training | Expected files |
|---|---|---|
| Add one `/readyz` assertion for `external_dependencies` | Shows Ask → Plan → Agent with a tiny diff | `tests/test_main.py` |
| Draft a spec for a synthetic dependency-health summary | Teaches spec discipline before code | `specs/api-health-observability.spec.md` or a new spec |
| Improve the checkout alert runbook checklist | Teaches read-only SRE review and docs iteration | [Module 6 runbook section](06-customize-agents-skills-mcp.md#runbook--checkout-api-error-rate-alert) |
| Review the Azure setup/deploy path | Teaches safety boundaries after v1 setup exists | `scripts/setup-github-azure-actions.sh`, `infra/bicep/main.bicep`, `.github/workflows/deploy-aca.yml` |
| Draft a Cloud Agent issue for readiness coverage | Teaches async PR delegation without live deployment | issue body / `.github/ISSUE_TEMPLATE/cloud-agent-api-observability.yml` |

### What not to demo

- Greenfield scaffolding of the v1 app.
- Live production deployment.
- Real customer incidents, telemetry exports, secrets, or enterprise data committed to the repo.
- Autonomous rollback, Azure resource deletion, restart, scale, merge, or alert-threshold mutation.
- Broad custom agents before native Copilot capabilities and prompt files have been tried.

---

## 2.2 Learning tiers

The modules can be consumed in tiers, depending on role and readiness:

| Tier | Audience | Modules | Outcome |
|---|---|---|---|
| Foundation | Everyone using Copilot in the repo | 1–3 | Safe first use, mode choice, model/cost discipline. |
| Working effectively | Developers, SREs, reviewers | 4–6 | Specs, prompt files, custom agents, skills, MCP boundaries. |
| Beyond the IDE | Terminal-first or async teams | 7–8 | CLI workflows, Cloud Agent issue-to-PR, report-only workflow review. |
| Adoption owners | Leads and platform owners | 9–10 | Lab artifacts, pilot scope, KPIs, and handover plan. |

The demo project remains the same in every tier. The difference is how much authority and automation the team is ready to introduce.

---

## 3. Safety principles

The program uses the same boundaries everywhere:

1. **Read-only first.** Start with explanation, planning, and review.
2. **Plan before Agent for risky or multi-file work.** Do not skip the thinking step.
3. **PR-shaped output.** Agents may draft changes; humans review and merge.
4. **Human-owned deployment.** Agents do not deploy, delete, restart, scale, merge, or publish customer-visible communications.
5. **No secrets or customer data.** Do not paste them into prompts, issues, logs, or repo files.
6. **Local proof beats claims.** Run tests or review evidence yourself.
7. **Customize only after the gap is visible.** Native Copilot first, prompt files next, custom agents/skills only when justified.

### Common anti-patterns to watch for

| Anti-pattern | What it looks like | Safer replacement in this program |
|---|---|---|
| Runaway loop | The agent keeps reading, editing, and retrying without a clear new signal. | Stop, summarize state, return to Plan Mode. |
| Phantom completion | The agent says “done” without tests, diff review, or evidence. | Require `pytest`, file-level evidence, or an explicit “not run” note. |
| Scope creep | A test request becomes deployment, auth, refactor, or infra redesign. | Restate expected files and out-of-scope before implementation. |
| Tool overreach | A review task tries to deploy, delete, restart, scale, or merge. | Refuse live mutation and produce a checklist or PR comment instead. |
| Context flooding | The prompt attaches the whole repo for a narrow review. | Attach only `app/`, `tests/`, `infra/bicep/`, workflow, or prompt files needed. |

### Demo — safety review

Ask Copilot:

```text
Review the copilot-ml safety boundaries.
Use README.md, .github/copilot-instructions.md, infra/bicep/main.bicep, scripts/setup-github-azure-actions.sh, and .github/workflows/deploy-aca.yml.
List allowed actions, human-approved actions, and forbidden actions.
Do not edit files.
```

Expected result: allowed actions are local explanation/review/tests; human-approved actions include deployment; forbidden actions include secrets, production mutation, and autonomous deletion.

---

## 4. Recommended learning path

For a complete path:

1. Read Modules 1–3 to learn mode choice and cost discipline.
2. Use Modules 4–6 to review, use, and adapt durable project assets.
3. Use Module 7 if the team works from terminal sessions or automation.
4. Use Module 8 when tasks are ready for asynchronous PR delegation or report-only repository automation.
5. Run Module 9 labs to produce artifacts.
6. Use Module 10 to decide what becomes part of the real customer pilot.

### Demo — choose your path

Ask Copilot:

```text
Given this team's goal — use Copilot to improve API observability and deployment review discipline — recommend which modules and labs to run first.
Use only the local curriculum files and the demo project.
```

Expected result: a path through Modules 1, 2, 4, 5, 6, 7 or 8 depending on team role, then Module 9 labs and Module 10 pilot planning.

---

## 5. Definition of done

The enablement package is ready when the team has:

- Completed the project orientation and mode-choice labs.
- Produced a reviewed spec.
- Used at least one prompt file.
- Reviewed the custom agent role contract.
- Applied the API observability skill.
- Recorded an MCP boundary decision.
- Produced a CLI workflow summary if CLI is in scope.
- Drafted one Cloud Agent-ready issue if asynchronous PR delegation is in scope.
- Reviewed one report-only workflow if repository automation is in scope.
- Built a pilot plan with owners, success measures, and safety boundaries.

The engagement is not considered done just because the demo runs. It is done when the team can repeat the operating loop in a real repository with clear ownership, reusable assets, and measurable outcomes.

### Evidence to keep

For each completed lab or pilot exercise, keep one small artifact:

- A spec or plan.
- A prompt-file run result.
- A custom-agent review or refusal test.
- A skill output.
- A model/cost comparison note.
- A Cloud Agent issue or PR review checklist.
- A pilot decision table.

These artifacts become the team's playbook seed.

### Demo — final readiness check

Ask Copilot:

```text
Using Module 9 completion checklist and Module 10 pilot checklist, create a readiness summary for this demo project.
Mark each item ready, needs review, or blocked.
```

---

## 6. Glossary

- **Ask Mode** — explanation and Q&A. No edits.
- **Plan Mode** — read-only planning. Produces a reviewable plan.
- **Agent Mode** — implementation with file edits and commands under human supervision.
- **Prompt file** — reusable slash prompt in `.github/prompts/`.
- **Custom instructions** — always-on repo guidance in `.github/copilot-instructions.md`.
- **Custom agent** — reusable role contract in `.github/agents/*.agent.md`.
- **Agent Skill** — repeatable procedure in `.github/skills/<name>/SKILL.md`.
- **MCP** — tool-connection boundary for approved external systems; optional in this demo.
- **Copilot CLI** — terminal-native Copilot workflow surface.
- **Cloud Agent** — asynchronous issue-to-PR delegation.
- **Report-only agentic workflow** — repository automation that summarizes or drafts safe outputs without live mutation.
- **Spec-driven development** — write and review intent before implementation.

---

> **Next:** [Module 1 — Day 1 with Copilot](01-day-1-with-copilot.md)
