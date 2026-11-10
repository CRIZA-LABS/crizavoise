// CrizaVoise brand builder (v4).
//
// 1. The mark (mark.js, "the bill being printed"): a shop bill coming out of a
//    thermal-printer slot, its TOTAL line ending in the Criza red dot. Dark
//    (navy tile) and light (white tile) theme versions.
// 2. The lockup "CRIZA VOISE." (lockup.js): built exactly like Criza's
//    "CRIZA LABS." from the Criza master lettering.
//
// Usage: node build-brand.js <repoRoot> <crizaSiteRoot> <previewDir> [--preview-only]
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const { markSvg, monoSvg } = require('./mark');
const { configure, buildLockup, png, ico, svg } = require('./lockup');

const [, , repo, crizaRoot, previewDir, flag] = process.argv;
const previewOnly = flag === '--preview-only';
configure({ repo, crizaRoot });

const files = {
  'mark-dark.svg': markSvg({ theme: 'dark' }),
  'mark-light.svg': markSvg({ theme: 'light' }),
  'mark-dark-small.svg': markSvg({ theme: 'dark', small: true }),
  'mark-light-small.svg': markSvg({ theme: 'light', small: true }),
  'symbol-on-dark.svg': markSvg({ theme: 'dark', plate: false }),
  'symbol-on-light.svg': markSvg({ theme: 'light', plate: false }),
  'symbol-mono.svg': monoSvg(),
};
// 16–47 px use the simplified small mark.
const pick = (theme, size) => files[`mark-${theme}${size < 48 ? '-small' : ''}.svg`];
const innerOf = (s) => s.replace(/^<svg[^>]*>/, '').replace(/<\/svg>$/, '');

