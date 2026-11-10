// CrizaVoise brand builder (v3) — consistent with the Criza Labs identity.
//
// 1. The mark ("Criza V"): the folded-ribbon "A" from the Criza master logo,
//    rebuilt as vectors from its own geometry (flat cap, parallel legs,
//    horizontal feet, highlight streak, dark crease) and turned upside down.
//    Left leg = Criza red (the A), right leg = Criza blue (the C), fold cap =
//    the C's magenta seam. On the Criza app-icon navy (#031326).
// 2. The lockup "CRIZA VOISE.": built exactly like Criza's "CRIZA LABS."
//    (scripts/build-logo.mjs in the Criza site): the master CRIZA lettering
//    without its big dot, then the product word in Inter SemiBold at 0.25em
//    tracking on the letters' baseline, ending in a small copy of the dot.
//
// Usage: node build-brand.js <repoRoot> <crizaSiteRoot> <previewDir> [--preview-only]
const fs = require('fs');
const path = require('path');
const fontkit = require('fontkit');
const sharp = require('sharp');

const [, , repo, crizaRoot, previewDir, flag] = process.argv;
const previewOnly = flag === '--preview-only';
const FONTS = path.join(repo, 'assets', 'fonts');
const MASTER = path.join(crizaRoot, 'logo', 'logo no tag.png');

// Colours sampled from the Criza master logo and app icon.
const C = {
  plate: '#031326', plateTop: '#0a2240',
  capLight: '#fd533a', redHi: '#fd2526', red: '#f61b15', redDeep: '#de0017', redLow: '#d91306',
  blueHi: '#0ad3ff', blue: '#00a6f5', blueDeep: '#0046bc', blueCrease: '#00297a',
  magenta: '#f50fa5', shadow: '#70021f',
  silverTop: '#fdfeff', silverLow: '#e3eaf2', inkDark: '#f6f2ea', inkLight: '#12131a',
};

// ---- Geometry of the Criza "A" (units from a 3x crop of the master) -------------
// Feet at y=630, flat top at y=45; outer slopes ±0.58; legs meet at (478,240).
const A = {
  left: [[378, 45], [591, 45], [251, 630], [38, 630]],
  right: [[375, 45], [588, 45], [930, 630], [706, 630]],
  cap: [[378, 45], [588, 45], [478, 240]],
  crease: [[478, 240], [706, 630], [795, 630], [522, 272]],
  streak: [[408, 60], [446, 60], [128, 612], [92, 612]],
  // thin shadow where the cap folds over each leg
  capShadowL: [[478, 240], [378, 45], [366, 66], [466, 262]],
  capShadowR: [[478, 240], [588, 45], [600, 66], [490, 262]],
};
// Flip vertically (A → V) and normalise to a 0..W x 0..H box.
const minX = 38, maxX = 930, minY = 45, maxY = 630;
const VW = maxX - minX, VH = maxY - minY; // 892 x 585
const flip = (pts) => pts.map(([x, y]) => [+(x - minX).toFixed(1), +(maxY - y).toFixed(1)]);
const d = (pts) => 'M' + flip(pts).map((p) => p.join(' ')).join('L') + 'Z';

const lin = (id, x1, y1, x2, y2, stops) =>
  `<linearGradient id="${id}" gradientUnits="userSpaceOnUse" x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}">` +
  stops.map(([o, c, a]) => `<stop offset="${o}" stop-color="${c}"${a !== undefined ? ` stop-opacity="${a}"` : ''}/>`).join('') +
  '</linearGradient>';

