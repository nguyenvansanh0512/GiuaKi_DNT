# Cấu hình DNS Windows cho backend MongoDB Atlas

## Entry point đã kiểm tra

| Lệnh | Entry point | Hàm kết nối chung |
|---|---|---|
| npm run seed | scripts/seed.js | src/config/database.js → connectDatabase |
| npm start | src/server.js | src/config/database.js → connectDatabase |
| npm run audit:data | scripts/audit-data.js | src/config/database.js → connectDatabase |
| npm run export | scripts/export.js | src/config/database.js → connectDatabase |
| npm run check:atlas | scripts/check-atlas.js | src/config/database.js → connectDatabase, rồi ping |

## Cấu hình

Trong `backend/.env`:

```env
MONGODB_DNS_SERVERS=8.8.8.8,1.1.1.1
```

`src/config/dns.js` nạp biến môi trường qua module env có sẵn, kiểm tra các IP IPv4/IPv6 và gọi `dns.setServers`. `connectDatabase` gọi module này trước `mongoose.connect`. Mỗi tiến trình chỉ áp dụng một lần; các lần kết nối tiếp theo không đổi resolver khi đang có truy vấn. Thay cấu hình cần restart tiến trình. Bỏ biến hoặc để rỗng sẽ giữ DNS mặc định.

Đây là cấu hình của tiến trình Node, không đổi DNS của Windows. Theo [tài liệu Node.js](https://nodejs.org/api/dns.html#dnssetserversservers), setServers tác động đến resolve/resolveSrv/resolveTxt/reverse, không tác động đến dns.lookup. Driver MongoDB hiện dùng dns.promises cho SRV/TXT; test đã xác nhận cả API callback và promises nhận cấu hình mới. Lỗi IP/cấu hình native được báo bằng thông báo an toàn, không in giá trị đầu vào hoặc URI.

Chỉ thêm/cập nhật dòng DNS trong `.env`; đã kiểm tra mọi biến khác giữ nguyên, bao gồm MongoDB URI, tài khoản, hash mật khẩu và JWT secret. Không thay file schema User hoặc mã Flutter.

## Kết quả thực tế sau cập nhật

- `npm test`: **19/19 đạt**; log `docs/test-results/backend-dns-tests.txt`.
- `npm run check:atlas`: kết nối Atlas thật và `ping` thành công, exit code 0. URI hiện dùng hostname Atlas, không đưa hostname/URI/tài khoản vào báo cáo.
- `npm run audit:data`: kết nối thật thành công, đọc collection có **0 document**. Collection rỗng chưa cung cấp bằng chứng cấu trúc của bản ghi Atlas đã lưu; schema và các bản ghi kiểm thử local vẫn được kiểm tra đúng bốn trường.
- Entry point server đã kết nối Atlas, khởi tạo collection/index, mở API trên loopback cổng 3001 bằng biến môi trường tạm. HTTP `/api/health` trả `{"status":"ok","database":"connected"}`.
- Chưa chạy seed hoặc export trên Atlas trong lần sửa này để tránh tự thêm dữ liệu hoặc ghi đè file xuất. Không xác nhận CRUD Web/Android với Atlas chỉ từ ping.

Khi thử server, phát hiện lỗi Mongoose khởi tạo model trước kết nối khi bufferCommands bị tắt quá sớm. Đã chuyển việc tắt buffering sang sau kết nối thành công; thêm test hồi quy với database module được import trước User model, tương tự server thật. Schema bốn trường không thay đổi.

Server cũng không còn báo “API sẵn sàng” khi Express truyền lỗi listen vào callback; log chỉ mã lỗi OS an toàn, không in địa chỉ hoặc cấu hình nhạy cảm.

## Lệnh demo

`HOST` hiện có trong `.env` không phân giải được (ENOTFOUND). Đã giữ nguyên giá trị này theo phạm vi chỉnh sửa DNS. Để bind trên máy phát triển cho cả Web và Android, đặt HOST bằng biến môi trường **trong terminal demo**:

```powershell
cd E:\DNTDD\Giua_ki\backend
$env:HOST='0.0.0.0'
$env:PORT='3000'
npm.cmd run check:atlas
npm.cmd run seed
npm.cmd start
```

`seed` chỉ thêm email mẫu chưa tồn tại, không ghi đè người dùng đã có. Không chạy lại setup:demo để tránh nhầm cấu hình hiện tại. Không thay URI hoặc mật khẩu đã hoạt động.

Terminal Flutter Web:

```powershell
cd E:\DNTDD\Giua_ki\frontend
..\.tools\flutter\bin\flutter.bat run -d chrome --web-port=8080
```

Android emulator, dùng terminal khác:

```powershell
cd E:\DNTDD\Giua_ki\frontend
..\.tools\flutter\bin\flutter.bat run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

Sau demo, trong terminal backend khác:

```powershell
cd E:\DNTDD\Giua_ki\backend
npm.cmd run audit:data
npm.cmd run export
```

Chỉ lệnh export ghi `database/users.export.json`; database không bị thay đổi. Các server dùng xác minh đã được dừng sau kiểm tra.
