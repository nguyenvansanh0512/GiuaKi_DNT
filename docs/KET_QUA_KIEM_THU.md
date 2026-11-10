# Kết quả kiểm thử thực tế — 10/11/2026

**Cập nhật sau khi cấu hình DNS Windows:** đã xác minh Atlas thật bằng kết nối + ping và HTTP health connected; `audit:data` chạy thành công với collection hiện có **0 document**. Backend hiện **19/19 test đạt**. Chi tiết tại [DNS_WINDOWS.md](DNS_WINDOWS.md), log mới `test-results/backend-dns-tests.txt`. Các nội dung “chưa có URI” và kết quả 12 test bên dưới là hồ sơ của lần triển khai ban đầu, không phải trạng thái kết nối mới. Chưa kiểm thử lại CRUD Web/Android với Atlas trong lần cập nhật DNS này.

## Phạm vi và môi trường

Thực hiện trên Windows, Node.js **22.22.2**, npm **10.9.7**, Flutter **3.47.9 stable**, Dart **3.13.7**, Chrome và emulator **Android 15/API 35, emulator-5554**. Flutter SDK được tải chính thức vào `.tools/flutter`, không nằm trong source Git.

**Chưa có URI MongoDB Atlas thật.** Các kiểm thử database bên dưới dùng MongoDB tạm thời cục bộ, không phải Atlas. Flutter production không chứa dữ liệu mẫu hoặc cơ chế tự thay Atlas bằng mock/local. Backend production từ chối URI placeholder và dừng trước khi mở cổng.

## Kết quả cuối cùng

| Kiểm tra | Kết quả | Phạm vi bằng chứng |
|---|---|---|
| npm ci/install | Đạt | Có package-lock, dependencies đã cài |
| npm test | **12/12 nhóm đạt** | HTTP API thực trên MongoDB ephemeral local |
| npm audit | **0 vulnerabilities** | Kết quả tại thời điểm chạy; không bảo đảm cho các bản cập nhật sau |
| npm run dev với URI mẫu | Dừng đúng, báo chưa cấu hình MONGODB_URI | Không giả kết nối thành công |
| flutter pub get | Đạt | Có pubspec.lock |
| flutter analyze | **No issues found** | Mã nguồn cuối |
| flutter test | **8/8 đạt** | Model/validation/ảnh, HTTP mock, responsive login, system Back/logout |
| flutter build web | **Đạt** | frontend/build/web, build thường và Wasm dry run thành công; chưa test chạy Wasm |
| flutter build apk --debug | **Đạt** | frontend/build/app/outputs/flutter-apk/app-debug.apk |
| Cài/mở APK | **Đạt** | Cài lên emulator, chạy MainActivity |
| Web Chrome end-to-end local | **Đạt luồng đã kiểm tra** | Login đúng/sai, thêm ảnh và UTF-8, sửa, tìm, hủy/xóa, logout; xác minh qua API local |
| Android chạy thật local | **Đạt luồng đã kiểm tra** | Login, danh sách, Photo Picker thật, preview, lưu ảnh, refresh, chi tiết ảnh tải lại, system Back |
| Kiểm tra bốn trường | **Đạt local và JSON mẫu** | Document chỉ có bốn khóa nghiệp vụ + _id; JSON mẫu chỉ bốn khóa |
| Kết nối/CRUD trên Atlas | **Chưa kiểm chứng** | Cần URI, Database User và IP allowlist của sinh viên |
| Xuất JSON Atlas thật | **Chưa thực hiện** | users.export.json chưa được tạo; users.json là mẫu |
| Ảnh Atlas, GitHub, video | **Chưa có** | Cần sinh viên hoàn thành theo checklist |

## Chi tiết kiểm thử backend

`backend/tests/api.test.js` sử dụng Supertest và MongoMemoryServer. MongoDB thực thi insert/find/update/delete và unique index thật trong database tạm; không có mock Mongoose. Dữ liệu kiểm thử bị loại bỏ khi kết thúc. Các nhóm kiểm tra:

1. Login đúng/sai và input đăng nhập sai kiểu.
2. Không token, token sai, token hết hạn.
3. Health, danh sách rỗng, CORS được phép/bị từ chối.
4. Tạo ảnh PNG thực, lưu và đọc lại đúng chuỗi, khóa document chính xác.
5. Email trùng hoa/thường, email/họ tên/mật khẩu sai, input kiểu object, trường ngoài đề, ảnh sai và request quá lớn.
6. Cập nhật đúng dữ liệu, chặn trường ngoài đề và trùng email.
7. Tìm họ tên/email và escape ký tự regex.
8. ID sai, bản ghi không tồn tại, xóa đúng document.
9. Schema strict, tất cả document thực chỉ có `_id` + bốn trường, kiểm tra JSON mẫu ≥5 bản ghi.
10. Ảnh quá 512 KB, MIME không khớp nội dung, thiếu trường.
11. JSON hỏng, endpoint không tồn tại.
12. Mất kết nối database trả 503, URI placeholder bị từ chối.

Log: [backend-tests.txt](test-results/backend-tests.txt), [npm-audit.txt](test-results/npm-audit.txt).

## Chi tiết Flutter và kiểm tra UI

