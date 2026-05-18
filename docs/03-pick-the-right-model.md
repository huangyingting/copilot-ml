# Module 3 — Pick the Right Model and Keep Cost Predictable

> **Goal:** by the end of this module, you can choose an appropriate model for a task, reduce wasted context, and compare output quality against cost signals.

All demos use:

`demo-projects/copilot-ml/`

---

## Chapter 3.0 — Model choice scenario

Scenario:

> Run the same review prompt against the demo project with two available models, then compare quality, verbosity, safety awareness, and estimated cost.

Use a read-only task. Do not create two competing implementations.

### Demo — model comparison setup

Prompt:

```text
Review infra/bicep/main.bicep for low-cost Azure Container Apps posture.
Include cost settings, deployment risks, rollback notes, and what a human must verify.
Do not edit files.
```

Run the same prompt with two models available in your environment.

Expected artifact: a comparison table with model, quality score, verbosity, safety notes, and recommendation.

---

## Chapter 3.1 — Model tiers

Use model tiers rather than memorizing model names.

| Tier | Use for | Avoid for |
|---|---|---|
| Fast/cheap | Short explanations, boilerplate, simple tests, summaries | Hard architecture or ambiguous debugging |
| Balanced/default | Most planning, code review, test writing, documentation | Extremely hard reasoning if it fails repeatedly |
| Deep/premium | Complex design, ambiguous failures, cross-file reasoning | Routine prompts, repeated summaries, simple edits |
| Auto/router | When unsure | Regulated tasks requiring a pinned approved model |

### Model selection matrix

| Task type | Default tier | Upgrade when | Demo project example |
|---|---|---|---|
| Explain one file | Fast/cheap or balanced | Explanation is wrong or misses framework behavior | Explain `app/main.py`. |
| Add a small test | Balanced | Failure is subtle or cross-file | Add one `/readyz` assertion. |
| Draft a spec | Balanced | Scope is ambiguous or high-impact | API observability spec. |
| Review deployment safety | Balanced or deep | Multiple infra/workflow files interact | Bicep + GitHub Actions review. |
| Design SDK/MCP boundary | Deep/premium | Tool authority, audit, and security are unclear | Safe app-embedded tools. |
| Summarize test output | Fast/cheap | Rarely needs upgrade | PR comment from `pytest`. |

If your Copilot environment exposes a reasoning-effort setting, use lower effort for summaries and boilerplate, medium for normal agent work, and higher effort for design or security-boundary decisions. Higher effort is not a substitute for scoped context.

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

Expected result: simple explanation and PR comments use cheaper tiers; planning/review uses default or deeper models when needed.

---

## Chapter 3.2 — Effective Tokens

Cost is driven by model tier, input context, cached context, and output length.

Tokens are pieces of text. Prompts, file context, tool output, instructions, and model responses all consume tokens. In practice, the team can control cost by controlling four things:

- **Model multiplier** — heavier models cost more per token.
- **Input size** — broad context, verbose instructions, and noisy tool output increase cost.
- **Cache reuse** — stable repeated context may be cheaper than new context.
- **Output size** — long answers are expensive and often harder to review.

Use this simplified formula:

$$
\text{ET} = m \times (1.0 \cdot I + 0.1 \cdot C + 4.0 \cdot O)
$$

Where:

- $m$ = model multiplier or relative tier cost.
- $I$ = new input tokens.
- $C$ = cached context tokens.
- $O$ = output tokens.

Output is expensive. Long essays and repeated verbose summaries add cost quickly.

### Concrete example

Suppose two reviews both inspect deployment readiness:

| Run | Model multiplier | New input | Cached context | Output | Effective Tokens intuition |
|---|---:|---:|---:|---:|---|
| Broad review | 2.0 | 20,000 | 0 | 2,000 | Expensive: large context and long answer. |
| Scoped review | 1.0 | 4,000 | 2,000 | 600 | Cheaper: narrow files and concise output. |

The scoped review is usually better for this demo because it attaches only `infra/bicep/main.bicep`, `.github/workflows/deploy-aca.yml`, and `README.md`, then asks for five structured findings.

### Demo — reduce output cost

Ask twice:

```text
Review this project for deployment readiness. Be thorough.
```

Then:

```text
Review this project for deployment readiness.
Return exactly five bullets: risk, evidence, impact, verification, owner.
Do not edit files.
```

Expected observation: the second prompt is cheaper to review and usually cheaper to generate.

---

## Chapter 3.3 — Context discipline

More context is not always better. Give the model the few files that matter.

### Demo — compare broad vs. narrow context

Run the same review twice:

1. Broad context: entire project or many folders.
2. Narrow context:
   - `infra/bicep/main.bicep`
   - `.github/workflows/deploy-aca.yml`
   - `README.md`

Prompt:

```text
Review low-cost Azure deployment readiness.
Focus on cost settings, secrets, rollback, and human approval.
Do not edit files.
```

Expected result: narrow context usually produces a sharper, shorter answer.

---

## Chapter 3.4 — Cost-control checklist

Use this before every non-trivial agent session:

- [ ] Is this Ask, Plan, or Agent?
- [ ] Can a cheaper model handle it?
- [ ] Did I attach only necessary files?
- [ ] Is the requested output concise?
- [ ] Are tools restricted to what the task needs?
- [ ] Is the task read-only unless implementation is approved?
- [ ] Did I stop loops early?
- [ ] Did I capture reusable prompts or rules after the task?

### Token-optimization tactics

Ranked by practical impact for this curriculum:

1. **Prune unused context.** Attach the few files needed for the task.
2. **Prefer deterministic local proof.** Use `pytest` for behavior proof instead of asking the model to infer everything.
3. **Pick the right tier.** Do not use a premium model for short summaries or boilerplate.
4. **Stop runaway loops.** Two failed attempts usually means the task needs a better spec or plan.
5. **Promote repeated work.** Turn repeated prompts into `.prompt.md`, role behavior into `.agent.md`, and procedures into `SKILL.md`.
6. **Keep instructions terse.** Always-on instructions are appended often; compress stable rules.
7. **Shape output.** Ask for tables, five bullets, or PR-ready comments instead of broad essays.

### Budgeting and governance

For pilot use, track cost at the workflow level, not only at the model level:

- Cost per useful spec.
- Cost per accepted PR comment.
- Cost per successful Agent Mode implementation.
- Cost per Cloud Agent PR that survives review.
- Cost outliers caused by loops, broad context, or overly verbose outputs.

The goal is not always the cheapest model. The goal is the cheapest reliable path to a reviewed artifact.

### Demo — cost review of a prompt

Ask Copilot:

```text
Review this prompt for cost discipline:
"Read the entire repo and tell me everything wrong with it."
Rewrite it for copilot-ml so it is scoped, cheaper, and safer.
```

Expected result: narrowed files, explicit output shape, and no edits.

---

## Chapter 3.5 — Lab connection

Use [Lab 9 — Model and cost comparison](09-workshop-and-labs.md#lab-9--model-and-cost-comparison) in Module 9.

---

> **Next:** [Module 4 — Spec-Driven Development](04-spec-driven-development.md)
> **Back:** [Module 2 — The Three Modes](02-three-modes.md)
