# pyright: reportMissingImports=false, reportMissingModuleSource=false

import os

from fastapi import FastAPI

from app.models import (
    AlertSnapshot,
    HealthResponse,
    Hypothesis,
    IncidentSummaryRequest,
    IncidentSummaryResponse,
    ReadinessResponse,
)


APP_NAME = "copilot-ml"
APP_ENV = os.getenv("APP_ENV", "local")
APP_VERSION = os.getenv("APP_VERSION", "0.1.0")

app = FastAPI(
    title="copilot-ml",
    summary="Minimal Web API for Copilot Modules 4–8 demos.",
    version=APP_VERSION,
)


@app.get("/", tags=["metadata"])
async def root() -> dict[str, str]:
    return {
        "service": APP_NAME,
        "docs": "/docs",
        "health": "/healthz",
        "ready": "/readyz",
    }


@app.get("/healthz", response_model=HealthResponse, tags=["health"])
async def healthz() -> HealthResponse:
    return HealthResponse(service=APP_NAME, environment=APP_ENV, version=APP_VERSION)


@app.get("/readyz", response_model=ReadinessResponse, tags=["health"])
async def readyz() -> ReadinessResponse:
    checks = {
        "configuration": "ok",
        "database": "not_configured_for_demo",
        "external_dependencies": "not_configured_for_demo",
    }
    return ReadinessResponse(ready=True, checks=checks)


@app.get("/api/version", tags=["metadata"])
async def version() -> dict[str, str]:
    return {"service": APP_NAME, "version": APP_VERSION, "environment": APP_ENV}


@app.get("/api/alerts/noisy-checkout-error", response_model=AlertSnapshot, tags=["training-data"])
async def noisy_checkout_error() -> AlertSnapshot:
    return AlertSnapshot(
        alert_id="azmon-checkout-error-rate-sev3",
        service="checkout-api",
        severity="sev3",
        summary="Checkout API 5xx rate is above the rolling 30-minute baseline.",
        current_error_rate=2.7,
        baseline_error_rate=0.4,
        recent_change="New payment-provider timeout setting deployed to the demo environment.",
        runbook_url="docs/05-customize-agents-skills-mcp.md#runbook--checkout-api-error-rate-alert",
        azure_monitor_query="requests | where cloud_RoleName == 'checkout-api' | summarize failures=countif(success == false), total=count() by bin(timestamp, 5m)",
    )


@app.post("/api/incidents/summarize", response_model=IncidentSummaryResponse, tags=["training-data"])
async def summarize_incident(request: IncidentSummaryRequest) -> IncidentSummaryResponse:
    symptom_text = "; ".join(request.symptoms)
    change_text = "; ".join(request.recent_changes) or "No recent change supplied."
    return IncidentSummaryResponse(
        incident_id=request.incident_id,
        service=request.service,
        top_hypotheses=[
            Hypothesis(
                rank=1,
                hypothesis="Recent configuration or dependency timeout changed request behavior.",
                evidence=f"Recent changes: {change_text}",
                next_read_only_check="Review deployment timeline and compare error rate before/after the latest change.",
            ),
            Hypothesis(
                rank=2,
                hypothesis="Downstream provider latency or failures are surfacing as API 5xx responses.",
                evidence=f"Observed symptoms: {symptom_text}",
                next_read_only_check="Query dependency duration and failure count by provider over the last 60 minutes.",
            ),
            Hypothesis(
                rank=3,
                hypothesis="Alert threshold is too sensitive for demo traffic volume.",
                evidence="The service has a low baseline and small absolute request volume in the demo environment.",
                next_read_only_check="Calculate absolute failed request count and compare against paging policy.",
            ),
        ],
        recommended_human_action="Open a reviewed issue or PR with evidence, proposed tuning, rollback notes, and owner approval. Do not auto-mitigate from the demo app.",
    )
