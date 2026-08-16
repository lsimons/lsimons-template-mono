# lsimons-template-mono

Project template for a polyglot monorepo covering Python, TypeScript, Go,
and Rust, plus an Astro Starlight documentation site published to GitHub
Pages. Each language uses its **native workspace** so standard toolchain
commands (uv / pnpm / `go.work` / Cargo workspace) keep working without an
orchestrator layer on top. [`mise`](https://mise.jdx.dev/) pins every
toolchain version and exposes every repo command as a task, so
`mise run lint test` replaces the old `make lint test` pattern.

## Using This Template

1. Click **Use this template** on GitHub (or clone this repo).
2. Clone your new repo locally and run:

   ```bash
   mise install          # pin + install every toolchain
   mise run init         # rename `template` → your project name
                         # (updates manifests + renames 5 package dirs)
   mise run install      # uv sync + pnpm install
   ```

   `mise run init` auto-detects your project name from the git remote
   (or directory name), stripping `lsimons-` / `-mono` suffixes. Pass
   `--name foo` to override. See `scripts/init.py` for details.

3. Update `AGENTS.md` (and `CLAUDE.md` symlink) with project-specific
   instructions.
4. Drop any languages you don't need: delete the
   `packages/lsimons-<name>-<lang>/` directory, remove the workspace
   entry (`pyproject.toml` / `pnpm-workspace.yaml` / `go.work` / root
   `Cargo.toml`), delete the matching mise tasks (`<lang>:*` in
   `.mise.toml`), remove the language from the top-level task `depends`
   lists, and delete the matching CI job.

## Included Configuration

### Shared
- **GitHub Actions CI** on push/PR to main, with every action pinned to
  a full-length commit SHA. `zizmor` enforces the pinning in CI and in
  `mise run audit`. Uses `jdx/mise-action` to install the toolchain, then
  `mise run <lang>:*`.
- **Workflow linting and auditing** — `actionlint` (with `shellcheck`) and
  `zizmor` run over `.github/`, in CI and locally via `mise run gha:lint`
  and `mise run audit`.
- **GitHub Pages deploy** (`.github/workflows/deploy.yml`) publishes the
  docs site to Pages on push to main. Set the Pages source to "GitHub
  Actions" (not "Deploy from a branch") in repo settings.
- **Dependency vulnerability scanning** — `mise run vuln` and a CI job of
  its own: `osv-scanner` over all five lockfiles (uv, pnpm, bun, cargo,
  gomod) plus `cargo-deny` for the crates.io-only source policy and
  `govulncheck` for the Go toolchain. Kept out of `mise run ci` so that
  gate stays runnable offline.
- **`.mise.toml`** pins every toolchain version *exactly* AND defines
  every repo task (install / lint / format / typecheck / test / build /
  clean / ci / audit / vuln, with per-language `<lang>:*` namespaces)
- **`.github/dependabot.yml`** — one entry per lockfile: `uv` (uv.lock),
  `npm` (pnpm-lock.yaml), `bun` (the docs site's bun.lock), `gomod`,
  `cargo` and `github-actions`
- **Frozen installs in CI** — every workflow uses the
  `<lang>:install-frozen` tasks, so a manifest change the lockfile does
  not reflect fails the run instead of being re-resolved on the runner
- **`docs/spec/`** for spec-driven development (see
  `docs/spec/002-toolchain.md` for the mise/CI rationale)

### Python (uv workspace)
- Python 3.14+, uv workspace with `packages/*-py` members
- ruff for lint + format, basedpyright strict for type checking, pytest
  for tests (80% coverage floor, enforced by `mise run py:test`)

### TypeScript (pnpm workspace)
- Node 24 LTS, native TypeScript type stripping
- Strict TypeScript (+ `erasableSyntaxOnly`, `noUncheckedIndexedAccess`,
  `exactOptionalPropertyTypes`); see `package.json` for the pinned
  compiler version
- Biome 2 for lint + format, Vitest 4 for tests (80% coverage threshold)
- Root `tsconfig.base.json` that each member extends

### Go (go.work workspace)
- Go 1.26+; one module per package listed in `go.work`
- golangci-lint v2, gofumpt + goimports, `go test -race -cover`

### Rust (Cargo workspace)
- Edition 2024. The rust *toolchain* is pinned exactly in `.mise.toml`
  like every other tool; that is a supply-chain pin, not an MSRV. There
  is deliberately no `rust-version` — it would cap dependency resolution
  at a version that goes stale independently of the toolchain pin
- Single workspace with shared lints (`all + pedantic` warn, `unsafe_code = forbid`)
- Release profile tuned for small binaries (thin LTO, strip, 1 codegen unit)
- clap 4 (derive) + assert_cmd/predicates for CLI tests

### Docs (Astro Starlight + Quarto)
- `packages/lsimons-template-doc/` — an Astro Starlight site built with
  bun, deployed to GitHub Pages under the `/lsimons-template-mono` base
  path (`astro.config.mjs`)
- Quarto slide decks in `public/presentations/` (committed HTML/PDF; CI
  does not run Quarto). Render with `mise run doc:slides`
- Intentionally **not** a pnpm workspace member — bun manages it
  standalone (`pnpm-workspace.yaml` globs `packages/*-ts` only)

## Project Structure

```
lsimons-template-mono/
├── .github/workflows/ci.yml          # parallel jobs (py / ts / go / rs / docs / vuln)
├── .github/workflows/deploy.yml      # docs → GitHub Pages on push to main
├── docs/spec/                        # Feature specifications
├── scripts/init.py                   # Rename-to-your-project helper
├── packages/
│   ├── lsimons-template-py/          # Python package
│   ├── lsimons-template-ts/          # TypeScript package
│   ├── lsimons-template-go/          # Go module
│   ├── lsimons-template-rs/          # Rust crate (lib + bin)
│   └── lsimons-template-doc/         # Astro Starlight docs site (bun)
├── .github/dependabot.yml            # one entry per lockfile
├── .golangci.yml                     # Go linter
├── .mise.toml                        # Exact toolchain pins + task runner
├── .nvmrc                            # Node version pin
├── AGENTS.md                         # AI agent instructions
├── CLAUDE.md -> AGENTS.md            # Claude Code compatibility
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── LICENSE                           # Apache-2.0 (no file extension)
├── Cargo.toml                        # Rust workspace root
├── Cargo.lock                        # never gitignore this
├── biome.json                        # TS lint + format
├── deny.toml                         # cargo-deny advisory + source policy
├── go.work                           # Go workspace
├── package.json                      # TS workspace root
├── pnpm-workspace.yaml               # pnpm workspace members
├── pnpm-lock.yaml                    # never gitignore this
├── pyproject.toml                    # Python workspace root + shared config
├── uv.lock                           # never gitignore this
├── rustfmt.toml                      # Rust formatter
├── tsconfig.base.json                # TS compiler base
└── README.md
```

## Development Commands

```bash
# One-time: allow this repo's mise config, then install the toolchains
mise trust
mise install

# Install deps (Python + TypeScript + docs)
mise run install

# Lint / typecheck / test / format / build everything
mise run lint
mise run typecheck
mise run test
mise run format
mise run build

# Full CI gate locally
mise run ci

# Workflow lint + supply-chain audit (audit needs a GitHub token:
# `gh auth login`; it refuses to run a degraded offline audit)
mise run gha:lint
mise run audit

# Scan every lockfile for known vulnerabilities (network, no token)
mise run vuln
mise run vuln:osv       # osv-scanner alone, all five lockfiles

# Language-scoped tasks
mise run py:test        # uv run pytest
mise run ts:test        # pnpm -r --parallel test
mise run go:test        # go test -race -cover ./...  (per module)
mise run rs:test        # cargo test --workspace --all-targets

# Docs site (Astro Starlight, bun)
mise run doc:dev        # live-reloading dev server
mise run doc:build      # static build into packages/lsimons-template-doc/dist
mise run doc:slides     # render the example Quarto deck (HTML + PDF)
```

Per-language native commands work the same way they would in each
single-language template. See `AGENTS.md` for the full matrix.

## Why This Layout

The explicit goal is that **the native toolchain Just Works** in each
language:

- `pnpm -r ...` iterates TS packages (selected by `pnpm-workspace.yaml`)
- `cargo <cmd> --workspace` operates on all Rust crates (selected by root
  `Cargo.toml`)
- `uv sync --all-packages` / `uv run pytest` operates on all Python
  members (selected by `[tool.uv.workspace]` in root `pyproject.toml`)
- `go <cmd>` cooperates with `go.work` to see all modules at once

The language suffix in package names (`-py`, `-ts`, `-go`, `-rs`) makes
workspace globs unambiguous and avoids collisions when one feature has
multiple implementations. See `docs/spec/000-shared-patterns.md`.

## License

Apache-2.0. See [LICENSE](./LICENSE).

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).
