---
name: pr
description: >
  Generate a polished, self-contained HTML pull request document from git diff output.
  Two modes: /pr writeup (author narrative — why you changed what) and /pr review
  (annotated diff with severity markers). Produces pr.html in the current directory.
---

# PR — Pull Request Document Generator

You are generating a pull request document as a self-contained HTML file. Two modes:

- **`/pr writeup`** — author's narrative: motivation, before/after, file-by-file tour, test plan.
  Helps reviewers understand intent, not just diffs. Based on the PR author's perspective.
- **`/pr review`** — annotated code review: file cards with severity markers, inline comments,
  risk classification, and a blocking-issues checklist.

The output must be a single `.html` file with all CSS inlined. Write to `pr.html` in the
current directory unless a different path is specified.

---

## When invoked as `/pr writeup` or `/pr review`

1. **Gather diff context** — run `git diff main...HEAD` (or the base branch). Also run
   `git log main...HEAD --oneline` for the commit list. Read any referenced spec or plan files.

2. **Analyse the changes**:
   - Group files by purpose (models, routes, tests, config, etc.)
   - Identify the intent of each group
   - Note which changes are risky (schema migrations, auth paths, shared utilities)

3. **Generate the HTML** for the chosen mode (see templates below).

4. **Write `pr.html`** to the current directory (or `specs/<dir>/pr.html` if working inside a specs dir).

5. **Tell the user** the output path.

---

## Design system