(async () => {
  fs.mkdirSync(previewDir, { recursive: true });
  const lockDark = await buildLockup(216, 'dark');
  const lockLight = await buildLockup(216, 'light');

  // ---- Family sheet: Criza Labs next to CrizaVoise ------------------------------------
  const W = 1500, H = 900;
  const comps = [
    { input: await sharp(path.join(crizaRoot, 'public', 'brand', 'icon-512.png')).resize(180).png().toBuffer(), left: 40, top: 80 },
    { input: await sharp(path.join(crizaRoot, 'public', 'brand', 'logo-labs.png')).resize({ height: 64 }).png().toBuffer(), left: 40, top: 300 },
    { input: await png(files['mark-dark.svg'], 180), left: 760, top: 80 },
    { input: await png(files['mark-light.svg'], 180), left: 960, top: 80 },
    { input: await sharp(lockDark).resize({ height: 64 }).png().toBuffer(), left: 760, top: 300 },
    { input: await sharp(lockLight).resize({ height: 64 }).png().toBuffer(), left: 80, top: 520 },
    { input: await png(files['mark-light.svg'], 110), left: 580, top: 500 },
  ];
  for (const [theme, rowTop] of [['dark', 470], ['light', 630]]) {
    let x = 790;
    for (const sz of [16, 24, 32, 48, 64]) {
      comps.push({ input: await png(pick(theme, sz), sz), left: x, top: rowTop + 90 - sz });
      x += sz + 26;
    }
  }
  const bg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}">` +
    `<rect width="${W}" height="${H}" fill="#08090d"/><rect x="40" y="460" width="680" height="260" rx="16" fill="#f4efe6"/>` +
    `<rect x="760" y="470" width="700" height="110" rx="12" fill="#202020"/><rect x="760" y="630" width="700" height="110" rx="12" fill="#f3f3f3"/>` +
    `<g font-family="Segoe UI, Arial" fill="#b3b7c2" font-size="22" font-weight="600">` +
    `<text x="40" y="44">PARENT · Criza Labs</text><text x="760" y="44">PRODUCT · CrizaVoise (dark · light)</text>` +
    `<text x="760" y="458">dark taskbar · 16 24 32 48 64</text><text x="760" y="618">light taskbar · 16 24 32 48 64</text></g></svg>`;
  await sharp(Buffer.from(bg)).composite(comps).png().toFile(path.join(previewDir, 'family.png'));
  if (previewOnly) { console.log('preview written'); return; }

  // ---- App assets -----------------------------------------------------------------------
  for (const dir of [path.join(repo, 'assets', 'brand'), path.join(repo, 'docs', 'brand')]) {
    fs.mkdirSync(dir, { recursive: true });
    for (const f of fs.readdirSync(dir)) if (/\.(svg|png)$/.test(f)) fs.unlinkSync(path.join(dir, f));
    for (const [n, s] of Object.entries(files)) fs.writeFileSync(path.join(dir, n), s);
    fs.writeFileSync(path.join(dir, 'lockup-dark.png'), lockDark);
    fs.writeFileSync(path.join(dir, 'lockup-light.png'), lockLight);
  }
  fs.copyFileSync(path.join(previewDir, 'family.png'), path.join(repo, 'docs', 'brand', 'family.png'));

  const icons = path.join(repo, 'assets', 'brand', 'icons');
  fs.mkdirSync(icons, { recursive: true });
  for (const f of fs.readdirSync(icons)) fs.unlinkSync(path.join(icons, f));
  fs.writeFileSync(path.join(icons, 'icon-1024.png'), await png(files['mark-dark.svg'], 1024));
  fs.writeFileSync(path.join(icons, 'icon-1024-light.png'), await png(files['mark-light.svg'], 1024));
  // Android adaptive: symbol inside the 66% safe zone over a navy layer.
  fs.writeFileSync(path.join(icons, 'android-foreground.png'),
    await png(svg('-12 -12 88 88', innerOf(files['symbol-on-dark.svg'])), 1024));
  fs.writeFileSync(path.join(icons, 'android-background.png'),
    await png(svg('0 0 64 64', '<rect width="64" height="64" fill="#121316"/>'), 1024));

  // Windows .ico (14 Microsoft target sizes). The dark tile reads on both
  // taskbars (family.png), so it is the .exe icon; brand-kit has the light one.
  const icoSizes = [16, 20, 24, 30, 32, 36, 40, 48, 60, 64, 72, 80, 96, 256];
  const buildIco = async (theme) => {
    const e = [];
    for (const sz of icoSizes) e.push({ size: sz, data: await png(pick(theme, sz), sz) });
    return ico(e);
  };
  const icoDark = await buildIco('dark');
  const icoLight = await buildIco('light');
  fs.writeFileSync(path.join(repo, 'windows', 'runner', 'resources', 'app_icon.ico'), icoDark);

  // Web
  fs.writeFileSync(path.join(repo, 'web', 'favicon.png'), await png(files['mark-dark-small.svg'], 32));
  for (const sz of [192, 512]) {
    fs.writeFileSync(path.join(repo, 'web', 'icons', `Icon-${sz}.png`), await png(files['mark-dark.svg'], sz));
    fs.writeFileSync(path.join(repo, 'web', 'icons', `Icon-maskable-${sz}.png`),
      await png(svg('0 0 64 64', '<rect width="64" height="64" fill="#121316"/>' +
        `<g transform="translate(32 32) scale(.78) translate(-32 -32)">${innerOf(files['mark-dark.svg'])}</g>`), sz));
  }

  // ---- brand-kit/: ready-to-use files outside the codebase -----------------------------
  const kit = path.join(repo, 'brand-kit');
  fs.rmSync(kit, { recursive: true, force: true });
  for (const theme of ['dark', 'light']) {
    const dir = path.join(kit, `icon-${theme}`);
    fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(path.join(dir, `crizavoise-icon-${theme}.svg`), files[`mark-${theme}.svg`]);
    fs.writeFileSync(path.join(dir, `crizavoise-icon-${theme}-small.svg`), files[`mark-${theme}-small.svg`]);
    fs.writeFileSync(path.join(dir, `crizavoise-icon-${theme}.ico`), theme === 'dark' ? icoDark : icoLight);
    for (const sz of [16, 24, 32, 48, 64, 128, 256, 512, 1024]) {
      fs.writeFileSync(path.join(dir, `crizavoise-icon-${theme}-${sz}.png`), await png(pick(theme, sz), sz));
    }
  }
  const logos = path.join(kit, 'logo');
  fs.mkdirSync(logos, { recursive: true });
  fs.writeFileSync(path.join(logos, 'crizavoise-logo-on-dark.png'), lockDark);
  fs.writeFileSync(path.join(logos, 'crizavoise-logo-on-light.png'), lockLight);
  fs.writeFileSync(path.join(logos, 'crizavoise-symbol-on-dark.svg'), files['symbol-on-dark.svg']);
  fs.writeFileSync(path.join(logos, 'crizavoise-symbol-on-light.svg'), files['symbol-on-light.svg']);
  fs.writeFileSync(path.join(logos, 'crizavoise-symbol-mono.svg'), files['symbol-mono.svg']);
  fs.copyFileSync(path.join(previewDir, 'family.png'), path.join(kit, 'overview.png'));
  fs.writeFileSync(path.join(kit, 'README.md'), [
    '# CrizaVoise brand kit',
    '',
    'Ready-to-use logo and icon files. Usage rules: `docs/brand.md`. Regenerate with `tool/brand` (`npm run build`).',
    '',
    '| Folder | What it is | Use it for |',
    '|---|---|---|',
    '| `icon-dark/` | App icon on an **Ink** tile | Dark themes and dark backgrounds. This is the Windows app icon (it also reads well on light taskbars). |',
    '| `icon-light/` | App icon on a **Paper** tile | Light themes and light backgrounds: light-mode docs, store screenshots, printed material. |',
    '| `logo/` | Full logo **CRIZA VOISE.** for dark and light backgrounds, the symbol without a tile, and a one-colour symbol | Websites, invoices, print, thermal receipts (mono). |',
    '',
    'Each icon folder has an SVG, a small-size SVG (for 16–47 px), a Windows `.ico` (14 sizes) and PNGs from 16 to 1024 px.',
    '`overview.png` shows everything next to the Criza Labs logo.',
    '',
  ].join('\n'));

  // OG image
  const og = `<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630"><rect width="1200" height="630" fill="#08090d"/>` +
    `<text x="600" y="545" text-anchor="middle" font-family="Segoe UI, Arial" font-size="30" fill="#b3b7c2">Simple billing for small businesses · criza.dev</text></svg>`;
  const ogLock = await sharp(lockDark).resize({ width: 760 }).png().toBuffer();
  const ogMeta = await sharp(ogLock).metadata();
  await sharp(Buffer.from(og)).composite([
    { input: await png(files['mark-dark.svg'], 190), left: 505, top: 90 },
    { input: ogLock, left: Math.round(600 - ogMeta.width / 2), top: 345 },
  ]).png().toFile(path.join(repo, 'web', 'og.png'));
  console.log('assets written');
})();
