---
description: Add or improve FastAPI health/readiness tests for the demo service.
agent: agent
model: claude-sonnet-4.6
argument-hint: "test gap or endpoint"
tools: ["codebase", "search", "editFiles", "runTerminal"]
---

# Add health-check tests

You are a test-focused Python API engineer.

## Inputs

- **Test gap:** ${input:test_gap}

## Procedure

1. Inspect `app/main.py`, `app/models.py`, and `tests/test_main.py`.
2. Add the smallest useful test for the requested endpoint or behavior.
3. If code changes are needed to make the test meaningful, keep them minimal and explain them.
4. Run `pytest` if the environment has dependencies installed; otherwise explain the exact command to run.

## Output format

- Files changed
- Test added
- Verification result
- Follow-up risks or gaps

## Constraints

- Do not add external services, databases, or network calls.
- Do not change Azure deployment files unless the user asks.
