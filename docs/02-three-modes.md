# Module 2 — The Three Modes: Ask, Plan, Agent

> **Goal:** by the end of this module, you can choose Ask, Plan, or Agent mode for the right reason and run a small implementation safely.

All demos start from the existing v1 project in the repository root:

`copilot-ml/`

---

## Chapter 2.0 — Mode scenario

Scenario:

> Improve the readiness endpoint test coverage for the existing v1 demo API without changing deployment behavior.

This task is small enough to implement, but still useful for showing the difference between explanation, planning, and execution on a brownfield codebase.

### Demo — classify the task

Ask Copilot:

```text
For copilot-ml, classify these requests as Ask, Plan, or Agent:
1. Explain what /readyz returns.
2. Plan one new readiness test assertion.
3. Implement the approved test assertion.
4. Deploy to Azure and delete failed resources.
Explain why.
```

Expected result:

- Explanation → Ask.
- Test plan → Plan.
- Approved test edit → Agent.
- Deploy/delete → not an autonomous agent task.

---

## Chapter 2.1 — Ask Mode

Ask Mode is for learning and review. It does not edit files.

Use Ask Mode when:

- You need a file, endpoint, test, or workflow explained.
- You want to compare approaches before deciding.
- You need to rewrite a risky prompt into a safe one.
- You are unsure whether a task is ready for Plan or Agent Mode.

Ask Mode output should be a decision aid, not a diff.

### Demo — Ask Mode explanation

Prompt:

```text
Explain /healthz and /readyz in app/main.py.
What would an SRE trust from these endpoints, and what still needs human validation?
Do not edit files.
```

Expected output:

- Clear endpoint explanation.
- An SRE could trust these endpoints as lightweight application self-reporting.

---

## Chapter 2.2 — Plan Mode

Plan Mode is for risky, multi-step, or multi-file work. It produces a reviewable plan before implementation.

A strong Plan Mode prompt has four required parts:

| Part | Purpose | Demo project example |
|---|---|---|
| Scope | What should change? | “Add one readiness test assertion.” |
| Existing context | What should Copilot inspect or reuse? | `app/main.py`, `app/models.py`, `tests/test_main.py`. |
| Out of scope | What must not change? | No Azure deployment, no auth, no real dependency. |
| Acceptance | How is “done” proven? | `pytest` passes and only expected files changed. |

For SRE or platform work, add these fields:

- **Blast radius** — what could break if the change is wrong?
- **Operational impact** — what changes for support, deployment, or monitoring?
- **Rollback** — how does a human undo the change?
- **Verification** — what local or CI evidence is required?

The Plan Mode loop is:

```text
prompt → inspect → plan → human review → revise plan → approve or stop
```

Do not treat a plan as permission to implement. It is a review artifact.

### Demo — create a plan

Prompt:

```text
Plan how to add one test assertion that /readyz returns demo dependency statuses.

Use:
- app/main.py
- app/models.py
- tests/test_main.py

Include files to inspect, exact test command, out-of-scope, rollback, and open questions.
Do not implement.
```

Expected plan:

- Only `tests/test_main.py` is likely to change.
- Verification is `pytest`.
- Out-of-scope includes deployment, auth, and real dependencies.
- Rollback is reverting the test change.

---

## Chapter 2.3 — Agent Mode

Agent Mode can edit files and run commands. Use it after the plan is accepted.

Agent Mode should feel like supervised pair programming:

1. **Start narrow.** Name files, tests, and out-of-scope items.
2. **Watch early tool calls.** The first few reads and edits reveal whether the agent understood the task.
3. **Interrupt quickly.** Stop the session if it reads unrelated areas, edits unexpected files, or proposes live mutation.
4. **Verify independently.** Review the diff and rerun or inspect tests yourself.
5. **Capture reusable learning.** Turn repeated prompts into prompt files, role-specific behavior into agents, and repeatable procedures into skills.

