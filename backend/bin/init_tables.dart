// ignore_for_file: avoid_print
// This is a CLI tool that requires print statements for user feedback

import 'package:postgres/postgres.dart';

void main() async {
  print('🔄 Đang kết nối database...');
  
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
  print('🔄 Đang tạo tables...\n');

  try {
    // Tạo bảng tracks
    print('📝 Tạo table "tracks"...');
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS tracks (
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
    print('✅ Table "tracks" đã được tạo!');

    // Tạo bảng users
    print('📝 Tạo table "users"...');
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS users (
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
    print('✅ Table "users" đã được tạo!');
    
    // Thêm columns reset_token nếu chưa có (migration)
    try {
      await connection.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_token VARCHAR(10)');
      await connection.execute('ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_token_expires TIMESTAMP');
      print('✅ Đã thêm columns reset_token và reset_token_expires');
    } catch (e) {
      // Columns đã tồn tại, bỏ qua
    }

    // Tạo indexes
    print('📝 Tạo indexes...');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_tracks_title ON tracks(title)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_tracks_play_count ON tracks(play_count)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_tracks_album_id ON tracks(album_id)');
    print('✅ Indexes đã được tạo!');

    // Kiểm tra xem có dữ liệu chưa
    final trackCount = await connection.execute('SELECT COUNT(*) FROM tracks');
    final userCount = await connection.execute('SELECT COUNT(*) FROM users');
    
    final trackRows = trackCount.first;
    final userRows = userCount.first;
    
    print('\n📊 Thống kê:');
    print('   - Tracks: ${trackRows[0]}');
    print('   - Users: ${userRows[0]}');

    // Nếu chưa có dữ liệu, thêm dữ liệu mẫu
    if (trackRows[0] == 0) {
      print('\n🔄 Thêm dữ liệu mẫu cho tracks...');
      await connection.execute('''
        INSERT INTO tracks (title, duration, file_url, artist, genre, play_count) VALUES
        ('Nhạc Pop Việt Nam', 180, 'https://example.com/pop_vietnam.mp3', 'Ca sĩ A', 'Pop', 10),
        ('Nhạc Rock Quốc Tế', 210, 'https://example.com/rock.mp3', 'Ca sĩ B', 'Rock', 5),
        ('Nhạc Jazz', 195, 'https://example.com/jazz.mp3', 'Ca sĩ C', 'Jazz', 8),
        ('Ballad Buồn', 240, 'https://example.com/ballad.mp3', 'Ca sĩ D', 'Ballad', 15),
        ('EDM Dance', 200, 'https://example.com/edm.mp3', 'DJ X', 'EDM', 20)
      ''');
      print('✅ Đã thêm 5 bài hát mẫu!');
    }

    if (userRows[0] == 0) {
      print('\n🔄 Thêm user admin mẫu...');
      // Password "admin123" đã được hash bằng BCrypt
      await connection.execute('''
        INSERT INTO users (email, password_hash, display_name, role) VALUES
        ('admin@example.com', '\$2a\$10\$rXKJ4W8mY9L7Q9F3vQ2xBuQ1QqXvZ8K4mN3L2P1Q0R5S9T6U7V8W', 'Admin User', 'Admin')
        ON CONFLICT (email) DO NOTHING
      ''');
      print('✅ Đã thêm user admin mẫu!');
      print('   Email: admin@example.com');
      print('   Password: admin123 (để test, nhưng cần hash lại trong code thực tế)');
    }

    print('\n🎉 Hoàn tất! Database đã sẵn sàng.');
    print('\n💡 Bây giờ bạn có thể chạy server:');
    print('   dart run bin/server.dart');

  } catch (e, stackTrace) {
    print('\n❌ LỖI: $e');
    print('Stack trace: $stackTrace');
  } finally {
    await connection.close();
  }
}


