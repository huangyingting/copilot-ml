# Module 3 — Pick the Right Model and Keep Cost Predictable

> **Goal:** by the end of this module, you can choose an appropriate model tier for a task, control unnecessary context and tool usage, compare output quality against cost signals, and explain the choice to another developer.

All demos start from the existing v1 project in the repository root:

`copilot-ml/`

---

## Chapter 3.0 — The decision frame

The right model is not always the strongest model. It is the cheapest reliable path to a reviewed artifact.

Before selecting a model, classify the work across four dimensions:

| Dimension | Ask yourself | Lower-cost signal | Higher-capability signal |
|---|---|---|---|
| **Task difficulty** | Is this a known pattern or a genuinely ambiguous problem? | Summary, simple explanation, boilerplate, small test | Architecture trade-off, unclear bug, security boundary |
| **Blast radius** | What happens if the answer is wrong? | Comment, local docs, non-critical refactor | Deployment, auth, secrets, data, production workflow |
| **Context breadth** | How many files or systems must interact? | One file or one narrow route | Cross-file behavior, infra + app + CI interactions |
| **Verification path** | Can we prove the answer locally? | `pytest`, lint, diff review, small demo | Human judgment, design review, external service behavior |

Use this rule of thumb:

- **Start cheaper** when the task is narrow, repetitive, or easy to verify.
- **Use the default/balanced tier** for most planning, reviews, tests, and documentation.
- **Upgrade deliberately** when the model misses important interactions, the failure is ambiguous, or the change has high blast radius.
- **Downgrade again** after the hard decision is made. A premium model might design the plan; a cheaper model can often summarize test output or draft the PR comment.

Model choice is only one lever. A well-scoped prompt on a default model usually beats a vague prompt on a premium model.

---

## Chapter 3.1 — Model tiers, not model-name memorization

Model catalogs change. Use tiers and live Copilot model information instead of memorizing a static list of model names.

| Tier | Use for | Avoid for | Practical habit |
|---|---|---|---|
| **Fast/cheap** | Short explanations, summaries, boilerplate, repetitive edits, simple tests | Ambiguous debugging, architecture, high-risk changes | Use when you can verify quickly and retry cheaply. |
| **Balanced/default** | Most Ask, Plan, code review, test writing, documentation, small-to-medium implementation | Extremely hard reasoning if it fails repeatedly | Make this the team's normal starting point. |
| **Deep/premium** | Complex design, ambiguous failures, security boundaries, cross-file reasoning, high-impact review | Routine prompts, repeated summaries, simple edits | Reach for it with a written reason and a narrow context set. |
| **Auto/router** | When unsure, when model availability changes, or when a workshop participant has a different model list | Regulated tasks requiring a pinned approved model | Let Copilot choose, then inspect whether the result was good enough. |

### Model selection matrix

Use this table as the team's default. Override it when the task gives you a clear reason.

| Task type | Default tier | Upgrade when | Demo project example |
|---|---|---|---|
| Explain one file | Fast/cheap or balanced | Explanation is wrong or misses framework behavior | Explain `app/main.py`. |
| Add a small test | Balanced | Failure is subtle or crosses app and test behavior | Add one `/readyz` assertion. |
| Draft a spec | Balanced | Scope is ambiguous or high-impact | API observability spec. |
| Review deployment safety | Balanced or deep | Bicep, GitHub Actions, auth, and cost settings interact | Review `infra/bicep/main.bicep` + deploy workflow. |
| Design SDK/MCP boundary | Deep/premium | Tool authority, audit, and security are unclear | Safe app-embedded tools. |
| Summarize test output | Fast/cheap | Rarely needs upgrade | PR comment from `pytest`. |
| Explore a codebase read-only | Fast/cheap or balanced | Findings require cross-system judgment | Identify files involved in health checks. |
| Multi-file implementation | Balanced | Repeated failures or hidden coupling appear | Add readiness behavior plus tests. |

### Upgrade and downgrade signals

Upgrade when you see one of these patterns:

- The answer is confident but misses an important file, dependency, or safety boundary.
- The model loops on the same failed edit or tool call.
- The task requires comparing alternatives rather than applying a known pattern.
- A human reviewer would need a strong explanation of trade-offs, not just a diff.

Downgrade when the hard part is over:

- The plan is approved and only mechanical edits remain.
- You only need a concise summary, checklist, or PR description.
- Tests already prove behavior and the model is only formatting the result.
- The task is repetitive across many similar files.

