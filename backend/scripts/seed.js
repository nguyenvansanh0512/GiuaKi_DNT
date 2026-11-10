require('../src/config/env');

const mongoose = require('mongoose');
const fs = require('node:fs');
const path = require('node:path');
const User = require('../src/models/User');
const { connectDatabase } = require('../src/config/database');
const { validateUser } = require('../src/middleware/validation');
const { auditDocument } = require('./data-utils');
(async () => {
  const rows = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../../database/users.json'), 'utf8'));
  const values = await Promise.all(rows.map(row => validateUser(auditDocument(row, false))));
  await connectDatabase(process.env.MONGODB_URI);
  await User.init();
  let added = 0;
  for (const value of values) {
    const result = await User.updateOne({ email: value.email }, { $setOnInsert: value }, { upsert: true, runValidators: true });
    added += result.upsertedCount;
  }
  console.log(`Đã thêm ${added} bản ghi mẫu; giữ nguyên bản ghi có email đã tồn tại.`);
})().catch(e => { console.error(e.message); process.exitCode = 1; }).finally(() => mongoose.disconnect());
