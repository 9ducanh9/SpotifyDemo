import 'package:postgres/postgres.dart';

class DatabaseService {
  late Connection connection;

  // Kết nối Database
  Future<void> connect() async {
    connection = await Connection.open(
      Endpoint(
        host: 'localhost',
        database: 'postgres',
        username: 'postgres',
        password: '130804', // Thay bằng mật khẩu của bạn
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );
    print("Kết nối Database thành công!");
  }

  // ==========================================
  // 1. QUẢN LÝ BÀI HÁT (TRACKS)
  // ==========================================

  // Lấy toàn bộ danh sách (Dùng cho route /tracks)
  Future<List<Map<String, dynamic>>> getAllTracks() async {
    final result = await connection.execute('SELECT * FROM tracks ORDER BY id ASC');
    return result.map((row) => row.toColumnMap()).toList();
  }

  // Tìm kiếm cơ bản (Dùng cho route /search)
  Future<List<Map<String, dynamic>>> searchTracks(String query) async {
    final result = await connection.execute(
      Sql.named("SELECT * FROM tracks WHERE title ILIKE @query"),
      parameters: {'query': '%$query%'},
    );
    return result.map((row) => row.toColumnMap()).toList();
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
    return result.map((row) => row.toColumnMap()).toList();
  }

  // Thêm bài hát
  Future<void> insertTrack(String title, int duration, String url) async {
    await connection.execute(
      Sql.named('INSERT INTO tracks (title, duration, file_url) VALUES (@title, @duration, @url)'),
      parameters: {'title': title, 'duration': duration, 'url': url},
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

  // Đăng ký User (Mức Trung bình)
  Future<void> createUser(String email, String passwordHash, String name) async {
    await connection.execute(
      Sql.named('INSERT INTO users (email, password_hash, display_name, role) VALUES (@email, @pwd, @name, @role)'),
      parameters: {
        'email': email,
        'pwd': passwordHash,
        'name': name,
        'role': 'User', 
      },
    );
  }

  // Tìm User (Dùng cho Đăng nhập)
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final result = await connection.execute(
      Sql.named('SELECT * FROM users WHERE email = @email'),
      parameters: {'email': email},
    );
    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  // ==========================================
  // 3. THỐNG KÊ (STATISTICS)
  // ==========================================

  Future<List<Map<String, dynamic>>> getTopTracks() async {
    final result = await connection.execute(
      'SELECT title, play_count FROM tracks ORDER BY play_count DESC LIMIT 5'
    );
    return result.map((row) => row.toColumnMap()).toList();
  }
}