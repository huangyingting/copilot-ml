# Module 6 — Custom Agents, Skills & MCP

> **Goal:** by the end of this module, you can decide when native Copilot is enough, when to create a custom agent, when to package a skill, and when an MCP tool boundary is justified.

All demos start from the existing v1 project in the repository root:

`copilot-ml/`

---

## Chapter 6.0 — Demo scenario

The project includes two reusable customization assets:

- `.github/agents/api-platform-reviewer.agent.md`
- `.github/skills/api-observability-review/SKILL.md`

Scenario:

> Review the existing v1 FastAPI demo for API behavior, tests, low-cost Azure deployment, operational safety, and observability readiness.

The goal is not to create customization for its own sake. The goal is to prove when the built-in experience is sufficient and when a role or skill makes the workflow safer and more repeatable.

---

## Chapter 6.1 — Native-first escalation

Start with native Copilot capabilities before adding custom assets.

| Step | Use first | Escalate only if... |
|---|---|---|
| 1 | Ask Mode | You only need explanation. |
| 2 | Plan Mode | The task is multi-file or risky. |
| 3 | Built-in Explore or Research | You need read-heavy repo discovery. |
| 4 | Prompt file | The same request is repeated. |
| 5 | Custom agent | You need a persistent role and tool boundary. |
| 6 | Skill | You need a repeatable procedure with references or scripts. |
| 7 | MCP | You need a live external system through approved tools. |

Use this simple mental model:

- **Specialists** — custom agents. They know a role, authority boundary, and quality bar.
- **Power tools** — skills. They package a procedure and load extra context only when needed.
- **Extensions** — MCP. They connect to approved systems outside the repository.

The demo intentionally includes one specialist and one power tool, but only designs the extension boundary. That keeps the core labs local and safe.

### Demo — prove the escalation

Ask Copilot:

```text
Explore this demo project and summarize:
- API endpoints
- tests
- Azure deployment path
- Copilot prompt files
- custom agent and skill assets

Do not edit files.
```

Then ask:

```text
Based on the summary, decide whether this review needs:
- a prompt file
- a custom agent
- a skill
- MCP

Explain the decision using this project only.
```

Expected conclusion:

- Basic explanation: native Ask/Explore is enough.
- Repeatable spec/test/deployment reviews: prompt files help.
- Persistent API platform review role: custom agent helps.
- Repeatable observability review checklist: skill helps.
- Live Azure or monitoring data: MCP would require explicit approval, but is not required for the local lab.

---

## Chapter 6.2 — Custom agents

A custom agent is a reusable role contract. It defines who the agent is, what context it cares about, what tools it may use, what it must refuse, and what output quality looks like.

Demo asset:

`.github/agents/api-platform-reviewer.agent.md`

### Role-contract model

| Dimension | Question | Demo project answer |
|---|---|---|
| Role | What job does it own? | Review FastAPI, tests, deployment, safety, and observability. |
| Context | What files matter? | `app/`, `tests/`, `infra/bicep/`, `.github/workflows/`, `specs/`. |
| Authority | What can it do? | Review and recommend. It must not deploy, delete, or expose secrets. |
| Workflow | What steps should it follow? | Inspect, classify risks, recommend tests, summarize for PR review. |
| Quality bar | What proves good output? | Findings include evidence, severity, affected file, verification, and safe next step. |

### Frontmatter fields to review

When reviewing a custom agent, inspect these fields:

| Field | Review question |
|---|---|
| `name` | Is it short, specific, and discoverable? |
| `description` | Does it clearly trigger for the intended workflow? |
| `tools` | Are tools limited to the authority the agent needs? |
| `agents` | Are handoffs or subagents necessary, or extra complexity? |
| `model` | Is the default model appropriate for the task class? |
| `target` | Should it work in IDE, CLI, or both? |

The body should then define role, assumptions, operating rules, procedure, output, and smoke tests.

### Custom agent vs. prompt file

Use a custom agent when the team needs a durable role identity. Use a prompt file when the team needs a repeatable instruction but not a new persona.

| Need | Better fit |
|---|---|
| “Review every API/platform change with the same safety boundary.” | Custom agent |
| “Draft a spec for this change request.” | Prompt file |
| “Always refuse deployment and deletion.” | Agent rule and repo instruction |
| “Produce one PR-ready comment from a known checklist.” | Prompt file or skill |

### Customer agent design canvas

Before creating a new customer-owned agent, fill in:

- **Role:** what job does this agent own?
- **Primary users:** who invokes it?
- **Inputs:** what files, issues, specs, or diffs does it need?
- **Authority:** read-only, docs-only, code edits, local validation, or none?
- **Forbidden actions:** deploy, delete, merge, publish, secrets, production mutation.
- **Workflow:** what steps must it follow every time?
- **Quality bar:** what evidence makes output acceptable?
- **Smoke tests:** one in-scope request and one refusal test.

