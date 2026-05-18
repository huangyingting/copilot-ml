# Spec Kit demo inputs

This folder contains stakeholder documents for a formal Spec Kit demo.

Suggested flow from the project root:

1. Initialize Spec Kit in a disposable branch or sandbox.
2. Copy `spec-kit/StakeholderDocuments/` into the Spec Kit workspace if needed.
3. Use the stakeholder files with `/speckit.constitution`, `/speckit.specify`, `/speckit.clarify`, `/speckit.plan`, and `/speckit.tasks`.
4. Review each artifact with `StakeholderDocuments/lab-scorecard.md`.

Demo prompt:

> Use the stakeholder documents in `spec-kit/StakeholderDocuments/` to create a formal Spec Kit package for copilot-ml. Keep the MVP minimal: FastAPI endpoints, tests, Docker, Azure Container Apps Bicep, Copilot prompts, one custom agent, one skill, one CLI workflow guide, and one Cloud Agent issue template. Do not include production auth, databases, customer data, or autonomous Azure deployment.
