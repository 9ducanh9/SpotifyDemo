// ignore_for_file: avoid_print
// This is a CLI tool that requires print statements for user feedback

import 'dart:io';
import 'package:postgres/postgres.dart';

void main() async {
  print('=' * 80);
  print('🔄 RESET BACKEND - XÓA TẤT CẢ DỮ LIỆU VÀ TẠO LẠI DATABASE');
  print('=' * 80);
  print('');
  
  print('🔌 Đang kết nối database...');
  
  try {
    final connection = await Connection.open(
      Endpoint(
        host: 'localhost',
        database: 'SpotifyDemo',
        username: 'postgres',
        password: '9ducanh9',
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
    
    print('✅ Kết nối thành công!');
    print('');
    
    // Đếm dữ liệu hiện tại
    final trackCount = await connection.execute('SELECT COUNT(*) FROM tracks');
    final userCount = await connection.execute('SELECT COUNT(*) FROM users');
    final totalTracks = trackCount.first[0] as int;
    final totalUsers = userCount.first[0] as int;
    
    print('📊 Dữ liệu hiện tại:');
    print('   - Tracks: $totalTracks');
    print('   - Users: $totalUsers');
    print('');
    
    print('⚠️  CẢNH BÁO: Sẽ xóa TẤT CẢ dữ liệu!');
    print('   - Tất cả tracks sẽ bị xóa');
    print('   - Tất cả users sẽ bị xóa');
    print('   - Tables sẽ được tạo lại');
    print('');
    print('Nhấn Enter để tiếp tục hoặc Ctrl+C để hủy...');
    // await stdin.readLineSync(); // Uncomment nếu muốn xác nhận
    
    // Xóa tất cả dữ liệu
    print('');
    print('🗑️  Đang xóa dữ liệu...');
    
    // Xóa tracks trước (vì có thể có foreign key)
    await connection.execute('DELETE FROM tracks');
    print('   ✅ Đã xóa tất cả tracks');
    
    // Xóa users
    await connection.execute('DELETE FROM users');
    print('   ✅ Đã xóa tất cả users');
    
    // Drop và tạo lại tables
    print('');
    print('🔄 Đang tạo lại tables...');
    
    // Drop tables nếu tồn tại
    await connection.execute('DROP TABLE IF EXISTS tracks CASCADE');
    await connection.execute('DROP TABLE IF EXISTS users CASCADE');
    print('   ✅ Đã xóa tables cũ');
    
    // Tạo lại table tracks
    print('📝 Tạo table "tracks"...');
    await connection.execute('''
      CREATE TABLE tracks (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        duration INTEGER NOT NULL DEFAULT 0,
        file_url VARCHAR(500) NOT NULL,
        album_id INTEGER,
        play_count INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        artist VARCHAR(255),
        genre VARCHAR(100)
      )
    ''');
    print('   ✅ Table "tracks" đã được tạo!');
    
    // Tạo lại table users
    print('📝 Tạo table "users"...');
    await connection.execute('''
      CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        display_name VARCHAR(255) NOT NULL,
        role VARCHAR(50) DEFAULT 'User',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        last_login_at TIMESTAMP,
        avatar_url VARCHAR(500),
        reset_token VARCHAR(10),
        reset_token_expires TIMESTAMP
      )
    ''');
    print('   ✅ Table "users" đã được tạo!');
    
    // Tạo indexes
    print('📝 Tạo indexes...');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_tracks_title ON tracks(title)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_tracks_play_count ON tracks(play_count)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_tracks_album_id ON tracks(album_id)');
    print('   ✅ Indexes đã được tạo!');
    
    // Kiểm tra kết quả
    final trackCountAfter = await connection.execute('SELECT COUNT(*) FROM tracks');
    final userCountAfter = await connection.execute('SELECT COUNT(*) FROM users');
    
    print('');
    print('📊 Dữ liệu sau reset:');
    print('   - Tracks: ${trackCountAfter.first[0]}');
    print('   - Users: ${userCountAfter.first[0]}');
    print('');
    
    print('🎉 Hoàn tất reset backend!');
    print('');
    print('💡 Bây giờ bạn có thể:');
    print('   1. Chạy init_tables.dart để thêm dữ liệu mẫu (nếu cần)');
    print('   2. Hoặc bắt đầu sử dụng backend với dữ liệu trống');
    print('   3. Chạy server: dart run bin/server.dart');
    print('');
    
    await connection.close();
    
  } catch (e, stackTrace) {
    print('❌ Lỗi: $e');
    print('');
    print('Stack trace:');
    print(stackTrace);
    exit(1);
  }
}

