#!/usr/bin/env node
// bin/install.js — unified installer for unagi AFK coding skills
// Detects installed AI coding agents and installs the skills to each one.
//
// Usage:
//   node bin/install.js                    detect + install to all found agents
//   node bin/install.js --list             show detected agents, exit
//   node bin/install.js --only claude-code install to Claude Code only
//   node bin/install.js --with-init        also write per-repo rule files
//   node bin/install.js --dry-run          show what would happen, write nothing
//   node bin/install.js --uninstall        remove from all agents

'use strict';

const fs   = require('fs');
const path = require('path');
const os   = require('os');
const { execSync, spawnSync } = require('child_process');

const ROOT     = path.resolve(__dirname, '..');
const HOME     = os.homedir();
const PLATFORM = process.platform;

// ── Colour helpers ─────────────────────────────────────────────────────────

const NO_COLOR = !process.stdout.isTTY || process.argv.includes('--no-color');
const c = {
  red    : s => NO_COLOR ? s : `\x1b[31m${s}\x1b[0m`,
  green  : s => NO_COLOR ? s : `\x1b[32m${s}\x1b[0m`,
  yellow : s => NO_COLOR ? s : `\x1b[33m${s}\x1b[0m`,
  blue   : s => NO_COLOR ? s : `\x1b[34m${s}\x1b[0m`,
  bold   : s => NO_COLOR ? s : `\x1b[1m${s}\x1b[0m`,
  dim    : s => NO_COLOR ? s : `\x1b[2m${s}\x1b[0m`,
};

// ── CLI args ───────────────────────────────────────────────────────────────

const args = process.argv.slice(2);
const DRY_RUN      = args.includes('--dry-run');
const WITH_INIT    = args.includes('--with-init');
const UNINSTALL    = args.includes('--uninstall');
const LIST         = args.includes('--list');
const ONLY_IDX     = args.indexOf('--only');
const ONLY         = ONLY_IDX !== -1 ? args[ONLY_IDX + 1] : null;
const CONFIG_DIR   = (() => {
  const i = args.indexOf('--config-dir');
  return i !== -1 ? args[i + 1] : (process.env.CLAUDE_CONFIG_DIR || path.join(HOME, '.claude'));
})();

// ── File utils ─────────────────────────────────────────────────────────────

function resolveHome(p) {
  return p.replace(/^~/, HOME);
}

function exists(p) {
  try { fs.accessSync(resolveHome(p)); return true; } catch { return false; }
}

function commandExists(cmd) {
  const result = spawnSync(PLATFORM === 'win32' ? 'where' : 'which', [cmd],
    { stdio: 'ignore', shell: false });
  return result.status === 0;
}

function ensureDir(p) {
  if (!DRY_RUN) fs.mkdirSync(resolveHome(p), { recursive: true });
}

function writeFile(dest, content, label) {
  dest = resolveHome(dest);
  if (DRY_RUN) {
    console.log(`  ${c.dim('would write')} ${dest}`);
    return;
  }
  ensureDir(path.dirname(dest));
  fs.writeFileSync(dest, content, { mode: 0o600 });
  console.log(`  ${c.green('✓')} wrote ${c.blue(dest)} ${label || ''}`);
}

function copyFile(src, dest, label) {
  src  = path.resolve(ROOT, src);
  dest = resolveHome(dest);
  if (!fs.existsSync(src)) { console.log(`  ${c.yellow('!')} skip ${src} (not found)`); return; }
  if (DRY_RUN) { console.log(`  ${c.dim('would copy')} ${src} → ${dest}`); return; }
  ensureDir(path.dirname(dest));
  fs.copyFileSync(src, dest);
  console.log(`  ${c.green('✓')} copied ${c.blue(path.basename(src))} → ${dest} ${label || ''}`);
}

