# Skills in this repo

Each skill is a portable, multi-file capability defined in a `SKILL.md` file. Skills follow the [agentskills.io](https://agentskills.io/) open standard — the same files work in VS Code Copilot, Copilot CLI, Cloud Agent, and Claude Code.

See [../../docs/06-skills-and-plugins.md](../../docs/06-skills-and-plugins.md) for the bigger picture on packaging and sharing.

## Inventory

| Skill | Trigger | Purpose |
|---|---|---|
| [api-observability-review](api-observability-review/SKILL.md) | Reviewing FastAPI endpoint changes or alert investigations | Walks the health/readiness checklist, expected telemetry, runbook impact, ACA cost safety |
| [sql-cost-review](sql-cost-review/SKILL.md) | New or changed SQL / dbt model | Flags warehouse-cost smells |
| [dq-test-review](dq-test-review/SKILL.md) | Any dbt model or warehouse table change | Verifies uniqueness, not-null, FK, accepted-values, freshness; caps at 8 tests/model |

## Shape on disk

```
.github/skills/<name>/
├── SKILL.md         # frontmatter (name, description, ...) + instructions
├── references/      # checklists, schemas, runbook excerpts — loaded on demand
└── scripts/         # optional helpers the skill can call (not used yet in this repo)
```

## How a skill is invoked

- **Auto.** A clear `description:` makes the skill match relevant tasks. The agent loads `SKILL.md` only when matched.
- **Explicit.** Type `/<skill-name>` in chat. Works because `user-invocable: true` (the default).
- **From another agent.** Mention the skill by name in the parent agent's procedure and let the model load it when the task matches. Use `agents:` only for actual `.agent.md` subagents, not for skill folders.

## Authoring rules

- **Folder name = `name:` frontmatter = filename `SKILL.md`.** Mismatches silently break discovery.
- **One skill, one capability.** Skills compose; multi-capability skills hide bugs.
- **`description:` is a search query** — write it so an LLM matches it to the right task ("Use when ...").
- **Keep `SKILL.md` under ~300 lines.** Push long content into `references/`.
- **Skills are read-only by default.** If a skill needs to run a tool, declare it explicitly in frontmatter and justify in the body.

## Sharing skills outside this repo

For our team's recommended packaging path (plugin manifest, marketplace, Git URL, and local-path trials), see [docs/06-skills-and-plugins.md](../../docs/06-skills-and-plugins.md).

Good upstream sources to learn from:

- [github/awesome-copilot](https://github.com/github/awesome-copilot)
- [anthropics/skills](https://github.com/anthropics/skills)
