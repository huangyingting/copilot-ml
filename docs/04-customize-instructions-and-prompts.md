# Module 4 — Customize Copilot: Instructions, Prompt Files & Hooks

> **Goal:** by the end of this module, you can decide what belongs in always-on instructions, what belongs in a reusable prompt file, and when a deterministic hook is justified. You can also review these assets for safety, cost, and usefulness before committing them to a team repository.

All demos start from the existing v1 project in the repository root:

`copilot-ml/`

---

## Chapter 4.0 — Customization stack and demo context

This module explains the lightweight customization layer first, then uses the demo project to show how each asset changes Copilot behavior. The demo project already includes these assets:

- `.github/copilot-instructions.md`
- `.github/prompts/draft-api-spec.prompt.md`
- `.github/prompts/review-azure-deployment.prompt.md`
- `.github/prompts/add-health-check-tests.prompt.md`
- `.github/prompts/investigate-api-alert.prompt.md`
- `.github/prompts/cloud-agent-task.prompt.md`

The demo project does **not** commit a hook by default. Hooks execute shell commands, so they are treated as an optional design-and-review exercise rather than enabled automatically in the base workshop.

The customer-safe scenario is:

> Make Copilot consistently review, test, and document changes to a minimal FastAPI API deployed to low-cost Azure Container Apps.

Use this customization stack to decide where each reusable behavior belongs:

| Layer | Purpose | Demo project asset | When to use |
|---|---|---|---|
| Repo instructions | Always-on project rules | `.github/copilot-instructions.md` | Rules that are true for almost every request. |
| File-based instructions | Targeted rules by file pattern or task | Optional `.github/instructions/*.instructions.md` | Python, tests, docs, or infra need different conventions. |
| Prompt files | Reusable slash commands | `.github/prompts/*.prompt.md` | Repeated tasks with input parameters and output format. |
| Hooks | Deterministic lifecycle automation | Optional `.github/hooks/*.json` | You must enforce, validate, log, or inject context at agent lifecycle points. |
| Custom agents | Persistent role contracts | `.github/agents/api-platform-reviewer.agent.md` | A role needs authority boundaries and a quality bar. Covered in Module 5. |
| Skills | Repeatable procedures | `.github/skills/api-observability-review/` | A workflow needs steps, references, or scripts. Covered in Module 5. |
| MCP boundary | Approved external tools | Designed in Module 5 | Local files are insufficient and read-only live data is approved. |

Start low in the stack:

1. Use native Copilot for one-off explanation.
2. Add **instructions** for durable repo rules.
3. Add **prompt files** for repeated tasks.
4. Add **hooks** only when guidance is not enough and a deterministic command is worth the security review.
5. Move to **agents, skills, or MCP** only when the lightweight layer is no longer enough.

The key distinction:

- Instructions and prompt files **guide** the model.
- Hooks **run code** at lifecycle points.

That difference is powerful, but it changes the review bar. Treat hooks like automation code, not like prose.

---

## Chapter 4.1 — Custom instructions

Custom instructions are standing rules. They are loaded repeatedly, so they should be short, durable, and repo-specific.

In the demo project, inspect:

- `.github/copilot-instructions.md`

This file defines the project stack, safety boundaries, verification commands, and Azure cost rules.

### Instruction types

| Type | Location | Loaded when | Use for |
|---|---|---|---|
| Always-on repo instructions | `.github/copilot-instructions.md` | Every chat request in the workspace | Project-wide rules, safety boundaries, preferred commands. |
| Cross-agent instructions | `AGENTS.md` | Every chat request when enabled | Shared guidance for teams using multiple AI coding agents. |
| File-based instructions | `.github/instructions/*.instructions.md` | Matching files or matching task description | Language, framework, test, docs, or infra-specific rules. |
| Organization instructions | GitHub organization setting | Available across repos when enabled | Broad company standards and mandatory policies. |
| User instructions | User profile | Personal preference across workspaces | Individual style preferences that do not weaken team rules. |

For this workshop, `.github/copilot-instructions.md` is enough. Add file-based instructions only when a rule applies to a specific part of the repo and would be noisy everywhere else.

### Instruction anatomy

Good repo instructions usually contain:

