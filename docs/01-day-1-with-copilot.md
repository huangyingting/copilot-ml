# Module 1 — Day 1 with Copilot

> **Goal:** by the end of this module, you can open the demo project, use Copilot safely in Ask Mode, and explain one file without editing or running risky commands.

All demos use:

`demo-projects/copilot-ml/`

---

## Chapter 1.0 — Day-1 scenario

Scenario:

> You have just opened a small FastAPI project that can be deployed to low-cost Azure Container Apps. Before asking Copilot to change anything, you want to understand the API, tests, and safety boundaries.

Primary files:

- `README.md`
- `app/main.py`
- `tests/test_main.py`
- `infra/bicep/main.bicep`
- `.github/copilot-instructions.md`
- `AGENTS.md`

### Demo — first safe question

Ask Copilot:

```text
Explain this demo project for a new developer.
Focus on the API endpoints, tests, Azure deployment shape, and safety rules.
Do not edit files or run commands.
```

Expected output:

- API endpoint summary.
- Local test command.
- Low-cost Azure posture.
- Explicit no-secrets/no-production-mutation boundary.

---

## Chapter 1.1 — What Copilot is

Copilot has two everyday surfaces:

- **Inline suggestions** — grey text while you type.
- **Chat** — Ask, Plan, and Agent conversations.

On Day 1, use Ask Mode. It is the safest way to learn the repo because it explains without editing.

In three sentences:

1. Copilot is a coding assistant that uses the current prompt, open files, repository context, instructions, and tools to propose useful next steps.
2. It is not a source of truth: it can miss repo conventions, invent behavior, or overreach if the task is vague.
3. The team remains responsible for scope, security, tests, review, deployment, and customer-visible outcomes.

For this demo, Copilot is useful on Day 1 for explanation, orientation, and safe rewrite of risky asks. It is not yet being trusted to deploy, refactor broadly, or make architecture decisions.

### Demo — explain one endpoint

Open `app/main.py` and ask:

```text
Explain the /readyz endpoint line by line.
What does it prove, and what does it intentionally not prove in this demo?
Do not edit files.
```

Expected result:

- Copilot explains readiness behavior.
- It notes demo dependencies are synthetic or intentionally not configured for production.

---

## Chapter 1.2 — First setup check

You need:

- VS Code with GitHub Copilot enabled.
- The `copilot-enablement` folder open.
- The demo project available locally.
- Python dependencies installed if you plan to run tests.
- A clean branch for lab work.
- No production credentials loaded into prompts or checked into files.
- A shared understanding that Azure deployment is manually approved, not chat-driven.

### Technical readiness checklist

Before the first hands-on session, confirm:

- [ ] You can locate `demo-projects/copilot-ml/`.
- [ ] You can open `app/main.py`, `tests/test_main.py`, and `infra/bicep/main.bicep`.
- [ ] You know the local proof command is `pytest` from the demo project root.
- [ ] You can explain that `/healthz` and `/readyz` are demo endpoints, not production SLO proof.
- [ ] You know which actions are forbidden in a Copilot session: secrets, production mutation, autonomous deployment, resource deletion, merge, and customer-visible publishing.

If one item is not true, stay in Ask Mode until it is resolved.

### Demo — verify local project shape

Ask Copilot:

```text
Inspect the current workspace and tell me whether copilot-ml has the files needed for local app review, tests, Azure deployment review, prompt files, a custom agent, and a skill.
Do not edit files.
```

Expected result: a file checklist with any missing items clearly called out.

---

## Chapter 1.3 — First local validation

Day 1 is still mostly read-only, but it is useful to know the local proof command.

Inline autocomplete can help with small local edits, but it is not the main teaching tool on Day 1. Use it for simple code completion only after you understand the file. If a suggestion changes behavior, treat it like any other code review: inspect it, test it, and reject it if it widens scope.

Recommended first 30 minutes:

1. Open `README.md` and identify the app purpose.
2. Open `app/main.py` and ask Copilot to explain the endpoints.
3. Open `tests/test_main.py` and ask which behaviors are covered.
4. Ask what `pytest` proves and what it does not prove.
5. Rewrite one unsafe request into a safe Ask Mode prompt.

### Demo — ask before running

Ask Copilot:

```text
What is the safest local command to validate this FastAPI demo?
Explain what it proves and what it does not prove.
Do not run it yet.
```

Expected result:

- `pytest` is the local proof command.
- It proves endpoint behavior covered by tests.
- It does not prove live Azure deployment.

If the environment is prepared, run tests manually or in a supervised Agent session later in Module 2.

---

## Chapter 1.4 — What not to ask on Day 1

Avoid these requests on Day 1:

- “Deploy this now.”
- “Delete resources if it fails.”
- “Add secrets to the workflow.”
- “Make this production-ready.”
- “Change everything needed.”

Rewrite them as safe questions:

- “Review deployment readiness.”
- “List manual deployment steps.”
- “Explain what secrets would be required, without creating them.”
- “Draft a plan; do not implement.”

### Demo — safe rewrite

Ask Copilot:

```text
Rewrite this unsafe request into a safe Day-1 Ask Mode prompt:
"Deploy this API to Azure now and clean up failed resources automatically."
```

Expected output: a read-only review prompt that asks for deployment prerequisites, risk, rollback, and manual checks.

### Wrong-choice examples

| Unsafe request | Why it is unsafe | Safer Day-1 request |
|---|---|---|
| “Make this production-ready.” | Scope is undefined and can trigger broad rewrites. | “List the gaps between this demo and production readiness.” |
| “Add secrets to the workflow.” | Secrets must not be pasted into chat or committed. | “Explain which secrets would be required and where a human should configure them.” |
| “Deploy and clean up failures.” | Deployment and deletion are live mutations. | “Review deployment prerequisites and cleanup steps for a human operator.” |
| “Fix all observability issues.” | “All” is unbounded and not testable. | “Draft a spec for one observability improvement with tests and rollback.” |

---

## Chapter 1.5 — Day-1 checklist

- [ ] You can open the demo project.
- [ ] You can ask Copilot to explain `app/main.py` without edits.
- [ ] You can identify the local test command.
- [ ] You can explain why Azure deployment is not automated in Day 1.
- [ ] You can rewrite an unsafe prompt into a safe Ask Mode prompt.

### Demo — self-check

Ask Copilot:

```text
Quiz me on the Day-1 checklist for this demo project. Ask five short questions and wait for my answers.
```

---

## Chapter 1.6 — Lab connection

Use [Lab 1 — Project orientation](09-workshop-and-labs.md#lab-1--project-orientation) in Module 9.

---

> **Next:** [Module 2 — The Three Modes](02-three-modes.md)
> **Back:** [Program Overview](00-program-overview.md)
