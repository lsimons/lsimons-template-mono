# Agent Instructions for lsimons-template-mono

> This file (`AGENTS.md`) is the canonical agent configuration. `CLAUDE.md` is a symlink to this file.

> **If this repo still says "template" everywhere:** run
> `mise run init` once to rename the placeholder packages to your
> project name. See `scripts/init.py` for details.

Brief project description.

This repo is a polyglot monorepo: each language uses its **native workspace**
(uv / pnpm / `go.work` / Cargo workspace), plus an Astro Starlight
documentation site (bun) deployed to GitHub Pages.
[`mise`](https://mise.jdx.dev/) is the top-level entry point — it pins every
toolchain version and exposes every repo command as a task (see `.mise.toml`).
`docs/spec/002-toolchain.md` has the full rationale.

## Quick Reference

First time in a fresh clone: `mise install` (downloads + pins the
toolchain), then `mise run install` (uv sync + pnpm install).

- **Install all deps**: `mise run install`
- **Lint all**: `mise run lint`
- **Test all**: `mise run test`
- **Typecheck all**: `mise run typecheck`
- **Format all**: `mise run format`
- **Full CI gate**: `mise run ci`
- **Lint workflows**: `mise run gha:lint` (actionlint + shellcheck)
- **Supply-chain audit**: `mise run audit` (zizmor over `.github/`;
  needs a GitHub token and refuses to run a degraded offline audit)
- **Dependency vulnerability scan**: `mise run vuln` (osv-scanner over
  all five lockfiles + cargo-deny + govulncheck; network, no token)

Tasks are namespaced `<lang>:<verb>` so you can fan out at any
granularity — e.g. `mise run py:lint`, `mise run rs:test`. The docs site
uses the `doc:` namespace — e.g. `mise run doc:dev`, `mise run doc:build`,
`mise run doc:check` (Astro type/content check, part of `typecheck`),
`mise run doc:slides` (render the Quarto deck).

Per-language native commands still work standalone when mise isn't in
the way:

| Language   | Install             | Lint                                                 | Typecheck                  | Test                                       |
|------------|---------------------|------------------------------------------------------|----------------------------|--------------------------------------------|
| Python     | `uv sync`           | `uv run ruff check . && uv run ruff format --check .`| `uv run basedpyright`      | `uv run pytest`                            |
| TypeScript | `pnpm install`      | `pnpm -r lint`                                       | `pnpm -r typecheck`        | `pnpm -r test`                             |
| Go         | (none)              | `golangci-lint run ./...` (in each module)           | `go vet ./...`             | `go test -race -cover ./...`               |
| Rust       | (none)              | `cargo fmt --all --check && cargo clippy --workspace --all-targets --all-features -- -D warnings` | (via clippy) | `cargo test --workspace --all-targets`    |

Native per-language pins (`.nvmrc`, `package.json` `packageManager`,
`pyproject.toml` `requires-python`, `go.work` / `go.mod` `go` directive)
remain authoritative — mise reads them, so they keep a non-mise fallback
working, and they must agree with `.mise.toml`. Rust has no native pin
file here; `.mise.toml` is its only one. Pinning the rust toolchain is
not an MSRV declaration — there is still deliberately no `rust-version`
in `Cargo.toml`.

## Structure

```
packages/
├── lsimons-template-py/    # Python (uv workspace member)
├── lsimons-template-ts/    # TypeScript (pnpm workspace member)
├── lsimons-template-go/    # Go (module in go.work)
├── lsimons-template-rs/    # Rust (crate in Cargo workspace; lib + bin)
└── lsimons-template-doc/   # Docs site (Astro Starlight; bun; standalone)
```

See `docs/spec/000-shared-patterns.md` for the naming convention and when
to add specs.

The docs site is a *project* site served under the `/lsimons-template-mono`
base path (set in `packages/lsimons-template-doc/astro.config.mjs`), so
content links and image sources are written root-relative and a rehype
plugin prepends the base at render time. It is deliberately **not** a pnpm
workspace member (`pnpm-workspace.yaml` globs `packages/*-ts` only) — bun
manages it standalone. `.github/workflows/deploy.yml` publishes
`packages/lsimons-template-doc/dist` to GitHub Pages on push to `main`; the
Pages source must be set to "GitHub Actions". CI does not run Quarto — the
slide outputs under `public/presentations/` are committed.

## Guidelines

**Python:**
- Full type annotations; basedpyright strict must be 0 errors
- ruff for lint + format; 100-char lines
- Coverage floor is 80% (`--cov-fail-under=80` in the root
  `pyproject.toml`, enforced by `mise run py:test`)

**TypeScript:**
- Strict TypeScript (no implicit `any`, `erasableSyntaxOnly`, etc.)
- Biome for lint + format; 0 warnings / errors
- Use `.ts` import extensions (required by NodeNext + Node native stripping)

**Go:**
- Code must be `gofumpt`-formatted and `goimports`-clean
- `go vet ./...` and `golangci-lint run` must report zero issues
- Tests for all functionality; prefer stdlib `testing` with table-driven cases

**Rust:**
- Edition 2024; the toolchain is exact-pinned in `.mise.toml` like every
  other tool, but there is no MSRV (`rust-version`) declaration
- `cargo clippy -- -D warnings` clean (warn on `all` + `pedantic`)
- `unsafe_code = "forbid"` by default (workspace-level lint)

**Docs:**
- Astro Starlight (bun); `mise run doc:check` (Astro type/content check)
  must pass clean and `mise run doc:build` must succeed
- Markdown pages live in `src/content/docs/`; each needs a `title` in
  frontmatter. Write content links/images root-relative (`/guides/foo/`)
- Slide decks are Quarto `.qmd` in `public/presentations/`; commit the
  rendered HTML/PDF (`mise run doc:slides`) — CI does not run Quarto

**Cross-cutting:**

- Do not silence a check without a written justification on the same
  line — a bare `# noqa`, `# type: ignore`, `//nolint`, `#[allow(...)]`
  or `biome-ignore` is not acceptable; a narrow one naming the reason
  is. Prefer fixing the cause; suppress when the cause is outside this
  repo.
- Never weaken a control to make a check pass: do not lower a coverage
  floor, unpin an action or a tool, or delete a failing test.
- A change to one language must keep `mise run ci` green for all of
  them. `mise run ci` and the CI workflow must cover the same ground —
  if you add a task to one, add it to the other, and put shared
  environment (`RUSTFLAGS`, `RUSTDOCFLAGS`, …) on the mise task rather
  than in the workflow, or the local gate is weaker than CI.
- **There is deliberately no `.editorconfig`.** Five formatters disagree
  by design here — gofumpt uses tabs, ruff/biome/rustfmt use 4 spaces at
  100 columns, and the YAML in `.github/workflows/` is 2-space while
  `pnpm-workspace.yaml` is 4-space — so any single rule would be wrong
  about part of the tree on day one and would manufacture the spurious
  diffs the file exists to prevent. Biome also ignores `.editorconfig`
  unless `formatter.useEditorconfig` is set. Do not add one without
  resolving those conflicts first.

**Supply chain:**

- Every lockfile (`uv.lock`, `pnpm-lock.yaml`, `Cargo.lock`, each
  `go.sum`, the docs site's `bun.lock`) is committed and must stay in the
  tree. Each one has a matching `.github/dependabot.yml` entry; adding a
  new package manager means adding an entry, or its dependencies are
  never updated by anything. `mise run vuln:osv` re-derives the lockfile
  list from git and fails if the scanner skipped one, so a new package
  manager that nothing scans goes red rather than quietly unscanned.
- CI installs with the `*:install-frozen` tasks, never the plain
  `install` ones. A manifest change the lock does not reflect must fail
  the run, not be re-resolved on the runner — a lockfile CI is willing to
  regenerate is not a pin. Use plain `mise run install` locally, which is
  the task you run while deliberately changing dependencies.
- `mise run vuln` must be clean. Note that `pnpm audit` and `bun audit`
  each see only their own tree; `vuln` is the one that covers all five.
  Fix a finding by moving the dependency, not by narrowing the scan.
  Where the advisory is in a *transitive* package, neither
  `pnpm update`/`bun update` nor dependabot will lift it — both act on
  constraints an importer declares and leave a satisfied nested
  resolution alone. The levers are an `overrides` block (see the docs
  site's `package.json`) or promoting the package to an explicit
  devDependency (see `vite` in the root `package.json`); both carry a
  comment saying which, and why, and when to remove it.
- GitHub Actions are pinned to full-length commit SHAs with a `# vX.Y.Z`
  comment. Pin the *commit*, not an annotated tag object: for an
  annotated tag, `refs/tags/vX.Y.Z` resolves to a tag object whose SHA is
  **not** the commit SHA, and pasting that is easy to do by accident.
  Check any pin you add or bump with
  `gh api repos/<owner>/<repo>/git/commits/<sha>` — it returns the commit
  for a real commit SHA and `404` for a tag object. `mise run audit`
  catches it too (zizmor's `ref-version-mismatch`).
- Every tool in `.mise.toml` is pinned to an exact version, python, go
  and rust included. Nothing there is covered by dependabot, so refresh
  it deliberately with `mise up` and read the diff.
- `mise.lock` records a checksum per tool *per platform* — all 11 in this
  repo, verified, so a contributor on any platform is covered. That
  breadth comes from this repo's tool set, not from mise: the same tool
  in `lsimons-template-rs` records only 2. Two entries have no checksum
  at all: `rust` (installed via rustup, which verifies against the
  channel manifest instead) and `go:.../govulncheck` (compiled from
  source, authenticated by the Go checksum database). Both are real
  controls, but they are different ones and the lockfile does not record
  their result. See the note at the top of `.mise.toml`.

## Commit Message Convention

Follow [Conventional Commits](https://conventionalcommits.org/):

**Format:** `type(scope): description`

Scopes should prefix the language when relevant: `feat(py): ...`,
`fix(rs): ...`, `ci(ts): ...`. Cross-language work can skip the scope.

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `build`, `ci`, `perf`, `revert`, `improvement`, `chore`

## Session Completion

Work is NOT complete until every change is committed, pushed, and CI passes.

1. **Quality gates** (run the ones that changed, or just `mise run ci`):
   ```bash
   mise run lint typecheck test
   ```

2. **Commit**: stage and commit every change from this session. Do not leave the working tree dirty.
   ```bash
   git status              # review untracked and unstaged files
   git add <files>
   git commit -m "<type>(<scope>): <description>"
   ```

3. **Push**:
   ```bash
   git pull --rebase && git push
   git status  # must show "up to date with origin"
   ```

4. **Verify CI**:
   ```bash
   mise run ci-watch
   ```
   On failure, inspect with `gh run view --log-failed`, fix, commit, push, and re-watch.

Never stop before CI is green. If anything fails, resolve and retry.
