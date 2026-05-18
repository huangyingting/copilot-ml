---
name: api-observability-review
description: Reviews a FastAPI endpoint or API PR for health/readiness behavior, synthetic Azure Monitor evidence, tests, runbook impact, and low-cost Azure Container Apps deployment safety. Use for API observability reviews, alert investigation, health endpoint changes, readiness checks, or demo SRE review workflows.
argument-hint: "endpoint, PR, alert, or deployment change"
user-invocable: true
disable-model-invocation: false
context: inline
---

# API Observability Review

## Goal

Help the user review whether an API change is observable, testable, and safe to run as a low-cost Azure Container Apps demo.

## When to use this skill

- Reviewing `/healthz`, `/readyz`, or API endpoint behavior.
- Reviewing an Azure Monitor-style alert or KQL snippet.
- Reviewing Bicep or GitHub Actions changes for the demo deployment.
- Preparing a PR comment for a Cloud Agent-generated change.

## When not to use this skill

- Do not use it to run live Azure deployment.
- Do not use it for production incident response.
- Do not use it for secrets, authentication, or customer data analysis.

## Procedure

1. **Scope the target.** Identify whether the input is API behavior, test coverage, alert/KQL evidence, deployment/IaC, or PR review.
2. **Inspect relevant files.** Prefer `app/`, `tests/`, `infra/bicep/`, `.github/workflows/`, `specs/`, and the consolidated runbook section in `docs/06-customize-agents-skills-mcp.md`.
3. **Apply the checklist.** Use [review-checklist.md](./references/review-checklist.md) for health, readiness, observability, cost, and safety criteria.
4. **Recommend verification.** Prefer `pytest`, `docker build`, Bicep build/review, and read-only smoke tests.

## Output

End with:

- **Decision:** approve / approve with comments / request changes
- **Evidence reviewed:** files or artifacts
- **Observability gaps:** bullets
- **Cost/safety gaps:** bullets
- **Verification:** run or recommended
- **PR-ready comment:** concise Markdown

## Rules

- Never run or recommend live Azure write commands as an automatic action.
- Never request secrets.
- Always call out if live evidence is missing and exported evidence is being used instead.
