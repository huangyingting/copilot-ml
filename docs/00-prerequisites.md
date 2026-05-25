# Module 0 — Prerequisites

> **Goal:** confirm the local tools, repository baseline, and training setup before using Copilot with the `copilot-ml` demo.

This module is intentionally practical. You should finish with a working local environment, the repository open in VS Code, and enough project context to start the tailored hands-on training.

---

## 0.1 Who this module is for

Use this module before the first workshop session or any self-guided lab if you are:

- Joining the tailored `copilot-ml` Copilot training.
- Facilitating a demo for API or developer teams.
- Preparing a clean local environment before asking Copilot to inspect or edit the project.
- Exploring the demo's Azure and GitHub deployment assets as part of the course.

If you already have the repository open, tests passing, and Copilot signed in, continue to [Module 1 — Day 1 with Copilot](01-day-1-with-copilot.md).

---

## 0.2 Required tools and access

| Requirement | How to verify |
|---|---|
| **VS Code** | VS Code opens this repository at the workspace root. |
| **GitHub Copilot** | The Copilot status icon is visible, and Copilot Chat can answer a simple “hello” prompt. |
| **Git** | `git status` works from the repository root, and you can create a disposable lab branch. |
| **Python 3.11+** | `python --version` or your team's Python launcher reports a supported version. |
| **Project dependencies** | `pytest` or `uv run pytest` can run the local test suite. |
| **Optional Docker** | Required only for the container-build lab or local container smoke test. |
| **Optional Azure CLI** | Required only for deployment setup walkthroughs. |
| **Optional GitHub CLI** | Required only for GitHub Actions setup workflows or CLI-focused labs. |

The course uses the provided demo app and sample values, so you do not need a separate Azure environment to complete the core modules.

---

## 0.3 Repository baseline

`copilot-ml` is a tailored Copilot training demo built around one existing **v1 FastAPI service**. The repository is not a greenfield exercise: the app, tests, docs, specs, and deployment examples already exist so you can practice realistic brownfield workflows.

The baseline includes:

- A typed FastAPI API in `app/`.
- Pydantic models in `app/models.py`.
- Local tests in `tests/`.
- A `Dockerfile` for local container builds.
- Azure Container Apps infrastructure in `infra/bicep/`.
- An Azure/GitHub setup script in `scripts/`.
- Reviewable specs in `specs/`.
- Copilot instructions, prompts, custom agent, skill, issue template, and workflow examples under `.github/`.

The default learning loop is:

```text
understand v1 → try a focused Copilot prompt → make a small change → verify locally → capture the useful artifact
```

---

## 0.4 Project map

| Path | Purpose |
|---|---|
| `README.md` | Quick start, local run/test commands, and Azure setup summary. |
| `app/main.py` | FastAPI app and demo endpoints such as `/healthz` and `/readyz`. |
| `app/models.py` | Pydantic models used by API responses. |
| `tests/test_main.py` | Local proof for API behavior. |
| `Dockerfile` | Container build for local and deployment workflows. |
| `specs/` | Small specs for API observability and Azure/GitHub setup. |
| `infra/bicep/` | Azure Container Apps infrastructure definition. |
| `scripts/setup-github-azure-actions.sh` | Setup script for Azure OIDC and GitHub Actions settings. |
| `.github/copilot-instructions.md` | Always-on repo guidance for Copilot. |
| `.github/prompts/` | Reusable prompt-file examples used later in the curriculum. |
| `.github/agents/` | Custom agent examples, including API review. |
| `.github/skills/` | Agent Skill examples, including API observability review. |
| `.github/workflows/` | Deployment and report-only workflow examples. |

---

## 0.5 Local validation

From the repository root, run the local tests:

```bash
uv run pytest
```

If your environment does not use `uv`, install dependencies with the Python workflow recommended by your instructor or team and run the equivalent `pytest` command.

To run the API locally:

```bash
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8080
```

Then open:

- API docs: <http://localhost:8080/docs>
- Health check: <http://localhost:8080/healthz>
- Readiness check: <http://localhost:8080/readyz>

The health and readiness endpoints are intentionally lightweight checks for the training app.

---

## 0.6 Branch and workspace hygiene

Before hands-on labs:

1. Start from a clean working tree.
2. Create a disposable lab branch.
3. Keep the repository root open in VS Code.
4. Open only the files relevant to the current lab when asking Copilot for context.
5. Skim suggested changes before keeping them.
6. Run local tests after any behavior change.

Good lab artifacts include:

- A short orientation note.
- A spec update.
- A small implementation plan.
- A test diff with evidence.
- A prompt-file improvement.
- A custom-agent or skill observation note.

Chat transcripts are less valuable than reusable artifacts you can keep with the project or share after the workshop.

---

## 0.7 First Copilot prompts

Start in Ask Mode and keep the prompt focused:

```text
Explain this demo project for a new developer.
Focus on the API endpoints, tests, docs, and Azure deployment shape.
```

```text
Inspect the current workspace and tell me whether copilot-ml has the files needed for local app review, tests, Azure deployment review, prompt files, a custom agent, and a skill.
```

```text
Suggest one beginner-friendly hands-on task for this demo project.
Keep it small enough to finish during Module 1 or Module 2.
```

---

## 0.8 Prerequisite checklist

- [ ] VS Code is installed and this repository is open at the workspace root.
- [ ] GitHub Copilot and Copilot Chat are enabled and signed in.
- [ ] You can run the local test command or know your environment's equivalent.
- [ ] You can describe what the existing v1 FastAPI app is.
- [ ] You can locate the API, tests, specs, Bicep, setup script, and Copilot customization assets.
- [ ] You have a clean branch for lab work.
- [ ] You can explain what `/healthz` and `/readyz` return in the demo app.
- [ ] You can run one focused Ask Mode prompt about the project.

Use [Lab 0 — Project orientation](15-workshop-and-labs.md#lab-0--project-orientation) when you are ready to practice.

---

> **Next:** [Module 1 — Day 1 with Copilot](01-day-1-with-copilot.md)