# Module 11 — Agent Mode Adoption Checklist

By now you understand the modes ([Module 2](02-three-modes.md)), the customization primitives ([Modules 4 – 7](04-customize-instructions-prompts-and-hooks.md)), spec-driven development ([Modules 8 – 10](08-spec-driven-development.md)), and the orchestration patterns ([Module 7](07-subagents-and-orchestration.md)). This module is the **operational checklist** the team prints, pins to a wall, and walks through before any Agent Mode session that will write code you intend to merge.

If you can't say "yes" to the boxes in §1, drop back to Plan Mode or Ask Mode first.

---

## 1. Before you press Enter

- [ ] **There is a spec or a written plan.** Lightweight markdown spec, Plan Mode plan, or `.specify/specs/<id>/spec.md`. Not "let's see what the agent does."
- [ ] **The spec is reviewed.** Not `draft`. Not "I'll review it after." See [Module 9 — Roles, RACI & Spec Sizing](09-roles-and-spec-sizing.md).
- [ ] **Scope is bounded.** Files in scope are listed. Files out of scope are listed.
- [ ] **Safety boundaries are loaded.** `copilot-instructions.md` or `AGENTS.md` is in the repo root. Sensitive paths (secrets, infra, prod configs) are listed as "do not touch".
- [ ] **Working tree is clean** (or you understand the uncommitted changes the agent will see).
- [ ] **You picked the right model** for the task. See [Module 3 — Pick the Right Model](03-pick-the-right-model.md).
- [ ] **You picked the right agent** (default, custom, or planning/implementing pair).

---

## 2. During the session

- [ ] **Read every tool call before approving.** Auto-approve only `read_file` / `grep_search` / `file_search`. Approve every shell command explicitly.
- [ ] **Stop the agent if it goes outside scope.** Don't let it "while I'm here" your way into a 40-file diff.
- [ ] **Stop the agent if it rewrites code it hasn't read.** This is the strongest signal of hallucinated changes.
- [ ] **Stop the agent if tests start failing in unrelated places.** Investigate before continuing.
- [ ] **Stop the agent if it loops.** Three attempts at the same failure mean the human needs to step in.
- [ ] **Watch token / cost burn.** Long Agent Mode runs on premium models add up. Cap with a turn count if your team has a budget.

---

## 3. After the session

- [ ] **Review the full diff before staging.** Not just the file the agent told you about.
- [ ] **Run the test suite locally.** Don't trust "all tests passed" in chat.
- [ ] **Run the linters and type checkers.** The agent often leaves stylistic noise.
- [ ] **Run the data-quality / data-diff checks** for DE changes.
- [ ] **Squash the agent's chatty commits** into one or two reviewable commits.
- [ ] **Write the PR description yourself**, or reduce the agent's draft heavily. Reviewers parse PR descriptions; AI-generated walls of text slow them down.
- [ ] **Capture what didn't work.** Add it to `.github/copilot-instructions.md`, an agent's instructions, or `/memories/repo/`.

---

## 4. Hard "no"s for Agent Mode

- No live writes to production data, prod warehouses, prod databases, prod Kafka topics, or prod cloud control planes.
- No `force-push`, `git reset --hard`, branch deletion, or `rm -rf` without explicit human confirmation.
- No merging of PRs.
- No interactive credentials (passwords, tokens, MFA codes) sent through chat.
- No "do whatever you think is best" prompts when the diff will exceed ~10 files.
- No `--no-verify` to skip hooks.

---

## 5. Quick-reference card (printable)

```
BEFORE   spec reviewed · scope bounded · safety on · clean tree · right model · right agent
DURING   read every tool call · stop on scope creep · stop on hallucinated edits · stop on loops · watch cost
AFTER    review full diff · run tests/lints locally · squash commits · write PR yourself · capture lessons
NEVER    prod writes · force-push · merge PRs · paste secrets · "do anything" prompts · --no-verify
```

---

## 6. See also

- [Module 15 — Lab 16: Agent Mode adoption checklist dry-run](15-workshop-and-labs.md#lab-16--agent-mode-adoption-checklist-dry-run) — the hands-on for this module
- [Module 2 — The Three Modes](02-three-modes.md) — when Ask or Plan is enough
- [Module 7 — Sub-agents & Orchestration Patterns](07-subagents-and-orchestration.md) — when one agent isn't enough
- [Module 9 — Roles, RACI & Spec Sizing](09-roles-and-spec-sizing.md) — who reviews what
- [Module 13 — GitHub Cloud Agent](13-github-cloud-agent.md) — the same discipline, but the agent runs in the cloud

---

> **Next:** [Module 12 — GitHub Copilot CLI](12-copilot-cli.md)
> **Back:** [Module 10 — Plan Mode vs Spec Kit & the SDD Landscape](10-plan-mode-vs-speckit-and-landscape.md)
