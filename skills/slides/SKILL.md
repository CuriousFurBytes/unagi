---
name: slides
description: >
  Turn a spec.md or plan.md into a keyboard-navigable HTML slide deck. Each major
  section becomes a slide. Produces a self-contained slides.html with no external
  dependencies — open in any browser, present from the terminal.
---

# Slides — Presentation Generator

You are converting a spec or plan document into a polished, keyboard-navigable slide deck.
The output is a single self-contained `.html` file. Arrow keys and spacebar advance slides.
The deck should feel like a design-review presentation: minimal, visual, high-signal.

## When invoked as `/slides <path>`

`<path>` can be:
- A spec file: `specs/20260511-csv-export/spec.md` → produces `specs/20260511-csv-export/slides.html`
- A plan file: `specs/20260511-csv-export/plan.md` → produces `specs/20260511-csv-export/slides.html`
- A specs directory: `specs/20260511-csv-export/` → reads both spec.md and plan.md, produces one combined deck

Steps:

1. **Read the source file(s)** completely.
2. **Draft the slide outline** — extract the highest-signal content from each section (see slide mapping below). A deck should have 5–10 slides; trim aggressively.
3. **Generate the HTML** using the design system and slide rules below.
4. **Write the output** to `<same-dir>/slides.html`.
5. **Tell the user** the output path and keyboard controls: ← → Space to navigate, F for fullscreen.

---

## Slide mapping

### From spec.md

| Spec section | Slide content |
|---|---|
| Title + problem statement | **Cover slide**: feature name + one-sentence problem statement |
| Actors | **Who** slide: actor table or visual role cards |
| User stories | **Stories** slide: 2–4 most important stories as large-text bullets |
| Functional requirements | **Requirements** slide: REQ-NNN list (cap at 8, group if more) |
| Non-functional requirements | Merge into Requirements slide or omit if few |
| Constraints | **Constraints** slide: 3–5 key constraints as bold bullets |
| Success criteria | **Definition of Done** slide: checkbox list |
| Open questions | **Open questions** slide (only if ≥ 2 unresolved items) |

### From plan.md

| Plan section | Slide content |
|---|---|
| Technical approach | **Approach** slide: 2–4 sentence strategy summary |
| Files to change | **Scope** slide: file count + change-type breakdown as a simple table or chips |
| Architecture decisions | **Key decisions** slide: 2–4 decision cards (choice + one-line rationale) |
| Data & API contracts | **API** slide (only if non-trivial contracts exist) |
| Risks & mitigations | **Risks** slide: top 3 risks with severity chips |
| Implementation order | **Roadmap** slide: numbered steps, parallel tasks highlighted |

### Combined deck order (spec + plan)

Cover → Who → Stories → Requirements → Approach → Key Decisions → Risks → Roadmap → Done

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

html, body { height: 100%; overflow: hidden; background: var(--slate); }

/* ── Slides container ── */
.deck {
  height: 100vh;
  overflow-y: scroll;
  scroll-snap-type: y mandatory;
  scrollbar-width: none;
}
.deck::-webkit-scrollbar { display: none; }

/* ── Individual slide ── */
.slide {
  height: 100vh;
  scroll-snap-align: start;
  display: flex; flex-direction: column; justify-content: center;
  padding: 64px 80px;
  background: var(--ivory);
  position: relative;
}

/* ── Slide variants ── */
.slide.cover {
  background: var(--slate); color: var(--ivory);
  justify-content: flex-end; padding-bottom: 80px;
}
.slide.invert {
  background: var(--oat);
}
.slide.dark {
  background: var(--gray-700); color: var(--ivory);
}

/* ── Slide counter ── */
.slide::after {
  content: attr(data-n) " / " attr(data-total);
  position: absolute; bottom: 28px; right: 36px;
  font-family: var(--mono); font-size: 11px; color: var(--gray-500);
}
.slide.cover::after { color: var(--gray-500); }

/* ── Progress bar ── */
.progress {
  position: fixed; top: 0; left: 0; height: 3px;
  background: var(--clay); width: 0%;
  transition: width 200ms ease; z-index: 100;
}

/* ── Typography ── */
.eyebrow {
  font-family: var(--mono); font-size: 11px; letter-spacing: .08em;
  text-transform: uppercase; color: var(--clay); margin-bottom: 16px;
}
.slide.cover .eyebrow { color: var(--gray-500); }

