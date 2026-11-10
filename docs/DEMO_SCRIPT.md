# Kịch bản video demo (khoảng 7–10 phút)

Chuẩn bị trước: Atlas đã kết nối, backend chạy cổng 3000, Web cổng 8080, Android emulator/điện thoại sẵn sàng. Chỉ sử dụng dữ liệu giả, tắt thông báo cá nhân, không quay `.env`, URI, JWT hoặc mật khẩu database. Điền tên sinh viên/lớp trên báo cáo.

| Thời lượng | Thao tác và lời giới thiệu |
|---|---|
| 00:00–00:30 | Giới thiệu tên, lớp, đề tài AdminSpace, mục tiêu thêm/hiển thị/sửa/xóa người dùng Web và Android. |
| 00:30–01:00 | Mở cấu trúc source; Flutter → REST API Express → Mongoose → Atlas. Web và Android dùng chung lib. |
| 01:00–01:40 | Mở Atlas cluster/database/collection. Chỉ rõ bốn trường nghiệp vụ và `_id` hệ thống, không có role/__v/timestamps. |
| 01:40–02:00 | Hiển thị terminal backend đã kết nối, health connected; tránh quay secret. |
| 02:00–02:40 | Mở Flutter Web, đăng nhập sai để thấy lỗi, sau đó đăng nhập đúng Admin demo. |
| 02:40–03:50 | Thêm email mới, mật khẩu demo, họ tên tiếng Việt; chọn ảnh, xem preview, lưu. Danh sách hiển thị bốn thông tin; bật hiện mật khẩu demo. |
| 03:50–04:20 | Quay sang Atlas refresh, lọc email vừa tạo; đối chiếu tên và hinhanh Data URI. |
| 04:20–05:00 | Sửa họ tên và thay ảnh, lưu; đối chiếu Atlas. Tải lại Web, đăng nhập để chứng minh dữ liệu vẫn còn. |
| 05:00–05:30 | Tìm theo họ tên, email; thử từ khóa không có kết quả, xóa tìm kiếm, làm mới. |
| 05:30–06:00 | Xóa: thử Hủy trước, sau đó xác nhận Xóa; refresh Atlas chứng minh đúng bản ghi đã bị xóa. |
| 06:00–07:30 | Mở Android, đăng nhập, hiển thị email/mật khẩu/họ tên/ảnh. Thêm hoặc sửa người dùng bằng ảnh từ thư viện Android, lưu, refresh và xem chi tiết để chứng minh ảnh tải lại. |
| 07:30–08:15 | Chạy audit:data, export; mở users.export.json cho thấy đúng bốn khóa. Mở báo cáo, ảnh minh họa và checklist. |
| 08:15–08:30 | Kết luận chức năng đã chứng minh, nêu giới hạn dùng mật khẩu giả; giới thiệu link source và file database nộp kèm. |

Không nói “đã kết nối Atlas” nếu chỉ đang chạy kiểm thử local. Nếu phần Android hoặc Atlas chưa chạy được, nêu đúng phần còn thiếu và hoàn thành trước khi nộp. Sau khi upload video, điền link thật vào checklist, thử mở bằng cửa sổ ẩn danh để xác nhận giảng viên xem được.
