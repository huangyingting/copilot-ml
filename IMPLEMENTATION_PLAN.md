# Implementation Plan — Publish `docs/` as GitHub Pages

## Current state

- `mkdocs.yml` already exists and is wired for Material, search, edit links, and the numbered `docs/` nav.
- `requirements-docs.txt` already pins the MkDocs toolchain.
- `docs/` already contains the full 00–15 curriculum plus `README.md` as the index.
- Missing piece: the GitHub Pages deployment workflow.

## Plan

1. **Confirm MkDocs inputs match the spec**
   - Check that `docs/README.md` is the site index.
   - Keep the nav in numeric order from `00` to `15`.
   - Preserve the current Material features and edit links.

2. **Add the Pages deployment workflow**
   - Create `.github/workflows/deploy-docs.yml`.
   - Use `pages: write`, `id-token: write`, and `contents: read`.
   - Build with `mkdocs build --strict`.
   - Publish with the official Pages action flow: `configure-pages` → `upload-pages-artifact` → `deploy-pages`.

3. **Wire safe triggers**
   - Run on `push` to `main` when `docs/**`, `mkdocs.yml`, `requirements-docs.txt`, or the workflow changes.
   - Add `workflow_dispatch` for manual publishing.

4. **Document the one-time Pages setup**
   - Note that repo Pages source must be set to **GitHub Actions** once by a maintainer.
   - Add the local preview command set: `pip install -r requirements-docs.txt`, `mkdocs serve`, and `mkdocs build --strict`.

5. **Verify the result**
   - Confirm the workflow file references the repo root and `docs/` correctly.
   - Confirm every module is reachable in nav order and the homepage points at `docs/README.md`.
   - Confirm the strict build is the gating check for publish.
