// CrizaVoise mark (v4) — "the bill being printed".
//
// A shop bill coming out of a thermal printer slot: the everyday moment at
// every small-business counter (kirana, retail, service shops). The slot is a
// Criza-blue bar; the bill has a torn zig-zag edge; its items lead to a bold
// TOTAL line that ends in the Criza Labs red dot — the same full stop that
// ends "CRIZA." and "CRIZA VOISE.".
//
// Built flat on a 64-unit grid. Optical corrections (docs/brand.md §3):
//  - the group is centred on visual mass: the heavy bar sits on top, so the
//    whole mark is lowered 0.6u from the bounding-box centre,
//  - the slot bar overhangs the bill by 5u each side so the T-silhouette
//    survives at 16 px,
//  - the dot is ~1.3x the total line's height so it reads as a round "stop",
//  - a 2u shadow band under the slot makes the bill read as emerging from it
//    (dropped at small sizes).

const COLORS = {
  navy: '#031326', // Criza app-icon navy
  navyLift: '#0b2442',
  paper: '#ffffff',
  blue: '#0a7fe0', // Criza blue (from the C), deepened for contrast on white
  blueBright: '#2fb4ff', // same hue for use on navy
  red: '#f61b15', // Criza red (the A / the dot)
};

// Geometry (64 grid, before centring offset)
const SLOT = { x: 13, y: 13.5, w: 38, h: 8.4 };
const STRIP = { x: 18.5, y: 17.5, w: 27, h: 28 }; // body above the teeth
const TEETH = 4; // across the width
const TOOTH = 3.6; // depth

function stripPath({ teeth = true } = {}) {
  const { x, y, w, h } = STRIP;
  const b = y + h;
  let d = `M${x} ${y} H${x + w} V${b}`;
  if (teeth) {
    const tw = w / TEETH;
    for (let i = TEETH - 1; i >= 0; i--) {
      d += ` L${(x + i * tw + tw / 2).toFixed(2)} ${b + TOOTH} L${(x + i * tw).toFixed(2)} ${b}`;
    }
  } else {
    d += ` H${x}`;
  }
  return d + ' Z';
}

const pill = (x, y, w, h, fill, op = 1) =>
  `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${h / 2}" fill="${fill}"${op < 1 ? ` fill-opacity="${op}"` : ''}/>`;

function contents({ theme, small }) {
  const ink = theme === 'dark' ? COLORS.navy : COLORS.paper;
  const op = theme === 'dark' ? 0.3 : 0.55;
  const x0 = STRIP.x + 5.5;
  if (small) {
    return pill(x0, 28.5, 12, 4.4, ink, op) +
      pill(x0, 36.4, 10, 5.4, ink) +
      `<circle cx="${x0 + 14.4}" cy="39.1" r="3.6" fill="${COLORS.red}"/>`;
  }
  return pill(x0, 27.5, 15, 3.4, ink, op) +
    pill(x0, 33.2, 9.5, 3.4, ink, op) +
    pill(x0, 39.4, 10.5, 4.4, ink) +
    `<circle cx="${x0 + 14.3}" cy="41.6" r="2.9" fill="${COLORS.red}"/>`;
}

function slot({ theme, small }) {
  const bar = theme === 'dark' ? COLORS.blueBright : COLORS.blue;
  const shade = small ? '' :
    `<rect x="${STRIP.x}" y="${SLOT.y + SLOT.h}" width="${STRIP.w}" height="2.2" fill="${COLORS.navy}" fill-opacity="${theme === 'dark' ? 0.16 : 0.35}"/>`;
  return shade + `<rect x="${SLOT.x}" y="${SLOT.y}" width="${SLOT.w}" height="${SLOT.h}" rx="${SLOT.h / 2}" fill="${bar}"/>`;
}

// visual-mass centring offset
const OFF = { x: 0, y: 0.6 };
// The mark is drawn at 1.1x about the plate centre (fills ~65% of the tile).
const SCALE = 1.1;
const grp = (inner) => `<g transform="translate(32 32) scale(${SCALE}) translate(-32 -32)">${inner}</g>`;

/**
 * theme: 'dark' (navy plate, white paper) | 'light' (white plate, navy paper)
 * small: 16–47 px variant (no teeth detail lost: teeth kept, fewer lines)
 * plate: false → transparent background
 */
function markSvg({ theme = 'dark', small = false, plate = true } = {}) {
  const paper = theme === 'dark' ? COLORS.paper : COLORS.navy;
  const body0 = `<g transform="translate(${OFF.x} ${OFF.y})">` +
    `<path d="${stripPath({ teeth: true })}" fill="${paper}"/>` +
    contents({ theme, small }) + slot({ theme, small }) + '</g>';
  const body = grp(body0);
  let plateSvg = '';
  if (plate) {
    plateSvg = theme === 'dark'
      ? `<rect width="64" height="64" rx="14.5" fill="${COLORS.navy}"/><rect x=".6" y=".6" width="62.8" height="62.8" rx="13.9" fill="none" stroke="${COLORS.navyLift}" stroke-width="1.2"/>`
      : `<rect width="64" height="64" rx="14.5" fill="#ffffff"/><rect x=".5" y=".5" width="63" height="63" rx="14" fill="none" stroke="#031326" stroke-opacity=".12"/>`;
  }
  // Unplated: the roll's separating ring must match the background, so the
  // unplated symbol is drawn for its theme's background.
  const vb = plate ? '0 0 64 64' : '9 9 46 46';
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vb}" role="img" aria-label="CrizaVoise">${plateSvg}${body}</svg>`;
}

function monoSvg() {
  // one colour: bill + slot in currentColor; contents knocked out of the bill,
  // and a hairline gap separates the slot from the bill.
  const x0 = STRIP.x + 5.5;
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="9 9 46 46" role="img" aria-label="CrizaVoise"><defs><mask id="k">` +
    `<rect width="64" height="64" fill="#fff"/><g transform="translate(${OFF.x} ${OFF.y})">` +
    pill(x0, 27.5, 15, 3.4, '#000') + pill(x0, 33.2, 9.5, 3.4, '#000') + pill(x0, 39.4, 10.5, 4.4, '#000') +
    `<circle cx="${x0 + 14.3}" cy="41.6" r="2.9" fill="#000"/>` +
    `<rect x="${STRIP.x}" y="${SLOT.y + SLOT.h}" width="${STRIP.w}" height="1.6" fill="#000"/></g></mask></defs>` +
    `<g transform="translate(32 32) scale(${SCALE}) translate(-32 -32)"><g fill="currentColor" mask="url(#k)" transform="translate(${OFF.x} ${OFF.y})"><path d="${stripPath()}"/>` +
    `<rect x="${SLOT.x}" y="${SLOT.y}" width="${SLOT.w}" height="${SLOT.h}" rx="${SLOT.h / 2}"/></g></g></svg>`;
}

module.exports = { markSvg, monoSvg, COLORS };
