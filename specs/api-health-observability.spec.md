# Spec — copilot-ml v1 baseline and API observability backlog

| | |
|---|---|
| **Spec ID** | `copilot-ml-spec-001` |
| **Status** | Implemented v1 baseline; ready for incremental labs |
| **Author** | Copilot enablement team |
| **Reviewer(s)** | Customer SRE lead / platform reviewer |
| **Created** | 2026-05-18 |
| **Last updated** | 2026-05-18 |
| **Related issue / ticket** | Demo Module 6 / Lab 3 |
| **Related PR(s)** | Filled in during workshop |

## 1. Goal

Use the implemented `copilot-ml` v1 FastAPI service as the starting point for Copilot training. Learners should inspect the existing app, draft specs for small improvements, make scoped changes only after review, and practice safe deployment review without rebuilding the project from scratch.

## 2. Background / context

The v1 repository already includes a runnable API, tests, Dockerfile, Azure Container Apps infrastructure, GitHub Actions deployment workflow, Azure/GitHub setup script, prompt files, a custom agent, a skill, a Cloud Agent issue template, and report-only workflow sketch.

Earlier lab drafts treated some of those assets as things learners had to create during the workshop. The redesigned lab path treats them as the baseline. Training now focuses on reading, planning, improving, reviewing, and safely delegating small changes in an existing application.

## 3. Users and stakeholders

- **Learner** — needs a reliable demo project for Modules 1–8.
- **Developer learner** — practices API, test, spec, and PR-shaped implementation workflows.
- **SRE learner** — practices read-only alert investigation, observability review, and deployment safety review.
- **Customer platform lead** — reviews whether this pattern can be adapted to an internal sandbox.
- **Facilitator** — prepares the repository and optional Azure sandbox before learners start.

## 4. Implemented v1 baseline

- FastAPI application with `/`, `/healthz`, `/readyz`, `/api/version`, `/api/alerts/noisy-checkout-error`, and `/api/incidents/summarize`.
- Typed response/request models in `app/models.py`.
- Endpoint tests in `tests/test_main.py`.
- Dockerfile for local container execution on port `8080`.
- Azure Container Apps Bicep with scale-to-zero cost controls.
- GitHub Actions deployment workflow using GHCR and Azure OIDC.
- Guarded setup script in `scripts/setup-github-azure-actions.sh`.
- Copilot prompt files, custom agent, and skill.
- Cloud Agent issue template and report-only workflow review artifact.

## 5. In scope for incremental labs

- Explain and review the v1 app before edits.
- Draft or revise specs for small API/test/observability improvements.
- Add narrow tests, such as explicit readiness dependency-status assertions.
- Propose small synthetic-data features, such as a dependency health summary endpoint, only after a reviewed spec.
- Review Azure deployment safety and cost posture without running live deployment commands from Copilot.
- Use prompt files, custom agent, skill, CLI, and Cloud Agent issue patterns against the same existing repository.

## 6. Out of scope

- Rebuilding the app or deployment pipeline from scratch during learner labs.
- Production authentication and authorization.
- Real customer data, M365 exports, live incident records, or production telemetry.
- Database, cache, queue, private networking, or live external dependency integration.
- Automatic remediation, deployment, rollback, restart, scale, merge, or resource deletion by an agent.
- Production-grade SLOs, alert routing, or always-on Azure defaults.

## 7. Candidate lab backlog

Use these as small PR-shaped exercises after learners understand v1:

| Backlog item | Suggested module/lab | Expected artifact |
|---|---|---|
| Add one `/readyz` assertion for `external_dependencies` | Module 2 / Lab 2 | Small test diff and `pytest` result |
| Draft a spec for a synthetic dependency-health summary | Module 6 / Lab 3 | Reviewed spec, no implementation yet |
| Review deployment workflow after OIDC setup | Module 5 / Lab 5 | PR-ready review comment |
| Apply observability review checklist to v1 | Module 5 / Lab 6 | Findings table and follow-up issue body |
| Draft a Cloud Agent issue for a readiness-test improvement | Module 8 / Lab 8 | Bounded issue body and reviewer checklist |
| Review report-only workflow safety | Module 8 / Lab 13 | Go/no-go decision |

## 8. Acceptance criteria

