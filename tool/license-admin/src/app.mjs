// CrizaVoise licence admin (Hono). Works on Node now and Cloudflare Workers later.
import { Hono } from 'hono';
import { getCookie, setCookie, deleteCookie } from 'hono/cookie';
import { hashPassword, checkPassword, randomToken, b64url, PLANS, signStatus } from './crypto.mjs';
import { createService, LicenceError } from './service.mjs';
import { layout, h, statusPill, planLabel, planSelect, keyMessage, money } from './views.mjs';

const enc = new TextEncoder();
const SESSION_HOURS = 12;

async function hmac(secret, text) {
  const k = await crypto.subtle.importKey('raw', enc.encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  return b64url(await crypto.subtle.sign('HMAC', k, enc.encode(text)));
}

export function createApp({ db, keys, canRotate = true }) {
  const svc = createService({ db, keys });
  const app = new Hono();
  const failures = new Map(); // ip -> {n, until}

  const secret = async () => {
    let s = await svc.setting('session_secret');
    if (!s) { s = randomToken(); await svc.setSetting('session_secret', s); }
    return s;
  };

  const page = (c, title, body, flash) =>
    c.html(layout({ title, body, path: new URL(c.req.url).pathname, flash }));

  const flashFrom = (c) => {
    const ok = c.req.query('ok'), err = c.req.query('err');
    return ok ? { type: 'ok', text: ok } : err ? { type: 'err', text: err } : null;
  };
  const back = (c, url, msg, isErr = false) =>
    c.redirect(`${url}${url.includes('?') ? '&' : '?'}${isErr ? 'err' : 'ok'}=${encodeURIComponent(msg)}`);

  // ---- security: same-origin form posts only ----
  app.use('*', async (c, next) => {
    if (c.req.method === 'POST') {
      const origin = c.req.header('origin');
      const host = new URL(c.req.url).host;
      if (origin && new URL(origin).host !== host) return c.text('Cross-site request blocked', 403);
    }
    await next();
    c.header('X-Frame-Options', 'DENY');
    c.header('Referrer-Policy', 'no-referrer');
    c.header('X-Content-Type-Options', 'nosniff');
  });

  // ---- online licence check (public; only useful once hosted) ----
  app.get('/api/v1/status', async (c) => {
    const id = c.req.query('id') || '', device = c.req.query('device') || '';
    const status = { ...(await svc.onlineStatus(id, device)), ts: new Date().toISOString() };
    return c.json(await signStatus(await keys.licenceKey(), status));
  });

  // ---- first run & sign-in ----
  app.get('/setup', async (c) => {
    if (await svc.setting('admin_password')) return c.redirect('/login');
    return page(c, 'Set up', `<h1>Set up the licence admin</h1><p class="sub">Choose the password for this admin. It protects licence keys and customer data.</p>
      <form method="post" class="card" style="max-width:420px"><label for="p">Password (12+ characters)</label><input id="p" name="password" type="password" minlength="12" required autofocus>
      <label for="p2">Type it again</label><input id="p2" name="password2" type="password" required><button>Save password</button></form>`, flashFrom(c));
  });
  app.post('/setup', async (c) => {
    if (await svc.setting('admin_password')) return c.redirect('/login');
    const f = await c.req.parseBody();
    if (String(f.password).length < 12) return back(c, '/setup', 'Use at least 12 characters.', true);
    if (f.password !== f.password2) return back(c, '/setup', 'The passwords don’t match.', true);
    await svc.setSetting('admin_password', await hashPassword(String(f.password)));
    await svc.audit('admin.setup', 'password set');
    return back(c, '/login', 'Password saved. Please sign in.');
  });

  app.get('/login', (c) => page(c, 'Sign in', `<h1>Sign in</h1><p class="sub">Criza Labs only.</p>
    <form method="post" class="card" style="max-width:420px"><label for="p">Password</label><input id="p" name="password" type="password" required autofocus><button>Sign in</button></form>`, flashFrom(c)));

  app.post('/login', async (c) => {
    const ip = c.req.header('cf-connecting-ip') || c.req.header('x-forwarded-for') || 'local';
    const f = failures.get(ip);
    if (f && f.until > Date.now()) return back(c, '/login', 'Too many attempts. Wait a few minutes.', true);
    const { password } = await c.req.parseBody();
    if (!(await checkPassword(String(password), await svc.setting('admin_password')))) {
      const n = (f?.n || 0) + 1;
      failures.set(ip, { n, until: n >= 5 ? Date.now() + 5 * 60000 : 0 });
      await svc.audit('admin.login_failed', ip);
      return back(c, '/login', 'Wrong password.', true);
    }
    failures.delete(ip);
    const exp = Date.now() + SESSION_HOURS * 3600000;
    setCookie(c, 'cv_admin', `${exp}.${await hmac(await secret(), String(exp))}`, {
      httpOnly: true, sameSite: 'Strict', path: '/', secure: new URL(c.req.url).protocol === 'https:', maxAge: SESSION_HOURS * 3600,
    });
    await svc.audit('admin.login', ip);
    return c.redirect('/');
  });

  app.post('/logout', (c) => { deleteCookie(c, 'cv_admin', { path: '/' }); return c.redirect('/login'); });

  // ---- everything below needs a session ----
  app.use('*', async (c, next) => {
    if (!(await svc.setting('admin_password'))) return c.redirect('/setup');
    const [exp, sig] = (getCookie(c, 'cv_admin') || '').split('.');
    if (!exp || Number(exp) < Date.now() || sig !== (await hmac(await secret(), exp))) return c.redirect('/login');
    await next();
  });

  // ---- dashboard ----
  app.get('/', async (c) => {
    const s = await svc.stats();
    const lic = await svc.listLicences();
    const expiring = lic.filter((l) => svc.statusOf(l) === 'expiring');
    const recent = await svc.recentAudit(8);
    return page(c, 'Dashboard', `<h1>Licences</h1><p class="sub">Issue, renew and move CrizaVoise licences. Everything stays on this computer.</p>
      <div class="grid">
        <div class="stat"><b>${s.active}</b><span>Active licences</span></div>
        <div class="stat"><b>${s.expiring}</b><span>Ending in 30 days</span></div>
        <div class="stat"><b>${s.expired}</b><span>Expired</span></div>
        <div class="stat"><b>${s.customers}</b><span>Customers</span></div>
        <div class="stat"><b>${money(s.thisMonth)}</b><span>This month</span></div>
      </div>
      <div class="actions"><a class="btn" href="/licences/new">+ Issue licence</a><a class="btn ghost" href="/customers/new">+ New customer</a><a class="btn ghost" href="/reset">Password reset code</a></div>
      <h2>Ending soon</h2>${expiring.length ? licenceTable(expiring, true) : '<p class="muted">Nothing ends in the next 30 days.</p>'}
      <h2>Recent activity</h2>${auditTable(recent)}`, flashFrom(c));
  });

  // ---- customers ----
  app.get('/customers', async (c) => {
    const q = c.req.query('q') || '';
    const rows = await svc.listCustomers(q);
    return page(c, 'Customers', `<h1>Customers</h1><p class="sub">Search by name, business, email, phone, device code or licence number.</p>
      <form class="actions" style="align-items:end"><input name="q" value="${h(q)}" placeholder="Search…" style="max-width:360px"><button class="ghost">Search</button><a class="btn" href="/customers/new">+ New customer</a></form>
      <table style="margin-top:16px"><tr><th>Name</th><th>Business</th><th>Contact</th><th>Active</th></tr>
      ${rows.map((r) => `<tr><td><a href="/customers/${h(r.id)}">${h(r.name)}</a></td><td>${h(r.business)}</td><td>${h(r.email)}<br><span class="muted">${h(r.phone)}</span></td><td>${r.active_count}</td></tr>`).join('') || '<tr><td colspan="4" class="muted">No customers yet.</td></tr>'}</table>`, flashFrom(c));
  });

  const customerForm = (cu = {}, action = '/customers') => `<form method="post" action="${action}" class="card">
    <div class="row"><div><label>Name *</label><input name="name" value="${h(cu.name)}" required></div><div><label>Business name (shown in the app)</label><input name="business" value="${h(cu.business)}"></div></div>
    <div class="row"><div><label>Email</label><input name="email" type="email" value="${h(cu.email)}"></div><div><label>Phone / WhatsApp</label><input name="phone" value="${h(cu.phone)}"></div><div><label>City</label><input name="city" value="${h(cu.city)}"></div></div>
    <label>Notes</label><textarea name="notes" rows="2">${h(cu.notes)}</textarea><button>Save customer</button></form>`;

  app.get('/customers/new', (c) => page(c, 'New customer', `<h1>New customer</h1>${customerForm()}`, flashFrom(c)));
  app.post('/customers', async (c) => {
    try {
      const id = await svc.saveCustomer(await c.req.parseBody());
      return back(c, `/customers/${id}`, 'Customer saved.');
    } catch (e) { return back(c, '/customers/new', e.message, true); }
  });
  app.get('/customers/:id', async (c) => {
    const cu = await svc.getCustomer(c.req.param('id'));
    if (!cu) return c.notFound();
    const lic = await svc.listLicences({ customerId: cu.id });
    const resets = await svc.resetHistory(cu.id);
    return page(c, cu.name, `<h1>${h(cu.name)}</h1><p class="sub">${h(cu.business)}</p>
      <div class="actions"><a class="btn" href="/licences/new?customer=${h(cu.id)}">+ Issue licence</a><a class="btn ghost" href="/reset?customer=${h(cu.id)}">Password reset code</a></div>
      <h2>Licences</h2>${lic.length ? licenceTable(lic) : '<p class="muted">No licences yet.</p>'}
      <h2>Details</h2>${customerForm(cu, `/customers/${cu.id}`)}
      <h2>Reset codes issued</h2>${resets.length ? `<table><tr><th>When</th><th>Installation ID</th><th>Note</th></tr>${resets.map((r) => `<tr><td>${h(r.created_at.slice(0, 16).replace('T', ' '))}</td><td class="mono">${h(r.installation_id)}</td><td>${h(r.note)}</td></tr>`).join('')}</table>` : '<p class="muted">None.</p>'}`, flashFrom(c));
  });
  app.post('/customers/:id', async (c) => {
    const id = c.req.param('id');
    try { await svc.saveCustomer({ ...(await c.req.parseBody()), id }); return back(c, `/customers/${id}`, 'Saved.'); } catch (e) { return back(c, `/customers/${id}`, e.message, true); }
  });

  // ---- licences ----
  function licenceTable(rows, withCustomer = false) {
    return `<table><tr><th>Licence</th>${withCustomer || rows[0]?.customer_name ? '<th>Customer</th>' : ''}<th>Plan</th><th>Device</th><th>Valid until</th><th>Status</th></tr>
      ${rows.map((l) => `<tr><td><a href="/licences/${h(l.id)}" class="mono">${h(l.id)}</a></td>${withCustomer || l.customer_name ? `<td>${h(l.customer_business || l.customer_name || '')}</td>` : ''}<td>${h(planLabel(l.plan))}</td><td class="mono">${h(l.device)}</td><td>${h(l.expires || 'Never')}</td><td>${statusPill(svc.statusOf(l))}</td></tr>`).join('')}</table>`;
  }

  app.get('/licences', async (c) => {
    const q = c.req.query('q') || '';
    const rows = await svc.listLicences({ q });
    return page(c, 'Licences', `<h1>All licences</h1>
      <form class="actions" style="align-items:end"><input name="q" value="${h(q)}" placeholder="Licence number, device code or customer…" style="max-width:420px"><button class="ghost">Search</button><a class="btn" href="/licences/new">+ Issue licence</a><a class="btn ghost" href="/export.csv">Export CSV</a></form>
      <div style="margin-top:16px">${rows.length ? licenceTable(rows, true) : '<p class="muted">No licences yet.</p>'}</div>`, flashFrom(c));
  });

  app.get('/licences/new', async (c) => {
    const customers = await svc.listCustomers();
    if (!customers.length) return back(c, '/customers/new', 'Add the customer first.', true);
    const pre = c.req.query('customer');
    return page(c, 'Issue licence', `<h1>Issue a licence</h1><p class="sub">The customer copies their device code from CrizaVoise → Settings → Licence.</p>
      <form method="post" action="/licences" class="card">
      <div class="row"><div><label>Customer *</label><select name="customerId" required>${customers.map((cu) => `<option value="${h(cu.id)}" ${cu.id === pre ? 'selected' : ''}>${h(cu.name)}${cu.business ? ` — ${h(cu.business)}` : ''}</option>`).join('')}</select></div>
      <div><label>Plan *</label>${planSelect()}</div></div>
      <div class="row"><div><label>Device code *</label><input name="device" class="mono" placeholder="7KQ2-M9XD-4TPA-0WRC" required></div>
      <div><label>Starts on</label><input name="issued" type="date" value="${new Date().toISOString().slice(0, 10)}"></div></div>
      <div class="row"><div><label>Amount paid (₹)</label><input name="amount" type="number" min="0" step="1"></div><div><label>Payment reference (UPI / invoice no.)</label><input name="paymentRef"></div></div>
      <label>Notes</label><textarea name="notes" rows="2"></textarea><button>Issue licence key</button></form>`, flashFrom(c));
  });
  app.post('/licences', async (c) => {
    const f = await c.req.parseBody();
    try {
      const l = await svc.issue({ ...f, issued: f.issued || undefined });
      return back(c, `/licences/${l.id}`, 'Licence issued. Send the key below to the customer.');
    } catch (e) {
      if (e instanceof LicenceError) return back(c, '/licences/new', e.message, true);
      throw e;
    }
  });

  app.get('/licences/:id', async (c) => {
    const l = await svc.getLicence(c.req.param('id'));
    if (!l) return c.notFound();
    const cu = await svc.getCustomer(l.customer_id);
    const st = svc.statusOf(l);
    const active = l.status === 'active';
    return page(c, l.id, `<h1 class="mono">${h(l.id)}</h1><p class="sub"><a href="/customers/${h(cu.id)}">${h(cu.name)}</a> · ${h(planLabel(l.plan))} · ${statusPill(st)}</p>
      <div class="grid"><div class="stat"><span>Device</span><b class="mono" style="font-size:16px">${h(l.device)}</b></div><div class="stat"><span>Issued</span><b style="font-size:16px">${h(l.issued)}</b></div>
      <div class="stat"><span>Valid until</span><b style="font-size:16px">${h(l.expires || 'Never (lifetime)')}</b></div><div class="stat"><span>Paid</span><b style="font-size:16px">${money(l.amount) || '—'}</b></div></div>
      ${l.replaces ? `<p>Replaces <a href="/licences/${h(l.replaces)}" class="mono">${h(l.replaces)}</a>.</p>` : ''}${l.replaced_by ? `<p>Replaced by <a href="/licences/${h(l.replaced_by)}" class="mono">${h(l.replaced_by)}</a>.</p>` : ''}
      <h2>Licence key</h2><div class="card"><textarea id="key" class="keybox" readonly>${h(l.licence_key)}</textarea><div class="actions"><button type="button" data-copy="key">Copy</button></div></div>
      <h2>Message for the customer</h2><div class="card"><textarea id="msg" class="keybox" style="min-height:220px;font-family:inherit" readonly>${h(keyMessage(l, cu))}</textarea>
      <div class="actions"><button type="button" data-copy="msg">Copy</button>${cu.phone ? `<a class="btn ghost" target="_blank" rel="noopener" href="https://wa.me/${h(String(cu.phone).replace(/\D/g, '').replace(/^0?(\d{10})$/, '91$1'))}?text=${encodeURIComponent(keyMessage(l, cu))}">Open WhatsApp</a>` : ''}${cu.email ? `<a class="btn ghost" href="mailto:${h(cu.email)}?subject=${encodeURIComponent('Your CrizaVoise licence ' + l.id)}&body=${encodeURIComponent(keyMessage(l, cu))}">Email</a>` : ''}</div></div>
      ${active ? `<div class="row">
        ${l.expires ? `<form method="post" action="/licences/${h(l.id)}/renew" class="card"><h2 style="margin-top:0">Renew</h2><p class="muted">Same computer. Continues from ${h(l.expires > new Date().toISOString().slice(0, 10) ? l.expires : 'today')}.</p><label>Plan</label>${planSelect(l.plan)}<label>Amount paid (₹)</label><input name="amount" type="number" min="0"><label>Payment reference</label><input name="paymentRef"><button>Renew</button></form>` : ''}
        <form method="post" action="/licences/${h(l.id)}/transfer" class="card" data-confirm="Move this licence to the new computer? The old key is marked as moved."><h2 style="margin-top:0">Move to a new PC</h2><p class="muted">Same plan and end date. Ask the customer to press “Remove licence” on the old PC.</p><label>New device code</label><input name="device" class="mono" required placeholder="XXXX-XXXX-XXXX-XXXX"><label>Note</label><input name="notes" placeholder="e.g. old laptop stolen"><button>Issue key for new PC</button></form>
        <form method="post" action="/licences/${h(l.id)}/revoke" class="card" data-confirm="Revoke this licence? This is recorded and can't be undone here."><h2 style="margin-top:0">Revoke</h2><p class="muted">For refunds or misuse. The app only learns about it once the online check is switched on.</p><label>Reason</label><input name="reason" required><button class="danger">Revoke licence</button></form>
      </div>` : ''}
      <h2>Notes</h2><form method="post" action="/licences/${h(l.id)}/notes" class="card"><textarea name="notes" rows="3">${h(l.notes)}</textarea><button class="ghost">Save notes</button></form>`, flashFrom(c));
  });

  const action = (name, fn) => app.post(`/licences/:id/${name}`, async (c) => {
    const id = c.req.param('id');
    try {
      const r = await fn(id, await c.req.parseBody());
      return r?.id ? back(c, `/licences/${r.id}`, `Done. New licence ${r.id}: send this key to the customer.`) : back(c, `/licences/${id}`, 'Saved.');
    } catch (e) {
      if (e instanceof LicenceError) return back(c, `/licences/${id}`, e.message, true);
      throw e;
    }
  });
  action('renew', (id, f) => svc.renew(id, f));
  action('transfer', (id, f) => svc.transfer(id, f));
  action('revoke', (id, f) => svc.revoke(id, f.reason));
  action('notes', (id, f) => svc.updateNotes(id, f.notes));

  app.get('/export.csv', async (c) => {
    const rows = await svc.listLicences();
    const q = (v) => `"${String(v ?? '').replaceAll('"', '""')}"`;
    const lines = ['licence,customer,business,plan,device,issued,expires,status,amount,payment_ref,created_at',
      ...rows.map((l) => [l.id, l.customer_name, l.customer_business, l.plan, l.device, l.issued, l.expires ?? 'never', svc.statusOf(l), l.amount ?? '', l.payment_ref, l.created_at].map(q).join(','))];
    c.header('Content-Disposition', `attachment; filename="crizavoise-licences-${new Date().toISOString().slice(0, 10)}.csv"`);
    return c.body(lines.join('\n'), 200, { 'Content-Type': 'text/csv; charset=utf-8' });
  });

  // ---- reset codes ----
  app.get('/reset', async (c) => {
    const customers = await svc.listCustomers();
    const pre = c.req.query('customer');
    const code = c.req.query('code');
    const hist = await svc.resetHistory();
    return page(c, 'Reset codes', `<h1>Password reset codes</h1><p class="sub">For a customer who lost both their password and recovery code. Confirm it's really the owner first (call them on their registered number).</p>
      ${code ? `<div class="card"><label>Code — valid about 3 days, only on that installation</label><textarea id="code" class="keybox" style="min-height:70px" readonly>${h(code)}</textarea><div class="actions"><button type="button" data-copy="code">Copy</button></div></div>` : ''}
      <form method="post" class="card"><div class="row"><div><label>Installation ID *</label><input name="installationId" class="mono" required placeholder="from Forgot password → Get a code from Criza Labs"></div>
      <div><label>Customer</label><select name="customerId"><option value="">—</option>${customers.map((cu) => `<option value="${h(cu.id)}" ${cu.id === pre ? 'selected' : ''}>${h(cu.name)}</option>`).join('')}</select></div></div>
      <label>How you verified them</label><input name="note" placeholder="e.g. called registered number, confirmed GSTIN"><button>Make reset code</button></form>
      <h2>Recent</h2>${hist.length ? `<table><tr><th>When</th><th>Customer</th><th>Installation ID</th><th>Verified by</th></tr>${hist.map((r) => `<tr><td>${h(r.created_at.slice(0, 16).replace('T', ' '))}</td><td>${h(r.customer_name || '—')}</td><td class="mono">${h(r.installation_id)}</td><td>${h(r.note)}</td></tr>`).join('')}</table>` : '<p class="muted">None yet.</p>'}`, flashFrom(c));
  });
  app.post('/reset', async (c) => {
    try {
      const code = await svc.resetCode(await c.req.parseBody());
      return c.redirect(`/reset?code=${encodeURIComponent(code)}`);
    } catch (e) { return back(c, '/reset', e.message, true); }
  });

  // ---- check a key ----
  app.get('/inspect', (c) => page(c, 'Check a key', `<h1>Check a licence key</h1><p class="sub">Paste a key a customer sent you to see what it contains and whether it's genuine.</p>
    <form method="post" class="card"><label>Licence key</label><textarea name="key" class="keybox" required></textarea><button>Check</button></form>`, flashFrom(c)));
  app.post('/inspect', async (c) => {
    const { key } = await c.req.parseBody();
    const r = await svc.inspectKey(String(key));
    const body = !r.valid
      ? '<div class="flash err">Not a genuine CrizaVoise key (or it was changed).</div>'
      : `<div class="flash ok">Genuine key, signed by Criza Labs.</div><table>${Object.entries({ Licence: r.payload.id, 'Licensed to': r.payload.n, Email: r.payload.e, Plan: planLabel(r.payload.p), Issued: r.payload.i, 'Valid until': r.payload.x || 'Never', Device: r.payload.d }).map(([k, v]) => `<tr><th>${k}</th><td>${h(v)}</td></tr>`).join('')}
        <tr><th>In our records</th><td>${r.licence ? `<a href="/licences/${h(r.licence.id)}">${h(r.licence.id)}</a> ${statusPill(svc.statusOf(r.licence))}` : 'Not found (issued with the command-line tool?)'}</td></tr></table>`;
    return page(c, 'Check a key', `<h1>Check a licence key</h1>${body}<p><a href="/inspect">Check another</a></p>`);
  });

  // ---- keys ----
  app.get('/keys', async (c) => {
    let info;
    try { info = keys.info(); } catch (e) { return page(c, 'Keys', `<h1>Signing keys</h1><div class="flash err">${h(e.message)}</div>`); }
    const gen = await svc.generation();
    const stale = (await svc.listLicences()).filter((l) => l.status === 'active' && l.key_generation < gen).length;
    return page(c, 'Keys', `<h1>Signing keys</h1><p class="sub">Generation ${gen}. Private keys are in <span class="mono">${h(info.secretsDir)}</span>. Back that folder up offline.</p>
      <table><tr><th>Key</th><th>Created</th><th>Public key</th></tr><tr><td>Licences</td><td>${h(info.licence.created)}</td><td class="mono">${h(info.licence.public)}</td></tr><tr><td>Reset codes</td><td>${h(info.reset.created)}</td><td class="mono">${h(info.reset.public)}</td></tr></table>
      ${stale ? `<div class="card"><h2 style="margin-top:0">Re-issue ${stale} active licence(s)</h2><p>These were signed with an older key. Re-sign them with the current key (same numbers, devices and dates), then send each customer their new key after they update the app.</p><form method="post" action="/keys/reissue"><button>Re-issue now</button></form></div>` : ''}
      ${canRotate ? `<form method="post" action="/keys/rotate" class="card" data-confirm="Really rotate the keys?"><h2 style="margin-top:0">Rotate keys</h2>
        <p><b>Only if a private key may have leaked.</b> After rotating:</p><ol><li>Every key already issued stops working in <b>new</b> app builds (old builds keep accepting old keys).</li><li><span class="mono">lib/licensing/license_keys.dart</span> is updated. Rebuild and ship the app.</li><li>Use “Re-issue” here and send every active customer a new key.</li></ol>
        <p>The old keys are kept in <span class="mono">.secrets/retired-…</span>.</p><label>Type ROTATE to confirm</label><input name="confirm" required pattern="ROTATE"><button class="danger">Rotate keys</button></form>` : ''}`, flashFrom(c));
  });
  app.post('/keys/rotate', async (c) => {
    if (!canRotate) return c.text('Not available here', 403);
    const { confirm } = await c.req.parseBody();
    if (confirm !== 'ROTATE') return back(c, '/keys', 'Type ROTATE to confirm.', true);
    const r = await keys.rotate();
    await svc.setSetting('key_generation', String((await svc.generation()) + 1));
    await svc.audit('keys.rotate', r);
    return back(c, '/keys', 'New keys made and license_keys.dart updated. Rebuild the app, then re-issue licences.');
  });
  app.post('/keys/reissue', async (c) => {
    const n = await svc.reissueActive();
    return back(c, '/licences', `${n} licence(s) re-signed with the current key.`);
  });

  // ---- activity ----
  function auditTable(rows) {
    return rows.length ? `<table><tr><th>When</th><th>What</th><th>Details</th></tr>${rows.map((a) => `<tr><td>${h(a.at.slice(0, 16).replace('T', ' '))}</td><td>${h(a.action)}</td><td class="mono" style="font-size:12px">${h(a.detail)}</td></tr>`).join('')}</table>` : '<p class="muted">Nothing yet.</p>';
  }
  app.get('/audit', async (c) => page(c, 'Activity', `<h1>Activity</h1><p class="sub">Every licence, reset code and key change, newest first.</p>${auditTable(await svc.recentAudit(500))}`));

  app.onError((err, c) => {
    console.error(err);
    return c.html(layout({ title: 'Error', body: `<h1>Something went wrong</h1><div class="flash err">${h(err.message)}</div><p><a href="/">Back to dashboard</a></p>`, authed: false }), 500);
  });

  return app;
}

export { PLANS };
