import 'dart:io';

/// Các hằng số cấu hình của ứng dụng
class AppConstants {
  /// Lấy base URL của API (tự động detect platform)
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Android Emulator: 10.0.2.2 là alias của localhost
      return 'http://10.0.2.2:8080';
    } else {
      // iOS, Windows, macOS, Linux, Web: dùng localhost
      return 'http://localhost:8080';
    }
  }
  
  static String get apiUrl => baseUrl;
  
  // API Endpoints
  static String get tracksEndpoint => '$apiUrl/tracks';
  static String get searchEndpoint => '$apiUrl/search';
  static String get loginEndpoint => '$apiUrl/auth/login';
  static String get registerEndpoint => '$apiUrl/auth/register';
  static String get googleSignInEndpoint => '$apiUrl/auth/google';
  static String get forgotPasswordEndpoint => '$apiUrl/auth/forgot-password';
  static String get statsEndpoint => '$apiUrl/stats/top-tracks';
  static String get searchAdvancedEndpoint => '$apiUrl/search-advanced';
  static String get exportCsvEndpoint => '$apiUrl/stats/export-csv';
  static String get adminUsersEndpoint => '$apiUrl/admin/users';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String userEmailKey = 'user_email';
  static const String userDisplayNameKey = 'user_display_name';
  
  // Database
  static const String databaseName = 'spotifydemo.db';
  static const int databaseVersion = 1;
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Audio
  static const double defaultVolume = 1.0;
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
}
