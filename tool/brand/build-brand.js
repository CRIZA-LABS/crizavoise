// CrizaVoise brand v2 — "Ribbon V".
// A V/check built from Criza Labs' two ribbons (red short arm, blue long arm
// folding over it), on the Criza navy plate. Wordmark in Bricolage Grotesque,
// endorsement line in Inter. Usage:
//   node build-brand-v2.js <repoRoot> <fontsDir> <outPreviewDir> [--preview-only]
const fs = require('fs');
const path = require('path');
const fontkit = require('fontkit');
const sharp = require('sharp');

const [, , repo, fontsDir, previewDir, flag] = process.argv;
const previewOnly = flag === '--preview-only';

// ---- Palette (from Criza Labs: logo ribbons, site tokens, app-icon plate) ----
const P = {
  navy: '#071426', navyTop: '#122a4c', // plate (Criza app icon background)
  red1: '#ff5a3c', red2: '#e2231a', red3: '#a5121b', // red ribbon (tip → fold)
  blue1: '#3cc8ff', blue2: '#0a8ef0', blue3: '#0a4fb3', // blue ribbon (tip → fold)
  seam: '#f51e91', // Criza magenta, only at the fold seam
  inkLight: '#12131a', inkDark: '#f6f2ea',
  voiseLight: '#0a5ea8', voiseDark: '#5cc0ff', // = app primary tokens (AA text)
  mutedLight: '#4a4e59', mutedDark: '#b3b7c2',
};

// ---- Geometry on a 64 grid ------------------------------------------------------
// Centre-lines A (left tip) → V (vertex) → B (right tip), ribbon thickness T.
// Mitred vertex; both tips cut HORIZONTALLY, like the feet of the Criza "A"
// (this V is that A turned upside down). The result is centred in the plate.
const T = 9.6;
const A0 = [1, 17], V0 = [10, 36.5], B0 = [31, 4];
const sub = (a, b) => [a[0] - b[0], a[1] - b[1]], add = (a, b) => [a[0] + b[0], a[1] + b[1]];
const mul = (a, k) => [a[0] * k, a[1] * k], norm = (a) => { const l = Math.hypot(a[0], a[1]); return [a[0] / l, a[1] / l]; };
const perp = (d) => [d[1], -d[0]];
function meet(p1, d1, p2, d2) { // intersection of p1+s*d1 and p2+u*d2
  const den = d1[0] * d2[1] - d1[1] * d2[0];
  const s2 = ((p2[0] - p1[0]) * d2[1] - (p2[1] - p1[1]) * d2[0]) / den;
  return add(p1, mul(d1, s2));
}
const atY = (p, d, y) => add(p, mul(d, (y - p[1]) / d[1]));
const dL = norm(sub(V0, A0)), dR = norm(sub(B0, V0));
const nL = perp(dL), nR = perp(dR); // nL points up-right (inner), nR points down-right (outer)
const h = T / 2;
const Lin = add(A0, mul(nL, h)), Lout = add(A0, mul(nL, -h));
const Rout = add(V0, mul(nR, h)), Rin = add(V0, mul(nR, -h));
const miterIn = meet(Lin, dL, Rin, dR), miterOut = meet(Lout, dL, Rout, dR);
const yTopL = A0[1] - 2, yTopR = B0[1];
let LEFT_PTS = [atY(Lout, dL, yTopL), atY(Lin, dL, yTopL), miterIn, miterOut];
let RIGHT_PTS = [miterIn, atY(Rin, dR, yTopR), atY(Rout, dR, yTopR), miterOut];
// seam: sliver of the red arm along the blue arm's inner edge
let SEAM_PTS = [miterIn, miterOut, add(miterOut, mul(dL, -3.2)), add(miterIn, mul(dL, -3.2))];
// centre in the 64 plate (optical: nudge 1 unit down so the mass sits centred)
const all = [...LEFT_PTS, ...RIGHT_PTS];
const minX = Math.min(...all.map((p) => p[0])), maxX = Math.max(...all.map((p) => p[0]));
const minY = Math.min(...all.map((p) => p[1])), maxY = Math.max(...all.map((p) => p[1]));
const off = [32 - (minX + maxX) / 2, 33 - (minY + maxY) / 2];
const fix = (pts) => pts.map((p) => add(p, off).map((v) => +v.toFixed(2)));
LEFT_PTS = fix(LEFT_PTS); RIGHT_PTS = fix(RIGHT_PTS); SEAM_PTS = fix(SEAM_PTS);
const poly = (pts) => 'M' + pts.map((p) => p.join(' ')).join('L') + 'Z';
const LEFT = poly(LEFT_PTS), RIGHT = poly(RIGHT_PTS), SEAM = poly(SEAM_PTS);
const M_in = LEFT_PTS[2], M_out = LEFT_PTS[3], A_out = LEFT_PTS[0], B_out = RIGHT_PTS[2];
const SYM_VB = `${(minX + off[0] - 2).toFixed(1)} ${(minY + off[1] - 2).toFixed(1)} ${(maxX - minX + 4).toFixed(1)} ${(maxY - minY + 4).toFixed(1)}`;
console.error('V bbox w,h =', (maxX-minX).toFixed(1), (maxY-minY).toFixed(1));

