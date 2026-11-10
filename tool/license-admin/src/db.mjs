// Storage: plain SQL that SQLite (node:sqlite, locally) and Cloudflare D1
// both accept. Every call is async so a D1 adapter can be swapped in.

export const SCHEMA = `
CREATE TABLE IF NOT EXISTS customers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  business TEXT,
  email TEXT,
  phone TEXT,
  city TEXT,
  notes TEXT,
  created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS licences (
  id TEXT PRIMARY KEY,
  customer_id TEXT NOT NULL REFERENCES customers(id),
  plan TEXT NOT NULL,
  device TEXT NOT NULL,
  issued TEXT NOT NULL,
  expires TEXT,
  licence_key TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  replaces TEXT,
  replaced_by TEXT,
  key_generation INTEGER NOT NULL DEFAULT 1,
  amount REAL,
  payment_ref TEXT,
  notes TEXT,
  created_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_lic_customer ON licences(customer_id);
CREATE INDEX IF NOT EXISTS idx_lic_device ON licences(device);
CREATE TABLE IF NOT EXISTS reset_codes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id TEXT,
  installation_id TEXT NOT NULL,
  code TEXT NOT NULL,
  note TEXT,
  created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS audit (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  at TEXT NOT NULL,
  action TEXT NOT NULL,
  detail TEXT
);
CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT
);
`;

/** node:sqlite adapter (local). */
export async function openNodeDb(path) {
  const { DatabaseSync } = await import('node:sqlite');
  const db = new DatabaseSync(path);
  db.exec('PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON;');
  db.exec(SCHEMA);
  const norm = (p) => p.map((v) => (v === undefined ? null : v));
  return {
    all: async (sql, ...p) => db.prepare(sql).all(...norm(p)).map((r) => ({ ...r })),
    get: async (sql, ...p) => {
      const r = db.prepare(sql).get(...norm(p));
      return r ? { ...r } : null;
    },
    run: async (sql, ...p) => db.prepare(sql).run(...norm(p)),
    close: () => db.close(),
  };
}

/** Cloudflare D1 adapter (for a future hosted deployment). */
export function d1Db(d1) {
  return {
    all: async (sql, ...p) => (await d1.prepare(sql).bind(...p).all()).results,
    get: async (sql, ...p) => (await d1.prepare(sql).bind(...p).first()) ?? null,
    run: async (sql, ...p) => d1.prepare(sql).bind(...p).run(),
    close: () => {},
  };
}
