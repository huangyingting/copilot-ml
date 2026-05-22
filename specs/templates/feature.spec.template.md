# Spec — <feature name>

> Copy this file to `specs/<area>/<short-feature-name>.spec.md`, fill it in, and review **before** any code is written. Keep it small — one feature, one PR.

| | |
|---|---|
| **Spec ID** | `<area>-spec-NNN` |
| **Status** | draft / reviewed / built / archived |
| **Author** | <name> (data engineer is the default driver) |
| **Reviewer(s)** | <tech lead> / <SRE or data quality owner> |
| **Created** | YYYY-MM-DD |
| **Last updated** | YYYY-MM-DD |
| **Related issue / PR** | <#nnn> |
| **Spec size** | XS / S / M / L (see [docs/09-roles-and-spec-sizing.md](../../docs/09-roles-and-spec-sizing.md)) |

## 1. Goal

One sentence. What outcome does this feature deliver, and for whom?

## 2. Background / context

Why now, what exists today, and what hurts without this feature. Link to the upstream model, table, pipeline, or dashboard.

## 3. Users and stakeholders

- Primary user: <role>, expected behavior change
- Reviewer: <role>
- Operator / on-call: <role>, alert or runbook impact

## 4. In scope

- Bullet list of concrete behaviors, files, models, columns, endpoints, jobs, or DAGs to add or change.

## 5. Out of scope

- Bullet list of things that will **not** change. Be explicit — this is the strongest guardrail for Agent Mode.

## 6. Design sketch

- Inputs (sources, schema, partition, refresh cadence)
- Outputs (table / endpoint / file / artifact + schema)
- Transformations (one paragraph or a small diagram)
- Idempotency / re-run safety
- Backfill strategy (if applicable)
- Failure mode and rollback

## 7. Acceptance criteria

Checkbox-style, testable, and matched to verification steps below.

- [ ] Behavior X is observable via test / query / endpoint Y
- [ ] No regression in <existing test / metric>
- [ ] PII / sensitive columns are masked or excluded
- [ ] Cost guardrails respected (see §9)

## 8. Verification

- Unit tests: <names>
- Data-quality tests: <dbt tests / Great Expectations / SQL assertions>
- Local run: <command>
- CI: <workflow name>
- Manual check: <query or dashboard link>

## 9. Operational impact and cost

- Compute: <warehouse size / cluster size / runtime estimate>
- Storage: <added bytes / partitions>
- Runbook impact: <alert added or changed>
- Cost ceiling: <expected $ / credits per run; halt threshold>

## 10. Rollback

How to disable or revert this change in one PR. State the exact step.

## 11. Open questions

Things the reviewer must answer before this leaves `draft`. Keep this list short — if it grows past 3, the spec is too big.
