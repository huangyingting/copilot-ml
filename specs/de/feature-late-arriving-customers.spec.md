# Spec — late-arriving customers in fct_orders

> Example DE feature spec. Mirrors [specs/templates/feature.spec.template.md](../templates/feature.spec.template.md).

| | |
|---|---|
| **Spec ID** | `de-spec-001` |
| **Status** | draft |
| **Author** | DE pilot participant |
| **Reviewer(s)** | Analytics tech lead |
| **Created** | 2026-05-18 |
| **Last updated** | 2026-05-18 |
| **Related issue / PR** | TBD |
| **Spec size** | S |

## 1. Goal

Stop dropping ~0.2% of orders whose `customer_id` does not yet exist in `dim_customer` at the time `fct_orders` is built. Capture them with a placeholder customer key so the row stays in the fact and is enriched on the next run.

## 2. Background

`fct_orders` joins `stg_orders` to `dim_customer` with an `INNER JOIN`. Late-arriving customers — those whose row has not yet been ingested when `fct_orders` runs — silently drop. Finance reconciliation noticed a ~0.2% gap last month traced to this. This is the canonical "late-arriving dimension" problem.

## 3. Users and stakeholders

- Primary user: finance analyst running daily reconciliation
- Reviewer: analytics tech lead
- Operator: on-call DE owning the `marts_sales` dbt run

## 4. In scope

- Change the join in `models/marts/sales/fct_orders.sql` from `INNER JOIN` to `LEFT JOIN`
- Introduce a placeholder `dim_customer` row with `customer_key = -1`
- Coalesce missing `customer_key` to `-1`
- Add a model-level test that asserts `customer_key` is `not_null` after the join
- Add an `accepted_values` style sanity test for the placeholder rate (<1%)

## 5. Out of scope

- Re-modeling `dim_customer` (Type 2 SCD work is a separate spec)
- Backfilling historical missing rows in past partitions
- Changing source ingestion cadence
- Adding alerting for the placeholder rate (separate spec for the freshness/DQ alerting work)

## 6. Design sketch

- **Inputs.** `stg_orders` (daily, append-only), `dim_customer` (daily snapshot)
- **Output.** `fct_orders` (unchanged columns, no schema change)
- **Transformation.** Replace `INNER JOIN dim_customer USING (customer_id)` with `LEFT JOIN dim_customer USING (customer_id)` + `COALESCE(customer_key, -1) AS customer_key`
- **Idempotency.** Unchanged — `fct_orders` is an incremental model keyed on `order_id`. Re-running on the same partition is safe.
- **Backfill.** Not in this spec. Will be handled by a one-off `dbt run --select fct_orders --vars '{backfill_window: 30}'` after spec is built.

## 7. Acceptance criteria

- [ ] `dim_customer` includes one placeholder row with `customer_key = -1`, `customer_id = NULL`, `customer_name = 'UNKNOWN'`
- [ ] `fct_orders` rows with previously-late customers now appear with `customer_key = -1`
- [ ] dbt test `not_null_fct_orders_customer_key` passes
- [ ] dbt test `placeholder_rate_below_threshold` passes (< 1% of rows have `customer_key = -1`)
- [ ] No change in row count for `fct_orders` partitions where all customers were on-time
- [ ] Row count for late partitions **increases** by the previously-dropped count

## 8. Verification

- `dbt build --select +fct_orders` passes locally
- Run on a sample partition where late arrivals are known:
  ```sql
  SELECT COUNT(*) FROM {{ ref('fct_orders') }} WHERE customer_key = -1
  ```
  should return the previously-dropped count.

## 9. Operational impact and cost

- **Compute.** No change — same partition, same join (LEFT vs INNER same cost on warehouse).
- **Storage.** +0.2% rows.
- **Runbook.** No new alert in this spec; placeholder rate will be alerted in a follow-up.
- **Cost ceiling.** Same as today (small mart, ~$0.05/run).

## 10. Rollback

Revert the PR. The placeholder row in `dim_customer` is harmless if left in place; remove it with one DELETE on the seed.

## 11. Open questions

- Should the placeholder customer surface as `'UNKNOWN'` or as `NULL` in BI tools? Reviewer to confirm.