function appendToFile(dest, marker, block, label) {
  dest = resolveHome(dest);
  if (DRY_RUN) { console.log(`  ${c.dim('would append')} ${dest}`); return; }
  const existing = fs.existsSync(dest) ? fs.readFileSync(dest, 'utf8') : '';
  if (existing.includes(marker)) {
    console.log(`  ${c.dim('already present')} ${dest} ${label || ''}`);
    return;
  }
  ensureDir(path.dirname(dest));
  fs.appendFileSync(dest, `\n${block}\n`);
  console.log(`  ${c.green('✓')} appended → ${c.blue(dest)} ${label || ''}`);
}

function removeFile(dest, label) {
  dest = resolveHome(dest);
  if (!fs.existsSync(dest)) return;
  if (DRY_RUN) { console.log(`  ${c.dim('would remove')} ${dest}`); return; }
  fs.rmSync(dest, { recursive: true, force: true });
  console.log(`  ${c.green('✓')} removed ${c.blue(dest)} ${label || ''}`);
}

// ── Skill content ──────────────────────────────────────────────────────────

function readSkill(name) {
  const p = path.join(ROOT, 'skills', name, 'SKILL.md');
  return fs.existsSync(p) ? fs.readFileSync(p, 'utf8') : '';
}

function ruleFileContent() {
  return `# unagi — spec-driven AFK coding with ralph loop

${readSkill('research')}

---

${readSkill('spec')}

---

${readSkill('plan')}

---

${readSkill('tasks')}

---

${readSkill('afk')}

---

## Quick start

\`\`\`bash
# Spec-driven workflow
/research "what to build"  # optional: parallel investigation
/spec "feature description" # create spec (WHAT + WHY)
/plan specs/.../spec.md     # technical plan (HOW)
/tasks specs/.../spec.md    # generate PRD.md

# Or quick path (skip spec/plan)
/ralph  # interview-style PRD creation

# Execute
./scripts/ralph-once.sh     # watch one iteration
./scripts/ralph.sh [N]      # go AFK
\`\`\`
`;
}

// ── PROVIDERS ─────────────────────────────────────────────────────────────
//
// Each entry:
//   id      – kebab-case identifier (used with --only)
//   label   – human display name
//   detect  – how to check if agent is installed
//   mech    – how to install (see install() below)
//   soft    – detection is best-effort (config-dir only)

const PROVIDERS = [
  {
    id: 'claude-code',
    label: 'Claude Code',
    detect: () => commandExists('claude') || exists('~/.claude'),
    mech: 'claude-skills',
  },
  {
    id: 'cursor',
    label: 'Cursor',
    detect: () => commandExists('cursor') || exists('~/.cursor') || exists('~/.config/Cursor'),
    mech: 'rules-mdc',
    rulesDir: '~/.cursor/rules',
    perRepo: '.cursor/rules',
    soft: true,
  },
  {
    id: 'windsurf',
    label: 'Windsurf',
    detect: () => commandExists('windsurf') || exists('~/.windsurf') || exists('~/.config/windsurf'),
    mech: 'rules-md',
    rulesDir: '~/.windsurf/rules',
    perRepo: '.windsurf/rules',
    soft: true,
  },
  {
    id: 'cline',
    label: 'Cline',
    detect: () => exists('~/.vscode/extensions') &&
      fs.readdirSync(resolveHome('~/.vscode/extensions')).some(e => e.startsWith('saoudrizwan.claude-dev')),
    mech: 'rules-md',
    rulesDir: null,
    perRepo: '.clinerules',
    soft: true,
  },
  {
    id: 'copilot',
    label: 'GitHub Copilot',
    detect: () => commandExists('gh'),
    mech: 'copilot-instructions',
    soft: true,
  },
  {
    id: 'gemini',
    label: 'Gemini CLI',
    detect: () => commandExists('gemini'),
    mech: 'gemini',
  },
  {
    id: 'opencode',
    label: 'opencode',
    detect: () => commandExists('opencode') || exists('~/.config/opencode'),
    mech: 'agents-md',
    soft: true,
  },
  {
    id: 'codex',
    label: 'OpenAI Codex',
    detect: () => commandExists('codex'),
    mech: 'codex',
  },
  {
    id: 'aider',
    label: 'Aider',
    detect: () => commandExists('aider'),
    mech: 'conventions',
    soft: true,
  },
  {
    id: 'amp',
    label: 'Sourcegraph Amp',
    detect: () => commandExists('amp'),
    mech: 'agents-md',
    soft: true,
  },
  {
    id: 'continue',
    label: 'Continue',
    detect: () => exists('~/.continue'),
    mech: 'npx-skills',
    profile: 'curiousfurbytes/unagi',
    soft: true,
  },
  {
    id: 'goose',
    label: 'Block Goose',
    detect: () => commandExists('goose'),
    mech: 'npx-skills',
    profile: 'curiousfurbytes/unagi',
    soft: true,
  },
  {
    id: 'roo',
    label: 'Roo Code',
    detect: () => exists('~/.vscode/extensions') &&
      fs.readdirSync(resolveHome('~/.vscode/extensions')).some(e => e.startsWith('rooveterinaryinc.roo-cline')),
    mech: 'npx-skills',
    profile: 'curiousfurbytes/unagi',
    soft: true,
  },
];

