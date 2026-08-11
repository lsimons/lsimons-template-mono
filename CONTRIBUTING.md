Thank you for investing your time in contributing to our project!

Any contributions you make are governed by our [License](LICENSE).

Please follow our [Code of Conduct](CODE_OF_CONDUCT.md) to keep our community approachable and respectable.

You could read the [GitHub Docs Contributing Guide](https://github.com/github/docs/blob/main/CONTRIBUTING.md) for general advice on how to contribute.

Since this is a small hobby project, your contribution may not be noticed for a while if we are busy elsewhere. Sorry!

## Getting set up

This is a polyglot monorepo. [`mise`](https://mise.jdx.dev/) installs
every pinned toolchain and runs every repo task.

```bash
mise trust        # allow this repo's .mise.toml
mise install      # install the exact pinned toolchains
mise run install  # install dependencies for every language
```

## Before you open a pull request

```bash
mise run ci       # lint + typecheck + test + build, every language
mise run audit    # zizmor supply-chain audit (needs `gh auth login`)
```

`mise run ci` is the same gate CI runs. If you touched only one language,
`mise run <lang>:lint` / `<lang>:test` (`py`, `ts`, `go`, `rs`, `doc`)
are faster, but run the full gate before pushing.

Commit messages follow [Conventional Commits](https://conventionalcommits.org/),
with the language as the scope where it helps: `feat(py): ...`,
`fix(rs): ...`. Open the pull request against `main`.

## Reporting a security problem

Do not open a public issue. See [SECURITY.md](SECURITY.md).

## Working with agents

[AGENTS.md](AGENTS.md) is the canonical instruction file for coding
agents (`CLAUDE.md` is a symlink to it). Keep it current when you change
the toolchain or the task list.