```css
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --ivory:    #FAF9F5;
  --slate:    #141413;
  --clay:     #D97757;
  --oat:      #E3DACC;
  --olive:    #788C5D;
  --rust:     #C0392B;
  --gray-150: #F0EEE6;
  --gray-300: #D1CFC5;
  --gray-500: #87867F;
  --gray-700: #3D3D3A;
  --white:    #FFFFFF;
  --serif: ui-serif, Georgia, 'Times New Roman', serif;
  --sans:  system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
  --mono:  ui-monospace, 'SF Mono', Menlo, Monaco, monospace;
}

body {
  background: var(--ivory); color: var(--gray-700);
  font-family: var(--sans); font-size: 15px; line-height: 1.6;
  padding: 56px 32px;
}
.container { max-width: 940px; margin: 0 auto; }

/* ── Header ── */
.pr-header { margin-bottom: 40px; border-bottom: 1.5px solid var(--gray-300); padding-bottom: 28px; }
.pr-header .eyebrow { font-family: var(--mono); font-size: 11px; text-transform: uppercase; letter-spacing: .08em; color: var(--clay); margin-bottom: 10px; }
.pr-header h1 { font-family: var(--serif); font-size: 2rem; color: var(--slate); margin-bottom: 14px; line-height: 1.15; }
.pr-meta { display: flex; gap: 20px; flex-wrap: wrap; font-size: 13px; color: var(--gray-500); font-family: var(--mono); }
.pr-meta strong { color: var(--gray-700); }

/* ── Sections ── */
section { margin-bottom: 44px; }
.sec-heading {
  font-family: var(--serif); font-size: 1.2rem; color: var(--slate);
  margin-bottom: 18px; padding-bottom: 10px;
  border-bottom: 1.5px solid var(--gray-300);
  display: flex; align-items: center; gap: 10px;
}
.sec-num { font-family: var(--mono); font-size: 11px; color: var(--gray-500); background: var(--oat); padding: 2px 8px; border-radius: 4px; }

/* ── TL;DR panel ── */
.tldr {
  background: var(--slate); color: var(--ivory);
  border-radius: 10px; padding: 24px 28px; margin-bottom: 40px;
}
.tldr .label { font-family: var(--mono); font-size: 10px; text-transform: uppercase; letter-spacing: .08em; color: var(--gray-500); margin-bottom: 8px; }
.tldr p { font-size: 1.05rem; line-height: 1.55; color: var(--ivory); }
.tldr .metrics { display: flex; gap: 20px; margin-top: 16px; flex-wrap: wrap; }
.tldr .metric { font-family: var(--mono); font-size: 12px; color: var(--gray-500); }
.tldr .metric strong { color: var(--clay); font-size: 1.1rem; }

/* ── Risk classification map ── */
.risk-map { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; margin: 16px 0; }
.risk-cell {
  border: 1.5px solid var(--gray-300); border-radius: 8px; padding: 14px;
  font-size: 13px;
}
.risk-cell.safe     { border-color: var(--olive);  background: #EBF0E4; }
.risk-cell.medium   { border-color: var(--oat);    background: #FAF3EC; }
.risk-cell.blocking { border-color: var(--rust);   background: #FDECEA; }
.risk-cell .risk-label {
  font-family: var(--mono); font-size: 10px; text-transform: uppercase;
  letter-spacing: .07em; margin-bottom: 6px;
}
.risk-cell.safe     .risk-label { color: var(--olive); }
.risk-cell.medium   .risk-label { color: var(--clay); }
.risk-cell.blocking .risk-label { color: var(--rust); }
.risk-cell ul { list-style: none; padding: 0; }
.risk-cell li { padding: 2px 0; color: var(--gray-700); font-family: var(--mono); font-size: 12px; }

/* ── File cards ── */
.file-card {
  border: 1.5px solid var(--gray-300); border-radius: 8px;
  margin-bottom: 20px; overflow: hidden;
}
.file-card-header {
  display: flex; align-items: center; gap: 12px;
  padding: 10px 16px; background: var(--gray-150);
  border-bottom: 1px solid var(--gray-300);
  cursor: pointer;
}
.file-path { font-family: var(--mono); font-size: 12px; color: var(--slate); flex: 1; }
.file-badge { font-family: var(--mono); font-size: 10px; padding: 2px 8px; border-radius: 999px; font-weight: 600; }
.file-badge.new      { background: #EBF0E4; color: var(--olive); }
.file-badge.modified { background: var(--oat); color: var(--gray-700); }
.file-badge.deleted  { background: #FDECEA; color: var(--rust); }
.line-delta { font-family: var(--mono); font-size: 11px; color: var(--gray-500); }
.line-delta .add { color: var(--olive); }
.line-delta .del { color: var(--rust); }

/* ── Diff view ── */
.diff-view { font-family: var(--mono); font-size: 12px; line-height: 1.65; overflow-x: auto; }
.diff-row { display: grid; grid-template-columns: 36px 36px 1fr; }
.diff-row .ln { padding: 1px 8px; color: var(--gray-500); background: var(--gray-150); text-align: right; user-select: none; border-right: 1px solid var(--gray-300); }
.diff-row .code { padding: 1px 12px; white-space: pre; }
.diff-row.add .code { background: #EBF0E4; color: #1a4a1a; }
.diff-row.add .ln   { background: #D4EDDA; }
.diff-row.del .code { background: #FDECEA; color: #5a1a1a; }
.diff-row.del .ln   { background: #F5C6CB; }
.diff-row.ctx .code { background: var(--white); color: var(--gray-700); }

/* ── Inline review comment ── */
.comment {
  margin: 4px 0 4px 72px; border-radius: 6px; padding: 10px 14px;
  font-size: 13px; line-height: 1.5; font-family: var(--sans);
  border: 1.5px solid;
}
.comment.blocking { border-color: var(--rust);  background: #FDECEA; }
.comment.nit      { border-color: var(--gray-300); background: var(--gray-150); }
.comment .comment-label { font-family: var(--mono); font-size: 10px; text-transform: uppercase; letter-spacing: .06em; margin-bottom: 4px; }
.comment.blocking .comment-label { color: var(--rust); }
.comment.nit      .comment-label { color: var(--gray-500); }

/* ── Narrative file section (writeup mode) ── */
.file-section { margin-bottom: 28px; }
.file-section .file-name {
  font-family: var(--mono); font-size: 12px; color: var(--slate);
  background: var(--oat); display: inline-block;
  padding: 3px 10px; border-radius: 4px; margin-bottom: 10px;
}
.file-section p { font-size: 14px; color: var(--gray-700); margin-bottom: 8px; }

/* ── Before/after panels ── */
.before-after { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin: 16px 0; }
.ba-panel { border: 1.5px solid var(--gray-300); border-radius: 8px; overflow: hidden; }
.ba-label {
  font-family: var(--mono); font-size: 10px; text-transform: uppercase; letter-spacing: .07em;
  padding: 6px 12px; background: var(--gray-150); border-bottom: 1px solid var(--gray-300);
}
.ba-label.before { color: var(--rust); }
.ba-label.after  { color: var(--olive); }
.ba-body { padding: 14px; font-size: 13px; color: var(--gray-700); line-height: 1.55; }
pre.ba-code { margin: 0; padding: 14px; background: var(--slate); color: #E8E6DF; font-size: 12px; border-radius: 0; }

/* ── Checklist ── */
.issue-list { list-style: none; padding: 0; }
.issue-list li {
  display: flex; align-items: flex-start; gap: 10px;
  padding: 10px 0; border-bottom: 1px solid var(--gray-150);
  font-size: 14px; color: var(--gray-700);
}
.issue-list li:last-child { border-bottom: none; }
.issue-dot { width: 8px; height: 8px; border-radius: 50%; background: var(--clay); margin-top: 6px; flex-shrink: 0; }
.issue-dot.blocking { background: var(--rust); }
.issue-dot.done     { background: var(--olive); }

/* ── Rollout checklist ── */
.rollout { list-style: none; padding: 0; }
.rollout li {
  display: flex; align-items: center; gap: 12px;
  padding: 10px 0; border-bottom: 1px solid var(--gray-150);
  font-size: 14px;
}
.rollout li:last-child { border-bottom: none; }
.rollout .step { font-family: var(--mono); font-size: 11px; color: var(--gray-500); background: var(--gray-150); padding: 2px 8px; border-radius: 999px; flex-shrink: 0; }

/* ── Footer ── */
.doc-footer {
  margin-top: 56px; padding-top: 18px; border-top: 1px solid var(--gray-300);
  font-size: 12px; color: var(--gray-500); font-family: var(--mono);
  display: flex; justify-content: space-between; flex-wrap: wrap; gap: 8px;
}

@media (max-width: 640px) {
  body { padding: 32px 16px; }
  .risk-map { grid-template-columns: 1fr; }
  .before-after { grid-template-columns: 1fr; }
}
```