### Demo — choose a tier

Ask Copilot:

```text
For each task, choose fast/cheap, balanced/default, deep/premium, or Auto:
1. Explain /healthz.
2. Add one test assertion.
3. Plan a new observability feature.
4. Review the full deployment workflow and safety boundary.
5. Draft a short PR comment from test output.
Use the demo project as context.
```

Expected result: simple explanation and PR comments use cheaper tiers; planning and deployment review use default or deeper models when justified.

---

## Chapter 3.2 — Where the model dial lives

Model choice can be set at several layers. The closer the setting is to the task, the safer it is for experimentation. The closer it is to the repository, the better it is for team consistency.

| Layer | Where it usually lives | Affects | Use it when |
|---|---|---|---|
| **Per-message** | Chat model picker | One request | Comparing models or trying a one-off upgrade. |
| **Prompt file** | `model:` frontmatter in a `.prompt.md` | Anyone running that prompt | A repeated prompt has a known good model tier. |
| **Custom agent** | `model:` frontmatter in a `.agent.md` | Anyone using that agent | A role needs consistent behavior, tools, and model choice. |
| **Workspace or user default** | VS Code / Copilot settings | Requests without an override | Personal preference or workshop baseline. |
| **Auto/router** | Model picker option | Copilot-selected model | The task is normal and no approved model is required. |

Prefer **repo assets** for team-critical defaults. A prompt file or custom agent documents intent in version control; a personal setting only changes one developer's machine.

### Reasoning effort

Some Copilot environments expose a reasoning-effort setting in addition to model choice. Treat it as a second dial, not as a replacement for good scoping.

| Effort | Use for | Avoid for |
|---|---|---|
| **Lower** | Summaries, classification, simple rewrites, boilerplate | Tasks where hidden coupling is likely. |
| **Medium** | Normal agent work, test generation, code review, docs | Extremely ambiguous architecture or security decisions. |
| **Higher** | Design trade-offs, deep debugging, security or deployment review | Routine edits and repeated summaries. |

Higher effort can improve reasoning, but it can also increase latency and cost. If the prompt includes too many unrelated files, higher effort simply reasons harder over noisy evidence. Scope first; increase effort second.

---

## Chapter 3.3 — GitHub AI Credits

GitHub Copilot usage-based billing is moving to **GitHub AI Credits**. One AI Credit represents `$0.01 USD` of usage, but the important team habit is not to memorize old price tables. Treat the live Copilot UI and GitHub billing reports as the source of truth because model catalogs, availability, and displayed rates can change.

AI Credits matter because they turn model choice, context size, tool usage, and output length into a shared team resource. A single expensive session is not automatically bad if it produces a reviewed design or fixes a hard deployment issue. A cheap session is not automatically good if it loops, edits the wrong file, or creates rework.

### Cost signals to understand

The stable mental model is simple:

- **Input context matters** — prompts, selected code, attached files, instructions, and tool results all become context.
- **Cached context may be cheaper than fresh context** — reusing a stable conversation can help when the prior context is still relevant.
- **Output matters** — long answers, tool-call arguments, repeated diffs, and looped retries all add cost.
- **Model choice matters** — lightweight models cost less than frontier or deep-reasoning models for comparable work.
- **Tools matter** — tool schemas and tool results are part of the conversation, so unused tools add cost and noise.

Do **not** rely on fixed formulas or old pricing examples in workshop material. The practical move is to compare live model information, keep prompts scoped, and inspect usage reports for outliers.

### What typically consumes AI Credits

Copilot Chat, Copilot CLI, Copilot cloud agent, Copilot Spaces, Spark, and third-party coding agents can consume AI Credits. Code completions and next edit suggestions are not billed in AI Credits for paid plans.

For this curriculum, the main cost surface is **Chat and Agent Mode**. Inline completions are still useful for fast local flow; use Chat and Agent Mode when the task needs explanation, planning, review, tool use, or cross-file implementation.

### How to check model AI-credit information

In VS Code:

1. Open Copilot Chat.
2. Open the model picker.
3. Choose **Manage Language Models**.
4. Review the available models and their displayed AI-credit cost or pricing details.
5. Pick a cheaper model for summaries and simple edits; reserve higher-cost models for architecture, security, deployment, or ambiguous debugging.

