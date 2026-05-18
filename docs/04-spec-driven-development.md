# Module 4 — Spec-Driven Development

> **Goal:** by the end of this module, you can turn a vague request into a reviewed spec before asking Copilot to implement anything.

All demos in this module use the same project:

`demo-projects/copilot-ml/`

This project is a minimal FastAPI service with health/readiness endpoints, synthetic Azure Monitoring-style alert evidence, tests, Docker, Azure Container Apps Bicep, prompt files, a custom agent, a skill, and cloud-agent artifacts.

---

## Chapter 4.0 — Demo scenario

Use one customer-safe request throughout the module:

> Improve the API observability baseline for `copilot-ml` without increasing Azure cost or adding live production dependencies.

The request is intentionally incomplete. The spec work is to make it reviewable.

**Project files used:**

- `demo-projects/copilot-ml/app/main.py`
- `demo-projects/copilot-ml/tests/test_main.py`
- `demo-projects/copilot-ml/infra/bicep/main.bicep`
- `demo-projects/copilot-ml/docs/specs/api-health-observability.spec.md`
- `demo-projects/copilot-ml/spec-kit/StakeholderDocuments/`

**Demo output:** a reviewed spec that says what will change, what is out of scope, how it is tested, what the operational impact is, and how rollback works.

---

## Chapter 4.1 — Why specs matter with Copilot

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
Use app/main.py, tests/test_main.py, infra/bicep/main.bicep, and docs/specs/api-health-observability.spec.md as context. Do not edit files.
```

Expected observations:

- “Better observability” is not testable yet.
- The desired endpoint or alert behavior is unclear.
- Cost guardrails must be preserved.
- Azure deployment must remain human-approved.
- Rollback and cleanup must be explicit.

---

## Chapter 4.2 — Lightweight spec workflow

Use lightweight specs for work that fits in one sprint and can be reviewed in one Markdown file.

Recommended location in the demo project:

`demo-projects/copilot-ml/docs/specs/`

The baseline example is:

`docs/specs/api-health-observability.spec.md`

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

Use this skeleton for new demo-project specs:

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
- docs/specs/api-health-observability.spec.md

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

## Chapter 4.3 — Formal Spec Kit workflow

Use formal Spec Kit-style artifacts when the work is larger, cross-team, customer-facing, or needs a durable audit trail.

The demo project includes local stakeholder documents so the exercise does not depend on external sample content:

`demo-projects/copilot-ml/spec-kit/StakeholderDocuments/`

### 4.3.1 When to use formal artifacts

| Use lightweight spec when | Use formal Spec Kit artifacts when |
|---|---|
| One file or one small feature | Multiple artifacts or phased delivery |
| One team owns the decision | Multiple roles must review |
| Implementation path is obvious | Architecture, rollout, or safety needs discussion |
| A single Markdown spec is enough | Constitution, spec, plan, and tasks are useful review gates |

### 4.3.2 Installation and current CLI syntax

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

### 4.3.3 Formal artifact flow

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

From the demo project, use these local inputs:

- `spec-kit/StakeholderDocuments/project-goals.md`
- `spec-kit/StakeholderDocuments/app-features.md`
- `spec-kit/StakeholderDocuments/tech-stack.md`
- `spec-kit/StakeholderDocuments/operational-guardrails.md`
- `spec-kit/StakeholderDocuments/lab-scorecard.md`

Prompt:

```text
Use the stakeholder documents in spec-kit/StakeholderDocuments/ to draft formal SDD artifacts for copilot-ml.

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

Review the generated artifacts with `spec-kit/StakeholderDocuments/lab-scorecard.md`.

---

## Chapter 4.4 — Specs and Plan Mode

Plan Mode works best when it can point to a spec. The spec supplies intent; Plan Mode supplies execution order.

### Demo — turn a spec into a plan

Use this prompt:

```text
Create an implementation plan for docs/specs/api-health-observability.spec.md.

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

## Chapter 4.5 — Review gates

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

## Chapter 4.6 — Lab connection

Use these labs in [Module 9](09-workshop-and-labs.md):

- [Lab 3 — Author a spec](09-workshop-and-labs.md#lab-3--author-a-spec)
- [Lab 3B — Formal Spec Kit greenfield SRE/development lab](09-workshop-and-labs.md#lab-3b--formal-spec-kit-greenfield-sredevelopment-lab)

Both labs use only `demo-projects/copilot-ml/`.

---

> **Next:** [Module 5 — Customize: Instructions & Prompt Files](05-customize-instructions-and-prompts.md)
> **Back:** [Module 3 — Pick the Right Model](03-pick-the-right-model.md)
