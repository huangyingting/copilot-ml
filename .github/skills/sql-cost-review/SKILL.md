---
name: sql-cost-review
description: Use when reviewing new or changed SQL queries or dbt models. Flags warehouse-cost smells (full-table scans, missing partition pruning, cartesian joins, expensive UDFs in WHERE, full-refresh on incremental models).
argument-hint: path to .sql file or dbt model name
user-invocable: true
disable-model-invocation: false
---

# SQL cost review

When invoked, do this and only this:

1. Read the SQL file(s) the user points at, plus their `schema.yml` if a dbt model.
2. Walk through [references/cost-checklist.md](references/cost-checklist.md) lens by lens.
3. Return a single markdown table:

   | Line | Severity | Smell | Suggested rewrite |
   |---|---|---|---|

4. End with a one-line verdict: `LGTM` / `nits` / `block` (block only if there is a destructive statement or a clearly unbounded scan on a known-large table).

## Rules

- Read-only. No file edits. No query execution.
- Do not estimate bytes scanned without an `EXPLAIN` plan.
- Do not crawl the rest of the project — read only the files named or directly imported.
- If the SQL uses Jinja (dbt), expand mentally; do not run `dbt compile`.
- If you flag a smell you cannot justify from the file alone, mark it `info` not `error`.
