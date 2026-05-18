# Module 5 — Customize Copilot: Instructions & Prompt Files

> **Goal:** by the end of this module, you can use repo instructions and prompt files to make repeated Copilot work consistent, reviewable, and reusable.

All demos use:

`demo-projects/copilot-ml/`

---

## Chapter 5.0 — Demo scenario

The demo project already includes the customization assets for this module:

- `.github/copilot-instructions.md`
- `AGENTS.md`
- `.github/prompts/draft-api-spec.prompt.md`
- `.github/prompts/review-azure-deployment.prompt.md`
- `.github/prompts/add-health-check-tests.prompt.md`
- `.github/prompts/investigate-api-alert.prompt.md`
- `.github/prompts/cloud-agent-task.prompt.md`

The customer-safe scenario is:

> Make Copilot consistently review, test, and document changes to a minimal FastAPI API deployed to low-cost Azure Container Apps.

Use this customization stack to decide where each reusable behavior belongs:

| Layer | Purpose | Demo project asset | When to use |
|---|---|---|---|
| Repo instructions | Always-on project rules | `.github/copilot-instructions.md`, `AGENTS.md` | Rules that are true for almost every request. |
| Prompt files | Reusable slash commands | `.github/prompts/*.prompt.md` | Repeated tasks with input parameters and output format. |
| Custom agents | Persistent role contracts | `.github/agents/api-platform-reviewer.agent.md` | A role needs authority boundaries and a quality bar. |
| Skills | Repeatable procedures | `.github/skills/api-observability-review/` | A workflow needs steps, references, or scripts. |
| MCP boundary | Approved external tools | Designed in Module 6 | Local files are insufficient and read-only live data is approved. |

Start low in the stack. Do not create a custom agent or skill until a repeated workflow proves that instructions and prompt files are not enough.

---

## Chapter 5.1 — Custom instructions

Custom instructions are standing rules. They are loaded repeatedly, so they should be short, durable, and repo-specific.

In the demo project, inspect:

- `.github/copilot-instructions.md`
- `AGENTS.md`

These files define the project stack, safety boundaries, verification commands, and Azure cost rules.

### Instruction anatomy

Good repo instructions usually contain:

- **Project overview** — what the repo is and what it is not.
- **Stack and commands** — runtime, framework, package manager, tests, lint/build if applicable.
- **Repo layout** — important folders and their purpose.
- **Safety rules** — secrets, deployment, destructive commands, production data.
- **Verification rules** — tests or checks that prove local behavior.
- **Style and review rules** — how to keep diffs small and reviewable.

For `copilot-ml`, durable rules include FastAPI, `pytest`, Docker, Azure Container Apps cost settings, no secrets, and no autonomous Azure deployment.

### Priority and scope

When multiple instructions exist, the safest working assumption is:

1. Organization or environment policy wins.
2. Repository instructions guide all repo work.
3. Prompt files specialize one task.
4. User request narrows the current session.

If instructions conflict, ask for clarification or choose the stricter safety rule. For example, if a prompt asks to deploy but repo instructions forbid autonomous deployment, refuse the deployment and offer a review checklist instead.

### What belongs in instructions

| Put in instructions | Keep out of instructions |
|---|---|
| Stable commands such as `pytest`. | Long runbooks or multi-step investigations. |
| Durable safety rules. | One-off task details. |
| Cost constraints. | Large examples that inflate every prompt. |
| Repo structure and conventions. | Prompt templates better stored as `.prompt.md`. |

Always-on instructions are loaded often, so concise instructions are a cost-control feature.

### Demo — review instruction quality

Ask Copilot:

```text
Review .github/copilot-instructions.md and AGENTS.md for this demo project.

Find:
- rules that are durable and should stay
- rules that are too verbose
- rules that belong in a prompt file instead
- missing safety rules for Azure deployment

Do not edit files. Produce a review table.
```

Expected result:

- Instructions mention FastAPI, tests, Docker, Azure Container Apps, and low-cost settings.
- Instructions forbid autonomous Azure deployment, resource deletion, secrets, and production mutation.
- Long task procedures are kept in prompt files, not always-on instructions.

---

## Chapter 5.2 — Prompt files

Prompt files are reusable slash commands. They are useful when a team repeats the same request.

They have three advantages over ad-hoc copy/paste prompts:

1. **Discoverability** — they appear as named commands.
2. **Reviewability** — prompt behavior is versioned with the repo.
3. **Parameterization** — inputs can be explicit instead of buried in prose.

In the demo project, inspect:

`.github/prompts/`

| Prompt file | Use it for |
|---|---|
| `draft-api-spec.prompt.md` | Draft a spec for API, observability, test, or deployment changes. |
| `review-azure-deployment.prompt.md` | Review Bicep and GitHub Actions for cost, safety, and rollback. |
| `add-health-check-tests.prompt.md` | Add or improve tests around API health/readiness behavior. |
| `investigate-api-alert.prompt.md` | Produce a read-only triage note from synthetic alert evidence. |
| `cloud-agent-task.prompt.md` | Draft a Cloud Agent-ready issue. |

### Demo — run the spec prompt

Use the prompt file directly from Copilot Chat:

