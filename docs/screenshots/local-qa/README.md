# Ảnh chạy thật trong môi trường QA local

Các PNG trong thư mục được chụp từ Chrome headless hoặc Android emulator đang chạy ứng dụng thật. Backend nối **MongoDB tạm thời cục bộ**, không phải MongoDB Atlas. Ảnh avatar màu xanh là file fixture dùng kiểm thử, không phải ảnh chân dung thật.

- `web-login.png`, `web-login-mobile.png`: giao diện đăng nhập Web ở hai kích thước.
- `web-empty.png`: collection QA ban đầu rỗng.
- `web-add-image.png`, `web-list-image.png`: form chọn ảnh và dữ liệu sau lưu.
- `web-search-debug.png`: tìm kiếm không có kết quả (ảnh thật, tên chứa debug do công cụ kiểm thử).
- `web-search.png`: kết quả tìm theo email.
- `web-delete-confirm.png`: xác nhận xóa.
- `android-login.png`, `android-list.png`: màn hình Android thực.
- `android-picker.png`: trình chọn ảnh hệ thống Android với fixture trong thư viện.
- `android-add-image.png`, `android-saved-image.png`: preview ảnh, form và kết quả sau lưu.
- `android-detail-reloaded.png`: ảnh sau refresh và đọc lại chi tiết qua API/MongoDB local.

Không sử dụng thư mục này để khẳng định kết nối Atlas. Sau khi cấu hình Atlas thật, chụp bổ sung các ảnh trong `../README.md` cho hồ sơ nộp bài.
