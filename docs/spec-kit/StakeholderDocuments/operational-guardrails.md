# Operational guardrails — stakeholder input

## Safety

- Agents may draft specs, code, tests, Bicep, workflows, and PR comments.
- Agents may run local tests if dependencies are installed.
- Agents must not run Azure write commands without explicit human approval.
- Agents must not deploy, delete resource groups, or change public endpoint exposure autonomously.

## Cost

- Container Apps must use Consumption scale.
- `minReplicas` must remain `0` for the demo.
- `maxReplicas` must remain `1` unless a reviewed spec says otherwise.
- Avoid ACR, databases, caches, and private networking for the base workshop.

## Observability

- Health and readiness endpoints must be testable.
- Synthetic alert evidence must be labeled synthetic.
- Triage output must separate facts, hypotheses, and read-only next checks.

## Rollback and cleanup

- Rollback is PR revert or redeploy prior image.
- Cleanup is manual deletion of the demo resource group after workshop approval.
- No automated deletion workflow is included by default.
