// ignore_for_file: avoid_print
// Database service may need print statements for debugging connection issues

import 'package:postgres/postgres.dart';
import 'package:bcrypt/bcrypt.dart';

class DatabaseService {
  late Connection connection;

  // Kết nối Database
  Future<void> connect() async {
    connection = await Connection.open(
      Endpoint(
        host: 'localhost',
        database: 'SpotifyDemo',
        username: 'postgres',
        password: '9ducanh9',
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
    print("Kết nối Database thành công!");
  }

  // ==========================================
  // 1. QUẢN LÝ BÀI HÁT (TRACKS)
  // ==========================================

  // Lấy toàn bộ danh sách (Dùng cho route /tracks)
  // Nếu userId được cung cấp, chỉ lấy tracks của user đó
  Future<List<Map<String, dynamic>>> getAllTracks({int? userId}) async {
    String query = 'SELECT * FROM tracks';
    List<dynamic> params = [];
    
    if (userId != null) {
      query += ' WHERE user_id = @userId';
      params.add(userId);
    }
    
    query += ' ORDER BY id ASC';
    
    final result = await connection.execute(
      Sql.named(query),
      parameters: userId != null ? {'userId': userId} : {},
    );
    
    return result.map((row) {
      final map = row.toColumnMap();
      // Convert DateTime to String for JSON serialization
      map.forEach((key, value) {
        if (value is DateTime) {
          map[key] = value.toIso8601String();
        }
      });
      return map;
    }).toList();
  }

  // Tìm kiếm cơ bản (Dùng cho route /search)
  // Nếu userId được cung cấp, chỉ tìm trong tracks của user đó
  Future<List<Map<String, dynamic>>> searchTracks(String query, {int? userId}) async {
    String sqlQuery = "SELECT * FROM tracks WHERE title ILIKE @query";
    Map<String, dynamic> params = {'query': '%$query%'};
    
    if (userId != null) {
      sqlQuery += " AND user_id = @userId";
      params['userId'] = userId;
    }
    
    final result = await connection.execute(
      Sql.named(sqlQuery),
      parameters: params,
    );
    return result.map((row) {
      final map = row.toColumnMap();
      // Convert DateTime to String for JSON serialization
      map.forEach((key, value) {
        if (value is DateTime) {
          map[key] = value.toIso8601String();
        }
      });
      return map;
    }).toList();
  }

  // TÌM KIẾM NÂNG CAO & PHÂN TRANG (Mức Trung bình)
  Future<List<Map<String, dynamic>>> searchTracksAdvanced({
    String? query,
    int? albumId,
    int limit = 10,
    int offset = 0,
  }) async {
    final result = await connection.execute(
      Sql.named(
        'SELECT * FROM tracks WHERE '
        '(@q IS NULL OR title ILIKE @q) AND '
        '(@albumId IS NULL OR album_id = @albumId) '
        'ORDER BY id ASC '
        'LIMIT @limit OFFSET @offset'
      ),
      parameters: {
        'q': query != null ? '%$query%' : null,
        'albumId': albumId,
        'limit': limit,
        'offset': offset,
      },
    );
    return result.map((row) {
      final map = row.toColumnMap();
      // Convert DateTime to String for JSON serialization
      map.forEach((key, value) {
        if (value is DateTime) {
          map[key] = value.toIso8601String();
        }
      });
      return map;
    }).toList();
  }

  // Thêm bài hát (với user_id)
  Future<void> insertTrack(String title, int duration, String url, {int? userId}) async {
    await connection.execute(
      Sql.named('INSERT INTO tracks (title, duration, file_url, user_id) VALUES (@title, @duration, @url, @userId)'),
      parameters: {'title': title, 'duration': duration, 'url': url, 'userId': userId},
    );
  }

  // Cập nhật bài hát
  Future<void> updateTrack(int id, String title, int duration, String fileUrl) async {
    await connection.execute(
      Sql.named('UPDATE tracks SET title = @title, duration = @duration, file_url = @url WHERE id = @id'),
      parameters: {'id': id, 'title': title, 'duration': duration, 'url': fileUrl},
    );
  }

  // Xóa bài hát
  Future<void> deleteTrack(int id) async {
    await connection.execute(
      Sql.named('DELETE FROM tracks WHERE id = @id'),
      parameters: {'id': id},
    );
  }

  // ==========================================
  // 2. QUẢN LÝ NGƯỜI DÙNG (USERS)
  // ==========================================

  // Đăng ký User (hỗ trợ email hoặc username)
  Future<void> createUser(String emailOrUsername, String passwordHash, String name) async {
    await connection.execute(
      Sql.named('INSERT INTO users (email, password_hash, display_name, role) VALUES (@email, @pwd, @name, @role)'),
      parameters: {
        'email': emailOrUsername, // Có thể là email hoặc username
        'pwd': passwordHash,
        'name': name,
        'role': 'User', 
      },
    );
  }

  // Tạo user từ Google (không cần password)
  Future<void> createUserFromGoogle(String email, String displayName, String? avatarUrl) async {
    // Tạo password hash giả (sẽ không dùng để login)
    final dummyHash = BCrypt.hashpw('google_user_${DateTime.now().millisecondsSinceEpoch}', BCrypt.gensalt());
    
    await connection.execute(
      Sql.named('''
        INSERT INTO users (email, password_hash, display_name, role, avatar_url) 
        VALUES (@email, @pwd, @name, @role, @avatar)
        ON CONFLICT (email) DO UPDATE 
        SET display_name = EXCLUDED.display_name,
            avatar_url = EXCLUDED.avatar_url,
            last_login_at = CURRENT_TIMESTAMP
      '''),
      parameters: {
        'email': email,
        'pwd': dummyHash,
        'name': displayName,
        'role': 'User',
        'avatar': avatarUrl,
      },
    );
  }

  // Tìm user theo email (cho Google Sign In)
  Future<Map<String, dynamic>?> findUserByEmailOnly(String email) async {
    final result = await connection.execute(
      Sql.named('SELECT * FROM users WHERE email = @email'),
      parameters: {'email': email},
    );
    if (result.isEmpty) return null;
    final map = result.first.toColumnMap();
    map.forEach((key, value) {
      if (value is DateTime) {
        map[key] = value.toIso8601String();
      }
    });
    return map;
  }

  // Tìm User (Dùng cho Đăng nhập)
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final result = await connection.execute(
      Sql.named('SELECT * FROM users WHERE email = @email'),
      parameters: {'email': email},
    );
    if (result.isEmpty) return null;
    final map = result.first.toColumnMap();
    // Convert DateTime to String for JSON serialization
    map.forEach((key, value) {
      if (value is DateTime) {
        map[key] = value.toIso8601String();
      }
    });
    return map;
  }

  // Tìm User theo Email hoặc Display Name (Username)
  Future<Map<String, dynamic>?> findUserByEmailOrUsername(String identifier) async {
    final result = await connection.execute(
      Sql.named('SELECT * FROM users WHERE email = @identifier OR display_name = @identifier'),
      parameters: {'identifier': identifier},
    );
    if (result.isEmpty) return null;
    final map = result.first.toColumnMap();
    // Convert DateTime to String for JSON serialization
    map.forEach((key, value) {
      if (value is DateTime) {
        map[key] = value.toIso8601String();
      }
    });
    return map;
  }

  // Lấy tất cả users (dùng cho Admin)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final result = await connection.execute(
      Sql.named('''
        SELECT id, email, display_name, role, created_at, last_login_at, avatar_url
        FROM users
        ORDER BY created_at DESC
      '''),
    );
    
    return result.map((row) {
      final map = row.toColumnMap();
      // Convert DateTime to String for JSON serialization
      map.forEach((key, value) {
        if (value is DateTime) {
          map[key] = value.toIso8601String();
        }
      });
      return map;
    }).toList();
  }

  // ==========================================
  // 3. THỐNG KÊ (STATISTICS)
  // ==========================================

  Future<List<Map<String, dynamic>>> getTopTracks() async {
    final result = await connection.execute(
      'SELECT title, play_count FROM tracks ORDER BY play_count DESC LIMIT 5'
    );
    return result.map((row) {
      final map = row.toColumnMap();
      // Convert DateTime to String for JSON serialization
      map.forEach((key, value) {
        if (value is DateTime) {
          map[key] = value.toIso8601String();
        }
      });
      return map;
    }).toList();
  }
}