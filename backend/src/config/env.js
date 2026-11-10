const path = require('node:path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env'), quiet: true });

function readConfig() {
  const config = {
    host: process.env.HOST || '0.0.0.0',
    port: Number(process.env.PORT || 3000),
    mongoUri: process.env.MONGODB_URI || '',
    adminEmail: (process.env.ADMIN_EMAIL || '').trim().toLowerCase(),
    adminHash: process.env.ADMIN_PASSWORD_HASH || '',
    jwtSecret: process.env.JWT_SECRET || '',
    origins: (process.env.CORS_ORIGINS || 'http://localhost:8080').split(',').map(s => s.trim()).filter(Boolean)
  };
  if (!config.adminEmail || !/^\$2[aby]\$\d{2}\$.{53}$/.test(config.adminHash)) {
    throw new Error('Chưa cấu hình Admin. Chạy npm run setup:demo hoặc npm run hash.');
  }
  if (config.jwtSecret.length < 32 || config.jwtSecret.includes('REPLACE_WITH')) {
    throw new Error('JWT_SECRET phải là chuỗi ngẫu nhiên ít nhất 32 ký tự.');
  }
  if (!Number.isInteger(config.port) || config.port < 1 || config.port > 65535) throw new Error('PORT không hợp lệ.');
  return config;
}
module.exports = { readConfig };
