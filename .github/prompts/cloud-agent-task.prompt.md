---
description: Draft a Cloud Agent-ready GitHub issue for this demo API.
agent: agent
model: claude-sonnet-4.6
argument-hint: "task idea"
tools: ["search/codebase", "search"]
---

# Draft Cloud Agent task

You are preparing a tight, reviewable issue for GitHub Copilot Cloud Agent.

## Inputs

- **Task idea:** ${input:task_idea}

## Procedure

1. Translate the task into one bounded issue for this repo.
2. Include acceptance criteria, out-of-scope, target files, test commands, and rollback notes.
3. State that the agent must open a PR and must not deploy to Azure.
4. Include reviewer checklist items for the session log and diff.

## Output format

Produce a GitHub issue body with these headings:

- Summary
- Context
- Acceptance criteria
- Out of scope
- Expected files
- Verification
- Rollback
- Safety rules for Copilot
- Reviewer checklist

## Constraints

- The issue must be one task, not a program.
- No production deployment, resource deletion, or secret handling.
