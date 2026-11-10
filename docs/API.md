# REST API

Base URL local `http://localhost:3000`. JSON UTF-8. CRUD cần header `Authorization: Bearer TOKEN`. Token hết hạn 2 giờ; logout phía Flutter xóa token RAM. Token bị sao chép vẫn có hiệu lực đến hết hạn, chưa có danh sách thu hồi token.

| Method / endpoint | Input | Thành công |
|---|---|---|
| POST /api/auth/login | `email`, `matkhau` Admin | 200 `{token, expiresIn:7200}` |
| GET /api/health | Không cần token | 200 khi MongoDB connected; 503 nếu disconnected |
| GET /api/users?q=... | Từ khóa ≤100 ký tự, tùy chọn | 200 `{users:[], total:N}`; total toàn collection |
| GET /api/users/:id | ObjectId | 200 `{user:{...}}` |
| POST /api/users | Đủ bốn trường kiểu string | 201 `{user:{...}}` |
| PUT /api/users/:id | Đủ bốn trường, thay nội dung nghiệp vụ | 200 `{user:{...}}` |
| DELETE /api/users/:id | ObjectId | 204 không có body |

Tạo/sửa:

```json
{"email":"an@example.com","matkhau":"Demo123456","hoten":"Nguyễn An","hinhanh":""}
```

`hinhanh` là chuỗi rỗng hoặc `data:image/jpeg;base64,...` / `data:image/png;base64,...`, không chấp nhận URL từ xa. Ảnh tối đa 512 KB sau giải Base64 và 16 MP. JSON tối đa 800 KB.

Email được trim/lowercase, ≤254 ký tự; mật khẩu 6–128 ký tự; họ tên trim và 1–100 ký tự. Không nhận trường thừa kể cả `_id`, `id`, role hoặc toán tử `$set`. Unique index đảm bảo email không trùng kể cả tạo đồng thời. Tìm kiếm regex đã escape, không chạy biểu thức regex của người dùng.

Lỗi có `{ "message": "Thông báo" }`: 400 dữ liệu/ID/JSON sai; 401 cần đăng nhập/token sai; 403 CORS; 404 không tồn tại; 409 trùng email; 413 body quá lớn; 429 đăng nhập quá 20 lần/15 phút/IP; 503 database không khả dụng. Không trả raw lỗi chứa URI hoặc thông tin nhạy cảm.

Ví dụ kiểm tra bằng PowerShell sau khi Atlas đã được cấu hình:

```powershell
$session = Invoke-RestMethod -Method Post -Uri http://localhost:3000/api/auth/login -ContentType application/json -Body '{"email":"admin@example.com","matkhau":"DemoAdmin@123"}'
$headers = @{ Authorization = "Bearer $($session.token)" }
Invoke-RestMethod http://localhost:3000/api/users -Headers $headers
```

Không chụp hoặc đưa token thật vào báo cáo.
