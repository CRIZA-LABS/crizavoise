// Server-rendered pages. No build step, no client framework.
import { PLANS } from './crypto.mjs';

export const h = (v) => String(v ?? '')
  .replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')
  .replaceAll('"', '&quot;').replaceAll("'", '&#39;');

const CSS = `
:root{--ink:#121316;--paper:#f6f1e7;--card:#fffdf8;--line:#e3dccd;--muted:#5d5a52;--stamp:#c8231c;--stamp-ink:#fff;--ok:#1a7d4c;--warn:#a86400;--bad:#c9302a;--chip:#efe8da}
@media (prefers-color-scheme:dark){:root{--paper:#121316;--card:#1b1d22;--line:#2c2f36;--muted:#a9a59b;--stamp:#ff5a4c;--stamp-ink:#121316;--chip:#24272e;--ok:#4cc38a;--warn:#e6a23c;--bad:#ff7a70}body{color:#f1ece2}}
*{box-sizing:border-box}body{margin:0;font:15px/1.5 Inter,system-ui,Segoe UI,sans-serif;background:var(--paper);color:var(--ink)}
a{color:var(--stamp)}header{background:#121316;color:#f6f1e7;display:flex;align-items:center;gap:24px;padding:0 24px;height:56px;position:sticky;top:0;z-index:2}
header b{font:800 17px/1 "Bricolage Grotesque",Inter,sans-serif;letter-spacing:.02em}header b i{color:#ff5a4c;font-style:normal}
header nav{display:flex;gap:4px;flex-wrap:wrap}header nav a{color:#d9d3c7;text-decoration:none;padding:6px 10px;border-radius:8px}header nav a.on,header nav a:hover{background:#2a2c31;color:#fff}
header form{margin-left:auto}main{max-width:1100px;margin:0 auto;padding:24px 16px 64px}
h1{font:800 26px/1.2 "Bricolage Grotesque",Inter,sans-serif;margin:0 0 4px}h2{font-size:18px;margin:28px 0 10px}.sub{color:var(--muted);margin:0 0 20px}
.card{background:var(--card);border:1px solid var(--line);border-radius:14px;padding:18px;margin-bottom:16px}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:12px}
.stat{background:var(--card);border:1px solid var(--line);border-radius:14px;padding:14px 16px}.stat b{display:block;font-size:24px}.stat span{color:var(--muted);font-size:13px}
table{width:100%;border-collapse:collapse;background:var(--card);border:1px solid var(--line);border-radius:14px;overflow:hidden}
th,td{text-align:left;padding:10px 12px;border-bottom:1px solid var(--line);vertical-align:top}th{font-size:12px;text-transform:uppercase;letter-spacing:.04em;color:var(--muted)}tr:last-child td{border-bottom:0}
.mono{font-family:Consolas,Menlo,monospace;font-size:13px}.muted{color:var(--muted)}
label{display:block;font-weight:600;font-size:13px;margin:12px 0 4px}input,select,textarea{width:100%;padding:10px 12px;border:1px solid var(--line);border-radius:10px;background:var(--card);color:inherit;font:inherit}
input:focus,select:focus,textarea:focus{outline:2px solid var(--stamp);outline-offset:1px}
.row{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:0 16px}
button,.btn{display:inline-flex;align-items:center;gap:6px;border:0;border-radius:10px;padding:10px 16px;font:600 14px/1 inherit;cursor:pointer;background:var(--stamp);color:var(--stamp-ink);text-decoration:none;margin-top:14px;min-height:40px}
.btn.ghost,button.ghost{background:transparent;color:inherit;border:1px solid var(--line)}button.danger{background:var(--bad);color:#fff}
.pill{display:inline-block;padding:2px 10px;border-radius:999px;font-size:12px;font-weight:700;background:var(--chip)}
.s-active{color:var(--ok)}.s-expiring{color:var(--warn)}.s-expired,.s-revoked{color:var(--bad)}.s-moved,.s-renewed{color:var(--muted)}
.flash{padding:12px 14px;border-radius:10px;margin-bottom:16px;border:1px solid}.flash.ok{border-color:var(--ok)}.flash.err{border-color:var(--bad)}
.keybox{width:100%;min-height:110px;font-family:Consolas,Menlo,monospace;font-size:13px;word-break:break-all}
.actions{display:flex;gap:8px;flex-wrap:wrap}.tabs a{margin-right:12px}
@media (max-width:640px){header{height:auto;flex-wrap:wrap;padding:10px 16px;gap:8px}header form{margin-left:0}table{display:block;overflow-x:auto}}
`;

const NAV = [
  ['/', 'Dashboard'], ['/customers', 'Customers'], ['/licences', 'Licences'],
  ['/reset', 'Reset codes'], ['/inspect', 'Check a key'], ['/keys', 'Keys'], ['/audit', 'Activity'],
];

export function layout({ title, body, path = '', flash, authed = true }) {
  const nav = authed
    ? `<nav>${NAV.map(([href, label]) => `<a href="${href}" class="${(href === '/' ? path === '/' : path.startsWith(href)) ? 'on' : ''}">${label}</a>`).join('')}</nav>
       <form method="post" action="/logout"><button class="ghost" style="margin:0;color:#d9d3c7;border-color:#3a3d44">Sign out</button></form>`
    : '';
  const f = flash ? `<div class="flash ${flash.type === 'err' ? 'err' : 'ok'}" role="status">${h(flash.text)}</div>` : '';
  return `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${h(title)} · CrizaVoise Licences</title><meta name="robots" content="noindex,nofollow"><style>${CSS}</style></head>
<body><header><b>CRIZA VOISE<i>.</i> <span style="font-weight:500;opacity:.7">Licences</span></b>${nav}</header>
<main>${f}${body}</main>
<script>document.querySelectorAll('[data-copy]').forEach(b=>b.addEventListener('click',()=>{const t=document.getElementById(b.dataset.copy);navigator.clipboard.writeText(t.value||t.textContent);b.textContent='Copied';setTimeout(()=>b.textContent='Copy',1500)}));
document.querySelectorAll('form[data-confirm]').forEach(f=>f.addEventListener('submit',e=>{if(!confirm(f.dataset.confirm))e.preventDefault()}));</script>
</body></html>`;
}

export const statusPill = (s) => `<span class="pill s-${h(s)}">${h(s)}</span>`;
export const planLabel = (p) => PLANS[p]?.label ?? p;
export const money = (n) => (n == null ? '' : `₹${Number(n).toLocaleString('en-IN')}`);

export function planSelect(selected = '1y') {
  return `<select name="plan" required>${Object.entries(PLANS).map(([k, v]) => `<option value="${k}" ${k === selected ? 'selected' : ''}>${v.label}${v.days ? ` (${v.days} days)` : ''}</option>`).join('')}</select>`;
}

/** Ready-to-send message for the customer (WhatsApp / email). */
export function keyMessage(l, c) {
  const exp = l.expires ? `valid until ${l.expires}` : 'lifetime licence';
  return `Hello ${c.name},

Thank you for choosing CrizaVoise! Here is your licence key (${planLabel(l.plan)}, ${exp}) for the computer with device code ${l.device}:

${l.licence_key}

How to activate: open CrizaVoise > Settings > Licence, paste the whole key in "Enter licence key" and press Activate.

Licence number: ${l.id}
Criza Labs`;
}