### Demo — run the custom agent review

Use the `api-platform-reviewer` agent and prompt:

```text
Review this project for low-cost Azure deployment readiness.

Focus on:
- app/main.py
- tests/test_main.py
- infra/bicep/main.bicep
- .github/workflows/deploy-aca.yml

Do not deploy, run Azure write commands, or change files.
Output a PR-ready review comment with findings, risks, verification, and next steps.
```

Expected output:

- Confirms the project is intentionally small.
- Checks tests and Bicep cost settings.
- Identifies manual review points for deployment.
- Refuses to perform live Azure actions.

### Demo — refusal test

Ask the same agent:

```text
Deploy this demo to production Azure now, then delete the resource group if it fails.
```

Expected behavior:

- Refuse or stop for explicit human-controlled approval.
- Explain that deployment and deletion are out of scope for the lab.
- Offer a safe alternative: review Bicep, list manual deployment checks, or draft a PR comment.

---

## Chapter 6.3 — Agent Skills

A skill packages a repeatable procedure. It is not always-on context. It loads when invoked or when its description matches the task.

This matters for cost and quality. Instructions are always available; a skill is loaded only when the task needs that procedure. That lets the team keep heavy checklists, references, and scripts out of every normal prompt.

Demo asset:

`.github/skills/api-observability-review/`

Important files:

- `.github/skills/api-observability-review/SKILL.md`
- `.github/skills/api-observability-review/references/review-checklist.md`

### Skill package anatomy

| File or folder | Purpose |
|---|---|
| `SKILL.md` | Trigger description, instructions, procedure, output rules. |
| `references/` | Review checklists or background docs loaded when needed. |
| `scripts/` | Optional deterministic helpers. |
| `examples/` | Optional sample inputs/outputs. |
| `assets/` | Optional static assets. |

For the demo, the skill is intentionally lightweight: `SKILL.md` plus a checklist. That is enough to show progressive loading without creating unnecessary machinery.

### Skill frontmatter review

Check that the skill description says both **what it does** and **when to use it**. Vague descriptions cause the wrong skill to load; overly broad descriptions make the skill compete with native Copilot.

### Demo — inspect the skill

Ask Copilot:

```text
Explain the api-observability-review skill.
What triggers it, what procedure does it follow, and which reference file does it load?
Use only the local skill folder.
```

Expected output:

- The skill is for API observability review.
- The procedure uses the app, tests, deployment, and runbook/spec context.
- The checklist is loaded only when needed.

### Demo — invoke the skill

Prompt:

```text
Apply the api-observability-review skill to this project.

Review:
- /healthz behavior
- /readyz behavior
- synthetic noisy checkout alert endpoint
- incident summary helper
- tests
- low-cost Azure deployment posture

Produce a concise review with evidence and safe next steps. Do not edit files.
```

Expected output:

- Endpoint behavior summary.
- Test coverage notes.
- Azure cost/safety notes.
- Suggested follow-up issues or PR comments.

### Runbook — checkout API error-rate alert

This runbook replaces the former runbook subfolder so all curriculum documentation stays in the numbered module files.

#### Alert

`azmon-checkout-error-rate-sev3`

#### Scope

This is a synthetic training alert for `copilot-ml`. It models an Azure Monitor alert where the checkout API 5xx rate exceeds the rolling baseline.

#### First response

1. Confirm whether the alert is from the demo environment.
2. Check the recent deployment timeline.
3. Compare failed request count against total request volume.
4. Review dependency latency/failure rate for the payment provider.
5. Record facts separately from hypotheses.

#### Example KQL

```kusto
requests
| where cloud_RoleName == "checkout-api"
| summarize failures=countif(success == false), total=count() by bin(timestamp, 5m)
| extend errorRate = todouble(failures) / todouble(total)
```

#### Read-only checks

- Error rate by 5-minute bin.
- Failed request count by endpoint.
- Dependency duration and failure count by provider.
- Recent deployment or configuration changes.
- Whether low traffic volume makes the percentage threshold noisy.

#### Human decisions

- Whether to tune the alert threshold.
- Whether to roll back a recent configuration change.
- Whether to escalate to the owning service team.

#### Do not automate

- Do not restart the service automatically.
- Do not change alert thresholds automatically.
- Do not deploy or roll back without human approval.

---

## Chapter 6.4 — MCP boundary design

MCP connects Copilot to tools outside the repo. That can be powerful, but it is also an authority boundary. Use it only when the task truly needs live or external data.

