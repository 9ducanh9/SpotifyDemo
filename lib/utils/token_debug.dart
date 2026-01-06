import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

/// Utility debug để kiểm tra token và thông tin user
class TokenDebug {
  /// Kiểm tra token và thông tin user đã lưu
  static Future<Map<String, dynamic>> checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    
    final token = prefs.getString(AppConstants.tokenKey);
    final email = prefs.getString(AppConstants.userEmailKey);
    final role = prefs.getString(AppConstants.userRoleKey);
    final displayName = prefs.getString(AppConstants.userDisplayNameKey);
    final userId = prefs.getString(AppConstants.userIdKey);
    
    return {
      'hasToken': token != null && token.isNotEmpty,
      'tokenLength': token?.length ?? 0,
      'tokenPreview': token != null && token.length > 20 
          ? '${token.substring(0, 20)}...' 
          : token ?? 'null',
      'email': email ?? 'null',
      'role': role ?? 'null',
      'displayName': displayName ?? 'null',
      'userId': userId ?? 'null',
      'isAdmin': role == 'Admin',
    };
  }
  
  /// In thông tin token và user ra console (debug)
  static Future<void> printTokenInfo() async {
    final info = await checkToken();
    print('=== TOKEN DEBUG INFO ===');
    print('Has Token: ${info['hasToken']}');
    print('Token Length: ${info['tokenLength']}');
    print('Token Preview: ${info['tokenPreview']}');
    print('Email: ${info['email']}');
    print('Role: ${info['role']}');
    print('Display Name: ${info['displayName']}');
    print('User ID: ${info['userId']}');
    print('Is Admin: ${info['isAdmin']}');
    print('=======================');
  }
}



