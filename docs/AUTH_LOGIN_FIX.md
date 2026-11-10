# Kết quả kiểm tra đăng nhập Admin

## Nguyên nhân và thay đổi

Đã đọc cấu hình `.env` local bằng chương trình kiểm tra, chỉ xuất các kết quả boolean, không in thông tin đăng nhập, hash, URI hoặc secret. Email cấu hình khớp tài khoản được yêu cầu; hash có định dạng bcrypt hợp lệ nhưng phép so sánh với mật khẩu được cung cấp trả về false.

Đã tạo bcrypt hash mới với cost 12 và thay riêng `ADMIN_PASSWORD_HASH` trong `.env` local. So sánh bcrypt sau cập nhật trả về true. Kiểm tra tự động xác nhận mọi biến môi trường khác giữ nguyên, bao gồm MongoDB URI, DNS và JWT secret. `.env.example` tiếp tục dùng placeholder, không chứa tài khoản local hoặc mật khẩu được yêu cầu.

Trong `backend/src/app.js`, bổ sung việc từ chối email/mật khẩu rỗng với HTTP 400, cùng hành vi thiếu trường. Đăng nhập vẫn dùng `bcrypt.compare`, cấp JWT HS256 có issuer/audience và hạn dùng 2 giờ. Tài khoản Admin lấy từ môi trường, không được thêm vào collection users.

Payload Flutter đã đúng: `POST /api/auth/login` với hai trường `email` và `matkhau`. AuthService lưu token trong ApiService; request quản lý gửi `Authorization: Bearer ...`; AuthProvider cập nhật trạng thái và AuthGate chuyển sang danh sách. Không cần sửa mã chạy của Flutter.

## Kết quả kiểm thử

| Kiểm tra | Kết quả |
|---|---|
| Backend regression và auth tests | 20/20 đạt |
| Flutter regression và login flow tests | 9/9 đạt |
| API thật: đăng nhập hợp lệ | HTTP 200, JWT xác minh thành công |
| API thật: sai mật khẩu | HTTP 401 |
| API thật: thiếu thông tin hoặc chuỗi rỗng | HTTP 400 |
| API thật: GET users bằng JWT vừa cấp | HTTP 200, đọc từ Atlas |
| Chrome: đăng nhập Flutter Web | Chuyển sang trang quản lý, GET users được chấp nhận với Bearer token |

Backend kiểm thử mới chạy trên loopback cổng 3001 với `.env` đã cập nhật và kết nối Atlas thật. Chrome mở Flutter đang phục vụ tại cổng 8080 trong một phiên kiểm thử riêng, chuyển các request API sang backend 3001. Không giả lập response API. Tiến trình backend 3000 của người dùng không bị khởi động lại; cần restart để nạp cấu hình mới. Backend kiểm thử 3001 được dừng sau xác minh.

Không ghi tài liệu này kèm mật khẩu, hash, token, JWT secret hay MongoDB URI. Không tạo/sửa/xóa document Atlas khi kiểm tra đăng nhập. Schema và các chức năng CRUD giữ nguyên.

Bằng chứng:

- `test-results/backend-auth-tests.txt`
- `test-results/flutter-auth-tests.txt`
- `test-results/admin-login-verification.json`
- `test-results/flutter-web-login-verification.json`

## Khởi động lại để demo

Trong terminal backend đang chạy, nhấn **Ctrl+C**, rồi chạy:

```powershell
cd E:\DNTDD\Giua_ki\backend
$env:HOST='0.0.0.0'
$env:PORT='3000'
npm.cmd start
```

Các biến HOST/PORT trên chỉ áp dụng cho terminal này, không sửa `.env`. Khi log báo kết nối MongoDB và API sẵn sàng, tải lại Flutter Web tại `http://localhost:8080` và đăng nhập bằng tài khoản đã cung cấp. Token lưu RAM nên trang sẽ yêu cầu đăng nhập lại sau khi tải lại.
