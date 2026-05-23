# Module 13 — GitHub Cloud Agent & Report-only Agentic Workflows

The chat agents and the Copilot CLI both keep you in the loop. You watch the tool calls, approve commands, and review the diff in your editor before anything ships. The **Cloud Agent** is different: you assign a task, walk away, and review a pull request later. The agent runs in a GitHub-hosted, GitHub-Actions-powered ephemeral environment — not on your laptop, and not in your IDE.

That makes it ideal for well-scoped, asynchronous work — bug fixes, small features, test coverage improvements, doc updates, technical debt — while raising the bar on how you write the request. There is no human at the keyboard to nudge it back. The issue *is* the spec.

This module covers when the Cloud Agent is the right surface, how to write an issue it can ship, how to review the resulting PR safely, and how to design report-only agentic workflows that summarize repository health without ever mutating production.

The running scenario stays the same:

> Delegate a small test improvement to the Cloud Agent, then review a report-only workflow sketch that summarizes API health without deploying to Azure.

Demo project assets used:

- `.github/ISSUE_TEMPLATE/cloud-agent-api-observability.yml`
- `.github/prompts/cloud-agent-task.prompt.md`
- `.github/workflows/daily-api-health-review.md`

Official references:

- [About GitHub Copilot Cloud Agent](https://docs.github.com/en/copilot/concepts/about-copilot-coding-agent)
- [Use Copilot Cloud Agent](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent)
- [Best practices for using Copilot Cloud Agent](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/best-practices)

> **Naming note.** GitHub recently renamed this feature "Copilot Cloud Agent" (formerly "Copilot coding agent"). Both names still appear in tooling and docs through 2026.

---

## What the Cloud Agent is

The Cloud Agent is an autonomous Copilot session that runs in a GitHub-hosted ephemeral environment. You assign it a task; it researches the repo, plans, edits a branch, runs your tests, and opens (or updates) a pull request. You and your team review and merge that PR like any other.

The key properties:

- **Asynchronous.** You assign the work and walk away. Notifications bring you back when the PR is ready or when the agent gets stuck.
- **GitHub-native.** The agent's filesystem, terminal, and runtime are all in the GitHub-hosted sandbox. Logs are visible to anyone with repo access.
- **Pull-request shaped.** The output is always a branch + PR — never a direct commit to `main`, never a diff in your editor.
- **Single-task, single-repo, single-PR.** One assignment = one task = one branch = one PR. No cross-repo refactors, no multi-PR sequences.

What it is good at:

- Incremental new features.
- Bug fixes paired with a sharp issue description.
- Improving test coverage.
- Updating documentation.
- Addressing tech debt.
- Resolving merge conflicts on existing PRs.
- Triaging and fixing security alerts assigned to it from a security campaign.

What it is *not* good at:

- Anything where the path is unclear (use Plan Mode first).
- Tight-loop changes that need a human watching every turn (use IDE Agent Mode).
- Live cloud or production mutation (always human-owned).

### Cloud Agent vs. IDE Agent Mode vs. Plan Mode

| Aspect | **Cloud Agent** | **IDE Agent Mode** | **Plan Mode** |
|---|---|---|---|
| Where it runs | GitHub-hosted sandbox | Your VS Code | Your VS Code |
| Synchronous? | No | Yes — you watch | Yes — interactive |
| Edits files? | Yes, on a branch in the sandbox | Yes, in your working tree | No |
| Output | Pull request + session log | Edits in your tree, optional PR | Plan file + handoff button |
| Trigger | Issue assignment, agents panel, Chat, REST API, integrations | "Agent" in chat | "Plan" in chat |
| Best for | Independent, well-specified tasks; backlog burn-down | Tightly-supervised local changes | De-risking anything multi-file before execution |

The decision rule is simple: if the task is well-scoped enough that you would happily review the resulting PR with no extra context, use the Cloud Agent. If you need to be in the loop turn by turn, stay in IDE Agent Mode. If the path is unclear, run Plan Mode first.

---

## How a Cloud Agent task flows

```text
1. Assign
   Issue assignee = Copilot, or "New agent task" in the agents panel.
   The repo's copilot-instructions.md, AGENTS.md, *.instructions.md load.
   copilot-setup-steps.yml runs (deps install).
   A new branch is created: copilot/<slug>.

2. Research (optional)
   The agent reads the codebase and drafts a plan.
   You can iterate on the plan before any code is written.

3. Implement
   Edits, builds, tests. Each step is a commit on the branch.
   Failures trigger a self-debug loop; rate of failure caps progress.

4. Draft PR
   The agent opens (or updates) a PR with a body summarizing what
   changed, what was tested, open questions, and next steps.

5. Review
   You review the diff and the session log.
   @copilot mention in PR comments → the agent iterates on the same PR.

6. Merge
   Same merge gates as a human PR. CI must pass.
```

You can pull a Cloud Agent session into your local environment at any time with `copilot --resume` ([Module 7](12-copilot-cli.md)) and finish at the keyboard.

---

## Setting the repo up so the agent succeeds

The Cloud Agent reads a smaller pool of context than your IDE — there are no open tabs, no editor selection, no conversation history. Every signal you want it to use has to live in the repo.

A "Cloud-Agent-ready" repo has:

| Asset | Location | Why |
|---|---|---|
| `copilot-instructions.md` (or `AGENTS.md`) | `.github/` | Coding conventions, where things live, what to never do. See [Module 4](04-customize-instructions-prompts-and-hooks.md). |
| `copilot-setup-steps.yml` | `.github/copilot-setup-steps.yml` | Pre-installs deps so the agent starts on a known-good baseline. |
| Path-scoped instructions | `.github/instructions/*.instructions.md` with `applyTo:` | Stricter rules for sensitive subsystems. |
| Custom agents | `.github/agents/*.agent.md` | Specialized roles the Cloud Agent can switch into. |
| Skills | `.github/skills/*/SKILL.md` | Procedural knowledge for recurring tasks. |
| MCP config | per-host | Extra data sources or runtime tools. |
| Issue templates | `.github/ISSUE_TEMPLATE/` | Reusable shapes for the kinds of tasks you delegate. |
| Test command in `pyproject.toml` / `Makefile` | Repo root | The agent runs `pytest` / `make test` heuristically — make those work without arguments. |

A minimal `copilot-setup-steps.yml` for the demo project:

```yaml
# .github/copilot-setup-steps.yml
steps:
  - name: Install Python deps
    run: pip install -e . -r requirements-dev.txt
  - name: Warm pytest
    run: pytest --collect-only -q
```

Keep setup under five minutes — the agent waits for it. Two extra knobs worth flagging: content exclusions are not enforced for Cloud Agent runs (gate confidential files by repo access, not exclusions), and protected-branch rulesets may need Copilot added as a bypass actor if your rules say "specific commit authors only."

---

## Writing issues the agent can ship

The Cloud Agent is a very literal reader of the issue. Vague issues yield wandering sessions, expensive runs, and PRs that miss the point. The fix is the same spec discipline from [Module 6](08-spec-driven-development.md): goal, scope, out-of-scope, acceptance, rollback.

### Bad

```markdown
Title: Improve readiness

Body:
Make the readiness checks better.
```

The agent will guess at "readiness" and "better," probably touch the wrong files, and the PR will be hard to review — or worse, it will quietly relax a check.

### Better

```markdown
Title: Improve readiness endpoint test coverage for copilot-ml

## Context
- app/main.py defines /readyz.
- tests/test_main.py has baseline endpoint tests.

## Acceptance
- [ ] Tests assert /readyz returns `ready: true`.
- [ ] Tests assert demo-only dependencies are labeled `not_configured_for_demo`.
- [ ] No production dependencies, Azure services, or secrets are added.
- [ ] `pytest` passes.
- [ ] PR description explains why this is a demo readiness contract.

## Out of scope
- Azure deployment.
- Database or external dependency integration.
- Authentication.

## Expected files
- tests/test_main.py
- Optional: specs/api-health-observability.spec.md

## Verification
- pytest

## Rollback
- Revert the PR. No infrastructure rollback required.

## Safety rules
- Open a PR only.
- Do not deploy to Azure.
- Do not add secrets or live data.
```

The "better" issue reads like a spec, because that is effectively what an issue *is* when you delegate to the Cloud Agent.

### A reusable issue-authoring checklist

- The title is the actual change, not the symptom (unless investigation is the point).
- The body has acceptance criteria as checkboxes.
- The body has at least two out-of-scope items.
- The body names file paths or modules where the work belongs.
- The body links to specs, prior PRs, dashboards, or runbooks where relevant.
- The issue has labels that map to a custom agent if you use one.

In the demo project, the issue template `.github/ISSUE_TEMPLATE/cloud-agent-api-observability.yml` enforces this shape, and the prompt file `.github/prompts/cloud-agent-task.prompt.md` drafts the issue, asks for review, and creates it after approval:

```text
/cloud-agent-task task_idea: Improve readiness endpoint test coverage for copilot-ml. Expected files: tests/test_main.py and optional specs/api-health-observability.spec.md.
```

---

## Reviewing the Cloud Agent's PR

Treat the PR like any other PR, with two extras: read the session log, and iterate via `@copilot` mentions.

### Read the session log

Every Cloud Agent PR links to its session transcript. Skim it before reviewing the diff. You are looking for:

- **Uncertainty.** Comments like "I'm not sure whether…" are leading indicators of bugs.
- **Tools that failed and were retried.** Three retries on the same `pytest` is a signal something is off — usually a missing dependency or a flaky test.
- **Scope drift.** Edits the agent made that are not in the issue.

If the log shows real wandering, request changes through `@copilot` in a PR comment. The agent picks the session back up and pushes another commit.

### Iterate via `@copilot`

```markdown
@copilot the new assertion you added doesn't actually fail without your fix.
Please add a test that fails on `main` first, then make it pass.
Don't change app code that isn't in scope.
```

A few rules of thumb:

- One ask per comment. The agent fans out badly on multi-part requests.
- Reference specific files or lines. GitHub's line comments work fine.
- Be explicit about scope. "Don't touch X" is more reliable than "only touch Y."
- Stop iterating after two rounds. If the third try does not land it, take it over locally with `copilot --resume`, or close the PR and redo in IDE Agent Mode.

### A PR review checklist

In addition to your normal PR review:

- Does the diff match the issue's acceptance criteria, no more?
- Are the new tests *meaningful* — regressions for the bug, edge cases for the feature — not coverage padding?
- Were dependencies added with the same justification you would expect from a human PR?
- Was any "fix" achieved by suppressing a check, broadening a type, or skipping a test? If so, request changes.
- Does the PR description match the actual diff? (The agent sometimes describes intent rather than result.)
- Did a human rerun the verification command (`pytest`) locally or in CI?

---

## Report-only agentic workflows

Beyond one-off issue assignments, the Cloud Agent can power **scheduled or event-triggered** reviews — for example, a daily summary of repository health that gets posted as a comment for the team to read. The demo project includes a design sketch at `.github/workflows/daily-api-health-review.md`.

The rule that makes these workflows safe is simple: **the agent's job is to produce a Markdown report**, not to mutate the repo or any live system.

A layered safety model:

| Layer | Control |
|---|---|
| Trigger | Prefer manual (`workflow_dispatch`) first; schedule only after review proves the design. |
| Permissions | Read-only repository permissions by default. |
| Data | Local files and synthetic evidence; never pass secrets. |
| Tools | No deployment, deletion, restart, scale, merge, or publish. |
| Output | A Markdown summary, issue draft, or PR comment that a human reviews. |
| Audit | Keep run logs; have the workflow note which files it inspected. |

Good first workflows: nightly drift summaries, weekly test-coverage reports, release-readiness checklists, PR review companions. Poor first workflows: anything that changes infrastructure, merges code, or modifies customer-facing state.

A useful review prompt:

```text
Review .github/workflows/daily-api-health-review.md for safety.

Check:
- trigger (manual or scheduled?)
- data sources (local files vs. live systems?)
- permissions (least privilege?)
- safe output (Markdown only?)
- forbidden actions (deploy, delete, merge?)
- whether Azure deployment is possible

Do not compile or run the workflow.
```

Expected conclusion: the workflow is report-only, the agent job stays read-only, no secrets are passed, Azure deployment is out of scope, and output is a Markdown summary or reviewed comment only.

---

## Limits and gotchas

Read these before betting a sprint on the Cloud Agent.

| Limit | Practical consequence |
|---|---|
| One repo per task | No cross-repo refactors. Use one issue per repo, merge in order. |
| One branch + one PR per task | No "split this into three PRs" workflows. Pre-split work yourself. |
| GitHub-hosted only | Does not work for repos hosted elsewhere. |
| Content exclusions ignored | Don't rely on exclusions for confidentiality; gate by repo access. |
| Some branch-protection rules block the agent | Add Copilot as a bypass actor on rulesets that conflict (for example "specific commit authors only"). |
| Setup steps cap practical task size | If `pip install && pytest` already takes ten minutes, every run pays that cost. Optimize. |
| Gets stuck on flaky tests | It will retry, then give up. Stabilize tests in a human-driven PR before delegating. |
| No access to your local env vars or secrets | Use repo / org Actions secrets surfaced to the agent. Never paste secrets in issues. |

---

## Cost and governance

The Cloud Agent burns two budgets per task: premium requests for the agent's LLM turns, and GitHub Actions minutes for the sandbox. Practical levers:

- **Scope tightly.** A precise issue costs less than a vague one.
- **Stop early.** If round two of `@copilot` iteration is still off, take it over locally instead of round three.
- **Pre-install dependencies.** `copilot-setup-steps.yml` reduces wasted Actions minutes on trial-and-error tool installs.
- **Track metrics.** PRs opened, PRs merged without takeover, review rounds per PR, scope-drift incidents, cost outliers. These show whether your issue templates are improving over time.

A go/no-go drill for any shared training environment:

> Given the Cloud Agent issue and the report-only workflow sketch, create a go/no-go checklist for running this in a shared customer training repository. Use only the demo project assets.

Expected output: **go** if the issue is tightly scoped, tests are local, secrets are absent, and a reviewer is named. **No-go** if the task needs Azure deployment, production data, broad credentials, or recurring automation without human review.

---

## Anti-patterns

| Anti-pattern | Symptom | Fix |
|---|---|---|
| **Vague issue** | The agent wanders; the PR misses the point | Make the issue a spec — goal, acceptance, out-of-scope, rollback. |
| **Too-large issue** | One issue covers an architecture redesign or several features | Pre-split. One task per assignment. |
| **No session-log review** | The PR summary is treated as enough | Always skim the session log for uncertainty and scope drift. |
| **Endless `@copilot` iteration** | Round five of comments, no convergence | Stop after two rounds. Take it over locally or close the PR. |
| **Recurring workflow scheduled too early** | The agent runs nightly before anyone has reviewed it manually | Start with `workflow_dispatch`. Only schedule after the design is proven. |
| **Report-only workflow with write authority** | Permissions exceed the goal | Drop to `read-only` and `pull-requests: write` (for the comment) at most. |
| **Secrets pasted into issues** | Tokens or connection strings end up in agent context | Never. Use Actions secrets and reference them by name. |

---

## Summary

The Cloud Agent moves Copilot from "tool that helps you code" to "teammate you can hand a ticket to." That shift is worth it for the right tasks — small, well-specified work where a clean PR is the right deliverable — but only if the repo is set up for it and the issue reads like a spec. With `copilot-instructions.md`, a `copilot-setup-steps.yml`, a few issue templates, and the same out-of-scope/acceptance/rollback discipline from [Module 6](08-spec-driven-development.md), the Cloud Agent becomes a reliable way to burn down backlog without surprises.

For scheduled work, design report-only workflows first. Keep permissions minimal, output as Markdown, and human review as the gate. The Cloud Agent is happy to run unattended; the design has to make sure unattended is safe.

For the hands-on labs, see [Lab 8](15-workshop-and-labs.md#lab-8--cloud-agent-readiness-test-issue-to-pr) and [Lab 13](15-workshop-and-labs.md#lab-13--report-only-agentic-workflow-review) in Module 15.

---

> **Next:** [Module 14 — Data Engineering Track](14-data-engineering-track.md)
> **Back:** [Module 12 — GitHub Copilot CLI](12-copilot-cli.md)
