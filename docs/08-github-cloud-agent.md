# Module 8 — GitHub Cloud Agent & Report-only Agentic Workflows

> **Goal:** by the end of this module, you can write a bounded issue for the cloud agent, review the resulting PR safely, and design a report-only workflow that summarizes repository health without mutating live systems.

All demos use:

`demo-projects/copilot-ml/`

Project assets for this module:

- `docs/cloud-agent/module-8-issue-to-pr-demo.md`
- `.github/ISSUE_TEMPLATE/cloud-agent-api-observability.yml`
- `.github/workflows/daily-api-health-review.md`

---

## Chapter 8.0 — Demo scenario

Scenario:

> Delegate a small test/spec improvement to the cloud agent, then review a report-only workflow sketch that summarizes API health without deploying to Azure.

Good task:

> Improve the demo API readiness test coverage and update the spec if needed. Do not deploy to Azure.

Expected output:

- A tight issue body.
- A PR review checklist.
- A decision to merge, request changes, or take over locally.
- A report-only workflow review.

---

## Chapter 8.1 — Cloud agent mental model

The cloud agent is asynchronous task delegation. A human assigns a bounded task; the agent works in a GitHub-hosted environment; the output is a branch and pull request.

It is best for small, reviewable tasks with clear acceptance criteria.

Compare the surfaces this way:

| Surface | Best for | Human responsibility |
|---|---|---|
| Ask Mode | Explanation and review | Decide what is true and what to do next. |
| Plan Mode | Read-only plan for risky work | Review and approve or reject the plan. |
| IDE Agent Mode | Supervised local implementation | Watch tool calls, inspect diff, run tests. |
| Cloud Agent | Async PR for bounded tasks | Write a good issue and review PR/session log. |

The cloud agent should not receive vague work. The issue is its spec.

### Demo — classify tasks

Ask Copilot:

```text
Classify these tasks for copilot-ml as Plan Mode, IDE Agent Mode, or Cloud Agent:

1. Explain what /readyz returns.
2. Add one test assertion for /readyz.
3. Redesign the deployment architecture.
4. Deploy to Azure and delete failed resources.
5. Draft a PR-ready issue for improving readiness test coverage.

Explain the safety reason for each classification.
```

Expected answer:

- Explanation → Ask or Plan.
- Small test assertion → Cloud Agent or IDE Agent.
- Architecture redesign → Plan first.
- Deploy/delete → human-owned, not an agent task.
- Issue drafting → prompt file or Plan.

---

## Chapter 8.2 — Cloud-agent-ready issue writing

The issue is the agent's spec. It must include context, acceptance criteria, out-of-scope, expected files, verification, rollback, and safety rules.

### Cloud agent lifecycle

```text
write issue → assign task → agent researches → agent opens PR → human reviews → iterate or close
```

At each step, keep the work PR-shaped:

- One task.
- Expected files named.
- Local verification command specified.
- Out-of-scope explicit.
- Safety rules repeated.

### Issue quality checklist

- [ ] Summary is one sentence.
- [ ] Context links to local files or specs.
- [ ] Acceptance criteria are testable.
- [ ] Expected files are named.
- [ ] Out-of-scope excludes deployment, secrets, production dependencies, and broad refactors.
- [ ] Verification command is included.
- [ ] Rollback is “revert PR” unless a human chooses otherwise.
- [ ] Review owner is named.

Demo guide:

`docs/cloud-agent/module-8-issue-to-pr-demo.md`

Issue template:

`.github/ISSUE_TEMPLATE/cloud-agent-api-observability.yml`

### Demo — draft the issue

Use the local prompt file:

```text
/cloud-agent-task change_request: Improve readiness endpoint test coverage for copilot-ml. expected_files: tests/test_main.py and optional specs/api-health-observability.spec.md
```

Expected issue includes:

- Summary.
- Context.
- Acceptance criteria.
- Out of scope.
- Expected files.
- Verification command: `pytest`.
- Rollback: revert PR.
- Safety rules: no Azure deployment, no secrets, no production dependencies.

### Bad vs. better issue

Bad:

```text
Improve readiness.
```

Better:

```text
Improve readiness endpoint test coverage for copilot-ml.

Context:
- app/main.py defines /readyz.
- tests/test_main.py has baseline endpoint tests.

Acceptance:
- Add one assertion that /readyz includes demo dependency statuses.
- pytest passes.

Out of scope:
- No Azure deployment.
- No workflow changes.
- No production dependency integration.

Rollback:
- Revert this PR.
```

---

## Chapter 8.3 — Reviewing the cloud-agent PR

