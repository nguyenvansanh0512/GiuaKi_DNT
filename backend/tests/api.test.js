const { test, before, after } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const request = require('supertest');
const sharp = require('sharp');
const { createApp } = require('../src/app');
const User = require('../src/models/User');
const { auditDocument } = require('../scripts/data-utils');
const { validateUser } = require('../src/middleware/validation');
const { connectDatabase } = require('../src/config/database');

let mongo, app, token, id, image;
const config = { adminEmail: 'admin@example.com', adminHash: '', jwtSecret: 'test-only-secret-with-more-than-32-characters', origins: ['http://localhost:8080'] };
const user = { email: 'an@example.com', matkhau: 'Demo123456', hoten: 'Nguyễn Văn An', hinhanh: '' };
const auth = req => req.set('Authorization', `Bearer ${token}`);
before(async () => {
  mongo = await MongoMemoryServer.create();
  await mongoose.connect(mongo.getUri(), { dbName: 'midterm_multiplatform' });
  await User.init();
  config.adminHash = await bcrypt.hash('DemoAdmin@123', 4);
  app = createApp(config);
  image = 'data:image/png;base64,' + (await sharp({ create: { width: 2, height: 2, channels: 3, background: '#123456' } }).png().toBuffer()).toString('base64');
}, { timeout: 180000 });
after(async () => { await mongoose.disconnect(); if (mongo) await mongo.stop(); });

