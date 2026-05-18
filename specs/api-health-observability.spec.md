# Spec — API health and observability baseline

| | |
|---|---|
| **Spec ID** | `copilot-ml-spec-001` |
| **Status** | Reviewed demo baseline |
| **Author** | Copilot enablement team |
| **Reviewer(s)** | Customer SRE lead / platform reviewer |
| **Created** | 2026-05-18 |
| **Last updated** | 2026-05-18 |
| **Related issue / ticket** | Demo Module 4 / Lab 3 |
| **Related PR(s)** | Filled in during workshop |

## 1. Goal

Provide a minimal FastAPI service with health, readiness, synthetic alert, and incident-summary endpoints that can be used to teach Copilot specs, prompts, custom agents, skills, CLI workflows, and cloud-agent PR review.

## 2. Background / context

The Copilot enablement program needs a bounded demo project that is realistic enough for SRE/development scenarios but safe enough to run in constrained customer environments. The app should deploy to Azure with minimal cost and should not require live production data.

## 3. Users and stakeholders

- **Learner** — needs a reliable demo project for Modules 4–8.
- **Developer learner** — practices API/test/spec workflows.
- **SRE learner** — practices read-only alert investigation, observability review, and deployment safety review.
- **Customer platform lead** — reviews whether this pattern can be adapted to an internal sandbox.

## 4. In scope

- FastAPI application with `/healthz`, `/readyz`, `/api/version`, synthetic alert, and incident-summary endpoints.
- Tests for the baseline endpoints.
- Dockerfile for containerized execution.
- Azure Container Apps Bicep with scale-to-zero cost controls.
- Copilot prompt files, custom agent, and skill for Modules 5–7.
- Cloud Agent and report-only workflow demo artifacts for Module 8.

## 5. Out of scope

- Production authentication and authorization.
- Real customer data, M365 exports, or live incident records.
- Database, cache, queue, or private networking.
- Automatic remediation, deployment, rollback, or resource deletion by an agent.
- Production-grade SLOs or alert routing.

## 6. User stories / scenarios

- As a learner, I can ask Copilot to explain a small FastAPI service and identify what is safe to change.
- As a learner, I can ask Copilot to draft a spec before modifying the app.
- As an SRE learner, I can review synthetic Azure Monitor evidence and produce a read-only triage note.
- As a platform reviewer, I can review Container Apps deployment settings for cost and safety.
- As a cloud-agent reviewer, I can assign one issue and review the resulting PR/session log.

## 7. Acceptance criteria

- [x] `GET /healthz` returns service, status, environment, and version.
- [x] `GET /readyz` returns readiness plus explicit demo dependency statuses.
- [x] Synthetic alert endpoint includes KQL-style context and runbook pointer.
- [x] Incident-summary endpoint returns ranked hypotheses and read-only checks.
- [x] `pytest` covers core endpoints.
- [x] Dockerfile runs the app on port `8080`.
- [x] Bicep defaults to Container Apps Consumption, `minReplicas: 0`, `maxReplicas: 1`.
- [x] Prompt files, custom agent, skill, CLI guide, and cloud-agent guide are present.

## 8. Non-functional constraints

- **Performance:** small demo app; no load target beyond workshop smoke tests.
- **Security:** no secrets, customer data, or live credentials in repo.
- **Compatibility:** Python 3.11+; container uses Python 3.12 slim.
- **Observability:** health/readiness endpoints and synthetic alert context are available.
- **Cost:** default Azure target should scale to zero and avoid ACR unless required.

## 9. Operational impact

- Public demo endpoint may be available during a workshop.
- The environment owner must delete the resource group after the demo unless the customer asks to retain it.
- No on-call rotation or production alert route is connected.

## 10. Blast radius

- **Affected components:** this demo API and its demo resource group only.
- **Affected environments:** local development and optional Azure workshop sandbox.
- **Maximum user/customer impact:** temporary demo endpoint unavailable.
- **Data impact:** no real customer data; synthetic responses only.

## 11. Rollback procedure

- **Rollback owner:** customer platform lead or assigned environment owner.
- **Rollback trigger:** failed smoke test, unexpected cost, or public exposure concern.
- **Rollback steps:** revert the PR or redeploy prior image; for cleanup, delete the demo resource group manually after approval.
- **Validation after rollback:** `GET /healthz` on prior endpoint or confirm resource group deletion.
- **Max acceptable rollback time:** 30 minutes for workshop demo.

## 12. Open questions

- [ ] Will the customer use a public GHCR package or private registry credentials?
- [ ] Which Azure region is approved for the workshop sandbox?
- [ ] Should Module 8 use Cloud Agent only, report-only workflow review only, or both?

## 13. References

- `README.md`
- `infra/bicep/main.bicep`
- `.github/prompts/`
- `.github/agents/api-platform-reviewer.agent.md`
- `.github/skills/api-observability-review/`
