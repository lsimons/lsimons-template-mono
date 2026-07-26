---
title: Getting started
description: Install the toolchain, run the dev server, and make the template your own.
---

This documentation site lives in the `packages/lsimons-template-doc/` package
of a polyglot monorepo. It is built with
[Astro Starlight](https://starlight.astro.build/), themed to match
[lsimons.github.io](https://lsimons.github.io), with a
[Quarto](https://quarto.org/) slide-deck setup and GitHub Pages deployment.

## Prerequisites

The whole monorepo's toolchain is pinned in the repo-root `.mise.toml`.
Install [mise](https://mise.jdx.dev/) once, then let it install the rest:

```bash
mise install
```

That includes `bun` (the site's package manager) and `quarto` (slide decks),
alongside the other languages' toolchains. Repo tasks are defined in
`.mise.toml` and run with `mise run <task>`; the docs site uses the `doc:`
namespace.

## Make it your own

Run the init task once (from the repo root) to rename the template
placeholders across the whole monorepo to your project:

```bash
mise run init                    # infer the name from the git remote / directory
mise run init --name my-project  # or set it explicitly
```

`init` replaces the `template` placeholder (in package names, the deploy base
path, manifests, and directory names) throughout the repo. See
`scripts/init.py` for exactly what it touches.

## Develop

```bash
mise run doc:install   # install site dependencies (bun)
mise run doc:dev       # dev server at http://localhost:4321/lsimons-template-mono/
mise run doc:build     # build the static site into packages/lsimons-template-doc/dist
mise run doc:check     # Astro type/content check
```

Content lives in `packages/lsimons-template-doc/src/content/docs/`; static assets and downloads in
`packages/lsimons-template-doc/public/`. Edit `packages/lsimons-template-doc/astro.config.mjs` to change the title, sidebar, and
social links.

## Publish

Enable GitHub Pages for your repo with the source set to **GitHub Actions**
(not "Deploy from a branch"). After that, every push to `main` builds and
deploys the site via `.github/workflows/deploy.yml`. Project sites live under a
subpath of `https://lsimons.github.io` matching the repo name - that subpath is
the `base` set in `packages/lsimons-template-doc/astro.config.mjs`.

## Next steps

- [Writing pages](/writing-pages/) - add content and wire up the sidebar.
- [Slide decks with Quarto](/slides/) - author and render presentations.
