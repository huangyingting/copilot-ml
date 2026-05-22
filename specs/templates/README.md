# Spec templates

Copy a template, rename to `specs/<area>/<short-name>.spec.md`, and review **before** asking an agent to implement.

| Template | Use when | Typical size |
|---|---|---|
| [feature.spec.template.md](feature.spec.template.md) | Adding a new model, table, endpoint, pipeline, or behavior | S / M |
| [bugfix.spec.template.md](bugfix.spec.template.md) | Fixing a defect with a known or suspected root cause | XS / S |
| [refactor.spec.template.md](refactor.spec.template.md) | Restructuring code with **no** behavior change | S / M |

See [../../docs/09-roles-and-spec-sizing.md](../../docs/09-roles-and-spec-sizing.md) for who writes the spec, how big it should be, and when to graduate from a lightweight spec to a full [Spec Kit](https://github.com/github/spec-kit) `/speckit.*` flow.
