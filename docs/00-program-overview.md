# GitHub Copilot Enablement Program

**Audience:** SRE, platform, and development teams learning how to use GitHub Copilot safely across code, tests, deployment review, customization, CLI workflows, and asynchronous PR delegation.

**Primary demo project:** `demo-projects/copilot-ml/`

This program is customer-facing. It uses one coherent project so every concept can be demonstrated without external sample apps, production credentials, or customer data.

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

The same FastAPI demo is used throughout:

- A small API in `app/`.
- Local tests in `tests/`.
- Low-cost Azure Container Apps infrastructure in `infra/bicep/`.
- Prompt files in `.github/prompts/`.
- A custom agent in `.github/agents/`.
- A skill in `.github/skills/`.
- Local stakeholder documents in `spec-kit/StakeholderDocuments/`.
- CLI, Cloud Agent, and report-only workflow guides under `docs/` and `.github/workflows/`.

### Demo — inspect the program spine

Open `demo-projects/copilot-ml/docs/module-demo-map.md` and ask Copilot:

```text
Explain how this one demo project supports Modules 4 through 8.
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
| 9 | [Hands-on Labs](09-workshop-and-labs.md) | Step-by-step practice | Lab artifacts for Modules 4–8 |
| 10 | [Pilot Playbook & Handover](10-pilot-and-playbook.md) | Team adoption and governance | Pilot plan and owner map |

---

## 2.1 Learning tiers

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
Use README.md, AGENTS.md, .github/copilot-instructions.md, infra/bicep/main.bicep, and .github/workflows/deploy-aca.yml.
List allowed actions, human-approved actions, and forbidden actions.
Do not edit files.
```

Expected result: allowed actions are local explanation/review/tests; human-approved actions include deployment; forbidden actions include secrets, production mutation, and autonomous deletion.

---

## 4. Recommended learning path

For a complete path:

1. Read Modules 1–3 to learn mode choice and cost discipline.
2. Use Modules 4–6 to build durable project assets.
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
- **Custom instructions** — always-on repo guidance in `.github/copilot-instructions.md` or `AGENTS.md`.
- **Custom agent** — reusable role contract in `.github/agents/*.agent.md`.
- **Agent Skill** — repeatable procedure in `.github/skills/<name>/SKILL.md`.
- **MCP** — tool-connection boundary for approved external systems; optional in this demo.
- **Copilot CLI** — terminal-native Copilot workflow surface.
- **Cloud Agent** — asynchronous issue-to-PR delegation.
- **Report-only agentic workflow** — repository automation that summarizes or drafts safe outputs without live mutation.
- **Spec-driven development** — write and review intent before implementation.

---

> **Next:** [Module 1 — Day 1 with Copilot](01-day-1-with-copilot.md)
