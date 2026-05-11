---
name: html
description: >
  Convert spec.md, plan.md, or research.md (or all three from a specs/<dir>/)
  into self-contained, beautifully styled HTML files. Produces *.html alongside
  the source markdown files with no external dependencies.
---

# HTML — Document Renderer

You are converting spec/plan/research markdown documents into polished, self-contained HTML
artifacts. The output must be a single `.html` file with all CSS inlined — no CDN links, no
external fonts, no JavaScript required. The result should look like a professional design document.

## When invoked as `/html <path>`

`<path>` can be:
- A specs directory: `specs/20260511-csv-export/` → render research.html, spec.html, and plan.html (skip any that don't exist)
- A specific file: `specs/20260511-csv-export/spec.md` → render only spec.html
- A specific file: `specs/20260511-csv-export/plan.md` → render only plan.html
- A specific file: `specs/20260511-csv-export/research.md` → render only research.html

Steps:

1. **Read the source file(s)** completely.

2. **Generate the HTML** using the design system and component mapping below. Map markdown
   sections to HTML semantics — do not dump raw markdown into the HTML. Render tables as
   `<table>`, checkboxes as styled items, code blocks as `<pre><code>`, etc.

3. **Write the output** to `<same-dir>/<filename>.html` (e.g. `spec.md` → `spec.html`).

4. **Tell the user** the output path(s) and that the files can be opened in any browser.

---

## Design system

Embed this CSS verbatim in every generated `<style>` block:

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
  background: var(--ivory);
  color: var(--gray-700);
  font-family: var(--sans);
  font-size: 15px;
  line-height: 1.6;
  padding: 56px 32px;
}

.container { max-width: 900px; margin: 0 auto; }

/* ── Header ── */
.doc-header { margin-bottom: 48px; border-bottom: 1.5px solid var(--gray-300); padding-bottom: 32px; }
.doc-header h1 { font-family: var(--serif); font-size: 2.2rem; color: var(--slate); line-height: 1.15; margin-bottom: 12px; }
.doc-meta { display: flex; gap: 24px; flex-wrap: wrap; font-size: 13px; color: var(--gray-500); font-family: var(--mono); }
.doc-meta span strong { color: var(--gray-700); }
.badge { display: inline-block; background: var(--oat); color: var(--slate); font-family: var(--mono); font-size: 11px; padding: 2px 8px; border-radius: 4px; }
.badge.draft   { background: var(--oat); }
.badge.approved { background: #D4EDDA; color: #155724; }

/* ── Sections ── */
section { margin-bottom: 48px; }
.section-heading {
  display: flex; align-items: center; gap: 12px;
  font-family: var(--serif); font-size: 1.3rem; color: var(--slate);
  margin-bottom: 20px; padding-bottom: 10px;
  border-bottom: 1.5px solid var(--gray-300);
}
.section-heading .num {
  font-family: var(--mono); font-size: 11px;
  background: var(--oat); color: var(--gray-500);
  padding: 3px 8px; border-radius: 4px; flex-shrink: 0;
}
h3 { font-family: var(--serif); font-size: 1rem; color: var(--slate); margin: 20px 0 8px; }

/* ── Prose ── */
p { margin-bottom: 12px; }
strong { color: var(--slate); }

/* ── Tables ── */
table { width: 100%; border-collapse: collapse; font-size: 14px; margin: 16px 0; }
th {
  background: var(--gray-150); color: var(--slate);
  font-family: var(--mono); font-size: 11px; text-transform: uppercase; letter-spacing: .05em;
  padding: 8px 12px; text-align: left; border: 1px solid var(--gray-300);
}
td { padding: 9px 12px; border: 1px solid var(--gray-300); vertical-align: top; }
tr:nth-child(even) td { background: var(--gray-150); }
code { font-family: var(--mono); font-size: 12px; background: var(--oat); padding: 1px 5px; border-radius: 3px; color: var(--slate); }

/* ── Code blocks ── */
pre {
  background: var(--slate); color: #E8E6DF;
  font-family: var(--mono); font-size: 13px; line-height: 1.65;
  padding: 20px 24px; border-radius: 8px; overflow-x: auto; margin: 16px 0;
}
pre code { background: none; padding: 0; color: inherit; font-size: inherit; }

/* ── Lists ── */
ul, ol { padding-left: 20px; margin: 8px 0 12px; }
li { margin-bottom: 6px; }
li::marker { color: var(--clay); }

/* ── Requirement list (REQ-NNN items) ── */
.req-list { list-style: none; padding: 0; }
.req-list li {
  display: flex; gap: 12px; align-items: flex-start;
  padding: 10px 14px; border: 1px solid var(--gray-300);
  border-radius: 6px; margin-bottom: 8px; background: var(--white);
}
.req-list li .req-id {
  font-family: var(--mono); font-size: 11px; color: var(--gray-500);
  background: var(--gray-150); padding: 2px 6px; border-radius: 3px;
  flex-shrink: 0; margin-top: 1px;
}

/* ── Checklist (success criteria) ── */
.checklist { list-style: none; padding: 0; }
.checklist li {
  display: flex; align-items: flex-start; gap: 10px;
  padding: 8px 0; border-bottom: 1px solid var(--gray-150);
}
.checklist li:last-child { border-bottom: none; }
.check-box {
  width: 16px; height: 16px; border: 1.5px solid var(--gray-300);
  border-radius: 3px; flex-shrink: 0; margin-top: 2px;
  display: flex; align-items: center; justify-content: center; font-size: 10px;
}
.check-box.done { background: var(--olive); border-color: var(--olive); color: white; }

/* ── Implementation task list ── */
.task-list { list-style: none; padding: 0; }
.task-list li {
  display: flex; gap: 16px; align-items: flex-start;
  padding: 12px 0; border-bottom: 1px solid var(--gray-150);
}
.task-list li:last-child { border-bottom: none; }
.task-num {
  font-family: var(--mono); font-size: 12px; color: var(--white);
  background: var(--clay); width: 24px; height: 24px; border-radius: 50%;
  display: flex; align-items: center; justify-content: center; flex-shrink: 0; margin-top: 1px;
}
.task-parallel .task-num { background: var(--olive); }
.task-parallel::after {
  content: 'PARALLEL'; font-family: var(--mono); font-size: 10px;
  color: var(--olive); background: #EBF0E4; padding: 1px 5px; border-radius: 3px;
  align-self: center; margin-left: auto; flex-shrink: 0;
}

/* ── Research: finding cards ── */
.finding-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 16px; margin: 16px 0; }
.finding-card {
  border: 1.5px solid var(--gray-300); border-radius: 8px;
  padding: 16px; background: var(--white);
}
.finding-card .area {
  font-family: var(--mono); font-size: 11px; color: var(--clay);
  text-transform: uppercase; letter-spacing: .06em; margin-bottom: 8px;
}
.finding-card h4 { font-family: var(--serif); font-size: .95rem; color: var(--slate); margin-bottom: 6px; }
.finding-card p { font-size: 13px; color: var(--gray-700); margin: 0; }