For billing review, GitHub usage reports include AI-credit fields that help compare historical usage and identify high-cost workflows. Use those reports to ask better questions:

- Which workflow is expensive: planning, implementation, review, or summarization?
- Did the cost spike because the model changed, the context grew, or the agent looped?
- Did a high-cost run produce a reviewed artifact, or only exploratory chatter?
- Can repeated work become a prompt file, custom agent, or skill?

### Concrete comparison

Two prompts can ask for the same deployment-readiness review but create very different cost and quality profiles.

| Run | Prompt shape | Likely behavior | Cost signal |
|---|---|---|---|
| Broad review | “Review this project for deployment readiness. Be thorough.” | Reads or discusses unrelated areas, produces a long mixed report, harder to verify | Higher: broad input, broad output, more chances to wander. |
| Scoped review | Names exact files, risk area, output count, and no-edit boundary | Focuses on deployment cost, secrets, rollback, and approval risks | Lower: narrow evidence, constrained output, easier review. |

A scoped review controls cost and quality by giving the model only the evidence it needs, naming the risk area, and constraining the answer. For this demo, use the deployment files that matter and ask for a fixed number of findings instead of a broad repository review.

### Demo — scope and constrain output

Compare a broad prompt with a scoped, structured prompt:

```text
Review this project for deployment readiness. Be thorough.
```

Then ask:

```text
Review low-cost Azure Container Apps deployment readiness using only these files:
- infra/bicep/main.bicep
- .github/workflows/deploy-aca.yml
- README.md

Return exactly five findings. For each finding include:
- risk
- evidence
- impact
- human verification step

Do not edit files.
```

Expected observation: the scoped prompt should focus on deployment cost, secrets, rollback, and approval risks instead of general cleanup. If the model mentions files outside the scope, ask it to revise using only the listed evidence.

---

## Chapter 3.4 — Context discipline

Context is evidence, not decoration. More context can help when the task truly spans many files, but it also increases cost and gives the model more ways to chase irrelevant details.

Use three buckets before sending a non-trivial prompt:

| Bucket | Meaning | Example |
|---|---|---|
| **Evidence** | Files the model must inspect to answer correctly | `app/main.py`, `tests/test_main.py` for API health behavior. |
| **Background** | Files that explain intent but are not direct proof | A spec or README section. |
| **Noise** | Files likely to distract from the requested decision | Infra files when the task is only route behavior. |

Attach evidence first. Add background only when the answer lacks intent. Leave noise out.

### Demo — build a context set before asking

Scenario: explain and test the API health behavior without reviewing deployment infrastructure.

Attach only:

- `app/main.py`
- `tests/test_main.py`

Do not attach:

- `infra/`
- `.github/workflows/`
- workshop docs

Prompt:

```text
Explain the current health and readiness behavior in this FastAPI app.
Identify up to three missing test assertions that would improve confidence.
Do not edit files.
```

Expected result: the answer should focus on route behavior, response models, and tests. If the model discusses Azure deployment, GitHub Actions, or workshop content, the context set is too broad or the prompt is under-constrained.

---

## Chapter 3.5 — Tool discipline and loop control

Agent workflows can become expensive when they repeatedly call tools, read irrelevant files, or retry the same failed operation. The fix is not “never use tools”; the fix is to use the minimum useful toolset and stop bad loops early.

### Tool discipline

- **Disable unused tools for the session** when your environment allows it. Tool descriptions and schemas can become context even when the tool is not used.
- **Prefer deterministic local proof** for behavior. A passing `pytest` run is stronger than a long model explanation of why tests should pass.
- **Use read-only tools for review tasks.** Do not let a model edit files when the expected artifact is a risk table or recommendation.
- **Compose deterministic setup outside the agent loop** when possible. For example, collect test output once, then ask Copilot to summarize it, instead of asking the agent to rediscover the same command repeatedly.

### Loop control

Stop and re-scope when you see these signals:

- The agent makes the same failed edit twice.
- The agent reads broad directories without explaining why.
- The answer grows longer but not more specific.
- The model ignores the no-edit boundary.
- The model asks for more context without naming exactly which file or fact is missing.

Two failed attempts usually mean the task needs a better prompt, smaller context, or a plan step before implementation. Canceling a wandering agent is a cost-control feature, not a failure.

---

## Chapter 3.6 — Model comparison demo

Use a read-only task. Do not create two competing implementations.

