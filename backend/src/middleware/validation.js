const sharp = require('sharp');
const fields = ['email', 'matkhau', 'hoten', 'hinhanh'];
const fail = message => Object.assign(new Error(message), { status: 400 });

async function validateUser(body) {
  if (!body || typeof body !== 'object' || Array.isArray(body)) throw fail('Dữ liệu phải là một JSON object.');
  if (Object.keys(body).some(k => !fields.includes(k))) throw fail('Chỉ cho phép email, matkhau, hoten, hinhanh.');
  if (fields.some(k => typeof body[k] !== 'string')) throw fail('Cần đủ bốn trường kiểu chuỗi.');
  const value = { email: body.email.trim().toLowerCase(), matkhau: body.matkhau, hoten: body.hoten.trim(), hinhanh: body.hinhanh };
  if (value.email.length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value.email)) throw fail('Email không hợp lệ.');
  if (value.matkhau.length < 6 || value.matkhau.length > 128) throw fail('Mật khẩu demo phải từ 6 đến 128 ký tự.');
  if (!value.hoten || value.hoten.length > 100) throw fail('Họ tên phải từ 1 đến 100 ký tự.');
  if (value.hinhanh) {
    const match = /^data:image\/(png|jpeg);base64,([A-Za-z0-9+/]+={0,2})$/.exec(value.hinhanh);
    if (!match) throw fail('Ảnh phải là Data URI PNG/JPEG hợp lệ.');
    const bytes = Buffer.from(match[2], 'base64');
    if (bytes.length > 512 * 1024) throw fail('Ảnh sau nén tối đa 512 KB.');
    if (bytes.toString('base64') !== match[2]) throw fail('Base64 không hợp lệ.');
    try {
      const decoded = sharp(bytes, { limitInputPixels: 16000000 });
      const meta = await decoded.metadata();
      if (meta.format !== match[1] || (meta.pages || 1) > 1) throw new Error('format');
      await decoded.stats();
    } catch { throw fail('Không giải mã được ảnh PNG/JPEG hoặc ảnh quá lớn (16 megapixel).'); }
  }
  return value;
}
module.exports = { fields, validateUser, fail };
