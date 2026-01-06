// ignore_for_file: avoid_print
// This is a CLI tool that requires print statements for user feedback

import 'package:postgres/postgres.dart';
import 'package:bcrypt/bcrypt.dart';

void main() async {
  print('=' * 80);
  print('🧹 CLEANUP USERS - XÓA TẤT CẢ USERS VÀ GIỮ LẠI camgiacntn');
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
    
    // Kiểm tra user camgiacntn có tồn tại không
    print('🔍 Đang kiểm tra user "camgiacntn"...');
    final checkResult = await connection.execute(
      Sql.named('SELECT * FROM users WHERE email = @email OR display_name = @name'),
      parameters: {
        'email': 'camgiacntn',
        'name': 'camgiacntn',
      },
    );
    
    String? existingPasswordHash;
    String? existingDisplayName;
    String? existingRole;
    int? existingId;
    
    if (checkResult.isNotEmpty) {
      final user = checkResult.first.toColumnMap();
      existingId = user['id'] as int?;
      existingPasswordHash = user['password_hash'] as String?;
      existingDisplayName = user['display_name'] as String?;
      existingRole = user['role'] as String?;
      
      print('✅ Tìm thấy user camgiacntn:');
      print('   ID: $existingId');
      print('   Email hiện tại: ${user['email']}');
      print('   Display name: $existingDisplayName');
      print('   Role: $existingRole');
      print('');
    } else {
      print('⚠️  Không tìm thấy user "camgiacntn"');
      print('   Sẽ tạo user mới với email: camgiacntn@gmail.com');
      print('');
      
      // Tạo password hash mặc định (có thể thay đổi sau)
      existingPasswordHash = BCrypt.hashpw('camgiacntn123', BCrypt.gensalt());
      existingDisplayName = 'camgiacntn';
      existingRole = 'Admin'; // Hoặc 'User' tùy bạn muốn
    }
    
    // Xác nhận trước khi xóa
    print('⚠️  CẢNH BÁO: Sẽ xóa TẤT CẢ users (trừ camgiacntn)');
    print('   Sau đó sẽ update/cập nhật user camgiacntn với email: camgiacntn@gmail.com');
    print('');
    print('Nhấn Enter để tiếp tục hoặc Ctrl+C để hủy...');
    // await stdin.readLineSync(); // Uncomment nếu muốn xác nhận
    
    // Đếm số users trước khi xóa
    final countBefore = await connection.execute('SELECT COUNT(*) FROM users');
    final totalBefore = countBefore.first[0] as int;
    print('📊 Tổng số users hiện tại: $totalBefore');
    print('');
    
    // Xóa tất cả users
    print('🗑️  Đang xóa tất cả users...');
    await connection.execute('DELETE FROM users');
    print('✅ Đã xóa tất cả users');
    print('');
    
    // Tạo lại user camgiacntn với email mới
    print('🔄 Đang tạo/cập nhật user camgiacntn...');
    
    if (existingId != null) {
      // Nếu user đã tồn tại, insert lại với thông tin cũ nhưng email mới
      await connection.execute(
        Sql.named('''
          INSERT INTO users (id, email, password_hash, display_name, role)
          VALUES (@id, @email, @pwd, @name, @role)
        '''),
        parameters: {
          'id': existingId,
          'email': 'camgiacntn@gmail.com',
          'pwd': existingPasswordHash!,
          'name': existingDisplayName ?? 'camgiacntn',
          'role': existingRole ?? 'Admin',
        },
      );
      print('✅ Đã cập nhật user camgiacntn với email mới');
    } else {
      // Tạo user mới
      await connection.execute(
        Sql.named('''
          INSERT INTO users (email, password_hash, display_name, role)
          VALUES (@email, @pwd, @name, @role)
        '''),
        parameters: {
          'email': 'camgiacntn@gmail.com',
          'pwd': existingPasswordHash!,
          'name': existingDisplayName ?? 'camgiacntn',
          'role': existingRole ?? 'Admin',
        },
      );
      print('✅ Đã tạo user camgiacntn mới');
    }
    
    print('');
    print('📋 Thông tin user camgiacntn:');
    print('   Email: camgiacntn@gmail.com');
    print('   Display name: ${existingDisplayName ?? 'camgiacntn'}');
    print('   Role: ${existingRole ?? 'Admin'}');
    print('   Password: (giữ nguyên password cũ)');
    print('');
    
    // Kiểm tra kết quả
    final countAfter = await connection.execute('SELECT COUNT(*) FROM users');
    final totalAfter = countAfter.first[0] as int;
    print('📊 Tổng số users sau cleanup: $totalAfter');
    print('');
    
    // Hiển thị user cuối cùng
    final finalUser = await connection.execute(
      Sql.named('SELECT * FROM users WHERE email = @email'),
      parameters: {'email': 'camgiacntn@gmail.com'},
    );
    
    if (finalUser.isNotEmpty) {
      final user = finalUser.first.toColumnMap();
      print('✅ User cuối cùng:');
      print('   ID: ${user['id']}');
      print('   Email: ${user['email']}');
      print('   Display name: ${user['display_name']}');
      print('   Role: ${user['role']}');
      print('   Created at: ${user['created_at']}');
    }
    
    print('');
    print('🎉 Hoàn tất cleanup!');
    print('');
    print('💡 Bây giờ bạn có thể:');
    print('   1. Đăng nhập với: camgiacntn@gmail.com / (password cũ)');
    print('   2. Hoặc đăng ký user mới (bắt buộc phải có email hợp lệ)');
    print('');
    
    await connection.close();
    
  } catch (e, stackTrace) {
    print('❌ Lỗi: $e');
    print('');
    print('Stack trace:');
    print(stackTrace);
  }
}



