// ignore_for_file: avoid_print
// Script cập nhật email admin thành camgiacntn@gmail.com

import 'package:postgres/postgres.dart';

void main() async {
  print('=' * 80);
  print('🔄 CẬP NHẬT EMAIL ADMIN');
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
    
    final oldEmail = 'camgiacntn';
    final newEmail = 'camgiacntn@gmail.com';
    
    // Kiểm tra email cũ có tồn tại không
    print('🔍 Kiểm tra email cũ: $oldEmail');
    final checkOld = await connection.execute(
      Sql.named('SELECT id, email, role FROM users WHERE email = @email'),
      parameters: {'email': oldEmail},
    );
    
    if (checkOld.isEmpty) {
      print('❌ Không tìm thấy tài khoản với email: $oldEmail');
      await connection.close();
      return;
    }
    
    final user = checkOld.first;
    final userId = user[0];
    final currentEmail = user[1];
    final role = user[2];
    
    print('✅ Tìm thấy tài khoản:');
    print('   🆔 ID: $userId');
    print('   📧 Email hiện tại: $currentEmail');
    print('   🔑 Role: $role');
    print('');
    
    if (role != 'Admin') {
      print('⚠️  Cảnh báo: Tài khoản này không phải Admin (Role: $role)');
      print('');
    }
    
    // Kiểm tra email mới đã tồn tại chưa
    print('🔍 Kiểm tra email mới: $newEmail');
    final checkNew = await connection.execute(
      Sql.named('SELECT id FROM users WHERE email = @email'),
      parameters: {'email': newEmail},
    );
    
    if (checkNew.isNotEmpty) {
      print('❌ Email $newEmail đã tồn tại!');
      print('   Không thể cập nhật vì email phải unique.');
      await connection.close();
      return;
    }
    
    // Cập nhật email
    print('');
    print('🔄 Đang cập nhật email...');
    await connection.execute(
      Sql.named('UPDATE users SET email = @newEmail WHERE email = @oldEmail'),
      parameters: {'oldEmail': oldEmail, 'newEmail': newEmail},
    );
    
    // Xác nhận
    final verify = await connection.execute(
      Sql.named('SELECT id, email, role FROM users WHERE email = @email'),
      parameters: {'email': newEmail},
    );
    
    if (verify.isNotEmpty) {
      final updatedUser = verify.first;
      print('✅ CẬP NHẬT THÀNH CÔNG!');
      print('=' * 80);
      print('👤 Thông tin tài khoản sau cập nhật:');
      print('   🆔 ID: ${updatedUser[0]}');
      print('   📧 Email: ${updatedUser[1]}');
      print('   🔑 Role: ${updatedUser[2]}');
      print('');
      print('💡 Bây giờ bạn có thể đăng nhập với email: $newEmail');
    } else {
      print('❌ Có lỗi xảy ra khi cập nhật!');
    }
    
    await connection.close();
    
  } catch (e, stackTrace) {
    print('❌ Lỗi: $e');
    print('');
    print('💡 Kiểm tra:');
    print('   1. PostgreSQL đang chạy?');
    print('   2. Database "SpotifyDemo" đã tồn tại?');
    print('   3. Email mới có hợp lệ không?');
    print('');
    print('Stack trace:');
    print(stackTrace);
  }
}

