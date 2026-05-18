# Module 10 — Pilot Playbook & Handover

> **Goal:** by the end of this module, you can decide which demo-project practices should become part of a real customer pilot, who owns them, and how success will be measured.

All planning examples use artifacts from the existing v1 project:

`copilot-ml/`

---

## Chapter 10.0 — Pilot scenario

Scenario:

> The team has completed the demo labs. Now it must decide what to adopt in a real repository: instructions, prompt files, custom agent, skill, CLI workflow, Cloud Agent issue template, report-only workflow, or SDK boundary pattern.

### Demo — create a pilot inventory

Ask Copilot:

```text
Using copilot-ml, create a pilot inventory table.

Rows:
- instructions
- prompt files
- custom agent
- skill
- MCP boundary decision
- CLI workflow
- Cloud Agent issue template
- report-only workflow
- SDK boundary design

Columns:
- demo asset
- value
- risk
- owner
- adopt / adapt / reject
```

Expected output: a decision table grounded in local assets.

---

## Chapter 10.1 — What the pilot answers

The pilot answers four questions:

1. Which Copilot workflow improves real team work?
2. Which repo assets are reused instead of ignored?
3. Which safety rules prevent bad agent behavior?
4. What is the cost and review effort per useful outcome?

The pilot is not a tool rollout by itself. It is a measured operating change: the team decides which Copilot habits and repo assets are worth adopting because they improve real work without weakening safety or review discipline.

### Evidence model

Collect evidence in three phases:

| Phase | Evidence |
|---|---|
| Before | Baseline cycle time, review rounds, test failure patterns, common repeated prompts, current runbooks/specs. |
| During | Specs drafted, plans reviewed, prompt files used, agent/skill outputs, tests run, PR review notes, cost outliers. |
| After | Adopt/adapt/reject decisions, owner map, updated repo assets, KPI summary, next hygiene date. |

### Demo — pilot questions for this project

Ask Copilot:

```text
For this demo project, turn the four pilot questions into measurable checks.
Use only local project assets and labs.
```

Expected checks:

- Did specs improve prompts?
- Did prompt files reduce repeated writing?
- Did the custom agent add role clarity?
- Did the skill improve review consistency?
- Did CLI/cloud-agent/report-only workflow stay safe?

---

## Chapter 10.2 — Pilot scope

Keep the first pilot small.

Recommended pilot shape:

- **Duration:** two to four weeks.
- **Repos:** one or two representative repositories.
- **Work type:** small PR-shaped tasks, deployment reviews, test improvements, specs, incident-summary drafts.
- **Participants:** developers, SRE/platform reviewer, repo owner, pilot owner.
- **Authority:** local tests and draft artifacts allowed; deployment and production mutation remain human-owned.

Recommended pilot assets:

- One `.github/copilot-instructions.md` baseline.
- Three prompt files adapted from the demo.
- One custom agent adapted from `api-platform-reviewer`.
- One skill adapted from `api-observability-review`.
- One Cloud Agent-ready issue template.
- One report-only workflow review, not an enabled recurring workflow.

### Demo — choose pilot scope

Ask Copilot:

```text
Given the demo assets, recommend a minimum viable customer pilot scope for a team that wants safer API and deployment reviews.
Include what to defer.
```

Expected result:

- Adopt instructions, prompt files, and a review agent first.
- Add skill once the review procedure is stable.
- Defer live MCP and recurring workflow until boundary evidence exists.

---

## Chapter 10.3 — Pre-pilot checklist

Before starting, confirm:

- [ ] Repo instructions reviewed.
- [ ] Prompt files reviewed and parameterized.
- [ ] Custom agent role contract reviewed.
- [ ] Skill description and procedure reviewed.
- [ ] MCP boundary documented.
- [ ] Mode decision table understood.
- [ ] Model/cost default selected.
- [ ] Cloud Agent issue template reviewed if async PR delegation is in scope.
- [ ] Report-only workflow reviewed if repository automation is in scope.
- [ ] Owners named for each asset.

### Demo — go/no-go review

Ask Copilot:

```text
Review the pre-pilot checklist using the demo project.
Mark each item ready, needs review, or blocked.
For blocked items, give the smallest safe next step.
```

---

## Chapter 10.4 — Pilot cadence

Use a short cadence:

- **Daily 15 minutes:** what Copilot helped, what failed, what to capture.
- **Weekly 30 minutes:** review artifacts, cost, safety, and reusable lessons.
- **End of pilot:** decide adopt, adapt, or reject each asset.

### Suggested four-week rhythm

| Week | Focus | Output |
|---|---|---|
| 1 | Orientation and baseline | Mode rules, first specs/plans, baseline metrics. |
| 2 | Customization | Prompt files, repo instructions, one agent or skill candidate. |
| 3 | Pilot execution | PR-shaped tasks, model/cost notes, review evidence. |
| 4 | Handover | KPI summary, adopted assets, owner map, next hygiene schedule. |

