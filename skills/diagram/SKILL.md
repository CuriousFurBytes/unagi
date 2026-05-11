---
name: diagram
description: >
  Generate a self-contained SVG-based HTML diagram from a spec, plan, codebase path,
  or freeform description. Produces architecture maps, data-flow diagrams, and
  process flowcharts — all as standalone HTML files with no external dependencies.
---

# Diagram — Visual Architecture Generator

You are generating a diagram as a self-contained HTML file. The output must work in any browser
with no external dependencies. Use SVG for all shapes, arrows, and labels. The result should
communicate structure, flow, or dependencies with clear spatial layout and semantic color coding.

## When invoked as `/diagram <target>`

`<target>` can be:
- A specs directory or plan file: `specs/20260511-csv-export/plan.md` → generate a data-flow or implementation-order diagram
- A source directory: `src/auth/` → generate a module dependency map
- A freeform description: `/diagram the deploy pipeline: code push → CI → staging → canary → prod`

Steps:

1. **Understand the domain** — read any referenced files; if given a directory, scan for key modules and imports.
2. **Choose the right diagram type** (see below).
3. **Plan the layout** on paper mentally: identify nodes, edges, hierarchy levels.
4. **Generate the HTML** using the design system and SVG rules below.
5. **Write the output**:
   - If derived from a specs file: write to `specs/<dir>/diagram.html`
   - If derived from a source directory: write to `<dir>/diagram.html`
   - If freeform: write to `diagram.html` in the current directory
6. **Tell the user** the output path.

---

## Diagram types

| Trigger | Diagram type | Description |
|---|---|---|
| plan.md / implementation order | **Flow** | Ordered steps with decision points and parallel branches |
| source directory / module map | **Architecture** | Box-and-arrow module dependency map |
| spec.md data models / API | **Data flow** | Entities, relationships, and data movement |
| freeform process description | **Flow** | Generic left-to-right or top-to-bottom process |

When uncertain, default to a top-to-bottom flow diagram.

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
  --serif: ui-serif, Georgia, 'Times New Roman', serif;
  --sans:  system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
  --mono:  ui-monospace, 'SF Mono', Menlo, Monaco, monospace;
}

body {
  background: var(--ivory);
  font-family: var(--sans);
  font-size: 15px;
  padding: 40px 24px;
}

.page { max-width: 1100px; margin: 0 auto; }

/* ── Header ── */
.diagram-header { margin-bottom: 32px; }
.diagram-header h1 { font-family: var(--serif); font-size: 1.6rem; color: var(--slate); margin-bottom: 6px; }
.diagram-header p  { font-size: 13px; color: var(--gray-500); font-family: var(--mono); }

/* ── Layout: diagram + side panel ── */
.layout { display: grid; grid-template-columns: minmax(0, 1fr) 280px; gap: 32px; align-items: start; }
.layout.no-panel { grid-template-columns: 1fr; }

