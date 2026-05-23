# Spec — Publish `docs/` curriculum as GitHub Pages

| | |
|---|---|
| **Spec ID** | `infra-spec-002` |
| **Status** | draft |
| **Author** | repo maintainer |
| **Reviewer(s)** | tech lead |
| **Created** | 2026-05-24 |
| **Last updated** | 2026-05-24 |
| **Related issue / PR** | — |
| **Spec size** | S |

## 1. Goal

Publish the 17-module curriculum in [docs/](../docs/) as a navigable GitHub Pages site so learners can read it in a browser with search, ordered navigation, and code highlighting, without changing the source Markdown files.

## 2. Background / context

Today the curriculum lives only as raw Markdown rendered by GitHub's file viewer. The numbered files (`00-…` through `16-…`) imply an order that GitHub's blob view does not surface as navigation, and there is no cross-document search. A static site solves both without forcing learners to clone the repo.

## 3. Users and stakeholders

- Primary user: workshop learners and self-serve readers — gain a browsable site with left-rail nav and search.
- Reviewer: repo maintainer / tech lead.
- Operator / on-call: none — site is fully static, served by GitHub Pages.

## 4. In scope

- Add `mkdocs.yml` at repo root configuring **MkDocs Material** with `docs_dir: docs`.
- Add `requirements-docs.txt` pinning `mkdocs`, `mkdocs-material`, and the small set of plugins we use.
- Add `.github/workflows/deploy-docs.yml` that builds the site and deploys to GitHub Pages via the official `actions/deploy-pages` flow (no `gh-pages` branch needed).
- Trigger workflow on pushes to `main` that touch `docs/**`, `mkdocs.yml`, `requirements-docs.txt`, or the workflow itself, plus `workflow_dispatch`.
- Configure the nav from the existing numeric file ordering (auto-ordered; no renames).
- Enable: instant search, code highlighting, dark/light toggle, copy-to-clipboard, "edit this page" link back to the source file on GitHub.

## 5. Out of scope

- Renaming or restructuring any file under `docs/`.
- Custom domain / DNS / `CNAME` (use the default `*.github.io` URL).
- Versioned docs (`mike`) — single `latest` only.
- Translating or rewriting curriculum content.
- Publishing anything outside `docs/` (no `specs/`, no `README.md`, no `logs/`).
- Changing the existing `deploy-aca.yml` workflow or any Azure resource.

## 6. Design sketch

- **Tooling:** MkDocs 1.6+ with the Material theme. Build is pure Python, runs in CI on `ubuntu-latest` with Python 3.12.
- **Source:** `docs/` directory, unchanged. `docs/README.md` becomes the site index via MkDocs' default behavior (or an explicit `index.md` alias declared in `nav`).
- **Nav:** declared explicitly in `mkdocs.yml` in module order so the left rail reads "00 Prerequisites → 16 Pilot Playbook" regardless of file-system sort quirks.
- **Build:** `mkdocs build --strict` so broken internal links fail CI.
- **Deploy:** `actions/configure-pages` → `actions/upload-pages-artifact` → `actions/deploy-pages`. Pages source must be set to **GitHub Actions** in repo settings (one-time, documented in spec §11).
- **Permissions:** workflow uses `pages: write`, `id-token: write`, `contents: read`. No secrets required.
- **Concurrency:** `group: pages, cancel-in-progress: false` so a queued deploy is not cancelled mid-publish.
- **Failure mode:** if build fails, no deploy happens; the previous published site is untouched.

## 7. Acceptance criteria

- [ ] `mkdocs build --strict` succeeds locally from a clean clone after `pip install -r requirements-docs.txt`.
- [ ] Workflow run on `main` publishes to `https://<owner>.github.io/copilot-ml/` and the homepage shows the curriculum index.
- [ ] All 17 modules are reachable from the left-rail nav in numeric order.
- [ ] In-site search returns results for a known term (e.g. "Plan Mode").
- [ ] Each page shows an "edit this page" link pointing at the correct file in `main`.
- [ ] No file under `docs/` was renamed or rewritten as part of this change.

## 8. Verification

- Local: `pip install -r requirements-docs.txt && mkdocs serve` → open `http://127.0.0.1:8000`.
- Local strict build: `mkdocs build --strict` (catches broken relative links between modules).
- CI: workflow `Deploy docs to GitHub Pages` green on `main`.
- Manual check: load the published URL, click through `00 → 16`, run a search, follow one "edit this page" link.

## 9. Operational impact and cost

- Compute: one `ubuntu-latest` job per docs-touching push, ~1–2 min.
- Storage: a single Pages artifact (~few MB).
- Cost: **$0** on public repos (GitHub Pages + Actions free tier).
- Runbook impact: none — static site, no alerts, no on-call surface.
- No Azure resources touched; this is independent of the ACA deployment.

## 10. Rollback

In repo **Settings → Pages**, switch the source from **GitHub Actions** back to **None** (or delete the workflow file). The published site stops updating immediately; the last build remains until Pages source is fully disabled. No data loss — source Markdown is untouched.

## 11. Open questions

- Confirm repo **Settings → Pages → Build and deployment → Source = GitHub Actions** is enabled by a maintainer once after merge. (One-time, cannot be set from the workflow itself.)
