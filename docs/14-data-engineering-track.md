# Module 14 — Data Engineering Track

The original curriculum (Modules 00 – 10) uses a FastAPI service on Azure Container Apps as the demo project. That stack is great for showing Copilot patterns, but the audience for this delivery is **data engineers**. This track maps every concept onto the work a DE actually does: SQL, dbt, PySpark, notebooks, Airflow, warehouses, and data-quality tests.

You do **not** need to throw the API demo away. Keep it as the "infrastructure-of-record" example for safety and deployment review, and add the DE artifacts in this track on top.

## 1. Audience and assumed environment

| Assumption | Default for this track |
|---|---|
| Primary IDE | VS Code with GitHub Copilot |
| Primary stack | dbt (any adapter) **or** PySpark on Databricks **or** Airflow + warehouse SQL |
| Test framework | dbt tests + Great Expectations **or** `pytest` for PySpark / Python-only jobs |
| Warehouse | Snowflake / BigQuery / Databricks / Redshift / Synapse — pick one for labs |
| Orchestrator | Airflow / Dagster / Databricks Workflows / dbt Cloud |
| Git host | GitHub (for Cloud Agent, Actions, OIDC to cloud) |

If a learner's stack differs, the patterns still apply — substitute their warehouse / orchestrator name in the prompts.

## 2. Stack swap — what changes from the FastAPI demo

| FastAPI demo concept | DE equivalent used in this track |
|---|---|
| `app/main.py` endpoint | dbt model `models/marts/<name>.sql` or PySpark job `jobs/<name>.py` |
| `app/models.py` Pydantic | dbt `schema.yml` columns + tests, or PySpark `StructType` |
| `/healthz`, `/readyz` | Pipeline freshness check, dbt source freshness, DAG SLA |
| `pytest tests/test_main.py` | `dbt build` (compile, run, test) **or** `pytest tests/` for PySpark |
| Dockerfile | Spark image / dbt image / Airflow image |
| Bicep + ACA | Terraform or Bicep for warehouse, Databricks workspace, Airflow env |
| Deploy workflow (`.github/workflows/deploy-aca.yml`) | dbt build & test workflow, PySpark CI workflow, Airflow DAG sync workflow |
| Synthetic API alert | Synthetic data-quality alert (row count drop, schema drift, freshness miss) |

## 3. Safety boundaries — DE edition

Copy this into `.github/copilot-instructions.md` (or `AGENTS.md`) for any DE project. These mirror the API-demo boundaries but in DE terms.

```markdown
## Data engineering safety boundaries

- Never run destructive DML against any environment without explicit human approval:
  no `DROP TABLE`, `TRUNCATE`, `DELETE` without a `WHERE`, `DROP SCHEMA`, or
  full-refresh against a prod model.
- Never connect Copilot or an agent to production warehouse credentials.
  Use a dev or sandbox warehouse with a small, masked dataset.
- Never include real PII in tests, prompts, fixtures, examples, or generated docs.
  Always use synthetic data.
- Never alter `dbt_project.yml`, `profiles.yml`, or warehouse role/grant files
  without a reviewed spec.
- Never set `materialized: table` or `full-refresh` on a multi-billion-row model
  without an explicit cost rationale.
- Never raise warehouse size or cluster size beyond the lab default.
- Never `git push --force` to shared branches; the agent must propose, not push.
- Mask any column whose name matches `email|phone|ssn|dob|name|address|ip` in
  generated samples and logs.
```

Why each one matters:

- **Destructive DML.** A single bad `DELETE` against a fact table can wipe months of data. Agents will happily run SQL — gate this on humans.
- **Prod credentials.** The single biggest blast radius lever a DE has. Keep agents on dev or sandbox warehouses.
- **PII in prompts.** Prompts are logged. Treat them as you treat application logs.
- **Cost.** A misconfigured `materialized: table` on a wide source can run for hours. Lab defaults exist for a reason.

## 4. Lab re-skin — DE versions of the existing labs

Pair each existing lab from [15-workshop-and-labs.md](15-workshop-and-labs.md) with a DE equivalent. The Copilot pattern is identical; only the artifact changes.

| Original lab | DE lab equivalent | DE artifact |
|---|---|---|
| Lab 1: Day-1 with Copilot in the API | Day-1 with Copilot in a dbt project | Add a `not_null` test to one column |
| Lab 2: Add `/readyz` dependency assertion | Add a `dbt source freshness` check | `sources.yml` change + freshness test |
| Lab 3: Draft a spec for a small API feature | Draft a spec for a new mart model | `specs/de/feature-mart-<name>.spec.md` (use [feature template](../specs/templates/feature.spec.template.md)) |
| Lab 4: Customize instructions / prompts | Add DE safety boundaries + DE prompt files | Updated `copilot-instructions.md`, `draft-dbt-model.prompt.md` |
| Lab 5: Custom agent / skill / MCP | Add `data-pipeline-reviewer` agent + DE skills | Files under `.github/agents/` and `.github/skills/` |
| Lab 6: Spec-Driven Development | Run Spec Kit on a multi-model refactor | `.specify/specs/NNN-<name>/{spec,plan,tasks}.md` |
| Lab 7: Copilot CLI on the API | Copilot CLI for ad-hoc warehouse work | Generate / explain a window function, refactor a long CTE |
| Lab 8: Cloud Agent issue | Cloud Agent issue for a dq-test backfill | Issue from `.github/ISSUE_TEMPLATE/cloud-agent-de-task.yml` |
| Lab 13: Report-only workflow review | Daily dbt-test summary workflow review | Report-only Action that posts an issue / Slack message |

