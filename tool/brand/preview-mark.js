// Review sheet for the v4 mark: themes, small sizes on taskbars, competitors.
const fs = require('fs'); const path = require('path'); const sharp = require('sharp');
const { markSvg, monoSvg } = require('./mark');
const [, , outDir, compDir] = process.argv;
const png = (svg, w) => sharp(Buffer.from(svg), { density: 600 }).resize(w, w, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } }).png().toBuffer();
(async () => {
  const W = 1500, H = 1060; const comps = [];
  // Hero: dark + light at 220
  comps.push({ input: await png(markSvg({ theme: 'dark' }), 220), left: 60, top: 80 });
  comps.push({ input: await png(markSvg({ theme: 'light' }), 220), left: 320, top: 80 });
  comps.push({ input: await png(monoSvg().replace('currentColor', '#031326'), 150), left: 600, top: 115 });
  // Small sizes on Windows taskbars (dark #202020, light #f3f3f3)
  const sizes = [16, 20, 24, 32, 48, 64];
  for (const [row, bgTop, theme] of [[0, 430, 'dark'], [1, 430, 'light'], [2, 600, 'dark'], [3, 600, 'light']]) {
    let x = row % 2 === 0 ? 80 : 820;
    const top = bgTop + 30;
    for (const s of sizes) { comps.push({ input: await png(markSvg({ theme, small: s < 48 }), s), left: x, top: top + (64 - s) }); x += s + 34; }
  }
  // Competitors strip
  if (compDir && fs.existsSync(path.join(compDir, 'competitors.png'))) {
    comps.push({ input: await sharp(path.join(compDir, 'competitors.png')).resize({ height: 120 }).png().toBuffer(), left: 60, top: 860 });
    comps.push({ input: await png(markSvg({ theme: 'dark' }), 120), left: 640, top: 860 });
    comps.push({ input: await png(markSvg({ theme: 'light' }), 120), left: 780, top: 860 });
  }
  const bg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}">
    <rect width="${W}" height="${H}" fill="#f4efe6"/>
    <rect x="40" y="440" width="700" height="130" rx="12" fill="#202020"/><rect x="780" y="440" width="680" height="130" rx="12" fill="#f3f3f3" stroke="#ddd"/>
    <rect x="40" y="610" width="700" height="130" rx="12" fill="#f3f3f3" stroke="#ddd"/><rect x="780" y="610" width="680" height="130" rx="12" fill="#202020"/>
    <g font-family="Segoe UI, Arial" font-size="20" font-weight="600" fill="#4a4e59">
      <text x="60" y="50">CrizaVoise mark — dark / light / mono</text>
      <text x="60" y="425">16 · 20 · 24 · 32 · 48 · 64 px — matched themes (dark icon on dark bar, light on light)</text>
      <text x="60" y="595">cross-check — dark icon on light bar, light icon on dark bar</text>
      <text x="60" y="845">Competitors (Vyapar · myBillBook · Khatabook · Swipe)  vs  CrizaVoise</text></g></svg>`;
  // swap: rows 0/1 matched; rows 2/3 crossed — place accordingly
  await sharp(Buffer.from(bg)).composite(comps).png().toFile(path.join(outDir, 'mark-review.png'));
  console.log('ok');
})();