---

## Mode A — Writeup template

Use this structure when invoked as `/pr writeup`:

```html
<div class="container">
  <header class="pr-header">
    <div class="eyebrow">Pull Request · [branch-name]</div>
    <h1>[PR title]</h1>
    <div class="pr-meta">
      <span><strong>Files</strong> [N] changed</span>
      <span><strong>Lines</strong> <span style="color:var(--olive)">+[N]</span> <span style="color:var(--rust)">−[N]</span></span>
      <span><strong>Commits</strong> [N]</span>
      <span><strong>Branch</strong> [branch → base]</span>
    </div>
  </header>

  <!-- TL;DR -->
  <div class="tldr">
    <div class="label">TL;DR</div>
    <p>[2–3 sentence summary: what changed, why, what it unlocks]</p>
    <div class="metrics">
      <div class="metric"><strong>[key metric]</strong> improvement</div>
    </div>
  </div>

  <!-- 1. Motivation -->
  <section>
    <h2 class="sec-heading"><span class="sec-num">01</span> Why this change</h2>
    <p>[Before state: what was the problem? Context + pain.]</p>
    <div class="before-after">
      <div class="ba-panel">
        <div class="ba-label before">Before</div>
        <div class="ba-body">[old behavior / code snippet]</div>
      </div>
      <div class="ba-panel">
        <div class="ba-label after">After</div>
        <div class="ba-body">[new behavior / code snippet]</div>
      </div>
    </div>
  </section>

  <!-- 2. File-by-file tour -->
  <section>
    <h2 class="sec-heading"><span class="sec-num">02</span> What changed and why</h2>
    <!-- one .file-section per logical group of files -->
    <div class="file-section">
      <span class="file-name">src/path/to/file.ts</span>
      <p>[What changed in this file and the rationale — the "why", not the "what".]</p>
    </div>
  </section>

  <!-- 3. Review focus -->
  <section>
    <h2 class="sec-heading"><span class="sec-num">03</span> Review focus</h2>
    <ul class="issue-list">
      <li><span class="issue-dot blocking"></span> [Area reviewers should scrutinise most carefully]</li>
      <li><span class="issue-dot"></span> [Secondary concern]</li>
    </ul>
  </section>

  <!-- 4. Test plan -->
  <section>
    <h2 class="sec-heading"><span class="sec-num">04</span> Test plan</h2>
    <ul class="rollout">
      <li><span class="step">Unit</span> [what the unit tests cover]</li>
      <li><span class="step">Integration</span> [integration tests]</li>
      <li><span class="step">Manual</span> [manual QA steps if any]</li>
    </ul>
  </section>

  <footer class="doc-footer">
    <span>Generated from git diff · [branch]</span>
    <span>[date]</span>
  </footer>
</div>
```

