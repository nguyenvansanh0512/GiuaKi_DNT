const { test, afterEach } = require('node:test');
const assert = require('node:assert/strict');
const dns = require('node:dns');
const mongoose = require('mongoose');

const originalDns = dns.getServers();
const originalEnv = process.env.MONGODB_DNS_SERVERS;
function freshConfig() {
  delete require.cache[require.resolve('../src/config/dns')];
  return require('../src/config/dns').configureMongoDns;
}
afterEach(() => {
  dns.setServers(originalDns);
  if (originalEnv === undefined) delete process.env.MONGODB_DNS_SERVERS;
  else process.env.MONGODB_DNS_SERVERS = originalEnv;
});

test('DNS không cấu hình giữ nguyên resolver mặc định', t => {
  const spy = t.mock.method(dns, 'setServers', () => {});
  freshConfig()('  ');
  assert.equal(spy.mock.callCount(), 0);
});
test('DNS trim danh sách, hỗ trợ IPv4/IPv6 và áp dụng cho promises/SRV của driver', () => {
  freshConfig()(' 8.8.8.8, 1.1.1.1, 2001:4860:4860::8888 ');
  const expected = ['8.8.8.8', '1.1.1.1', '2001:4860:4860::8888'];
  assert.deepEqual(dns.getServers(), expected);
  assert.deepEqual(dns.promises.getServers(), expected);
});
test('DNS chỉ áp dụng một lần, không thay resolver giữa các kết nối', t => {
  const configure = freshConfig();
  const spy = t.mock.method(dns, 'setServers', () => {});
  configure('8.8.8.8,1.1.1.1');
  configure(' 8.8.8.8, 1.1.1.1 ');
  assert.equal(spy.mock.callCount(), 1);
  assert.throws(() => configure('9.9.9.9'), /Khởi động lại/);
});
test('DNS sai bị chặn trước khi thay resolver, không lộ giá trị đầu vào', t => {
  const spy = t.mock.method(dns, 'setServers', () => {});
  for (const value of ['8.8.8.8,', 'not-an-ip', '8.8.8.8,,1.1.1.1', '999.1.1.1', 'https://secret.invalid']) {
    assert.throws(() => freshConfig()(value), error => {
      assert.equal(error.message.includes(value), false);
      return /MONGODB_DNS_SERVERS/.test(error.message);
    });
  }
  assert.equal(spy.mock.callCount(), 0);
});
test('Lỗi native setServers được che, không đánh dấu đã áp dụng khi lỗi', t => {
  const configure = freshConfig();
  const spy = t.mock.method(dns, 'setServers', () => { throw new Error('sensitive-internal-details'); });
  assert.throws(() => configure('8.8.8.8'), error => !error.message.includes('sensitive-internal-details'));
  spy.mock.restore();
  configure('8.8.8.8');
  assert.deepEqual(dns.getServers(), ['8.8.8.8']);
});
test('connectDatabase áp dụng DNS trước mongoose.connect, truyền nguyên URI và không lặp cấu hình', async t => {
  process.env.MONGODB_DNS_SERVERS = '8.8.8.8,1.1.1.1';
  freshConfig();
  delete require.cache[require.resolve('../src/config/database')];
  const { connectDatabase } = require('../src/config/database');
  const order = [];
  t.mock.method(dns, 'setServers', () => order.push('dns'));
  t.mock.method(mongoose, 'connect', async (uri, options) => {
    assert.equal(uri, 'mongodb://test-only.invalid/database');
    assert.equal(options.dbName, 'midterm_multiplatform');
    order.push('connect');
  });
  t.mock.method(console, 'log', () => {});
  await connectDatabase('mongodb://test-only.invalid/database');
  await connectDatabase('mongodb://test-only.invalid/database');
  assert.deepEqual(order, ['dns', 'connect', 'connect']);
});
