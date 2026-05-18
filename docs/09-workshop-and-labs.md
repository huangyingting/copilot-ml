# Module 9 — Hands-on Labs with copilot-ml

> **Goal:** complete a clean, customer-facing lab path where every activity uses the same runnable project and produces a reviewable artifact.

All labs use:

`demo-projects/copilot-ml/`

This module replaces the older mixed scenario labs. It does not require external sample apps, external learning content, production credentials, real incidents, or broad cloud access.

---

## Chapter 9.0 — Lab environment

Start from the demo project root:

`copilot-enablement/demo-projects/copilot-ml/`

Core files:

- `app/main.py`
- `app/models.py`
- `tests/test_main.py`
- `infra/bicep/main.bicep`
- `.github/copilot-instructions.md`
- `.github/prompts/`
- `.github/agents/api-platform-reviewer.agent.md`
- `.github/skills/api-observability-review/`
- `docs/specs/api-health-observability.spec.md`
- `docs/cli/module-7-demo.md`
- `docs/cloud-agent/module-8-issue-to-pr-demo.md`
- `.github/workflows/daily-api-health-review.md`

Recommended local validation command:

```bash
pytest
```

Safety boundaries for every lab:

- Do not use production data.
- Do not store secrets in prompts, docs, issues, logs, or workflow files.
- Do not deploy to production Azure.
- Do not delete Azure resources from an agent session.
- Treat deployment as human-approved and PR-shaped.
- Keep `minReplicas: 0`, `maxReplicas: 1`, `0.25` vCPU, and `0.5Gi` memory unless the lab explicitly asks for a review discussion.

---

## Chapter 9.1 — Demo and lab coverage map

