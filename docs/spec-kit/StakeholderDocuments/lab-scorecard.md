# Spec Kit lab scorecard

Use this scorecard to review generated Spec Kit artifacts.

| Area | Pass criteria |
|---|---|
| Problem framing | Explains why the demo project exists and which modules it supports. |
| Scope | Keeps the MVP to FastAPI, tests, Docker, Bicep, prompts, agent, skill, CLI, and cloud-agent artifacts. |
| Out of scope | Excludes production auth, real data, databases, and autonomous remediation. |
| Acceptance | Health/readiness, synthetic alert, incident summary, tests, and deployment review are testable. |
| Operations | Includes observability, cost, rollback, and cleanup. |
| Safety | Blocks secrets, live Azure mutation, and customer data. |
| Cost | Preserves Container Apps scale-to-zero and avoids unnecessary paid services. |

Decision options:

- **Approved:** ready for implementation.
- **Approve with comments:** minor wording or test criteria gaps.
- **Request changes:** scope, safety, cost, or rollback gaps must be fixed before implementation.