const lin = (id, x1, y1, x2, y2, stops) =>
  `<linearGradient id="${id}" gradientUnits="userSpaceOnUse" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}">` +
  stops.map(([o, c, a]) => `<stop offset="${o}" stop-color="${c}"${a !== undefined ? ` stop-opacity="${a}"` : ''}/>`).join('') +
  `</linearGradient>`;

function ribbonDefs(s) {
  return lin(`${s}r`, A_out[0], A_out[1], M_out[0], M_out[1], [[0, P.red1], [0.6, P.red2], [1, P.red3]]) +
    lin(`${s}b`, B_out[0], B_out[1], M_in[0], M_out[1], [[0, P.blue1], [0.55, P.blue2], [1, P.blue3]]) +
    lin(`${s}s`, M_in[0], M_in[1], M_in[0] - 3.2, M_in[1] + 6, [[0, P.seam, 0.95], [1, P.seam, 0]]);
}
const ribbons = (s, detail = true) =>
  `<path d="${LEFT}" fill="url(#${s}r)"/>` +
  (detail ? `<path d="${SEAM}" fill="url(#${s}s)"/>` : '') +
  `<path d="${RIGHT}" fill="url(#${s}b)"/>`;

const plate = (s) =>
  `<rect width="64" height="64" rx="14" fill="url(#${s}p)"/>` +
  `<rect x=".5" y=".5" width="63" height="63" rx="13.5" fill="none" stroke="#ffffff" stroke-opacity=".08"/>`;
const plateDef = (s) => lin(`${s}p`, 0, 0, 0, 64, [[0, P.navyTop], [1, P.navy]]);

const svg = (vb, body, label = 'CrizaVoise') =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vb}" role="img" aria-label="${label}">${body}</svg>`;

// App icon (plated) — full detail, and a small-size version without the seam.
const markSvg = svg('0 0 64 64', `<defs>${plateDef('m')}${ribbonDefs('m')}</defs>${plate('m')}${ribbons('m')}`);
const markSmallSvg = svg('0 0 64 64', `<defs>${plateDef('k')}${ribbonDefs('k')}</defs>${plate('k')}${ribbons('k', false)}`);
// Unplated symbol (transparent) — for in-app use and Windows unplated assets.
const symbolSvg = svg(SYM_VB, `<defs>${ribbonDefs('y')}</defs>${ribbons('y')}`);
// Monochrome symbol (currentColor) with a hairline gap so the fold still reads.
const monoSvg = svg(SYM_VB,
  `<defs><mask id="g"><rect x="0" y="0" width="64" height="64" fill="#fff"/>` +
  `<path d="M${M_in.join(' ')}L${M_out.join(' ')}" stroke="#000" stroke-width="1.6"/></mask></defs>` +
  `<g fill="currentColor" mask="url(#g)"><path d="${LEFT}"/><path d="${RIGHT}"/></g>`);
const markMonoSvg = svg('0 0 64 64',
  `<defs><mask id="mm"><rect width="64" height="64" rx="14" fill="#fff"/>` +
  `<path d="${LEFT}" fill="#000"/><path d="${RIGHT}" fill="#000"/></mask></defs>` +
  `<rect width="64" height="64" rx="14" fill="currentColor" mask="url(#mm)"/>`);