---

## Mode B — Review template

Use this structure when invoked as `/pr review`:

```html
<div class="container">
  <header class="pr-header">
    <div class="eyebrow">Code Review · PR #[N]</div>
    <h1>[PR title]</h1>
    <div class="pr-meta">
      <span><strong>Reviewer</strong> [model / agent]</span>
      <span><strong>Files reviewed</strong> [N]</span>
      <span><strong>Date</strong> [date]</span>
    </div>
  </header>

  <!-- Risk map -->
  <section>
    <h2 class="sec-heading"><span class="sec-num">01</span> Risk classification</h2>
    <div class="risk-map">
      <div class="risk-cell safe">
        <div class="risk-label">Safe to merge</div>
        <ul><li>file.ts</li></ul>
      </div>
      <div class="risk-cell medium">
        <div class="risk-label">Review carefully</div>
        <ul><li>auth.ts</li></ul>
      </div>
      <div class="risk-cell blocking">
        <div class="risk-label">Blocking</div>
        <ul><li>migration.sql</li></ul>
      </div>
    </div>
  </section>

  <!-- Annotated diffs — one .file-card per file -->
  <section>
    <h2 class="sec-heading"><span class="sec-num">02</span> File-by-file review</h2>

    <div class="file-card">
      <div class="file-card-header">
        <span class="file-path">src/path/file.ts</span>
        <span class="file-badge modified">modified</span>
        <span class="line-delta"><span class="add">+12</span> <span class="del">−4</span></span>
      </div>
      <!-- diff view -->
      <div class="diff-view">
        <div class="diff-row ctx"><div class="ln">42</div><div class="ln"></div><div class="code"> existing context line</div></div>
        <div class="diff-row del"><div class="ln">43</div><div class="ln"></div><div class="code">-removed line</div></div>
        <div class="diff-row add"><div class="ln"></div><div class="ln">43</div><div class="code">+added line</div></div>
        <div class="diff-row ctx"><div class="ln">44</div><div class="ln">44</div><div class="code"> context</div></div>
      </div>
      <!-- inline comment after a hunk -->
      <div class="comment blocking">
        <div class="comment-label">Blocking</div>
        [What the issue is and what to do instead]
      </div>
    </div>

  </section>

  <!-- Blocking issues summary -->
  <section>
    <h2 class="sec-heading"><span class="sec-num">03</span> Issues to resolve before merge</h2>
    <ul class="issue-list">
      <li><span class="issue-dot blocking"></span> [Blocking issue description + file reference]</li>
      <li><span class="issue-dot"></span> [Non-blocking nit]</li>
    </ul>
  </section>

  <footer class="doc-footer">
    <span>Review of [branch] → [base]</span>
    <span>[date]</span>
  </footer>
</div>
```

---

## Diff rendering rules

- Show **3 lines of context** around each change (`ctx` rows)
- Use left column for old line numbers, right for new; leave blank on added/deleted rows
- Limit each file card to **20 diff rows** — show the most significant hunk; add a note if truncated
- Place `.comment` blocks immediately after the hunk they reference
- Mark `.comment.blocking` for correctness/security issues, `.comment.nit` for style/minor

---

## Full workflow

```
/spec <description> ← define the feature
/plan <spec-path>   ← plan the implementation
./scripts/ralph.sh  ← implement autonomously
/pr writeup         ← generate author narrative HTML (you are here)
/pr review          ← generate annotated review HTML (you are here)
/html <specs/dir/>  ← render spec + plan as styled documents
/diagram <path>     ← visualize architecture
```
