---
name: html
description: >
  Convert a spec.md or plan.md (or both from a specs/<dir>/) into a self-contained,
  beautifully styled HTML file. Produces spec.html and/or plan.html alongside
  the source markdown files with no external dependencies.
---

# HTML — Document Renderer

You are converting spec/plan markdown documents into polished, self-contained HTML artifacts.
The output must be a single `.html` file with all CSS inlined — no CDN links, no external fonts,
no JavaScript. The result should look like a professional design document.

## When invoked as `/html <path>`

`<path>` can be:
- A specs directory: `specs/20260511-csv-export/` → render both spec.html and plan.html
- A specific file: `specs/20260511-csv-export/spec.md` → render only spec.html
- A specific file: `specs/20260511-csv-export/plan.md` → render only plan.html

Steps:

1. **Read the source file(s)** completely.

2. **Generate the HTML** using the design system below. Map markdown sections to HTML
   semantics precisely — do not dump raw markdown into the HTML. Render tables as `<table>`,
   checkboxes as styled `<ul>` items, code blocks as `<pre><code>`, etc.

3. **Write the output** to `<same-dir>/<filename>.html` (e.g. `spec.md` → `spec.html`).

4. **Tell the user** the output path(s) and that the files can be opened in any browser.

---

## Design system

Embed this CSS verbatim in every generated `<style>` block (adapt to content, do not omit):

```css
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --ivory:    #FAF9F5;
  --slate:    #141413;
  --clay:     #D97757;
  --oat:      #E3DACC;
  --olive:    #788C5D;
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

/* Header */
.doc-header { margin-bottom: 48px; border-bottom: 1.5px solid var(--gray-300); padding-bottom: 32px; }
.doc-header h1 { font-family: var(--serif); font-size: 2.2rem; color: var(--slate); line-height: 1.15; margin-bottom: 12px; }
.doc-meta { display: flex; gap: 24px; flex-wrap: wrap; font-size: 13px; color: var(--gray-500); font-family: var(--mono); }
.doc-meta span strong { color: var(--gray-700); }
.badge { display: inline-block; background: var(--oat); color: var(--slate); font-family: var(--mono); font-size: 11px; padding: 2px 8px; border-radius: 4px; }

/* Sections */
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

/* Prose */
p { margin-bottom: 12px; }
strong { color: var(--slate); }

/* Tables */
table { width: 100%; border-collapse: collapse; font-size: 14px; margin: 16px 0; }
th {
  background: var(--gray-150); color: var(--slate);
  font-family: var(--mono); font-size: 11px; text-transform: uppercase; letter-spacing: .05em;
  padding: 8px 12px; text-align: left; border: 1px solid var(--gray-300);
}
td { padding: 9px 12px; border: 1px solid var(--gray-300); vertical-align: top; }
tr:nth-child(even) td { background: var(--gray-150); }
code { font-family: var(--mono); font-size: 12px; background: var(--oat); padding: 1px 5px; border-radius: 3px; color: var(--slate); }

/* Code blocks */
pre {
  background: var(--slate); color: #E8E6DF;
  font-family: var(--mono); font-size: 13px; line-height: 1.65;
  padding: 20px 24px; border-radius: 8px; overflow-x: auto;
  margin: 16px 0;
}
pre code { background: none; padding: 0; color: inherit; font-size: inherit; }

/* Lists */
ul, ol { padding-left: 20px; margin: 8px 0 12px; }
li { margin-bottom: 6px; }
li::marker { color: var(--clay); }

/* Requirement list */
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

/* Checklist */
.checklist { list-style: none; padding: 0; }
.checklist li {
  display: flex; align-items: flex-start; gap: 10px;
  padding: 8px 0; border-bottom: 1px solid var(--gray-150);
}
.checklist li:last-child { border-bottom: none; }
.check-box {
  width: 16px; height: 16px; border: 1.5px solid var(--gray-300);
  border-radius: 3px; flex-shrink: 0; margin-top: 2px;
  display: flex; align-items: center; justify-content: center;
}
.check-box.done { background: var(--olive); border-color: var(--olive); color: white; font-size: 10px; }

/* Ordered tasks */
.task-list { list-style: none; padding: 0; counter-reset: task; }
.task-list li {
  display: flex; gap: 16px; align-items: flex-start;
  padding: 12px 0; border-bottom: 1px solid var(--gray-150);
  counter-increment: task;
}
.task-list li:last-child { border-bottom: none; }
.task-num {
  font-family: var(--mono); font-size: 12px; color: var(--white);
  background: var(--clay); width: 24px; height: 24px; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0; margin-top: 1px;
}
.task-parallel .task-num { background: var(--olive); }

/* Callout box */
.callout {
  border-left: 3px solid var(--clay); background: var(--gray-150);
  padding: 12px 16px; border-radius: 0 6px 6px 0;
  font-size: 13px; margin: 12px 0;
}

/* Risk severity */
.risk-high   { color: #C0392B; font-weight: 600; }
.risk-medium { color: #D97757; font-weight: 600; }
.risk-low    { color: var(--olive); font-weight: 600; }

/* Footer */
.doc-footer {
  margin-top: 64px; padding-top: 20px; border-top: 1px solid var(--gray-300);
  font-size: 12px; color: var(--gray-500); font-family: var(--mono);
  display: flex; justify-content: space-between; flex-wrap: wrap; gap: 8px;
}

@media (max-width: 640px) {
  body { padding: 32px 16px; }
  .doc-meta { flex-direction: column; gap: 6px; }
  .doc-footer { flex-direction: column; }
}
```

