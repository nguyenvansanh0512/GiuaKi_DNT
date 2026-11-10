const mongoose = require('mongoose');
const User = require('../models/User');
const { validateUser, fail } = require('../middleware/validation');

function checkId(req, _res, next) {
  if (!/^[a-f\d]{24}$/i.test(req.params.id)) return next(fail('ObjectId không hợp lệ.'));
  next();
}
function databaseReady(_req, res, next) {
  if (mongoose.connection.readyState !== 1) return res.status(503).json({ message: 'MongoDB chưa kết nối. Kiểm tra backend và Atlas.' });
  next();
}
async function list(req, res) {
  if (req.query.q !== undefined && typeof req.query.q !== 'string') throw fail('Từ khóa không hợp lệ.');
  const q = (req.query.q || '').trim();
  if (q.length > 100) throw fail('Tìm kiếm tối đa 100 ký tự.');
  const escaped = q.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const filter = q ? { $or: [{ email: { $regex: escaped, $options: 'i' } }, { hoten: { $regex: escaped, $options: 'i' } }] } : {};
  res.json({ users: await User.find(filter).sort({ hoten: 1, _id: 1 }).lean(), total: await User.countDocuments({}) });
}
async function get(req, res) {
  const user = await User.findById(req.params.id).lean();
  if (!user) return res.status(404).json({ message: 'Không tìm thấy người dùng.' });
  res.json({ user });
}
async function create(req, res) {
  const value = await validateUser(req.body);
  res.status(201).json({ user: await User.create(value) });
}
async function update(req, res) {
  const value = await validateUser(req.body);
  const user = await User.findByIdAndUpdate(req.params.id, { $set: value }, { new: true, runValidators: true });
  if (!user) return res.status(404).json({ message: 'Không tìm thấy người dùng.' });
  res.json({ user });
}
async function remove(req, res) {
  const user = await User.findByIdAndDelete(req.params.id);
  if (!user) return res.status(404).json({ message: 'Không tìm thấy người dùng.' });
  res.status(204).end();
}
module.exports = { list, get, create, update, remove, checkId, databaseReady };
