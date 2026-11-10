require('../src/config/env');
const mongoose = require('mongoose');
const User = require('../src/models/User');
const { connectDatabase } = require('../src/config/database');
const { auditDocument } = require('./data-utils');
(async () => {
  await connectDatabase(process.env.MONGODB_URI);
  const docs = await User.collection.find({}).toArray();
  docs.forEach(doc => auditDocument(doc));
  console.log(`${docs.length} document hợp lệ: chỉ bốn trường nghiệp vụ và _id hệ thống.`);
})().catch(e => { console.error(e.message); process.exitCode = 1; }).finally(() => mongoose.disconnect());
