# SQL cost-smell checklist

Use one row per query. Severity: `error` (block), `warn` (fix this PR), `nit` (consider), `info` (heuristic).

## Scan and filter

- [ ] `SELECT *` in non-test, non-staging code → name columns (`warn`)
- [ ] Filter on partitioned column missing or wrapped in a function that defeats pruning (`error` if source > 100M rows)
- [ ] Filter applied after join when it could go in a pre-join CTE (`warn`)
- [ ] `LIKE '%foo%'` on a high-cardinality wide column (`warn`)
- [ ] `regexp_*` in `WHERE` when `LIKE` would suffice (`nit`)
- [ ] Implicit cast in `WHERE` (e.g. comparing `INT` to `STRING`) — defeats pruning (`warn`)

## Joins

- [ ] Join missing `ON` clause (`error`)
- [ ] Cartesian product on > 10K × 10K rows (`error`)
- [ ] `DISTINCT` masking duplicate rows from a bad join — fix upstream (`warn`)
- [ ] Many-to-many join not flagged in code or in `schema.yml` (`warn`)
- [ ] Self-join used for "max per group" — replace with `QUALIFY ROW_NUMBER() OVER (...)` (`nit`)

## Aggregation and windows

- [ ] `ORDER BY` in a CTE that is consumed by another CTE — usually wasted (`nit`)
- [ ] Window function without `PARTITION BY` on a very large table (`warn`)
- [ ] `COUNT(DISTINCT col)` on a high-cardinality column when an approximate count would do (`nit`)

## Materialization / dbt-specific

- [ ] `materialized: table` on a model > ~1M rows without a stated reason (`warn`)
- [ ] `materialized: incremental` with `--full-refresh` requested in the PR without justification (`warn`)
- [ ] Missing `unique_key` on an incremental model (`warn`)
- [ ] Missing partitioning / clustering on a `materialized: table` model > ~10M rows (`warn`)
- [ ] `ephemeral` model selected by many downstream models — risks re-computing the same CTE many times (`info`)

## Anti-patterns

- [ ] UDF called inside a `WHERE` clause that defeats predicate pushdown (`warn`)
- [ ] `UNION` instead of `UNION ALL` when duplicates are impossible (`nit`)
- [ ] Long chain of CTEs each adding one column — consider a single SELECT (`nit`)
- [ ] Multiple subqueries reading the same source table — consider a single CTE (`nit`)

## Hard "block" conditions

- Any `DROP`, `TRUNCATE`, `DELETE` without `WHERE`, `ALTER ... DROP COLUMN`.
- Full-refresh on an incremental model > 100M rows without an explicit cost rationale in the PR description.
- Cross-join on two large tables.
- New SELECT that exposes a column matching `email|phone|ssn|dob|name|address|ip` to a wider audience than before (escalate to `pii-scanner` or human reviewer).