/* ── SVG container ── */
.diagram-wrap {
  background: var(--white, #fff); border: 1.5px solid var(--gray-300);
  border-radius: 12px; padding: 24px; overflow-x: auto;
}
svg { display: block; width: 100%; height: auto; }

/* ── Side panel ── */
.panel {
  position: sticky; top: 24px;
  background: var(--white, #fff); border: 1.5px solid var(--gray-300);
  border-radius: 12px; padding: 20px;
}
.panel h3 { font-family: var(--serif); font-size: 1rem; color: var(--slate); margin-bottom: 12px; }
.panel-title { font-family: var(--mono); font-size: 12px; color: var(--clay); text-transform: uppercase; letter-spacing: .06em; margin-bottom: 4px; }
.panel-body  { font-size: 13px; color: var(--gray-700); line-height: 1.55; }
.panel-meta  { margin-top: 10px; font-family: var(--mono); font-size: 11px; color: var(--gray-500); }
.panel-empty { color: var(--gray-500); font-size: 13px; font-style: italic; }

/* ── Legend ── */
.legend { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 20px; font-size: 12px; color: var(--gray-700); }
.legend-item { display: flex; align-items: center; gap: 6px; }
.legend-swatch { width: 14px; height: 14px; border-radius: 3px; border: 1.5px solid; }

/* ── Footer ── */
.diagram-footer {
  margin-top: 32px; padding-top: 16px; border-top: 1px solid var(--gray-300);
  font-size: 12px; color: var(--gray-500); font-family: var(--mono);
  display: flex; justify-content: space-between; flex-wrap: wrap; gap: 8px;
}

@media (max-width: 780px) {
  .layout { grid-template-columns: 1fr; }
  .panel { position: static; }
}
```

---

## SVG drawing rules

### Arrow markers — define once in `<defs>`:

```svg
<defs>
  <!-- default gray arrow -->
  <marker id="arrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
    <path d="M0,0 L0,6 L8,3 z" fill="#D1CFC5"/>
  </marker>
  <!-- success / parallel path -->
  <marker id="arrow-olive" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
    <path d="M0,0 L0,6 L8,3 z" fill="#788C5D"/>
  </marker>
  <!-- failure / error path -->
  <marker id="arrow-rust" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
    <path d="M0,0 L0,6 L8,3 z" fill="#C0392B"/>
  </marker>
</defs>
```

### Node shapes:

| Node type | SVG shape | Fill | Stroke |
|---|---|---|---|
| Default process | `<rect rx="8">` | `#FAF9F5` | `#D1CFC5` / 1.5px |
| Start / end terminal | `<rect rx="22">` | `#E3DACC` | `#D1CFC5` / 1.5px |
| Decision (yes/no) | `<polygon>` diamond | `#FAF9F5` | `#D1CFC5` / 1.5px |
| Active / highlighted | `<rect rx="8">` | `#FAF9F5` | `#D97757` / 2px |
| Success state | `<rect rx="8">` | `#EBF0E4` | `#788C5D` / 1.5px |
| Error / failure | `<rect rx="8">` | `#FDECEA` | `#C0392B` / 1.5px |
| External system | `<rect rx="4">` | `#F0EEE6` | `#D1CFC5` / 1px, dashed |

### Text in nodes:

```svg
<text x="[cx]" y="[cy]" text-anchor="middle" dominant-baseline="middle"
      font-family="system-ui, sans-serif" font-size="13" fill="#3D3D3A">Label</text>
<!-- Sub-label (smaller, gray) -->
<text x="[cx]" y="[cy+16]" text-anchor="middle" dominant-baseline="middle"
      font-family="ui-monospace, monospace" font-size="10" fill="#87867F">sublabel</text>
```

### Edges / arrows:

```svg
<!-- straight line -->
<line x1="300" y1="100" x2="300" y2="150" stroke="#D1CFC5" stroke-width="1.5" marker-end="url(#arrow)"/>

<!-- curved path (use for bypass / error routes) -->
<path d="M300,200 C190,200 190,340 300,340" fill="none" stroke="#C0392B"
      stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrow-rust)"/>

<!-- edge label -->
<text x="[midpoint-x]" y="[midpoint-y]" text-anchor="middle"
      font-family="ui-monospace, monospace" font-size="10" fill="#87867F">yes</text>
```

### Diamond (decision) node:

```svg
<!-- Diamond centered at cx,cy with half-width hw and half-height hh -->
<polygon points="[cx],[cy-hh] [cx+hw],[cy] [cx],[cy+hh] [cx-hw],[cy]"
         fill="#FAF9F5" stroke="#D1CFC5" stroke-width="1.5"/>
```

### Click-to-detail interaction (include when diagram has a side panel):

```html
<script>
const DETAILS = {
  "node-id": {
    title: "Node Name",
    meta: "type · estimated time",
    body: "What this node does and why it exists."
  }
  // …
};
document.querySelectorAll('[data-k]').forEach(el => {
  el.style.cursor = 'pointer';
  el.addEventListener('click', () => {
    document.querySelectorAll('[data-k]').forEach(n => n.classList.remove('active'));
    el.classList.add('active');
    const d = DETAILS[el.dataset.k] || {};
    document.getElementById('panel-title').textContent = d.title || '';
    document.getElementById('panel-meta').textContent  = d.meta  || '';
    document.getElementById('panel-body').textContent  = d.body  || '';
    document.getElementById('panel-empty').style.display = 'none';
  });
});
</script>
```

- Attach `data-k="node-id"` to every clickable `<g>` wrapper.
- Give the active stroke state via CSS: `[data-k].active rect, [data-k].active polygon { stroke: #D97757; stroke-width: 2; }`

---

## HTML skeleton

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Diagram title]</title>
  <style>/* full CSS above */</style>
</head>
<body>
  <div class="page">
    <header class="diagram-header">
      <h1>[Title]</h1>
      <p>Generated from [source] · [date]</p>
    </header>

    <div class="layout">  <!-- add class="no-panel" if no side panel needed -->
      <div class="diagram-wrap">
        <svg viewBox="0 0 [width] [height]" xmlns="http://www.w3.org/2000/svg">
          <defs><!-- arrow markers --></defs>
          <!-- nodes and edges -->
        </svg>
      </div>

      <!-- omit aside if layout has class no-panel -->
      <aside class="panel">
        <h3>Details</h3>
        <div class="panel-title"  id="panel-title"></div>
        <div class="panel-meta"   id="panel-meta"></div>
        <div class="panel-body"   id="panel-body"></div>
        <p   class="panel-empty"  id="panel-empty">Click any node to see details.</p>
      </aside>
    </div>

    <div class="legend">
      <!-- one .legend-item per node type used in this diagram -->
    </div>

    <footer class="diagram-footer">
      <span>Generated from [source]</span>
      <span>[date]</span>
    </footer>
  </div>
  <script>/* click-to-detail JS if side panel is present */</script>
</body>
</html>
```

---

## Layout guidelines

- **Top-to-bottom** for process flows and implementation order (x centered around 300–400, y increments of 80–120px)
- **Left-to-right** for data flows and pipelines (y centered around 200–400, x increments of 160–200px)
- **Radial / cluster** for module maps (central hub, satellites around it)
- Standard node size: 180×44px (process), 160×36px (terminal), diamond half-width 80, half-height 28
- Minimum SVG viewBox width: 600; height: as needed (add 80px top/bottom padding)
- Use `data-k` groups and side panel for diagrams with more than 6 nodes
- Skip side panel (`class="layout no-panel"`) for simple ≤6 node diagrams

---

## Full workflow

```
/research <topic>   ← investigate
/spec <description> ← define WHAT and WHY
/plan <spec-path>   ← define HOW
/diagram <path>     ← visualize architecture or process (you are here)
/html <specs/dir/>  ← render spec + plan as styled documents
/slides <path>      ← turn spec or plan into a slide deck
/tasks <spec-path>  ← generate PRD.md for the ralph loop
./scripts/ralph.sh  ← execute tasks autonomously
```
