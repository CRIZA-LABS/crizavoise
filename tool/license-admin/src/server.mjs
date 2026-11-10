// Local entry point: http://127.0.0.1:8787 (this computer only).
//   cd tool/license-admin && npm install && npm start
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { serve } from '@hono/node-server';
import { createApp } from './app.mjs';
import { openNodeDb } from './db.mjs';
import { nodeKeystore } from './keystore-node.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const repoDir = path.resolve(here, '..', '..', '..');
const secretsDir = process.env.CV_SECRETS_DIR || path.join(repoDir, '.secrets');
const dataDir = process.env.CV_ADMIN_DATA || path.join(secretsDir, 'admin');
fs.mkdirSync(dataDir, { recursive: true });

const db = await openNodeDb(path.join(dataDir, 'licences.db'));
const keys = nodeKeystore({ secretsDir, repoDir });
const app = createApp({ db, keys });

const port = Number(process.env.PORT || 8787);
serve({ fetch: app.fetch, hostname: '127.0.0.1', port }, () => {
  console.log(`CrizaVoise licence admin: http://127.0.0.1:${port}`);
  console.log(`Data: ${dataDir}  (inside .secrets: back it up with your keys)`);
});