Service tests dùng HTTP mock để kiểm tra token, phương thức/path/body, Unicode, thông báo lỗi và 401, không dùng làm bằng chứng Atlas. Image test tạo PNG, chạy nén JPEG và kiểm tra kích thước đầu ra. Widget tests kiểm tra login 360×800 và 1440×900, validation, hiện/ẩn mật khẩu; regression navigation kiểm tra system Back từ form và logout khi form đang mở.

Log: [flutter-analyze.txt](test-results/flutter-analyze.txt), [flutter-tests.txt](test-results/flutter-tests.txt).

Web chạy **bản build thật** trong Chrome headless bằng Playwright, gọi Express thật qua cổng 3000. Backend QA tách riêng tại `scripts/qa-local.js`, bắt buộc `--local-only`, không nhập vào production server và không ghi đè `.env`. Luồng Web tạo họ tên tiếng Việt, tải file PNG qua file chooser, resize/nén, lưu, đọc API xác nhận ảnh và đúng bốn trường, sửa/xóa và xác nhận persistence. Kiểm tra tìm kiếm có cả ảnh chụp giao diện và response API; văn bản trạng thái rỗng trong Flutter semantics không luôn xuất hiện khi input đang focus nên ảnh thật được đối chiếu trực tiếp.

Kết quả: [web-local-qa.json](test-results/web-local-qa.json). Script tái chạy: `backend/scripts/qa-web.cjs`, chỉ chấp nhận health có dấu local-ephemeral, từ chối backend production/Atlas. Dùng phiên QA sạch không có dữ liệu khác.

Android dùng APK debug cuối, cài bằng adb và thao tác trên UI thật: đăng nhập, mở Photo Picker, chọn ảnh fixture PNG màu xanh trong Pictures, điền bốn trường, lưu và nhận thông báo thành công. Sau đó refresh và mở chi tiết, ảnh được tải lại từ API/MongoDB local. Kiểm tra API xác nhận email, họ tên, Data URI JPEG và đúng các khóa; nút Back hệ thống từ chi tiết trở về danh sách. Fixture ảnh là một ảnh màu dùng kiểm thử, không phải ảnh người thật; screenshot là ảnh chụp màn hình thực, không được dựng.

Kết quả: [android-local-qa.json](test-results/android-local-qa.json). Chưa kiểm thử CRUD Android đầy đủ trên Atlas/điện thoại thật, Android release hoặc xử lý Activity bị hủy trong điều kiện thiết bị thật.

## Các lỗi đã phát hiện và sửa

- Npm audit cảnh báo sharp phiên bản cũ: nâng lên bản vá 0.35.5; chạy lại test và audit.
- Fixture HTTP trong test chứa tiếng Việt được mã hóa Latin-1 mặc định: dùng bytes UTF-8. Client cũng khai báo JSON charset UTF-8 rõ ràng và phân biệt lỗi mạng với lỗi lập trình.
- Kotlin incremental cache bị lỗi do Pub cache ổ C: và project ổ E:: đặt `kotlin.incremental=false`, build lại thành công.
- Android system Back chưa chuyển vào nested Navigator: thêm NavigatorPopHandler và test hồi quy; kiểm tra thật trên emulator đạt.
- Cải thiện ranh giới semantics ô tìm kiếm, tránh gộp vùng nhập với phần còn lại của bảng.
- Tải NDK 28.2.13676358, SDK Platform 36 và CMake 3.22.1 còn thiếu bằng Gradle với giấy phép đã có trên máy. Doctor vẫn báo thiếu cmdline-tools; thành phần này nên cài trước các lần quản lý SDK sau.

## Tái chạy Web QA local tùy chọn

Không chạy các lệnh QA như cấu hình demo Atlas chính thức. Dừng backend production trước, giữ nguyên `.env`. Tại thư mục gốc:

```powershell
npm.cmd install --prefix .tools/qa playwright
# Terminal 1, DB tạm thời và rỗng (tắt/bật lại để reset giữa các lượt)
node backend/scripts/qa-local.js --local-only
# Terminal 2, sau khi đã flutter build web
node backend/scripts/qa-serve-web.cjs
# Terminal 3, cùng thư mục gốc
node backend/scripts/qa-web.cjs
```

Chờ terminal 1 in `QA LOCAL ONLY` trước khi chạy script E2E; lần đầu có thể tải MongoDB binary và mất vài phút. Nếu Chrome đặt nơi khác, cấu hình `$env:CHROME_PATH`. Script dùng ảnh fixture và dữ liệu giả, ghi ảnh vào `docs/screenshots/local-qa`. Nhiều lần chạy login liên tục có thể chạm rate limit; khởi tạo lại **QA local**, không tắt rate limit production. Ctrl+C dừng cả server QA; sau đó cấu hình Atlas để demo thật bằng `npm start`.

## Artifact và việc còn lại

Build Web và APK đã có tại các đường dẫn trên, được `.gitignore` loại khỏi source. APK debug lớn vì bao gồm thành phần debug/kiến trúc mặc định; không phải APK phát hành đã ký. Checksum/kích thước nằm ở [build-artifacts.json](test-results/build-artifacts.json).

Cần cấu hình Atlas, chạy demo end-to-end trên cả Web/Android, `audit:data`, `export`, chụp ảnh Atlas và hoàn thành GitHub/video. Không suy ra điểm số từ kết quả local. Các server QA được dừng khi bàn giao để tránh nhầm chúng với kết nối Atlas.
