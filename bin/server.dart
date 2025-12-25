import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:music_backend/database_service.dart';
import 'package:postgres/postgres.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

void main() async {
  final db = DatabaseService();
  await db.connect();

  final router = Router();
  final String secretKey = "TRAN_QUOC_DAI_SECRET";

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

  // ------------------------------------------
  // 1. MỨC DỄ: XEM VÀ TÌM KIẾM
  // ------------------------------------------

  router.get('/tracks', (Request request) async {
    final tracks = await db.getAllTracks();
    return Response.ok(
      jsonEncode(tracks),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.get('/search', (Request request) async {
    final query = request.url.queryParameters['q'] ?? '';
    final data = await db.searchTracks(query);
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
    final result = await db.connection.execute(
      Sql.named('SELECT * FROM tracks WHERE id = @id'),
      parameters: {'id': int.parse(id)},
    );
    if (result.isEmpty)
      return Response.notFound(jsonEncode({'message': 'Không thấy'}));
    return Response.ok(
      jsonEncode(result.first.toColumnMap()),
      headers: {'content-type': 'application/json'},
    );
  });

  // ------------------------------------------
  // 2. MỨC TRUNG BÌNH: THÊM/SỬA/XÓA (CHỈ ADMIN)
  // ------------------------------------------

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
    final authError = await validateAdmin(request);
    if (authError != null) return authError;

    await db.deleteTrack(int.parse(id));
    return Response.ok(jsonEncode({'message': 'Admin đã xóa id $id'}));
  });

  // ------------------------------------------
  // 3. AUTH & THỐNG KÊ & TÌM KIẾM NÂNG CAO
  // ------------------------------------------

  router.post('/auth/register', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    if (await db.findUserByEmail(payload['email']) != null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Email đã tồn tại'}),
      );
    }
    final hashed = BCrypt.hashpw(payload['password'], BCrypt.gensalt());
    await db.createUser(payload['email'], hashed, payload['display_name']);
    return Response.ok(jsonEncode({'message': 'Đăng ký thành công'}));
  });

  router.post('/auth/login', (Request request) async {
    final payload = jsonDecode(await request.readAsString());
    final user = await db.findUserByEmail(payload['email']);

    if (user == null ||
        !BCrypt.checkpw(payload['password'], user['password_hash'])) {
      return Response.forbidden(
        jsonEncode({'error': 'Sai tài khoản hoặc mật khẩu'}),
      );
    }

    final jwt = JWT({'id': user['id'], 'role': user['role']});
    final token = jwt.sign(SecretKey(secretKey), expiresIn: Duration(hours: 1));

    return Response.ok(
      jsonEncode({
        'token': token,
        'user': {'name': user['display_name'], 'role': user['role']},
      }),
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

  // --------------------------------------------------------
  // KHỞI TẠO SERVER (Luôn để ở cuối cùng của hàm main)
  // --------------------------------------------------------
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  var server = await io.serve(handler, '0.0.0.0', 8080);
  print(
    'Backend Spotify đang chạy tại: http://${server.address.host}:${server.port}',
  );
}