// ── Detection ──────────────────────────────────────────────────────────────

function detect(provider) {
  try { return provider.detect(); }
  catch { return false; }
}

// ── Install mechanics ──────────────────────────────────────────────────────

function installProvider(provider) {
  console.log(`\n${c.bold(provider.label)}`);

  const content = ruleFileContent();
  const MARKER  = '<!-- unagi-afk -->';

  switch (provider.mech) {
    case 'claude-skills': {
      const skillsDir = path.join(CONFIG_DIR, 'skills', 'unagi');
      for (const name of ['research', 'spec', 'plan', 'tasks', 'afk', 'ralph', 'ralph-loop']) {
        copyFile(`skills/${name}/SKILL.md`, `${skillsDir}/${name}.md`, `(${name} skill)`);
      }
      const binDest = path.join(HOME, '.local', 'bin');
      copyFile('scripts/ralph.sh',      `${binDest}/ralph`,      '(PATH)');
      copyFile('scripts/ralph-once.sh', `${binDest}/ralph-once`, '(PATH)');
      if (!DRY_RUN) {
        try { fs.chmodSync(path.join(binDest, 'ralph'), 0o755); } catch {}
        try { fs.chmodSync(path.join(binDest, 'ralph-once'), 0o755); } catch {}
      }
      break;
    }

    case 'rules-mdc':
    case 'rules-md': {
      const ext = provider.mech === 'rules-mdc' ? '.mdc' : '.md';
      if (WITH_INIT || provider.rulesDir === null) {
        const dir = provider.perRepo;
        writeFile(`${dir}/unagi-afk${ext}`, content, '(per-repo)');
      } else if (provider.rulesDir) {
        writeFile(`${provider.rulesDir}/unagi-afk${ext}`, content, '(global)');
      }
      break;
    }

    case 'copilot-instructions': {
      const block = `${MARKER}\n${content}\n${MARKER}`;
      if (WITH_INIT) {
        appendToFile('.github/copilot-instructions.md', MARKER, block, '(per-repo)');
      } else {
        appendToFile('~/.github/copilot-instructions.md', MARKER, block, '(global)');
      }
      break;
    }

    case 'gemini': {
      writeFile('GEMINI.md', readSkill('afk') + '\n\n' + readSkill('ralph') + '\n\n' + readSkill('ralph-loop'), '(context)');
      break;
    }

    case 'agents-md': {
      const block = `${MARKER}\n${content}\n${MARKER}`;
      if (WITH_INIT) {
        appendToFile('AGENTS.md', MARKER, block, '(per-repo)');
      } else {
        console.log(`  ${c.dim('use --with-init to write AGENTS.md to current repo')}`);
      }
      break;
    }

    case 'codex': {
      copyFile('.codex/hooks.json', '~/.codex/hooks.json', '(hooks)');
      break;
    }

    case 'conventions': {
      if (WITH_INIT) {
        const block = `${MARKER}\n${content}\n${MARKER}`;
        appendToFile('CONVENTIONS.md', MARKER, block, '(per-repo)');
      }
      break;
    }

    case 'npx-skills': {
      if (provider.profile && commandExists('npx')) {
        const cmd = `npx skills add ${provider.profile} -a ${provider.id}`;
        console.log(`  ${c.dim('run:')} ${cmd}`);
        if (!DRY_RUN) {
          try { execSync(cmd, { stdio: 'inherit' }); }
          catch { console.log(`  ${c.yellow('!')} npx skills failed — install manually`); }
        }
      }
      break;
    }

    default:
      console.log(`  ${c.yellow('!')} no installer for mech=${provider.mech}`);
  }
}