h1 { font-family: var(--serif); font-size: clamp(2rem, 5vw, 3.5rem); line-height: 1.1; color: var(--slate); margin-bottom: 20px; }
.slide.cover h1 { color: var(--ivory); }

h2 { font-family: var(--serif); font-size: clamp(1.4rem, 3vw, 2rem); color: var(--slate); margin-bottom: 24px; line-height: 1.2; }
.slide.invert h2, .slide.dark h2 { color: var(--slate); }
.slide.dark h2 { color: var(--ivory); }

.lead { font-size: clamp(1rem, 2vw, 1.25rem); color: var(--gray-500); max-width: 640px; line-height: 1.55; }
.slide.cover .lead { color: var(--gray-300); }

/* ── Content components ── */

/* bullet list */
.bullet-list { list-style: none; padding: 0; max-width: 680px; }
.bullet-list li {
  display: flex; align-items: flex-start; gap: 14px;
  font-size: clamp(1rem, 1.8vw, 1.15rem); color: var(--gray-700);
  padding: 10px 0; border-bottom: 1px solid var(--gray-150);
  line-height: 1.4;
}
.bullet-list li:last-child { border-bottom: none; }
.bullet-list li::before { content: '—'; color: var(--clay); font-weight: 700; flex-shrink: 0; margin-top: 1px; }