## 5. Pilot task examples for the DE pilot

These are small, well-scoped tasks suitable for a 1- to 2-day pilot per DE. Each task lists the Copilot surface to use, the artifact to produce, and the size.

### 5.1 Late-arriving data handling (S)

- **Problem.** `fct_orders` joins `dim_customer` on `customer_id`. ~0.2% of orders arrive before the customer dim row.
- **Spec.** [specs/de/feature-late-arriving-customers.spec.md](../specs/de/feature-late-arriving-customers.spec.md)
- **Copilot surface.** Plan Mode → Agent Mode. One PR.
- **Artifact.** Patched model + new `not_null_after_join` test.

### 5.2 Null-email bugfix in `dim_customer` (XS)

- **Problem.** `dim_customer.email` is null for ~3% of rows, breaking a downstream notification job.
- **Spec.** [specs/de/bugfix-dim-customer-email-null.spec.md](../specs/de/bugfix-dim-customer-email-null.spec.md)
- **Copilot surface.** Inline chat or Ask Mode, no full spec needed.
- **Artifact.** Source-system patch SQL + dbt test for the null-rate SLO.

### 5.3 Refactor 4,000-line ingestion notebook (M)

- **Problem.** One notebook does ingest, clean, model, and publish. Hard to test, slow to onboard.
- **Spec.** [specs/de/refactor-notebook-to-job.spec.md](../specs/de/refactor-notebook-to-job.spec.md)
- **Copilot surface.** Spec Kit `/speckit.specify → plan → tasks → implement` with sub-agent fan-out per cell group.
- **Artifact.** Notebook split into 3 Python modules + 1 thin notebook + parity tests.

### 5.4 DQ SLO + freshness alert (S)

- **Problem.** No alert when a critical dbt source is more than 6 hours stale.
- **Copilot surface.** Plan Mode → Agent Mode.
- **Artifact.** `sources.yml` freshness block + report-only GitHub Action that opens an issue.

### 5.5 SQL cost cleanup of warehouse top-10 (M)

- **Problem.** Top-10 most expensive queries from last week's warehouse spend report.
- **Copilot surface.** Custom agent `data-pipeline-reviewer` with `sql-cost-review` skill, one sub-agent per query.
- **Artifact.** Review comments with proposed rewrites; merge the safe ones, spec the rest.

## 6. Model picks for DE work

Lean on the matrix in [03-pick-the-right-model.md](03-pick-the-right-model.md). DE-specific tilts:

- **SQL explanation / rewrite.** Mid-tier models are usually enough. Don't burn a premium model on `EXPLAIN`-style work.
- **Long-context refactors (4k-line notebook).** Use a long-context model (Claude Sonnet 4.6, GPT-5-class).
- **dbt model design + test design.** Premium reasoning model is worth it. The blast radius is high.
- **PySpark logic optimization.** Premium reasoning. Spark perf bugs are subtle.
- **Code-style cleanups / `f-string` conversions.** Smallest fast model.

## 7. DE artifacts shipped in this repo

| Artifact | Path |
|---|---|
| Feature spec example | [specs/de/feature-late-arriving-customers.spec.md](../specs/de/feature-late-arriving-customers.spec.md) |
| Bugfix spec example | [specs/de/bugfix-dim-customer-email-null.spec.md](../specs/de/bugfix-dim-customer-email-null.spec.md) |
| Refactor spec example | [specs/de/refactor-notebook-to-job.spec.md](../specs/de/refactor-notebook-to-job.spec.md) |
| DE custom agent | [.github/agents/data-pipeline-reviewer.agent.md](../.github/agents/data-pipeline-reviewer.agent.md) |
| Draft-dbt-model prompt | [.github/prompts/draft-dbt-model.prompt.md](../.github/prompts/draft-dbt-model.prompt.md) |
| Review SQL performance prompt | [.github/prompts/review-sql-performance.prompt.md](../.github/prompts/review-sql-performance.prompt.md) |
| Write DQ suite prompt | [.github/prompts/write-dq-suite.prompt.md](../.github/prompts/write-dq-suite.prompt.md) |
| `sql-cost-review` skill | [.github/skills/sql-cost-review/SKILL.md](../.github/skills/sql-cost-review/SKILL.md) |
| `dq-test-review` skill | [.github/skills/dq-test-review/SKILL.md](../.github/skills/dq-test-review/SKILL.md) |

## 8. See also

- [02-three-modes.md](02-three-modes.md) — Ask / Plan / Agent, unchanged for DE
- [08-spec-driven-development.md](08-spec-driven-development.md) — lightweight SDD + Spec Kit
- [16-pilot-and-playbook.md](16-pilot-and-playbook.md) — pilot KPIs and rollout
- [09-roles-and-spec-sizing.md](09-roles-and-spec-sizing.md) — who writes the spec, how big

---

> **Next:** [Module 15 — Hands-on Labs with copilot-ml](15-workshop-and-labs.md)
> **Back:** [Module 13 — GitHub Cloud Agent & Report-only Agentic Workflows](13-github-cloud-agent.md)
