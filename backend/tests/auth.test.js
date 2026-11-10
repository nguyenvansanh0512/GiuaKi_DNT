const { test } = require('node:test');
const assert = require('node:assert/strict');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('node:crypto');
const request = require('supertest');
const { createApp } = require('../src/app');

test('Admin login: bcrypt, chuẩn hóa email, token và thông tin thiếu/sai tên trường', async () => {
  // Generated credentials belong only to this test; never read local secrets.
  const password = crypto.randomBytes(16).toString('hex');
  const config = {
    adminEmail: 'qa-admin@example.com',
    adminHash: await bcrypt.hash(password, 4),
    jwtSecret: crypto.randomBytes(48).toString('hex'),
    origins: ['http://localhost:8080']
  };
  const app = createApp(config);
  for (const body of [
    {}, { email: config.adminEmail }, { matkhau: password },
    { email: '', matkhau: password }, { email: '   ', matkhau: password },
    { email: config.adminEmail, matkhau: '' },
    { email: config.adminEmail, password },
    { email: config.adminEmail, matkhau: null }
  ]) {
    const response = await request(app).post('/api/auth/login').send(body).expect(400);
    assert.equal(response.body.token, undefined);
  }
  await request(app).post('/api/auth/login').send({ email: config.adminEmail, matkhau: 'incorrect-test-input' }).expect(401);
  await request(app).post('/api/auth/login').send({ email: 'other@example.com', matkhau: password }).expect(401);
  const response = await request(app).post('/api/auth/login').send({ email: ' QA-ADMIN@EXAMPLE.COM ', matkhau: password }).expect(200);
  const claims = jwt.verify(response.body.token, config.jwtSecret, {
    algorithms: ['HS256'], issuer: 'midterm-api', audience: 'midterm-admin'
  });
  assert.equal(claims.sub, config.adminEmail);
  assert.equal(claims.exp - claims.iat, 7200);
  assert.deepEqual(Object.keys(response.body).sort(), ['expiresIn', 'token']);
});
