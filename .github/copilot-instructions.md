# Copilot instructions — copilot-ml

This repo is a Copilot training demo for a small FastAPI service deployed to Azure Container Apps.

## Preferred workflow

1. For feature or infrastructure changes, draft or update a spec in `specs/` first.
2. Use Plan Mode before multi-file changes.
3. Keep changes small and testable.
4. Run `pytest` for Python changes.
5. For Azure changes, review Bicep and workflow safety before deployment.

## Safety boundaries

- Never run live Azure write commands unless the human explicitly approves the target subscription and resource group.
- Never add secrets to files, logs, prompts, tests, or examples.
- Never change the deployment to always-on or high-cost defaults without an explicit cost rationale.
- Never remove `minReplicas: 0` or raise `maxReplicas` above `1` for the demo unless the spec says why.

## Coding conventions

- Keep FastAPI routes small and typed with Pydantic models.
- Prefer explicit response models.
- Keep demo data synthetic and safe to share.
- Add or update tests with every behavior change.

## Azure conventions

- Default target: Azure Container Apps Consumption.
- Default registry: GHCR to avoid ACR cost in short workshops.
- Use GitHub Actions OIDC for Azure auth.
- Human review required before deployment, resource deletion, or public endpoint exposure.
