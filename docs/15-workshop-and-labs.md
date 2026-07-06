# Module 15 — Hands-on Labs with copilot-ml

> **Goal:** practice Copilot concepts on one already-working v1 application, then make small reviewed improvements instead of rebuilding the demo from scratch.

All labs start from the repository root:

`copilot-ml/`

The v1 baseline already includes:

- FastAPI app: `app/main.py`, `app/models.py`
- Tests: `tests/test_main.py`
- Local/container run path: `README.md`, `Dockerfile`
- Azure deployment assets: `infra/bicep/main.bicep`, `.github/workflows/deploy-aca.yml`, `scripts/setup-github-azure-actions.sh`
- Specs: `specs/api-health-observability.spec.md`, `specs/github-actions-azure-setup.spec.md`
- Copilot customization: `.github/copilot-instructions.md`, `.github/prompts/`, `.github/agents/api-platform-reviewer.agent.md`, `.github/skills/api-observability-review/`
- Async/workflow assets: `.github/ISSUE_TEMPLATE/cloud-agent-api-observability.yml`, `.github/workflows/daily-api-health-review.md`, consolidated CLI/SDK guidance in `docs/12-copilot-cli.md`, and consolidated Cloud Agent guidance in `docs/13-github-cloud-agent.md`
- Formal SDD inputs: consolidated in `docs/08-spec-driven-development.md`

This module replaces the older greenfield-style lab sequence. Learners now start by understanding v1, then use Copilot to specify, plan, implement, review, and delegate small changes.

---

## Chapter 15.0 — Lab environment

Recommended local validation command:

```bash
pytest
```

If the environment uses `uv`, this is also valid:

```bash
uv run pytest
```

The Azure/GitHub setup script may already have been run by a facilitator or environment owner. The default hands-on path focuses on reading the project, trying Copilot prompts, making small local changes, and validating the result.

### Lab operating pattern

Each lab follows the same loop:

```text
orient to v1 → ask or plan → inspect local evidence → choose scope → implement the exercise → verify → save artifact
```

The saved artifact matters more than the chat transcript. A useful artifact can be reused in a PR, issue, prompt file, agent, skill, runbook, or pilot plan.

---

## Chapter 15.1 — Demo and lab coverage map

Lab IDs are module-aligned: **Lab 3** supports Module 3, **Lab 8A/8B** support Module 8, and so on. Suffix letters indicate multiple labs for the same module. The recommended workshop path can still introduce a later module's lab early when the teaching flow benefits from it.