- **Project overview** — what the repo is and what it is not.
- **Stack and commands** — runtime, framework, package manager, tests, lint/build if applicable.
- **Repo layout** — important folders and their purpose.
- **Safety rules** — secrets, deployment, destructive commands, production data.
- **Verification rules** — tests or checks that prove local behavior.
- **Style and review rules** — how to keep diffs small and reviewable.

For `copilot-ml`, durable rules include FastAPI, `pytest`, Docker, Azure Container Apps cost settings, no secrets, and no autonomous Azure deployment.

### Priority and conflict handling

Different Copilot surfaces can load organization, repository, user, and file-based instructions together. Do not rely on a clever conflict-resolution trick. Write instructions so they do not conflict.

Use these review rules:

- If two rules conflict, keep the stricter safety rule.
- If a prompt asks for deployment but repo instructions forbid autonomous deployment, refuse the deployment and offer a review checklist instead.
- If a personal instruction weakens a repo or organization safety rule, treat it as invalid for the task.
- If rules are duplicated in multiple files, keep the shortest authoritative version and link to the detailed workflow elsewhere.

### What belongs in instructions

| Put in instructions | Keep out of instructions |
|---|---|
| Stable commands such as `.venv/bin/pytest` or `pytest`. | Long runbooks or multi-step investigations. |
| Durable safety rules. | One-off task details. |
| Cost constraints. | Large examples that inflate every prompt. |
| Repo structure and conventions. | Prompt templates better stored as `.prompt.md`. |
| Pointers to reusable assets. | Model-specific preferences that should be set in a prompt or agent. |

Always-on instructions are loaded often, so concise instructions are a cost-control feature. The source material's practical lesson is simple: write the first version clearly, then compress once the team agrees the rules are stable.

### Demo — review instruction quality

Ask Copilot:

```text
Review .github/copilot-instructions.md for this demo project.

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
- Long task procedures are kept in prompt files, skills, or docs, not always-on instructions.

---

## Chapter 4.2 — Targeted instruction files

A targeted instruction file is a Markdown file ending in `.instructions.md`. It can include frontmatter that tells Copilot when to apply it.

Use targeted instructions when one part of the repo has special rules that should not become global noise.

Example design, not required for the base demo:

```markdown
---
name: "Python API standards"
description: "FastAPI and pytest conventions for copilot-ml"
applyTo: "{app,tests}/**/*.py"
---
- Keep FastAPI routes small and typed with Pydantic models.
- Add or update pytest coverage for behavior changes.
- Do not add live external dependencies to demo endpoints.
```

### When targeted instructions help

| Situation | Better than always-on because... | Demo example |
|---|---|---|
| Python API rules | They do not need to load for docs-only work. | `app/**/*.py`, `tests/**/*.py` |
| Bicep cost rules | They are only relevant for infrastructure edits. | `infra/bicep/**/*.bicep` |
| Prompt-authoring conventions | They apply only to customization files. | `.github/prompts/*.prompt.md` |
| Workshop docs tone | They apply only to `docs/`. | `docs/**/*.md` |

Avoid `applyTo: "**"` unless the rule truly applies to every file and every task. Broad `applyTo` rules increase baseline context and make unrelated tasks noisier.

### Demo — design, do not create

Ask Copilot:

```text
Design one targeted .instructions.md file for copilot-ml.

Choose the narrowest useful applyTo pattern.
Explain:
- why this should not go in .github/copilot-instructions.md
- which tasks should trigger it
- which tasks should not trigger it