```text
/draft-api-spec change_request: Add an endpoint that summarizes API dependency health from synthetic demo data. target_area: FastAPI app and tests
```

Expected output:

- Spec sections are present.
- Out-of-scope excludes real dependencies and production data.
- Acceptance criteria include tests.
- Cost and Azure deployment boundaries remain unchanged.

---

## Chapter 5.3 — Prompt-file anatomy

Each prompt file has two parts:

1. **Frontmatter** — description, agent, model, tools, argument hint.
2. **Body** — role, inputs, procedure, output format, constraints.

Recommended prompt-file sections:

| Section | Why it matters |
|---|---|
| `description` | Helps users pick the right slash command. |
| `argument-hint` | Shows what input the command expects. |
| `tools` | Prevents unnecessary authority. |
| Inputs | Makes task variables explicit. |
| Procedure | Keeps repeated steps consistent. |
| Output format | Makes review easier and limits verbosity. |
| Constraints | Keeps the prompt inside safety and cost boundaries. |

For this demo, prompt files should prefer review, spec drafting, test planning, and PR comments. They should not hide deployment or deletion behavior.

### Demo — inspect prompt-file frontmatter

Open:

`.github/prompts/review-azure-deployment.prompt.md`

Ask Copilot:

```text
Explain the frontmatter and body of .github/prompts/review-azure-deployment.prompt.md.
Why are the tools read-only? What output format does it enforce?
```

Expected result:

- The prompt is scoped to review, not deployment.
- It uses repo/search context rather than Azure write tools.
- It produces a PR-ready review structure.

---

## Chapter 5.4 — Instructions vs. prompt files

Use this decision rule:

| If the guidance is... | Put it in... | Demo project example |
|---|---|---|
| Always true for the repo | Custom instructions | Keep Azure cost low; never commit secrets. |
| A repeated task | Prompt file | Review deployment, draft spec, add tests. |
| A persistent role | Custom agent | API platform reviewer in Module 6. |
| A multi-step capability | Skill | API observability review in Module 6. |

### The 30-second rule

If a rule should influence almost every request in the repo, keep it in instructions. If a person would say “run the deployment review prompt” or “draft the API spec prompt,” put it in a prompt file. If the behavior requires a durable role identity, use a custom agent. If the behavior is a procedure with references, use a skill.

For example:

- “Never commit secrets” is an instruction.
- “Review this Bicep and workflow for deployment readiness” is a prompt file.
- “Act as an API platform reviewer with refusal rules” is a custom agent.
- “Apply this observability review checklist” is a skill.

### Demo — move procedure out of instructions

Ask Copilot:

```text
Compare AGENTS.md and .github/prompts/investigate-api-alert.prompt.md.
Which content belongs in always-on instructions, and which belongs in the prompt file?
Suggest one improvement without editing.
```

Expected result:

- Standing safety rules stay in `AGENTS.md`.
- Detailed alert investigation steps stay in the prompt file.

---

## Chapter 5.5 — Create one new prompt file

Use this when the team identifies a repeated request not already covered.

### Demo — design a new prompt

Scenario:

> We often need a concise PR review comment for changes to `app/main.py`, `tests/test_main.py`, and `infra/bicep/main.bicep`.

Ask Copilot:

```text
Draft a new prompt file for this demo project named api-pr-review.prompt.md.

It should review API behavior, tests, Azure Container Apps cost settings, rollback, and safety.
It must not run Azure write commands.
It should output a PR-ready review comment.

Do not create the file yet. Show the proposed prompt file content for review.
```

After review, create the file only if the team agrees it adds value.

---

## Chapter 5.6 — Day-2 bootstrapping checklist

After the first few Copilot sessions, review what should become durable repo assets:

- [ ] Did a prompt get reused at least twice?
- [ ] Did the team repeat the same safety warning manually?
- [ ] Did reviews ask for the same output shape repeatedly?
- [ ] Did a task need a persistent reviewer role?
- [ ] Did a task need a checklist or reference document?
- [ ] Did a request require live external data, or were local files enough?

Turn only proven repetition into customization. This keeps the repo clean and prevents over-engineering.

## Chapter 5.7 — Anti-patterns

- **Instruction dumping:** putting long procedures in always-on instructions.
- **Prompt file sprawl:** creating many commands that no one uses.
- **Hidden authority:** a review prompt that can deploy or mutate live systems.
- **No output shape:** a prompt that produces essays instead of reviewable artifacts.
- **No owner:** repo customization files with no maintainer.

---

## Chapter 5.8 — Lab connection

Use these labs in [Module 9](09-workshop-and-labs.md):

- [Lab 4a — Prompt file (15–20 min)](09-workshop-and-labs.md#lab-4a--prompt-file-1520-min)
- [Lab 4 — Design a custom agent, then package reusable prompts/skills](09-workshop-and-labs.md#lab-4--design-a-custom-agent-then-package-reusable-promptsskills)

Both labs use the prompt files in `demo-projects/copilot-ml/.github/prompts/`.

---

> **Next:** [Module 6 — Custom agents, Skills, MCP](06-customize-agents-skills-mcp.md)
> **Back:** [Module 4 — Spec-Driven Development](04-spec-driven-development.md)
