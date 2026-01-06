// ignore_for_file: avoid_print
// Script kiểm tra tài khoản admin

import 'package:postgres/postgres.dart';

void main() async {
  print('=' * 80);
  print('🔍 KIỂM TRA TÀI KHOẢN ADMIN');
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
    
    // Tìm tài khoản với email camgiacntn@gmail.com
    final targetEmail = 'camgiacntn@gmail.com';
    print('🔍 Tìm kiếm email: $targetEmail');
    print('');
    
    final result = await connection.execute(
      Sql.named('SELECT * FROM users WHERE email = @email'),
      parameters: {'email': targetEmail},
    );
    
    if (result.isEmpty) {
      print('❌ KHÔNG TÌM THẤY tài khoản với email: $targetEmail');
      print('');
      
      // Tìm kiếm các email tương tự
      print('🔍 Tìm kiếm các email tương tự (chứa "camgiacntn")...');
      final similarResult = await connection.execute(
        Sql.named("SELECT id, email, display_name, role FROM users WHERE email LIKE @pattern"),
        parameters: {'pattern': '%camgiacntn%'},
      );
      
      if (similarResult.isNotEmpty) {
        print('');
        print('📋 Tìm thấy ${similarResult.length} tài khoản tương tự:');
        print('=' * 80);
        for (var row in similarResult) {
          print('👤 User ID: ${row[0]}');
          print('   📧 Email: ${row[1]}');
          print('   👤 Tên: ${row[2]}');
          print('   🔑 Role: ${row[3]}');
          print('');
        }
      } else {
        print('❌ Không tìm thấy email nào chứa "camgiacntn"');
      }
    } else {
      final user = result.first;
      final userId = user[0];
      final email = user[1];
      final displayName = user[3];
      final role = user[4];
      
      print('✅ TÌM THẤY tài khoản:');
      print('=' * 80);
      print('   🆔 ID: $userId');
      print('   📧 Email: $email');
      print('   👤 Tên hiển thị: $displayName');
      print('   🔑 Role: $role');
      print('');
      
      if (role == 'Admin') {
        print('✅ ĐÚNG! Đây là tài khoản Admin');
      } else {
        print('⚠️  Tài khoản này KHÔNG phải Admin (Role: $role)');
        print('');
        print('💡 Để nâng cấp thành Admin:');
        print('   UPDATE users SET role = \'Admin\' WHERE email = \'$targetEmail\';');
      }
    }
    
    // Hiển thị tất cả Admin
    print('=' * 80);
    print('📊 TẤT CẢ TÀI KHOẢN ADMIN');
    print('=' * 80);
    print('');
    
    final adminResult = await connection.execute(
      Sql.named("SELECT id, email, display_name, created_at FROM users WHERE role = 'Admin'"),
    );
    
    if (adminResult.isEmpty) {
      print('❌ Không có tài khoản Admin nào!');
    } else {
      print('✅ Tìm thấy ${adminResult.length} tài khoản Admin:');
      print('');
      for (var i = 0; i < adminResult.length; i++) {
        final row = adminResult[i];
        print('👤 Admin #${i + 1}');
        print('   🆔 ID: ${row[0]}');
        print('   📧 Email: ${row[1]}');
        print('   👤 Tên: ${row[2]}');
        print('   📅 Tạo lúc: ${row[3]}');
        print('');
      }
    }
    
    await connection.close();
    
  } catch (e, stackTrace) {
    print('❌ Lỗi: $e');
    print('');
    print('💡 Kiểm tra:');
    print('   1. PostgreSQL đang chạy?');
    print('   2. Database "SpotifyDemo" đã tồn tại?');
    print('   3. Username/password đúng? (postgres / 9ducanh9)');
    print('');
    print('Stack trace:');
    print(stackTrace);
  }
}