/* requirement chips */
.req-chips { display: flex; flex-wrap: wrap; gap: 8px; max-width: 760px; }
.req-chip {
  display: flex; align-items: center; gap: 8px;
  background: var(--white, #fff); border: 1.5px solid var(--gray-300);
  border-radius: 6px; padding: 8px 14px; font-size: 13px; color: var(--gray-700);
}
.req-chip .id { font-family: var(--mono); font-size: 10px; color: var(--gray-500); background: var(--gray-150); padding: 2px 6px; border-radius: 3px; }

/* decision cards */
.decision-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 16px; max-width: 860px; }
.decision-card { background: var(--white, #fff); border: 1.5px solid var(--gray-300); border-radius: 10px; padding: 18px; }
.decision-card .label { font-family: var(--mono); font-size: 10px; text-transform: uppercase; letter-spacing: .07em; color: var(--gray-500); margin-bottom: 6px; }
.decision-card .choice { font-family: var(--serif); font-size: 1.05rem; color: var(--slate); margin-bottom: 6px; }
.decision-card .why { font-size: 12px; color: var(--gray-700); line-height: 1.5; }

/* risk table */
.risk-table { width: 100%; max-width: 700px; border-collapse: collapse; font-size: 14px; }
.risk-table th { font-family: var(--mono); font-size: 10px; text-transform: uppercase; letter-spacing: .05em; color: var(--gray-500); padding: 6px 12px; text-align: left; border-bottom: 1.5px solid var(--gray-300); }
.risk-table td { padding: 10px 12px; border-bottom: 1px solid var(--gray-150); color: var(--gray-700); }
.sev { font-family: var(--mono); font-size: 11px; padding: 2px 8px; border-radius: 999px; font-weight: 600; }
.sev.high   { background: #FDECEA; color: var(--rust); }
.sev.medium { background: #FDF0EB; color: var(--clay); }
.sev.low    { background: #EBF0E4; color: var(--olive); }

/* checklist */
.check-list { list-style: none; padding: 0; max-width: 640px; }
.check-list li {
  display: flex; align-items: flex-start; gap: 12px;
  padding: 10px 0; border-bottom: 1px solid var(--gray-150);
  font-size: 1rem; color: var(--gray-700);
}
.check-list li:last-child { border-bottom: none; }
.chk { width: 18px; height: 18px; border: 1.5px solid var(--gray-300); border-radius: 4px; flex-shrink: 0; margin-top: 2px; }

/* roadmap steps */
.roadmap { list-style: none; padding: 0; max-width: 680px; }
.roadmap li { display: flex; gap: 16px; align-items: flex-start; padding: 12px 0; border-bottom: 1px solid var(--gray-150); }
.roadmap li:last-child { border-bottom: none; }
.step-num { width: 28px; height: 28px; border-radius: 50%; background: var(--clay); color: #fff; font-family: var(--mono); font-size: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.step-num.parallel { background: var(--olive); }
.step-text { font-size: 14px; color: var(--gray-700); padding-top: 4px; }

/* actor cards */
.actor-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 12px; max-width: 760px; }
.actor-card { background: var(--white, #fff); border: 1.5px solid var(--gray-300); border-radius: 8px; padding: 14px; }
.actor-card .role { font-family: var(--mono); font-size: 10px; text-transform: uppercase; letter-spacing: .06em; color: var(--clay); margin-bottom: 4px; }
.actor-card .name { font-family: var(--serif); font-size: .95rem; color: var(--slate); }
.actor-card .desc { font-size: 12px; color: var(--gray-500); margin-top: 4px; }

@media (max-width: 640px) {
  .slide { padding: 40px 24px; }
  .decision-grid { grid-template-columns: 1fr; }
  .actor-grid { grid-template-columns: 1fr 1fr; }
}
```

---

## JavaScript (keyboard navigation + progress bar)

Include this script verbatim at the end of `<body>`:

```html
<script>
(function() {
  const deck   = document.querySelector('.deck');
  const slides = Array.from(document.querySelectorAll('.slide'));
  const bar    = document.querySelector('.progress');
  const total  = slides.length;

  slides.forEach((s, i) => { s.dataset.n = i + 1; s.dataset.total = total; });

  function currentIndex() {
    const mid = deck.scrollTop + deck.clientHeight / 2;
    let best = 0, bestDist = Infinity;
    slides.forEach((s, i) => {
      const dist = Math.abs(s.offsetTop + s.clientHeight / 2 - deck.scrollTop - deck.clientHeight / 2);
      if (dist < bestDist) { bestDist = dist; best = i; }
    });
    return best;
  }

  function goTo(i) {
    i = Math.max(0, Math.min(total - 1, i));
    slides[i].scrollIntoView({ behavior: 'smooth' });
  }

  deck.addEventListener('scroll', () => {
    const pct = ((currentIndex() + 1) / total) * 100;
    bar.style.width = pct + '%';
  }, { passive: true });

  document.addEventListener('keydown', e => {
    const i = currentIndex();
    if (e.key === 'ArrowRight' || e.key === 'ArrowDown' || e.key === ' ') { e.preventDefault(); goTo(i + 1); }
    if (e.key === 'ArrowLeft'  || e.key === 'ArrowUp')                    { e.preventDefault(); goTo(i - 1); }
    if (e.key === 'f' || e.key === 'F') { document.documentElement.requestFullscreen?.(); }
    if (e.key === 'Home') goTo(0);
    if (e.key === 'End')  goTo(total - 1);
  });
})();
</script>
```

---

## HTML skeleton

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Feature name] — [Spec / Plan / Overview]</title>
  <style>/* full CSS above */</style>
</head>
<body>

  <div class="progress" id="progress"></div>

  <div class="deck">

    <!-- Slide 1: Cover (always slate background) -->
    <section class="slide cover">
      <div class="eyebrow">Spec · [SPEC-ID] · [date]</div>
      <h1>[Feature Name]</h1>
      <p class="lead">[One-sentence problem statement]</p>
    </section>

    <!-- Slide 2+: content slides -->
    <section class="slide">
      <div class="eyebrow">[section label]</div>
      <h2>[Slide title]</h2>
      <!-- content component here -->
    </section>

    <!-- Use class="slide invert" for visual variety every 3rd slide -->
    <!-- Use class="slide dark"   for final "Definition of Done" slide -->

  </div>

  <script>/* navigation JS above */</script>
</body>
</html>
```

---

## Slide writing rules

- **One idea per slide** — if a section has 10 items, split it or trim to the 5 highest-signal ones
- **Cover slide**: feature name headline + one-sentence problem statement only
- **No raw markdown text** — every bullet is a proper `<li>` in a styled list
- **Use `class="invert"`** every 2–3 slides for visual rhythm
- **Use `class="dark"`** for the final "Definition of Done" or "Questions?" slide
- **Limit prose** — max 40 words per slide outside of lists
- **Decision cards**: use `.decision-grid` for architecture decisions (max 4 per slide)
- **Risks**: include severity chips (`.sev.high / .medium / .low`); top 3 risks only

---

## Full workflow

```
/research <topic>   ← optional
/spec <description> ← define WHAT and WHY → spec.md
/plan <spec-path>   ← define HOW → plan.md
/slides <path>      ← turn spec or plan into a slide deck (you are here)
/html <specs/dir/>  ← render full documents as styled HTML
/diagram <path>     ← generate architecture or flow diagrams
/tasks <spec-path>  ← generate PRD.md for the ralph loop
./scripts/ralph.sh  ← execute tasks autonomously
```
