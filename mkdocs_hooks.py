"""MkDocs hook: rewrite repo-relative links that escape the docs/ tree.

The curriculum links to files outside docs/ (specs/, .github/, root README).
Those work on GitHub's blob view but 404 on the published Pages site, so we
rewrite them to absolute github.com URLs at build time without touching the
source Markdown.
"""

from __future__ import annotations

import posixpath
import re

REPO_BLOB_BASE = "https://github.com/huangyingting/copilot-ml/blob/main"
REPO_TREE_BASE = "https://github.com/huangyingting/copilot-ml/tree/main"

# Match Markdown links of the form [text](path) where path starts with ../
# and is not already an absolute URL or anchor. Captures the path (group 1)
# and any optional title (group 2).
_LINK_RE = re.compile(r"\]\((\.\./[^)\s]+?)(\s+\"[^\"]*\")?\)")


def _rewrite(match: re.Match[str], page_src_uri: str) -> str:
    raw_path = match.group(1)
    title = match.group(2) or ""

    # Split anchor / query so we only resolve the file portion.
    path, sep, suffix = raw_path.partition("#")
    if not sep:
        path, sep, suffix = raw_path.partition("?")

    # Resolve the path relative to the page's location inside docs/.
    page_dir = posixpath.dirname(page_src_uri)
    resolved = posixpath.normpath(posixpath.join(page_dir, path))

    # Anything still inside docs/ is left alone — MkDocs will resolve it.
    if not resolved.startswith("../"):
        return match.group(0)

    # Strip the leading "../" segments so the URL is rooted at the repo.
    repo_path = resolved.lstrip("./")
    base = REPO_TREE_BASE if repo_path.endswith("/") or path.endswith("/") else REPO_BLOB_BASE
    rebuilt = f"{base}/{repo_path}{sep}{suffix}" if sep else f"{base}/{repo_path}"
    return f"]({rebuilt}{title})"


def on_page_markdown(markdown: str, *, page, config, files) -> str:  # noqa: ARG001
    src_uri = page.file.src_uri
    return _LINK_RE.sub(lambda m: _rewrite(m, src_uri), markdown)
