# Daily API health review — report-only workflow sketch

> This is a report-only workflow design sketch for Module 8. It is intentionally not a deployment workflow.

## Trigger

- `workflow_dispatch`
- Optional later: daily schedule after manual runs are reviewed.

## Goal

Produce a read-only health review for the demo API repository.

## Agent instructions

Review the repository without editing files. Summarize:

1. Health/readiness endpoint status based on code and tests.
2. Test coverage gaps for `app/main.py`.
3. Azure Container Apps cost/safety posture in `infra/bicep/main.bicep`.
4. GitHub Actions deployment risks in `.github/workflows/deploy-aca.yml`.
5. Recommended follow-up issues.

## Permissions

- Agent job: read-only repository permissions.
- No secrets passed to the agent.
- No Azure deployment.
- Safe output: workflow summary only, or draft issue comments after review.

## Safe output

Write a Markdown summary with:

- Decision: healthy / needs attention
- Evidence reviewed
- Top risks
- Suggested issues
- What was not checked
