---
name: python
description: Guidelines for writing Python code. Read this before interacting with any Python code in any way, including reading Python files or running one-time Python commands.
---

## Package management

Use the `uv` package manager for all projects. To run some ephemeral python
code which requires a package not used in the project, use `uv run --with <package>`

Use `uv sync`/`uv add`/`uv remove` instead of `uv pip` commands

To run a Python file, you can directly run `uv run file.py` instead of `uv run python file.py`

Never add or remove packages in pyproject.toml manually, use `uv` commands instead

## Type annotations

- Never add `from __future__ import annotations`. This is now default behaviour
  in Python, so this import is no longer needed.
- Use `TypedDict` instead of arbitrary `dict[str, ...]` when the structure is known

## Linting

- Format your code with `uv run ruff format`
- Run `uv run ruff check --fix` and `uv run mypy .` after your changes 
- Don't add any global rule exceptions in `pyproject.toml` without asking the user first
