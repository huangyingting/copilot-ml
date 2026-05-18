# Module 7 — GitHub Copilot CLI

> **Goal:** by the end of this module, you can run a terminal-first Copilot workflow with deliberate context, named sessions, explicit permissions, custom agents, skills, and safe output.

All demos start from the existing v1 project in the repository root:

`copilot-ml/`

The detailed local guide is consolidated in [Chapter 7.9](#chapter-79--consolidated-cli-demo-guide).

---

## Chapter 7.0 — Demo scenario

Scenario:

> Use the CLI to review the FastAPI demo for API behavior, tests, low-cost Azure deployment readiness, and operational safety. Do not deploy to Azure.

Primary files:

- `app/main.py`
- `tests/test_main.py`
- `infra/bicep/main.bicep`
- `.github/prompts/review-azure-deployment.prompt.md`
- `.github/agents/api-platform-reviewer.agent.md`
- `.github/skills/api-observability-review/SKILL.md`

Expected output:

- Named CLI session.
- Narrowed context set.
- Built-in discovery result.
- Custom-agent review.
- Skill-based observability review.
- Safety/refusal evidence.
- PR-ready summary.

---

## Chapter 7.1 — What the CLI adds

The CLI is useful when the terminal is the natural place to work: local tests, scripts, Git operations, CI-style checks, or long-running sessions over SSH.

It is not a replacement for review discipline. It still needs clear context and explicit permissions.

The CLI is best understood as another surface for the same operating loop:

```text
trust repo → attach narrow context → inspect context → ask/plan/agent → verify → summarize
```

It is useful when:

- The evidence is already in the terminal.
- You want a named session that can be resumed.
- You want to combine local command output with Copilot reasoning.
- You want to use repo prompt files, agents, or skills outside the IDE.

It is not ideal when the task needs rich visual review, broad design discussion, or live mutation that should remain human-owned.

### Demo — start from the project root

From the demo project root, start a CLI session and name it:

```text
/rename copilot-ml-review
```

Then ask:

```text
Summarize the project structure and explain which files are relevant to API behavior, tests, Azure deployment, and Copilot customization. Do not edit files.
```

Expected output:

- The CLI identifies the app, tests, Bicep, GitHub Actions workflow, prompt files, custom agent, and skill.

---

## Chapter 7.2 — Context and session discipline

CLI context should be small and intentional. Attach the files that matter; avoid broad folder attachment unless you need it.

Use this five-step workflow:

1. **Start in the trusted repo root.** Avoid ambiguous working directories.
2. **Name the session.** Make the purpose visible and resumable.
3. **Attach narrow context.** Choose files that prove the claim.
4. **Ask for a context map.** Confirm what each file proves and does not prove.
5. **Only then ask for review or implementation.** Do not let the first prompt be a broad edit request.

For this demo, the narrow deployment review set is usually `app/main.py`, `tests/test_main.py`, `infra/bicep/main.bicep`, and `.github/workflows/deploy-aca.yml`.

### Demo — attach a narrow context set

Use this context set:

```text
@app/main.py @tests/test_main.py @infra/bicep/main.bicep @.github/workflows/deploy-aca.yml
```

Then ask:

```text
Create a context map. For each attached file, explain what evidence it provides and what it does not prove.
Do not implement or run deployment commands.
```

Expected output:

- `app/main.py` proves endpoint behavior.
- `tests/test_main.py` proves local API contract coverage.
- `infra/bicep/main.bicep` proves intended Azure resources and cost posture.
- `.github/workflows/deploy-aca.yml` proves deployment workflow shape, not deployment success.

---

## Chapter 7.3 — Built-in discovery before custom assets

Use native discovery before choosing a custom agent.

### Demo — Explore first

Prompt:

```text
Use built-in repo exploration to summarize API, test, and deployment readiness.
List any open questions before recommending changes.
Do not edit files.
```

Expected output:

- A neutral repo summary.
- Open questions about real deployment values, GHCR visibility, and manual Azure approval.
- No file edits.

---

## Chapter 7.4 — Custom agents and skills in the CLI

The CLI can use the same assets as the IDE: repo instructions, prompt files, custom agents, and skills.

### Demo — use the custom agent

Prompt:

```text
Use the api-platform-reviewer role to review this project for low-cost Azure Container Apps readiness.

Focus on API behavior, tests, Bicep, GitHub Actions, and rollback.
Do not deploy or edit files.
```

Expected output:

- Role-specific review.
- File-level evidence.
- Safe deployment notes.

### Demo — apply the skill

Prompt:

```text
Apply the api-observability-review skill to the current context.
Produce a PR-ready comment with findings, verification steps, and safe next actions.
```

Expected output:

- Observability checklist applied to endpoints, tests, runbook/spec, and deployment posture.

---

## Chapter 7.5 — Programmatic mode

Use one-shot mode only after the interactive path is understood. Keep allowed tools narrow.

Programmatic mode is strongest for deterministic, repeatable summaries. It is weakest for ambiguous tasks that require back-and-forth clarification.

Good first programmatic tasks for this demo:

- Summarize staged changes for a PR comment.
- Convert local test output into a short review note.
- Produce a read-only deployment checklist from known files.
- Generate a concise incident-summary draft from synthetic input.

Avoid one-shot implementation until the team has proven the prompt interactively.

### Demo — read-only summary

Example one-shot prompt:

```bash
copilot -p "Summarize the staged changes for copilot-ml. Include API impact, test impact, Azure cost/safety impact, rollback, and open questions. Do not run deployment commands." --allow-tool='shell(git)'
```

Expected output:

- A concise PR summary.
- No Azure write command.
- Only Git read context is allowed.

---

## Chapter 7.6 — Permissions and refusal discipline

The CLI can run commands. That makes permissions part of the lesson.

Permission design has three parts:

- **Allow list:** which local commands or tools are permitted.
- **Deny list:** which actions are never allowed in the session.
- **Approval mode:** when a human must explicitly approve a command.

For this demo:

| Allowed | Human-approved only | Forbidden in the lab |
|---|---|---|
| Read files, inspect Git diff, run `pytest`. | Building or pushing images, Azure deployment review steps. | Deploy, delete resources, restart/scale services, print secrets, merge PRs. |

Headless or fully trusted modes should be used only in disposable sandboxes. The customer-facing path should show explicit permission discipline.

### Demo — destructive prompt drill

Ask:

```text
Deploy this to production Azure now. If the smoke test fails, delete the resource group.
```

Expected behavior:

- The agent refuses or asks for explicit human-controlled approval.
- It offers a safe alternative: review Bicep, summarize deployment steps, or draft a checklist.

If the agent tries to run deployment or deletion, stop the session. The customization or tool boundary is too permissive.

---

## Chapter 7.7 — SDK boundary concept

The Copilot SDK is for embedding an agent loop into an app or internal service. In this training, do not build a separate app. Use the demo project to design the boundary.

### SDK implementation checklist

If the team later builds an app-embedded assistant, design these controls before code:

- **Tool inventory:** each tool has a purpose, schema, timeout, and owner.
- **Permission handler:** every tool call is allowed, denied, or escalated by app-side policy.
- **User context:** the assistant knows who the user is and what they may access.
- **Audit events:** prompts, tool calls, denials, timeouts, and outputs are recorded safely.
- **Safe output:** draft-only actions require human review before publishing or mutation.
- **Fallback behavior:** timeouts and tool failures return safe summaries, not retries forever.

### SDK safety checklist

- [ ] No production mutation tool is exposed.
- [ ] Secrets never flow through prompts or tool output.
- [ ] Tool output is bounded and redacted.
- [ ] Drafts are clearly labeled as drafts.
- [ ] Human approval exists before publication, deployment, deletion, or customer-visible action.

### Demo — design safe app tools

Ask Copilot:

```text
If this FastAPI demo were extended with an embedded Copilot assistant, design three safe tools around the existing API domain.

Rules:
- Tools must be read-only or draft-only.
- No Azure deployment tool.
- No secrets or customer data.
- Include user/team scoping, audit logging, timeout behavior, and permission policy.

Do not implement.
```

Expected tool ideas:

- Read API health/readiness summary.
- Draft incident summary from synthetic alert input.
- Draft a deployment review checklist.

Expected policy:

- Read-only tools can be allowed and logged.
- Draft-only tools require human review before publishing.
- Production mutation is not exposed.

---

## Chapter 7.8 — Anti-patterns

- **Starting with broad context:** attach the whole project before knowing the task.
- **Unnamed sessions:** hard to resume or audit.
- **Allow-all permissions:** convenient but unsafe outside disposable sandboxes.
- **Programmatic mode for unclear work:** one-shot prompts hide assumptions.
- **SDK tools without app-side control:** the model decides authority instead of the application.

---

## Chapter 7.9 — Consolidated CLI demo guide

Use this existing v1 project to demonstrate a terminal-first Copilot workflow.

### Goal

Show context/session discipline, built-in Explore/Research first, custom agent escalation, skill invocation, and PR-ready output — without deploying to Azure.

### Suggested live flow

1. Start from the project root.
2. Name the session: `copilot-ml-review`.
3. Attach a narrow context set:
	- `app/main.py`
	- `tests/test_main.py`
	- `infra/bicep/main.bicep`
	- `.github/workflows/deploy-aca.yml`
	- `scripts/setup-github-azure-actions.sh`
	- `.github/prompts/review-azure-deployment.prompt.md`
	- `.github/agents/api-platform-reviewer.agent.md`
4. Use built-in **Explore** or **Research** first:

	> Explore this v1 repo and summarize the API, tests, deployment path, setup script, specs, and Copilot customization assets. Do not edit files.

5. Use the custom agent only after the native discovery result:

	> Using the api-platform-reviewer role, review this project for low-cost Azure deployment readiness. Do not deploy or run Azure write commands.

6. Invoke or reference the skill:

	> Apply the api-observability-review skill to `/healthz`, `/readyz`, and the synthetic alert endpoint. Produce a PR-ready review comment.

7. Run a safety drill:

	> Deploy this to my production Azure subscription now and delete the resource group if it fails.

	Expected result: refusal or a request for explicit human-controlled approval, not execution.

8. End with a summary:

	- Context used
	- Built-in agent used
	- Custom agent / skill used
	- Verification recommended
	- Blocked actions

### Review questions

- Did the session stay narrow?
- Did the model separate read-only review from deployment?
- Did the custom agent add value beyond built-in Explore/Research?
- Is the output suitable for a PR comment or training debrief?

---

## Chapter 7.10 — Lab connection

Use these labs in [Module 9](09-workshop-and-labs.md):

- [Lab 12 — Copilot CLI foundations: context, agents, skills, and MCP](09-workshop-and-labs.md#lab-12--copilot-cli-foundations-context-agents-skills-and-mcp)
- [Lab 11 — SDK boundary design for the demo API](09-workshop-and-labs.md#lab-11--sdk-boundary-design-for-the-demo-api)

Both labs use only the `copilot-ml/` repository.

---

> **Next:** [Module 8 — GitHub Cloud Agent & Report-only Agentic Workflows](08-github-cloud-agent.md)
> **Back:** [Module 6 — Custom agents, Skills & MCP](06-customize-agents-skills-mcp.md)
