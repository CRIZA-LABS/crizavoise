// Licence business logic. Pure: needs only a db adapter and a keystore, so
// it runs the same locally and on Cloudflare Workers.
import {
  PLANS, addDays, isoDate, normalizeDevice, signLicence, signResetCode, verifyLicence,
  importVerifyKey, unb64,
} from './crypto.mjs';

const now = () => new Date().toISOString();
const today = () => isoDate(Date.now());
const uid = () => crypto.randomUUID();

export class LicenceError extends Error {}

export function createService({ db, keys }) {
  async function audit(action, detail) {
    await db.run('INSERT INTO audit (at, action, detail) VALUES (?, ?, ?)', now(), action,
      typeof detail === 'string' ? detail : JSON.stringify(detail));
  }

  async function setting(key, fallback = null) {
    const r = await db.get('SELECT value FROM settings WHERE key = ?', key);
    return r ? r.value : fallback;
  }
  async function setSetting(key, value) {
    await db.run('INSERT INTO settings (key, value) VALUES (?, ?) ON CONFLICT(key) DO UPDATE SET value = excluded.value', key, value);
  }

  async function generation() {
    return Number(await setting('key_generation', '1'));
  }

  async function nextLicenceId() {
    const year = new Date().getUTCFullYear();
    const k = `seq_${year}`;
    const n = Number(await setting(k, '0')) + 1;
    await setSetting(k, String(n));
    return `CV-${year}-${String(n).padStart(4, '0')}`;
  }

  /** Effective status shown in the UI. */
  function statusOf(l, on = today()) {
    if (l.status !== 'active') return l.status; // revoked / moved / renewed
    if (l.expires && l.expires < on) return 'expired';
    if (l.expires && l.expires <= addDays(on, 30)) return 'expiring';
    return 'active';
  }

  // ---------- customers ----------
  async function saveCustomer(c) {
    if (!c.name?.trim()) throw new LicenceError('Customer name is required.');
    const fields = ['name', 'business', 'email', 'phone', 'city', 'notes'].map((f) => (c[f] ?? '').trim());
    if (c.id) {
      await db.run('UPDATE customers SET name=?, business=?, email=?, phone=?, city=?, notes=? WHERE id=?', ...fields, c.id);
      await audit('customer.update', { id: c.id, name: fields[0] });
      return c.id;
    }
    const id = uid();
    await db.run('INSERT INTO customers (id, name, business, email, phone, city, notes, created_at) VALUES (?,?,?,?,?,?,?,?)', id, ...fields, now());
    await audit('customer.create', { id, name: fields[0] });
    return id;
  }

  const getCustomer = (id) => db.get('SELECT * FROM customers WHERE id = ?', id);

  async function listCustomers(q = '') {
    const like = `%${q.trim()}%`;
    return db.all(
      `SELECT c.*, (SELECT COUNT(*) FROM licences l WHERE l.customer_id = c.id AND l.status = 'active') AS active_count
       FROM customers c
       WHERE ? = '%%' OR c.name LIKE ? OR c.business LIKE ? OR c.email LIKE ? OR c.phone LIKE ?
          OR c.id IN (SELECT customer_id FROM licences WHERE device LIKE ? OR id LIKE ?)
       ORDER BY c.created_at DESC`,
      like, like, like, like, like, like, like);
  }

  // ---------- licences ----------
  async function sign(l, customer) {
    return signLicence(await keys.licenceKey(), {
      id: l.id, name: customer.business || customer.name, email: customer.email,
      plan: l.plan, issued: l.issued, expires: l.expires, device: l.device,
    });
  }

  async function issue({ customerId, plan, device, issued, expires, amount, paymentRef, notes, replaces }) {
    const customer = await getCustomer(customerId);
    if (!customer) throw new LicenceError('Choose a customer.');
    if (!PLANS[plan]) throw new LicenceError('Choose a plan.');
    const dev = device === '*' ? '*' : normalizeDevice(device || '');
    if (!dev) throw new LicenceError('The device code should look like 7KQ2-M9XD-4TPA-0WRC (16 letters and numbers).');
    const iss = issued || today();
    const exp = expires !== undefined ? expires : (PLANS[plan].days == null ? null : addDays(iss, PLANS[plan].days));
    const l = {
      id: await nextLicenceId(), customer_id: customerId, plan, device: dev, issued: iss, expires: exp,
      replaces: replaces ?? null, key_generation: await generation(),
      amount: amount === '' || amount == null ? null : Number(amount), payment_ref: paymentRef ?? '', notes: notes ?? '',
    };
    l.licence_key = await sign(l, customer);
    await db.run(
      `INSERT INTO licences (id, customer_id, plan, device, issued, expires, licence_key, status, replaces, key_generation, amount, payment_ref, notes, created_at)
       VALUES (?,?,?,?,?,?,?,'active',?,?,?,?,?,?)`,
      l.id, l.customer_id, l.plan, l.device, l.issued, l.expires, l.licence_key, l.replaces, l.key_generation,
      l.amount, l.payment_ref, l.notes, now());
    await audit('licence.issue', { id: l.id, customer: customer.name, plan, device: dev, expires: exp, replaces: l.replaces });
    return l;
  }

  const getLicence = (id) => db.get('SELECT * FROM licences WHERE id = ?', id);

  async function listLicences({ customerId, q } = {}) {
    if (customerId) return db.all('SELECT * FROM licences WHERE customer_id = ? ORDER BY created_at DESC', customerId);
    const like = `%${(q || '').trim()}%`;
    return db.all(
      `SELECT l.*, c.name AS customer_name, c.business AS customer_business FROM licences l
       JOIN customers c ON c.id = l.customer_id
       WHERE ? = '%%' OR l.id LIKE ? OR l.device LIKE ? OR c.name LIKE ? OR c.business LIKE ?
       ORDER BY l.created_at DESC`, like, like, like, like, like);
  }

  async function mustBeActive(id) {
    const l = await getLicence(id);
    if (!l) throw new LicenceError('Licence not found.');
    if (l.status !== 'active') throw new LicenceError(`This licence is already ${l.status}.`);
    return l;
  }

  /** Renewal on the same computer: continues from the old expiry if it's still in the future. */
  async function renew(id, { plan, amount, paymentRef, notes }) {
    const old = await mustBeActive(id);
    if (!old.expires) throw new LicenceError('Lifetime licences never need renewing.');
    const from = old.expires > today() ? old.expires : today();
    const p = plan || old.plan;
    const fresh = await issue({
      customerId: old.customer_id, plan: p, device: old.device, issued: today(),
      expires: PLANS[p].days == null ? null : addDays(from, PLANS[p].days),
      amount, paymentRef, notes: notes || `Renewal of ${old.id}`, replaces: old.id,
    });
    await db.run("UPDATE licences SET status = 'renewed', replaced_by = ? WHERE id = ?", fresh.id, old.id);
    await audit('licence.renew', { from: old.id, to: fresh.id });
    return fresh;
  }

  /** Customer changed computer: same plan and expiry on the new device; the old one is marked moved. */
  async function transfer(id, { device, notes }) {
    const old = await mustBeActive(id);
    const dev = normalizeDevice(device || '');
    if (!dev) throw new LicenceError('Enter the new computer’s device code.');
    if (dev === old.device) throw new LicenceError('That is the same computer.');
    const fresh = await issue({
      customerId: old.customer_id, plan: old.plan, device: dev, issued: today(), expires: old.expires,
      notes: notes || `Moved from ${old.device} (${old.id})`, replaces: old.id,
    });
    await db.run("UPDATE licences SET status = 'moved', replaced_by = ? WHERE id = ?", fresh.id, old.id);
    await audit('licence.transfer', { from: old.id, to: fresh.id, oldDevice: old.device, newDevice: dev });
    return fresh;
  }

  async function revoke(id, reason) {
    await mustBeActive(id);
    await db.run("UPDATE licences SET status = 'revoked', notes = COALESCE(notes,'') || ? WHERE id = ?",
      `\nRevoked ${today()}: ${reason || ''}`, id);
    await audit('licence.revoke', { id, reason });
  }

  async function updateNotes(id, notes) {
    await db.run('UPDATE licences SET notes = ? WHERE id = ?', notes, id);
  }

  /** Paste a key a customer sent: shows what it is and whether we issued it. */
  async function inspectKey(key) {
    const pub = await keys.licencePublic();
    const payload = await verifyLicence(await importVerifyKey(pub), key);
    if (!payload) return { valid: false };
    const ours = await getLicence(payload.id);
    return { valid: true, payload, licence: ours };
  }

  // ---------- reset codes ----------
  async function resetCode({ installationId, customerId, note }) {
    const inst = (installationId || '').trim();
    if (!/^[0-9a-fA-F-]{8,64}$/.test(inst)) throw new LicenceError('Paste the installation ID from the customer’s Forgot password screen.');
    const code = await signResetCode(await keys.resetKey(), inst);
    await db.run('INSERT INTO reset_codes (customer_id, installation_id, code, note, created_at) VALUES (?,?,?,?,?)',
      customerId || null, inst, code, note || '', now());
    await audit('reset.issue', { installationId: inst, customerId });
    return code;
  }

  // ---------- keys ----------
  /** After a key rotation: re-sign every active licence with the new key (same id, device, dates). */
  async function reissueActive() {
    const gen = await generation();
    const rows = await db.all("SELECT * FROM licences WHERE status = 'active' AND key_generation < ?", gen);
    for (const l of rows) {
      const customer = await getCustomer(l.customer_id);
      const key = await sign(l, customer);
      await db.run('UPDATE licences SET licence_key = ?, key_generation = ? WHERE id = ?', key, gen, l.id);
    }
    await audit('keys.reissue', { count: rows.length, generation: gen });
    return rows.length;
  }

  async function stats() {
    const all = await db.all('SELECT status, expires, amount, created_at FROM licences');
    const t = today();
    const s = { customers: (await db.get('SELECT COUNT(*) n FROM customers')).n, active: 0, expiring: 0, expired: 0, lifetime: 0, revenue: 0, thisMonth: 0 };
    for (const l of all) {
      const st = statusOf(l, t);
      if (st === 'active' || st === 'expiring') s.active++;
      if (st === 'expiring') s.expiring++;
      if (st === 'expired') s.expired++;
      if (l.status === 'active' && !l.expires) s.lifetime++;
      s.revenue += l.amount || 0;
      if (l.created_at.slice(0, 7) === t.slice(0, 7)) s.thisMonth += l.amount || 0;
    }
    return s;
  }

  const recentAudit = (limit = 200) => db.all('SELECT * FROM audit ORDER BY id DESC LIMIT ?', limit);

  /** Status for the online licence check (used once the app is hosted). */
  async function onlineStatus(id, device) {
    const l = await getLicence(id);
    if (!l) return { id, status: 'unknown' };
    const dev = normalizeDevice(device || '') || device;
    return { id, status: l.device === dev || l.device === '*' ? statusOf(l) : 'other-device', expires: l.expires };
  }

  return {
    audit, setting, setSetting, generation, statusOf,
    saveCustomer, getCustomer, listCustomers,
    issue, getLicence, listLicences, renew, transfer, revoke, updateNotes, inspectKey,
    resetCode, reissueActive, stats, recentAudit, onlineStatus,
    resetHistory: (customerId) => customerId
      ? db.all('SELECT * FROM reset_codes WHERE customer_id = ? ORDER BY id DESC', customerId)
      : db.all('SELECT r.*, c.name AS customer_name FROM reset_codes r LEFT JOIN customers c ON c.id = r.customer_id ORDER BY r.id DESC LIMIT 100'),
  };
}

export { unb64 };