// V in its own coordinate box (0..892 x 0..585). `p` prefixes gradient ids.
function vDefs(p) {
  return lin(`${p}L`, 0, 0, 440, VH, [[0, C.redHi], [0.45, C.red], [1, C.redDeep]]) +
    lin(`${p}R`, VW, 0, 440, VH, [[0, C.blueHi], [0.5, C.blue], [1, C.blueDeep]]) +
    lin(`${p}K`, 340, 0, 520, VH, [[0, C.blueCrease, 0.0], [0.45, C.blueCrease, 0.55], [1, C.blueCrease, 0.9]]) +
    lin(`${p}C`, 340, VH, 550, VH, [[0, C.capLight], [0.55, '#ff3a6e'], [1, C.magenta]]) +
    lin(`${p}S`, 0, 0, 300, VH, [[0, '#ffffff', 0.32], [1, '#ffffff', 0]]) +
    lin(`${p}D`, 0, VH - 200, 0, VH, [[0, C.shadow, 0], [1, C.shadow, 0.55]]);
}
function vBody(p, detail = true) {
  return `<path d="${d(A.left)}" fill="url(#${p}L)"/>` +
    (detail ? `<path d="${d(A.streak)}" fill="url(#${p}S)"/>` : '') +
    `<path d="${d(A.right)}" fill="url(#${p}R)"/>` +
    (detail ? `<path d="${d(A.crease)}" fill="url(#${p}K)"/>` : '') +
    (detail ? `<path d="${d(A.capShadowL)}" fill="url(#${p}D)"/><path d="${d(A.capShadowR)}" fill="url(#${p}D)"/>` : '') +
    `<path d="${d(A.cap)}" fill="url(#${p}C)"/>`;
}

const svg = (vb, body, label = 'CrizaVoise') =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vb}" role="img" aria-label="${label}">${body}</svg>`;

// Plated app icon on a 1024 canvas; the V fills 70% of the width (80% in the
// small-size variant), optically centred.
function iconSvg(p, detail = true, rounded = true, fill = 0.70) {
  const S = 1024, vw = S * fill, k = vw / VW, vh = VH * k;
  const tx = (S - vw) / 2, ty = (S - vh) / 2 + S * 0.01;
  const plate = rounded
    ? `<rect width="${S}" height="${S}" rx="${S * 0.22}" fill="url(#${p}P)"/>` +
      `<rect x="6" y="6" width="${S - 12}" height="${S - 12}" rx="${S * 0.22 - 6}" fill="none" stroke="#ffffff" stroke-opacity=".07" stroke-width="6"/>`
    : `<rect width="${S}" height="${S}" fill="url(#${p}P)"/>`;
  return svg(`0 0 ${S} ${S}`,
    `<defs>${lin(`${p}P`, 0, 0, 0, S, [[0, C.plateTop], [1, C.plate]])}${vDefs(p)}</defs>${plate}` +
    `<g transform="translate(${tx.toFixed(1)} ${ty.toFixed(1)}) scale(${k.toFixed(5)})">${vBody(p, detail)}</g>`);
}

const files = {
  'mark.svg': iconSvg('m'),
  'mark-small.svg': iconSvg('s', false, true, 0.80),
  'symbol.svg': svg(`-20 -20 ${VW + 40} ${VH + 40}`, `<defs>${vDefs('y')}</defs>${vBody('y')}`),
  'symbol-mono.svg': svg(`-20 -20 ${VW + 40} ${VH + 40}`,
    `<g fill="currentColor"><path d="${d(A.left)}"/><path d="${d(A.right)}"/></g>` +
    `<path d="${d(A.cap)}" fill="none" stroke="#fff" stroke-opacity="0" />`),
};

