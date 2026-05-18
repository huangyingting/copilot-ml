# pyright: reportMissingImports=false, reportMissingModuleSource=false

from typing import Literal

from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    status: Literal["ok"] = "ok"
    service: str
    environment: str
    version: str


class ReadinessResponse(BaseModel):
    ready: bool
    checks: dict[str, str]


class AlertSnapshot(BaseModel):
    alert_id: str
    service: str
    severity: Literal["sev3", "sev2", "sev1"]
    summary: str
    current_error_rate: float = Field(ge=0)
    baseline_error_rate: float = Field(ge=0)
    recent_change: str
    runbook_url: str
    azure_monitor_query: str


class IncidentSummaryRequest(BaseModel):
    incident_id: str = Field(min_length=3)
    service: str = Field(min_length=2)
    symptoms: list[str] = Field(min_length=1)
    recent_changes: list[str] = Field(default_factory=list)


class Hypothesis(BaseModel):
    rank: int
    hypothesis: str
    evidence: str
    next_read_only_check: str


class IncidentSummaryResponse(BaseModel):
    incident_id: str
    service: str
    top_hypotheses: list[Hypothesis]
    recommended_human_action: str