// ---- Type outlining ------------------------------------------------------------
const brico = fontkit.openSync(path.join(fontsDir, 'BricolageGrotesque-Variable.ttf')).getVariation({ wght: 760, opsz: 48, wdth: 100 });
const inter = fontkit.openSync(path.join(fontsDir, 'Inter-Variable.ttf')).getVariation({ wght: 600, opsz: 14 });

function outline(font, text, size, startX = 0, trackingEm = 0) {
  const scale = size / font.unitsPerEm;
  const run = font.layout(text);
  let x = startX / scale;
  const parts = [];
  run.glyphs.forEach((g, i) => {
    parts.push(g.path.scale(scale, -scale).translate(x * scale, font.ascent * scale).toSVG());
    x += run.positions[i].xAdvance + trackingEm * font.unitsPerEm;
  });
  return { d: parts.join(''), width: x * scale, ascent: font.ascent * scale, capH: font.capHeight * scale, descent: -font.descent * scale };
}

const WM = 100; // wordmark size
const criza = outline(brico, 'Criza', WM, 0, -0.025);
const voise = outline(brico, 'Voise', WM, criza.width, -0.025);
const wmW = Math.ceil(voise.width) + 2;
const wmTop = criza.ascent - criza.capH - 2; // crop to cap height
const wmH = Math.ceil(criza.capH + criza.descent * 0.35 + 4);
const wordmark = (cInk, vInk) =>
  svg(`0 ${wmTop.toFixed(1)} ${wmW} ${wmH}`, `<path d="${criza.d}" fill="${cInk}"/><path d="${voise.d}" fill="${vInk}"/>`);

// Endorsed lockup: mark | wordmark over "by Criza Labs".
function lockup(theme, endorse = true, plated = true) {
  const cInk = theme === 'dark' ? P.inkDark : P.inkLight;
  const vInk = theme === 'dark' ? P.voiseDark : P.voiseLight;
  const muted = theme === 'dark' ? P.mutedDark : P.mutedLight;
  const capH = criza.capH;
  const by = outline(inter, 'BY CRIZA LABS', capH * 0.30, 0, 0.16);
  const markSize = endorse ? capH * 1.62 : capH * 1.3;
  const gap = markSize * 0.3;
  const textX = markSize + gap;
  const totalH = markSize;
  const textBlockH = capH + (endorse ? capH * 0.30 + capH * 0.30 : 0);
  const textTop = (totalH - textBlockH) / 2;
  const w = Math.ceil(textX + Math.max(voise.width, by.width)) + 2;
  const s = markSize / 64;
  const markBody = plated
    ? `<defs>${plateDef('lp')}${ribbonDefs('lp')}</defs><g transform="scale(${s})">${plate('lp')}${ribbons('lp')}</g>`
    : `<defs>${ribbonDefs('lp')}</defs><g transform="scale(${s})">${ribbons('lp')}</g>`;
  const wmY = textTop - (criza.ascent - capH);
  let body = markBody +
    `<g transform="translate(${textX} ${wmY})"><path d="${criza.d}" fill="${cInk}"/><path d="${voise.d}" fill="${vInk}"/></g>`;
  if (endorse) {
    const byY = textTop + capH + capH * 0.30 - (by.ascent - by.capH);
    body += `<g transform="translate(${textX + 2} ${byY})"><path d="${by.d}" fill="${muted}"/></g>`;
  }
  return svg(`0 0 ${w} ${Math.ceil(totalH)}`, body);
}

const files = {
  'mark.svg': markSvg,
  'mark-small.svg': markSmallSvg,
  'symbol.svg': symbolSvg,
  'symbol-mono.svg': monoSvg,
  'mark-mono.svg': markMonoSvg,
  'wordmark-light.svg': wordmark(P.inkLight, P.voiseLight),
  'wordmark-dark.svg': wordmark(P.inkDark, P.voiseDark),
  'wordmark-mono.svg': wordmark('currentColor', 'currentColor'),
  'lockup-light.svg': lockup('light'),
  'lockup-dark.svg': lockup('dark'),
  'lockup-compact-light.svg': lockup('light', false),
  'lockup-compact-dark.svg': lockup('dark', false),
};

async function png(svgStr, w, h) {
  return sharp(Buffer.from(svgStr), { density: 1600 }).resize(w, h ?? w, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } }).png().toBuffer();
}

