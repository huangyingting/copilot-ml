---
description: Review a SQL or dbt file for warehouse cost and performance smells. Read-only.
agent: agent
tools: [read_file, grep_search, file_search]
---

# Review SQL / dbt model for cost and performance

Goal: produce a single, copy-pasteable PR review comment that lists cost and performance issues found in the SQL file(s) the user points at. Read-only.

## Inputs expected

The user names one of:

- a path to a `.sql` file
- a dbt model name (look up the file under `models/`)
- a path to a folder of SQL files

## Steps

1. Read the file(s).
2. If a dbt model, also read its `schema.yml` for partitioning / clustering / materialization hints, and `dbt_project.yml` for project-wide configs.
3. Apply the cost checklist (read [.github/skills/sql-cost-review/references/cost-checklist.md](../skills/sql-cost-review/references/cost-checklist.md) if available, otherwise use the embedded list below).
4. Produce a single markdown comment with:
   - One-line summary (verdict: `LGTM` / `nits` / `block`).
   - Table of findings (line ref, severity, smell, suggested rewrite).
   - Suggested follow-up specs for any change beyond a one-line rewrite.

## Embedded cost checklist (fallback)

- `SELECT *` in non-test code → name columns
- Joins without explicit `ON` or with cartesian product
- Filtering after join when the filter could go in a CTE before the join
- Missing partition predicate on a partitioned source
- `ORDER BY` in a CTE consumed by another CTE (usually wasted)
- `DISTINCT` used to mask a bad join (look for upstream duplicates instead)
- Window function over an unbounded partition where a `QUALIFY ROW_NUMBER()` would do
- `materialized: table` on a model > ~1M rows without explicit reason
- Full-refresh on incremental models without justification
- `regexp_*` in `WHERE` on large columns where a `LIKE` would do
- Self-join used to find max-per-group (use `QUALIFY` instead)
- UDFs called inside a `WHERE` that defeats predicate pushdown
- `UNION` instead of `UNION ALL` when duplicates are impossible

## Hard rules

- **Read-only.** Do not modify any file.
- **No SQL execution.** Do not connect to any warehouse.
- **No estimates of bytes scanned** unless the user supplies a recent `EXPLAIN` plan or query profile.
- **Don't suggest rewrites you cannot justify from the file alone.** If you need runtime evidence, say so and ask the user to share an `EXPLAIN`.
