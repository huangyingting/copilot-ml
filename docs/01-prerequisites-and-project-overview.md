# Module 1 — Prerequisites and Project Overview

> **Goal:** confirm the local prerequisites, understand what the demo project is, and know the safety boundaries before asking Copilot to change anything.

Keep this module short: learners only need enough context to start using the existing v1 project safely.

---

## 1. What this project is

`copilot-ml` is a Copilot training demo built around one existing **v1 FastAPI service**. The project shows how to use Copilot to understand, test, document, review, and safely deploy a small API to Azure Container Apps.

The repo is not a greenfield exercise. The baseline already includes:

- A small typed FastAPI API in `app/`.
- Local tests in `tests/`.
- A `Dockerfile` for container builds.
- Azure Container Apps infrastructure in `infra/bicep/`.
- A guarded Azure/GitHub setup script in `scripts/`.
- Specs in `specs/`.
- Copilot instructions, prompts, custom agent, skill, issue template, and workflow examples under `.github/`.

The default learning loop is:

```text
understand v1 → draft or revise a spec → plan a scoped change → implement after review → verify locally → capture the useful artifact
```

---

## 2. Prerequisites

Before the workshop or first hands-on session, confirm:

- VS Code is installed and GitHub Copilot is enabled.
- The `copilot-ml` repository is open at the workspace root.
- Python dependencies can be installed and tests can run locally.
- You have a clean branch for lab work.
- No secrets, production credentials, customer data, or live incident details are pasted into prompts or committed to files.
- Azure deployment, resource deletion, scaling, merge, and customer-visible publishing remain human-approved actions.

Useful local commands from the repository root:

```bash
uv run pytest
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8080
```

If your environment does not use `uv`, install dependencies with the team-approved Python workflow and run the equivalent `pytest` command.

---

## 3. Project map

| Path | Purpose |
|---|---|
| `README.md` | Quick start, local run/test commands, and Azure setup summary. |
| `app/main.py` | FastAPI app and demo endpoints such as `/healthz` and `/readyz`. |
| `app/models.py` | Pydantic models used by API responses. |
| `tests/test_main.py` | Local proof for API behavior. |
| `specs/` | Small specs for API observability and Azure/GitHub setup. |
| `infra/bicep/` | Azure Container Apps infrastructure definition. |
| `scripts/setup-github-azure-actions.sh` | Dry-run-first setup script for Azure OIDC and GitHub Actions settings. |
| `.github/copilot-instructions.md` | Always-on repo guidance for Copilot. |
| `.github/prompts/`, `.github/agents/`, `.github/skills/` | Reusable prompt, agent, and skill examples used later in the curriculum. |

---

## 4. Safety boundaries

Use Copilot read-only first. Explanation, planning, repo review, and local tests are safe starting points.

Do **not** use Copilot to autonomously:

- Add, reveal, or rotate secrets.
- Deploy to Azure or expose public endpoints.
- Delete, restart, or scale cloud resources.
- Merge PRs or publish customer-visible messages.
- Convert the demo into production infrastructure without a reviewed spec.

For live Azure or GitHub configuration, a human must approve the subscription, resource group, repository, branch, secrets, and cost posture before running write commands.

---

## 5. First safe Copilot prompts

Start in Ask Mode and keep the prompt bounded:

```text
Explain this demo project for a new developer.
Focus on the API endpoints, tests, Azure deployment shape, and safety rules.
Do not edit files or run commands.
```

```text
Inspect the current workspace and tell me whether copilot-ml has the files needed for local app review, tests, Azure deployment review, prompt files, a custom agent, and a skill.
Do not edit files.
```

```text
Rewrite this unsafe request into a safe Ask Mode prompt:
"Deploy this API to Azure now and clean up failed resources automatically."
```

---

## 6. What comes next

After this prerequisite module, the curriculum moves from safe orientation to controlled use:

| Module | Focus |
|---|---|
| [Module 2 — The Three Modes](02-three-modes.md) | Choose Ask, Plan, or Agent for the right level of authority. |
| [Module 3 — Pick the Right Model](03-pick-the-right-model.md) | Match model choice to task complexity and cost. |
| [Module 4 — Spec-Driven Development](04-spec-driven-development.md) | Turn vague ideas into reviewable specs before coding. |
| [Module 5 — Instructions & Prompt Files](05-customize-instructions-and-prompts.md) | Reuse repo instructions and prompts. |
| [Module 6 — Custom Agents, Skills & MCP](06-customize-agents-skills-mcp.md) | Add role contracts and procedures only when useful. |
| [Module 7 — Copilot CLI](07-copilot-cli.md) | Use terminal-first Copilot workflows. |
| [Module 8 — Cloud Agent & Report-only Workflows](08-github-cloud-agent.md) | Delegate bounded async work and review safe automation. |
| [Module 9 — Hands-on Labs](09-workshop-and-labs.md) | Practice the workflow end to end. |
| [Module 10 — Pilot Playbook & Handover](10-pilot-and-playbook.md) | Convert useful practices into a team pilot. |

---

## 7. Module 1 checklist

- [ ] You can describe what the `copilot-ml` project is.
- [ ] You can locate the API, tests, specs, Bicep, setup script, and Copilot customization assets.
- [ ] You know the local proof command is `uv run pytest` or the team-approved equivalent.
- [ ] You can explain why `/healthz` and `/readyz` are demo checks, not production SLO proof.
- [ ] You can state which actions require human approval.
- [ ] You can rewrite an unsafe deployment request into a read-only review prompt.

Use [Lab 1 — Project orientation](09-workshop-and-labs.md#lab-1--project-orientation) in Module 9 when you are ready to practice.

---

> **Next:** [Module 2 — The Three Modes](02-three-modes.md)