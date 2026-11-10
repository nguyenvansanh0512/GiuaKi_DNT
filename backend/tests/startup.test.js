const { test } = require('node:test');
const assert = require('node:assert/strict');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
// Match src/server.js: database configuration is imported before the model.
const { connectDatabase } = require('../src/config/database');
const User = require('../src/models/User');

test('Startup: model nhập trước kết nối vẫn khởi tạo collection và unique index', { timeout: 180000 }, async () => {
  let mongo;
  try {
    // Let automatic model initialization run while still disconnected.
    await new Promise(resolve => setImmediate(resolve));
    mongo = await MongoMemoryServer.create();
    await connectDatabase(mongo.getUri());
    await User.init();
    const indexes = await User.collection.indexes();
    assert.ok(indexes.some(index => index.key.email === 1 && index.unique === true));
    assert.equal(mongoose.get('bufferCommands'), false);
    assert.equal(await User.countDocuments(), 0);
  } finally {
    await mongoose.disconnect();
    if (mongo) await mongo.stop();
  }
});
