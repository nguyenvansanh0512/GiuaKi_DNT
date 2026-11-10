# AdminSpace — Đồ án giữa kỳ Lập trình đa nền tảng

Ứng dụng Admin dùng **Flutter Web + Android**, Express REST API và MongoDB Atlas. Quản lý đúng bốn trường `email`, `matkhau`, `hoten`, `hinhanh`; MongoDB tự tạo `_id`. Không có `__v`, timestamps hoặc role trong collection. Tài khoản Admin cấu hình riêng tại backend.

## Chạy nhanh trên Windows

**Cập nhật DNS Windows:** backend hỗ trợ `MONGODB_DNS_SERVERS=8.8.8.8,1.1.1.1` trong `backend/.env`. Cấu hình dùng chung cho seed/start/audit/export và được áp dụng trước khi Mongoose kết nối. Bỏ trống để giữ DNS mặc định. Kiểm tra chỉ đọc bằng `npm.cmd run check:atlas`. Xem [kết quả xác minh DNS và Atlas thật](docs/DNS_WINDOWS.md).

Yêu cầu Node.js ≥ 22, Flutter stable và Chrome. Android cần Android Studio/SDK, Java tương thích Gradle. Máy triển khai này có Flutter tại `.tools/flutter` (đã bỏ qua trong Git). Trong PowerShell tại thư mục gốc:

```powershell
$env:Path = "$PWD\.tools\flutter\bin;$env:Path"
cd backend
npm.cmd ci
npm.cmd run setup:demo
```

`setup:demo` tạo `.env` nếu chưa có và sinh JWT secret ngẫu nhiên. Nếu file đã tồn tại, script giữ nguyên. **Điền URI Atlas thật vào `backend/.env`** theo [hướng dẫn Atlas](docs/HUONG_DAN_MONGODB_ATLAS.md). Không đưa URI vào Flutter.

Admin minh họa sau khi dùng script: **admin@example.com / DemoAdmin@123**. Chỉ dùng cho bài thi. Đổi hash bằng `npm.cmd run hash` nếu cần.

```powershell
# Terminal backend
npm.cmd run seed
npm.cmd start
# Chế độ theo dõi thay đổi: npm.cmd run dev
```

```powershell
# Terminal khác tại thư mục gốc
cd frontend
flutter pub get
flutter run -d chrome --web-port=8080
```

Web gọi `http://localhost:3000`. Luôn dùng cổng Web 8080 để khớp CORS mẫu; nếu đổi cổng phải sửa `CORS_ORIGINS` rồi khởi động lại backend.

```powershell
# Emulator Android
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000
# Điện thoại thật cùng LAN (thay địa chỉ bằng IP máy chạy backend)
flutter run -d DEVICE_ID --dart-define=API_BASE_URL=http://IP_LAN_MAY_TINH:3000
```

Cho phép Node.js qua Windows Firewall ở mạng Private nếu demo điện thoại thật. HTTP cleartext chỉ được cho phép trong Android **debug**. Release dùng HTTPS endpoint và cấu hình CORS phù hợp cho Web. Không có URI hoặc tài khoản database trong Flutter.

## Chức năng

- Đăng nhập Admin bằng bcrypt/JWT, token ở RAM; tải lại trang cần đăng nhập lại. Hết hạn hoặc API trả 401 sẽ trở về đăng nhập.
- Thêm, đọc danh sách/chi tiết, sửa, xóa có xác nhận; tìm theo email/họ tên, đếm tổng, làm mới.
- Hiện/ẩn mật khẩu demo, placeholder ảnh, trạng thái tải/rỗng/lỗi, SnackBar.
- `image_picker` chọn JPG/PNG; ảnh gốc tối đa 8 MB và 16 MP, resize tối đa 800 px, JPEG chất lượng 78, tối đa 512 KB. Data URI lưu trong `hinhanh`.
- Backend xác minh ảnh bằng sharp, request tối đa 800 KB; chặn trường thừa, email trùng và ID sai; CORS allowlist và giới hạn đăng nhập.

## Cấu trúc

```text
frontend/     Flutter: android/, web/, lib/, test/
backend/      src/{config,models,controllers,routes,middleware}, scripts/, tests/
database/     users.json (5 bản ghi mẫu); users.export.json (chỉ có sau xuất Atlas)
docs/         Báo cáo, cài đặt, Atlas, demo, checklist, screenshots, test-results
.tools/       Flutter SDK cục bộ, không nộp/không commit
```

Các file chính: `backend/src/models/User.js`, `backend/src/app.js`, `frontend/lib/app.dart`, `frontend/lib/screens/user_list_screen.dart`, `frontend/lib/screens/user_form_screen.dart`. API gồm `POST /api/auth/login`, `GET /api/health`, `GET/POST /api/users`, `GET/PUT/DELETE /api/users/:id`. Chi tiết ở [API.md](docs/API.md).

## Kiểm thử và build

```powershell
cd backend
npm.cmd test
npm.cmd audit
cd ../frontend
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

Backend test dùng MongoDB tạm thời cục bộ do `mongodb-memory-server` quản lý, **không phải Atlas**. Flutter service tests dùng HTTP mock. Kết quả đã chạy và hạn chế môi trường nằm tại [KET_QUA_KIEM_THU.md](docs/KET_QUA_KIEM_THU.md). Chưa có URI Atlas thì backend dừng với thông báo cấu hình, không chuyển sang dữ liệu giả.

## Database và nộp bài

`database/users.json` là dữ liệu mẫu ban đầu, chỉ có bốn khóa, không phải bản xuất Atlas. Trước khi nộp, chạy ở backend:

```powershell
npm.cmd run audit:data
npm.cmd run export
```

`database/users.export.json` là dữ liệu thực đọc từ Atlas, bỏ `_id`, không sửa collection. Script từ chối document thừa/thiếu trường. File xuất được Git ignore vì có dữ liệu và mật khẩu demo; đưa riêng vào bộ hồ sơ nộp bài sau khi kiểm tra. Chỉ dùng thông tin giả. Mật khẩu dạng rõ tuân theo bài minh họa và **không phù hợp hệ thống thực tế**.

Xem [báo cáo](docs/BAO_CAO_GIUA_KY.md), [cài đặt](docs/HUONG_DAN_CAI_DAT.md), [kịch bản demo](docs/DEMO_SCRIPT.md), [checklist nộp](docs/CHECKLIST_NOP_BAI.md), [danh sách ảnh](docs/screenshots/README.md).

## Đưa source lên GitHub

Chưa tạo hoặc đẩy repository. Không commit `.env`, node_modules, build, `.tools`, token hoặc URI thật.

```powershell
git init
git add .
git diff --cached --stat
git diff --cached
git commit -m "Initial commit - Midterm Multiplatform CRUD"
# Tạo repository trống trên github.com rồi thay URL thật:
git remote add origin https://github.com/TEN_CUA_BAN/TEN_REPO.git
git branch -M main
git push -u origin main
```

Link GitHub: **[Sinh viên điền sau khi push]**. Link video: **[Sinh viên điền sau khi quay và tải lên]**.
