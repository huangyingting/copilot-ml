# API observability review checklist

## API health/readiness

- `/healthz` returns service, environment, version, and a stable `ok` status.
- `/readyz` separates demo-only dependencies from real readiness checks.
- Response models are typed and tested.
- Endpoint behavior is safe for anonymous workshop calls.

## Azure Monitoring evidence

- Alert summary separates facts from hypotheses.
- KQL examples are marked as examples unless backed by live data.
- Suggested checks are read-only.
- Triage note names missing evidence instead of inventing it.

## Deployment and cost

- Azure Container Apps Consumption is used.
- `minReplicas` remains `0`.
- `maxReplicas` remains `1` for demo use.
- CPU and memory remain small unless a spec justifies a change.
- No unnecessary Azure Container Registry, database, cache, or always-on service is added.

## Safety

- No secrets in code, logs, workflows, prompts, or examples.
- GitHub Actions uses OIDC for Azure login.
- Cloud Agent tasks are issue-to-PR only.
- Any live Azure deploy or resource deletion remains human-controlled.
