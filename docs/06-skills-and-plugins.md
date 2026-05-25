# Module 6 — Skills Portfolio, Packaging & Sharing

[Module 5](05-customize-agents-skills-mcp.md) introduced custom agents, skills, and MCP. This module zooms in on the **skills slice**: what skills already ship in this repo, how to author new ones, and how to bundle skills, agents, hooks, and MCP server config into an **agent plugin** you can share across teams or organizations. It also covers the three install paths: marketplace, Git URL, and local path.

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

## 3. Packaging — plugins {#3-packaging--plugins}

A **plugin** (Copilot Preview) bundles any combination of skills, custom agents, hooks, and MCP servers behind a single install. The official shape matches [Module 5 § Agent plugins (Preview)](05-customize-agents-skills-mcp.md#agent-plugins-preview):

```
my-plugin/
├── plugin.json              # Plugin metadata and configuration
├── skills/
│   └── sql-cost-review/
│       └── SKILL.md
├── agents/
│   └── data-pipeline-reviewer.agent.md
├── hooks.json               # Lifecycle hooks (Copilot format — at the plugin root)
└── .mcp.json                # MCP server definitions
```

`plugin.json` example:

```json
{
  "name": "copilot-ml-de-pack",
  "version": "0.1.0",
  "description": "Data engineering Copilot pack: dbt/SQL skills and a pipeline reviewer agent.",
  "author": { "name": "Your Team" },
  "skills": "skills/",
  "agents": "agents/",
  "hooks": "hooks.json",
  "mcpServers": ".mcp.json"
}
```

Field rules per the [VS Code plugin reference](https://code.visualstudio.com/docs/copilot/customization/agent-plugins#_plugin-metadata-pluginjson) and the [Copilot CLI plugin reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference#pluginjson):

- `skills` / `agents`: string or string array of **directory** paths (default `skills/` and `agents/`). Each subdirectory holds one skill/agent.
- `hooks`: path to a hooks JSON file (or an inline hooks object). For Copilot format the file lives at the plugin root as `hooks.json`; for Claude format it lives at `hooks/hooks.json` — VS Code auto-detects.
- `mcpServers`: path to an MCP config file (typically `.mcp.json` at the plugin root) or an inline server object.
- `prompts` is **not** a documented top-level field. Ship reusable prompts as skills or as repo-level `.prompt.md` files instead.

The plugin format is shared between VS Code, Copilot CLI, and Claude Code — VS Code auto-detects which format a given plugin uses.

---

## 4. Installing plugins and skills

### 4.1 From a marketplace

VS Code: Extensions view → `@agentPlugins` → search/install. The default marketplaces are [`github/copilot-plugins`](https://github.com/github/copilot-plugins) and [`github/awesome-copilot`](https://github.com/github/awesome-copilot). Add more with `chat.plugins.marketplaces`:

```jsonc
// settings.json
"chat.plugins.marketplaces": [
  "anthropics/claude-code",
  "your-org/copilot-ml-plugins"
]
```

Values can be shorthand `owner/repo`, an HTTPS Git URL, an SSH-style remote, or a `file://` URI for an already-cloned marketplace. A "marketplace" is a Git repo with a `marketplace.json` file in `.github/plugin/` (Copilot/VS Code format) or `.claude-plugin/` (Claude format) that lists discoverable plugins. See the [CLI marketplace reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference#marketplacejson) for the file shape.

### 4.2 From a Git URL or source

In VS Code, run `Chat: Install Plugin From Source` from the Command Palette and enter the Git URL. In the Copilot CLI:

```bash
# Install from a registered marketplace
copilot plugin install copilot-ml-de-pack@your-org

# Install directly from a GitHub repo (OWNER/REPO[:PATH])
copilot plugin install your-org/copilot-ml-de-pack
```

The CLI plugin subcommand is singular (`copilot plugin install`, not `plugins`). Full specification syntax: [CLI plugin reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference#plugin-specification-for-install-command).

### 4.3 From a local path (during development)

`chat.pluginLocations` registers locally cloned plugin directories. It is an **object** mapping absolute paths to enabled/disabled, not an array:

```jsonc
// settings.json
"chat.pluginLocations": {
  "/absolute/path/to/my-plugin": true,
  "/absolute/path/to/another-plugin": false
}
```

VS Code reloads the plugin on save.

---

## 5. Where shareable skills live in the wild

| Source | Description |
|---|---|
| [github/awesome-copilot](https://github.com/github/awesome-copilot) | Curated prompts, agents, skills, and plugins for Copilot (registered as a default marketplace) |
| [anthropics/skills](https://github.com/anthropics/skills) | Anthropic's reference skills (same `SKILL.md` shape, fully portable) |
| [github/copilot-plugins](https://github.com/github/copilot-plugins) | Default Copilot plugin marketplace |
| Internal | Your team's own marketplace repo (registered via `chat.plugins.marketplaces`) |

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
- [VS Code agent skills docs](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [VS Code agent plugins docs](https://code.visualstudio.com/docs/copilot/customization/agent-plugins)
- [Copilot CLI plugin reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference)
- [agentskills.io](https://agentskills.io/) — open standard

---

> **Next:** [Module 7 — Sub-agents & Orchestration Patterns](07-subagents-and-orchestration.md)
> **Back:** [Module 5 — Custom Agents, Skills & MCP](05-customize-agents-skills-mcp.md)
