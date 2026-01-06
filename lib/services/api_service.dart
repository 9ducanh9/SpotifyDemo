import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service xử lý các API calls với backend server
class ApiService {
  /// Lấy token xác thực từ SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  /// Tạo headers cho HTTP request (bao gồm token nếu cần)
  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Lấy tất cả tracks từ API (gửi token để filter theo user)
  Future<List<Track>> getTracks() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.tracksEndpoint),
        headers: await _getHeaders(requiresAuth: true), // Luôn gửi token nếu có
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('API request timeout');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Track.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tracks: $e');
    }
  }

  /// Tìm kiếm tracks theo query
  Future<List<Track>> searchTracks(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.searchEndpoint}?q=$query'),
        headers: await _getHeaders(requiresAuth: true), // Luôn gửi token nếu có
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Track.fromMap(json)).toList();
      } else {
        throw Exception('Failed to search tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching tracks: $e');
    }
  }

  /// Lấy track theo ID
  Future<Track> getTrackById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.tracksEndpoint}/$id'),
        headers: await _getHeaders(requiresAuth: true), // Luôn gửi token nếu có
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Track.fromMap(data);
      } else {
        throw Exception('Failed to load track: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching track: $e');
    }
  }

  /// Tạo track mới (chỉ Admin)
  Future<void> createTrack(Track track) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.tracksEndpoint),
        headers: await _getHeaders(requiresAuth: true),
        body: jsonEncode(track.toMap()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create track: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating track: $e');
    }
  }

  /// Cập nhật track (chỉ Admin)
  Future<void> updateTrack(int id, Track track) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.tracksEndpoint}/$id'),
        headers: await _getHeaders(requiresAuth: true),
        body: jsonEncode(track.toMap()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update track: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating track: $e');
    }
  }

  /// Xóa track (chỉ Admin)
  Future<void> deleteTrack(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.tracksEndpoint}/$id'),
        headers: await _getHeaders(requiresAuth: true),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - Backend không phản hồi');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // Success
      }

      // Parse thông báo lỗi từ response
      String errorMessage = 'Failed to delete track: ${response.statusCode}';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['error'] ?? errorMessage;
      } catch (_) {
        // Nếu không parse được, dùng thông báo mặc định
      }

      throw Exception(errorMessage);
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('timeout')) {
        errorMessage = 'Kết nối timeout. Vui lòng kiểm tra backend server.';
      } else if (errorMessage.contains('SocketException') || errorMessage.contains('Failed host lookup')) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      } else if (errorMessage.contains('403') || errorMessage.contains('forbidden')) {
        errorMessage = 'Bạn không có quyền xóa bài hát. Chỉ Admin mới có quyền này.';
      }
      throw Exception(errorMessage);
    }
  }

  /// Lấy tất cả tracks cho Admin (không filter theo user)
  Future<List<Track>> getAllTracksForAdmin() async {
    try {
      final url = '${AppConstants.baseUrl}/admin/tracks';
      final headers = await _getHeaders(requiresAuth: true);
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - Backend không phản hồi');
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Track.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tracks: $e');
    }
  }

  /// Lấy danh sách top tracks (cho thống kê)
  Future<List<Map<String, dynamic>>> getTopTracks() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.statsEndpoint),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load top tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching top tracks: $e');
    }
  }

  /// Lấy danh sách tất cả users (chỉ Admin)
  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.adminUsersEndpoint),
        headers: await _getHeaders(requiresAuth: true),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - Backend không phản hồi');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }
}

