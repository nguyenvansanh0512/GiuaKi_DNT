# MongoDB Atlas — thiết lập database thật

Nếu Node trên Windows bị lỗi DNS SRV/TXT nhưng mạng vẫn truy cập được Atlas, thêm `MONGODB_DNS_SERVERS=8.8.8.8,1.1.1.1` trong `backend/.env`, rồi khởi động lại backend. Kiểm tra bằng `npm.cmd run check:atlas`. Module dùng chung áp dụng DNS trước mọi kết nối của seed/start/audit/export. Xem [DNS_WINDOWS.md](DNS_WINDOWS.md) để biết giới hạn và kết quả xác minh mới nhất.

Hướng dẫn dùng Atlas online, không cần MongoDB Community Server hay Compass. Các tên nút có thể thay đổi theo giao diện Atlas. Tham khảo [tài liệu triển khai Free cluster](https://www.mongodb.com/docs/atlas/tutorial/deploy-free-tier-cluster/) và [kết nối ứng dụng](https://www.mongodb.com/docs/atlas/driver-connection/). Chỉ chọn **Free/M0**, không chọn gói tính phí.

## 1. Tài khoản, Project và cluster

1. Mở https://cloud.mongodb.com/ bằng trình duyệt, chọn đăng ký nếu chưa có tài khoản. Xác minh email theo yêu cầu. Có thể đăng nhập bằng tài khoản cá nhân phù hợp.
2. Tạo Project mới, ví dụ `Midterm Multiplatform`; giữ quyền quản trị của tài khoản mình.
3. Chọn tạo deployment/cluster, chọn **Free (M0)**. Nếu giao diện chọn gói mặc định trả phí, chuyển sang Free trước khi tiếp tục. Không cung cấp thanh toán cho đồ án này.
4. Chọn cloud provider và region được Free hỗ trợ, ưu tiên gần nơi sử dụng. Đặt tên cluster dễ nhớ, chờ chuyển sang trạng thái sẵn sàng. Không tải sample datasets vì bài yêu cầu schema riêng.
5. Chụp ảnh cluster thật, tránh hiển thị thông tin tài khoản nhạy cảm.

## 2. Database User và Network Access

1. Vào mục **Security / Database Access** hoặc phần Database Users trong cấu hình bảo mật của Project.
2. Add New Database User → Password authentication. Tạo username riêng, mật khẩu mạnh riêng cho database. Đây **khác** tài khoản đăng nhập trang Atlas và khác tài khoản Admin của ứng dụng.
3. Chọn quyền đọc/ghi phù hợp; nếu có tùy chọn phạm vi, giới hạn `readWrite` cho database `midterm_multiplatform`. Không đưa username/password thật vào README hoặc screenshot.
4. Vào **Network Access / IP Access List**, chọn Add IP Address → Add Current IP Address, lưu và đợi áp dụng. Cần cho phép **IP public máy chạy backend**, không phải IP điện thoại/emulator.
5. Khi đổi Wi-Fi/VPN hoặc IP public thay đổi, cập nhật allowlist. Tránh mở `0.0.0.0/0` khi không cần; đóng quyền tạm thời sau demo nếu từng mở.

## 3. Tạo database và collection

1. Mở cluster → Browse Collections / Data Explorer.
2. Create Database: database **`midterm_multiplatform`**, collection **`users`** (đúng chữ thường).
3. Collection ban đầu để trống. Chạy script seed ở bước 5 để nhập `database/users.json` có 5 người dùng mẫu. Có thể Insert Document thủ công bằng JSON, nhưng phải dùng đúng bốn trường:

```json
{"email":"an@example.com","matkhau":"Demo123456","hoten":"Nguyễn Văn An","hinhanh":""}
```

Atlas thêm `_id` hệ thống tự động. Không bổ sung `id`, `__v`, role, username, password, createdAt, updatedAt hoặc trường khác. Mongoose khai báo versionKey/timestamps false và strict throw. Unique index email được tạo khi server khởi động; nếu đã nhập trùng email thủ công, cần xử lý các bản ghi trùng trước.

## 4. Lấy connection string

1. Cluster → Connect → Drivers → chọn Node.js và driver hiện hành.
2. Sao chép mẫu `mongodb+srv://...`. Thay username và password của **Database User**, thay host đúng cluster; bỏ dấu `<` `>`.
3. Đặt đường dẫn database `/midterm_multiplatform` trước `?`. Backend cũng ép `dbName` này để tránh ghi nhầm database.
4. Nếu mật khẩu có `@`, `:`, `/`, `?`, `#`, `%` hoặc ký tự đặc biệt, URL-encode **riêng username/password**, không encode toàn URI. Không gửi URI vào chat, báo cáo, ảnh chụp hoặc frontend.
5. Tạo `backend/.env` bằng `npm.cmd run setup:demo` nếu chưa có. Điền URI vào `MONGODB_URI`. Ví dụ dưới đây chỉ là mẫu, không thể kết nối:

```env
MONGODB_URI=mongodb+srv://USERNAME:PASSWORD@CLUSTER_HOST/midterm_multiplatform?retryWrites=true&w=majority
```

Giữ `.env` ngoài Git. Không đặt connection string trong `--dart-define`; tham số đó chỉ chứa địa chỉ HTTP API công khai.

## 5. Kết nối và nhập mẫu

Tại PowerShell ở thư mục backend:

```powershell
npm.cmd ci
npm.cmd run seed
npm.cmd start
```

Seed kiểm tra dữ liệu mẫu đúng bốn trường, chỉ thêm email chưa tồn tại bằng upsert `$setOnInsert`; không xóa hoặc thay đổi các bản ghi đã có. Khi kết nối thành công, log có `Đã kết nối MongoDB — database midterm_multiplatform.` rồi `API sẵn sàng tại cổng 3000.` Kiểm tra:

```powershell
Invoke-RestMethod http://localhost:3000/api/health
```

Kết quả phải là `status: ok`, `database: connected`. Mở Flutter Web cổng 8080, đăng nhập, danh sách được đọc từ API/Atlas. Không thấy dữ liệu thì làm mới Data Explorer và kiểm tra đúng database, collection, tài khoản và backend đang chạy.

## 6. Chứng minh dữ liệu thật

1. Thêm một người dùng từ Flutter với email dễ nhận biết, họ tên tiếng Việt, mật khẩu giả và ảnh JPG/PNG.
2. Quay sang Atlas, refresh collection, lọc email đó. Document phải có `_id`, `email`, `matkhau`, `hoten`, `hinhanh`; chuỗi ảnh bắt đầu bằng Data URI.
3. Sửa tên/ảnh từ Flutter, refresh Atlas và đối chiếu. Tải lại Flutter, đăng nhập lại để kiểm tra dữ liệu bền và ảnh hiển thị.
4. Xóa bản ghi từ Flutter, xác nhận, refresh Atlas và chứng minh document biến mất. Không xóa nhầm bản ghi cần giữ cho bài nộp.
5. Chạy `npm.cmd run audit:data` kiểm tra **mọi document**, không chỉ bản ghi đang xem.

## 7. Xuất JSON nộp bài

```powershell
# Trong backend; .env đang trỏ Atlas thật
npm.cmd run audit:data
npm.cmd run export
```

Script đọc trực tiếp collection bằng driver qua Mongoose, kiểm tra các khóa, loại `_id` khi tạo kết quả và ghi **`database/users.export.json`**. Không sửa document, không xóa collection, không ghi đè dữ liệu mẫu. Nếu phát hiện trường thừa/thiếu, script dừng để bạn kiểm tra dữ liệu thật thay vì âm thầm loại trường sai. Nếu file xuất cũ tồn tại và lệnh thất bại, không dùng file cũ như bản xuất mới; đối chiếu thời gian và thông báo thành công.

Nộp riêng `users.export.json` sau demo và giữ `users.json` để giảng viên có dữ liệu khởi tạo. File xuất chỉ có đúng bốn khóa trên mỗi object, không có `_id`. Dữ liệu có mật khẩu giả nên không đưa dữ liệu cá nhân thật vào bài.

## 8. Khắc phục lỗi

| Thông báo | Cần kiểm tra |
|---|---|
| Chưa cấu hình MONGODB_URI | `.env` đúng thư mục backend; thay toàn bộ placeholder |
| Sai tài khoản Database User | Username/password database, URL-encode, quyền database; không dùng tài khoản website Atlas |
| DNS/querySrv/không truy cập | Host cluster chính xác, DNS, mạng, VPN/firewall |
| Timeout | IP public trong Network Access, cluster đang chạy, mạng và URI |
| Email đã tồn tại | Unique index email; không nhập lại cùng email |
| Không tạo được index | Collection trước đó có email trùng hoặc dữ liệu sai |

Timeout không đủ để kết luận chắc chắn IP chưa được cấp quyền. Không đưa raw lỗi có thể chứa URI lên GitHub. Chỉ chụp ảnh Data Explorer/cluster và log đã che thông tin nhạy cảm. Chưa có URI thật tại thời điểm triển khai nên chưa có ảnh Atlas hoặc xác nhận kết nối Atlas.
