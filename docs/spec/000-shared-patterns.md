# 000 - Shared Patterns Reference

This document contains templates and boilerplate code that specs can reference to avoid repetition.

## Spec Template

Standard template for new specification documents:

```markdown
# XXX - Feature Name

**Purpose:** One-line description of what this does and why

**Requirements:**
- Key functional requirement 1
- Key functional requirement 2
- Important constraints or non-functional requirements

**Design Approach:**
- High-level design decision 1
- High-level design decision 2
- Key technical choices and rationale

**Implementation Notes:**
- Critical implementation details only
- Dependencies or special considerations
- Integration points with existing code

**Status:** [Draft/Approved/Implemented]
```

## Naming Convention

Packages under `packages/` are suffixed by language so each toolchain can
discover what it owns:

- `packages/<name>-py/` — Python (uv workspace member)
- `packages/<name>-ts/` — TypeScript (pnpm workspace member)
- `packages/<name>-go/` — Go (module listed in `go.work`)
- `packages/<name>-rs/` — Rust (crate listed in `Cargo.toml` workspace)

When a single feature spans languages, pick one `<name>` and let the suffix
distinguish the implementation.
