---
title: Contributing
description: How the site and slide decks are built and how to contribute.
---

This site is built with [Astro Starlight](https://starlight.astro.build/) and
published to GitHub Pages. Contributions are welcome - see
[CONTRIBUTING.md](https://github.com/lsimons/lsimons-template-mono/blob/main/CONTRIBUTING.md)
in the repository root.

## The site

Tools are pinned in `.mise.toml`; run `mise install` once. Then:

- `mise run doc:install` - install the site dependencies (bun).
- `mise run doc:dev` - start the live-reloading dev server.
- `mise run doc:build` - build the static site into `packages/lsimons-template-doc/dist`.
- `mise run doc:check` - run the Astro type/content check.

Content lives in `packages/lsimons-template-doc/src/content/docs/`; static assets in `packages/lsimons-template-doc/public/`.

## Slide decks

The [example presentation](/presentations/example.qmd) is built with
[Quarto](https://quarto.org/). Render it with `mise run doc:slides` (or
`quarto render packages/lsimons-template-doc/public/presentations/example.qmd`).

The presentations change so rarely that their rendered HTML and PDF outputs are
committed to git.

## Conventions

Commit messages follow [Conventional Commits](https://conventionalcommits.org/);
prefix the scope with the language when relevant (`docs(doc): ...`). The full
monorepo CI gate runs with `mise run ci`, and `mise run doc:check` plus
`mise run doc:build` cover the docs site. See `AGENTS.md` at the repo root for
the per-language guidelines.
