---
description: Draft, review, and create a Cloud Agent-ready GitHub issue for this demo API.
agent: agent
model: claude-sonnet-4.6
argument-hint: "task idea"
tools: ["codebase", "search", "mcp_github_search_issues", "mcp_github_issue_write"]
---

# Create Cloud Agent task issue

You are preparing a tight, reviewable GitHub issue for GitHub Copilot Cloud Agent.

## Inputs

- **Task idea:** ${input:task_idea}

## Procedure

1. Translate the task into one bounded issue for this repo.
2. Include acceptance criteria, out-of-scope, target files, test commands, and rollback notes.
3. State that the agent must open a PR and must not deploy to Azure.
4. Include reviewer checklist items for the session log and diff.
5. Show the proposed issue title and body before creating anything.
6. Ask for explicit human approval before creating the issue.
7. After approval, search existing issues by title to avoid duplicates.
8. If no duplicate exists, create the issue with the GitHub MCP issue tool using these labels: `copilot`, `cloud-agent`, `demo`, `observability`.
9. Return the created issue URL and the next Cloud Agent assignment step.

## Output format

Before creation, produce a proposed GitHub issue title and body with these headings:

- Summary
- Context
- Acceptance criteria
- Out of scope
- Expected files
- Verification
- Rollback
- Safety rules for Copilot
- Reviewer checklist

After creation, return:

- Created issue URL
- Labels applied
- Cloud Agent assignment next step
- Any dry-run reason if the issue was not created

## Constraints

- The issue must be one task, not a program.
- No production deployment, resource deletion, or secret handling.
- Do not create a GitHub issue until the user approves the title and body.
- Do not assign Copilot or Cloud Agent unless the issue was created successfully and the user explicitly approves assignment.
- Prefer the GitHub MCP issue tool for creation. Do not use terminal-based `gh issue create` unless the user explicitly asks for a CLI fallback.
- If GitHub MCP issue creation is unavailable or unauthenticated, return the reviewed issue body and explain that the issue was not created.