Do not create the file.
```

Expected result: a narrow file pattern and a short body. Reject designs that repeat the entire repo instruction file.

---

## Chapter 4.3 — Prompt files

Prompt files are reusable slash commands. They are useful when a team repeats the same request.

They have three advantages over ad-hoc copy/paste prompts:

1. **Discoverability** — they appear as named commands.
2. **Reviewability** — prompt behavior is versioned with the repo.
3. **Parameterization** — inputs can be explicit instead of buried in prose.

In the demo project, inspect:

`.github/prompts/`

| Prompt file | Use it for | Why it belongs as a prompt |
|---|---|---|
| `draft-api-spec.prompt.md` | Draft a spec for API, observability, test, or deployment changes. | It is a repeated task with clear sections and constraints. |
| `review-azure-deployment.prompt.md` | Review Bicep and GitHub Actions for cost, safety, and rollback. | It needs structured output and a no-deploy boundary. |
| `add-health-check-tests.prompt.md` | Add or improve tests around API health/readiness behavior. | It has a narrow implementation target and test expectation. |
| `investigate-api-alert.prompt.md` | Produce a read-only triage note from synthetic alert evidence. | It is a reusable incident-analysis shape. |
| `cloud-agent-task.prompt.md` | Draft a Cloud Agent-ready issue. | It turns a request into bounded async-agent work. |

### When to create a prompt file

Create a prompt file when you have typed substantially the same multi-paragraph prompt twice.

Good candidates:

- Draft a spec from a change request.
- Review deployment files for safety and rollback.
- Add tests for a known endpoint pattern.
- Summarize test output into a PR comment.
- Investigate synthetic alert evidence read-only.
- Draft a bounded Cloud Agent issue.

Bad candidates:

- A one-off question.
- A broad “review everything” request.
- A prompt that secretly grants deployment or deletion authority.
- A prompt that duplicates all repo instructions instead of linking to them.

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

## Chapter 4.4 — Prompt-file anatomy

Each prompt file has two parts:

1. **Frontmatter** — description, name, agent, model, tools, argument hint.
2. **Body** — role, inputs, procedure, output format, constraints.

Recommended prompt-file sections:

| Section | Why it matters |
|---|---|
| `description` | Helps users pick the right slash command. |
| `argument-hint` | Shows what input the command expects. |
| `agent` | Chooses Ask, Plan, Agent, or a custom agent for this task. |
| `tools` | Prevents unnecessary authority and reduces tool noise. |
| Inputs | Makes task variables explicit. |
| Procedure | Keeps repeated steps consistent. |
| Output format | Makes review easier and limits verbosity. |
| Constraints | Keeps the prompt inside safety and cost boundaries. |

For this demo, prompt files should prefer review, spec drafting, test planning, and PR comments. They should not hide deployment or deletion behavior.

### Frontmatter review checklist

| Field | Good sign | Risk sign |
|---|---|---|
| `description` | Specific trigger words and task scope. | Vague description such as “do stuff”. |
| `argument-hint` | Names required user input. | No hint for a prompt that needs parameters. |
| `agent` | Matches the work mode. | Uses Agent Mode for a read-only review without reason. |
| `tools` | Minimum tool set for the task. | Broad tools or write tools for a review prompt. |
| `model` | Only pinned when the task has a strong reason. | Pins a high-cost model for routine summaries. |

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

## Chapter 4.5 — Agent hooks

Hooks run shell commands at specific points during an agent session. In VS Code, agent hooks are currently **Preview**, and an organization may disable them. Use the live VS Code hooks documentation as the source of truth when enabling them.

Hooks are different from instructions and prompt files:

| Primitive | Behavior | Deterministic? | Example |
|---|---|---:|---|
| Instructions | Tell Copilot what rules to follow. | No | “Do not run Azure write commands.” |
| Prompt file | Gives Copilot a reusable task procedure. | No | `/review-azure-deployment` |
| Hook | Runs your command at a lifecycle point. | Yes | Block a tool call that attempts `az group delete`. |

Use hooks when a behavior must be enforced or automated. Do not use hooks just because a sentence in `copilot-instructions.md` would be enough.

### Hook locations and lifecycle

Workspace hooks usually live in:

`.github/hooks/*.json`

VS Code also supports other locations and agent-scoped hooks, but for this workshop the safest mental model is: **workspace hooks are team-shared automation and require code review**.

Common lifecycle events:

| Event | Fires when | Useful for |
|---|---|---|
| `SessionStart` | A new agent session begins. | Inject safe project context such as branch, test command, or repo mode. |
| `UserPromptSubmit` | A user submits a prompt. | Audit requests or warn on risky phrasing. |
| `PreToolUse` | Before a tool runs. | Deny, allow, or ask for confirmation before sensitive operations. |
| `PostToolUse` | After a tool succeeds. | Run formatters, linters, or logging after edits. |
| `PreCompact` | Before context compaction. | Save important state before long sessions compress context. |
| `SubagentStart` | A subagent starts. | Track nested agent usage or inject role-specific context. |
| `SubagentStop` | A subagent completes. | Aggregate results or validate handoff output. |
| `Stop` | The agent tries to finish. | Remind or block completion if required proof is missing. Use sparingly. |

Hooks receive JSON on stdin and can return JSON on stdout. `PreToolUse` can return a permission decision such as `allow`, `ask`, or `deny`. Exit code `2` can block an operation. This is why hook scripts must be small, reviewed, and easy to audit.

### Good hook candidates for `copilot-ml`

| Need | Hook event | Design idea | Enable by default? |
|---|---|---|---:|
| Prevent accidental Azure mutation | `PreToolUse` | Ask or deny terminal/tool calls that match deployment, deletion, scale, or public endpoint changes. | No — design and review first. |
| Format after Python edits | `PostToolUse` | Run a fast formatter only on changed files. | Maybe, if formatter is already a team standard. |
| Log agent tool usage for a workshop | `PreToolUse` or `PostToolUse` | Write tool name and timestamp to a local audit file. | Maybe, if no secrets or prompt content are logged. |
| Inject safe project context | `SessionStart` | Add Python version, repo root, and test command. | Maybe, if context is short and non-sensitive. |
| Require proof before completion | `Stop` | Remind that tests were not run. | Rarely — avoid loops and extra cost. |

For this repository, the most useful hook design exercise is an Azure safety guard. It reinforces the same boundary as the repo instructions: Copilot may review deployment files, but it must not run live Azure write commands without explicit human approval.

### Demo — design a hook without enabling it

Ask Copilot:

```text
Design a reviewed hook for copilot-ml, but do not create files.

Goal:
- warn or block risky Azure write/delete/deploy commands during Agent Mode
- allow read-only review and local pytest
- never log secrets, prompts, or tokens
- keep timeout short

Return:
- event choice
- proposed .github/hooks/*.json shape
- proposed script behavior in pseudocode
- review checklist
- risks and rollback
```

Expected result:

- `PreToolUse` is chosen for enforcement before a tool runs.
- The hook design asks or denies risky Azure mutation commands.
- The design does not embed credentials or secrets.
- The design includes how to disable or remove the hook.
- The answer says the hook is not enabled until reviewed.

### Hook safety checklist

Before committing or enabling a hook:

- [ ] Is a hook necessary, or would an instruction/prompt be enough?
- [ ] Is the command short, deterministic, and auditable?
- [ ] Does it avoid secrets, tokens, prompt text, and customer data in logs?
- [ ] Does it validate and sanitize JSON input from the agent?
- [ ] Does it have a short timeout?
- [ ] Does it avoid network access unless explicitly approved?
- [ ] Is the hook script protected from agent edits or reviewed before use?
- [ ] Is there a clear rollback: remove or disable the hook file?

Troubleshooting tips:

- Hook files must be valid `.json` files in a loaded hooks location.
- Hook commands must be executable on the VS Code extension host OS.
- Use the **GitHub Copilot Chat Hooks** output channel to inspect hook output.
- Use hook diagnostics/logs to confirm which hook files were loaded.

---

## Chapter 4.6 — Choosing the right primitive

Use this decision rule:

| If the guidance is... | Put it in... | Demo project example |
|---|---|---|
| Always true for the repo | Custom instructions | Keep Azure cost low; never commit secrets. |
| True only for a file type or folder | Targeted instructions | FastAPI rules for `app/**/*.py`. |
| A repeated task | Prompt file | Review deployment, draft spec, add tests. |
| A deterministic guard or automation | Hook | Ask before Azure write commands; run formatter after edits. |
| A persistent role | Custom agent | API platform reviewer in Module 5. |
| A multi-step capability | Skill | API observability review in Module 5. |
| A live external data/tool boundary | MCP | Read-only monitoring connector in Module 5. |

### The 30-second rule

Ask:

```text
Should this be always-on, invoked on demand, or enforced by code?
```

- **Always-on:** instruction.
- **On demand:** prompt file.
- **Guaranteed lifecycle automation:** hook.
- **Role with tools:** custom agent.
- **Procedure with references/scripts:** skill.
- **External system access:** MCP.

Examples:

- “Never commit secrets” is an instruction.
- “Review this Bicep and workflow for deployment readiness” is a prompt file.
- “Ask before running Azure write commands” can be a hook, after review.
- “Act as an API platform reviewer with refusal rules” is a custom agent.
- “Apply this observability review checklist” is a skill.

### Demo — move procedure out of instructions

Ask Copilot:

```text
Compare .github/copilot-instructions.md and .github/prompts/investigate-api-alert.prompt.md.
Which content belongs in always-on instructions, which belongs in the prompt file, and which — if any — would justify a hook?
Suggest one improvement without editing.
```

Expected result:

- Standing safety rules stay in `.github/copilot-instructions.md`.
- Detailed alert investigation steps stay in the prompt file.
- Hooks are proposed only for deterministic enforcement, not for long reasoning procedures.

---

## Chapter 4.7 — Create one new prompt file or hook design

Use this when the team identifies a repeated request not already covered.

### Demo A — design a new prompt

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

### Demo B — design a hook guard

Scenario:

> We want an optional guardrail that makes risky Azure write operations visible before an agent runs them.

Ask Copilot:

```text
Draft a hook design for a PreToolUse guard in copilot-ml.