Scenario:

> Run the same read-only review prompt against the existing v1 demo project with two available models, then compare quality, verbosity, safety awareness, and cost signals.

Prompt:

```text
Review infra/bicep/main.bicep for low-cost Azure Container Apps posture.
Include cost settings, deployment risks, rollback notes, and what a human must verify.
Do not edit files.
```

Run the same prompt with two models available in your environment. Keep the context, output request, and no-edit boundary identical so the comparison is fair.

Expected artifact:

| Model or tier | Quality score | Verbosity | Safety notes | Cost signal | Recommendation |
|---|---:|---|---|---|---|
| Model A | 1–5 | Too short / useful / too long | What it caught or missed | Lower / medium / higher | Use / avoid / use for this task only |
| Model B | 1–5 | Too short / useful / too long | What it caught or missed | Lower / medium / higher | Use / avoid / use for this task only |

Evaluate the answer, not the brand. A cheaper model that catches the important `minReplicas: 0`, `maxReplicas: 1`, identity, secrets, and human-approval risks may be the better workshop default than a premium model that writes a beautiful but vague essay.

---

## Chapter 3.7 — Budgeting and governance

For pilot use, track cost at the workflow level, not only at the model level. The question is not “Which model is cheapest?” The better question is “Which workflow creates useful reviewed artifacts at predictable cost?”

Useful pilot metrics:

- Cost per useful spec.
- Cost per accepted PR comment.
- Cost per successful Agent Mode implementation.
- Cost per Copilot cloud-agent PR that survives review.
- Cost outliers caused by broad context, tool loops, or overly verbose outputs.
- Rework rate after using a cheaper model versus a deeper model.

Governance habits for a team:

- Use GitHub billing and usage reports to find outlier workflows.
- Set budgets and alerts at the level your organization supports.
- Decide whether overflow usage is allowed or blocked before a workshop or pilot begins.
- Keep high-cost models available for genuinely hard tasks, but require a reason for routine use.
- Review prompt files, custom agents, and skills when model availability changes.
- Avoid pinning retiring or experimental models in shared repo assets unless the team has approved that choice.

If the team changes its default model, retune high-traffic prompts and instructions. Different model families can vary in verbosity, tool eagerness, and planning style. Keep behavior stable by testing the same prompt against the same task before updating shared defaults.

---

## Chapter 3.8 — Cost-control checklist

Use this before every non-trivial Copilot session.

### Per session

- [ ] Is this Ask, Plan, or Agent?
- [ ] Can a cheaper model handle it?
- [ ] If reasoning effort is available, is the effort level appropriate?
- [ ] Did I attach only necessary evidence files?
- [ ] Is the requested output concise and structured?
- [ ] Are tools restricted to what the task needs?
- [ ] Is the task read-only unless implementation is approved?
- [ ] Do I have a deterministic proof path such as tests, lint, or a small diff review?
- [ ] Did I stop loops early instead of paying for repeated failure?

### Per repo

- [ ] Are repeated prompts promoted to `.prompt.md` files?
- [ ] Are repeated role behaviors promoted to `.agent.md` files?
- [ ] Are multi-step procedures promoted to `SKILL.md` when appropriate?
- [ ] Are always-on instructions concise enough to avoid unnecessary baseline context?
- [ ] Are shared prompt or agent files using current, approved model choices?

### Per pilot or team

- [ ] Are usage reports reviewed for outliers?
- [ ] Are model defaults documented and revisited when the model catalog changes?
- [ ] Are budget alerts configured where the organization supports them?
- [ ] Are high-cost sessions tied to high-value artifacts?
- [ ] Are workshop participants taught to scope context before upgrading models?

### Demo — cost review of a prompt

Ask Copilot:

```text
Review this prompt for cost discipline:
"Read the entire repo and tell me everything wrong with it."
Rewrite it for copilot-ml so it is scoped, cheaper, and safer.
```

Expected result: narrowed files, explicit output shape, and no edits.

---

## Chapter 3.9 — Lab connection

Use [Lab 9 — Model and cost comparison](09-workshop-and-labs.md#lab-9--model-and-cost-comparison) in Module 9.

---

> **Next:** [Module 4 — Customize Copilot: Instructions, Prompt Files & Hooks](04-customize-instructions-prompts-and-hooks.md)
> **Back:** [Module 2 — The Three Modes](02-three-modes.md)
