# Project conventions

<!-- The AFK loop reads this file on every iteration. Keep it current. -->

## Test runner

- Run all tests: `<e.g., npm test / pytest -q / go test ./...>`
- Run single file: `<e.g., jest src/foo.test.ts / pytest tests/test_foo.py>`
- Watch mode: `<e.g., jest --watch>`

## Lint & format

- Lint: `<e.g., npm run lint / ruff check . / golangci-lint run>`
- Format: `<e.g., prettier --write . / black . / gofmt -w .>`

## Build

- Build: `<e.g., npm run build / go build ./... / python -m build>`
- Type check: `<e.g., tsc --noEmit / mypy . / go vet ./...>`

## Key paths

- Source: `src/`
- Tests: `tests/` or `src/**/*.test.ts`
- Config: `.env.local` (never commit)

## Code conventions

- <e.g., use named exports, not default exports>
- <e.g., errors returned, not thrown>
- <e.g., tests colocated with source>

## Do not touch

- <e.g., src/legacy/ — owned by another team>
- <e.g., database migrations — must be reviewed before running>
