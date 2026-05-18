# copilot-ml

This project was created for GitHub Copilot training, demonstrating how Copilot can assist with developing, testing, documenting, and operating a small FastAPI service for Azure Container Apps.

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
