# Module 6 — Skills Portfolio, Packaging & Sharing

[Module 5](05-customize-agents-skills-mcp.md) introduced custom agents, skills, and MCP. This module zooms in on the **skills slice**: what skills already ship in this repo, how to author new ones, and how to bundle skills + agents + prompts into an **agent plugin** you can share across teams or organizations. It also covers the three install paths (marketplace, Git URL, local) and the `npx`-style convention for ad-hoc skill trials.

If your team's customizations have moved past "useful to me" and into "useful to other teams", this is the chapter that turns them into a distributable unit.

---

## 1. Skills inventory in this repo

| Skill | Path | Trigger | Purpose | Tools requested |
|---|---|---|---|---|
| `api-observability-review` | [.github/skills/api-observability-review/SKILL.md](../.github/skills/api-observability-review/SKILL.md) | Reviewing FastAPI endpoint changes or alert investigations | Walks through the health/readiness checklist, expected synthetic telemetry, runbook impact, ACA cost safety | read-only |
| `sql-cost-review` *(DE track)* | [.github/skills/sql-cost-review/SKILL.md](../.github/skills/sql-cost-review/SKILL.md) | New / changed SQL or dbt model | Looks for full scans, unbounded windows, missing partition pruning, costly joins | read-only |
| `dq-test-review` *(DE track)* | [.github/skills/dq-test-review/SKILL.md](../.github/skills/dq-test-review/SKILL.md) | Any dbt model change | Asks for `unique`, `not_null`, `accepted_values`, `relationships`, freshness, and a custom test if appropriate | read-only |

Each skill has the same shape:

```
.github/skills/<name>/
├── SKILL.md           # frontmatter (name, description, optional tools / model) + instructions
├── references/        # checklists, table schemas, runbook excerpts (loaded on demand)
└── scripts/           # optional helper scripts (Python, bash) the skill can call
```

### Why this shape