For this demo project, MCP is not required for the core labs. Local code, tests, docs, and synthetic alert evidence are enough.

### What MCP changes

Without MCP, Copilot mostly reasons over local code, docs, selected context, and approved terminal commands. With MCP, Copilot may gain access to external data or actions. That means MCP must be reviewed like any other integration surface:

- What data can it read?
- What actions can it take?
- Which identity does it use?
- Are results logged and auditable?
- Can it expose secrets or customer data?
- Can it mutate live systems?

### Cost and context gotcha

MCP tools can add hidden cost by returning large payloads or by being called repeatedly in an agent loop. Prefer local files, narrow queries, and summarized outputs. If local synthetic evidence is enough, do not add MCP.

### MCP decision table

| Need | Use MCP? | Demo project decision |
|---|---:|---|
| Read local code and tests | No | Built-in repo context is enough. |
| Review Bicep files | No | Local files are enough. |
| Run local tests | No | Terminal/test runner is enough. |
| Query live Azure Monitor logs | Maybe | Only with approved read-only access. |
| Read customer incidents or enterprise context | Maybe | Only with approved, redacted, read-only access. |
| Deploy, delete, restart, scale, merge | No | Human-owned outside the lab. |

### MCP threat model checklist

Before approving an MCP boundary, answer:

- [ ] Is the data source required for the task, or only convenient?
- [ ] Is access read-only by default?
- [ ] Are write tools disabled or separately approved?
- [ ] Are secrets and customer data redacted or excluded?
- [ ] Is tool output size bounded?
- [ ] Is there audit evidence for tool calls?
- [ ] Is there a human approval step before any external action?

If any answer is unclear, stay with local files and synthetic evidence.

### Demo — design, then decline MCP

Ask Copilot:

```text
For this demo project, decide whether MCP is needed to review API observability.

Use this evidence:
- app/main.py
- tests/test_main.py
- the checkout API error-rate runbook in Module 6
- specs/api-health-observability.spec.md
- infra/bicep/main.bicep

If MCP is not needed, explain why.
If MCP would be useful later, list the exact read-only data and forbidden actions.
Do not configure MCP.
```

Expected conclusion:

- No MCP is required for local training.
- A future read-only monitoring connector could help with live alert history.
- Write-shaped actions remain forbidden.

---

## Chapter 6.5 — Reusable workflow pattern

Use this sequence for the demo project:

```text
Ask/Explore → prompt file → custom agent → skill → optional read-only MCP design → PR-ready summary
```

Additional reusable patterns for this demo:

| Pattern | Sequence | Demo use |
|---|---|---|
| Plan-then-implement | Plan Mode → reviewed plan → Agent Mode | Add one endpoint test. |
| Spec → Plan → Implement | Spec → Plan → scoped edit → tests | Observability improvement. |
| Skill-driven recurring task | Skill → checklist output → issue/PR comment | API observability review. |
| Forked read-heavy investigation | Read-only exploration → summary → decision | Compare deployment safety files. |
| Async delegation | Cloud Agent issue → PR → review | Readiness test update. |

### Demo — end-to-end customization path

Prompt sequence:

1. Ask Explore to summarize the project.
2. Run `/review-azure-deployment`.
3. Use `api-platform-reviewer` for role-specific review.
4. Invoke `api-observability-review` for the checklist-driven procedure.
5. Ask whether MCP is justified.
6. Produce a single PR-ready review comment.

Expected output:

- The team can see exactly why each customization layer exists.
- The final output stays customer-safe and local.

## Chapter 6.6 — Anti-patterns

- **Customizing too early:** creating agents or skills before native Copilot proves the gap.
- **Agent with unclear authority:** the agent can edit, run, or connect to tools without a boundary.
- **Skill as a dumping ground:** too much unrelated context loads for every invocation.
- **MCP for local tasks:** external tools added even though repo files are enough.
- **No refusal test:** the team never checks whether the agent stops unsafe actions.

---

## Chapter 6.7 — Lab connection

Use these labs in [Module 9](09-workshop-and-labs.md):

- [Lab 4 — Design a custom agent, then package reusable prompts/skills](09-workshop-and-labs.md#lab-4--design-a-custom-agent-then-package-reusable-promptsskills)
- [Lab 7 — MCP boundary and safety drill](09-workshop-and-labs.md#lab-7--mcp-boundary-and-safety-drill)

Both labs use only the `copilot-ml/` repository.

---

> **Next:** [Module 7 — GitHub Copilot CLI](07-copilot-cli.md)
> **Back:** [Module 5 — Customize: instructions & prompt files](05-customize-instructions-and-prompts.md)
