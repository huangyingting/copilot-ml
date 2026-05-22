# Spec — bugfix: dim_customer.email is null for ~3% of rows

> Example DE bugfix spec. Mirrors [specs/templates/bugfix.spec.template.md](../templates/bugfix.spec.template.md).

| | |
|---|---|
| **Spec ID** | `de-bug-001` |
| **Status** | draft |
| **Author** | DE pilot participant |
| **Reviewer(s)** | Analytics tech lead / CRM data owner |
| **Created** | 2026-05-18 |
| **Severity** | sev2 |
| **Related incident** | INC-2026-0418 |
| **Spec size** | XS |

## 1. Symptom

The downstream `send-welcome-email` job logs ~3% delivery failures with `recipient_address_missing`. Trace shows the rows are read from `dim_customer` with `email IS NULL`. Expected null rate: < 0.1%.

## 2. Reproduction

```sql
SELECT
  COUNT(*)                       AS total,
  COUNT_IF(email IS NULL)        AS null_email,
  COUNT_IF(email IS NULL) / COUNT(*) AS null_rate
FROM analytics.dim_customer
WHERE created_date >= CURRENT_DATE - 7;
-- Expected: null_rate < 0.001
-- Observed: null_rate ≈ 0.031
```

## 3. Root cause

The staging model `stg_customer` was changed two sprints ago to read `email_address` from a new source `crm_v2`. `crm_v2` uses lowercase `email` (not `email_address`). The staging model now silently coalesces to `NULL` for every `crm_v2` row.

```sql
-- current (broken)
SELECT id, name, email_address AS email FROM {{ source('crm_v2', 'customers') }}

-- should be
SELECT id, name, email FROM {{ source('crm_v2', 'customers') }}
```

## 4. Blast radius

- Affected rows: ~3% of `dim_customer` rows created in the last 30 days (~9k rows)
- Affected downstream: `send-welcome-email`, `customer_360_dashboard`, `marketing_segments`
- Time affected: since 2026-04-02 (the deploy of the `stg_customer` change)
- Bad data written: no — `email` was simply null, not wrong. No correction-by-overwrite needed; just re-run.

## 5. Proposed fix

- One-line change in `models/staging/crm/stg_customer.sql`: `email_address` → `email` in the `crm_v2` branch of the UNION.
- Add a dbt test that fails if `dim_customer.email` null rate exceeds 1% over the last 7 days.

## 6. Out of scope

- Reformatting the wider `stg_customer.sql`
- Renaming `email` to `email_address` in `dim_customer`
- Backfilling welcome emails for the 9k missed customers (CRM team will handle separately)

## 7. Acceptance criteria

- [ ] `stg_customer.sql` reads `email` from `crm_v2`
- [ ] After `dbt run --select +dim_customer`, the null-email rate for last 7 days is below 0.1%
- [ ] New custom dbt test `email_null_rate_below_threshold` exists and passes
- [ ] CRM team notified to backfill the 9k welcome emails (not done in this PR, but linked in PR description)

## 8. Verification

- New test: `tests/dim_customer_email_null_rate.sql`
- Local repro: re-run the SQL in §2 after `dbt build --select +dim_customer`
- Production check (read-only): same SQL against `analytics.dim_customer` after the next prod run

## 9. Rollback

`git revert` the PR. Null rate returns to ~3% but nothing else breaks.

## 10. Follow-ups

- Add schema contract / source-freshness check on `crm_v2.customers` so the column rename is caught at ingest, not 6 weeks later.
- Document the column-rename detection pattern in the team's data-quality runbook.
