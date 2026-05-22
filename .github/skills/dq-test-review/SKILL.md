---
name: dq-test-review
description: Use when reviewing dbt or warehouse table changes. Checks that the test suite covers uniqueness, not-null on required columns, accepted-values for enums, relationships for FKs, and source freshness. Suggests at most 8 tests per model.
argument-hint: dbt model name or path to schema.yml
user-invocable: true
disable-model-invocation: false
---

# Data-quality test review

When invoked, do this:

1. Read the model SQL (or table definition) and its `schema.yml`.
2. Apply the checklist in [references/dq-checklist.md](references/dq-checklist.md).
3. Return a single markdown comment with two parts:
   - **Coverage gaps** — required tests that are missing, with severity (`error` / `warn` / `nit`).
   - **Proposed additions** — a fenced YAML block ready to paste into `schema.yml`, plus fenced SQL blocks for any custom tests.
4. Cap proposals at **8 tests per model**. If more are needed, group the rest as "Follow-up spec required" with a short rationale.

## Rules

- Read-only. Do not modify any file.
- Do not run `dbt test`. Static analysis only.
- Do not suggest tests that would emit raw PII values on failure (`email|phone|ssn|dob|name|address|ip`). Use `where:` counts only.
- If the model has no `schema.yml` at all, flag that as `error` and stop after producing a minimal starter `schema.yml`.