- **Discoverable.** VS Code lists the skill in the agent picker and surfaces it to other agents.
- **Auto-invocable.** A clear `description:` makes the skill match the right tasks without the user having to type `/<name>`.
- **Portable.** Same `SKILL.md` works in Copilot CLI, Cloud Agent, and Claude Code. This is the [agentskills.io](https://agentskills.io/) open standard.
- **Progressively loaded.** Discovery loads only `name` + `description`. Invocation loads `SKILL.md`. References and scripts load only when the skill reads / runs them. Keeps the context budget tight.

---

## 2. Anatomy of a `SKILL.md`

```markdown
---
name: sql-cost-review
description: Use when reviewing new or changed SQL queries or dbt models. Flags full-table scans, cartesian joins, missing partition pruning, and other warehouse-cost smells.
argument-hint: path to SQL file or dbt model name
user-invocable: true
disable-model-invocation: false
context: inline          # 'inline' is default; 'fork' (experimental) runs in a fresh subagent
---

# SQL cost review

When invoked, do the following ...

## Steps

1. Read the file(s) the user pointed at.
2. For each query, check ...
3. Produce a single comment block with the findings table from [references/cost-checklist.md](references/cost-checklist.md).

## Reference materials

- [references/cost-checklist.md](references/cost-checklist.md)
- [references/warehouse-anti-patterns.md](references/warehouse-anti-patterns.md)
```

Frontmatter rules to memorize:

- `name`: kebab-case, must match the folder name, no slashes, no namespaces. Bad: `de/sql-cost`. Good: `sql-cost-review`.
- `description`: one or two sentences, **task-trigger-shaped**. Bad: "SQL utility." Good: "Use when reviewing new or changed SQL or dbt models. Flags cost smells."
- `user-invocable: true` lets the user type `/<name>`. Default is true.
- `disable-model-invocation: true` hides the skill from auto-invocation (`/<name>` only).
- `context: fork` (experimental) makes the skill run in a forked sub-agent with a fresh context — useful for long reference material that you don't want to pollute the main chat.

---

## 3. Packaging — plugins

A **plugin** (Copilot Preview) bundles any combination of skills, slash commands, custom agents, hooks, and MCP servers behind a single install. Shape:

```
my-plugin/
├── plugin.json                  # name, description, version, contents
├── skills/
│   └── sql-cost-review/SKILL.md
├── agents/
│   └── data-pipeline-reviewer.agent.md
├── prompts/
│   └── draft-dbt-model.prompt.md
├── hooks/
│   └── hooks.json
└── mcp/
    └── server-config.json
```

`plugin.json` example:

```json
{
  "name": "copilot-ml-de-pack",
  "version": "0.1.0",
  "description": "Data engineering Copilot pack: spec templates, dbt/SQL skills, pipeline reviewer agent, DE-flavored prompts.",
  "skills": ["skills/sql-cost-review", "skills/dq-test-review"],
  "agents": ["agents/data-pipeline-reviewer.agent.md"],
  "prompts": ["prompts/draft-dbt-model.prompt.md", "prompts/review-sql-performance.prompt.md"],
  "hooks": ["hooks/"]
}
```

Format is auto-detected — the same plugin layout is consumed by Copilot, Copilot CLI, and Claude Code without changes.

---

## 4. Installing plugins and skills — three paths

### 4.1 From a marketplace

VS Code: Extensions view → `@agentPlugins` → search/install. Cross-tool: configure marketplace repos via `chat.pluginLocations`:

```jsonc
// settings.json
"chat.pluginLocations": [
  "github:copilot-plugins/copilot-plugins",
  "github:huangyingting/copilot-ml-plugins"  // your team's marketplace repo
]
```

A "marketplace" is just a Git repo whose `plugin-marketplace.json` lists discoverable plugins.

### 4.2 From a Git URL

```bash
# Copilot CLI
copilot plugins install github:huangyingting/copilot-ml-de-pack@v0.1.0
```

### 4.3 From a local path (during development)

```jsonc
"chat.pluginLocations": ["file:///absolute/path/to/my-plugin"]
```

VS Code reloads on save.

### 4.4 `npx`-style ad-hoc skill use

For one-off skills you want to try without installing, the convention is:

```bash
npx -y @your-org/copilot-skill-sql-cost-review --install ~/.copilot/skills/
```

The package's `bin` copies its `skills/<name>/` folder into the target directory. After install, VS Code picks the skill up on the next chat. Useful for sharing experimental skills before they earn a place in `.github/skills/`.

---

## 5. Where shareable skills live in the wild

| Source | Description |
|---|---|
| [github/awesome-copilot](https://github.com/github/awesome-copilot) | Curated prompts, agents, skills, and plugins for Copilot |
| [anthropics/skills](https://github.com/anthropics/skills) | Anthropic's reference skills (same `SKILL.md` shape, fully portable) |
| `copilot-plugins/*` | Marketplace-shaped plugin repos to point `chat.pluginLocations` at |
| Internal | Your team's own marketplace repo (one per org) |

---

## 6. Authoring discipline

- One skill, one capability. Skills compose; multi-capability skills hide bugs.
- Keep `SKILL.md` short (< 300 lines). Push longer content into `references/`.
- Treat the `description` like a search query — it is one. Write it so an LLM matches it to the right tasks.
- Pin scripts to relative paths inside the skill folder; never assume CWD.
- Mark a skill `disable-model-invocation: true` while you are iterating, then flip when it's stable.
- Add a regression test: a prompt that should match, a prompt that should not.

---

## 7. See also

- [Module 15 — Lab 14: Bundle a skill into a local plugin](15-workshop-and-labs.md#lab-14--bundle-a-skill-into-a-local-plugin) — the hands-on for this module
- [Module 5 — Custom Agents, Skills & MCP](05-customize-agents-skills-mcp.md) — skill basics and how skills fit with agents and MCP
- [Module 4 — Customize: Instructions, Prompt Files & Hooks](04-customize-instructions-prompts-and-hooks.md#customization-primitives-at-a-glance) — where skills fit among prompts / agents / hooks
- [VS Code skills docs](https://code.visualstudio.com/docs/copilot/customization/skills)
- [VS Code plugins docs](https://code.visualstudio.com/docs/copilot/customization/plugins)
- [agentskills.io](https://agentskills.io/) — open standard

---

> **Next:** [Module 7 — Sub-agents & Orchestration Patterns](07-subagents-and-orchestration.md)
> **Back:** [Module 5 — Custom Agents, Skills & MCP](05-customize-agents-skills-mcp.md)
