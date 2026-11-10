# Hướng dẫn cài đặt Windows

## 1. Công cụ

1. Cài Git từ https://git-scm.com/downloads/win và Node.js LTS từ https://nodejs.org/en/download (dự án yêu cầu ≥22). Mở PowerShell mới, chạy `git --version`, `node --version`, `npm.cmd --version`.
2. Tải Flutter stable từ [SDK archive chính thức](https://docs.flutter.dev/install/archive), giải nén vào thư mục có quyền ghi, tránh Program Files. Hoặc dùng bản `.tools/flutter` đã tải trong workspace này. Thêm đường dẫn `flutter/bin` vào PATH của tài khoản, mở terminal mới.
3. Chạy `flutter --version`, `dart --version`, `flutter doctor -v`. Chrome cần được cài để chạy Web. Không cần Visual Studio C++ vì dự án chỉ chạy Web/Android.
4. Cài Android Studio từ https://developer.android.com/studio nếu chạy Android. Trong Settings → Languages & Frameworks → Android SDK, cài SDK Platform được Flutter yêu cầu, SDK Build-Tools, Platform-Tools, Android SDK Command-line Tools (latest), Android Emulator. Tab SDK Tools có thể cần bật Show Package Details.
5. Dùng JDK đi kèm Android Studio; nếu Flutter không tự tìm thấy: `flutter config --jdk-dir="C:\Program Files\Android\Android Studio\jbr"`. Chạy `flutter doctor --android-licenses`, tự đọc và đồng ý giấy phép; chạy lại `flutter doctor -v`.
6. Tools → Device Manager → Create device, chọn thiết bị và system image, khởi động emulator. `flutter devices` phải thấy thiết bị. Điện thoại thật cần Developer options, USB debugging và xác nhận tin cậy máy tính.

Ở môi trường triển khai ngày 10/11/2026, Flutter 3.47.9/Dart 3.13.7 được tải trong `.tools/flutter`; Node 22.22.2; Android SDK có sẵn nhưng thiếu cmdline-tools. Kết quả build thực tế xem tài liệu kiểm thử.

## 2. Backend và thư viện

Mở PowerShell tại thư mục gốc:

```powershell
$env:Path = "$PWD\.tools\flutter\bin;$env:Path"  # nếu dùng SDK cục bộ
cd backend
npm.cmd ci
npm.cmd run setup:demo
```

Các thư viện backend: express, mongoose, dotenv, cors, helmet, express-rate-limit, bcryptjs (bcrypt thuần JS), jsonwebtoken, sharp. Công cụ test: node:test, supertest, mongodb-memory-server. `npm ci` dùng phiên bản chính xác trong package-lock.

Script setup sinh `.env` từ `.env.example` và **không ghi đè** file hiện có. Admin minh họa `admin@example.com / DemoAdmin@123`; JWT secret tự sinh. Để tạo hash khác: `npm.cmd run hash`, nhập mật khẩu demo 8–128 ký tự, dán hash vào `ADMIN_PASSWORD_HASH` trong `.env` (không chia sẻ hash/secret thật).

Điền `MONGODB_URI` từ Atlas theo tài liệu riêng. `.env` phải đặt ở **backend/.env**, không phải frontend. Giữ `HOST=0.0.0.0`, `PORT=3000` cho demo LAN. Giới hạn firewall trong mạng tin cậy. Nếu chỉ Web trên máy, có thể đổi HOST thành 127.0.0.1.

```powershell
npm.cmd run seed
npm.cmd start
```

Seed chỉ thêm email chưa có, không xóa collection, không ghi đè người dùng đã tồn tại. Backend chỉ mở cổng khi kết nối database và khởi tạo unique index thành công. Kiểm tra `Invoke-RestMethod http://localhost:3000/api/health` phải thấy connected.

## 3. Flutter Web

Terminal mới ở thư mục gốc:

```powershell
cd frontend
flutter pub get
flutter run -d chrome --web-port=8080
```

Flutter dependencies gồm http, provider, image_picker, image và flutter_localizations. Không dùng dart:io trong code chung. Đăng nhập Admin bằng tài khoản đã cấu hình. UI lấy dữ liệu API; không có danh sách mẫu hardcode. Nếu không seed, danh sách ban đầu rỗng.

```powershell
flutter build web --dart-define=API_BASE_URL=https://TEN_BACKEND_HTTPS_CUA_BAN
```

Thư mục build là `frontend/build/web`. Phục vụ qua HTTP server, không mở index.html bằng file://. Bản Web HTTPS phải gọi backend HTTPS để tránh mixed content. Khai báo đúng origin Web trong CORS backend.

## 4. Android

```powershell
flutter devices
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000
flutter build apk --debug
```

APK ở `frontend/build/app/outputs/flutter-apk/app-debug.apk`. Main manifest có INTERNET; chỉ debug manifest cho phép HTTP cleartext. Với điện thoại thật, dùng IP LAN của máy tính (`ipconfig` xem IPv4 đúng adapter), không dùng localhost hay 10.0.2.2; thay qua `--dart-define=API_BASE_URL=http://IP_LAN:3000`. Hai thiết bị cùng Wi-Fi, không bị AP isolation; firewall phải cho cổng 3000 trong mạng Private. Release phải dùng HTTPS; dự án chưa cấu hình khóa ký phát hành.

Chọn ảnh qua thư viện hệ thống bằng image_picker. Có xử lý dữ liệu ảnh thất lạc khi Android hủy Activity; mở lại form để khôi phục ảnh. Nội dung các ô chưa lưu không được lưu bền khi hệ điều hành đóng ứng dụng.

## 5. Kiểm tra và lỗi thường gặp

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

- `npm.ps1 cannot be loaded`: dùng `npm.cmd`, không cần hạ ExecutionPolicy.
- Chưa cấu hình URI: sửa `.env`; không có kết nối giả dự phòng.
- Authentication failed: kiểm tra Database User, không dùng mật khẩu tài khoản đăng nhập Atlas, URL-encode mật khẩu.
- Timeout: kiểm tra IP Network Access, cluster, DNS, firewall; xem hướng dẫn Atlas.
- CORS: dùng `http://localhost:8080` hoặc thêm origin chính xác rồi restart; 127.0.0.1 khác localhost.
- Cổng 3000 bận: dừng tiến trình backend cũ hoặc đổi PORT và API_BASE_URL.
- Thiếu SDK/NDK: mở Android SDK Manager cài đúng thành phần mà Gradle yêu cầu; đọc giấy phép và chấp thuận bằng công cụ chính thức.
- 401: đăng nhập lại; refresh Web xóa token RAM theo thiết kế.
- Email trùng: chọn email khác; lỗi 409 không làm mất dữ liệu đang nhập.
- Chọn ảnh lỗi: dùng JPG/PNG nhỏ hơn 8 MB, 16 MP; ảnh lưu sau nén ≤512 KB.

## 6. Tạo hồ sơ nộp

Sau demo chạy `npm.cmd run audit:data` và `npm.cmd run export` tại backend. Chụp ảnh thật theo `screenshots/README.md`; cập nhật báo cáo tên sinh viên/lớp, bằng chứng và kết quả Atlas/Android thực tế. Tự tạo repository và push theo README, quay video theo DEMO_SCRIPT, điền hai link thật vào checklist.
