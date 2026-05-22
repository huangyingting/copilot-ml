# Spec — refactor: <area being refactored>

> Copy to `specs/<area>/refactor-<short-name>.spec.md`. A refactor spec **must** define "no behavior change" precisely and the test evidence that proves it.

| | |
|---|---|
| **Spec ID** | `<area>-refactor-NNN` |
| **Status** | draft / reviewed / built / archived |
| **Author** | <name> |
| **Reviewer(s)** | <tech lead> / <owner of touched code> |
| **Created** | YYYY-MM-DD |
| **Spec size** | S / M (anything ≥ L should be split per [docs/09-roles-and-spec-sizing.md](../../docs/09-roles-and-spec-sizing.md)) |

## 1. Goal

One sentence. What structural improvement do we want and why now (cost, readability, testability, on-call pain, technical-debt budget)?

## 2. Why this is a refactor, not a feature

State explicitly: external behavior, schema, contract, and observable outputs do **not** change. If any of these change, this should be a feature spec instead.

## 3. Scope

- Files / modules / models / DAGs to touch
- Naming changes (old → new)
- Interfaces removed, kept, or deprecated

## 4. Out of scope

- New features, new columns, new endpoints, new tests beyond regression coverage, opportunistic rewrites of unrelated code.

## 5. Non-behavior-change evidence

The single most important section. List the tests, snapshots, or data-diff queries that, if green before and after, prove no observable change.

- Existing tests that must keep passing: <list or "all of `tests/`">
- New characterization tests added before the refactor: <list>
- Data diff (for SQL/dbt refactors): row counts, hash of <key columns>, before vs after
- Output snapshot (for notebooks / jobs): file size, schema, sample rows

## 6. Migration plan

Step-by-step, each step independently shippable and revertible.

1. Add new structure alongside old (no callers switched)
2. Switch callers one batch at a time
3. Remove old structure
4. Clean up dead code

## 7. Acceptance criteria

- [ ] All pre-existing tests still pass
- [ ] New characterization tests pass before and after
- [ ] Data diff is empty (or differences are explained and approved)
- [ ] No change in job runtime > X% (state ceiling)
- [ ] No change in cost > Y% (state ceiling)
- [ ] Dead code removed; no `TODO` left behind unowned

## 8. Verification

- Test command: <pytest / dbt build / job run>
- Data-diff command: <SQL or script>
- Performance check: <how>

## 9. Risk and rollback

- Highest-risk step: <which one>
- Rollback: revert the migration step in question — each step is one commit.

## 10. Follow-ups

What is intentionally left for later, captured as separate specs.
