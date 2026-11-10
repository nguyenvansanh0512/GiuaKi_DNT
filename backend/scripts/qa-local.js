// Explicit local QA harness only. Never imported by production server.
const { MongoMemoryServer } = require('mongodb-memory-server');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const crypto = require('node:crypto');
const { createApp } = require('../src/app');
const User = require('../src/models/User');

(async () => {
  if (!process.argv.includes('--local-only')) throw new Error('Chỉ chạy kiểm thử: node scripts/qa-local.js --local-only');
  const mongo = await MongoMemoryServer.create();
  await mongoose.connect(mongo.getUri(), { dbName: 'midterm_multiplatform' });
  await User.init();
  const config = { qaLocal: true, adminEmail: 'admin@example.com', adminHash: await bcrypt.hash('DemoAdmin@123', 12), jwtSecret: crypto.randomBytes(48).toString('hex'), origins: ['http://localhost:8080'] };
  const server = createApp(config).listen(3000, '0.0.0.0', () => console.log('QA LOCAL ONLY — MongoDB tạm thời, KHÔNG phải Atlas. API cổng 3000, collection ban đầu rỗng.'));
  for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => server.close(async () => { await mongoose.disconnect(); await mongo.stop(); process.exit(0); }));
  server.on('error', async () => { console.error('Cổng QA 3000 đang bận.'); await mongoose.disconnect(); await mongo.stop(); process.exitCode = 1; });
})().catch(e => { console.error(e.message); process.exitCode = 1; });
