const mongoose = require('mongoose');
const { readConfig } = require('./config/env');
const { connectDatabase } = require('./config/database');
const User = require('./models/User');
const { createApp } = require('./app');

async function start() {
  const config = readConfig();
  await connectDatabase(config.mongoUri);
  await User.init();
  const server = createApp(config).listen(config.port, config.host, error => {
    if (!error) console.log(`API sẵn sàng tại cổng ${config.port}.`);
  });
  server.on('error', error => {
    const code = ['EADDRINUSE', 'EACCES', 'EADDRNOTAVAIL', 'ENOTFOUND'].includes(error.code) ? error.code : 'LISTEN_FAILED';
    console.error(`Không mở được cổng API (${code}). Kiểm tra HOST, PORT và ứng dụng đang chiếm cổng.`);
    process.exitCode = 1;
    mongoose.disconnect();
  });
  for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => server.close(async () => { await mongoose.disconnect(); process.exit(0); }));
}
start().catch(async error => { console.error(error.message); await mongoose.disconnect(); process.exitCode = 1; });
