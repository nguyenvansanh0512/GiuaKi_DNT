const { fields } = require('../src/middleware/validation');
function auditDocument(doc, allowId = true) {
  const keys = Object.keys(doc);
  if (fields.some(k => typeof doc[k] !== 'string') || keys.some(k => !fields.includes(k) && !(allowId && k === '_id'))) throw new Error('Document thiếu trường hoặc có trường thừa; dừng xuất/nhập dữ liệu.');
  return Object.fromEntries(fields.map(k => [k, doc[k]]));
}
module.exports = { auditDocument };
