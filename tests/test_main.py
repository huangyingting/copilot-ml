# pyright: reportMissingImports=false, reportMissingModuleSource=false

from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_healthz_returns_service_metadata():
    response = client.get("/healthz")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ok"
    assert body["service"] == "copilot-ml"
    assert "version" in body


def test_readyz_is_true_for_demo_dependencies():
    response = client.get("/readyz")
    assert response.status_code == 200
    body = response.json()
    assert body["ready"] is True
    assert body["checks"]["database"] == "not_configured_for_demo"


def test_alert_snapshot_contains_kql_training_context():
    response = client.get("/api/alerts/noisy-checkout-error")
    assert response.status_code == 200
    body = response.json()
    assert body["alert_id"] == "azmon-checkout-error-rate-sev3"
    assert "requests" in body["azure_monitor_query"]


def test_incident_summary_ranks_read_only_hypotheses():
    response = client.post(
        "/api/incidents/summarize",
        json={
            "incident_id": "INC-1001",
            "service": "checkout-api",
            "symptoms": ["5xx rate above baseline", "provider timeout errors increasing"],
            "recent_changes": ["timeout changed from 3s to 1s"],
        },
    )
    assert response.status_code == 200
    body = response.json()
    assert body["incident_id"] == "INC-1001"
    assert len(body["top_hypotheses"]) == 3
    assert body["top_hypotheses"][0]["rank"] == 1
    assert "Do not auto-mitigate" in body["recommended_human_action"]

