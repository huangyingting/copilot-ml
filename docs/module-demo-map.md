# Module 4–8 demo map

Use this map to run the same project through multiple Copilot enablement topics.

| Module | Demo focus | Starting files | Learner output |
|---|---|---|---|
| Module 4 — Spec-Driven Development | Convert a vague request into a reviewed spec | `docs/specs/api-health-observability.spec.md`, `spec-kit/StakeholderDocuments/` | Lightweight spec or Spec Kit artifact set |
| Module 5 — Instructions and prompts | Turn repeated tasks into prompt files | `.github/copilot-instructions.md`, `.github/prompts/` | Prompt-file run result and PR-ready prompt change |
| Module 6 — Custom agents, Skills, MCP | Use native-first, then package role/procedure | `.github/agents/api-platform-reviewer.agent.md`, `.github/skills/api-observability-review/` | Agent worksheet/refusal proof and skill output |
| Module 7 — Copilot CLI | Run terminal-first review with narrow context | `docs/cli/module-7-demo.md` | Named CLI session summary and safety evidence |
| Module 8 — Cloud Agent / report-only workflow | Assign one bounded task and design report-only automation | `docs/cloud-agent/`, `.github/ISSUE_TEMPLATE/`, `.github/workflows/daily-api-health-review.md` | Cloud Agent issue/PR review and report-only workflow safety decision |

## Suggested end-to-end storyline

1. **Module 4:** "The checkout API alert is noisy; improve the demo service observability without increasing Azure cost." Draft a spec.
2. **Module 5:** Run `/draft-api-spec`, `/investigate-api-alert`, and `/review-azure-deployment` against the project.
3. **Module 6:** Use built-in Explore/Research first, then invoke `api-platform-reviewer` and `api-observability-review`.
4. **Module 7:** Repeat the review from the CLI with a named session and narrowed context.
5. **Module 8:** Draft a bounded Cloud Agent issue and review the report-only `daily-api-health-review.md` workflow sketch.

## What not to demo

- Live production deployment.
- Real customer incidents or enterprise-context exports committed to the repo.
- Autonomous rollback, Azure resource deletion, or alert-threshold mutation.
- Broad custom agents before native Copilot capabilities have been tried.