// ---- Lockup: "CRIZA VOISE." (mirrors Criza's build-logo.mjs) --------------------
async function buildLockup(height, theme) {
  const ink = theme === 'dark' ? C.inkDark : C.inkLight;
  const FONT_SIZE = Math.round(height * 0.32);
  const GAP = Math.round(height * 0.14);

  const master = await sharp(MASTER).trim({ threshold: 10 }).png().toBuffer({ resolveWithObject: true });
  const raw = await sharp(master.data).raw().toBuffer({ resolveWithObject: true });
  const inkInColumn = (x) => {
    for (let y = 0; y < raw.info.height; y++) if (raw.data[(y * raw.info.width + x) * raw.info.channels + 3] > 40) return true;
    return false;
  };
  let split = raw.info.width - 1;
  while (split > 0 && inkInColumn(split)) split--;
  const lettersWidth = split;
  while (lettersWidth > 0 && !inkInColumn(split)) split--;

  let criza = await sharp(master.data).extract({ left: 0, top: 0, width: split + 1, height: master.info.height })
    .resize({ height, kernel: 'lanczos3' }).png().toBuffer({ resolveWithObject: true });
  let dotSrc = await sharp(master.data)
    .extract({ left: lettersWidth + 1, top: 0, width: master.info.width - lettersWidth - 1, height: master.info.height })
    .trim({ threshold: 10 }).png().toBuffer();

  // Light backgrounds: the silver letters/dot become ink; the red A and the
  // C keep their colours (only low-saturation, bright pixels are recoloured).
  if (theme === 'light') {
    const recolor = async (buf) => {
      const r = await sharp(buf).raw().toBuffer({ resolveWithObject: true });
      const [ir, ig, ib] = [1, 3, 5].map((i) => parseInt(C.inkLight.slice(i, i + 2), 16));
      for (let i = 0; i < r.data.length; i += r.info.channels) {
        const [R, G, B] = [r.data[i], r.data[i + 1], r.data[i + 2]];
        const max = Math.max(R, G, B), min = Math.min(R, G, B);
        const sat = max === 0 ? 0 : (max - min) / max;
        if (sat < 0.16 && max > 150) { r.data[i] = ir; r.data[i + 1] = ig; r.data[i + 2] = ib; }
      }
      return sharp(r.data, { raw: r.info }).png().toBuffer({ resolveWithObject: true });
    };
    criza = await recolor(criza.data);
    dotSrc = (await recolor(dotSrc)).data;
  }

  // "VOISE" in Inter SemiBold, 0.25em tracking, outlined with fontkit.
  const inter = fontkit.openSync(path.join(FONTS, 'Inter-Variable.ttf')).getVariation({ wght: 600, opsz: 32 });
  const sc = FONT_SIZE / inter.unitsPerEm;
  const run = inter.layout('VOISE');
  let x = 0; const parts = [];
  run.glyphs.forEach((g, i) => {
    parts.push(g.path.scale(sc, -sc).translate(x * sc, inter.ascent * sc).toSVG());
    x += run.positions[i].xAdvance + (i < run.glyphs.length - 1 ? 0.25 * inter.unitsPerEm : 0);
  });
  const wW = Math.ceil(x * sc) + 4, wH = Math.ceil((inter.ascent - inter.descent) * sc);
  const word = await sharp(Buffer.from(svg(`0 0 ${wW} ${wH}`, `<path d="${parts.join('')}" fill="${ink}"/>`)), { density: 300 })
    .resize({ width: wW * 2 }).resize({ width: wW }).trim({ threshold: 0 }).png().toBuffer({ resolveWithObject: true });

  // Baseline: lowest solid row across "RIZ".
  const { data, info } = await sharp(criza.data).raw().toBuffer({ resolveWithObject: true });
  const solid = (y) => { let c = 0; for (let xx = Math.round(info.width * 0.25); xx < Math.round(info.width * 0.6); xx++) if (data[(y * info.width + xx) * info.channels + 3] > 128) c++; return c; };
  let baseline = info.height - 1;
  while (baseline > 0 && solid(baseline) < 5) baseline--;

  const DOT = Math.round(word.info.height * 0.5);
  const dot = await sharp(dotSrc).resize({ width: DOT, height: DOT, fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } }).png().toBuffer();
  const DOT_GAP = Math.round(FONT_SIZE * 0.12);
  const width = criza.info.width + GAP + word.info.width + DOT_GAP + DOT;
  return sharp({ create: { width, height, channels: 4, background: { r: 0, g: 0, b: 0, alpha: 0 } } })
    .composite([
      { input: criza.data, left: 0, top: 0 },
      { input: word.data, left: criza.info.width + GAP, top: baseline + 1 - word.info.height },
      { input: dot, left: criza.info.width + GAP + word.info.width + DOT_GAP, top: baseline + 1 - DOT },
    ]).png({ compressionLevel: 9 }).toBuffer();
}

