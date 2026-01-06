# Backend Server - SpotifyDemo

## Yêu Cầu

- Dart SDK 3.10.1 trở lên
- PostgreSQL đang chạy
- Database `SpotifyDemo` đã được tạo
- Tables `users` và `tracks` đã được khởi tạo

## Cách Chạy Backend

### Windows (PowerShell)
```powershell
.\start_backend.ps1
```

### Windows (Command Prompt)
```cmd
start_backend.bat
```

### Thủ Công
```bash
cd backend
dart pub get
dart run bin/server.dart
```

## Cấu Hình Database

Backend mặc định kết nối đến:
- Host: `localhost`
- Database: `SpotifyDemo`
- Username: `postgres`
- Password: `9ducanh9`

Để thay đổi, sửa file `backend/lib/database_service.dart`

## Endpoints

Server chạy tại: `http://localhost:8080`

### Public Endpoints
- `GET /stats/top-tracks` - Lấy top 5 bài hát phát nhiều nhất
- `POST /auth/register` - Đăng ký
- `POST /auth/login` - Đăng nhập
- `POST /auth/google` - Đăng nhập Google

### User Endpoints (Yêu cầu token)
- `GET /tracks` - Lấy danh sách bài hát của user
- `GET /search?q=...` - Tìm kiếm bài hát
- `GET /tracks/<id>` - Lấy thông tin bài hát

### Admin Endpoints (Yêu cầu Admin token)
- `GET /admin/tracks` - Lấy tất cả bài hát (không filter)
- `POST /tracks` - Thêm bài hát mới
- `PUT /tracks/<id>` - Cập nhật bài hát
- `DELETE /tracks/<id>` - Xóa bài hát

## Khởi Tạo Database

Nếu chưa có database và tables, chạy:
```bash
cd backend
dart run bin/init_tables.dart
```

## Kiểm Tra Server

Sau khi chạy, server sẽ hiển thị:
```
Backend Spotify đang chạy tại: http://0.0.0.0:8080
```

Kiểm tra server có chạy:
```powershell
netstat -an | findstr ":8080"
```

## Dừng Server

Nhấn `Ctrl+C` trong terminal đang chạy server.



