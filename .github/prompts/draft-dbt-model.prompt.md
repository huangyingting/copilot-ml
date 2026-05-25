---
description: Draft a small, reviewable dbt model spec from a natural-language ask.
agent: ask
---

# Draft a dbt model spec

Goal: turn the user's natural-language ask into a small, reviewable spec for **one** new or modified dbt model. Do **not** write SQL yet.

## What to produce

A markdown spec following the structure of [specs/templates/feature.spec.template.md](../../specs/templates/feature.spec.template.md), filled in for the user's request, **and nothing else**.

## Steps

1. Read the user's ask. If it implies more than one model or more than one mart, stop and ask the user to narrow scope to one model.
2. Read `dbt_project.yml`, the relevant `schema.yml`, and any model the spec will touch or reference. Do not read the full project tree.
3. Draft the spec with these constraints:
   - Pick a `Spec ID` of the form `de-spec-NNN` (NNN = next free).
   - Status = `draft`.
   - Size = XS, S, or M (never L; if it would be L, stop and ask the user to split).
   - In-scope: list the dbt file(s) to add or change, the columns to add or change, the tests to add.
   - Out-of-scope: list things you noticed the user might have meant but were not asked for.
   - Acceptance criteria: at least one item per new column, one for tests, one for cost ceiling.
   - Operational impact: estimate warehouse cost band (cheap / medium / expensive). If `expensive`, ask the user to confirm before continuing.
   - Open questions: list anything you had to guess.
4. Output the spec as a single fenced markdown block the user can save into `specs/de/<short-name>.spec.md`.

## Hard rules

- **Do not write SQL.** The spec is reviewed before code.
- **Do not edit any file.** This is a drafting prompt only.
- **Do not include real data in examples.** Use placeholder values.
- **Do not propose `materialized: table` on tables larger than ~1M rows** without flagging the cost.
- If the user has not provided a column list or grain, ask before drafting — do not guess.

## Example open questions to surface

- "What is the grain of the model — one row per X?"
- "What columns are required by the consumer?"
- "Does this need to be `incremental`, and on what unique key?"
- "Is the data sensitive (PII)? Should we mask any column in lower envs?"
