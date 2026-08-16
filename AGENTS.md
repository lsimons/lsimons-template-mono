# Agent Instructions for lsimons-template-mono

> This file (`AGENTS.md`) is the canonical agent configuration. `CLAUDE.md` is a symlink to this file.

> **If this repo still says "template" everywhere:** run
> `mise run init` once to rename the placeholder packages to your
> project name. See `scripts/init.py` for details.

Brief project description.

A polyglot monorepo: each language uses its native workspace (uv / pnpm /
`go.work` / Cargo workspace), plus an Astro Starlight docs site (bun) on
GitHub Pages. [`mise`](https://mise.jdx.dev/) pins every toolchain and
exposes every command as a task. Rationale lives in `.mise.toml`'s
comments and `docs/spec/002-toolchain.md`, not here.

## Quick Reference

Fresh clone: `mise install`, then `mise run install`.

| Task | What it does |
| ---- | ------------ |
| `mise run install` | Install all deps; may update lockfiles |
| `mise run install-frozen` | Install, failing on a stale lock; what CI runs |
| `mise run lint` / `format` / `typecheck` / `test` / `build` | All languages |
| `mise run ci` | Full gate: lint + typecheck + test + build (offline) |
| `mise run gha:lint` | actionlint + shellcheck over workflows |
| `mise run audit` | zizmor over `.github/`; needs a GitHub token |
| `mise run vuln` | osv-scanner + cargo-deny + govulncheck; network, no token |

Tasks are namespaced `<lang>:<verb>` — `py:lint`, `rs:test`, `doc:build`.
`mise tasks` lists them all.

Native commands still work standalone:

| Language   | Install             | Lint                                                 | Typecheck                  | Test                                       |
|------------|---------------------|------------------------------------------------------|----------------------------|--------------------------------------------|
| Python     | `uv sync`           | `uv run ruff check . && uv run ruff format --check .`| `uv run basedpyright`      | `uv run pytest`                            |
| TypeScript | `pnpm install`      | `pnpm -r lint`                                       | `pnpm -r typecheck`        | `pnpm -r test`                             |
| Go         | (none)              | `golangci-lint run ./...` (in each module)           | `go vet ./...`             | `go test -race -cover ./...`               |
| Rust       | (none)              | `cargo fmt --all --check && cargo clippy --workspace --all-targets --all-features --locked -- -D warnings` | (via clippy) | `cargo test --workspace --all-targets --locked` |

Native pin files (`.nvmrc`, `packageManager`, `requires-python`,
`go.work`) are authoritative and must agree with `.mise.toml`. Rust is
pinned in `.mise.toml` only, and that is not an MSRV declaration.

## Structure

```
packages/
├── lsimons-template-py/    # Python (uv workspace member)
├── lsimons-template-ts/    # TypeScript (pnpm workspace member)
├── lsimons-template-go/    # Go (module in go.work)
├── lsimons-template-rs/    # Rust (crate in Cargo workspace; lib + bin)
└── lsimons-template-doc/   # Docs site (Astro Starlight; bun; standalone)
```

Naming convention and when to add specs: `docs/spec/000-shared-patterns.md`.

The docs site is not a pnpm workspace member — bun manages it standalone.
It deploys under the `/lsimons-template-mono` base path, so content links
and images are written root-relative and a rehype plugin prepends the
base. `deploy.yml` publishes it on push to `main`; the Pages source must
be "GitHub Actions".

## Guidelines

**Python:** full type annotations, basedpyright strict at 0 errors; ruff
lint + format at 100 chars; coverage floor 80%.

**TypeScript:** strict TS; Biome clean; `.ts` import extensions (required
by NodeNext + native stripping).

**Go:** `gofumpt`-formatted, `goimports`-clean; `go vet` and
`golangci-lint run` at zero issues; table-driven stdlib tests.

**Rust:** edition 2024; `cargo clippy -- -D warnings` clean (`all` +
`pedantic`); `unsafe_code = "forbid"`. No `rust-version`: resolver 3 caps
dependency resolution at a rustc version either way, and omitting it
makes that cap track the toolchain pin rather than go stale. Declare one
only when publishing a library, together with a CI job that builds with
it.

**Docs:** `mise run doc:check` and `doc:build` must pass. Pages live in
`src/content/docs/` and need a `title`; write links and images
root-relative. Slide decks are Quarto `.qmd` under
`public/presentations/` — commit the rendered output, CI does not run
Quarto.

**Cross-cutting:**

- No bare `# noqa`, `# type: ignore`, `//nolint`, `#[allow(...)]` or
  `biome-ignore`. Narrow it and name the reason on the same line. Prefer
  fixing the cause.
- Never weaken a control to make a check pass: no lowered coverage
  floors, no unpinned actions or tools, no deleted tests.
- `mise run ci` and the CI workflow must cover the same ground. Put
  shared environment (`RUSTFLAGS`, …) on the mise task, not the workflow.
- **No `.editorconfig`**, deliberately — five formatters disagree by
  design. Do not add one.

**Supply chain:**

- Every lockfile is committed: `uv.lock`, `pnpm-lock.yaml`, `Cargo.lock`,
  `bun.lock`, each `go.sum`. Each needs a `.github/dependabot.yml` entry.
- CI installs with the `*:install-frozen` tasks. Use plain
  `mise run install` when deliberately changing dependencies.
- `mise run vuln` must be clean. Fix a finding by moving the dependency,
  never by narrowing the scan. For a transitive advisory the levers are
  an `overrides` block or an explicit devDependency — see the comments in
  the docs site's and the root `package.json`.
- Pin GitHub Actions to full-length commit SHAs — the *commit*, not an
  annotated tag object. Check with
  `gh api repos/<owner>/<repo>/git/commits/<sha>`.
- Every `.mise.toml` tool is exact-pinned and invisible to dependabot;
  refresh with `mise up` and read the diff.
- What `mise.lock` does and does not checksum is documented at the top of
  `.mise.toml`. Read it before relying on it.

## Commit Message Convention

[Conventional Commits](https://conventionalcommits.org/):
`type(scope): description`.

Prefix the language in the scope where it helps: `feat(py)`, `fix(rs)`,
`ci(ts)`. Cross-language work can skip the scope.

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `build`, `ci`, `perf`, `revert`, `improvement`, `chore`

## Session Completion

Work is not complete until every change is committed, pushed, and CI passes.

1. `mise run ci` (or the tasks that changed)
2. Commit everything — do not leave the working tree dirty
3. `git pull --rebase && git push`
4. `mise run ci-watch`; on failure `gh run view --log-failed`, fix, repeat

Never stop before CI is green.