---

## HTML structure rules

Use this skeleton for every document:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Document title]</title>
  <style>
    /* paste full CSS here */
  </style>
</head>
<body>
  <div class="container">

    <header class="doc-header">
      <h1>[Title from # heading]</h1>
      <div class="doc-meta">
        <span><strong>ID</strong> [SPEC/PLAN-ID]</span>
        <span><strong>Status</strong> <span class="badge">[Draft / Approved]</span></span>
        <span><strong>Created</strong> [date]</span>
      </div>
    </header>

    <!-- One <section> per ## heading -->
    <section>
      <h2 class="section-heading"><span class="num">01</span> Section Title</h2>
      <!-- section content -->
    </section>

    <footer class="doc-footer">
      <span>Generated from [source-file]</span>
      <span>[date]</span>
    </footer>

  </div>
</body>
</html>
```

### Mapping markdown → HTML

| Markdown element | HTML rendering |
|---|---|
| `## Section` | `<section>` with `.section-heading` + incrementing `.num` badge |
| `### Subsection` | `<h3>` |
| `- REQ-001: text` requirement list | `<ul class="req-list">` with `.req-id` span |
| `- [ ] criterion` checklist | `<ul class="checklist">` with `.check-box` div |
| `- [x] criterion` checked | `.check-box.done` with ✓ |
| Numbered implementation tasks | `<ol class="task-list">` with `.task-num` circles |
| `[PARALLEL]` task | add `.task-parallel` to the `<li>` |
| `[NEEDS CLARIFICATION]` | wrap in `.callout` |
| Risk table — Likelihood/Impact | apply `.risk-high`, `.risk-medium`, `.risk-low` classes |
| Inline `code` | `<code>` |
| Fenced code block | `<pre><code>` |
| Pipe table | `<table>` with `<th>` / `<td>` |
| Plain paragraph | `<p>` |

---

## Full workflow

```
/research <topic>   ← optional: spawn parallel agents first
/spec <description> ← define WHAT and WHY → produces spec.md
/plan <spec-path>   ← define HOW → produces plan.md
/html <specs/dir/>  ← render both as HTML (you are here)
/tasks <spec-path>  ← generate PRD.md for the ralph loop
./scripts/ralph.sh  ← execute tasks autonomously
```
