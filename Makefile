# Top-level orchestrator. Each target just delegates to the native toolchain
# for each language, so everything also works when invoked directly
# (pnpm -r ..., cargo ..., uv run ..., go ...). No hidden state.

.PHONY: install lint format typecheck test build clean \
        py-install py-lint py-format py-typecheck py-test \
        ts-install ts-lint ts-format ts-typecheck ts-test ts-build \
        go-lint go-format go-test go-build \
        rs-lint rs-format rs-test rs-build

install: py-install ts-install

lint: py-lint ts-lint go-lint rs-lint
format: py-format ts-format go-format rs-format
typecheck: py-typecheck ts-typecheck
test: py-test ts-test go-test rs-test
build: ts-build go-build rs-build

clean:
	rm -rf node_modules packages/*/node_modules
	rm -rf .venv packages/*/.venv
	rm -rf target
	find packages -name 'bin' -maxdepth 2 -type d -exec rm -rf {} +
	find packages -name 'dist' -maxdepth 2 -type d -exec rm -rf {} +
	find packages -name '*.tsbuildinfo' -delete
	find . -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null || true

# Python -----------------------------------------------------------------------
py-install:
	uv sync --all-groups --all-packages
py-lint:
	uv run ruff check .
	uv run ruff format --check .
py-format:
	uv run ruff format .
	uv run ruff check --fix .
py-typecheck:
	uv run basedpyright
py-test:
	uv run pytest

# TypeScript -------------------------------------------------------------------
ts-install:
	pnpm install
ts-lint:
	pnpm -r --parallel lint
ts-format:
	pnpm -r --parallel format
ts-typecheck:
	pnpm -r --parallel typecheck
ts-test:
	pnpm -r --parallel test
ts-build:
	pnpm -r --parallel build

# Go ---------------------------------------------------------------------------
# go.work coordinates the modules, but most `go` subcommands still want to be
# run from inside a module directory; iterate over packages/*-go so adding a
# new Go module is "drop it in + add a `use` line in go.work".
GO_MODULES = $(wildcard packages/*-go)

go-lint:
	@for m in $(GO_MODULES); do \
	  echo "--- golangci-lint $$m"; \
	  (cd $$m && golangci-lint run ./...) || exit 1; \
	  out=$$(cd $$m && gofmt -l .); \
	  if [ -n "$$out" ]; then echo "Unformatted Go files in $$m:" && echo "$$out" && exit 1; fi; \
	done
go-format:
	@for m in $(GO_MODULES); do (cd $$m && gofumpt -w .); done
go-test:
	@for m in $(GO_MODULES); do \
	  echo "--- go test $$m"; \
	  (cd $$m && go test -race -cover ./...) || exit 1; \
	done
go-build:
	@for m in $(GO_MODULES); do \
	  echo "--- go build $$m"; \
	  (cd $$m && go build ./...) || exit 1; \
	done

# Rust -------------------------------------------------------------------------
rs-lint:
	cargo fmt --all --check
	cargo clippy --workspace --all-targets --all-features -- -D warnings
rs-format:
	cargo fmt --all
rs-test:
	cargo test --workspace --all-targets
rs-build:
	cargo build --workspace --all-targets
