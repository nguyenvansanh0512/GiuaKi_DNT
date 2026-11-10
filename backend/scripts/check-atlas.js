require('../src/config/env');
const mongoose = require('mongoose');
const { connectDatabase } = require('../src/config/database');

(async () => {
  await connectDatabase(process.env.MONGODB_URI);
  const result = await mongoose.connection.db.command({ ping: 1 });
  if (result.ok !== 1) throw new Error('MongoDB chưa xác nhận ping thành công.');
  console.log('MongoDB ping thành công. Kiểm tra chỉ đọc, không sửa dữ liệu.');
})().catch(() => {
  // Do not print raw driver errors, URI, account details or environment values.
  console.error('Kiểm tra MongoDB chưa thành công. Kiểm tra DNS, mạng, Network Access và cấu hình backend.');
  process.exitCode = 1;
}).finally(() => mongoose.disconnect());
