require('../src/config/env');
const mongoose = require('mongoose');
const fs = require('node:fs');
const path = require('node:path');
const User = require('../src/models/User');
const { connectDatabase } = require('../src/config/database');
const { auditDocument } = require('./data-utils');
(async () => {
  await connectDatabase(process.env.MONGODB_URI);
  // Đọc toàn bộ document để phát hiện trường thừa trước khi loại _id.
  const docs = await User.collection.find({}).sort({ email: 1 }).toArray();
  const rows = docs.map(doc => auditDocument(doc));
  const target = path.resolve(__dirname, '../../database/users.export.json');
  fs.writeFileSync(target, JSON.stringify(rows, null, 2) + '\n');
  console.log(`Đã xuất ${rows.length} bản ghi thật, đúng bốn trường, vào database/users.export.json. Không thay đổi collection.`);
})().catch(e => { console.error(e.message); process.exitCode = 1; }).finally(() => mongoose.disconnect());