### V1 baseline acceptance

- [x] `GET /healthz` returns service, status, environment, and version.
- [x] `GET /readyz` returns readiness plus explicit demo dependency statuses.
- [x] Synthetic alert endpoint includes KQL-style context and runbook pointer.
- [x] Incident-summary endpoint returns ranked hypotheses and read-only checks.
- [x] `pytest` covers core endpoints.
- [x] Dockerfile runs the app on port `8080`.
- [x] Bicep defaults to low-cost Container Apps settings: `minReplicas: 0`, `maxReplicas: 1`, `0.25` vCPU, and `0.5Gi` memory.
- [x] Prompt files, custom agent, skill, CLI guide, Cloud Agent guide, and report-only workflow artifact are present.

### Lab acceptance

- [ ] Learners can explain what v1 does before editing.
- [ ] Every implementation lab starts from a reviewed plan or spec.
- [ ] Each code-changing lab names expected files and verification command.
- [ ] Every lab keeps Azure deployment and deletion human-approved.
- [ ] Each completed lab produces a saved artifact: spec, plan, test diff, review comment, issue body, CLI summary, or go/no-go decision.

## 9. Non-functional constraints

- **Performance:** small demo app; no load target beyond workshop smoke tests.
- **Security:** no secrets, customer data, or live credentials in repo, prompts, logs, examples, issues, or tests.
- **Compatibility:** Python 3.11+ locally; container uses Python 3.12 slim.
- **Observability:** health/readiness endpoints and synthetic alert context are available for training.
- **Cost:** Azure target should scale to zero and avoid ACR or always-on services unless a reviewed spec explicitly justifies the change.

## 10. Operational impact

- The app can be run locally for all labs.
- An optional public demo endpoint may be available during a workshop after human-approved setup/deployment.
- The setup script and deployment workflow are demonstration assets; learner labs should review them before relying on them.
- The environment owner must clean up the demo resource group after the workshop unless the customer asks to retain it.
- No on-call rotation, production alert route, or live incident process is connected.

## 11. Blast radius

- **Affected components:** this demo API, its GitHub repository settings, and optional demo Azure resource group.
- **Affected environments:** local development and optional Azure workshop sandbox.
- **Maximum user/customer impact:** temporary demo endpoint unavailable.
- **Data impact:** no real customer data; synthetic responses only.

## 12. Rollback procedure

- **Code/docs rollback:** revert the PR or restore the prior commit.
- **Local lab rollback:** discard the branch or reset the scoped file change after review.
- **Azure rollback:** human operator redeploys the prior image or deletes the demo resource group after approval.
- **Validation after rollback:** run `pytest`; if Azure was used, verify `/healthz` on the restored endpoint or confirm resource group deletion.
- **Max acceptable rollback time:** 30 minutes for workshop demo cleanup.

## 13. Verification plan

- Run `pytest` for Python behavior changes.
- Run `bash -n scripts/setup-github-azure-actions.sh` after setup-script changes.
- Review `infra/bicep/main.bicep` and `.github/workflows/deploy-aca.yml` for Azure changes.
- Keep each lab artifact in a PR comment, issue body, spec file, or workshop notes.

## 14. Teaching notes

- Start every module by reminding learners that v1 already exists.
- Use Copilot first for explanation and planning, not immediate edits.
- Favor small, reversible changes that show the operating loop: spec → plan → agent → review → measure.
- Treat deployment setup as facilitator-prepared or human-approved work, not autonomous learner-agent work.

## 15. Open questions

- [ ] Which optional v1 improvement should become the main customer-facing feature lab?
- [ ] Will the workshop use only local execution, or also a human-approved Azure sandbox?
- [ ] Will the customer use a public GHCR package or private registry credentials?
- [ ] Which Azure region is approved for the workshop sandbox?
- [ ] Should Module 8 use Cloud Agent only, report-only workflow review only, or both?

## 16. References

- `README.md`
- `app/main.py`
- `app/models.py`
- `tests/test_main.py`
- `infra/bicep/main.bicep`
- `.github/workflows/deploy-aca.yml`
- `scripts/setup-github-azure-actions.sh`
- `.github/prompts/`
- `.github/agents/api-platform-reviewer.agent.md`
- `.github/skills/api-observability-review/`
