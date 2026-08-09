---
name: semble
description: Semantic code search with Semble, allows to immediately find code by description instead of trying different grep patterns and reading a lot of files to find what you need.
---

# Code Search

Use `semble search` to find code by describing what it does or naming a
symbol/identifier, instead of grep:

```bash
semble search "authentication flow" ./my-project --max-snippet-lines 10  # first 10 lines only, concise
semble search "save_pretrained" ./my-project                          # full chunk content
semble search "save model to disk" ./my-project --top-k 10           # more results
```

The index is built on first run (and cached for subsequent runs) and
invalidated automatically when files change.

Use `--content docs` to search documentation and prose, `--content config` for
config files (yaml, toml, etc.), or `--content all` to search code, docs, and
config:

```bash
semble search "deployment guide" ./my-project --content docs
semble search "database host port" ./my-project --content config
semble search "authentication" ./my-project --content all
```

Use `semble find-related` to discover code similar to a known location (pass
`file_path` and `line` from a prior search result):

```bash
semble find-related src/auth.py 42 ./my-project
```

`path` defaults to the current directory when omitted; git URLs are accepted.

## Workflow

1. Start with `semble search` to find relevant chunks. The index is built and
   cached automatically.
2. Use `--content docs` for documentation, `--content config` for config files,
   or `--content all` for everything.
3. Navigate directly to the returned file and line — do not re-search or grep
   for the same content.
4. Optionally use `semble find-related` with a promising result's `file_path`
   and `line` to discover related implementations.
5. Use grep only when you need every occurrence of a literal string across the
   whole repo (e.g., all callers of a renamed function).
