const jwt = require('jsonwebtoken');
function requireAuth(config) {
  return (req, res, next) => {
    const match = /^Bearer (\S+)$/.exec(req.headers.authorization || '');
    if (!match) return res.status(401).json({ message: 'Vui lòng đăng nhập Admin.' });
    try {
      const payload = jwt.verify(match[1], config.jwtSecret, { algorithms: ['HS256'], issuer: 'midterm-api', audience: 'midterm-admin' });
      if (payload.sub !== config.adminEmail) throw new Error('subject');
      next();
    } catch { res.status(401).json({ message: 'Phiên đăng nhập hết hạn hoặc không hợp lệ.' }); }
  };
}
module.exports = { requireAuth };