### Demo — weekly retro prompt

Ask Copilot:

```text
Draft a weekly retro agenda for a Copilot pilot based on the demo project assets.
Include evidence to collect and decisions to make.
```

---

## Chapter 10.5 — KPIs

Track outcomes, not activity.

| KPI | Why it matters | Source | Cadence |
|---|---|---|---|
| Spec coverage | Shows whether work starts with clear intent. | PRs/issues with specs. | Weekly |
| Plan usage | Shows whether risky work is planned before implementation. | Plan artifacts or comments. | Weekly |
| Prompt reuse | Shows whether prompt files are valuable. | Prompt-file run notes. | Weekly |
| Agent refusal proof | Shows whether role boundaries are working. | Refusal drill result. | Once per asset, then monthly |
| Skill output quality | Shows whether the procedure improves consistency. | Skill review output. | Weekly during pilot |
| Review rounds | Shows whether AI output reduces or increases rework. | PR review history. | Weekly |
| Test pass evidence | Shows whether validation is real. | Local/CI results. | Per task |
| Cost per useful artifact | Shows whether the workflow is sustainable. | Session/model usage notes. | Weekly |

Targets should be modest. A good first pilot target is not “AI writes everything.” Better targets are: fewer repeated prompts, clearer specs, faster review preparation, fewer unsafe requests, and better evidence in PRs.

### Demo — KPI table

Ask Copilot:

```text
Create a pilot KPI table for these demo outputs:
- spec
- prompt-file run
- custom-agent review
- skill review
- CLI summary
- Cloud Agent issue
- report-only workflow review

Include baseline, pilot result, evidence source, and owner.
```

---

## Chapter 10.6 — Handover package

At the end, hand over:

- Adopted repo instructions.
- Prompt files and owners.
- Custom agent file and review notes.
- Skill folder and review notes.
- MCP boundary decision.
- CLI workflow summary if used.
- Cloud Agent issue template if used.
- Report-only workflow decision if used.
- Model/cost recommendation.
- Pilot KPI summary.

### Pilot report template

Use this structure for the final report:

```markdown
# Copilot pilot — final report

## Summary
One paragraph on scope, dates, repos, and recommendation.

## KPI results
Table of baseline, pilot result, evidence, and owner.

## What worked
Patterns and assets worth keeping.

## What did not work
Prompts, agents, skills, or workflows to reject or redesign.

## Repo assets created
Instructions, prompt files, agents, skills, issue templates, workflow sketches.

## Decisions
Adopt, adapt, reject, or defer each asset.

## Next steps
Owners, dates, and next hygiene review.
```

### Demo — handover summary

Ask Copilot:

```text
Draft a one-page handover summary for the customer pilot owner.
Use the demo project assets as examples.
Include owners, adopted assets, deferred assets, KPIs, and next review date.
```

---

## Chapter 10.7 — Steady-state playbook

After the pilot, the team should keep a small playbook:

- **Defaults:** preferred modes and models by task type.
- **Mode policy:** when Ask, Plan, Agent, CLI, or Cloud Agent is allowed.
- **Spec policy:** which work requires a spec.
- **Repo assets:** owners for instructions, prompt files, agents, and skills.
- **MCP policy:** approved read-only sources and forbidden actions.
- **Report-only workflow policy:** manual review before scheduling.
- **Cost discipline:** context, output length, model tier, loop stopping.
- **Review discipline:** diff review, test evidence, session-log review.
- **Onboarding:** how new team members learn the loop.

### Monthly hygiene checklist

- [ ] Remove unused prompt files.
- [ ] Compress verbose instructions.
- [ ] Review custom agent authority and refusal tests.
- [ ] Review skill descriptions and trigger accuracy.
- [ ] Check MCP boundaries and permissions.
- [ ] Review model/cost outliers.
- [ ] Update owners and next review dates.

### Signal-to-action tuning

| Signal | Action |
|---|---|
| Same prompt repeated three times | Create or improve a prompt file. |
| Same reviewer role repeated | Consider a custom agent. |
| Same checklist repeated | Consider a skill. |
| Agent repeatedly overreaches | Tighten instructions and refusal tests. |
| Cost spikes | Narrow context, reduce output, or lower model tier. |
| PRs need many AI fixup rounds | Improve spec and Plan Mode prompts. |

---

## Chapter 10.8 — Lab connection

Use [Lab 10 — Pilot planning with the demo project](09-workshop-and-labs.md#lab-10--pilot-planning-with-the-demo-project) in Module 9.

---

> **Back:** [Module 1 — Day 1 with Copilot](01-day-1-with-copilot.md)
