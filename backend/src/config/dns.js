const dns = require('node:dns');
const { isIP } = require('node:net');
require('./env');

let appliedConfiguration;

function configureMongoDns(value = process.env.MONGODB_DNS_SERVERS || '') {
  const servers = value.trim() ? value.split(',').map(server => server.trim()) : [];
  if (servers.some(server => !isIP(server))) {
    throw new Error('MONGODB_DNS_SERVERS phải là danh sách địa chỉ IPv4/IPv6 hợp lệ, ngăn cách bằng dấu phẩy.');
  }
  const key = servers.join(',');
  if (appliedConfiguration === key) return;
  if (appliedConfiguration !== undefined) {
    throw new Error('Cấu hình DNS đã được khởi tạo. Khởi động lại tiến trình để đổi MONGODB_DNS_SERVERS.');
  }
  // setServers must run before any SRV/TXT queries, never during a connection.
  // An empty setting preserves the default resolver. Never log supplied values.
  if (servers.length) {
    try { dns.setServers(servers); }
    catch { throw new Error('Không áp dụng được cấu hình MONGODB_DNS_SERVERS.'); }
  }
  appliedConfiguration = key;
}

module.exports = { configureMongoDns };
