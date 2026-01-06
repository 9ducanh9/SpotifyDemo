// ignore_for_file: avoid_print
// This is a CLI tool that requires print statements for user feedback

import 'dart:io';
import 'package:postgres/postgres.dart';
import 'package:bcrypt/bcrypt.dart';

void main(List<String> args) async {
  // Lấy thông tin từ arguments hoặc dùng giá trị mặc định
  final email = args.isNotEmpty ? args[0] : 'lamchitai2200@gmail.com';
  final password = args.length > 1 ? args[1] : '9ducanh9';
  final displayName = args.length > 2 ? args[2] : 'Admin';
  
  print('=' * 80);
  print('👤 TẠO TÀI KHOẢN ADMIN');
  print('=' * 80);
  print('');
  print('📋 Thông tin tài khoản:');
  print('   Email: $email');
  print('   Display Name: $displayName');
  print('   Role: Admin');
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
    
    // Kiểm tra xem email đã tồn tại chưa
    print('🔍 Đang kiểm tra email...');
    final checkResult = await connection.execute(
      Sql.named('SELECT * FROM users WHERE email = @email'),
      parameters: {'email': email},
    );
    
    if (checkResult.isNotEmpty) {
      final user = checkResult.first.toColumnMap();
      print('⚠️  Email đã tồn tại!');
      print('   ID: ${user['id']}');
      print('   Email: ${user['email']}');
      print('   Display Name: ${user['display_name']}');
      print('   Role: ${user['role']}');
      print('');
      print('💡 Bạn có muốn cập nhật password và role thành Admin không?');
      print('   (Script sẽ tự động cập nhật)');
      print('');
      
      // Hash password mới
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
      
      // Cập nhật user
      await connection.execute(
        Sql.named('''
          UPDATE users 
          SET password_hash = @pwd, 
              display_name = @name, 
              role = 'Admin',
              updated_at = CURRENT_TIMESTAMP
          WHERE email = @email
        '''),
        parameters: {
          'email': email,
          'pwd': passwordHash,
          'name': displayName,
        },
      );
      
      print('✅ Đã cập nhật tài khoản thành Admin!');
    } else {
      // Hash password
      print('🔐 Đang hash password...');
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
      print('✅ Đã hash password');
      print('');
      
      // Tạo user mới
      print('👤 Đang tạo tài khoản Admin...');
      await connection.execute(
        Sql.named('''
          INSERT INTO users (email, password_hash, display_name, role)
          VALUES (@email, @pwd, @name, 'Admin')
        '''),
        parameters: {
          'email': email,
          'pwd': passwordHash,
          'name': displayName,
        },
      );
      
      print('✅ Đã tạo tài khoản Admin thành công!');
    }
    
    // Hiển thị thông tin user cuối cùng
    print('');
    print('📋 Thông tin tài khoản:');
    final finalResult = await connection.execute(
      Sql.named('SELECT * FROM users WHERE email = @email'),
      parameters: {'email': email},
    );
    
    if (finalResult.isNotEmpty) {
      final user = finalResult.first.toColumnMap();
      print('   ID: ${user['id']}');
      print('   Email: ${user['email']}');
      print('   Display Name: ${user['display_name']}');
      print('   Role: ${user['role']}');
      print('   Created At: ${user['created_at']}');
    }
    
    print('');
    print('🎉 Hoàn tất!');
    print('');
    print('💡 Bây giờ bạn có thể đăng nhập với:');
    print('   Email: $email');
    print('   Password: $password');
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

