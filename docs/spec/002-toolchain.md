# 002 - Toolchain

**Purpose:** Standardize how this repo — and downstream projects forked
from [`lsimons/lsimons-template-mono`](https://github.com/lsimons/lsimons-template-mono)
and its single-language siblings — manage runtime versions, repo tasks,
and CI.

**Requirements:**
- [`mise`](https://mise.jdx.dev/) is the single source of truth for
  runtime versions and repo tasks. `mise install` + `mise run <task>`
  are the only entry points a contributor needs to know.
- `.mise.toml` pins every tool under `[tools]` and declares every repo
  task under `[tasks.<task>]`. Tasks are namespaced `<lang>:<verb>`
  (`py:lint`, `rs:test`, …) with top-level fan-outs (`lint`, `test`,
  `ci`, …) that `depends = [...]` on the namespaced ones.
- Native per-language pin files stay authoritative (`.nvmrc`,
  `package.json` `packageManager`, `pyproject.toml` `requires-python`,
  `go.work` / `go.mod` `go` directive). mise reads them, so native tools
  still work for contributors without mise, and they must agree with
  `.mise.toml`. Rust has no native pin file — see below.
- CI uses [`jdx/mise-action`](https://github.com/jdx/mise-action),
  SHA-pinned, to install the toolchain, then calls `mise run <task>`.
  One action replaces per-language `setup-python` / `setup-node` /
  `setup-go` / `dtolnay/rust-toolchain` setups.
- Per-language caches (uv cache, pnpm store, cargo) stay as dedicated
  `actions/cache` steps on top of mise.
- Secrets use `op://` references resolved by
  [`fnox`](https://fnox.jdx.dev/) via an `[env]` block that loads an
  optional gitignored `.env`. Plaintext tokens never land on disk.

**Design Approach:**
- **Every tool in `[tools]` is pinned to an exact version**, python, go
  and rust included. This is a supply-chain rule, not a stability one:
  an upstream compromise must never arrive by auto-download, and a
  blanket "pin everything, update mechanically with `mise up`" policy is
  cheaper to review than per-upstream trust judgements. Nothing in
  `[tools]` is covered by dependabot, so it must be refreshed
  deliberately.
- **No MSRV for Rust**, despite the exact toolchain pin: no
  `rust-version` in `Cargo.toml`, no `clippy.toml` msrv. The two are
  separate questions — the pin says which compiler *we* build with, an
  MSRV would say which compilers *others* must support. Personal
  projects don't need to support old compilers.
- **`rustfmt` + `clippy` components are installed by an explicit CI
  step** (`rustup component add rustfmt clippy`). mise's rust plugin
  sets `RUSTUP_TOOLCHAIN`, which overrides any `rust-toolchain.toml`,
  so components declared there don't take effect.
- **Go tasks iterate `packages/*-go` in-shell** in polyglot repos —
  `go test ./...` from a workspace root without a root module fails.
- **`mise run init` is the first command on a fresh fork.** The
  template ships a `scripts/init.py` that renames the placeholder
  `template` identifiers to the project name auto-detected from the
  git remote. Downstream repos that forked before `init` existed can
  remove that script + task once initialized.
- **CI keeps independent parallel jobs per language** in polyglot
  repos. Each job re-installs the full toolchain; the mise cache
  makes this cheap and logs stay readable.

**Status:** Active. Canonical implementation lives in
[`lsimons/lsimons-template-mono`](https://github.com/lsimons/lsimons-template-mono);
single-language equivalents live in `lsimons-template-{py,ts,go,rs}`.
