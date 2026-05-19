# Module 6 — Spec-Driven Development

> **Goal:** by the end of this module, you can turn a vague request into a reviewed spec before asking Copilot to implement anything.

All demos in this module start from the existing v1 project in the repository root:

`copilot-ml/`

This project is a minimal FastAPI service with health/readiness endpoints, synthetic Azure Monitoring-style alert evidence, tests, Docker, Azure Container Apps Bicep, GitHub Actions deployment workflow, setup script, specs, prompt files, a custom agent, a skill, and cloud-agent artifacts.

---

## Chapter 6.0 — Spec-first workflow and demo context

This module explains how to turn an incomplete request into a reviewed implementation spec. Use one customer-safe brownfield request throughout the module:

> Improve the existing `copilot-ml` API observability baseline without increasing Azure cost or adding live production dependencies.

The request is intentionally incomplete. The spec work is to make it reviewable.

**Project files used:**

- `app/main.py`
- `tests/test_main.py`
- `infra/bicep/main.bicep`
- `scripts/setup-github-azure-actions.sh`
- `specs/api-health-observability.spec.md`
- consolidated stakeholder inputs in [Chapter 6.3.4](#634-consolidated-spec-kit-demo-inputs)

**Demo output:** a reviewed spec that says what will change, what is out of scope, how it is tested, what the operational impact is, and how rollback works.

---

## Chapter 6.1 — Why specs matter with Copilot

Without a spec, an Agent Mode session often becomes this chain:

```text
vague intent → model interpretation → tool calls → diff → late review surprise
```

With a spec, the chain becomes:

```text
reviewed intent → plan → scoped implementation → diff review against acceptance criteria
```

The spec is not paperwork. It is the control surface for AI-assisted implementation.

### Demo — reject a vague request

Open the demo project and ask Copilot in Ask or Plan Mode:

```text
We need better observability for this API. What is missing from this request before implementation?
Use app/main.py, tests/test_main.py, infra/bicep/main.bicep, and specs/api-health-observability.spec.md as context. Do not edit files.
```

Expected observations:

- “Better observability” is not testable yet.
- The desired endpoint or alert behavior is unclear.
- Cost guardrails must be preserved.
- Azure deployment must remain human-approved.
- Rollback and cleanup must be explicit.

---

## Chapter 6.2 — Lightweight spec workflow

Use lightweight specs for work that fits in one sprint and can be reviewed in one Markdown file.

Recommended location in the demo project:

`specs/`

The baseline example is:

`specs/api-health-observability.spec.md`

The lightweight lifecycle is:

```text
request → draft spec → clarify gaps → review gates → plan → implement → verify → update spec if needed
```

The rule is simple: no implementation is requested until the API behavior, tests, cost guardrails, and rollback are written down.

### Required spec sections

| Section | Why it matters |
|---|---|
| Goal | Prevents the work from drifting. |
| Background | Explains why the change is needed now. |
| In scope | Tells Copilot what to deliver. |
| Out of scope | Tells Copilot what not to touch. |
| Acceptance criteria | Makes review and testing concrete. |
| Non-functional constraints | Captures cost, security, performance, and compatibility. |
| Operational impact | Identifies what changes for deploy, support, and monitoring. |
| Blast radius | Defines the maximum impact if the change fails. |
| Rollback | Keeps recovery human-owned and explicit. |
| Open questions | Prevents hidden assumptions. |

### Reusable spec template

Use this skeleton for new project specs:

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

### Demo — draft a lightweight spec

Use this prompt:

```text
Draft a lightweight spec for improving the copilot-ml observability baseline.

Context:
- app/main.py
- tests/test_main.py
- infra/bicep/main.bicep
- specs/api-health-observability.spec.md

Requirements:
- Keep Azure Container Apps low cost.
- Keep minReplicas at 0 and maxReplicas at 1.
- Do not add a database, cache, queue, or live external dependency.
- Add or improve tests for the behavior you propose.
- Include operational impact, blast radius, rollback, verification, and open questions.

Do not implement. Produce the spec only.
```

Review the output against the required sections. Reject the spec if it lacks out-of-scope, rollback, or cost constraints.

---

## Chapter 6.3 — Formal Spec Kit workflow

Use formal Spec Kit-style artifacts when the work is larger, cross-team, customer-facing, or needs a durable audit trail.

The demo project includes consolidated stakeholder inputs below so the exercise does not depend on external sample content.

### 6.3.1 When to use formal artifacts

| Use lightweight spec when | Use formal Spec Kit artifacts when |
|---|---|
| One file or one small feature | Multiple artifacts or phased delivery |
| One team owns the decision | Multiple roles must review |
| Implementation path is obvious | Architecture, rollout, or safety needs discussion |
| A single Markdown spec is enough | Constitution, spec, plan, and tasks are useful review gates |

### 6.3.2 Installation and current CLI syntax

For customer delivery, use the Spec Kit tooling already approved in the environment. Do not run installation commands during the customer-facing lab unless the environment owner has approved them.

Expected commands if Spec Kit is already available:

```bash
specify version
specify init --here --integration copilot --script sh
```

On Windows PowerShell:

```powershell
specify version
specify init --here --integration copilot --script ps
```

If the CLI is not available, run the lightweight spec lab instead. The learning goal is spec discipline, not tool installation.

### 6.3.3 Formal artifact flow

```text
constitution → specify → clarify → plan → tasks → analyze → implement only after review
```

Each step should produce a reviewable artifact. Human review is the gate between steps.

### Quality gates for formal SDD

| Gate | Question | Why it matters in the demo |
|---|---|---|
| Constitution | Are principles and non-negotiables clear? | Keeps low-cost, no-secrets, no-live-mutation rules visible. |
| Specify | Is the desired behavior testable? | Prevents “better observability” from staying vague. |
| Clarify | Are assumptions resolved before planning? | Avoids hidden dependencies or production data. |
| Plan | Is execution sequenced and scoped? | Keeps Agent Mode bounded. |
| Tasks | Are tasks small enough for PR review? | Makes Cloud Agent or local Agent work safe. |
| Analyze | Are risks, tradeoffs, and unknowns explicit? | Helps reviewers reject weak artifacts early. |

### Demo — use local stakeholder documents

From the demo project, use the consolidated stakeholder inputs in [Chapter 6.3.4](#634-consolidated-spec-kit-demo-inputs).

Prompt:

```text
Use the consolidated stakeholder inputs in Module 6 to draft formal SDD artifacts for copilot-ml.

Keep the MVP minimal:
- health/readiness behavior
- synthetic alert evidence
- incident summary helper
- tests
- Docker
- Azure Container Apps Bicep
- Copilot prompts, one custom agent, one skill, one CLI guide, and one Cloud Agent issue template

Do not include production auth, databases, customer data, or autonomous Azure deployment.
```

Review the generated artifacts with the scorecard in [Chapter 6.3.4](#634-consolidated-spec-kit-demo-inputs).

### 6.3.4 Consolidated Spec Kit demo inputs

These inputs replace the former Spec Kit subfolder. Keep them here so all curriculum documentation lives in the numbered module files.

#### Suggested flow

1. Initialize Spec Kit in a disposable branch or sandbox.
2. Use the stakeholder inputs in this section as the source material.
3. Use the stakeholder content with `/speckit.constitution`, `/speckit.specify`, `/speckit.clarify`, `/speckit.plan`, and `/speckit.tasks` if those commands are available.
4. Review each artifact with the scorecard below.

Demo prompt:

```text
Use the consolidated stakeholder inputs in Module 6 to create a formal Spec Kit package for the existing copilot-ml v1 app.
Keep the next increment minimal: FastAPI endpoint behavior, tests, Docker, Azure Container Apps Bicep, setup script, Copilot prompts, one custom agent, one skill, one CLI workflow guide, and one Cloud Agent issue template.
Do not include production auth, databases, customer data, or autonomous Azure deployment.
```

#### Project goals

**Business goal:** create a minimal, low-cost Python Web API demo that lets customer SRE/development teams practice Copilot Modules 1–8 against one coherent project.

Success metrics:

- Learners produce one reviewed spec.
- Learners use at least two prompt files.
- Learners smoke-test one custom agent and one skill.
- Learners run one CLI context/session exercise.
- Learners draft one Cloud Agent issue and one report-only workflow review.
- Azure deployment remains low-cost and deletable after the workshop.

Scope:

- FastAPI service with health/readiness and synthetic alert context.
- Tests, Dockerfile, Bicep, GitHub Actions, setup script, prompt files, custom agent, skill, and demo docs.

Non-goals:

- Real production traffic.
- Real enterprise-context exports.
- Production authentication, database, or private network.
- Automatic remediation or autonomous Azure deployment.

#### App features

1. **Health endpoint:** `GET /healthz` supports workshop smoke tests and Container Apps probes. It returns service name, version, environment, and stable status.
2. **Readiness endpoint:** `GET /readyz` labels demo-only dependencies clearly instead of pretending real dependencies exist.
3. **Synthetic Azure Monitor alert evidence:** `GET /api/alerts/noisy-checkout-error` returns a synthetic alert snapshot with severity, current/baseline error rate, recent change, runbook pointer, and KQL-style query.
4. **Incident summary helper:** `POST /api/incidents/summarize` accepts symptoms and recent changes, then returns ranked hypotheses with read-only validation steps.
5. **Deployment review surface:** Bicep and GitHub Actions allow learners to review cost, scale, registry, identity, and rollback decisions.

#### Tech stack

Runtime:

- Python 3.11+
- FastAPI
- Uvicorn
- Pydantic models

Testing:

- Pytest
- FastAPI TestClient

Packaging:

- Dockerfile based on `python:3.12-slim`
- GHCR image for workshop deployment

Azure:

- Azure Container Apps Consumption
- Bicep for resources
- GitHub Actions OIDC for Azure login
- No default Azure Container Registry
- No database or cache

Constraints:

- Keep the app small enough to understand during a live demo.
- Keep Azure resources deletable as one resource group.
- Prefer exported or synthetic evidence over live customer data.

#### Operational guardrails

Safety:

- Agents may draft specs, code, tests, Bicep, workflows, and PR comments.
- Agents may run local tests if dependencies are installed.
- Agents must not run Azure write commands without explicit human approval.
- Agents must not deploy, delete resource groups, or change public endpoint exposure autonomously.

Cost:

- Container Apps must use Consumption scale.
- `minReplicas` must remain `0` for the demo.
- `maxReplicas` must remain `1` unless a reviewed spec says otherwise.
- Avoid ACR, databases, caches, and private networking for the base workshop.

Observability:

- Health and readiness endpoints must be testable.
- Synthetic alert evidence must be labeled synthetic.
- Triage output must separate facts, hypotheses, and read-only next checks.

Rollback and cleanup:

- Rollback is PR revert or redeploy prior image.
- Cleanup is manual deletion of the demo resource group after workshop approval.
- No automated deletion workflow is included by default.

#### Spec Kit lab scorecard

Use this scorecard to review generated Spec Kit artifacts.

| Area | Pass criteria |
|---|---|
| Problem framing | Explains why the demo project exists and which modules it supports. |
| Scope | Keeps the MVP to FastAPI, tests, Docker, Bicep, prompts, agent, skill, CLI, and cloud-agent artifacts. |
| Out of scope | Excludes production auth, real data, databases, and autonomous remediation. |
| Acceptance | Health/readiness, synthetic alert, incident summary, tests, and deployment review are testable. |
| Operations | Includes observability, cost, rollback, and cleanup. |
| Safety | Blocks secrets, live Azure mutation, and customer data. |
| Cost | Preserves Container Apps scale-to-zero and avoids unnecessary paid services. |

Decision options:

- **Approved:** ready for implementation.
- **Approve with comments:** minor wording or test criteria gaps.
- **Request changes:** scope, safety, cost, or rollback gaps must be fixed before implementation.

---

## Chapter 6.4 — Specs and Plan Mode

Plan Mode works best when it can point to a spec. The spec supplies intent; Plan Mode supplies execution order.

### Demo — turn a spec into a plan

Use this prompt:

```text
Create an implementation plan for specs/api-health-observability.spec.md.

Use only this demo project.
Read app/main.py, app/models.py, tests/test_main.py, infra/bicep/main.bicep, and README.md.

The plan must include:
- files likely to change
- exact test commands
- Azure deployment review steps
- rollback and cleanup
- out-of-scope items

Do not implement.
```

Expected plan sections:

- Goal
- Files/context inspected
- Implementation steps
- Verification
- Rollback/cleanup
- Open questions

---

## Chapter 6.5 — Review gates

Every generated spec or plan should pass review before implementation.

| Gate | Review question | Demo project example |
|---|---|---|
| Scope | Is the change small enough? | Only health/readiness/alert behavior, not auth or database. |
| Cost | Does it preserve low-cost Azure settings? | `minReplicas: 0`, `maxReplicas: 1`, GHCR default. |
| Tests | Can acceptance be verified locally? | `pytest` covers endpoint behavior. |
| Operations | Is rollback/cleanup clear? | Revert PR or delete demo resource group manually. |
| Safety | Are live writes blocked? | No autonomous Azure deployment or deletion. |

### Spec anti-patterns

- **Implementation disguised as spec:** jumps straight to code changes without acceptance criteria.
- **No out-of-scope:** allows auth, database, queue, deployment, or real monitoring to sneak in.
- **No rollback:** assumes every generated change will work.
- **No local proof:** leaves reviewers with only AI claims.
- **No cost constraint:** accidentally changes scale, resource shape, or deployment assumptions.
- **No owner:** leaves open questions unresolved.

### Demo — reject and revise

Ask Copilot:

```text
Review this spec against the five gates: scope, cost, tests, operations, and safety.
Find at least three issues or risks.
Then propose a revised version of the weakest section.
```

The goal is to practice rejecting a polished but incomplete artifact.

---

## Chapter 6.6 — Lab connection

Use these labs in [Module 9](09-workshop-and-labs.md):

- [Lab 3 — Author a spec](09-workshop-and-labs.md#lab-3--author-a-spec)
- [Lab 3B — Formal Spec Kit brownfield SRE/development lab](09-workshop-and-labs.md#lab-3b--formal-spec-kit-brownfield-sredevelopment-lab)

Both labs use only the `copilot-ml/` repository.

---

> **Next:** [Module 7 — GitHub Copilot CLI](07-copilot-cli.md)
> **Back:** [Module 5 — Custom Agents, Skills & MCP](05-customize-agents-skills-mcp.md)
