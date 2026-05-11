# PRD: <Feature Name>

<!-- Delete this comment block when filling in. Each story must be right-sized:
     implementable in one Claude context window, with a clear TDD red phase. -->

## Context

<1-3 sentences: what problem this solves and why now>

## Tech stack

- Language: <e.g., TypeScript / Python / Go>
- Framework: <e.g., Next.js 14 / FastAPI / net/http>
- Key files: <e.g., src/api/users.ts, src/db/schema.ts>
- Test runner: <e.g., jest / pytest / go test>
- Run tests: <e.g., npm test / pytest -q / go test ./...>

## Constraints

- <e.g., must not break existing auth flow>
- <e.g., no new dependencies without approval>
- <e.g., API response time <200ms>

## Acceptance criteria

- [ ] <Top-level test that proves the feature works end-to-end>

## Stories

<!-- Order matters — later stories may depend on earlier ones. -->
<!-- Each story: one focused feature, one commit, one set of tests. -->

- [ ] **Story 1**: Set up project structure — create directory layout and install dependencies
- [ ] **Story 2**: <imperative title> — <one sentence of what done looks like>
- [ ] **Story 3**: <imperative title> — <one sentence of what done looks like>
- [ ] **Story 4**: <imperative title> — <one sentence of what done looks like>
- [ ] **Story 5**: <imperative title> — <one sentence of what done looks like>
- [ ] **Story N**: Write end-to-end acceptance test — verifies the acceptance criteria above

<!--
SIZING GUIDE
  Too big  → "Add user authentication with OAuth, sessions, and JWT"
  Just right → "Add GET /users/:id endpoint with 404 handling"
  Too small → "Add a comment to the auth function"

GOOD STORY TEMPLATE
  - [ ] **Add <thing>**: implement <what> so that <acceptance criterion>
-->
