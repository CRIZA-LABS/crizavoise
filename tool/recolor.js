// Codemod: replace hard-coded Material/Tailwind colours in screens and
// widgets with meaning-based CvSwatch constants (lib/theme/swatch.dart).
//   blue/indigo/purple/cyan/blueGrey... (decorative) -> neutral
//   green/teal                                       -> success
//   orange/amber/yellow                              -> warning
//   red/deepOrange/pink                              -> danger
// Shades 50/100 -> …Tint, 200/300 -> …Soft, everything else -> plain.
// Files that use colours as DATA (PDF colour pickers, template previews,
// report chart series) are excluded. Colors.white/black/grey/transparent are
// left alone. Usage: node tool/recolor.js [--dry]
const fs = require('fs');
const path = require('path');

const ROOTS = ['lib/screens', 'lib/widgets'];
const EXCLUDE = [
  'lib/screens/screens_v1/', // legacy, unused
  'lib/screens/settings/pdf_settings_screen_v2.dart', // invoice colour picker (user data)
  'lib/screens/onboarding/onboarding_step_appearance.dart', // invoice colour picker
  'lib/widgets/template_list_tile.dart', // PDF template previews
  'lib/screens/reports_screen.dart', // chart series need distinct colours; done by hand
];
const dry = process.argv.includes('--dry');

const FAMILY = {
  blue: 'neutral', blueAccent: 'neutral', lightBlue: 'neutral', lightBlueAccent: 'neutral',
  indigo: 'neutral', indigoAccent: 'neutral', cyan: 'neutral', cyanAccent: 'neutral',
  purple: 'neutral', purpleAccent: 'neutral', deepPurple: 'neutral', deepPurpleAccent: 'neutral',
  blueGrey: 'neutral',
  green: 'success', greenAccent: 'success', lightGreen: 'success', teal: 'success', tealAccent: 'success',
  orange: 'warning', orangeAccent: 'warning', amber: 'warning', amberAccent: 'warning', yellow: 'warning',
  red: 'danger', redAccent: 'danger', deepOrange: 'danger', deepOrangeAccent: 'danger', pink: 'danger', pinkAccent: 'danger',
};
const HEX = {
  // decorative blues/purples/cyans -> neutral
  '7C3AED': 'neutral', '1565C0': 'neutral', '6A1B9A': 'neutral', '2563EB': 'neutral', '1D4ED8': 'neutral',
  '3B82F6': 'neutral', '1E40AF': 'neutral', '0891B2': 'neutral', '002E78': 'neutral', '6D28D9': 'neutral',
  '4F46E5': 'neutral', '0EA5E9': 'neutral', '6366F1': 'neutral', '8B5CF6': 'neutral', '1E3A5F': 'neutral',
  '93C5FD': 'neutralSoft', 'BFDBFE': 'neutralSoft', 'C7D2FE': 'neutralSoft', 'DDD6FE': 'neutralSoft', 'A5F3FC': 'neutralSoft',
  'EFF6FF': 'neutralTint', 'EEF2FF': 'neutralTint', 'F5F3FF': 'neutralTint', 'ECFEFF': 'neutralTint', 'F0F9FF': 'neutralTint',
  'DBEAFE': 'neutralTint', 'E0E7FF': 'neutralTint', 'EDE9FE': 'neutralTint', 'CFFAFE': 'neutralTint', 'E3F2FD': 'neutralTint',
  // slate greys used as light-only fills/borders/text
  'F8FAFC': 'neutralTint', 'F1F5F9': 'neutralTint', 'E5E7EB': 'neutralSoft', 'E2E8F0': 'neutralSoft', 'CBD5E1': 'neutralSoft',
  '94A3B8': 'neutral', '64748B': 'neutral', '475569': 'neutral', '334155': 'neutral',
  // greens -> success
  '16A34A': 'success', '2E7D32': 'success', '22C55E': 'success', '059669': 'success', '0F766E': 'success',
  '047857': 'success', '15803D': 'success', '10B981': 'success', '1B5E20': 'success', '388E3C': 'success',
  'BBF7D0': 'successSoft', 'A7F3D0': 'successSoft', 'DCFCE7': 'successTint', 'F0FDF4': 'successTint', 'ECFDF5': 'successTint', 'E8F5E9': 'successTint',
  // ambers/oranges -> warning
  'F59E0B': 'warning', 'F57C00': 'warning', 'E65100': 'warning', 'D97706': 'warning', '92400E': 'warning',
  'EA580C': 'warning', 'B45309': 'warning', 'C2410C': 'warning', 'EF6C00': 'warning',
  'FDE68A': 'warningSoft', 'FED7AA': 'warningSoft', 'FCD34D': 'warningSoft',
  'FFFBEB': 'warningTint', 'FEF3C7': 'warningTint', 'FFF7ED': 'warningTint', 'FFEDD5': 'warningTint', 'FFF3E0': 'warningTint',
  // leftovers found in screenshots
  '065F46': 'success', '6EE7B7': 'successSoft', '155E75': 'neutral', '67E8F9': 'neutralSoft',
  '5B21B6': 'neutral', 'C4B5FD': 'neutralSoft', '546E7A': 'neutral', '9A3412': 'warning',
  'FDBA74': 'warningSoft', 'F5F5F5': 'neutralTint',
  // reds -> danger
  'DC2626': 'danger', 'C62828': 'danger', 'B71C1C': 'danger', 'EF4444': 'danger', '991B1B': 'danger',
  '7C2D12': 'danger', 'B91C1C': 'danger', 'D32F2F': 'danger', 'E53935': 'danger', 'F44336': 'danger',
  'FECACA': 'dangerSoft', 'FCA5A5': 'dangerSoft', 'FEE2E2': 'dangerTint', 'FEF2F2': 'dangerTint', 'FFEBEE': 'dangerTint',
};

