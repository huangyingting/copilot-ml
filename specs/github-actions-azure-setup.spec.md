# Spec — GitHub Actions Azure deployment setup

| | |
|---|---|
| **Spec ID** | `copilot-ml-spec-002` |
| **Status** | Implemented v1 setup baseline; review before reuse |
| **Author** | Copilot enablement team |
| **Reviewer(s)** | Customer platform lead / Azure owner |
| **Created** | 2026-05-18 |
| **Last updated** | 2026-05-18 |

## 1. Goal

Provide a safe, repeatable setup path for deploying `copilot-ml` to Azure Container Apps through GitHub Actions using GitHub OIDC and GHCR.

## 2. Background

The repository already includes the v1 application and deployment assets:

- `.github/workflows/deploy-aca.yml` to test, build, push, deploy, and smoke test the app.
- `infra/bicep/main.bicep` to create Azure Container Apps resources.
- `scripts/setup-github-azure-actions.sh` to configure Azure identity and GitHub repository settings.
- Low-cost Azure Container Apps defaults: scale to zero, `minReplicas: 0`, `maxReplicas: 1`, `0.25` vCPU, and `0.5Gi` memory.

The setup script exists so facilitators or approved environment owners can prepare the demo repository before labs. It is not intended to teach autonomous Azure mutation from Copilot.

## 3. In scope

- Configure, when explicitly approved by a human:
  - Azure resource group.
  - Microsoft Entra application/service principal for GitHub Actions OIDC.
  - Federated credential for a specific GitHub repo and branch.
  - Resource-group scoped `Contributor` role assignment.
  - GitHub repository secrets and variables required by `.github/workflows/deploy-aca.yml`.
- Keep the script dry-run by default.
- Infer the GitHub repository from the current git checkout.
- Use the currently selected Azure CLI subscription.
- Require explicit `--apply` and confirmation before any live Azure or GitHub writes.
- Document prerequisites, usage, and safety boundaries.

## 4. Out of scope

- Running live Azure deployment commands from Copilot.
- Asking learners to create deployment identity from scratch during every lab.
- Storing client secrets, passwords, PATs, or registry tokens in the repository.
- Production deployment hardening, private networking, databases, queues, caches, or real monitoring integration.
- Raising Container Apps scale or cost defaults.
- Deleting Azure resources from an agent session.

## 5. Acceptance criteria

- [x] A setup script exists under `scripts/`.
- [x] The script is dry-run by default and has explicit `--apply` mode.
- [x] The script infers the GitHub repository and current Azure CLI subscription without requiring `--repo` or `--subscription-id` switches.
- [x] The script validates required inputs before write operations.
- [x] The script avoids printing secret values.
- [x] The README explains how to prepare GitHub Actions settings.
- [x] The deployment workflow runs tests before build/deploy.
- [x] The Bicep file preserves low-cost Container Apps settings.

## 6. Operational impact

When run with `--apply`, the setup script creates or updates Azure identity resources, a resource group, role assignment, and GitHub repository settings. These are live control-plane writes and must be run only by a human who has approved the target subscription, resource group, repository, and branch.

For learner labs, treat the script and workflow as reviewable artifacts. Learners may inspect, critique, and document the setup path, but should not run live Azure write operations unless the workshop explicitly includes a human-approved deployment exercise.

## 7. Blast radius

- **Azure:** one approved subscription and one resource group.
- **GitHub:** one repository's Actions secrets and variables.
- **Identity:** one Entra application/service principal and branch-scoped federated credential.
- **App exposure:** one optional public Container Apps endpoint during the workshop.

## 8. Rollback

A human can remove:

- GitHub repository secrets and variables created by the script.
- The federated credential from the Entra application.
- The resource-group role assignment.
- The service principal and application registration if no longer used.
- The demo resource group after the workshop.

Rollback and cleanup should be documented in workshop notes or a reviewed issue. Agents may draft checklists but must not delete resources.

## 9. Verification

- Run `bash -n scripts/setup-github-azure-actions.sh` after script edits.
- Run `scripts/setup-github-azure-actions.sh --help` to verify usage text.
- Run `pytest` or `uv run pytest` for app behavior.
- Review `.github/workflows/deploy-aca.yml` for test/build/deploy/smoke-test order.
- After human-approved setup and deployment, manually verify `/healthz` on the deployed endpoint.

## 10. Demo and lab use

- Module 1: explain what the setup script does and why it is not run automatically by Copilot.
- Module 2: classify setup/deploy/delete requests as human-approved operations, not autonomous agent tasks.
- Module 3: compare model outputs on a read-only deployment review.
- Module 4: use this spec as an example of implemented infrastructure documentation.
- Module 5: run `/review-azure-deployment` against the workflow and Bicep.
- Module 6: use the custom agent to review safety boundaries.
- Module 7: review deployment readiness from the CLI with narrow context.
- Module 8: keep Cloud Agent issues scoped to tests/specs unless a human explicitly approves deployment-related work.

## 11. Open questions

- Which Azure subscription and resource group should the human approve for each workshop?
- Which GitHub repository and branch should be authorized for OIDC?
- Should the GHCR package remain private or be made public for the workshop?
- Is the deployment workflow used live in the session, or only reviewed as a completed v1 asset?
