# lsimons-template-mono

Project template for a polyglot monorepo covering Python, TypeScript, Go,
and Rust. Each language uses its **native workspace** so standard toolchain
commands (uv / pnpm / `go.work` / Cargo workspace) keep working without an
orchestrator layer on top. A thin top-level `Makefile` wraps them for
unified `make lint test` style invocation.

## Using This Template

1. Copy this repository to create a new project
2. Replace placeholders throughout:
   - `$project` — project name (e.g., `myproject`)
   - `$shortDescription` — one-line description

3. Update manifests:
   - `pyproject.toml` (root + `packages/lsimons-$project-py/`) — rename
     `lsimons-$project-workspace` / `lsimons-$project-py`
   - `package.json` (root) — rename `lsimons-$project-workspace`
   - `packages/lsimons-$project-ts/package.json` — rename
   - `packages/lsimons-$project-go/go.mod` — update module path
   - `go.work` — update the `use` directive
   - `Cargo.toml` (root) — update `members`
   - `packages/lsimons-$project-rs/Cargo.toml` — rename

4. Rename the four package directories once placeholders are substituted.

5. Update `AGENTS.md` (and `CLAUDE.md` symlink) with project-specific
   instructions.

6. Drop any languages you don't need: delete the `packages/lsimons-$project-<lang>/`
   directory, remove the corresponding workspace entry
   (`pyproject.toml` / `pnpm-workspace.yaml` / `go.work` / root
   `Cargo.toml`), delete the matching Makefile targets, and delete the
   matching CI job.

## Included Configuration

### Shared
- **GitHub Actions CI** on push/PR to main, with actions pinned to
  full-length commit SHAs (the repo setting *Require actions to be
  pinned to a full-length commit SHA* is enabled)
- **`Makefile`** orchestrator — zero-install, delegates to native tools
- **`.mise.toml`** optional runtime-version pin (Node, pnpm, Python, Rust, Go)
- **`docs/spec/`** for spec-driven development

### Python (uv workspace)
- Python 3.14+, uv workspace with `packages/*-py` members
- ruff for lint + format, basedpyright strict for type checking, pytest for tests

### TypeScript (pnpm workspace)
- Node 24 LTS, native TypeScript type stripping
- TypeScript 6.x strict (+ `erasableSyntaxOnly`, `noUncheckedIndexedAccess`,
  `exactOptionalPropertyTypes`)
- Biome 2 for lint + format, Vitest 4 for tests (80% coverage threshold)
- Root `tsconfig.base.json` that each member extends

### Go (go.work workspace)
- Go 1.26+; one module per package listed in `go.work`
- golangci-lint v2, gofumpt + goimports, `go test -race -cover`

### Rust (Cargo workspace)
- Edition 2024, MSRV 1.85
- Single workspace with shared lints (`all + pedantic` warn, `unsafe_code = forbid`)
- Release profile tuned for small binaries (thin LTO, strip, 1 codegen unit)
- clap 4 (derive) + assert_cmd/predicates for CLI tests

> **Note:** CI is red on this template repo itself — the `$project`
> placeholder makes every manifest name malformed on purpose. Once you
> fork and do the search/replace described above, CI turns green.

## Project Structure

```
lsimons-$project/
├── .github/workflows/ci.yml          # 4 parallel jobs (py / ts / go / rs)
├── docs/spec/                        # Feature specifications
├── packages/
│   ├── lsimons-$project-py/          # Python package
│   ├── lsimons-$project-ts/          # TypeScript package
│   ├── lsimons-$project-go/          # Go module
│   └── lsimons-$project-rs/          # Rust crate (lib + bin)
├── .golangci.yml                     # Go linter
├── .mise.toml                        # Optional toolchain pin
├── .nvmrc                            # Node version pin
├── AGENTS.md                         # AI agent instructions
├── CLAUDE.md -> AGENTS.md            # Claude Code compatibility
├── Cargo.toml                        # Rust workspace root
├── Makefile                          # Top-level orchestrator
├── biome.json                        # TS lint + format
├── clippy.toml                       # Rust lint MSRV
├── go.work                           # Go workspace
├── package.json                      # TS workspace root
├── pnpm-workspace.yaml               # pnpm workspace members
├── pyproject.toml                    # Python workspace root + shared config
├── rustfmt.toml                      # Rust formatter
├── tsconfig.base.json                # TS compiler base
└── README.md
```

## Development Commands

```bash
# Install (Python + TypeScript)
make install

# Lint / typecheck / test / format everything
make lint
make typecheck
make test
make format

# Language-scoped targets
make py-test        # uv run pytest
make ts-test        # pnpm -r --parallel test
make go-test        # go test -race -cover ./...
make rs-test        # cargo test --workspace --all-targets
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

See [LICENSE.md](./LICENSE.md).

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).
