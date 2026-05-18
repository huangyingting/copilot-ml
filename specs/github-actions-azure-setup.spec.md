# Spec — GitHub Actions Azure deployment setup

## Goal

Provide a safe, repeatable setup path for deploying `copilot-ml` to Azure Container Apps through GitHub Actions using GitHub OIDC and GHCR.

## Background

The repository already includes:

- `.github/workflows/deploy-aca.yml` to test, build, push, deploy, and smoke test the app.
- `infra/bicep/main.bicep` to create Azure Container Apps resources.
- Low-cost Azure Container Apps defaults: Consumption-style scale to zero, `minReplicas: 0`, `maxReplicas: 1`, `0.25` vCPU, and `0.5Gi` memory.

The workflow needs GitHub repository secrets and variables before it can authenticate to Azure and deploy.

## In scope

- Add a guarded setup script that can configure:
  - Azure resource group.
  - Microsoft Entra application/service principal for GitHub Actions OIDC.
  - Federated credential for a specific GitHub repo and branch.
  - Resource-group scoped `Contributor` role assignment.
  - GitHub repository secrets and variables required by `.github/workflows/deploy-aca.yml`.
- Keep the script dry-run by default.
- Infer the GitHub repository from the current git checkout.
- Use the currently selected Azure CLI subscription.
- Require explicit `--apply` and confirmation before any live Azure or GitHub writes.
- Document prerequisites and usage.

## Out of scope

- Running live Azure deployment commands from Copilot.
- Storing client secrets, passwords, PATs, or registry tokens in the repository.
- Production deployment hardening, private networking, databases, queues, caches, or real monitoring integration.
- Raising Container Apps scale or cost defaults.

## Acceptance criteria

- A setup script exists under `scripts/`.
- The script supports `--dry-run` default behavior and an explicit `--apply` mode.
- The script infers the GitHub repository and current Azure CLI subscription without `--repo` or `--subscription-id` switches.
- The script validates required inputs before write operations.
- The script avoids printing secret values.
- The README explains how to prepare GitHub Actions settings.
- Local validation confirms script syntax and Python tests pass.

## Operational impact

When run with `--apply`, the script creates or updates Azure identity resources, a resource group, role assignment, and GitHub repository settings. These are live control-plane writes and must be run only by a human who has approved the target subscription, resource group, repository, and branch.

## Blast radius

The intended blast radius is one Azure resource group and one GitHub repository. The federated credential is scoped to one repo and one branch.

## Rollback

A human can remove:

- GitHub repository secrets and variables created by the script.
- The federated credential from the Entra application.
- The resource-group role assignment.
- The service principal and application registration if no longer used.
- The demo resource group after the workshop.

## Verification

- Run `bash -n scripts/setup-github-azure-actions.sh`.
- Run `scripts/setup-github-azure-actions.sh --help`.
- Run `uv run pytest -q`.
- After human-approved setup, manually trigger the `Deploy copilot-ml to Azure Container Apps` workflow and verify `/healthz`.

## Open questions

- Which Azure subscription and resource group should the human approve?
- Which GitHub repository and branch should be authorized for OIDC?
- Should the GHCR package remain private or be made public for the workshop?
