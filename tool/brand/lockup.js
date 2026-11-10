// "CRIZA VOISE." lockup — built exactly like Criza's "CRIZA LABS." (see the
// Criza site's scripts/build-logo.mjs), plus png() and ico() helpers.
const path = require('path');
const fontkit = require('fontkit');
const sharp = require('sharp');

const C = { inkDark: '#f6f2ea', inkLight: '#12131a' };
let FONTS = '', MASTER = '';
function configure({ repo, crizaRoot }) {
  FONTS = path.join(repo, 'assets', 'fonts');
  MASTER = path.join(crizaRoot, 'logo', 'logo no tag.png');
}
const svg = (vb, body, label = 'CrizaVoise') =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vb}" role="img" aria-label="${label}">${body}</svg>`;

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


module.exports = { configure, buildLockup, png, ico, svg };