function uninstallProvider(provider) {
  console.log(`\n${c.bold(provider.label)}`);
  switch (provider.mech) {
    case 'claude-skills':
      removeFile(`${CONFIG_DIR}/skills/unagi`, '(skills)');
      removeFile(`${HOME}/.local/bin/ralph`);
      removeFile(`${HOME}/.local/bin/ralph-once`);
      break;
    case 'rules-mdc':
    case 'rules-md': {
      const ext = provider.mech === 'rules-mdc' ? '.mdc' : '.md';
      if (provider.rulesDir) removeFile(`${provider.rulesDir}/unagi-afk${ext}`);
      if (provider.perRepo)  removeFile(`${provider.perRepo}/unagi-afk${ext}`, '(per-repo)');
      break;
    }
    default:
      console.log(`  ${c.dim('manual removal required')}`);
  }
}

// ── List ───────────────────────────────────────────────────────────────────

function list() {
  console.log(`\n${c.bold('Agent detection matrix')}\n`);
  const COL = 24;
  for (const p of PROVIDERS) {
    const found = detect(p);
    const status = found
      ? c.green('✓ found')
      : (p.soft ? c.dim('– not found (soft)') : c.dim('– not found'));
    const pad = ' '.repeat(Math.max(1, COL - p.label.length));
    console.log(`  ${p.id.padEnd(20)} ${p.label}${pad}${status}`);
  }
  console.log('');
}

// ── Main ───────────────────────────────────────────────────────────────────

console.log(`\n${c.bold('unagi')} — AFK coding skills installer`);
if (DRY_RUN)   console.log(c.yellow('  DRY RUN — nothing will be written'));
if (UNINSTALL) console.log(c.yellow('  UNINSTALL mode'));
if (WITH_INIT) console.log(c.blue('  --with-init: will also write per-repo rule files'));
console.log('');

if (LIST) { list(); process.exit(0); }

const targets = ONLY
  ? PROVIDERS.filter(p => p.id === ONLY)
  : PROVIDERS.filter(p => detect(p));

if (targets.length === 0) {
  if (ONLY) {
    console.log(c.red(`No provider with id '${ONLY}'.`));
    console.log('Valid ids: ' + PROVIDERS.map(p => p.id).join(', '));
  } else {
    console.log(c.yellow('No supported AI coding agents detected.'));
    console.log('\nInstall one of: claude, cursor, windsurf, codex, gemini, opencode, aider, amp');
    console.log('Then re-run this installer.\n');
    console.log(`Or install manually: node bin/install.js --only <agent-id>`);
  }
  process.exit(0);
}

for (const p of targets) {
  if (UNINSTALL) uninstallProvider(p);
  else           installProvider(p);
}

console.log(`\n${c.green('Done!')} ${targets.length} agent(s) ${UNINSTALL ? 'uninstalled' : 'installed'}.`);
if (!UNINSTALL) {
  console.log(`\nNext steps (spec-driven):`);
  console.log(`  1. Research:   /research "what to build"     (optional)`);
  console.log(`  2. Spec:       /spec "feature description"`);
  console.log(`  3. Plan:       /plan specs/.../spec.md`);
  console.log(`  4. Tasks:      /tasks specs/.../spec.md      (generates PRD.md)`);
  console.log(`  5. Test loop:  ./scripts/ralph-once.sh`);
  console.log(`  6. Go AFK:     ./scripts/ralph.sh`);
  console.log(`\n  Quick path (skip spec/plan): /ralph → ./scripts/ralph.sh`);
}
console.log('');