Treat the PR like a human PR, plus one extra review: read the session log for drift.

Review sequence:

1. Read issue and acceptance criteria.
2. Read PR summary and changed files.
3. Inspect the diff manually.
4. Read the session log for scope drift, unsafe commands, or repeated failures.
5. Rerun or verify local tests.
6. Decide: merge, request changes, take over locally, or close.

### Demo — review checklist

When the PR exists, review:

- Did the diff touch only expected files?
- Did tests change meaningfully?
- Did the PR avoid Azure deployment or workflow edits unless required?
- Does the PR description explain the demo readiness contract?
- Did the session log show unsafe attempts, broad exploration, or repeated failure loops?
- Did a human rerun or verify tests?

If the PR misses the target, write one focused `@copilot` comment. If it still misses after a second round, take over locally or close the PR.

---

## Chapter 8.4 — Report-only agentic workflow

The demo project includes a report-only workflow source sketch:

`.github/workflows/daily-api-health-review.md`

This is not a deployment workflow. It is a design artifact for a safe scheduled or manually triggered repository health review.

### Layered safety model

Report-only workflows should be designed with multiple layers:

| Layer | Control |
|---|---|
| Trigger | Prefer manual trigger first; schedule only after review. |
| Permissions | Read-only repository permissions by default. |
| Data | Use local files and synthetic evidence; do not pass secrets. |
| Tools | No deployment, deletion, restart, scale, merge, or publish tools. |
| Output | Markdown summary, issue draft, or PR comment that a human reviews. |
| Audit | Keep run logs and summarize what files were inspected. |

Good first workflows are summaries and checklists. Poor first workflows are anything that changes infrastructure, merges code, or modifies customer-facing state.

### Demo — review workflow safety

Ask Copilot:

```text
Review .github/workflows/daily-api-health-review.md for safety.

Check:
- trigger
- data sources
- permissions
- safe output
- forbidden actions
- whether Azure deployment is possible

Do not compile or run the workflow.
```

Expected conclusion:

- The workflow is report-only.
- Agent job should remain read-only.
- No secrets should be passed to the agent.
- Azure deployment is out of scope.
- Output should be a Markdown summary or reviewed issue/comment only.

---

## Chapter 8.5 — Governance and cost boundaries

Use these controls before delegating or scheduling agent work.

| Boundary | Demo project rule |
|---|---|
| Scope | One task, one repo, one PR. |
| Context | Issue body names files and acceptance criteria. |
| Permissions | PR-only; no live deployment or deletion. |
| Secrets | Never paste secrets into issues or prompts. |
| Cost | Prefer small tasks and stop after repeated misses. |
| Review | Human reviews diff, tests, and session log. |

### Limits and gotchas

- The cloud agent is only as good as the issue quality and repo setup.
- It may not understand implicit team norms unless they are in repo instructions.
- It can spend cost on broad exploration if expected files are not named.
- It may produce a plausible PR that still violates scope.
- It should not be used for live operational decisions without human review.

### Metrics to collect

- PRs opened by cloud agent.
- PRs merged without takeover.
- Review rounds per PR.
- Test pass evidence.
- Scope-drift incidents.
- Cost outliers.
- Reusable issue templates improved.

### Demo — go/no-go decision

Ask Copilot:

```text
Given the cloud-agent issue and the report-only workflow sketch, create a go/no-go checklist for running this in a shared customer training repository.
Use only the demo project assets.
```

Expected output:

- Go if issue scope is tight, tests are local, secrets are absent, and review owner is assigned.
- No-go if task requires Azure deployment, production data, broad credentials, or recurring automation without review.

---

## Chapter 8.6 — Anti-patterns

- **Vague issue:** no expected files, acceptance, or verification.
- **Too-large issue:** architecture redesign or multi-feature work in one task.
- **No session-log review:** treating the PR summary as enough.
- **Recurring workflow too early:** scheduling automation before manual review proves safety.
- **Report-only workflow with write authority:** permissions exceed the output goal.

---

## Chapter 8.7 — Lab connection

Use these labs in [Module 9](09-workshop-and-labs.md):

- [Lab 8 — Cloud agent: readiness test issue-to-PR](09-workshop-and-labs.md#lab-8--cloud-agent-readiness-test-issue-to-pr)
- [Lab 13 — Report-only agentic workflow review](09-workshop-and-labs.md#lab-13--report-only-agentic-workflow-review)

Both labs use only `demo-projects/copilot-ml/`.

---

> **Next:** [Module 9 — Hands-on Labs](09-workshop-and-labs.md)
> **Back:** [Module 7 — GitHub Copilot CLI](07-copilot-cli.md)
