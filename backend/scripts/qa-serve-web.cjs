// Serves a compiled Flutter build on loopback for local browser QA only.
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../../frontend/build/web');
const types = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.json': 'application/json', '.wasm': 'application/wasm', '.png': 'image/png', '.ttf': 'font/ttf' };
const server = http.createServer((req, res) => {
  let target;
  try { target = path.resolve(root, '.' + decodeURIComponent(new URL(req.url, 'http://localhost').pathname)); }
  catch { res.writeHead(400).end(); return; }
  if (!target.startsWith(root + path.sep) && target !== root) { res.writeHead(403).end(); return; }
  if (fs.existsSync(target) && fs.statSync(target).isDirectory()) target = path.join(target, 'index.html');
  fs.readFile(target, (error, data) => {
    if (error) { res.writeHead(404).end(); return; }
    res.setHeader('Content-Type', types[path.extname(target)] || 'application/octet-stream');
    res.end(data);
  });
});
server.listen(8080, '127.0.0.1', () => console.log('Flutter Web QA: http://localhost:8080 (chỉ loopback).'));
server.on('error', () => { console.error('Không mở được cổng Web QA 8080.'); process.exitCode = 1; });
