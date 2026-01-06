// ignore_for_file: avoid_print
// This is a CLI server tool that requires print statements for logging and debugging

import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:music_backend/database_service.dart';
import 'package:postgres/postgres.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:path/path.dart' as path;

void main() async {
  final db = DatabaseService();
  
  try {
    await db.connect();
  } catch (e, stackTrace) {
    print('❌ LỖI KẾT NỐI DATABASE: $e');
    print('Stack trace: $stackTrace');
    print('\n💡 Hướng dẫn:');
    print('1. Kiểm tra PostgreSQL đang chạy');
    print('2. Kiểm tra database "SpotifyDemo" đã tồn tại');
    print('3. Kiểm tra password: 9ducanh9');
    print('4. Kiểm tra tables "tracks" và "users" đã được tạo (chạy init_database.sql)');
    return;
  }

  final router = Router();
  final String secretKey = "TRAN_QUOC_DAI_SECRET";
  final connection = db.connection;

  // --------------------------------------------------------
  // HÀM BỔ TRỢ: KIỂM TRA TOKEN (Đã chèn logic hết hạn mới)
  // --------------------------------------------------------

  // Hàm này trả về Response nếu có lỗi, hoặc null nếu hợp lệ
  Future<Response?> validateAdmin(Request request) async {
    final authHeader = request.headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.forbidden(jsonEncode({'error': 'Thiếu Token xác thực'}));
    }

    try {
      final token = authHeader.replaceFirst('Bearer ', '');
      final jwt = JWT.verify(token, SecretKey(secretKey));

      if (jwt.payload['role'] != 'Admin') {
        return Response.forbidden(jsonEncode({'error': 'Quyền Admin yêu cầu'}));
      }
      return null; // Token hợp lệ và là Admin
    } on JWTExpiredException {
      return Response.forbidden(
        jsonEncode({'error': 'Token đã hết hạn, vui lòng đăng nhập lại'}),
      );
    } on JWTException catch (e) {
      return Response.forbidden(
        jsonEncode({'error': 'Token không hợp lệ: ${e.message}'}),
      );
    }
  }

  // Validate user token và trả về user info (cho bất kỳ user nào)
  Map<String, dynamic>? validateUser(Request request) {
    final authHeader = request.headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return null;
    }

    try {
      final token = authHeader.replaceFirst('Bearer ', '');
      final jwt = JWT.verify(token, SecretKey(secretKey));
      
      return {
        'id': jwt.payload['id'] as int,
        'role': jwt.payload['role'] as String,
      };
    } on JWTExpiredException {
      return null;
    } on JWTException {
      return null;
    }
  }

  // ------------------------------------------
  // 1. MỨC DỄ: XEM VÀ TÌM KIẾM
  // ------------------------------------------

  router.get('/tracks', (Request request) async {
    try {
      // Lấy user_id từ token (nếu có)
      final userInfo = validateUser(request);
      final userId = userInfo?['id'] as int?;
      
      // Chỉ lấy tracks của user đăng nhập
      final tracks = await db.getAllTracks(userId: userId);
      return Response.ok(
        jsonEncode(
          tracks,
          toEncodable: (item) => item is DateTime ? item.toIso8601String() : item,
        ),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      print('Lỗi khi lấy tracks: $e');
      print('Stack trace: $stackTrace');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Lỗi khi lấy danh sách bài hát',
          'message': e.toString(),
          'hint': 'Kiểm tra xem table "tracks" đã được tạo chưa'
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.get('/search', (Request request) async {
    final query = request.url.queryParameters['q'] ?? '';
    // Lấy user_id từ token (nếu có)
    final userInfo = validateUser(request);
    final userId = userInfo?['id'] as int?;
    
    // Chỉ tìm trong tracks của user đăng nhập
    final data = await db.searchTracks(query, userId: userId);
    return Response.ok(
      jsonEncode(
        data,
        toEncodable: (item) =>
            (item is DateTime) ? item.toIso8601String() : item,
      ),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.get('/tracks/<id>', (Request request, String id) async {
    // Lấy user_id từ token
    final userInfo = validateUser(request);
    final userId = userInfo?['id'] as int?;
    
    String query = 'SELECT * FROM tracks WHERE id = @id';
    Map<String, dynamic> params = {'id': int.parse(id)};
    
    // Chỉ cho phép xem tracks của chính user đó
    if (userId != null) {
      query += ' AND user_id = @userId';
      params['userId'] = userId;
    }
    
    final result = await db.connection.execute(
      Sql.named(query),
      parameters: params,
    );
    if (result.isEmpty) {
      return Response.notFound(jsonEncode({'message': 'Không thấy'}));
    }
    return Response.ok(
      jsonEncode(result.first.toColumnMap()),
      headers: {'content-type': 'application/json'},
    );
  });

  // ------------------------------------------
  // 2. MỨC TRUNG BÌNH: THÊM/SỬA/XÓA (CHỈ ADMIN)
  // ------------------------------------------

  // Admin endpoint: Lấy tất cả tracks (không filter theo user)
  router.get('/admin/tracks', (Request request) async {
    final authError = await validateAdmin(request);
    if (authError != null) return authError;

    try {
      // Lấy tất cả tracks (không filter theo userId)
      final tracks = await db.getAllTracks();
      return Response.ok(
        jsonEncode(
          tracks,
          toEncodable: (item) => item is DateTime ? item.toIso8601String() : item,
        ),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      print('Lỗi khi lấy tracks (admin): $e');
      print('Stack trace: $stackTrace');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Lỗi khi lấy danh sách bài hát',
          'message': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Admin endpoint: Lấy tất cả users
  router.get('/admin/users', (Request request) async {
    final authError = await validateAdmin(request);
    if (authError != null) return authError;

    try {
      final users = await db.getAllUsers();
      return Response.ok(
        jsonEncode(
          users,
          toEncodable: (item) => item is DateTime ? item.toIso8601String() : item,
        ),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      print('Lỗi khi lấy users (admin): $e');
      print('Stack trace: $stackTrace');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Lỗi khi lấy danh sách users',
          'message': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.post('/tracks', (Request request) async {
    final authError = await validateAdmin(request);
    if (authError != null) return authError;

    final payload = jsonDecode(await request.readAsString());
    await db.insertTrack(
      payload['title'],
      payload['duration'] ?? 0,
      payload['file_url'] ?? '',
    );
    return Response.ok(
      jsonEncode({'message': 'Admin thêm bài hát thành công'}),
    );
  });

  router.put('/tracks/<id>', (Request request, String id) async {
    final authError = await validateAdmin(request);
    if (authError != null) return authError;

    final payload = jsonDecode(await request.readAsString());
    await db.updateTrack(
      int.parse(id),
      payload['title'],
      payload['duration'],
      payload['file_url'],
    );
    return Response.ok(jsonEncode({'message': 'Admin cập nhật thành công'}));
  });

  router.delete('/tracks/<id>', (Request request, String id) async {
    try {
      final authError = await validateAdmin(request);
      if (authError != null) {
        print('❌ DELETE /tracks/$id - Auth error: ${authError.statusCode}');
        return authError;
      }

      final trackId = int.tryParse(id);
      if (trackId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'ID không hợp lệ'}),
        );
      }

      // Kiểm tra track có tồn tại không
      final trackResult = await connection.execute(
        Sql.named('SELECT id FROM tracks WHERE id = @id'),
        parameters: {'id': trackId},
      );
      
      if (trackResult.isEmpty) {
        return Response.notFound(jsonEncode({'error': 'Không tìm thấy bài hát với ID $trackId'}));
      }

      // Xóa track
      await db.deleteTrack(trackId);
      
      print('✅ DELETE /tracks/$id - Đã xóa thành công');
      return Response.ok(jsonEncode({'message': 'Đã xóa bài hát thành công'}));
    } catch (e, stackTrace) {
      print('❌ DELETE /tracks/$id - Lỗi: $e');
      print('Stack trace: $stackTrace');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Lỗi khi xóa bài hát: $e'}),
      );
    }
  });

  // ------------------------------------------
  // 3. AUTH & THỐNG KÊ & TÌM KIẾM NÂNG CAO
  // ------------------------------------------

  router.post('/auth/register', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final email = payload['email'] as String? ?? '';
    final displayName = payload['display_name'] ?? payload['displayName'] ?? '';
    
    // Validate email bắt buộc và phải là email hợp lệ
    if (email.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Email không được để trống'}),
      );
    }
    
    // Kiểm tra email có format hợp lệ
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Email không hợp lệ. Vui lòng nhập email đúng định dạng (ví dụ: user@example.com)'}),
      );
    }
    
    if (displayName.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Tên hiển thị không được để trống'}),
      );
    }
    
    // Kiểm tra email đã tồn tại chưa
    final existingUser = await db.findUserByEmailOnly(email);
    if (existingUser != null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Email này đã được sử dụng'}),
      );
    }
    
    // Kiểm tra display_name đã tồn tại chưa (username phải unique)
    final existingDisplayName = await connection.execute(
      Sql.named('SELECT * FROM users WHERE display_name = @name'),
      parameters: {'name': displayName},
    );
    if (existingDisplayName.isNotEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Tên hiển thị đã được sử dụng'}),
      );
    }
    
    final hashed = BCrypt.hashpw(payload['password'], BCrypt.gensalt());
    await db.createUser(email, hashed, displayName);
    return Response.ok(jsonEncode({'message': 'Đăng ký thành công'}));
  });

  router.post('/auth/login', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final email = payload['email'] as String? ?? '';
    
    if (email.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Email không được để trống'}),
      );
    }
    
    // Kiểm tra email có format hợp lệ
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Email không hợp lệ'}),
      );
    }
    
    // Tìm user theo email (bắt buộc email)
    final user = await db.findUserByEmailOnly(email);

    if (user == null ||
        !BCrypt.checkpw(payload['password'], user['password_hash'])) {
      return Response.forbidden(
        jsonEncode({'error': 'Sai email hoặc mật khẩu'}),
      );
    }

    final jwt = JWT({'id': user['id'], 'role': user['role']});
    final token = jwt.sign(SecretKey(secretKey), expiresIn: Duration(hours: 1));

    // Cập nhật last_login_at
    await connection.execute(
      Sql.named('UPDATE users SET last_login_at = CURRENT_TIMESTAMP WHERE id = @id'),
      parameters: {'id': user['id']},
    );

    return Response.ok(
      jsonEncode({
        'token': token,
        'user': {
          'name': user['display_name'],
          'role': user['role'],
          'email': user['email'],
        },
      }),
    );
  });

  // Google Sign In
  router.post('/auth/google', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final email = payload['email'] as String?;
    final displayName = payload['display_name'] ?? payload['displayName'] ?? '';
    final avatarUrl = payload['avatar_url'] ?? payload['avatarUrl'];
    
    if (email == null || email.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Email từ Google không hợp lệ'}),
      );
    }
    
    // Tìm hoặc tạo user từ Google
    var user = await db.findUserByEmailOnly(email);
    
    if (user == null) {
      // Tạo user mới từ Google
      await db.createUserFromGoogle(email, displayName, avatarUrl);
      user = await db.findUserByEmailOnly(email);
    } else {
      // Cập nhật thông tin nếu có thay đổi
      if (displayName.isNotEmpty || avatarUrl != null) {
        await connection.execute(
          Sql.named('''
            UPDATE users 
            SET display_name = COALESCE(@name, display_name),
                avatar_url = COALESCE(@avatar, avatar_url),
                last_login_at = CURRENT_TIMESTAMP
            WHERE email = @email
          '''),
          parameters: {
            'email': email,
            'name': displayName.isNotEmpty ? displayName : null,
            'avatar': avatarUrl,
          },
        );
        user = await db.findUserByEmailOnly(email);
      } else {
        // Cập nhật last_login_at
        await connection.execute(
          Sql.named('UPDATE users SET last_login_at = CURRENT_TIMESTAMP WHERE email = @email'),
          parameters: {'email': email},
        );
        user = await db.findUserByEmailOnly(email);
      }
    }
    
    if (user == null) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Không thể tạo/tìm user'}),
      );
    }
    
    // Tạo JWT token
    final jwt = JWT({'id': user['id'], 'role': user['role']});
    final token = jwt.sign(SecretKey(secretKey), expiresIn: Duration(hours: 1));
    
    return Response.ok(
      jsonEncode({
        'token': token,
        'user': {
          'name': user['display_name'],
          'role': user['role'],
          'email': user['email'],
        },
      }),
    );
  });

  // Forgot Password - Gửi mã reset
  router.post('/auth/forgot-password', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final email = payload['email'] as String? ?? '';
    
    if (email.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Email không được để trống'}),
      );
    }
    
    // Kiểm tra email có format hợp lệ
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Email không hợp lệ'}),
      );
    }
    
    // Tìm user theo email
    final user = await db.findUserByEmailOnly(email);
    if (user == null) {
      // Không tiết lộ email có tồn tại hay không (security best practice)
      return Response.ok(
        jsonEncode({'message': 'Nếu email tồn tại, mã khôi phục đã được gửi'}),
      );
    }
    
    // Tạo mã reset 6 số ngẫu nhiên
    final random = DateTime.now().millisecondsSinceEpoch;
    final resetCode = (random % 1000000).toString().padLeft(6, '0');
    
    // Lưu mã reset vào database (hết hạn sau 15 phút)
    final expiresAt = DateTime.now().add(const Duration(minutes: 15));
    await connection.execute(
      Sql.named('''
        UPDATE users 
        SET reset_token = @token, reset_token_expires = @expires
        WHERE email = @email
      '''),
      parameters: {
        'email': email,
        'token': resetCode,
        'expires': expiresAt,
      },
    );
    
    // TODO: Gửi email với mã reset
    // Hiện tại in ra console để test
    print('');
    print('=' * 80);
    print('📧 MÃ KHÔI PHỤC MẬT KHẨU');
    print('=' * 80);
    print('Email: $email');
    print('Mã reset: $resetCode');
    print('Hết hạn sau: 15 phút');
    print('=' * 80);
    print('');
    
    return Response.ok(
      jsonEncode({
        'message': 'Mã khôi phục đã được gửi đến email của bạn',
        // Trong môi trường development, có thể trả về mã để test
        // 'reset_code': resetCode, // Chỉ dùng cho development
      }),
    );
  });
  
  // Reset Password - Đặt lại mật khẩu với mã reset
  router.post('/auth/reset-password', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final email = payload['email'] as String? ?? '';
    final resetCode = payload['reset_code'] as String? ?? '';
    final newPassword = payload['new_password'] as String? ?? '';
    
    if (email.isEmpty || resetCode.isEmpty || newPassword.isEmpty) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Email, mã reset và mật khẩu mới không được để trống'}),
      );
    }
    
    if (newPassword.length < 6) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Mật khẩu mới phải có ít nhất 6 ký tự'}),
      );
    }
    
    // Tìm user và kiểm tra mã reset
    final user = await db.findUserByEmailOnly(email);
    if (user == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Email không tồn tại'}),
      );
    }
    
    final storedToken = user['reset_token'] as String?;
    final tokenExpires = user['reset_token_expires'] as DateTime?;
    
    if (storedToken == null || storedToken != resetCode) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Mã reset không hợp lệ'}),
      );
    }
    
    if (tokenExpires == null || tokenExpires.isBefore(DateTime.now())) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Mã reset đã hết hạn. Vui lòng yêu cầu mã mới'}),
      );
    }
    
    // Cập nhật mật khẩu mới
    final hashed = BCrypt.hashpw(newPassword, BCrypt.gensalt());
    await connection.execute(
      Sql.named('''
        UPDATE users 
        SET password_hash = @pwd, reset_token = NULL, reset_token_expires = NULL
        WHERE email = @email
      '''),
      parameters: {
        'email': email,
        'pwd': hashed,
      },
    );
    
    return Response.ok(
      jsonEncode({'message': 'Đặt lại mật khẩu thành công'}),
    );
  });

  router.get('/stats/top-tracks', (Request request) async {
    final data = await db.getTopTracks();
    return Response.ok(
      jsonEncode(data),
      headers: {'content-type': 'application/json'},
    );
  });

  router.get('/search-advanced', (Request request) async {
    final params = request.url.queryParameters;
    final query = params['q'];
    final albumId = int.tryParse(params['albumId'] ?? '');
    final limit = int.tryParse(params['limit'] ?? '10') ?? 10;
    final offset = int.tryParse(params['offset'] ?? '0') ?? 0;

    final data = await db.searchTracksAdvanced(
      query: query,
      albumId: albumId,
      limit: limit,
      offset: offset,
    );

    return Response.ok(
      jsonEncode(
        data,
        toEncodable: (i) => i is DateTime ? i.toIso8601String() : i,
      ),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.get('/stats/export-csv', (Request request) async {
    final data = await db.getTopTracks();
    String csvContent = "Title,Play Count\n";
    for (var track in data) {
      csvContent += "${track['title']},${track['play_count']}\n";
    }
    return Response.ok(
      csvContent,
      headers: {
        'Content-Type': 'text/csv',
        'Content-Disposition': 'attachment; filename="top_tracks.csv"',
      },
    );
  });

  // Serve static audio files from assets/audio/
  // Handle route manually to support special characters in filename
  Future<Response> serveAudioFiles(Request request) async {
    try {
      // Extract filename from URL path
      final urlPath = request.url.path;
      if (!urlPath.startsWith('/assets/audio/')) {
        return Response.notFound(jsonEncode({'error': 'Invalid path'}));
      }
      
      final filenameFromPath = urlPath.replaceFirst('/assets/audio/', '');
      
      // URL decode filename to handle special characters
      String decodedFilename = filenameFromPath;
      try {
        decodedFilename = Uri.decodeComponent(filenameFromPath);
      } catch (e) {
        // If decoding fails, use original filename
        print('⚠️ Warning: Could not decode filename, using as-is: $filenameFromPath');
      }
      
      // Get the project root
      final currentDir = Directory.current;
      String projectRoot = currentDir.path;
      
      // Check if we're in backend directory
      if (path.basename(currentDir.path) == 'backend') {
        projectRoot = path.dirname(currentDir.path);
      } else if (path.basename(path.dirname(currentDir.path)) == 'backend' && 
                 path.basename(currentDir.path) == 'bin') {
        // If in backend/bin, go up 2 levels
        projectRoot = path.dirname(path.dirname(currentDir.path));
      }
      
      final assetsPath = path.join(projectRoot, 'assets', 'audio', decodedFilename);
      final file = File(assetsPath);
      
      print('📁 Serving audio file:');
      print('   Request URL: ${request.requestedUri}');
      print('   Path: $urlPath');
      print('   Extracted filename: $filenameFromPath');
      print('   Decoded filename: $decodedFilename');
      print('   Current dir: $currentDir');
      print('   Project root: $projectRoot');
      print('   Full path: $assetsPath');
      print('   File exists: ${await file.exists()}');
      
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final extension = path.extension(decodedFilename).toLowerCase();
        
        // Determine content type
        String contentType = 'audio/mpeg'; // default for mp3
        if (extension == '.m4a') {
          contentType = 'audio/mp4';
        } else if (extension == '.wav') {
          contentType = 'audio/wav';
        } else if (extension == '.flac') {
          contentType = 'audio/flac';
        } else if (extension == '.ogg') {
          contentType = 'audio/ogg';
        }
        
        return Response.ok(
          bytes,
          headers: {
            'Content-Type': contentType,
            'Content-Length': bytes.length.toString(),
            'Accept-Ranges': 'bytes',
          },
        );
      } else {
        print('❌ File not found: $assetsPath');
        return Response.notFound(
          jsonEncode({
            'error': 'File not found',
            'requested_filename': filenameFromPath,
            'decoded_filename': decodedFilename,
            'full_path': assetsPath,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error serving file: $e');
      print('Stack trace: $stackTrace');
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Error serving file',
          'message': e.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  // --------------------------------------------------------
  // KHỞI TẠO SERVER (Luôn để ở cuối cùng của hàm main)
  // --------------------------------------------------------
  // Create middleware to handle /assets/audio/ requests before router
  final handler = Pipeline()
      .addMiddleware((innerHandler) {
        return (Request request) async {
          // Handle /assets/audio/ requests
          if (request.url.path.startsWith('/assets/audio/')) {
            return await serveAudioFiles(request);
          }
          // Otherwise, use router
          return innerHandler(request);
        };
      })
      .addMiddleware(logRequests())
      .addHandler(router.call);

  var server = await io.serve(handler, '0.0.0.0', 8080);
  print(
    'Backend Spotify đang chạy tại: http://${server.address.host}:${server.port}',
  );
}
