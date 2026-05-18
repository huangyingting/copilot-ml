# Module 8 demo — Cloud Agent issue-to-PR

Use this guide to demonstrate GitHub Cloud Agent with a bounded task.

## Good Cloud Agent task

> Improve the demo API observability baseline by adding one additional assertion to the readiness tests and updating the spec if needed. Do not deploy to Azure.

## Issue body template

### Summary

Improve the readiness endpoint test coverage for copilot-ml.

### Context

The project is a training API for Copilot Modules 4–8. The readiness endpoint currently returns demo dependency statuses. We want the tests to make that contract explicit so future learners do not accidentally make the demo look production-ready.

### Acceptance criteria

- [ ] Tests assert `/readyz` returns `ready: true`.
- [ ] Tests assert demo-only dependencies are labeled `not_configured_for_demo`.
- [ ] No production dependencies, Azure services, or secrets are added.
- [ ] `pytest` passes.
- [ ] PR description explains why this is a demo readiness contract.

### Out of scope

- Azure deployment.
- Database or external dependency integration.
- Authentication.
- Alert routing.

### Expected files

- `tests/test_main.py`
- Optional: `docs/specs/api-health-observability.spec.md`

### Verification

- Run `pytest`.

### Rollback

- Revert the PR. No infrastructure rollback is required.

### Safety rules for Copilot

- Open a PR only.
- Do not deploy to Azure.
- Do not edit GitHub Actions unless needed for tests.
- Do not add secrets or live data.

### Reviewer checklist

- Review the diff.
- Review the session log for drift or unsafe attempts.
- Rerun `pytest` locally or in CI.