const png = (s, w) => sharp(Buffer.from(s), { density: 300 }).resize(w, w, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } }).png().toBuffer();

function ico(entries) {
  const header = Buffer.alloc(6); header.writeUInt16LE(0, 0); header.writeUInt16LE(1, 2); header.writeUInt16LE(entries.length, 4);
  const dir = Buffer.alloc(16 * entries.length); let off = 6 + dir.length;
  entries.forEach(({ size, data }, i) => {
    const o = i * 16; dir.writeUInt8(size >= 256 ? 0 : size, o); dir.writeUInt8(size >= 256 ? 0 : size, o + 1);
    dir.writeUInt16LE(1, o + 4); dir.writeUInt16LE(32, o + 6); dir.writeUInt32LE(data.length, o + 8); dir.writeUInt32LE(off, o + 12); off += data.length;
  });
  return Buffer.concat([header, dir, ...entries.map((e) => e.data)]);
}

(async () => {
  fs.mkdirSync(previewDir, { recursive: true });
  const lockDark = await buildLockup(216, 'dark');
  const lockLight = await buildLockup(216, 'light');

  // ---- Family sheet: Criza Labs next to CrizaVoise -------------------------------
  const W = 1500, H = 980;
  const crizaIcon = await sharp(path.join(crizaRoot, 'public', 'brand', 'icon-512.png')).resize(200).png().toBuffer();
  const crizaLabs = await sharp(path.join(crizaRoot, 'public', 'brand', 'logo-labs.png')).resize({ height: 72 }).png().toBuffer();
  const ld = await sharp(lockDark).resize({ height: 72 }).png().toBuffer();
  const ll = await sharp(lockLight).resize({ height: 72 }).png().toBuffer();
  const ourIcon = await png(files['mark.svg'], 200);
  const sizes = [16, 24, 32, 48];
  const smalls = []; let sx = 760;
  for (const s of sizes) { smalls.push({ input: await png(s < 48 ? files['mark-small.svg'] : files['mark.svg'], s), left: sx, top: 905 - s }); sx += s + 30; }
  const smallsLight = []; sx = 1060;
  for (const s of sizes) { smallsLight.push({ input: await png(s < 48 ? files['mark-small.svg'] : files['mark.svg'], s), left: sx, top: 905 - s }); sx += s + 30; }
  const bg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}">` +
    `<rect width="${W}" height="${H}" fill="#08090d"/><rect x="0" y="560" width="${W}" height="${H - 560}" fill="#08090d"/>` +
    `<rect x="40" y="580" width="680" height="360" rx="16" fill="#f4efe6"/>` +
    `<rect x="1040" y="840" width="${W - 1080}" height="100" rx="12" fill="#f3f3f3"/>` +
    `<g font-family="Segoe UI, Arial" fill="#b3b7c2" font-size="22" font-weight="600">` +
    `<text x="40" y="44">PARENT · Criza Labs</text><text x="760" y="44">PRODUCT · CrizaVoise</text>` +
    `<text x="760" y="820">16 · 24 · 32 · 48 px (dark / light taskbar)</text></g></svg>`;
  await sharp(Buffer.from(bg)).composite([
    { input: crizaIcon, left: 40, top: 80 }, { input: crizaLabs, left: 40, top: 330 },
    { input: ourIcon, left: 760, top: 80 }, { input: ld, left: 760, top: 330 },
    { input: ll, left: 80, top: 640 },
    { input: await sharp(lockLight).resize({ height: 44 }).png().toBuffer(), left: 80, top: 760 },
    { input: await png(files['symbol.svg'], 160), left: 520, top: 690 },
    ...smalls, ...smallsLight,
  ]).png().toFile(path.join(previewDir, 'family.png'));
  if (previewOnly) { console.log('preview written'); return; }

  // ---- Write assets ---------------------------------------------------------------
  const outBrand = path.join(repo, 'assets', 'brand');
  const outDocs = path.join(repo, 'docs', 'brand');
  for (const dir of [outBrand, outDocs]) {
    fs.mkdirSync(dir, { recursive: true });
    for (const f of fs.readdirSync(dir)) if (/\.(svg|png)$/.test(f)) fs.unlinkSync(path.join(dir, f));
    for (const [n, s] of Object.entries(files)) fs.writeFileSync(path.join(dir, n), s);
    fs.writeFileSync(path.join(dir, 'lockup-dark.png'), lockDark);
    fs.writeFileSync(path.join(dir, 'lockup-light.png'), lockLight);
  }
  fs.copyFileSync(path.join(previewDir, 'family.png'), path.join(outDocs, 'family.png'));

  const icons = path.join(outBrand, 'icons'); fs.mkdirSync(icons, { recursive: true });
  for (const f of fs.readdirSync(icons)) fs.unlinkSync(path.join(icons, f));
  fs.writeFileSync(path.join(icons, 'icon-1024.png'), await png(files['mark.svg'], 1024));
  // Android adaptive: V inside the 66% safe zone on a navy layer.
  const fgVb = `${-VW * 0.62} ${-VH * 0.62 - VW * 0.31} ${VW * 2.24} ${VW * 2.24}`;
  fs.writeFileSync(path.join(icons, 'android-foreground.png'), await png(svg(fgVb, `<defs>${vDefs('a')}</defs>${vBody('a')}`), 1024));
  fs.writeFileSync(path.join(icons, 'android-background.png'),
    await png(svg('0 0 64 64', `<defs>${lin('b', 0, 0, 0, 64, [[0, C.plateTop], [1, C.plate]])}</defs><rect width="64" height="64" fill="url(#b)"/>`), 1024));
  const icoSizes = [16, 20, 24, 30, 32, 36, 40, 48, 60, 64, 72, 80, 96, 256];
  const entries = [];
  for (const s of icoSizes) entries.push({ size: s, data: await png(s < 48 ? files['mark-small.svg'] : files['mark.svg'], s) });
  fs.writeFileSync(path.join(repo, 'windows', 'runner', 'resources', 'app_icon.ico'), ico(entries));
  fs.writeFileSync(path.join(repo, 'web', 'favicon.png'), await png(files['mark-small.svg'], 32));
  for (const s of [192, 512]) {
    fs.writeFileSync(path.join(repo, 'web', 'icons', `Icon-${s}.png`), await png(files['mark.svg'], s));
    fs.writeFileSync(path.join(repo, 'web', 'icons', `Icon-maskable-${s}.png`), await png(iconSvg('w', true, false, 0.56), s));
  }
  // OG image
  const og = `<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630"><defs>` +
    `<radialGradient id="r1" cx="10%" cy="0%" r="65%"><stop offset="0" stop-color="${C.red}" stop-opacity=".22"/><stop offset="1" stop-color="${C.plate}" stop-opacity="0"/></radialGradient>` +
    `<radialGradient id="r2" cx="95%" cy="100%" r="70%"><stop offset="0" stop-color="${C.blue}" stop-opacity=".22"/><stop offset="1" stop-color="${C.plate}" stop-opacity="0"/></radialGradient></defs>` +
    `<rect width="1200" height="630" fill="#08090d"/><rect width="1200" height="630" fill="url(#r1)"/><rect width="1200" height="630" fill="url(#r2)"/>` +
    `<text x="600" y="520" text-anchor="middle" font-family="Segoe UI, Arial" font-size="30" fill="#b3b7c2">Invoices made simple · criza.dev</text></svg>`;
  const ogLock = await sharp(lockDark).resize({ width: 760 }).png().toBuffer();
  const ogMeta = await sharp(ogLock).metadata();
  await sharp(Buffer.from(og)).composite([
    { input: await png(files['mark.svg'], 170), left: 515, top: 110 },
    { input: ogLock, left: Math.round(600 - ogMeta.width / 2), top: 330 },
  ]).png().toFile(path.join(repo, 'web', 'og.png'));
  console.log('assets written');
})();
