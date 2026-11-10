const mongoose = require('mongoose');
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true, trim: true, lowercase: true, maxlength: 254 },
  matkhau: { type: String, required: true, minlength: 6, maxlength: 128 },
  hoten: { type: String, required: true, trim: true, maxlength: 100 },
  hinhanh: { type: String, default: '' }
}, { versionKey: false, timestamps: false, strict: 'throw' });
module.exports = mongoose.model('User', userSchema, 'users');