const strength = (shade) => {
  if (shade == null) return '';
  const n = parseInt(shade, 10);
  if (n <= 100) return 'Tint';
  if (n <= 300) return 'Soft';
  return '';
};

function files(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((e) => {
    const p = path.join(dir, e.name).replace(/\\/g, '/');
    if (e.isDirectory()) return files(p);
    return p.endsWith('.dart') ? [p] : [];
  });
}

let total = 0;
const report = [];
for (const root of ROOTS) {
  for (const f of files(root)) {
    if (EXCLUDE.some((x) => f.startsWith(x))) continue;
    let s = fs.readFileSync(f, 'utf8');
    let n = 0;
    // Colors.family(.shadeNNN | [NNN])?  — not followed by an identifier char
    s = s.replace(/\bColors\.([a-zA-Z]+)(?:\.shade(\d+)|\[(\d+)\])?(?![A-Za-z0-9_])/g, (m, fam, sh1, sh2) => {
      const fam2 = FAMILY[fam];
      if (!fam2) return m;
      n++;
      return `CvSwatch.${fam2}${strength(sh1 ?? sh2)}`;
    });
    // Colors.red[700]! style null-assert left behind -> remove the "!"
    s = s.replace(/(CvSwatch\.[a-zA-Z]+)!/g, '$1');
    s = s.replace(/\bColor\(0x[Ff]{2}([0-9A-Fa-f]{6})\)/g, (m, hex) => {
      const t = HEX[hex.toUpperCase()];
      if (!t) return m;
      n++;
      return `CvSwatch.${t}`;
    });
    if (n === 0) continue;
    if (!s.includes("package:crizavoise/theme/swatch.dart")) {
      // add the import after the last package import
      const imports = [...s.matchAll(/^import '[^']+';\r?\n/gm)];
      const last = imports[imports.length - 1];
      const at = last ? last.index + last[0].length : 0;
      s = s.slice(0, at) + "import 'package:crizavoise/theme/swatch.dart';\n" + s.slice(at);
    }
    total += n;
    report.push(`${String(n).padStart(4)}  ${f}`);
    if (!dry) fs.writeFileSync(f, s);
  }
}
console.log(report.sort().reverse().join('\n'));
console.log(`${dry ? '[dry] ' : ''}replaced ${total} colours in ${report.length} files`);