test('01 login đúng/sai, token trả về có hạn dùng', async () => {
  await request(app).post('/api/auth/login').send({ email: config.adminEmail, matkhau: 'wrong' }).expect(401);
  await request(app).post('/api/auth/login').send({ email: {}, matkhau: [] }).expect(400);
  const res = await request(app).post('/api/auth/login').send({ email: config.adminEmail, matkhau: 'DemoAdmin@123' }).expect(200);
  token = res.body.token;
  assert.equal(res.body.expiresIn, 7200);
});
test('02 CRUD cần token; token sai/hết hạn bị chặn', async () => {
  await request(app).get('/api/users').expect(401);
  await request(app).get('/api/users').set('Authorization', 'Bearer bad').expect(401);
  const expired = jwt.sign({}, config.jwtSecret, { subject: config.adminEmail, issuer: 'midterm-api', audience: 'midterm-admin', expiresIn: -1 });
  await request(app).get('/api/users').set('Authorization', `Bearer ${expired}`).expect(401);
});
test('03 health, danh sách rỗng, CORS', async () => {
  await request(app).get('/api/health').expect(200);
  const res = await auth(request(app).get('/api/users')).expect(200);
  assert.deepEqual(res.body, { users: [], total: 0 });
  await request(app).get('/api/health').set('Origin', 'https://untrusted.example').expect(403);
  const allowed = await request(app).get('/api/health').set('Origin', 'http://localhost:8080').expect(200);
  assert.equal(allowed.headers['access-control-allow-origin'], 'http://localhost:8080');
});
test('04 thêm ảnh thật và đọc lại từ MongoDB kiểm thử', async () => {
  const res = await auth(request(app).post('/api/users')).send({ ...user, email: ' AN@EXAMPLE.COM ', hinhanh: image }).expect(201);
  id = res.body.user._id;
  assert.equal(res.body.user.email, user.email);
  const get = await auth(request(app).get(`/api/users/${id}`)).expect(200);
  assert.equal(get.body.user.hinhanh, image);
  const stored = await User.collection.findOne({ _id: new mongoose.Types.ObjectId(id) });
  assert.deepEqual(Object.keys(stored).sort(), ['_id', 'email', 'hinhanh', 'hoten', 'matkhau'].sort());
  assert.equal(auditDocument(stored).hinhanh, image);
});
test('05 email trùng (không phân biệt hoa/thường) và dữ liệu sai', async () => {
  await auth(request(app).post('/api/users')).send({ ...user, email: 'AN@example.com' }).expect(409);
  for (const value of [{ ...user, email: 'bad' }, { ...user, hoten: ' ' }, { ...user, matkhau: '123' }, { ...user, email: { $ne: null } }, { ...user, role: 'admin' }, { ...user, _id: id }, { ...user, hinhanh: 'https://example.com/a.png' }, { ...user, hinhanh: 'data:image/png;base64,YWJj' }]) {
    await auth(request(app).post('/api/users')).send(value).expect(400);
  }
  await auth(request(app).post('/api/users')).send({ ...user, hinhanh: 'x'.repeat(820000) }).expect(413);
});
test('06 sửa đúng bốn trường; không cho phép trường thừa / trùng email', async () => {
  const changed = { ...user, hoten: 'Trần Bình', hinhanh: image };
  const res = await auth(request(app).put(`/api/users/${id}`)).send(changed).expect(200);
  assert.equal(res.body.user.hoten, changed.hoten);
  await auth(request(app).put(`/api/users/${id}`)).send({ ...changed, updatedAt: 'now' }).expect(400);
  await auth(request(app).post('/api/users')).send({ ...user, email: 'second@example.com' }).expect(201);
  await auth(request(app).put(`/api/users/${id}`)).send({ ...user, email: 'second@example.com' }).expect(409);
});
test('07 tìm theo họ tên/email; ký tự regex không được thực thi', async () => {
  let res = await auth(request(app).get('/api/users').query({ q: 'Trần' })).expect(200);
  assert.equal(res.body.users.length, 1);
  assert.equal(res.body.total, 2);
  res = await auth(request(app).get('/api/users').query({ q: 'SECOND@' })).expect(200);
  assert.equal(res.body.users.length, 1);
  res = await auth(request(app).get('/api/users').query({ q: '.*' })).expect(200);
  assert.equal(res.body.users.length, 0);
});
test('08 ObjectId sai, không tồn tại, xóa đúng bản ghi', async () => {
  await auth(request(app).get('/api/users/nope')).expect(400);
  const absent = new mongoose.Types.ObjectId().toString();
  await auth(request(app).get(`/api/users/${absent}`)).expect(404);
  await auth(request(app).put(`/api/users/${absent}`)).send(user).expect(404);
  await auth(request(app).delete(`/api/users/${id}`)).expect(204);
  await auth(request(app).delete(`/api/users/${id}`)).expect(404);
  assert.equal(await User.countDocuments(), 1);
});
test('09 schema strict và toàn bộ document chỉ có bốn trường + _id', async () => {
  assert.throws(() => new User({ ...user, username: 'invalid' }), /strict/i);
  const docs = await User.collection.find({}).toArray();
  docs.forEach(doc => { assert.deepEqual(Object.keys(doc).sort(), ['_id', ...Object.keys(user)].sort()); auditDocument(doc); });
  assert.throws(() => auditDocument({ ...user, role: 'admin' }), /trường thừa/);
  assert.throws(() => auditDocument({ ...user, _id: 'id' }, false), /trường thừa/);
  const samples = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../../database/users.json'), 'utf8'));
  assert.ok(samples.length >= 5);
  for (const row of samples) { auditDocument(row, false); await validateUser(row); }
});
test('10 ảnh vượt giới hạn / giả định dạng / thiếu trường bị từ chối', async () => {
  await assert.rejects(validateUser({ ...user, hinhanh: 'data:image/png;base64,' + Buffer.alloc(513 * 1024).toString('base64') }), /512 KB/);
  await assert.rejects(validateUser({ ...user, hinhanh: image.replace('image/png', 'image/jpeg') }), /giải mã/);
  await assert.rejects(validateUser({ email: user.email }), /bốn trường/);
});
test('11 JSON lỗi, API lạ trả status phù hợp', async () => {
  await request(app).post('/api/auth/login').set('Content-Type', 'application/json').send('{bad').expect(400);
  await request(app).get('/api/nope').expect(404);
});
test('12 database mất kết nối trả 503; URI mẫu không được nhận', async () => {
  await mongoose.disconnect();
  await request(app).get('/api/health').expect(503);
  await auth(request(app).get('/api/users')).expect(503);
  await assert.rejects(connectDatabase('mongodb+srv://USERNAME:PASSWORD@CLUSTER_HOST/test'), /Chưa cấu hình/);
});
