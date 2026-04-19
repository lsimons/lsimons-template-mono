# 002 - Adopt mise for toolchain + tasks

**Purpose:** Replace the root `Makefile` and per-language version managers
with [mise](https://mise.jdx.dev/) as the single source of truth for
runtime versions and repo tasks across all four languages.

**Requirements:**
- One file (`.mise.toml`) pins Node, pnpm, Python, Go, Rust, uv. It also
  declares every repo task (install / lint / format / typecheck / test /
  build / clean / ci) plus a per-language namespace (`py:*`, `ts:*`,
  `go:*`, `rs:*`).
- `mise install` is the only prerequisite for a fresh clone. No separate
  nvm / rustup / pyenv / brew installs.
- `mise run <task>` replaces `make <target>`. The root `Makefile` is
  removed.
- CI uses `jdx/mise-action` (SHA-pinned) to install the toolchain, then
  calls `mise run <lang>:<task>`. One action replaces the previous four
  `setup-python` / `setup-node` / `setup-go` / `dtolnay/rust-toolchain`
  actions across all jobs.
- Per-language caches (uv cache, pnpm store, cargo) stay as dedicated
  cache steps — they sit on top of mise, not inside it.
- Native per-language pin files stay authoritative (`.nvmrc`,
  `rust-toolchain.toml`, `go.mod` `go` directive, `pyproject.toml`
  `requires-python`). mise reads them; a contributor without mise can
  still use the native tools directly.

**Design Approach:**
- `.mise.toml` structure mirrors the old `Makefile` phony targets so
  downstream muscle memory carries over:
  ```toml
  [tools]
  node = "24"; pnpm = "10"; python = "3.14"; go = "1.26"; rust = "latest"; uv = "latest"

  [tasks.lint]
  depends = ["py:lint", "ts:lint", "go:lint", "rs:lint"]

  [tasks."py:lint"]
  run = ["uv run ruff check .", "uv run ruff format --check ."]
  # …and so on for py:format / py:typecheck / py:test, plus
  # ts:/go:/rs: variants.
  ```
- Task namespacing uses `<lang>:<verb>` (e.g. `py:lint`) so a contributor
  can always fan out at any granularity they want.
- Go tasks iterate `packages/*-go` in-shell rather than relying on
  `./...` from the root, because `go test ./...` from a workspace root
  with no root module fails — same reason the old `Makefile` iterated.
- CI is still four parallel jobs (python / typescript / go / rust). Each
  job installs the full mise toolchain; that's wasteful on paper but the
  mise cache makes it cheap in practice and keeps job logs independent.
- Environment / secrets: `.mise.toml` has an `[env]` block that loads an
  optional `.env` file (gitignored). Secret references use `op://` and
  are resolved by [fnox](https://fnox.jdx.dev/) running outside git
  checkout scope.

**Implementation Notes:**
- Shipped commits: `feat(mise): replace Makefile with mise tasks`,
  `ci: migrate to jdx/mise-action`, `docs(spec): add 002-mise-adoption`.
- The `Makefile` deletion is not reversible in-place; anyone with local
  muscle memory for `make` should alias `make='mise run'` or similar.
- `jdx/mise-action` is pinned to
  `1648a7812b9aeae629881980618f079932869151` (v4.0.1) in the workflow.
  Bump like any other action — via SHA, with the comment noting the tag.
- Downstream application repos that consume this template inherit the
  same pattern. `lsimons-agent` and `typelinkmodel/tlm` are the polyglot
  downstream adopters; single-language downstream repos follow the
  single-language templates (`lsimons-template-py/-ts/-go/-rs`), which
  each ship an equivalent single-language `.mise.toml`.

**Status:** Approved — shipped in commit range starting at
`feat(mise): replace Makefile with mise tasks`.
