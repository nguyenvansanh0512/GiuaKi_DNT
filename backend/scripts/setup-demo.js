const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const bcrypt = require('bcryptjs');
(async () => {
  const target = path.resolve(__dirname, '../.env');
  const template = fs.readFileSync(path.resolve(__dirname, '../.env.example'), 'utf8');
  const content = template.replace('REPLACE_WITH_BCRYPT_HASH', await bcrypt.hash('DemoAdmin@123', 12)).replace('REPLACE_WITH_LONG_RANDOM_SECRET', crypto.randomBytes(48).toString('hex'));
  fs.writeFileSync(target, content, { flag: 'wx', mode: 0o600 });
  console.log('Đã tạo .env. Admin demo: admin@example.com / DemoAdmin@123. Điền MONGODB_URI trước khi chạy. Không ghi đè file đã tồn tại.');
})().catch(e => { console.error(e.code === 'EEXIST' ? '.env đã tồn tại; không thay đổi. Tự chỉnh cấu hình nếu cần.' : e.message); process.exitCode = 1; });