The hook should:
- ask for confirmation before Azure write/deploy/delete commands
- allow read-only commands and local pytest
- avoid logging prompts, secrets, environment variables, or tokens
- have a timeout of 10 seconds or less

Do not create files. Return a design review table.
```

After review, decide whether the hook belongs in this repo, a facilitator-only branch, or a personal/user hook. For the base workshop, keep it as a design artifact unless the facilitator explicitly approves enabling hooks.

---

## Chapter 4.8 — Day-2 bootstrapping checklist

After the first few Copilot sessions, review what should become durable repo assets.

### Instructions

- [ ] Did `/init` produce useful repo instructions?
- [ ] Did a human remove obvious or duplicated facts?
- [ ] Are safety rules short and non-conflicting?
- [ ] Are file-specific rules kept out of always-on instructions?

### Prompt files

- [ ] Did a prompt get reused at least twice?
- [ ] Did reviews ask for the same output shape repeatedly?
- [ ] Does each prompt have a clear description and argument hint?
- [ ] Are tools restricted to the minimum needed for the task?
- [ ] Are no-edit or no-deploy boundaries explicit where needed?

### Hooks

- [ ] Is there a deterministic behavior that instructions cannot reliably enforce?
- [ ] Is the hook design reviewed like code?
- [ ] Is it short, local, auditable, and timeout-bounded?
- [ ] Does it avoid secrets and customer data?
- [ ] Is there a rollback path to disable it?

Turn only proven repetition or necessary enforcement into customization. This keeps the repo clean and prevents over-engineering.

---

## Chapter 4.9 — Anti-patterns

| Anti-pattern | Symptom | Fix |
|---|---|---|
| **Instruction dumping** | A long always-on file repeats every procedure and example. | Keep instructions short; move procedures into prompt files or skills. |
| **Prompt file sprawl** | Slash menu fills with commands no one uses. | Keep a small owned set; delete unused prompts. |
| **Hidden authority** | A review prompt can deploy or mutate live systems. | Restrict tools and state no-edit/no-deploy boundaries. |
| **No output shape** | A prompt produces essays instead of reviewable artifacts. | Require tables, checklists, issue bodies, or PR comments. |
| **Hook as policy theater** | A hook logs or warns but does not actually enforce the intended rule. | Decide whether the hook should ask, deny, block, or only observe. |
| **Unreviewed hook code** | A shell script runs with VS Code permissions but nobody reviewed it. | Review hooks like automation code; keep them small. |
| **Long-running hook** | Agent sessions feel stuck or expensive. | Keep hook timeouts short and avoid heavy work in lifecycle hooks. |
| **Hook edits itself** | Agent can modify scripts that later execute. | Protect hook scripts from auto-approved edits and require human review. |
| **Stop-hook loop** | A hook keeps preventing completion and burns turns. | Use `Stop` hooks sparingly and include loop protection. |
| **Secrets in hooks** | Hook command, env, or logs expose credentials. | Never hardcode secrets; avoid logging sensitive data. |
| **No owner** | Repo customization files drift and nobody knows who approves changes. | Assign owners for instructions, prompts, hooks, agents, and skills. |

---

## Chapter 4.10 — Lab connection

Use this lab in [Module 9](09-workshop-and-labs.md):

- [Lab 4a — Prompt file and hook design](09-workshop-and-labs.md#lab-4a--prompt-file-and-hook-design-2030-min)

This lab uses prompt files in `.github/prompts/` and treats hooks as a design exercise. Do not enable hooks during a customer workshop unless the facilitator and environment owner explicitly approve them.

---

> **Next:** [Module 5 — Custom agents, Skills, MCP](05-customize-agents-skills-mcp.md)
> **Back:** [Module 3 — Pick the Right Model](03-pick-the-right-model.md)
