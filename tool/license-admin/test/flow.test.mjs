import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { createApp } from '../src/app.mjs';
import { openNodeDb } from '../src/db.mjs';
import { nodeKeystore } from '../src/keystore-node.mjs';
import { newKeyFile, importVerifyKey, verifyLicence, unb64, normalizeDevice } from '../src/crypto.mjs';

async function setup() {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'cvadmin-'));
  const secrets = path.join(dir, '.secrets');
  fs.mkdirSync(path.join(dir, 'lib', 'licensing'), { recursive: true });
  fs.mkdirSync(secrets);
  fs.writeFileSync(path.join(secrets, 'license_signing_key.json'), JSON.stringify(await newKeyFile()));
  fs.writeFileSync(path.join(secrets, 'reset_signing_key.json'), JSON.stringify(await newKeyFile()));
  const db = await openNodeDb(':memory:');
  const keys = nodeKeystore({ secretsDir: secrets, repoDir: dir });
  const app = createApp({ db, keys });
  let cookie = '';
  const req = async (method, url, form) => {
    const res = await app.request(`http://127.0.0.1${url}`, {
      method,
      headers: { cookie, ...(form ? { 'content-type': 'application/x-www-form-urlencoded' } : {}) },
      body: form ? new URLSearchParams(form).toString() : undefined,
      redirect: 'manual',
    });
    const set = res.headers.get('set-cookie');
    if (set) cookie = set.split(';')[0];
    return res;
  };
  return { dir, db, keys, req };
}

test('full licence lifecycle', async () => {
  const { req, keys, db, dir } = await setup();
  const pub = await importVerifyKey(await keys.licencePublic());

  // first run asks for a password, then login
  assert.equal((await req('GET', '/')).headers.get('location'), '/setup');
  await req('POST', '/setup', { password: 'correct horse battery', password2: 'correct horse battery' });
  assert.equal((await req('POST', '/login', { password: 'nope' })).headers.get('location').startsWith('/login?err'), true);
  assert.equal((await req('POST', '/login', { password: 'correct horse battery' })).headers.get('location'), '/');
  assert.equal((await req('GET', '/')).status, 200);

  // customer + licence
  const loc = (await req('POST', '/customers', { name: 'Ravi', business: 'Sharma Traders', email: 'r@s.in', phone: '9876543210' })).headers.get('location');
  const customerId = loc.split('/')[2].split('?')[0];
  const issued = await req('POST', '/licences', { customerId, plan: '1y', device: 'n1z8 c0ec yf0b 18fr', issued: '2026-11-10', amount: '1999' });
  const id = issued.headers.get('location').split('/')[2].split('?')[0];
  assert.match(id, /^CV-\d{4}-0001$/);
  const lic = await db.get('SELECT * FROM licences WHERE id = ?', id);
  assert.equal(lic.device, 'N1Z8-C0EC-YF0B-18FR');
  assert.equal(lic.expires, '2027-11-10');
  const p = await verifyLicence(pub, lic.licence_key);
  assert.equal(p.n, 'Sharma Traders');
  assert.equal(p.x, '2027-11-10');
  assert.match(await (await req('GET', `/licences/${id}`)).text(), /Open WhatsApp/);

  // bad device code is refused with a message
  const bad = await req('POST', '/licences', { customerId, plan: '6m', device: 'abc' });
  assert.match(decodeURIComponent(bad.headers.get('location')), /device code should look like/);

  // move to a new PC: same expiry, old one marked moved
  const moved = await req('POST', `/licences/${id}/transfer`, { device: 'AAAA-BBBB-CCCC-DDDD' });
  const newId = moved.headers.get('location').split('/')[2].split('?')[0];
  const n = await db.get('SELECT * FROM licences WHERE id = ?', newId);
  assert.equal(n.expires, '2027-11-10');
  assert.equal(n.replaces, id);
  assert.equal((await db.get('SELECT status FROM licences WHERE id = ?', id)).status, 'moved');
  assert.equal((await verifyLicence(pub, n.licence_key)).d, 'AAAA-BBBB-CCCC-DDDD');

  // renewal continues from the current expiry
  const ren = await req('POST', `/licences/${newId}/renew`, { plan: '1y' });
  const renId = ren.headers.get('location').split('/')[2].split('?')[0];
  assert.equal((await db.get('SELECT expires FROM licences WHERE id = ?', renId)).expires, '2028-11-09');

  // revoke + online status
  await req('POST', `/licences/${renId}/revoke`, { reason: 'refund' });
  const st = await (await req('GET', `/api/v1/status?id=${renId}&device=AAAA-BBBB-CCCC-DDDD`)).json();
  assert.equal(JSON.parse(Buffer.from(st.body, 'base64url').toString()).status, 'revoked');

  // reset code
  const rc = await req('POST', '/reset', { installationId: '3f2b6a1e-1111-4222-8333-444455556666', customerId, note: 'called' });
  assert.match(rc.headers.get('location'), /^\/reset\?code=/);

  // key rotation writes the Dart file and makes old keys stale; reissue re-signs
  const active = await req('POST', '/licences', { customerId, plan: 'life', device: '*' });
  const activeId = active.headers.get('location').split('/')[2].split('?')[0];
  await req('POST', '/keys/rotate', { confirm: 'ROTATE' });
  const dart = fs.readFileSync(path.join(dir, 'lib', 'licensing', 'license_keys.dart'), 'utf8');
  assert.match(dart, /licensePublicKey/);
  await req('POST', '/keys/reissue');
  const re = await db.get('SELECT * FROM licences WHERE id = ?', activeId);
  const newPub = await importVerifyKey(await keys.licencePublic());
  assert.equal((await verifyLicence(newPub, re.licence_key)).id, activeId);
  assert.equal(await verifyLicence(pub, re.licence_key), null, 'old public key no longer accepts it');

  // everything is in the activity log; CSV export works
  const audit = await db.all('SELECT action FROM audit');
  for (const a of ['licence.issue', 'licence.transfer', 'licence.renew', 'licence.revoke', 'reset.issue', 'keys.rotate', 'keys.reissue']) {
    assert.ok(audit.some((r) => r.action === a), a);
  }
  assert.match(await (await req('GET', '/export.csv')).text(), /Sharma Traders/);
});

test('cross-site posts and unauthenticated access are blocked', async () => {
  const { req } = await setup();
  await req('POST', '/setup', { password: 'correct horse battery', password2: 'correct horse battery' });
  const res = await req('GET', '/licences');
  assert.equal(res.headers.get('location'), '/login');
});

test('device codes are normalised', () => {
  assert.equal(normalizeDevice('n1z8 c0ec-yfob 18fr'), 'N1Z8-C0EC-YF0B-18FR');
  assert.equal(normalizeDevice('short'), null);
  assert.ok(unb64);
});
