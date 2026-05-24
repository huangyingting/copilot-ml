# Module 5 — Custom Agents, Skills & MCP

[Module 4](04-customize-instructions-prompts-and-hooks.md) covered the lightweight customizations every Copilot repo should have: instructions, prompt files, and hooks. Those three primitives go a long way. But after a few weeks of real use, teams usually run into the same three new wishes:

- "I want a *different* agent for code review — one that can read but never edit."
- "We keep running this same multi-step procedure. It does not fit in a prompt file because it has scripts and reference docs."
- "Copilot needs to talk to our database / Kubernetes cluster / Jira to be really useful."

Those wishes map to three heavier customizations:

- **Custom agents** — `.agent.md` files that define a persistent persona with its own tools, model, and handoffs. A planning agent, a security reviewer, an on-call companion.
- **Agent Skills** — `SKILL.md` folders that package a multi-step capability with scripts and reference material. Skills are an [open standard](https://agentskills.io) that work across Copilot, Claude, and Codex CLI.
- **MCP servers** — Model Context Protocol servers that expose tools the agent can call to read or act on external systems (GitHub, databases, browsers, internal APIs).

These three are layered: a custom agent can use skills; a skill can call MCP tools; the same MCP server is available to every agent that is allowed to use it. You will often combine all three. Later in the module we also touch on **agent plugins (Preview)** — the packaging format that bundles any of these into a single installable unit.

This module uses the demo project's committed examples:

- `.github/agents/api-platform-reviewer.agent.md`
- `.github/skills/api-observability-review/SKILL.md`

Official VS Code references:

- [Custom agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
- [Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [MCP servers](https://code.visualstudio.com/docs/copilot/customization/mcp-servers)

---

## When to graduate from Module 4

The signs that plain instructions, prompt files, and hooks are no longer enough:

- The team keeps wishing the agent had a *different tool list* for a specific job.
- A recurring task has *real procedure*: scripts, references, multiple files — too much for a prompt file.
- A capability needs to be *portable* across Copilot, Claude, and Codex CLI.
- The agent needs to *talk to an external system*: a database, a browser, a Jira, an internal API.

Pick the asset that matches the wish:

| Wish | Asset |
|---|---|
| A persistent role with its own tools, model, and handoffs | **Custom agent** |
| A multi-step capability with scripts, references, examples | **Agent Skill** |
| Live access to an external system | **MCP server** |

A useful three-word mental model:

- **Custom agent** = specialist.
- **Skill** = power-tool attachment.
- **MCP server** = browser extension.

Specialists change *who* does the work. Power tools change *which steps* they follow. Extensions change *which systems* they can reach.

---

## Custom agents

A custom agent is a persistent persona. Once you define one, it appears alongside Ask, Plan, and Agent in the agent picker. Every invocation of that agent uses the same description, tool list, model, and (optionally) handoff rules.

Built-in agents are general-purpose. A planning agent might only need read-only tools so it cannot accidentally edit code, while an implementation agent needs full editing capabilities. By defining your own agents, you control which tools each persona can use and what the role is responsible for.

Reach for a custom agent when:

- You want a *role* that gets used across many prompts (reviewer, planner, on-call companion), not a one-shot template.
- The role needs a different tool list or model than the default.
- You want guided multi-step workflows where one agent hands off to the next.

### Where they live

Custom agent files are Markdown files with the `.agent.md` extension. The default locations are:

| Scope | Location |
|---|---|
| Workspace | `.github/agents/` |
| Workspace (Claude format) | `.claude/agents/` |
| User profile | `~/.copilot/agents/` |

A workspace agent travels with the repo and can be reviewed in code review. A user agent is yours alone and is available across every workspace.

> The `.chatmode.md` extension is deprecated. Rename existing files to `.agent.md`. "Custom chat modes" and "custom agents" are the same thing — VS Code uses the latter term now.

### File format

A custom agent has YAML frontmatter and a Markdown body. The frontmatter tells VS Code how the agent should behave; the body is the system prompt the agent uses when it runs.

```markdown
---
name: api-platform-reviewer
description: Review FastAPI changes for behavior, tests, low-cost Azure deployment, and operational safety. Read-only.
tools: ['codebase', 'search']
model: claude-sonnet-4.6
user-invocable: true
handoffs:
  - label: 'Draft a follow-up issue'
    agent: cloud-agent-task
    prompt: 'Prepare a reviewed Cloud Agent-ready issue from the review findings above.'
---
# API platform reviewer

You are the API platform reviewer for the copilot-ml demo project.

Scope:
- Review API behavior in `app/`, tests in `tests/`, deployment in `infra/bicep/` and `.github/workflows/`, and observability docs in `docs/` and `specs/`.

Rules:
- You may not edit files.
- You may not run Azure write commands or deploy.
- You must not request or print secrets.

Procedure:
1. Inspect the changed files or the file paths you are asked about.
2. Identify behavior changes, test coverage gaps, cost concerns (Container Apps Consumption, minReplicas: 0, maxReplicas: 1), and safety concerns.
3. Produce a PR-ready review comment with findings, severity, evidence, and recommended next steps.
```

The most useful frontmatter fields:

| Field | Purpose |
|---|---|
| `name` | Required. Slash-command name and label in the agent picker. |
| `description` | Shown as placeholder text in the chat input. Used by the model when deciding whether to invoke as a subagent. |
| `tools` | Restricts which tools this persona may use. Smaller surface = lower per-turn cost and better focus. |
| `agents` | Subagents this agent may invoke via `runSubagent`. |
| `model` | A specific model name, or an array (the system tries each in order until one is available). |
| `user-invocable` | `false` hides the agent from the picker but keeps it available as a subagent. |
| `handoffs` | Buttons shown after the response completes, suggesting the next agent and a pre-filled prompt. |
| `target` | `vscode`, `github-copilot`, or both — controls where the agent is loaded. |

### Custom agent vs. prompt file

A common point of confusion: custom agent or prompt file? Use this rule:

| Choose a **prompt file** when… | Choose a **custom agent** when… |
|---|---|
| You want one reusable multi-paragraph prompt | You want a role used across many prompts |
| The default tools and model are fine | You need a different tool set or model |
| Stateless — every invocation is fresh | You will spend most of your day in this persona |
| Used occasionally | Used as a persistent working mode |

A useful pattern: a custom agent that *includes* prompt files. The agent provides the persona and tools; prompt files provide reusable shortcuts inside that persona.

### Handoffs

Handoffs make a multi-step workflow explicit. After the agent finishes a response, VS Code can show buttons that move the conversation to another agent with a pre-filled prompt. This keeps each step reviewable: the user (not the model) decides when to continue.

A typical pattern is **Plan → Implement → Review**: a planning agent produces a plan, the user clicks **Start Implementation**, the implementation agent takes over with the plan as its prompt, and finally a review agent inspects the diff.

In frontmatter, handoffs look like:

```yaml
handoffs:
  - label: 'Start Implementation'
    agent: implement
    prompt: 'Execute the plan above.'
    send: false
```

Set `send: false` (the default) when the next step could edit files or run commands, so the user can review the prompt before submitting. Set `send: true` only when the next step is genuinely safe to run automatically.

### Designing a good custom agent

Before writing any YAML, answer these five questions. They are the role contract:

| Dimension | Question | Demo answer |
|---|---|---|
| **Role** | What job does this agent own? | Review FastAPI changes for safety, cost, and observability. |
| **Context** | What files matter? | `app/`, `tests/`, `infra/bicep/`, `.github/workflows/`. |
| **Authority** | What is it allowed to do? | Read code; never edit, never deploy, never print secrets. |
| **Workflow** | What happens before and after? | Triggered after a PR is ready; hands off to "Draft a follow-up issue". |
| **Quality bar** | What does good output look like? | PR-ready comment with findings, severity, evidence, next steps. |

Good agents pass five quick tests:

1. A teammate can explain when to use it in one sentence.
2. The tool list contains only what the role actually needs.
3. The body explicitly states what the agent must *not* do.
4. Risky transitions use `handoffs` with `send: false`.
5. There is a smoke-test prompt the team uses to verify it works.

### Demo — run the review agent

In the demo project, pick `api-platform-reviewer` from the agent picker and submit:

```text
Review this project for low-cost Azure deployment readiness.

Focus on:
- app/main.py
- tests/test_main.py
- infra/bicep/main.bicep
- .github/workflows/deploy-aca.yml

Do not deploy, run Azure write commands, or change files.
Output a PR-ready review comment with findings, risks, verification, and next steps.
```

Expected behavior: the agent inspects the listed files, confirms the project intentionally stays low-cost, flags any test or safety gaps, and produces a PR-ready comment. It does not edit files or attempt deployment.

### Demo — refusal test

Submit a prompt the agent should refuse:

```text
Deploy this demo to production Azure now, then delete the resource group if it fails.
```

Expected behavior: the agent refuses, explains that deployment and deletion are out of scope, and offers a safe alternative such as reviewing the Bicep file or drafting a deployment checklist for a human to execute. A refusal test is the cheapest way to confirm that your tool list and instructions actually constrain the agent.

---

## Agent Skills

Custom agents are about *who* does the work. Skills are about *which procedure they follow*. A skill is a folder containing a `SKILL.md` file plus optional scripts, references, and examples. When the agent decides a skill is relevant — or when you invoke it with `/skill-name` — VS Code loads the skill's instructions into the conversation and the agent follows them.

The killer feature is **progressive loading**:

1. **Discovery** — Copilot reads only the skill's `name` and `description` from frontmatter. Cheap.
2. **Instructions** — When the skill matches the user's intent (or the user types `/skill-name`), VS Code loads the body of `SKILL.md`.
3. **Resources** — Files in the skill folder load only when the instructions reference them by relative Markdown link.

This means you can install many skills without paying their full token cost on every request — exactly the opposite of always-on instructions.

Reach for a skill when:

- The procedure has multiple steps, scripts, or reference documents.
- The capability should be portable across Copilot, Claude, and Codex CLI.
- You want the procedure to load only when relevant, not on every chat turn.

### Where they live

| Scope | Location |
|---|---|
| Workspace | `.github/skills/`, `.claude/skills/`, `.agents/skills/` |
| User profile | `~/.copilot/skills/`, `~/.claude/skills/` |

A skill is a directory. The folder name must match the `name` field in `SKILL.md` — lowercase, hyphens, no slashes or dots, up to 64 characters. Mismatched names silently fail to load.

### Folder layout

```text
.github/skills/
└── api-observability-review/
    ├── SKILL.md                  ← required, name must match folder
    ├── references/
    │   └── review-checklist.md
    ├── scripts/                  ← optional
    └── examples/                 ← optional
```

The demo project keeps its skill intentionally small — `SKILL.md` plus a checklist under `references/`. That is enough to show progressive loading without inventing scripts the workshop does not need.

### File format

`SKILL.md` has YAML frontmatter and a Markdown body:

```markdown
---
name: api-observability-review
description: Review the demo FastAPI project for observability readiness — health/readiness endpoints, synthetic alert evidence, tests, and low-cost Azure deployment posture. Read-only. Produces a PR-ready review.
argument-hint: 'optional focus areas'
---
# API observability review

Goal: produce a short, PR-ready observability review for the copilot-ml demo.

Procedure:
1. Inspect `app/main.py` for `/healthz` and `/readyz` behavior.
2. Inspect `tests/test_main.py` for coverage of those endpoints.
3. Inspect `infra/bicep/main.bicep` for low-cost Container Apps Consumption settings.
4. Walk the [review checklist](./references/review-checklist.md) and record results.
5. Produce a review comment with findings, severity, evidence, and safe next steps.

Constraints:
- Read-only. Do not edit files.
- Do not run Azure write commands.
```

Required and useful frontmatter fields:

| Field | Required? | Purpose |
|---|---:|---|
| `name` | Yes | Slash-command name; must match folder name; ≤ 64 chars; lowercase + hyphens only. |
| `description` | Yes | Up to 1024 chars. Used by Copilot to decide whether to load the skill. Be specific about *what* it does and *when* to use it. |
| `argument-hint` | No | Hint shown next to the slash command in the chat input. |
| `user-invocable` | No | Defaults to `true`. Set to `false` to hide from the slash menu but keep it available for the model to load automatically. |
| `disable-model-invocation` | No | Defaults to `false`. Set to `true` to require manual `/skill-name` invocation. |
| `context` | No | Defaults to `inline`. Set to `fork` (experimental) to run the skill in a dedicated subagent so its intermediate reads do not pollute the parent context. |

The body should explain what the skill helps accomplish, when to use it, the step-by-step procedure, the expected output shape, and references to any included files (use Markdown links with relative paths so the agent picks them up).

### Visibility options

| `user-invocable` | `disable-model-invocation` | Result | Best for |
|---|---|---|---|
| `true` (default) | `false` (default) | Shows in `/` menu, model can also auto-load | General-purpose skills |
| `false` | `false` | Hidden from menu; model auto-loads when relevant | Background knowledge ("how we do logging") |
| `true` | `true` | Shows in `/`; only runs when user types it | Sensitive procedures you only want on demand |

### Forked context for heavy reads

By default a skill runs *inline* — its instructions are added to the parent agent's context. For skills that read many files or do long investigations whose intermediate reasoning is not interesting downstream, set `context: fork` in the frontmatter. The skill then runs in a dedicated subagent, and only its final result is returned to the parent. This keeps the main conversation lean.

Forked context is experimental and requires `github.copilot.chat.skillTool.enabled`. Good candidates are PR reviews, dependency audits, and large codebase explorations that should produce a single summary.

### Demo — inspect the skill

```text
Explain the api-observability-review skill.
What triggers it, what procedure does it follow, and which reference file does it load?
Use only the local skill folder.
```

Expected output: the skill targets observability review for the demo FastAPI project, follows the five-step procedure, and pulls in `references/review-checklist.md` when the procedure references it.

### Demo — invoke the skill

```text
/api-observability-review
Review /healthz, /readyz, the existing tests, and the low-cost Azure deployment posture.
Produce a concise review with evidence and safe next steps. Do not edit files.
```

Expected output: a short review with endpoint behavior summary, test coverage notes, Bicep cost/safety notes, and a few suggested follow-up issues or PR comments — no edits.

### Custom agent vs. skill

| Pick a **custom agent** when… | Pick a **skill** when… |
|---|---|
| You want a persistent persona with a tool list and model | You want a procedure that loads on demand |
| The asset is Copilot-specific | You want the asset to be portable across Copilot, Claude, and Codex CLI |
| The asset is *who* | The asset is *how* |

Often the answer is both. A `code-reviewer` custom agent gives you the persona and the read-only tool list; a `pr-security-review` skill gives that persona a specific procedure to follow on demand.

---

## MCP servers

Custom agents and skills change what Copilot says. MCP servers change what Copilot can *do*. The [Model Context Protocol](https://modelcontextprotocol.io) is an open standard for exposing tools to an LLM. An MCP server is a small process — local or remote — that advertises a list of tools (with JSON schemas) the agent can call. When you enable an MCP server in VS Code, every tool it exposes joins the agent's tool list.

Typical MCP servers for a project like this one:

| MCP server | What the agent can do |
|---|---|
| **GitHub** | List or search issues, read or comment on PRs, manage labels, read Actions runs. |
| **Playwright** | Drive a real browser for synthetic checks. |
| **Postgres / MySQL** | Query a read-only replica. |
| **Azure / AWS / GCP** | Inspect cloud resources through the provider's MCP server. *Read-only by default.* |
| **Filesystem** | Read or write files outside the workspace. Use sparingly. |
| **Custom (yours)** | Any internal API or runtime your team owns. |

Reach for an MCP server when:

- The task genuinely needs *live* external data or action that no local file can provide.
- The capability is used in *most* conversations in the repo — the per-turn cost gets amortized.
- You can scope the credentials to read-only by default and have a separate path for any write action.

### How to add a server

Two practical options.

**From the gallery.** Open the Extensions view, search `@mcp`, install the server you want either in your user profile (available everywhere) or in the workspace (commits a `.vscode/mcp.json` entry your team picks up). When prompted, confirm that you trust the server before starting it.

**By editing `mcp.json`.** Create `.vscode/mcp.json` in your workspace (shared with the team) or run **MCP: Open User Configuration** to edit the user-level file. A minimal config with two servers:

```jsonc
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp"
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@microsoft/mcp-server-playwright"]
    }
  }
}
```

Never hard-code credentials in `mcp.json` — the file is source-controlled. Use environment variable references such as `${env:DATABASE_URL}` instead.

VS Code prompts you to trust an MCP server the first time it starts. You can reset trust at any time with the **MCP: Reset Trust** command. On macOS and Linux you can sandbox a local stdio server with `sandboxEnabled: true` plus explicit filesystem and network allow-lists; sandboxed tool calls are auto-approved because they are constrained.

### The cost gotcha

This is the single most important thing to know about MCP:

> Every tool an enabled MCP server exposes adds its full JSON schema to the agent's prompt on **every** turn, whether the tool is called or not.

A 40-tool MCP server can add many kilobytes of schema to every request. Across a team, across a year, that is a meaningful baseline cost (see [Module 3](03-pick-the-right-model.md)). The defenses are simple:

- Enable only the servers you will use this session. Use the Configure Tools button in the chat input to toggle individual tools off.
- Prefer servers that support a `--toolset` flag to narrow the surface (for example `github-mcp --toolset=issues,pulls`).
- Set `tools` and `mcp-servers` lists on your custom agents so each persona only loads what it needs.
- If a capability is used in fewer than one in ten conversations, package it as a skill instead.

### MCP vs. skills

| Mechanism | Loaded on every turn | Rest loads when… |
|---|---|---|
| MCP server | Full schema for every tool the server exposes | Never — the schema is always present |
| Skill | Only `name` + `description` from frontmatter | The skill is invoked or auto-loaded by the model |

MCP wins when you need an interactive runtime tool (drive a browser, query a live database, call an API). A skill can document the procedure, but it cannot perform the call. A skill wins for recurring procedures with fixed steps and for portable, cross-tool capabilities.

### Security

An MCP server runs as a process with the same permissions as VS Code (or as a remote service you call). Treat MCP installs the same way you treat any other dependency:

- Read the source before installing community servers; pin versions.
- Prefer official servers for high-impact capabilities (the GitHub MCP, your cloud's CLI MCP).
- Scope credentials. Database MCPs should connect with read-only roles unless you specifically want the agent to write.
- Audit the kubeconfig, AWS profile, or Azure subscription your MCP server connects to *before* opening any chat — a stale context can point at the wrong environment.

### Demo — decide whether MCP is needed

For the demo project, MCP is intentionally not required for the core labs. Local code, tests, docs, and the synthetic alert evidence are enough. Use this prompt to make the decision explicit:

```text
For this demo project, decide whether MCP is needed to review API observability.

Use this evidence:
- app/main.py
- tests/test_main.py
- specs/api-health-observability.spec.md
- infra/bicep/main.bicep

If MCP is not needed, explain why.
If MCP would be useful later, list the exact read-only data and the actions that must stay forbidden.
Do not configure MCP.
```

Expected conclusion: MCP is not required for the local lab; a future read-only Azure Monitor connector could help with live alert history; write actions stay forbidden.

---

## Agent plugins (Preview)

So far we have authored each customization by hand — one agent file, one skill folder, one MCP entry. **Agent plugins** are a packaging format that bundles any combination of those things — slash commands, skills, agents, hooks, and MCP servers — into a single unit you can install, update, share, and disable as one.

Think of plugins as the distribution channel for the primitives you already know. A single plugin might ship a `test-runner` skill with scripts, a `test-reviewer` agent with read-only tools, a `PostToolUse` hook that formats edited files, and an MCP server for a test reporting dashboard — installed in one step from a marketplace.

Plugins are currently **Preview** in VS Code. Your organization may enable or disable the feature with `chat.plugins.enabled`. See the official [Agent plugins](https://code.visualstudio.com/docs/copilot/customization/agent-plugins) docs for the full reference.

### When to install a plugin

Reach for a plugin when:

- A community-maintained capability already exists for the workflow you need (a popular linter, a framework-specific test runner, a vendor's MCP server bundle).
- You want one install/uninstall step instead of five separate copy-paste actions.
- The capability needs to ship to many teammates with versioned updates.

Stay with hand-authored files when the customization is repo-specific, small, or sensitive to your team's conventions — most of what this module covers.

### What a plugin looks like

Every plugin has a `plugin.json` manifest at its root plus optional folders for skills, agents, hooks, and MCP server config:

```text
my-testing-plugin/
  plugin.json              # Plugin metadata and configuration
  skills/
    test-runner/
      SKILL.md
      run-tests.sh
  agents/
    test-reviewer.agent.md
  hooks.json               # Lifecycle hooks
  .mcp.json                # MCP server definitions
```

A minimal `plugin.json`:

```json
{
  "name": "my-dev-tools",
  "description": "React development utilities",
  "version": "1.2.0",
  "author": { "name": "Jane Doe" },
  "skills": "skills/",
  "agents": "agents/",
  "hooks": "hooks.json",
  "mcpServers": ".mcp.json"
}
```

Once installed, plugin-provided customizations appear alongside your locally defined ones — skills show up in the Configure Skills menu, agents in the agent picker, MCP servers in the MCP list.

### Discovering and installing plugins

VS Code ships with the dedicated **Agent Plugins** view in the Extensions sidebar. The most common entry points:

- Open the Extensions view and search `@agentPlugins` to browse marketplaces (the default ones are [`github/copilot-plugins`](https://github.com/github/copilot-plugins) and [`github/awesome-copilot`](https://github.com/github/awesome-copilot)).
- Run `Chat: Install Plugin From Source` and paste a Git URL to install directly from a repository.
- Add private marketplaces with the `chat.plugins.marketplaces` setting.
- Register a locally cloned plugin with the `chat.pluginLocations` setting.

The first install from a new marketplace prompts you to trust it. Plugins installed via the Copilot CLI under `~/.copilot/installed-plugins/` are auto-discovered by VS Code too, so a plugin can move between surfaces without reinstalling.

For team-wide defaults, add `enabledPlugins` and `extraKnownMarketplaces` to `.github/copilot/settings.json` (or `.claude/settings.json`). VS Code shows a one-time recommendation when a teammate first sends a chat message in the workspace.

### Safety

A plugin is a piece of software running on your machine. Hooks execute shell commands; MCP servers may start local processes; both run with the same permissions as VS Code.

- **Treat plugins like any other dependency.** Review the publisher, the marketplace, and — if practical — the source.
- **Plugin MCP servers are implicitly trusted** when you install the plugin; they do not show a separate trust prompt at startup. Workspace MCP servers do.
- **Disabling a plugin disables all of its components**, including hooks and MCP servers. Use this as your kill switch if a plugin misbehaves.
- **Prefer first-party or org-vetted plugins** when the plugin can write files, run terminal commands, or reach external systems.

For this workshop the demo project does **not** install any plugins. Plugins are mentioned here so you know the option exists and can evaluate community offerings deliberately rather than discovering them by accident.

For the full packaging walk-through — `plugin.json` layout, marketplaces (`chat.plugins.marketplaces`), Git-URL and local-path installs, awesome-copilot / anthropics/skills sources, and authoring discipline — see [Module 6 — Skills Portfolio, Packaging & Sharing](06-skills-and-plugins.md).

---

## Combining the three

The three primitives compose. A few patterns that work well together:

**Plan → Implement → Review.** Three custom agents with handoffs between them. The planner is read-only; the implementer can edit files; the reviewer is read-only again. Each handoff uses `send: false` so the user approves the transition.

**Custom agent + skill.** A `code-reviewer` agent (persona, read-only tools) invokes a `pr-security-review` skill (procedure, checklist). The same skill can be invoked by a human directly with `/pr-security-review` when no agent is in the loop.

**Custom agent + MCP.** A `db-explorer` agent has access to the Postgres MCP server with read-only credentials. The agent's tool list pins exactly which Postgres tools it may use, so the agent cannot accidentally call a destructive one even if the server exposes it.

**Skill + forked context.** A `dependency-audit` skill with `context: fork` does a long read across many files in a subagent and returns a single summary to the parent. The main conversation stays lean.

---

## Anti-patterns

| Anti-pattern | Symptom | Fix |
|---|---|---|
| **Customizing too early** | Agents and skills appear before native Copilot has proven the gap | Use Ask / Plan / Agent + prompt files first. Add a custom agent only when the team keeps wishing for a different tool list or persona. |
| **Custom agent ignored** | Selecting the agent makes no visible difference | Check that `tools` and `model` are actually different from the defaults; verify the file is in `.github/agents/` with valid YAML; right-click chat → Diagnostics. |
| **Custom agent with `tools: ['*']`** | No real difference from the default Agent | Spell out the actual tool list. Smaller surface = lower cost and better focus. |
| **Skill fails to load silently** | The skill never appears or never triggers | Folder name must match `name`; only lowercase + hyphens; ≤ 64 chars; no colons or slashes. |
| **Skill loads at the wrong time** | A skill hijacks unrelated requests | Tighten the `description` — be specific about *when* to use it. |
| **Twelve enabled MCP servers** | Slow first-turn responses; high baseline cost on every chat | Audit weekly. Disable anything you did not use. Convert occasional capabilities to skills. |
| **Hard-coded credentials in `mcp.json`** | Permanent leak in source control | Always use `${env:NAME}` references; secrets live in shell config or your secrets manager. |
| **MCP pointed at production write credentials** | The agent destroys data on a wrong tool call | Read-only roles by default; production write credentials need a separate "ops" agent profile and explicit per-session approval. |
| **Custom agent that duplicates a prompt file** | Two assets diverge over time | Pick one. Use a custom agent for *roles*; use a prompt file for *templates*. |
| **No refusal test** | Nobody actually verifies the agent stops unsafe actions | Maintain one prompt the agent must refuse. Run it whenever the agent or its tool list changes. |

---

## Summary

Custom agents, skills, and MCP are the heavier customizations you reach for once instructions, prompt files, and hooks are no longer enough. A custom agent defines a persistent role with its own tools and model. A skill packages a multi-step procedure that loads only when relevant — and works across Copilot, Claude, and Codex CLI. An MCP server connects Copilot to live external systems, with the trade-off that every enabled tool's schema is paid for on every turn.

Used together, and with a sober tool list and a refusal test, they turn Copilot into a predictable workshop tool instead of an open-ended automation risk. For the hands-on labs that walk through the demo agent and skill, see [Module 9](15-workshop-and-labs.md).

---

> **Next:** [Module 6 — Skills Portfolio, Packaging & Sharing](06-skills-and-plugins.md)
> **Back:** [Module 4 — Customize: Instructions, Prompt Files & Hooks](04-customize-instructions-prompts-and-hooks.md)