### Demo — implement one approved test change

Prompt:

```text
Implement only the approved readiness test assertion from the plan.
Edit tests/test_main.py only.
Run pytest.
Stop and summarize the diff and test result.
```

Expected behavior:

- The agent edits only the expected test file.
- The agent runs local tests only.
- No Azure deployment or workflow change is attempted.

---

## Chapter 2.4 — Mode decision table

| Situation | Use | Demo project example |
|---|---|---|
| Need explanation | Ask | Explain `app/main.py`. |
| Need a safe approach | Plan | Plan a readiness test update. |
| Approved small edit | Agent | Edit `tests/test_main.py` and run `pytest`. |
| Needs live deployment | Human-approved workflow | Review Bicep, but do not deploy from chat. |
| Repeated request | Prompt file | `/review-azure-deployment`. |
| Persistent review role | Custom agent | `api-platform-reviewer`. |

### Decision flow

Use these questions before choosing a mode:

1. **Do I only need to understand?** Use Ask.
2. **Is the task risky, ambiguous, or multi-file?** Use Plan first.
3. **Is the plan reviewed and acceptance clear?** Use Agent for a scoped edit.
4. **Does the task require live cloud mutation, secrets, merge, or deletion?** Keep it human-owned.
5. **Will the team repeat this request?** Package it as a prompt file, custom agent, or skill after one successful manual run.

### Demo — apply the table

Ask Copilot:

```text
Using the mode decision table, decide how to handle: "Improve API observability without increasing Azure cost." Include the first safe prompt I should use.
```

Expected result: start with Plan Mode or a spec prompt, not Agent Mode.

---

## Chapter 2.5 — Agent safety checklist

Before Agent Mode:

- [ ] Plan reviewed.
- [ ] Files to edit are named.
- [ ] Out-of-scope is explicit.
- [ ] Test command is explicit.
- [ ] Deployment and deletion are forbidden.
- [ ] Human will review diff and rerun tests.

During Agent Mode:

- Watch first tool calls.
- Stop if unexpected files are read or edited.
- Reject commands that deploy, delete, restart, scale, merge, or expose secrets.

After Agent Mode:

- Review diff.
- Rerun or verify tests.
- Keep reusable lessons in prompt files, instructions, agents, or skills.

### Healthy signals vs. stop signals

| Healthy signal | Stop signal |
|---|---|
| Reads named files first. | Reads broad folders without reason. |
| Restates scope and out-of-scope. | Starts implementing before understanding. |
| Edits only expected files. | Touches deployment, secrets, lockfiles, or unrelated modules unexpectedly. |
| Runs the agreed local validation. | Runs deploy/delete/merge/publish commands. |
| Reports “not run” honestly when tests are unavailable. | Claims success without evidence. |

### Common Agent Mode anti-patterns

- **“While I am here” refactor:** reject unrelated cleanup.
- **Broad fix request:** replace “fix everything” with one scoped acceptance criterion.
- **Silent tool escalation:** stop if the agent reaches for tools outside the task.
- **Repeated failure loop:** after two failed attempts, stop and return to Plan Mode.
- **Review bypass:** never merge, deploy, or publish based only on the agent's summary.

### Demo — checklist review

Ask Copilot:

```text
Review this Agent Mode request against the safety checklist:
"Update readiness tests and make any deployment fixes needed."
What is unsafe or ambiguous? Rewrite it safely.
```

Expected result: the rewrite limits edits to tests and forbids deployment changes.

---

## Chapter 2.6 — Lab connection

Use [Lab 2 — Ask, Plan, and Agent mode on the demo project](09-workshop-and-labs.md#lab-2--ask-plan-and-agent-mode-on-the-demo-project) in Module 9.

---

> **Next:** [Module 3 — Pick the Right Model](03-pick-the-right-model.md)
> **Back:** [Module 1 — Prerequisites and Project Overview](01-prerequisites-and-project-overview.md)
