# Spec — refactor: split monolithic ingestion notebook into modular Spark job

> Example DE refactor spec. Mirrors [specs/templates/refactor.spec.template.md](../templates/refactor.spec.template.md).

| | |
|---|---|
| **Spec ID** | `de-refactor-001` |
| **Status** | draft |
| **Author** | DE pilot participant |
| **Reviewer(s)** | Platform tech lead / on-call DE |
| **Created** | 2026-05-18 |
| **Spec size** | M |

## 1. Goal

Split `notebooks/daily_ingest.ipynb` (4,200 lines, mixed ingest + clean + model + publish) into three Python modules and a thin orchestrating notebook so the job becomes testable, reviewable, and ~30% cheaper through better predicate pushdown and partition pruning.

## 2. Why this is a refactor, not a feature

Output tables (`bronze.events`, `silver.events_clean`, `gold.events_published`) keep the same schema and the same daily refresh contract. No new tables, no new columns, no new alerts.

## 3. Scope

Files / modules to touch:

- `notebooks/daily_ingest.ipynb` — split into:
  - `jobs/ingest/bronze_loader.py` (raw → bronze)
  - `jobs/ingest/silver_cleaner.py` (bronze → silver)
  - `jobs/ingest/gold_publisher.py` (silver → gold)
  - `notebooks/daily_ingest_orchestrator.ipynb` (thin notebook calling the three modules in order)
- `tests/jobs/ingest/` — new characterization tests
- Airflow DAG `dags/daily_ingest.py` — update task IDs and references

Naming changes (old → new):

- `_load_raw()` → `bronze_loader.load()`
- `_clean()` → `silver_cleaner.clean()`
- `_publish()` → `gold_publisher.publish()`

Interfaces removed: the in-notebook helper functions become module-level public functions with explicit type signatures.

## 4. Out of scope

- New columns or new tables
- Schema changes
- New tests beyond regression / characterization
- Migration to Delta Live Tables / DBT (separate spec)
- Renaming gold tables

## 5. Non-behavior-change evidence

This is the section the reviewer will read first.

- Existing pipeline-level tests in `tests/integration/test_daily_ingest_e2e.py` must keep passing.
- New characterization tests added **before** the refactor:
  - `test_bronze_row_count_matches_source.py` — row count of `bronze.events` for one sample day
  - `test_silver_hash_stable.py` — `MD5(CONCAT_WS(',', *))` per row, hashed and aggregated; before vs after must match
  - `test_gold_schema_stable.py` — `DESCRIBE gold.events_published` snapshot
- Data diff: for the same input partition, row count of `gold.events_published` is identical before vs after.
- Performance: end-to-end runtime must not regress by more than 5%.

## 6. Migration plan

1. Add `bronze_loader.py` alongside the notebook, with `bronze_loader.load()` mirroring `_load_raw()`. Add unit tests. Notebook still uses `_load_raw()`. No production change.
2. Switch the notebook to call `bronze_loader.load()`. Run characterization tests. Ship.
3. Repeat steps 1–2 for `silver_cleaner.py`.
4. Repeat steps 1–2 for `gold_publisher.py`.
5. Replace the notebook body with the thin orchestrator (just three function calls + logging). Ship.
6. Remove dead helper functions and unused imports.

Each step is one PR. Each can be reverted independently.

## 7. Acceptance criteria

- [ ] All pre-existing integration tests pass
- [ ] Characterization tests added and passing before and after each migration step
- [ ] Row counts identical for `bronze`, `silver`, `gold` on the sample-day fixture
- [ ] Schema unchanged for all three tables
- [ ] End-to-end runtime within ±5% of baseline
- [ ] Daily cost within ±10% of baseline (target: −30%, ceiling: +10%)
- [ ] No dead code left in the notebook
- [ ] No `TODO` comments added without owners

## 8. Verification

- Test command: `pytest tests/jobs/ingest/ tests/integration/test_daily_ingest_e2e.py`
- Data diff: `scripts/diff_partition.py --table gold.events_published --date 2026-05-15`
- Performance check: compare Databricks job duration for the last 5 prod runs vs. the new module's first 5 runs

## 9. Risk and rollback

- Highest-risk step: step 3 (`silver_cleaner`) — most complex transformations, joins, window functions.
- Rollback: each step is one commit; revert the offending commit and the notebook falls back to the previous internal helper.

## 10. Follow-ups (separate specs)

- Move to Delta Live Tables for declarative expectations
- Replace the orchestrating notebook with a pure Python `main.py` so the job can run outside Databricks for tests
- Add unit-test coverage report to CI
