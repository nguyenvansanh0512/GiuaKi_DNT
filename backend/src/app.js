const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const { rateLimit } = require('express-rate-limit');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { requireAuth } = require('./middleware/auth');

function createApp(config) {
  const app = express();
  app.disable('x-powered-by');
  app.use(helmet());
  app.use(cors({ origin(origin, cb) {
    if (!origin || config.origins.includes(origin)) return cb(null, true);
    cb(Object.assign(new Error('Origin không được cấp quyền CORS.'), { status: 403 }));
  } }));
  app.use(express.json({ limit: '800kb' }));
  app.get('/api/health', (_req, res) => {
    const connected = mongoose.connection.readyState === 1;
    res.status(connected ? 200 : 503).json({ status: connected ? 'ok' : 'unavailable', database: connected ? 'connected' : 'disconnected', ...(config.qaLocal ? { testEnvironment: 'local-ephemeral' } : {}) });
  });
  app.post('/api/auth/login', rateLimit({ windowMs: 15 * 60 * 1000, limit: 20, standardHeaders: 'draft-8', legacyHeaders: false, message: { message: 'Quá nhiều lần đăng nhập. Thử lại sau 15 phút.' } }), async (req, res) => {
    const { email, matkhau } = req.body || {};
    if (typeof email !== 'string' || typeof matkhau !== 'string' || !email.trim() || !matkhau || email.length > 254 || matkhau.length > 128) return res.status(400).json({ message: 'Email và mật khẩu không hợp lệ.' });
    const matched = await bcrypt.compare(matkhau, config.adminHash);
    if (email.trim().toLowerCase() !== config.adminEmail || !matched) return res.status(401).json({ message: 'Email hoặc mật khẩu Admin không đúng.' });
    const token = jwt.sign({}, config.jwtSecret, { algorithm: 'HS256', subject: config.adminEmail, issuer: 'midterm-api', audience: 'midterm-admin', expiresIn: '2h' });
    res.json({ token, expiresIn: 7200 });
  });
  app.use('/api/users', requireAuth(config), require('./routes/users'));
  app.use((_req, res) => res.status(404).json({ message: 'Endpoint không tồn tại.' }));
  app.use((error, _req, res, _next) => {
    let status = error.status || 500;
    let message = status < 500 ? error.message : 'Lỗi máy chủ. Vui lòng thử lại.';
    if (error.code === 11000) { status = 409; message = 'Email đã tồn tại.'; }
    if (['ValidationError', 'StrictModeError', 'CastError'].includes(error.name)) { status = 400; message = 'Dữ liệu không hợp lệ hoặc có trường ngoài quy định.'; }
    if (error.type === 'entity.too.large') { status = 413; message = 'Request quá lớn (tối đa 800 KB).'; }
    if (error.type === 'entity.parse.failed') { status = 400; message = 'JSON không hợp lệ.'; }
    if (/Mongo|Mongoose/.test(error.name) && status === 500) { status = 503; message = 'MongoDB không khả dụng. Kiểm tra kết nối Atlas.'; }
    res.status(status).json({ message });
  });
  return app;
}
module.exports = { createApp };
