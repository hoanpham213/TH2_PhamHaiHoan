# Note_App

Ứng dụng ghi chú đơn giản viết bằng Flutter.

## Tính năng

- Thêm, sửa, xóa ghi chú
- Tìm kiếm theo tiêu đề
- Ghi chú được lưu vào `SharedPreferences` dưới dạng JSON
- Giao diện lưới Masonry (2 cột) với màu nền thay đổi
- Hỗ trợ cả Android và iOS (sử dụng Android embedding v2)

## Cấu trúc thư mục chính

```
lib/
  main.dart              # entry point
  models/note.dart       # lớp dữ liệu Note
  screens/
    home_screen.dart     # màn hình chính
    add_note_screen.dart # thêm ghi chú
    edit_note_screen.dart# sửa/xóa ghi chú
android/                # project Android
ios/                    # project iOS
pubspec.yaml            # phụ thuộc của Flutter
```

## Hướng dẫn chạy

1. Cài đặt Flutter và đảm bảo `flutter` trong PATH.
2. Mở terminal tại thư mục dự án:
   ```bash
   cd C:\Users\hoand\Documents\DART\Note_App
   flutter pub get
   ```
3. Khởi chạy ứng dụng trên thiết bị hoặc emulator:
   ```bash
   flutter run
   ```

## Lưu ý

- Nếu gặp lỗi liên quan đến Android embedding (v1/v2), xóa thư mục
  `android/` và chạy `flutter create .` để tái tạo.
- Hiện đang dùng `WillPopScope`; có thể chuyển sang `PopScope` khi nâng
  cấp Flutter.

## Mở rộng

Bạn có thể:

- Thay `SharedPreferences` bằng SQLite/Cloud Firestore để lưu trữ lâu dài.
- Thêm phân loại, thẻ, hay màu sắc cho ghi chú.
- Đồng bộ hóa ghi chú giữa nhiều thiết bị qua Firebase hoặc REST API.

---

*Được cập nhật tự động theo lịch sử chỉnh sửa trong cuộc trò chuyện.*