const mongoose = require('mongoose');
const { configureMongoDns } = require('./dns');

function databaseMessage(error) {
  if (error.code === 18 || /auth|credential/i.test(error.message)) return 'Sai tài khoản hoặc mật khẩu Database User; kiểm tra URI và mã hóa ký tự đặc biệt.';
  if (/ENOTFOUND|querySrv|ECONNREFUSED/i.test(error.message)) return 'Không truy cập được database. Kiểm tra tên cluster, DNS và mạng.';
  return 'Kết nối MongoDB timeout/không khả dụng. Kiểm tra cluster đang hoạt động, Network Access/IP, firewall và URI. Không thể tự xác định chắc chắn lỗi IP từ timeout.';
}
async function connectDatabase(uri) {
  if (!uri || /USERNAME|PASSWORD|CLUSTER_HOST/.test(uri)) throw new Error('Chưa cấu hình MONGODB_URI thật trong backend/.env.');
  if (!/^mongodb(\+srv)?:\/\//.test(uri)) throw new Error('MONGODB_URI phải bắt đầu bằng mongodb:// hoặc mongodb+srv://.');
  configureMongoDns();
  try {
    await mongoose.connect(uri, { dbName: 'midterm_multiplatform', serverSelectionTimeoutMS: 10000 });
    // Models compiled before connect must be allowed to await the initial
    // connection. Disable buffering only after that connection is ready.
    mongoose.set('bufferCommands', false);
    console.log('Đã kết nối MongoDB — database midterm_multiplatform.');
  } catch (error) { throw new Error(databaseMessage(error)); }
}
module.exports = { connectDatabase, databaseMessage };
