# Tech stack — stakeholder input

## Runtime

- Python 3.11+
- FastAPI
- Uvicorn
- Pydantic models

## Testing

- Pytest
- FastAPI TestClient

## Packaging

- Dockerfile based on `python:3.12-slim`
- GHCR image for workshop deployment

## Azure

- Azure Container Apps Consumption
- Bicep for resources
- GitHub Actions OIDC for Azure login
- No default Azure Container Registry
- No database or cache

## Constraints

- Keep the app small enough to understand during a live demo.
- Keep Azure resources deletable as one resource group.
- Prefer exported/synthetic evidence over live customer data.
