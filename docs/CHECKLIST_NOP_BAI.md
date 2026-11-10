# Checklist nộp bài

Ba trạng thái sử dụng: **Đạt** = đã có file/kết quả kiểm chứng phù hợp; **Chưa đạt** = còn thiếu sản phẩm cần nộp; **Chưa kiểm chứng** = có mã nhưng chưa xác minh đúng môi trường yêu cầu. “Đạt local” không đồng nghĩa “Đạt Atlas”.

## Đối chiếu yêu cầu

| Hạng mục | Trạng thái hiện tại | Bằng chứng/cần bổ sung |
|---|---|---|
| Source Flutter Web + Android | Đạt | frontend/lib, web, android |
| Backend Express/Mongoose thật | Đạt | backend/src và kiểm thử MongoDB local |
| Đúng bốn trường nghiệp vụ, không __v/timestamps | Đạt local; Chưa kiểm chứng Atlas | Schema strict + kiểm thử document thực local; chạy audit:data trên Atlas |
| File JSON mẫu ≥5 người, đúng bốn khóa | Đạt | database/users.json |
| Kết nối MongoDB Atlas thật | Đạt kết nối/ping/HTTP health | Đã xác minh sau sửa DNS; xem DNS_WINDOWS.md. Collection hiện có 0 document; CRUD Web/Android với Atlas vẫn cần demo |
| Nhập/hiển thị email, matkhau, hoten, hinhanh trên Web với Atlas (8 điểm) | Chưa kiểm chứng Atlas | Demo Chrome rồi đối chiếu Data Explorer |
| Đăng nhập đúng/sai, token, sửa, xóa | Đạt kiểm thử backend local; cần demo Atlas | Xem KET_QUA_KIEM_THU.md |
| Tìm kiếm, đếm, refresh, loading/rỗng/lỗi, validation | Đã triển khai | Kiểm tra UI local và demo Atlas |
| Build Web | Đạt | frontend/build/web; xem kết quả kiểm thử |
| Build APK debug | Đạt | frontend/build/app/outputs/flutter-apk/app-debug.apk |
| Android chạy trên emulator | Đạt login/danh sách/chọn ảnh/lưu/tải lại ảnh local | Ảnh local-qa và android-local-qa.json; kiểm tra lại Atlas trước khi nộp |
| Android chọn/lưu/tải lại ảnh với Atlas (0,5 điểm) | Chưa kiểm chứng Atlas | Thực hiện demo và chụp 13–15 |
| Báo cáo chi tiết bằng tiếng Việt | Đạt bản thảo | BAO_CAO_GIUA_KY.md; điền thông tin sinh viên và bằng chứng thật |
| Lệnh cài thư viện/hướng dẫn Windows | Đạt | README, HUONG_DAN_CAI_DAT.md |
| Hướng dẫn Atlas và API | Đạt | HUONG_DAN_MONGODB_ATLAS.md, API.md |
| File JSON xuất từ Atlas sau demo | Chưa đạt | Chạy npm run export, nộp users.export.json |
| Ảnh cơ sở dữ liệu Atlas | Chưa đạt | Chụp 01–05 và 09 theo screenshots/README.md |
| Ảnh minh họa kết quả Atlas Web/Android | Chưa đạt | Có ảnh QA local riêng; cần ảnh demo Atlas |
| Link GitHub source | Chưa đạt | Tự tạo repo và push theo README |
| Video demo và link xem được | Chưa đạt | Quay theo DEMO_SCRIPT.md, upload và thử quyền xem |

## Việc phải làm trước khi nộp

- [ ] Điền tên, MSSV, lớp, giảng viên trong báo cáo.
- [ ] Tạo Free/M0 Atlas, Database User, cấp IP public backend, database và collection đúng tên.
- [ ] Điền URI vào backend/.env, không đưa secret vào source/ảnh/video.
- [ ] Chạy seed rồi backend; health connected, Web Chrome chạy cổng 8080.
- [ ] Thêm/sửa/xóa từ UI và đối chiếu dữ liệu thật trên Atlas.
- [ ] Demo Android với ảnh từ thư viện; refresh/xem chi tiết chứng minh ảnh được tải lại.
- [ ] Chạy audit:data và export sau demo; kiểm tra users.export.json mỗi object đúng bốn khóa.
- [ ] Chụp đủ 15 ảnh thật, đưa vào báo cáo; không dùng QA local như ảnh Atlas.
- [ ] Tạo GitHub repository, kiểm tra git diff --cached không có secret trước khi commit/push.
- [ ] Quay video, upload, thử mở link ở cửa sổ ẩn danh.
- [ ] Đọc KET_QUA_KIEM_THU.md, cập nhật trạng thái theo kết quả mới; không tự chấm đủ điểm nếu chưa có bằng chứng.
- [ ] Hồ sơ gồm source (không node_modules, .tools, build, .env), báo cáo, ảnh, JSON mẫu, JSON thật và hai link thật.

GitHub: **[Điền link thật]**

Video demo: **[Điền link thật]**