// ICO writer: PNG-compressed entries (supported since Windows Vista).
function ico(entries) {
  const header = Buffer.alloc(6); header.writeUInt16LE(0, 0); header.writeUInt16LE(1, 2); header.writeUInt16LE(entries.length, 4);
  const dir = Buffer.alloc(16 * entries.length);
  let offset = 6 + dir.length;
  entries.forEach(({ size, data }, i) => {
    const o = i * 16;
    dir.writeUInt8(size >= 256 ? 0 : size, o); dir.writeUInt8(size >= 256 ? 0 : size, o + 1);
    dir.writeUInt8(0, o + 2); dir.writeUInt8(0, o + 3); dir.writeUInt16LE(1, o + 4); dir.writeUInt16LE(32, o + 6);
    dir.writeUInt32LE(data.length, o + 8); dir.writeUInt32LE(offset, o + 12); offset += data.length;
  });
  return Buffer.concat([header, dir, ...entries.map((e) => e.data)]);
}

(async () => {
  fs.mkdirSync(previewDir, { recursive: true });

  // ---- Small-size + background test sheet: current vs new ----
  const current = fs.readFileSync(path.join(repo, 'assets', 'brand', 'mark.svg'), 'utf8');
  const sizes = [16, 24, 32, 48, 96];
  const rows = [['Current', current, current], ['New', markSvg, markSmallSvg]];
  const bgs = [['#f3f3f3', 'light taskbar'], ['#202020', 'dark taskbar']];
  const comps = []; let y = 20;
  const labels = [];
  for (const [bg] of bgs) {
    for (const [name, big, small] of rows) {
      let x = 150;
      for (const s of sizes) {
        comps.push({ input: await png(s <= 32 ? small : big, s), left: x, top: y + Math.round((96 - s) / 2) });
        x += s + 40;
      }
      labels.push({ name, y: y + 54, bg });
      y += 116;
    }
  }
  const sheetW = 150 + sizes.reduce((a, s) => a + s + 40, 0), sheetH = y + 10;
  const half = sheetH / 2;
  const bgSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="${sheetW}" height="${sheetH}">` +
    `<rect width="${sheetW}" height="${half}" fill="${bgs[0][0]}"/><rect y="${half}" width="${sheetW}" height="${half}" fill="${bgs[1][0]}"/>` +
    labels.map((l) => `<text x="20" y="${l.y}" font-family="Segoe UI,Arial" font-size="22" font-weight="600" fill="${l.bg === '#202020' ? '#eee' : '#222'}">${l.name}</text>`).join('') +
    `</svg>`;
  await sharp(Buffer.from(bgSvg)).composite(comps).png().toFile(path.join(previewDir, 'size-test.png'));

  // ---- Lockup sheet ----
  const lw = 900;
  const lockL = await sharp(Buffer.from(files['lockup-light.svg']), { density: 900 }).resize({ width: 640 }).png().toBuffer();
  const lockD = await sharp(Buffer.from(files['lockup-dark.svg']), { density: 900 }).resize({ width: 640 }).png().toBuffer();
  const monoL = await sharp(Buffer.from(files['symbol-mono.svg'].replace(/currentColor/g, '#12131a')), { density: 900 }).resize(120).png().toBuffer();
  const big = await png(markSvg, 220);
  const sheet2 = `<svg xmlns="http://www.w3.org/2000/svg" width="${lw}" height="720"><rect width="${lw}" height="360" fill="#f4efe6"/><rect y="360" width="${lw}" height="360" fill="#08090d"/></svg>`;
  await sharp(Buffer.from(sheet2)).composite([
    { input: lockL, left: 40, top: 60 }, { input: monoL, left: 740, top: 200 },
    { input: lockD, left: 40, top: 420 }, { input: big, left: 660, top: 470 },
  ]).png().toFile(path.join(previewDir, 'lockups.png'));

  if (previewOnly) { console.log('preview written', previewDir); return; }

  // ---- Write assets ----
  const outBrand = path.join(repo, 'assets', 'brand');
  const outDocs = path.join(repo, 'docs', 'brand');
  for (const d of [outBrand, outDocs]) {
    for (const f of fs.readdirSync(d)) if (f.endsWith('.svg')) fs.unlinkSync(path.join(d, f));
    for (const [n, s] of Object.entries(files)) fs.writeFileSync(path.join(d, n), s);
  }
  const icons = path.join(outBrand, 'icons');
  fs.mkdirSync(icons, { recursive: true });
  fs.writeFileSync(path.join(icons, 'icon-1024.png'), await png(markSvg, 1024));
  // Android adaptive: ribbons centred in the 66% safe zone on a navy layer.
  const fg = svg('-14 -12 92 92', `<defs>${ribbonDefs('a')}</defs>${ribbons('a')}`);
  fs.writeFileSync(path.join(icons, 'android-foreground.png'), await png(fg, 1024));
  const bgL = svg('0 0 64 64', `<defs>${plateDef('b')}</defs><rect width="64" height="64" fill="url(#bp)"/>`);
  fs.writeFileSync(path.join(icons, 'android-background.png'), await png(bgL, 1024));
  // Windows ICO: Microsoft's minimum set plus common scale steps; the
  // seam-less small mark below 48px keeps the silhouette crisp.
  const icoSizes = [16, 20, 24, 30, 32, 36, 40, 48, 60, 64, 72, 80, 96, 256];
  const entries = [];
  for (const s of icoSizes) entries.push({ size: s, data: await png(s < 48 ? markSmallSvg : markSvg, s) });
  fs.writeFileSync(path.join(repo, 'windows', 'runner', 'resources', 'app_icon.ico'), ico(entries));
  // Linux/deb + web favicon
  fs.writeFileSync(path.join(repo, 'web', 'favicon.png'), await png(markSmallSvg, 32));
  for (const s of [192, 512]) {
    fs.writeFileSync(path.join(repo, 'web', 'icons', `Icon-${s}.png`), await png(markSvg, s));
    fs.writeFileSync(path.join(repo, 'web', 'icons', `Icon-maskable-${s}.png`),
      await png(svg('-8 -8 80 80', `<defs>${plateDef('w')}${ribbonDefs('w')}</defs><rect x="-8" y="-8" width="80" height="80" fill="url(#wp)"/>${ribbons('w')}`), s));
  }
  // In-app PNG fallbacks
  fs.writeFileSync(path.join(icons, 'lockup-light@2x.png'), await sharp(Buffer.from(files['lockup-light.svg']), { density: 600 }).resize({ height: 160 }).png().toBuffer());
  fs.writeFileSync(path.join(icons, 'lockup-dark@2x.png'), await sharp(Buffer.from(files['lockup-dark.svg']), { density: 600 }).resize({ height: 160 }).png().toBuffer());

  // OG image 1200x630 on Criza navy with ribbon glow
  const ogLock = await sharp(Buffer.from(files['lockup-dark.svg']), { density: 900 }).resize({ width: 820 }).png().toBuffer();
  const ogMeta = await sharp(ogLock).metadata();
  const og = `<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630"><defs>` +
    `<radialGradient id="r1" cx="8%" cy="0%" r="65%"><stop offset="0" stop-color="${P.red2}" stop-opacity=".28"/><stop offset="1" stop-color="#08090d" stop-opacity="0"/></radialGradient>` +
    `<radialGradient id="r2" cx="96%" cy="100%" r="70%"><stop offset="0" stop-color="${P.blue2}" stop-opacity=".26"/><stop offset="1" stop-color="#08090d" stop-opacity="0"/></radialGradient></defs>` +
    `<rect width="1200" height="630" fill="#08090d"/><rect width="1200" height="630" fill="url(#r1)"/><rect width="1200" height="630" fill="url(#r2)"/>` +
    `<text x="600" y="500" text-anchor="middle" font-family="Segoe UI, Arial" font-size="32" fill="#b3b7c2">Invoices made simple · criza.dev</text></svg>`;
  await sharp(Buffer.from(og)).composite([{ input: ogLock, left: Math.round(600 - ogMeta.width / 2), top: Math.round(270 - ogMeta.height / 2) }]).png().toFile(path.join(repo, 'web', 'og.png'));
  fs.copyFileSync(path.join(previewDir, 'size-test.png'), path.join(outDocs, 'size-test.png'));
  fs.copyFileSync(path.join(previewDir, 'lockups.png'), path.join(outDocs, 'lockups.png'));
  fs.writeFileSync(path.join(outDocs, 'preview-icon.png'), await png(markSvg, 512));
  console.log('assets written');
})();
