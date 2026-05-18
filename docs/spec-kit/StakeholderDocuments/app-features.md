# App features — stakeholder input

## Feature 1 — Health endpoint

The service exposes `GET /healthz` for workshop smoke tests and Container Apps probes. It returns service name, version, environment, and stable status.

## Feature 2 — Readiness endpoint

The service exposes `GET /readyz`. Because this is a minimal demo with no database or external services, readiness must label demo-only dependencies clearly instead of pretending they exist.

## Feature 3 — Synthetic Azure Monitor alert evidence

The service exposes `GET /api/alerts/noisy-checkout-error`, returning a synthetic alert snapshot with severity, current/baseline error rate, recent change, runbook pointer, and KQL-style query.

## Feature 4 — Incident summary helper

The service exposes `POST /api/incidents/summarize`, accepting symptoms and recent changes and returning ranked hypotheses with read-only validation steps.

## Feature 5 — Deployment review surface

The repo includes Bicep and GitHub Actions that allow learners to review cost, scale, registry, identity, and rollback decisions.
