---
description: Propose a focused data-quality test suite for a dbt model or warehouse table.
mode: agent
tools: [read_file, grep_search, file_search]
---

# Write a focused DQ test suite

Goal: propose a **small, opinionated** set of data-quality tests for the dbt model or warehouse table the user names. Output should be ready to paste into a `schema.yml` or a `tests/` SQL file.

## Inputs expected

- A dbt model name, or a `<schema>.<table>` reference.
- (Optional) a description of the grain and the columns that matter.

## Steps

1. Read the model SQL and its current `schema.yml` (if any).
2. Identify:
   - Primary key candidate(s) → propose `unique` + `not_null`
   - Required business columns → propose `not_null`
   - Enum-like columns → propose `accepted_values` (read the model to find the actual set)
   - Foreign-key columns → propose `relationships`
   - Numeric columns with known bounds → propose a custom range test
   - Time columns → propose freshness check on the source (loaded_at vs. current_timestamp)
3. Limit the suite to **at most 8 tests per model**. More than that and the suite stops being read by anyone.
4. Output a single fenced YAML block plus, if needed, one fenced SQL block per custom test, ready for the user to drop into the repo.

## Conventions

- Use `severity: error` for primary-key and not-null on required columns.
- Use `severity: warn` for `accepted_values` and freshness so warnings don't block deploys but are visible.
- Pair every new test with a one-line comment in the YAML explaining **why**, not what.

## Hard rules

- **Read-only.** Do not edit files. Output proposals only.
- **No real data in examples.** If you need to show sample rows, use placeholders.
- **Do not propose tests you have not justified** from the model definition or the user's description. Don't bulk-add tests that just bloat the schema.
- **PII columns** (`email`, `phone`, `ssn`, `dob`, `name`, `address`, `ip`) — do not propose tests that emit raw values in failure messages. Use `where:` clauses that count, not select.
