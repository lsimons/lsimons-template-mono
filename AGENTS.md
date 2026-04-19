# Agent Instructions for lsimons-$project

> This file (`AGENTS.md`) is the canonical agent configuration. `CLAUDE.md` is a symlink to this file.

Brief project description.

This repo is a polyglot monorepo: each language uses its **native workspace**
(uv / pnpm / `go.work` / Cargo workspace). [`mise`](https://mise.jdx.dev/)
is the top-level entry point — it pins every toolchain version and exposes
every repo command as a task (see `.mise.toml`). `docs/spec/002-mise-
adoption.md` has the full rationale.

## Quick Reference

First time in a fresh clone: `mise install` (downloads + pins the
toolchain), then `mise run install` (uv sync + pnpm install).

- **Install all deps**: `mise run install`
- **Lint all**: `mise run lint`
- **Test all**: `mise run test`
- **Typecheck all**: `mise run typecheck`
- **Format all**: `mise run format`
- **Full CI gate**: `mise run ci`

Tasks are namespaced `<lang>:<verb>` so you can fan out at any
granularity — e.g. `mise run py:lint`, `mise run rs:test`.

Per-language native commands still work standalone when mise isn't in
the way:

| Language   | Install             | Lint                                                 | Typecheck                  | Test                                       |
|------------|---------------------|------------------------------------------------------|----------------------------|--------------------------------------------|
| Python     | `uv sync`           | `uv run ruff check . && uv run ruff format --check .`| `uv run basedpyright`      | `uv run pytest`                            |
| TypeScript | `pnpm install`      | `pnpm -r lint`                                       | `pnpm -r typecheck`        | `pnpm -r test`                             |
| Go         | (none)              | `golangci-lint run ./...` (in each module)           | `go vet ./...`             | `go test -race -cover ./...`               |
| Rust       | (none)              | `cargo fmt --all --check && cargo clippy --workspace --all-targets --all-features -- -D warnings` | (via clippy) | `cargo test --workspace --all-targets`    |

Native per-language pins (`.nvmrc`, `pyproject.toml` `requires-python`,
`go.mod` `go` directive, `rust-version` in `Cargo.toml`) remain
authoritative — mise reads them, so they keep a non-mise fallback
working.

## Structure

```
packages/
├── lsimons-$project-py/   # Python (uv workspace member)
├── lsimons-$project-ts/   # TypeScript (pnpm workspace member)
├── lsimons-$project-go/   # Go (module in go.work)
└── lsimons-$project-rs/   # Rust (crate in Cargo workspace; lib + bin)
```

See `docs/spec/000-shared-patterns.md` for the naming convention and when
to add specs.

## Guidelines

**Python:**
- Full type annotations; basedpyright strict must be 0 errors
- ruff for lint + format; 100-char lines

**TypeScript:**
- Strict TypeScript (no implicit `any`, `erasableSyntaxOnly`, etc.)
- Biome for lint + format; 0 warnings / errors
- Use `.ts` import extensions (required by NodeNext + Node native stripping)

**Go:**
- Code must be `gofumpt`-formatted and `goimports`-clean
- `go vet ./...` and `golangci-lint run` must report zero issues
- Tests for all functionality; prefer stdlib `testing` with table-driven cases

**Rust:**
- Edition 2024; MSRV tracked via `rust-version` in `Cargo.toml`
- `cargo clippy -- -D warnings` clean (warn on `all` + `pedantic`)
- `unsafe_code = "forbid"` by default (workspace-level lint)

## Commit Message Convention

Follow [Conventional Commits](https://conventionalcommits.org/):

**Format:** `type(scope): description`

Scopes should prefix the language when relevant: `feat(py): ...`,
`fix(rs): ...`, `ci(ts): ...`. Cross-language work can skip the scope.

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `build`, `ci`, `perf`, `revert`, `improvement`, `chore`

## Session Completion

Work is NOT complete until `git push` succeeds.

1. **Quality gates** (run the ones that changed, or just `mise run ci`):
   ```bash
   mise run lint typecheck test
   ```

2. **Push**:
   ```bash
   git pull --rebase && git push
   git status  # must show "up to date with origin"
   ```

Never stop before pushing. If push fails, resolve and retry.