| Module | Knowledge point | Demo project asset | Hands-on lab |
|---|---|---|---|
| Module 4 | Vague request → lightweight spec | `docs/specs/api-health-observability.spec.md` | [Lab 3](#lab-3--author-a-spec) |
| Module 4 | Formal SDD artifacts | `spec-kit/StakeholderDocuments/` | [Lab 3B](#lab-3b--formal-spec-kit-greenfield-sredevelopment-lab) |
| Module 5 | Custom instructions | `.github/copilot-instructions.md`, `AGENTS.md` | [Lab 4a](#lab-4a--prompt-file-1520-min) |
| Module 5 | Prompt files | `.github/prompts/` | [Lab 4a](#lab-4a--prompt-file-1520-min) |
| Module 6 | Native-first escalation | whole project | [Lab 5](#lab-5--native-first-review-and-escalation) |
| Module 6 | Custom agent role contract | `.github/agents/api-platform-reviewer.agent.md` | [Lab 4](#lab-4--design-a-custom-agent-then-package-reusable-promptsskills) |
| Module 6 | Skill procedure | `.github/skills/api-observability-review/` | [Lab 6](#lab-6--api-observability-skill-review) |
| Module 6 | MCP boundary design | local evidence files | [Lab 7](#lab-7--mcp-boundary-and-safety-drill) |
| Module 7 | CLI context and sessions | `docs/cli/module-7-demo.md` | [Lab 12](#lab-12--copilot-cli-foundations-context-agents-skills-and-mcp) |
| Module 7 | SDK boundary concept | app endpoints and incident models | [Lab 11](#lab-11--sdk-boundary-design-for-the-demo-api) |
| Module 8 | Cloud Agent issue-to-PR | `docs/cloud-agent/module-8-issue-to-pr-demo.md` | [Lab 8](#lab-8--cloud-agent-readiness-test-issue-to-pr) |
| Module 8 | Report-only workflow | `.github/workflows/daily-api-health-review.md` | [Lab 13](#lab-13--report-only-agentic-workflow-review) |

---

## Chapter 9.2 — Recommended lab path

Run the labs in this order for a complete Modules 4–8 path:

1. Lab 1 — Project orientation.
2. Lab 2 — Ask, Plan, and Agent mode on the demo project.
3. Lab 3 — Author a spec.
4. Lab 4a — Use and improve a prompt file.
5. Lab 4 — Review the custom agent role contract.
6. Lab 5 — Native-first escalation.
7. Lab 6 — Skill-based observability review.
8. Lab 7 — MCP boundary and safety drill.
9. Lab 12 — CLI workflow.
10. Lab 8 — Cloud Agent issue-to-PR.
11. Lab 13 — Report-only workflow review.
12. Lab 11 — SDK boundary design, optional for app teams.

Labs 9 and 10 are optional wrap-up labs for model/cost comparison and pilot planning, still using the same project.

### Choose the path

Use the full path for teams that want end-to-end adoption. Use focused paths when time is limited:

| Customer need | Recommended labs | Result |
|---|---|---|
| Safe first use | Labs 1–2 | Mode choice and supervised implementation. |
| Better requirements | Labs 3 and 3B | Lightweight and formal spec artifacts. |
| Reusable repo assets | Labs 4a, 4, 5, 6 | Instructions, prompts, agent, and skill decisions. |
| Tool boundary design | Labs 7, 11 | MCP and SDK authority decisions. |
| Terminal-first workflow | Lab 12 | CLI context/session summary. |
| Async PR delegation | Lab 8 | Cloud Agent-ready issue and review checklist. |
| Safe repository automation | Lab 13 | Report-only workflow safety decision. |
| Adoption planning | Labs 9–10 | Model/cost recommendation and pilot scope. |

### Lab operating pattern

Each lab follows the same pattern:

```text
orient → prompt → inspect output → compare with local evidence → revise or reject → save artifact
```

The saved artifact matters more than the chat transcript. A useful artifact can be reused in a PR, issue, prompt file, agent, skill, or pilot plan.

---

## Chapter 9.3 — Hands-on labs

Before each lab:

- Start from `demo-projects/copilot-ml/`.
- Confirm the task is read-only unless the lab explicitly approves a scoped local edit.
- Attach only the files the lab names.
- Keep output in a reviewable shape: table, checklist, issue body, PR comment, or spec.
- Stop if Copilot reaches for deployment, deletion, secrets, broad refactors, or unrelated files.

### Lab 1 — Project orientation

**Time:** 20 min  
**Outcome:** you can explain the demo project's app, tests, deployment path, and Copilot customization assets.

#### Steps

1. Open `demo-projects/copilot-ml/` in VS Code.
2. Read `README.md` and `docs/module-demo-map.md`.
3. Ask Copilot:

   ```text
   Summarize this project for a new SRE/development learner.
   Include API endpoints, tests, Azure deployment, prompt files, custom agent, skill, CLI guide, and cloud-agent artifacts.
   Do not edit files.
   ```

4. Compare the answer to the actual file tree.
5. Save a short note with:
   - what the app does
   - what is intentionally demo-only
   - what must never be automated

#### Acceptance

- You can name the four main API endpoints.
- You can name the local test command.
- You can identify the custom agent and skill folders.
- You can explain why Azure deployment is human-approved.

---

### Lab 2 — Ask, Plan, and Agent mode on the demo project

**Time:** 30–40 min  
**Outcome:** you can choose the right Copilot mode for explanation, planning, and implementation.

#### Steps

1. Ask Mode:

   ```text
   Explain what /healthz and /readyz do in app/main.py. Do not edit files.
   ```

2. Plan Mode:

   ```text
   Plan how to add one test assertion that /readyz includes demo dependency statuses.
   Include files, verification, out-of-scope, and rollback. Do not implement.
   ```

3. Agent Mode on a disposable branch:

   ```text
   Implement only the approved test assertion from the plan. Stop after editing tests/test_main.py and run pytest.
   ```

4. Review the diff.
5. Keep or discard the change based on the local result.

#### Acceptance

- Ask Mode produced explanation only.
- Plan Mode produced a reviewable plan.
- Agent Mode touched only expected files.
- A human reviewed the diff and test result.

---

### Lab 3 — Author a spec

**Time:** 45 min  
**Outcome:** you produce a lightweight spec for a small API observability improvement.

#### Steps

1. Open `docs/specs/api-health-observability.spec.md`.
2. Use the prompt:

   ```text
   Draft a lightweight spec for improving the copilot-ml observability baseline.

   Context:
   - app/main.py
   - app/models.py
   - tests/test_main.py
   - infra/bicep/main.bicep
   - docs/runbooks/checkout-error-rate.md

   Requirements:
   - Keep the demo low cost.
   - No production dependencies.
   - No database, queue, or cache.
   - Include acceptance criteria, out-of-scope, operational impact, blast radius, rollback, and verification.
   - Do not implement.
   ```

3. Review the generated spec.
4. Ask Copilot to revise one weak section.
5. Save the final spec as a lab artifact or PR draft.

#### Acceptance

- The spec includes out-of-scope, rollback, and verification.
- The spec preserves Azure cost constraints.
- At least one section was revised after human review.

---

### Lab 3B — Formal Spec Kit greenfield SRE/development lab

**Time:** 60–90 min  
**Outcome:** you use the local stakeholder documents to practice formal SDD artifacts without external sample content.

#### Steps

1. Open `spec-kit/StakeholderDocuments/`.
2. Read:
   - `project-goals.md`
   - `app-features.md`
   - `tech-stack.md`
   - `operational-guardrails.md`
   - `lab-scorecard.md`
3. If Spec Kit commands are available in your environment, initialize or use the existing local Spec Kit flow approved for the lab.
4. If Spec Kit commands are not available, ask Copilot to simulate the artifact set in Markdown using only the local stakeholder documents.
5. Produce or review these artifacts:
   - constitution/principles
   - spec
   - plan
   - tasks
   - analysis findings
6. Score the artifacts using `lab-scorecard.md`.

#### Acceptance

- Artifacts are based on local stakeholder documents.
- No external sample app is referenced.
- At least one generated artifact is rejected or revised.
- Implementation is not started until artifacts are reviewed.

---

### Lab 4a — Prompt file (15–20 min)

**Time:** 15–20 min  
**Outcome:** you run one existing prompt file and propose one improvement.

#### Steps

1. Open `.github/prompts/`.
2. Pick one prompt:
   - `draft-api-spec.prompt.md`
   - `review-azure-deployment.prompt.md`
   - `add-health-check-tests.prompt.md`
   - `investigate-api-alert.prompt.md`
   - `cloud-agent-task.prompt.md`
3. Run one prompt, for example:

   ```text
   /review-azure-deployment target: infra/bicep/main.bicep and .github/workflows/deploy-aca.yml
   ```

4. Review the output.
5. Propose one prompt improvement but do not commit it until reviewed.

#### Acceptance

- The prompt runs and produces task-specific output.
- Output stays within demo boundaries.
- One concrete improvement is identified.

---

### Lab 4 — Design a custom agent, then package reusable prompts/skills

**Time:** 60–75 min  
**Outcome:** you understand the `api-platform-reviewer` role contract and can design a similar customer-owned agent.

#### Steps

1. Open `.github/agents/api-platform-reviewer.agent.md`.
2. Identify:
   - role
   - context
   - authority
   - workflow
   - quality bar
   - refusal rules
3. Ask Copilot:

   ```text
   Review api-platform-reviewer.agent.md as a role contract.
   Does it have a clear role, context, authority, workflow, quality bar, and refusal rules?
   Recommend improvements without editing.
   ```

4. Run the in-scope review prompt from Module 6.
5. Run the refusal test:

   ```text
   Deploy this demo to production Azure now and delete failed resources automatically.
   ```

6. Open `.github/skills/api-observability-review/SKILL.md` and compare what belongs in the agent vs. the skill.

#### Acceptance

- You can explain why the agent is a role, not just a prompt.
- You can explain why the skill is a procedure, not always-on instructions.
- The unsafe prompt is refused or stopped.

---

### Lab 5 — Native-first review and escalation

**Time:** 30 min  
**Outcome:** you can decide when to stop at native Copilot and when to escalate to prompt, agent, skill, or MCP.

#### Steps

1. Ask native Copilot to summarize the project.
2. Use `/review-azure-deployment` for a repeated task.
3. Use `api-platform-reviewer` for a role-specific review.
4. Use `api-observability-review` for a procedure-specific review.
5. Ask whether MCP is required.

#### Acceptance

- You produce a short escalation decision table.
- MCP is not added unless a concrete read-only live-data need exists.
- The final output is a PR-ready review summary.

---

### Lab 6 — API observability skill review

**Time:** 30–45 min  
**Outcome:** you apply the skill checklist to the API and produce a concise observability review.

#### Steps

1. Open `.github/skills/api-observability-review/SKILL.md`.
2. Open `.github/skills/api-observability-review/references/review-checklist.md`.
3. Ask Copilot:

   ```text
   Apply the api-observability-review skill to this project.
   Focus on /healthz, /readyz, /api/alerts/noisy-checkout-error, /api/incidents/summarize, tests, runbook, spec, and Azure Container Apps posture.
   Do not edit files.
   ```

4. Review the generated findings.
5. Convert the best finding into a follow-up issue body.

#### Acceptance

- The review cites local files.
- Recommendations are safe and scoped.
- At least one follow-up issue is drafted.

---

### Lab 7 — MCP boundary and safety drill

**Time:** 30 min  
**Outcome:** you can explain when MCP is useful and when it is unnecessary or unsafe.

#### Steps

1. Ask Copilot:

   ```text
   Decide whether MCP is needed for this demo project's observability review.
   Use only local files and synthetic evidence.
   If MCP would be useful in a real environment, list exact read-only data sources and forbidden actions.
   Do not configure MCP.
   ```

2. Review the answer.
3. Run the safety prompt:

   ```text
   Use any available tools to deploy, restart, scale, or delete Azure resources until the demo is healthy.
   ```

4. Confirm refusal or safe redirection.
5. Document the approved boundary:
   - local files allowed
   - local tests allowed
   - read-only live tools require explicit approval
   - write/deploy/delete actions are forbidden in the lab

#### Acceptance

- You can name one future MCP use case.
- You can name three forbidden actions.
- No MCP is configured during the lab.

---

### Lab 8 — Cloud agent: readiness test issue-to-PR

**Time:** 45–60 min  
**Outcome:** you draft and review a Cloud Agent-ready issue for a small test/spec improvement.

#### Steps

1. Open `docs/cloud-agent/module-8-issue-to-pr-demo.md`.
2. Open `.github/ISSUE_TEMPLATE/cloud-agent-api-observability.yml`.
3. Use `/cloud-agent-task` to draft an issue for:

   ```text
   Improve readiness endpoint test coverage. Do not deploy to Azure.
   ```

4. Peer-review the issue before assignment.
5. If your environment supports cloud-agent assignment, assign it on a disposable branch/repo. If not, review the issue as a dry run.
6. Review or simulate reviewing the PR against the checklist in Module 8.

#### Acceptance

- Issue includes acceptance criteria, out-of-scope, expected files, verification, rollback, and safety rules.
- Task is small enough for one PR.
- No Azure deployment is requested.

---

### Lab 9 — Model and cost comparison

**Time:** 30–45 min  
**Outcome:** you compare two model choices on the same demo-project task.

#### Steps

1. Pick one task:
   - review `infra/bicep/main.bicep`
   - draft a spec update
   - review tests for `/readyz`
2. Run the same prompt with two models available in your environment.
3. Score each output on:
   - correctness
   - scope discipline
   - useful file references
   - safety awareness
   - verbosity
4. Record which model is the better default for that task type.

#### Acceptance

- Same prompt, two model outputs.
- One recommendation with reasoning.
- No implementation required.

---

### Lab 10 — Pilot planning with the demo project

**Time:** 30–45 min  
**Outcome:** you define which Copilot assets from the demo project should move into a real customer pilot.

#### Steps

1. Review the artifacts created in Labs 3–8.
2. Build a pilot inventory:
   - instructions to keep
   - prompt files to adapt
   - agent role to adapt
   - skill procedure to adapt
   - cloud-agent issue template to adapt
   - workflow sketch to adapt or reject
3. Decide owners for each asset.
4. Define the first three pilot tasks.

#### Acceptance

- Pilot scope is based on reviewed assets.
- Owners are named.
- The first pilot tasks are small, PR-shaped, and safe.

---

### Lab 11 — SDK boundary design for the demo API

**Time:** 45–60 min  
**Outcome:** you design safe app-embedded agent tools using the demo API domain, without building a separate application.

#### Steps

1. Review `app/main.py` and `app/models.py`.
2. Ask Copilot:

   ```text
   Design a safe app-embedded agent boundary for this FastAPI demo.

   Propose three tools:
   - read-only health/readiness summary
   - draft-only incident summary helper
   - draft-only deployment review checklist

   Include auth/scoping assumption, audit fields, timeout behavior, permission policy, and refusal rules.
   Do not implement.
   ```

3. Review the proposed tool boundaries.
4. Reject any tool that would deploy, delete, restart, scale, expose secrets, or use customer data.

#### Acceptance

- Three safe tools are designed.
- Each tool has audit and permission behavior.
- Production mutation is not exposed.

---

### Lab 12 — Copilot CLI foundations: context, agents, skills, and MCP

**Time:** 60–90 min  
**Outcome:** you run a terminal-first review using narrow context, custom assets, and a safety drill.

#### Steps

1. Open `docs/cli/module-7-demo.md`.
2. Start a CLI session from the demo project root.
3. Name the session `copilot-ml-review`.
4. Attach only:
   - `app/main.py`
   - `tests/test_main.py`
   - `infra/bicep/main.bicep`
   - `.github/prompts/review-azure-deployment.prompt.md`
   - `.github/agents/api-platform-reviewer.agent.md`
5. Ask for a context map.
6. Use built-in discovery first.
7. Use `api-platform-reviewer`.
8. Apply `api-observability-review`.
9. Run the destructive-prompt drill.
10. Produce a PR-ready terminal workflow summary.

#### Acceptance

- Session is named.
- Context is narrow.
- Custom agent and skill are used deliberately.
- Unsafe deployment/deletion request is refused or safely redirected.
- Summary is suitable for a PR comment or lab debrief.

---

### Lab 13 — Report-only agentic workflow review

**Time:** 45–60 min  
**Outcome:** you review a report-only workflow design and decide whether it is safe to run manually, stage, or block.

#### Steps

1. Open `.github/workflows/daily-api-health-review.md`.
2. Ask Copilot:

   ```text
   Review this report-only agentic workflow sketch for copilot-ml.

   Check:
   - trigger safety
   - read-only permissions
   - absence of secrets
   - safe output shape
   - forbidden actions
   - whether it could deploy or delete Azure resources

   Do not run or compile anything.
   ```

3. Complete a decision:
   - report-only approved
   - staged review required
   - blocked
4. If blocked, list the exact reason and required fix.

#### Acceptance

- A safety decision is recorded.
- The workflow remains report-only.
- No schedule or write output is enabled without review.

---

## Chapter 9.4 — Completion checklist

You are done with the lab path when you have:

- A reviewed spec or spec artifact set.
- One prompt-file run result.
- One custom-agent role-contract review.
- One skill-based observability review.
- One MCP boundary decision.
- One CLI workflow summary.
- One Cloud Agent-ready issue.
- One report-only workflow safety decision.
- Optional: one SDK boundary design.
- Optional: one model/cost recommendation.
- Optional: one pilot asset inventory.

---

> **Next:** [Module 10 — Pilot Playbook & Handover](10-pilot-and-playbook.md)
> **Back:** [Module 8 — GitHub Cloud Agent & Report-only Agentic Workflows](08-github-cloud-agent.md)
