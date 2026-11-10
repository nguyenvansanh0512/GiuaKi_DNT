const bcrypt = require('bcryptjs');
const readline = require('node:readline/promises');
(async () => {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  const password = await rl.question('Mật khẩu Admin demo (hiển thị khi nhập; chỉ dùng mật khẩu giả): ');
  rl.close();
  if (password.length < 8 || password.length > 128) throw new Error('Cần 8–128 ký tự.');
  console.log(await bcrypt.hash(password, 12));
})().catch(e => { console.error(e.message); process.exitCode = 1; });