| Module | Knowledge point | Existing v1 asset | Hands-on lab |
|---|---|---|---|
| Module 0 | Prerequisites and setup | `README.md`, `docs/00-prerequisites.md` | [Lab 0](#lab-0--project-orientation) |
| Module 1 | Day-1 Copilot orientation | `docs/01-day-1-with-copilot.md`, `app/main.py`, `tests/test_main.py` | [Lab 1](#lab-1--day-1-copilot-orientation) |
| Module 2 | Ask → Plan → Agent | `tests/test_main.py`, `/readyz` | [Lab 2](#lab-2--ask-plan-and-agent-mode-on-the-demo-project) |
| Module 3 | Model/cost comparison | `infra/bicep/main.bicep`, `.github/workflows/deploy-aca.yml` | [Lab 3](#lab-3--model-and-cost-comparison) |
| Module 4 | Instructions, prompt files, and hooks | `.github/copilot-instructions.md`, `.github/prompts/`, `.github/hooks/` | [Lab 4](#lab-4--instructions-prompt-files-and-hooks-review) |
| Module 5 | Custom agent role contract | `.github/agents/api-platform-reviewer.agent.md` | [Lab 5A](#lab-5a--custom-agent-role-contract) |
| Module 5 | Native-first escalation | Whole project | [Lab 5B](#lab-5b--native-first-review-and-escalation) |
| Module 5 | Skill procedure | `.github/skills/api-observability-review/` | [Lab 5C](#lab-5c--api-observability-skill-review) |
| Module 5 | MCP boundary design | Local files and synthetic evidence | [Lab 5D](#lab-5d--mcp-boundary-design) |
| Module 6 | Skill packaging and plugin layout | `.github/skills/sql-cost-review/`; scratch `plugin.json` created outside the repo | [Lab 6](#lab-6--bundle-a-skill-into-a-local-plugin) |
| Module 7 | Sub-agent orchestration patterns | `.github/agents/api-platform-reviewer.agent.md` | [Lab 7](#lab-7--add-a-second-reviewer-agent-and-chain-it) |
| Module 8 | Vague request → reviewed spec | `specs/api-health-observability.spec.md` | [Lab 8A](#lab-8a--author-a-spec) |
| Module 8 | Formal SDD artifacts | `docs/08-spec-driven-development.md` Spec Kit graduation criteria | [Lab 8B](#lab-8b--formal-spec-kit-brownfield-api-lab) |
| Module 9 | Roles, RACI & spec sizing | `specs/templates/` and any in-flight spec | discussion-led (paired with Lab 8A or 8B) |
| Module 10 | Plan Mode vs Spec Kit | `specs/templates/`, `docs/10-plan-mode-vs-speckit-and-landscape.md` | discussion-led (paired with Lab 8A or 8B) |
| Module 11 | Agent Mode adoption checklist | `docs/11-agent-mode-checklist.md`, any small backlog item | [Lab 11](#lab-11--agent-mode-adoption-checklist-dry-run) |
| Module 12 | CLI context and sessions | `docs/12-copilot-cli.md` CLI customization and safety | [Lab 12A](#lab-12a--copilot-cli-foundations-context-agents-skills-and-mcp) |
| Module 12 | Copilot SDK app embedding | GitHub Copilot SDK and Awesome Copilot PR visualization recipe | [Lab 12B](#lab-12b--copilot-sdk-pr-visualization-demo) |
| Module 12 | Human-led multi-agent team demo | Squad reference repo and this repo's agent/skill assets | [Lab 12C](#lab-12c--squad-human-led-agent-team-demo) |
| Module 13 | Cloud Agent issue-to-PR | `docs/13-github-cloud-agent.md` issue-authoring + PR review checklists | [Lab 13A](#lab-13a--cloud-agent-readiness-test-issue-to-pr) |
| Module 13 | Report-only workflow | `.github/workflows/daily-api-health-review.md` | [Lab 13B](#lab-13b--report-only-agentic-workflow-review) |
| Module 13 | Agentic workflow design demo | GitHub Agentic Workflows (`gh-aw`) reference repo and report-only workflow artifact | [Lab 13C](#lab-13c--github-agentic-workflows-report-only-demo) |
| Module 14 | DE track stack swap | `specs/de/`, `.github/skills/sql-cost-review/`, `.github/skills/dq-test-review/` | [Lab 14](#lab-14--data-engineering-track-swap) |
| Module 15 | Pilot planning | All lab artifacts | [Lab 15](#lab-15--pilot-planning-with-the-demo-project) |

---

## Chapter 15.2 — Recommended lab paths

### Full path

1. Lab 0 — Project orientation.
2. Lab 1 — Day-1 Copilot orientation.
3. Lab 2 — Ask, Plan, and Agent mode on the v1 app.
4. Lab 3 — Model and cost comparison.
5. Lab 4 — Instructions, prompt files, and hooks review.
6. Lab 5A — Review the custom agent role contract.
7. Lab 5B — Native-first review and escalation.
8. Lab 5C — Skill-based observability review.
9. Lab 5D — MCP boundary design.
10. Lab 6 — Bundle a skill into a local plugin.
11. Lab 7 — Add a second reviewer agent and chain it.
12. Lab 8A — Author a next-feature spec.
13. Lab 11 — Agent Mode adoption checklist dry-run.
14. Lab 12A — CLI workflow.
15. Lab 12B — Copilot SDK PR visualization demo.
16. Lab 12C — Squad human-led agent team demo.
17. Lab 13A — Cloud Agent issue-to-PR.
18. Lab 13B — Report-only workflow review.
19. Lab 13C — GitHub Agentic Workflows report-only demo.
20. Lab 15 — Pilot planning.

Labs 8B and 14 are optional add-ons for formal Spec Kit practice and the data-engineering track.

### Focused paths

| Customer need | Recommended labs | Result |
|---|---|---|
| First use on an existing app | Labs 0–2 | Orientation, mode choice, guided tiny diff |
| Brownfield feature discipline | Labs 2, 8A, 8B | Plan/spec before implementation |
| Reusable repo assets | Labs 4, 5A, 5B, 5C, 6 | Instructions, agent, skill, and plugin packaging decisions |
| Multi-agent orchestration | Labs 5A, 7, 12C | Single-agent baseline, chained reviewer pattern, Squad-style team design |
| SRE / platform safety | Labs 5B, 5C, 5D, 11, 13B | Review output, MCP boundary, report-only decision, adoption gate |
| Terminal-first workflow | Lab 12A | CLI use-case decision plus context/session summary |
| App-embedded Copilot demo | Labs 12A, 12B | CLI-to-SDK decision and PR visualization demo notes |
| Async PR delegation | Lab 13A | Cloud Agent-ready issue, assignment decision, and review checklist |
| Agentic workflow automation | Labs 13B, 13C | Report-only safety review plus gh-aw-style workflow sketch |
| Adoption planning | Labs 3, 11, 15 | Model/cost recommendation, adoption checklist, pilot scope |

---

## Chapter 15.3 — Hands-on labs

The detailed sections below are sorted by module-aligned lab ID. Use the coverage map and recommended paths above when you want a different delivery flow.

Before each lab:

- Start from `copilot-ml/`.
- Confirm the task is read-only unless the lab explicitly approves a scoped local edit.
- Attach only the files named by the lab.
- Keep output in a reviewable shape: table, checklist, issue body, PR comment, or spec.
- If a lab allows implementation, use a disposable branch and review the diff.

### Lab 0 — Project orientation {#lab-0--project-orientation}

**Time:** 20 min
**Outcome:** you can explain the v1 app, tests, deployment path, specs, and Copilot customization assets.

#### Steps

1. Open `copilot-ml/` in VS Code.
2. Read `README.md`, `docs/00-prerequisites.md`, `docs/01-day-1-with-copilot.md`, and `specs/api-health-observability.spec.md`.
3. Ask Copilot:

   ```text
   Summarize this existing v1 project for a new learner.
   Include API endpoints, tests, Azure deployment assets, setup script, specs, prompt files, custom agent, skill, CLI guide, and cloud-agent artifacts.
   Explain how each part supports the training.
   Return a short orientation summary.
   ```

4. Compare the answer to the actual file tree.
5. Save a short orientation note with:
   - what v1 already does
   - which files prove the app behavior
   - which files are most useful for the next exercise
   - one question you still have about the project

#### Acceptance

- You can name the six API routes.
- You can name the local test command.
- You can identify the setup script, Bicep, and deployment workflow.
- You can identify the prompt, agent, skill, issue template, and report-only workflow assets.
- You can explain where the Azure deployment examples live.

---

### Lab 1 — Day-1 Copilot orientation {#lab-1--day-1-copilot-orientation}

**Time:** 20 min<br>
**Outcome:** you can use inline suggestions and Copilot Chat against the existing v1 app without changing files unnecessarily.

#### Steps

1. Open `docs/01-day-1-with-copilot.md`, `app/main.py`, and `tests/test_main.py`.
2. Practice one inline suggestion in a scratch area or disposable branch; dismiss or accept only after reading it.
3. Ask Copilot:

   ```text
   Explain app/main.py and tests/test_main.py for a new developer.
   Focus on what the API already does and which tests prove it.
   Do not edit files.
   ```

4. Ask one `@workspace` question, one `#file` question, and one `/` slash-command question that is available in your environment.
5. Save a short Day-1 note with:
   - one useful inline-suggestion habit
   - one useful Chat context habit
   - one project fact Copilot helped you verify

#### Acceptance

- You can explain the difference between inline suggestions and Chat.
- You used `@`, `#`, and `/` at least once or documented why an option was unavailable.
- No repo files were edited unless you intentionally worked on a disposable branch.
- You saved one Day-1 takeaway.

---

### Lab 2 — Ask, Plan, and Agent mode on the demo project {#lab-2--ask-plan-and-agent-mode-on-the-demo-project}

**Time:** 30–40 min
**Outcome:** you can choose the right Copilot mode for explanation, planning, and one tiny implementation.

#### Steps

1. Ask Mode:

   ```text
   Explain what /healthz and /readyz do in app/main.py.
   What do these endpoints prove, and what do they intentionally not prove in this demo?
   Return an explanation only.
   ```

2. Plan Mode:

   ```text
   Plan how to add one test assertion that /readyz includes the external_dependencies demo status.

   Use:
   - app/main.py
   - app/models.py
   - tests/test_main.py

   Include files, verification, out-of-scope, rollback, and open questions.
   Do not implement.
   ```

3. Agent Mode on a disposable branch:

   ```text
   Implement only the approved readiness test assertion from the plan.
   Edit tests/test_main.py only.
   Run pytest.
   Stop and summarize the diff and test result.
   ```

4. Review the diff.
5. Keep or discard the change based on the local result.

#### Acceptance

- Ask Mode produced explanation only.
- Plan Mode produced a reviewable plan.
- Agent Mode touched only `tests/test_main.py`.
- `pytest` was run or explicitly marked not run with a reason.
- A human reviewed the diff and test result.

---

### Lab 3 — Model and cost comparison {#lab-3--model-and-cost-comparison}

**Time:** 30–45 min<br>
**Outcome:** you compare two model choices on the same read-only v1 task.

#### Steps

1. Pick one task:
   - review `infra/bicep/main.bicep`
   - review `.github/workflows/deploy-aca.yml`
   - draft a spec update
   - review tests for `/readyz`
2. Run the same prompt with two models available in your environment.
3. Score each output on:
   - correctness
   - scope discipline
   - useful file references
   - scope awareness
   - verbosity
4. Record which model is the better default for that task type.

#### Acceptance

- Same prompt, two model outputs.
- One recommendation with reasoning.
- No implementation required.

---

### Lab 4 — Instructions, prompt files, and hooks review {#lab-4--instructions-prompt-files-and-hooks-review}

**Time:** 30–40 min<br>
**Outcome:** you can explain how lightweight Copilot customizations shape repo behavior before reaching for agents or skills.

#### Steps

1. Open `docs/04-customize-instructions-prompts-and-hooks.md`.
2. Inspect `.github/copilot-instructions.md`, two prompt files under `.github/prompts/`, and `.github/hooks/hooks.json`.
3. Ask Copilot:

   ```text
   Review the lightweight Copilot customization layer in this repo.
   Compare instructions, prompt files, and hooks.
   Identify one durable rule, one reusable prompt, and one hook safety boundary.
   Do not edit files.
   ```

4. Confirm the hook scripts avoid logging full prompts or secrets.
5. Record one improvement idea, but do not implement it unless a facilitator explicitly scopes it.

#### Acceptance

- You can explain what belongs in always-on instructions versus a prompt file.
- You can identify which hook event scans prompts for threat signals.
- You can explain why hooks are reviewed like automation code.
- The review stays read-only.

---

### Lab 5A — Custom agent role contract {#lab-5a--custom-agent-role-contract}

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

4. Run the in-scope review prompt from Module 5.
5. Run the deployment-overview prompt:

   ```text
   Explain which files are involved in deploying this demo to Azure and what each one contributes.
   ```

6. Open `.github/skills/api-observability-review/SKILL.md` and compare what belongs in the agent vs. the skill.

#### Acceptance

- You can explain why the agent is a role, not just a prompt.
- You can explain why the skill is a procedure, not always-on instructions.
- The deployment prompt produces a clear file-and-step overview.

---

### Lab 5B — Native-first review and escalation {#lab-5b--native-first-review-and-escalation}

**Time:** 30 min  
**Outcome:** you can decide when to stop at native Copilot and when to escalate to prompt, agent, skill, or MCP.

#### Steps

1. Ask native Copilot to summarize the v1 project.
2. Use `/review-azure-deployment` for the repeated deployment-review task.
3. Use `api-platform-reviewer` for a role-specific review.
4. Use `api-observability-review` for a procedure-specific review.
5. Ask whether MCP is required for this local lab.

#### Acceptance

- You produce a short escalation decision table.
- MCP is not added unless a concrete read-only live-data need exists.
- The final output is a PR-ready review summary.

---

### Lab 5C — API observability skill review {#lab-5c--api-observability-skill-review}

**Time:** 30–45 min
**Outcome:** you apply the skill checklist to v1 and produce a concise observability review.

#### Steps

1. Open `.github/skills/api-observability-review/SKILL.md`.
2. Open `.github/skills/api-observability-review/references/review-checklist.md`.
3. Ask Copilot:

   ```text
   Apply the api-observability-review skill to this existing v1 project.
   Focus on /healthz, /readyz, /api/alerts/noisy-checkout-error, /api/incidents/summarize, tests, runbook, specs, setup script, and Azure Container Apps posture.
   Return an explanation only.
   ```

4. Review the generated findings.
5. Convert the best finding into a follow-up issue body.

#### Acceptance

- The review cites local files.
- Recommendations are specific and scoped.
- At least one follow-up issue is drafted.

---

### Lab 5D — MCP boundary design {#lab-5d--mcp-boundary-design}

**Time:** 30 min  
**Outcome:** you can explain when MCP is useful and when local project context is enough.

#### Steps

1. Ask Copilot:

   ```text
   Decide whether MCP is needed for this v1 demo project's observability review.
   Use only local files and synthetic evidence.
   If MCP would be useful in a real environment, list exact data sources and what question each source would answer.
   Do not configure MCP.
   ```

2. Review the answer.
3. Run the comparison prompt:

   ```text
   Compare using only local files versus adding MCP-backed live data for this demo review.
   Explain when each approach is worth the extra setup.
   ```

4. Confirm the output explains the tradeoffs clearly.
5. Document the proposed boundary:
   - local files used in this lab
   - local tests used in this lab
   - optional external data sources for a future version
   - when to keep the exercise local

#### Acceptance

- You can name one future MCP use case.
- You can name three local sources used in the lab.
- No MCP is configured during the lab.

---

### Lab 6 — Bundle a skill into a local plugin {#lab-6--bundle-a-skill-into-a-local-plugin}

**Time:** 25–30 min<br>
**Outcome:** you wrap one existing skill plus a reference file into a minimal **plugin** layout, register it locally with VS Code, and confirm it loads and triggers in chat. No publication; no marketplace; no network.

This lab makes [Module 6 — Skills Portfolio, Packaging & Sharing](06-skills-and-plugins.md) concrete. The point is to feel the boundary between "a skill in `.github/skills/`" and "a plugin you could share" — it is one file (`plugin.json`) plus a discipline about what belongs inside.

#### Prerequisites

- Lab 5C completed (you have read and run an existing skill).
- VS Code Insiders with chat plugins support (the `chat.pluginLocations` setting is honored).

#### Steps

1. Pick the source skill:
   - **API track:** `.github/skills/api-observability-review/`
   - **DE track:** `.github/skills/sql-cost-review/`
2. Create a scratch folder **outside** the repo (so you do not accidentally commit a plugin build), for example `~/scratch/copilot-ml-plugin/`.
3. Ask Copilot in Plan Mode (do **not** let it write yet):

   ```text
   I want to package one existing skill into a local Copilot agent plugin
   for trial only. The skill source lives at <path>. Propose:

   - the minimum folder layout under ~/scratch/copilot-ml-plugin/
   - a minimum plugin.json (name, description, version, author, skills)
   - a one-paragraph references/<name>-checklist.md that the skill will cite
   - the VS Code setting needed to register this folder as a local plugin
     source (chat.pluginLocations)

   Do not write or modify files in the repo. Output a single plan.
   ```

4. Review the plan against [Module 6 § Packaging — plugins](06-skills-and-plugins.md#3-packaging--plugins). Reject anything that:
   - puts secrets in `plugin.json`
   - bundles hooks or MCP servers you have not reviewed
   - uses a non-kebab-case `name` or one that does not match the folder
5. Switch to Agent Mode and let Copilot create the files in the scratch folder only. Verify the tree matches the plan.
6. Add the scratch folder to your VS Code user settings. `chat.pluginLocations` is an object mapping absolute paths to enabled/disabled (see [Module 6 § 4.3](06-skills-and-plugins.md#43-from-a-local-path-during-development)):

   ```json
   "chat.pluginLocations": {
     "/absolute/path/to/scratch/copilot-ml-plugin": true
   }
   ```

7. Reload VS Code. Open a fresh chat and confirm:
   - the skill appears in **Configure Skills**
   - typing `/<skill-name>` triggers it
   - the skill cites your new `references/<name>-checklist.md`
8. Capture a short artifact in your notes folder (not the repo) with:
   - the final `plugin.json`
   - the tree (`tree -L 3` output)
   - one chat transcript showing the skill firing
   - one paragraph: what would change if you wanted to share this with a teammate via a marketplace or Git URL instead of a local path

#### Acceptance

- The plugin loads from `chat.pluginLocations` without warnings.
- `plugin.json` contains no secrets, no absolute paths, and no unreviewed hook/MCP entries.
- The skill triggers on `/<skill-name>` and reads its own `references/` file.
- The repo working tree is unchanged (`git status` clean) — the plugin lives outside the repo.
- You can describe in one sentence the difference between **install from local path** (`chat.pluginLocations`), **install from a Git URL** (`Chat: Install Plugin From Source`), and **install from a marketplace** (`chat.plugins.marketplaces`).

#### Stretch

- Add a second skill from the same track into the same plugin and confirm both appear.
- Write a one-line install command for a teammate (`Chat: Install Plugin From Source` + the Git URL form).

---

### Lab 7 — Add a second reviewer agent and chain it {#lab-7--add-a-second-reviewer-agent-and-chain-it}

**Time:** 30–40 min<br>
**Outcome:** you create a second custom agent with a narrow focus, configure a handoff from the existing reviewer, run both on one spec, and compare the chained output against a single-agent baseline.

This lab makes [Module 7 — Sub-agents & Orchestration Patterns](07-subagents-and-orchestration.md) concrete using the **multi-perspective review** pattern. You will see (a) why a second narrow agent often beats one broad agent and (b) why uncontrolled fan-out is expensive.

#### Prerequisites

- Lab 5A completed (you have read `.github/agents/api-platform-reviewer.agent.md`).
- One spec to review: `specs/api-health-observability.spec.md` (or, for DE track, any model under `specs/de/`).

#### Steps

1. **Single-agent baseline.** Open the chosen spec. Invoke `@api-platform-reviewer` (or `@data-pipeline-reviewer` for DE) and ask for a full review. Save the response as `~/scratch/lab7-baseline.md` (outside the repo).
2. **Plan the second agent.** In Plan Mode, ask Copilot:

   ```text
   Propose a SECOND custom agent file for .github/agents/ that focuses
   strictly on ONE narrow concern the existing reviewer under-weights.

   For the API track: cost-only review (Container Apps minReplicas, log
   retention, Bicep parameter drift). Read-only tools only.

   For the DE track: data-quality test coverage only (uniqueness, not-null,
   freshness). Read-only tools only.

   The new agent must declare:
   - name, description ("use when…"), model, tools (read-only)
   - a handoffs/agents frontmatter entry pointing back at the primary
     reviewer with send: false (human approves the transition)
   - a refusal rule for any tool call that would write or deploy

   Do not modify the existing reviewer. Output the file content only.
   ```

3. Review the plan against the [Module 5 anti-pattern table](05-customize-agents-skills-mcp.md#anti-patterns). Reject anything that uses `tools: ['*']`, has a vague description, or omits the refusal rule.
4. Write the new file under `.github/agents/<name>.agent.md` on a disposable branch (`git switch -c lab7-second-reviewer`).
5. Reload VS Code so the new agent appears in the agent picker.
6. **Chained run.** Open the same spec, invoke the **primary** reviewer, and let it hand off to the new agent. Confirm:
   - the handoff prompt is visible and you approve it (no `send: true` surprises)
   - the second agent only uses its declared tools (Diagnostics view)
   - the second agent refuses any write/deploy ask you throw at it
7. Save the chained output as `~/scratch/lab7-chained.md`.
8. **Compare.** In one short table, record:
   - issues only the baseline caught
   - issues only the chain caught
   - issues both caught (and whether the chain's wording was sharper)
   - extra cost signal (rough turn count / token feel)
9. Decide: keep the new agent, merge it into the primary, or discard it. Record the decision in one sentence and why.
10. **Clean up.** If you keep the agent, open a real PR. Otherwise `git switch main && git branch -D lab7-second-reviewer`.

#### Acceptance

- The new agent file has an explicit `tools:` list (no `['*']`), an actionable `description`, and a refusal rule.
- The handoff is `send: false`; the human approves every transition.
- The comparison table exists and includes at least one issue that only the chain caught (or a clear note that the chain added no value).
- A keep/merge/discard decision is written down.
- The repo is either on `main` (discarded) or on a branch with a clean PR-ready diff (kept).

#### Stretch

- Replace the multi-perspective pattern with **planner → implementer → reviewer**: a planning agent produces a plan, the existing reviewer critiques it, and the new agent does a final cost pass. Note where it overspends vs the simpler chain.
- Try `allowInvocationsFromSubagents: false` on the new agent and confirm the primary cannot recursively call it without human approval.

---

### Lab 8A — Author a spec {#lab-8a--author-a-spec}

**Time:** 45 min<br>
**Outcome:** you produce a reviewed spec for one small next-feature idea on the existing app.

#### Steps

1. Open `specs/api-health-observability.spec.md`.
2. Use the prompt:

   ```text
   Draft a lightweight spec for one incremental copilot-ml observability improvement.

   Starting point:
   - v1 already has /healthz, /readyz, synthetic alert evidence, incident summary, tests, Docker, Bicep, GitHub Actions, and setup script.

   Candidate improvement:
   - Add a synthetic dependency-health summary to the API without connecting to real services.

   Context:
   - app/main.py
   - app/models.py
   - tests/test_main.py
   - specs/api-health-observability.spec.md
   - infra/bicep/main.bicep

   Requirements:
   - Keep the demo low cost.
   - No external service dependencies.
   - No database, queue, cache, or live external dependency.
   - Include acceptance criteria, out-of-scope, operational impact, rollback, and verification.
   - Do not implement.
   ```

3. Review the generated spec.
4. Ask Copilot to revise one weak section.
5. Save the final spec as a lab artifact or PR draft.

#### Acceptance

- The spec starts from v1 instead of scaffolding a new app.
- The spec includes out-of-scope, rollback, and verification.
- The spec preserves Azure cost constraints.
- At least one section was revised after human review.

---

### Lab 8B — Formal Spec Kit brownfield API lab {#lab-8b--formal-spec-kit-brownfield-api-lab}

**Time:** 60–90 min<br>
**Outcome:** you use local stakeholder documents to practice formal SDD artifacts for an existing app.

#### Steps

1. Open `docs/08-spec-driven-development.md` and read [§ When to graduate to GitHub Spec Kit](08-spec-driven-development.md#when-to-graduate-to-github-spec-kit), [§ The Spec Kit flow](08-spec-driven-development.md#the-spec-kit-flow), and [§ Quality gates](08-spec-driven-development.md#quality-gates).
2. Treat these existing repo files as your local stakeholder inputs:
   - `README.md`
   - `docs/00-prerequisites.md`
   - `specs/api-health-observability.spec.md`
   - `.github/copilot-instructions.md`
   - `infra/bicep/main.bicep`
3. If Spec Kit commands are available in your environment, initialize or use the approved local Spec Kit flow on a disposable branch.
4. If Spec Kit commands are not available, ask Copilot to simulate the artifact set in Markdown using only the local stakeholder documents.
5. Produce or review these artifacts:
   - constitution/principles
   - spec
   - plan
   - tasks
   - analysis findings
6. Score the artifacts against the quality gates in [Module 8 § Quality gates](08-spec-driven-development.md#quality-gates).

#### Acceptance

- Artifacts are based on local stakeholder documents and the v1 app.
- No external sample app is referenced.
- At least one generated artifact is rejected or revised.
- Implementation is not started until artifacts are reviewed.

---

### Lab 11 — Agent Mode adoption checklist dry-run {#lab-11--agent-mode-adoption-checklist-dry-run}

**Time:** 15–20 min<br>
**Outcome:** you walk through the printed adoption checklist against one small real backlog item **before** invoking Agent Mode, run it, then record which checklist items would have caught what actually happened.

This is the operational gate for [Module 11 — Agent Mode Adoption Checklist](11-agent-mode-checklist.md). It is intentionally short and deliberately boring; the value is the discipline.

#### Prerequisites

- A small change in mind that you would normally run Agent Mode on (XS or S sized). Suggestions if you do not have one:
  - add a test in `tests/test_main.py` asserting that `/api/version` returns a non-empty `service` and `version` string
  - tighten one test in `tests/test_main.py` to assert a specific response shape
  - add one missing not-null test to a dbt model under `specs/de/`

#### Steps

1. Open [docs/11-agent-mode-checklist.md](11-agent-mode-checklist.md) side by side with the spec or backlog item.
2. Copy the checklist into `~/scratch/lab11-checklist-<task-slug>.md`. For each box, fill in **one line** of evidence — not "yes" or "✓":

   ```text
   [x] The spec is reviewed.
       → specs/api-health-observability.spec.md is at status: reviewed, last
         clarified 2026-05-15.

   [x] The change is XS or S.
       → one endpoint, one test, no infra change.

   [x] The tool list is restricted.
       → will use default Agent Mode tools, no MCP enabled this session.

   ...
   ```

3. If **any** box is honestly empty, stop and fix the gap (clarify the spec, shrink the scope, disable an MCP server) **before** running Agent Mode.
4. Open a disposable branch (`git switch -c lab11-<task-slug>`). Run Agent Mode on the change. Keep the diff small.
5. After the run, append a **"What actually happened"** section to the same file with three lines:
   - one thing the checklist correctly caught up front
   - one thing Agent Mode did that you did **not** anticipate
   - one box you would tighten or add next time
6. Decide: merge the change, iterate, or abandon. Record the decision in one sentence.
7. **Clean up.** If abandoned, `git switch main && git branch -D lab11-<task-slug>`.

#### Acceptance

- Every box in the checklist has one line of concrete evidence (not a bare tick).
- The "What actually happened" section exists and is honest — including any surprises.
- A merge / iterate / abandon decision is recorded.
- No box was checked retroactively after Agent Mode finished.

#### Stretch

- Run the same change a second time **without** the checklist on a separate disposable branch. Compare time-to-merge, diff size, and number of revert/retry rounds.
- Convert the filled checklist into a `.github/PULL_REQUEST_TEMPLATE/agent-mode.md` so future Agent-Mode PRs prompt the same evidence.

---

### Lab 12A — Copilot CLI foundations: context, agents, skills, and MCP {#lab-12a--copilot-cli-foundations-context-agents-skills-and-mcp}

**Time:** 60–90 min  
**Outcome:** you run a terminal-first review using narrow context, custom assets, and an edge-case prompt drill.

#### Steps

1. Open `docs/12-copilot-cli.md` and read [§ Steering and context management](12-copilot-cli.md#steering-and-context-management), [§ Customization in the CLI](12-copilot-cli.md#customization-in-the-cli), and [§ Permissions and safety](12-copilot-cli.md#permissions-and-safety).
2. Read [Module 12 § Workshop use cases](12-copilot-cli.md#workshop-use-cases) and pick one use case to practice live. Leave `gh-aw` and `squad` as reference material unless the facilitator explicitly scopes live use.
3. Start a CLI session from the repo root.
4. Name the session `copilot-ml-review`.
5. Attach only:
   - `app/main.py`
   - `tests/test_main.py`
   - `infra/bicep/main.bicep`
   - `.github/workflows/deploy-aca.yml`
   - `.github/prompts/review-azure-deployment.prompt.md`
   - `.github/agents/api-platform-reviewer.agent.md`
6. Ask for a context map.
7. Use built-in discovery first.
8. Use `api-platform-reviewer`.
9. Apply `api-observability-review`.
10. Run the [Module 12 § Demo — destructive prompt drill](12-copilot-cli.md#demo--destructive-prompt-drill) inside the CLI session and capture the agent's refusal.
11. Produce a PR-ready terminal workflow summary.

#### Acceptance

- Session is named.
- Context is narrow.
- Custom agent and skill are used deliberately.
- Edge-case deployment/deletion request is converted into a summary or checklist.
- Summary is suitable for a PR comment or lab debrief.

---

### Lab 12B — Copilot SDK PR visualization demo {#lab-12b--copilot-sdk-pr-visualization-demo}

**Time:** 45–60 min  
**Outcome:** you can explain when the Copilot SDK is more useful than the CLI, and you can review or run a Python SDK demo that generates a pull-request age chart without exposing customer data.

#### Prerequisites

- Read [Module 12 § Where the Copilot SDK fits](12-copilot-cli.md#where-the-copilot-sdk-fits) and [§ Demo — PR age visualization with Python](12-copilot-cli.md#demo--pr-age-visualization-with-python).
- GitHub Copilot CLI is installed and authenticated if you run the demo live.
- Python 3.11+ is available if you run the Python recipe.
- Use the isolated local demo under `examples/copilot-sdk/`; generated output is ignored by Git.

#### Steps

1. Open the official SDK references:
   - [GitHub Copilot SDK](https://github.com/github/copilot-sdk)
   - [Copilot SDK getting started](https://github.com/github/copilot-sdk/blob/main/docs/getting-started.md)
   - [Copilot Python SDK reference](https://github.com/github/copilot-sdk/blob/main/python/README.md)
   - local demo: `examples/copilot-sdk/README.md`
   - local script: `examples/copilot-sdk/pr_visualization.py`
   - upstream recipe: [Python PR visualization recipe](https://github.com/github/awesome-copilot/blob/main/cookbook/copilot-sdk/python/pr-visualization.md)
2. In the local script, identify:
   - client and session creation
   - system message / task scoping
   - message send call
   - event handling for assistant messages, tool execution, and session idle
   - permission handler choice
   - GitHub MCP dependency
   - generated chart output
3. Decide whether this session will be a **guided walkthrough** or a **live run**.
4. Run the local dry-run from `examples/copilot-sdk/` using a public repository such as `github/copilot-sdk`.
5. If running live, install `examples/copilot-sdk/requirements.txt`, then run the local script from the same folder.
6. Approve only the minimum useful tool activity:
   - read-only GitHub PR lookup
   - local chart generation in `examples/copilot-sdk/output/`
   - setup commands inside the demo virtual environment
7. Deny or stop any request to deploy, delete resources, expose secrets, write outside the demo output directory, or use private/customer data.
8. Compare CLI versus SDK for this scenario:
   - CLI: fastest for one terminal user asking for a PR summary.
   - SDK: better when an app needs session lifecycle control, event streaming, custom tools, permission policy, or a reusable UI.
9. Save a short artifact with:
   - chart screenshot/path or dry-run reason
   - permission decisions made
   - three SDK concepts you observed
   - one hardening step required before a customer pilot

#### Acceptance

- You can explain the SDK architecture at a high level: app → SDK client → Copilot CLI runtime over JSON-RPC.
- You can name the core Python SDK concepts used by the demo.
- The demo uses public repository data or is walkthrough-only.
- No generated chart is committed to this repo; local demo output stays under the ignored `examples/copilot-sdk/output/` folder.
- Permission handling is discussed explicitly, including why blanket approval is not a production default.
- The final artifact explains whether CLI or SDK is the better surface for the PR visualization scenario.

---

### Lab 12C — Squad human-led agent team demo {#lab-12c--squad-human-led-agent-team-demo}

**Time:** 30–45 min<br>
**Outcome:** you can explain when a human-led specialist team is more useful than one broad custom agent, and you can design a Squad-style team without installing anything in this repo.

#### Steps

1. Read [Module 12 § Demo — Squad human-led agent team walkthrough](12-copilot-cli.md#demo--squad-human-led-agent-team-walkthrough).
2. Open these local assets:
   - `.github/agents/api-platform-reviewer.agent.md`
   - `.github/skills/api-observability-review/SKILL.md`
   - `.github/workflows/daily-api-health-review.md`
3. Open the [Squad README](https://github.com/bradygaster/squad) and note that Squad is alpha, human-led, and persists team state as repo files.
4. Ask Copilot to design the four-role Squad-style team from Module 12. Keep the run read-only.
5. Score the proposed team:
   - where it is sharper than one reviewer agent
   - where it adds too much coordination cost
   - which role owns final recommendation
   - which actions every role must refuse
6. Decide whether the real pilot should keep one reviewer, add one narrow reviewer, or trial Squad in a scratch repo.

#### Acceptance

- No Squad files are created in this repo.
- The output names roles, handoff rules, refusal rules, and artifacts.
- The decision explains why multi-agent coordination is or is not worth the added cost.
- Any live Squad command is run only in a scratch repo prepared by the facilitator.

---

### Lab 13A — Cloud agent: readiness test issue-to-PR {#lab-13a--cloud-agent-readiness-test-issue-to-pr}

**Time:** 45–60 min<br>
**Outcome:** you draft and review a Cloud Agent-ready issue for a small test/spec improvement.

#### Steps

1. Open `docs/13-github-cloud-agent.md` and read [§ Writing issues the agent can ship](13-github-cloud-agent.md#writing-issues-the-agent-can-ship) and [§ A reusable issue-authoring checklist](13-github-cloud-agent.md#a-reusable-issue-authoring-checklist).
2. Open `.github/ISSUE_TEMPLATE/cloud-agent-api-observability.yml`.
3. Use `/cloud-agent-task` to draft, review, and create a GitHub issue:

   ```text
   /cloud-agent-task task_idea: Improve readiness endpoint test coverage for copilot-ml by asserting all demo dependency statuses. Do not deploy to Azure.
   ```

4. Review the proposed title and issue body before approving creation.
5. Approve the prompt's GitHub MCP issue-creation step only if the task is bounded, safe, and ready for Cloud Agent assignment. If GitHub MCP issue creation is unavailable, keep the reviewed issue body as the dry-run artifact.
6. Capture the created issue URL.
7. If your environment supports cloud-agent assignment, assign the created issue on a disposable branch/repo. If not, keep the issue as a dry-run artifact or close it after review.
8. Review or simulate reviewing the PR against [Module 13 § A PR review checklist](13-github-cloud-agent.md#a-pr-review-checklist).

#### Acceptance

- Issue includes acceptance criteria, out-of-scope, expected files, verification, rollback, and exercise constraints.
- Created issue URL is captured, or the dry-run reason is documented.
- Task is small enough for one PR.
- No Azure deployment is requested.

---

### Lab 13B — Report-only agentic workflow review {#lab-13b--report-only-agentic-workflow-review}

**Time:** 45–60 min  
**Outcome:** you review a report-only workflow design and decide whether it is safe to run manually, stage, or block.

#### Steps

1. Open `.github/workflows/daily-api-health-review.md`.
2. Read [Module 13 § Cloud Agent use cases](13-github-cloud-agent.md#cloud-agent-use-cases). Use `gh-aw` and `squad` only as comparison references for report-only workflows and multi-agent collaboration, not as required lab dependencies.
3. Ask Copilot:

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

4. Complete a decision:
   - report-only approved
   - staged review required
   - blocked
5. If blocked, list the exact reason and required fix.

#### Acceptance

- A safety decision is recorded.
- The workflow remains report-only.
- No schedule or write output is enabled without review.

---

### Lab 13C — GitHub Agentic Workflows report-only demo {#lab-13c--github-agentic-workflows-report-only-demo}

**Time:** 30–45 min<br>
**Outcome:** you can translate this repo's report-only workflow idea into a `gh-aw`-style design and decide whether it is safe to stage.

#### Steps

1. Read [Module 13 § Demo — GitHub Agentic Workflows report-only sketch](13-github-cloud-agent.md#demo--github-agentic-workflows-report-only-sketch).
2. Open `.github/workflows/daily-api-health-review.md`.
3. Open the [GitHub Agentic Workflows README](https://github.com/github/gh-aw) and identify read-only defaults, safe outputs, allow-listed tools, sandboxing, and approval gates.
4. Ask Copilot to draft the `gh-aw`-style report-only workflow sketch from Module 13. Keep the run read-only.
5. Compare the sketch to the existing workflow artifact:
   - trigger and schedule posture
   - allowed inputs
   - denied actions
   - safe output location
   - human review gate
   - audit evidence
6. Record a decision: keep as design note, stage in a sandbox repo, or block.

#### Acceptance

- No `gh-aw` workflow is created or scheduled in this repo.
- The artifact includes allowed inputs, denied tools/actions, safe output, and a human review gate.
- The decision names one concrete safety reason for go, stage, or block.
- Any live `gh-aw` run happens only in a disposable GitHub repository with no secrets or production environment.

---

### Lab 14 — Data engineering track swap {#lab-14--data-engineering-track-swap}

**Time:** 30–45 min<br>
**Outcome:** you can translate the FastAPI demo labs into a dbt, SQL, PySpark, Airflow, or warehouse workflow without changing the core Copilot operating pattern.

#### Steps

1. Open `docs/14-data-engineering-track.md` and `specs/de/README.md`.
2. Pick one DE stack for the exercise: dbt, PySpark, Airflow, Databricks, or warehouse SQL.
3. Map three API-demo artifacts to DE equivalents:
   - endpoint or response model
   - test or quality gate
   - deployment or report-only workflow
4. Review the DE customization assets:
   - `.github/agents/data-pipeline-reviewer.agent.md`
   - `.github/skills/sql-cost-review/SKILL.md`
   - `.github/skills/dq-test-review/SKILL.md`
   - `.github/prompts/draft-dbt-model.prompt.md`
5. Draft a short DE lab plan that names:
   - one source file or model to inspect
   - one test or DQ check to add or review
   - one safety boundary that must not move

#### Acceptance

- You can explain the DE equivalent of `/healthz` or `/readyz`.
- You can identify one DE-specific prompt, agent, and skill.
- The proposed DE lab uses synthetic or masked data only.
- No warehouse, cloud, or production write command is run.

---
### Lab 15 — Pilot planning with the demo project {#lab-15--pilot-planning-with-the-demo-project}

**Time:** 30–45 min<br>
**Outcome:** you define which Copilot assets from the v1 demo should move into a real customer pilot.

#### Steps

1. Review the artifacts created in the module-aligned labs, especially Labs 3, 5A–5D, 8A, 11, 12A, 13A, and 13B.
2. Build a pilot inventory:
   - instructions to keep
   - prompt files to adapt
   - agent role to adapt
   - skill procedure to adapt
   - cloud-agent issue template to adapt
   - workflow sketch to adapt or reject
   - setup/deployment review process to adapt
3. Decide owners for each asset.
4. Define the first three pilot tasks.

#### Acceptance

- Pilot scope is based on reviewed artifacts.
- Owners are named.
- The first pilot tasks are small, PR-shaped, and safe.

---


## Chapter 15.4 — Completion checklist

You are done with the lab path when you have:

- A v1 orientation note.
- A reviewed plan and one scoped local test result or dry-run diff.
- A reviewed spec or formal SDD artifact set.
- One custom-agent role-contract review.
- One skill-based observability review.
- One local plugin you packaged from an existing skill.
- One second reviewer agent (kept or discarded with a written reason).
- One MCP boundary decision.
- One filled-in Agent Mode adoption checklist with a written outcome.
- One CLI workflow summary if CLI is in scope.
- One Copilot SDK demo or dry-run note if SDK is in scope.
- One Cloud Agent-ready issue if async delegation is in scope.
- One report-only workflow safety decision.
- Optional: one DE track-swap plan if the audience is data-engineering focused.
- Optional: one model/cost recommendation.
- Optional: one pilot asset inventory.

---

> **Next:** [Module Index](README.md)<br>
> **Back:** [Module 14 — Data Engineering Track](14-data-engineering-track.md)
