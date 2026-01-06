// ignore_for_file: avoid_print
// This is a CLI tool that requires print statements

import 'package:postgres/postgres.dart';

void main() async {
  print('=' * 80);
  print('👥 DANH SÁCH TẤT CẢ TÀI KHOẢN');
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
    
    // Lấy tất cả users
    final result = await connection.execute('''
      SELECT id, email, display_name, role, created_at, last_login_at, avatar_url
      FROM users
      ORDER BY created_at DESC
    ''');
    
    if (result.isEmpty) {
      print('⚠️  Không có user nào trong database!');
      print('');
      print('💡 Tạo user mẫu:');
      print('   dart run bin/init_tables.dart');
      await connection.close();
      return;
    }
    
    print('📊 Tìm thấy ${result.length} tài khoản:');
    print('=' * 80);
    print('');
    
    for (var i = 0; i < result.length; i++) {
      final row = result[i];
      final userId = row[0];
      final email = row[1];
      final displayName = row[2];
      final role = row[3];
      final createdAt = row[4];
      final lastLoginAt = row[5];
      final avatarUrl = row[6];
      
      print('👤 User #${i + 1}');
      print('   🆔 ID: $userId');
      print('   📧 Email: $email');
      print('   👤 Tên hiển thị: $displayName');
      print('   🔑 Role: $role');
      
      if (createdAt != null) {
        print('   📅 Tạo lúc: $createdAt');
      }
      if (lastLoginAt != null) {
        print('   🕒 Đăng nhập lần cuối: $lastLoginAt');
      }
      if (avatarUrl != null) {
        print('   🖼️  Avatar: $avatarUrl');
      }
      
      print('');
    }
    
    // Thống kê
    print('=' * 80);
    print('📊 THỐNG KÊ');
    print('=' * 80);
    
    final totalResult = await connection.execute('SELECT COUNT(*) FROM users');
    final totalUsers = totalResult.first[0];
    
    final adminResult = await connection.execute("SELECT COUNT(*) FROM users WHERE role = 'Admin'");
    final adminCount = adminResult.first[0];
    
    final userResult = await connection.execute("SELECT COUNT(*) FROM users WHERE role = 'User'");
    final userCount = userResult.first[0];
    
    final creatorResult = await connection.execute("SELECT COUNT(*) FROM users WHERE role = 'Creator'");
    final creatorCount = creatorResult.first[0];
    
    print('Tổng số users: $totalUsers');
    print('  - Admin: $adminCount');
    print('  - User: $userCount');
    print('  - Creator: $creatorCount');
    print('');
    
    // Hiển thị thông tin đăng nhập
    print('=' * 80);
    print('🔐 THÔNG TIN ĐĂNG NHẬP');
    print('=' * 80);
    print('');
    print('⚠️  Lưu ý: Password đã được hash bằng BCrypt, không thể hiển thị.');
    print('');
    print('💡 Để test đăng nhập:');
    print('   - User admin mẫu: admin@example.com / admin123');
    print('   - Hoặc đăng ký user mới qua app');
    print('');
    
    await connection.close();
    
  } catch (e, stackTrace) {
    print('❌ Lỗi: $e');
    print('');
    print('💡 Kiểm tra:');
    print('   1. PostgreSQL đang chạy?');
    print('   2. Database "SpotifyDemo" đã tồn tại?');
    print('   3. Username/password đúng? (postgres / 9ducanh9)');
    print('   4. Port 5432 đang mở?');
    print('');
    print('Stack trace:');
    print(stackTrace);
  }
}

