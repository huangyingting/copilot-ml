# copilot-ml

This project was created for GitHub Copilot training, demonstrating how Copilot can assist with developing, testing, documenting, and operating a small FastAPI service for Azure Container Apps.

## Training starting point

This repository is the **v1 baseline** for the demo and labs. The app, tests, Dockerfile, Azure Container Apps Bicep, GitHub Actions deployment workflow, Azure/GitHub setup script, specs, prompt files, custom agent, skill, Cloud Agent issue template, and report-only workflow artifact already exist.

Workshop activities should start by understanding the existing application, then use Copilot to make small reviewed improvements:

```text
understand v1 → draft or revise a spec → plan a scoped change → implement only after review → verify locally → capture the artifact
```

Key curriculum documents:

- `docs/01-prerequisites-and-project-overview.md` — prerequisite and project overview for the existing v1 demo.
- `docs/09-workshop-and-labs.md` — redesigned hands-on labs for the existing app.
- `specs/api-health-observability.spec.md` — baseline app/observability spec and next-feature backlog.
- `specs/github-actions-azure-setup.spec.md` — deployment setup spec and safety boundaries.

## Run locally with uv

From the repository root, start the FastAPI app on port `8080`:

```bash
uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8080
```

After the app starts, open the API docs at <http://localhost:8080/docs> or check the health endpoint at <http://localhost:8080/healthz>.

Run tests with:

```bash
uv run pytest
```

## Build and run locally with Docker

From the repository root, build the container image:

```bash
docker build -t copilot-ml:local .
```

Run the app locally on port `8080`:

```bash
docker run --rm -p 8080:8080 -e APP_ENV=local -e APP_VERSION=0.1.0 copilot-ml:local
```

After the container starts, open the API docs at <http://localhost:8080/docs> or check the health endpoint at <http://localhost:8080/healthz>.

## Prepare GitHub Actions deployment to Azure

This repo includes a GitHub Actions workflow that deploys `copilot-ml` to Azure Container Apps:

- Workflow: `.github/workflows/deploy-aca.yml`
- Infrastructure: `infra/bicep/main.bicep`
- Setup script: `scripts/setup-github-azure-actions.sh`

The setup script prepares the Azure OIDC identity and GitHub repository settings required by the workflow. It is **dry-run by default** and only performs live Azure/GitHub writes when you pass `--apply` and confirm the target settings.

The script infers the GitHub repository from the current `origin` remote and uses your currently selected Azure CLI subscription. To check or change the Azure target before setup, use `az account show` or `az account set --subscription <subscription-id>`.

Preview the setup commands without changing Azure or GitHub:

```bash
./scripts/setup-github-azure-actions.sh \
	--resource-group rg-copilot-ml-demo \
	--location eastus
```

After a human approves the target subscription, resource group, repository, and branch, apply the setup:

```bash
./scripts/setup-github-azure-actions.sh \
	--resource-group rg-copilot-ml-demo \
	--location eastus \
	--apply
```

The script configures these GitHub Actions secrets:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

And these GitHub Actions variables:

- `AZURE_RESOURCE_GROUP`
- `AZURE_LOCATION`
- `CONTAINER_APP_NAME`
- `CONTAINER_ENV_NAME`

When setup is complete, manually run the `Deploy copilot-ml to Azure Container Apps` workflow from GitHub Actions. The workflow runs tests, builds the container image, pushes it to GHCR, deploys the Bicep template, and smoke-tests `/healthz`.

For the simplest demo deployment, make the GHCR package readable by Azure Container Apps. If the package remains private, configure registry credentials separately and pass the Bicep registry parameters during deployment.
