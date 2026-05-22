# Spec — bugfix: <short defect title>

> Copy to `specs/<area>/bugfix-<short-name>.spec.md`. Bugfix specs are usually XS or S. If reproducing the bug takes more than a day, split it.

| | |
|---|---|
| **Spec ID** | `<area>-bug-NNN` |
| **Status** | draft / reviewed / built / archived |
| **Author** | <name> |
| **Reviewer(s)** | <tech lead> / <on-call> |
| **Created** | YYYY-MM-DD |
| **Severity** | sev1 / sev2 / sev3 |
| **Related incident / ticket** | <link> |
| **Spec size** | XS / S |

## 1. Symptom

What the user, dashboard, alert, or test actually sees. Quote the error or include a screenshot link.

## 2. Reproduction

Exact steps or query to reproduce in a safe environment.

```text
<command or SQL>
```

Expected vs. observed.

## 3. Root cause (current best understanding)

One paragraph. If unknown, write "unknown — investigation needed" and stop here until the reviewer approves a spike.

## 4. Blast radius

- Who is affected (users, downstream tables, dashboards, jobs)
- How long they have been affected
- Whether bad data was written that needs backfill / correction

## 5. Proposed fix

The smallest change that resolves the symptom.

- Files / models / SQL to change
- Tests to add that would have caught this

## 6. Out of scope

- Refactors, rename cleanups, unrelated quality improvements. Keep the diff tight.

## 7. Acceptance criteria

- [ ] Bug is no longer reproducible (cite test name)
- [ ] Regression test added in <path>
- [ ] Backfill / correction applied (if applicable) — state the exact query or job
- [ ] Runbook updated (if alert behavior changed)

## 8. Verification

- New / changed test: <name>
- Local repro now passes: <command>
- Production check (read-only): <query / dashboard>

## 9. Rollback

If the fix itself causes issues, the revert is: <git revert / feature flag / config rollback>.

## 10. Follow-ups (not in this PR)

Refactors or hardening that the reviewer agrees should be filed as separate specs.