/* ── Research: source chip ── */
.source-chips { display: flex; flex-wrap: wrap; gap: 6px; margin: 12px 0; }
.source-chip {
  font-family: var(--mono); font-size: 11px; color: var(--gray-700);
  background: var(--gray-150); border: 1px solid var(--gray-300);
  padding: 3px 10px; border-radius: 999px;
}

/* ── Callout ── */
.callout {
  border-left: 3px solid var(--clay); background: var(--gray-150);
  padding: 12px 16px; border-radius: 0 6px 6px 0; font-size: 13px; margin: 12px 0;
}

/* ── Risk severity ── */
.risk-high   { color: var(--rust);  font-weight: 600; }
.risk-medium { color: var(--clay);  font-weight: 600; }
.risk-low    { color: var(--olive); font-weight: 600; }

/* ── Footer ── */
.doc-footer {
  margin-top: 64px; padding-top: 20px; border-top: 1px solid var(--gray-300);
  font-size: 12px; color: var(--gray-500); font-family: var(--mono);
  display: flex; justify-content: space-between; flex-wrap: wrap; gap: 8px;
}

@media (max-width: 640px) {
  body { padding: 32px 16px; }
  .doc-meta { flex-direction: column; gap: 6px; }
  .finding-grid { grid-template-columns: 1fr; }
  .doc-footer { flex-direction: column; }
}
```

---

## HTML skeleton

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Document title]</title>
  <style>/* full CSS above */</style>
</head>
<body>
  <div class="container">
    <header class="doc-header">
      <h1>[Title]</h1>
      <div class="doc-meta">
        <span><strong>ID</strong> [id]</span>
        <span><strong>Status</strong> <span class="badge draft">Draft</span></span>
        <span><strong>Created</strong> [date]</span>
      </div>
    </header>

    <!-- one <section> per ## heading, numbered badges 01, 02, … -->

    <footer class="doc-footer">
      <span>Generated from [source-filename]</span>
      <span>[today's date]</span>
    </footer>
  </div>
</body>
</html>
```

---

## Markdown → HTML element mapping

| Markdown element | HTML to emit |
|---|---|
| `## Section heading` | `<section><h2 class="section-heading"><span class="num">01</span> Title</h2>…</section>` — increment badge |
| `### Subsection` | `<h3>` |
| `- REQ-001: text` or `- NFR-001: text` | `<ul class="req-list"><li><span class="req-id">REQ-001</span> text</li>` |
| `- [ ] criterion` | `<ul class="checklist"><li><div class="check-box"></div> text</li>` |
| `- [x] criterion` | same with `<div class="check-box done">✓</div>` |
| Numbered tasks `1. Task` | `<ol class="task-list"><li><div class="task-num">1</div><div>text</div></li>` |
| `[PARALLEL]` in a task | add class `task-parallel` to the `<li>` |
| `[NEEDS CLARIFICATION]` | wrap content in `<div class="callout">` |
| Risk table — Likelihood/Impact | apply `.risk-high`, `.risk-medium`, `.risk-low` classes to cells |
| Inline `code` | `<code>` |
| Fenced code block | `<pre><code>` |
| Pipe table | `<table>` with `<th>` / `<td>` |
| Paragraph | `<p>` |
| Bullet list (non-REQ) | `<ul><li>` |

### Research.md specific mapping

research.md typically has sections for each investigation area. Render them as:
- Investigation area headings → finding cards inside `.finding-grid`
- Each finding card gets the area name in `.area`, a summary `<h4>`, and detail `<p>`
- Source files or references → `.source-chips` row of `.source-chip` pills
- Key insight bullet points remain as `<ul>` inside each card

---

## Full workflow

```
/research <topic>   ← optional: spawn parallel agents first → research.md
/spec <description> ← define WHAT and WHY → spec.md
/plan <spec-path>   ← define HOW → plan.md
/html <specs/dir/>  ← render all three as HTML (you are here)
/diagram <path>     ← generate architecture or flow diagram
/slides <path>      ← render spec or plan as a slide deck
/tasks <spec-path>  ← generate PRD.md for the ralph loop
./scripts/ralph.sh  ← execute tasks autonomously
```
