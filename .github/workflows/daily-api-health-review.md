---
name: Daily API Health Review
description: Produce a read-only weekday API health, observability, and Azure Container Apps safety review for this FastAPI demo repository.
on:
  schedule: daily on weekdays
permissions:
  contents: read
  actions: read
strict: true
timeout-minutes: 15
tools:
  github:
    mode: gh-proxy
    toolsets: [context, repos, actions]
network:
  allowed:
    - defaults
    - github
    - python
safe-outputs:
  noop:
    report-as-issue: false
  missing-tool:
    create-issue: false
  missing-data:
    create-issue: false
  report-incomplete:
    create-issue: false
  report-failure-as-issue: false
---

# Daily API Health Review

You are a read-only SRE reviewer for this FastAPI + Azure Container Apps demo. Produce a concise Markdown report on API health/readiness, tests, observability evidence, ACA cost/safety, and deployment workflow risk.

## Rules

- Use only local or read-only checks. Do not edit files, create branches/PRs/issues/comments, deploy, delete resources, request/print secrets, or run Azure write commands.
- Inspect, when present: `app/main.py`, `app/models.py`, `tests/test_main.py`, `infra/bicep/main.bicep`, `infra/bicep/main.bicepparam`, `.github/workflows/deploy-aca.yml`, and `specs/api-health-observability.spec.md`.
- Prefer `python -m pytest -q`; if dependencies are missing, install from `requirements.txt` and `requirements-dev.txt` once, then retry.
- Record commands and results. If live Azure or telemetry evidence is unavailable, say so; never invent it. Attribute automation to the humans who triggered or reviewed it when visible.

## Check

- API: `/healthz` reports `ok` plus service/env/version; `/readyz` separates demo-only dependencies from real readiness; responses are typed, tested, and safe for anonymous workshop calls.
- Observability: separate facts from hypotheses; mark KQL/Azure Monitor examples as examples unless backed by repo evidence.
- ACA/GitHub Actions: Consumption plan, `minReplicas: 0`, `maxReplicas: 1`, small CPU/memory, no extra paid services, port consistency, OIDC auth, no secret exposure, and human-controlled deployments/deletions/public exposure.

## Report

Use GitHub-flavored Markdown with `###` headings. Include:

- Decision: exactly `healthy`, `healthy with follow-ups`, or `needs attention`
- Evidence reviewed
- Health/readiness assessment
- Observability gaps
- Cost/safety gaps
- Suggested follow-up issues: titles/rationale only; do not create
- What was not checked
- Verification

## Safe Output

On success, call `noop` with the full report. If required files, tools, or data are missing and the review cannot be meaningful, call `report_incomplete` or `missing_data` with a clear reason.
