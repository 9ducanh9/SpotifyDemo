import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = NotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<User?> {
  @override
  User? build() {
    ref.read(authServiceProvider);
    // Load stored auth asynchronously after build
    Future.microtask(() => _loadStoredAuth());
    return null;
  }

  AuthService get _authService => ref.read(authServiceProvider);

  Future<void> _loadStoredAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      // Load user from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final storedEmail = prefs.getString(AppConstants.userEmailKey);
      final storedName = prefs.getString(AppConstants.userDisplayNameKey);
      final roleString = prefs.getString(AppConstants.userRoleKey);
      
      if (storedEmail != null && storedEmail.isNotEmpty) {
        state = User(
          email: storedEmail,
          displayName: storedName ?? '',
          role: UserRole.fromString(roleString ?? 'User'),
        );
      }
    }
  }

  String? _lastError;

  String? get lastError => _lastError;

  /// Đăng nhập với email và mật khẩu
  Future<bool> login(String email, String password) async {
    _lastError = null;
    final result = await _authService.login(email, password);
    if (result['success'] == true) {
      // Lấy user data từ result hoặc từ SharedPreferences
      final userData = result['user'] as Map<String, dynamic>?;
      if (userData != null) {
        state = User(
          email: userData['email'] as String? ?? email,
          displayName: userData['displayName'] as String? ?? '',
          role: UserRole.fromString(userData['role'] as String? ?? 'User'),
        );
      } else {
        // Fallback: Load từ SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final storedEmail = prefs.getString(AppConstants.userEmailKey) ?? email;
        final storedName = prefs.getString(AppConstants.userDisplayNameKey) ?? '';
        final roleString = prefs.getString(AppConstants.userRoleKey) ?? 'User';
        state = User(
          email: storedEmail,
          displayName: storedName,
          role: UserRole.fromString(roleString),
        );
      }
      return true;
    }
    _lastError = result['error'] as String?;
    return false;
  }

  /// Đăng ký tài khoản mới
  Future<bool> register(String emailOrUsername, String password, String displayName) async {
    _lastError = null;
    final result = await _authService.register(emailOrUsername, password, displayName);
    if (result['success'] == true) {
      // Load user data từ SharedPreferences (được lưu bởi auth_service sau khi login tự động)
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(AppConstants.userEmailKey) ?? emailOrUsername;
      final storedName = prefs.getString(AppConstants.userDisplayNameKey) ?? displayName;
      final roleString = prefs.getString(AppConstants.userRoleKey) ?? 'User';
      
      state = User(
        email: email,
        displayName: storedName,
        role: UserRole.fromString(roleString),
      );
      return true;
    }
    _lastError = result['error'] as String?;
    return false;
  }

  /// Đăng nhập bằng Google
  Future<bool> signInWithGoogle() async {
    _lastError = null;
    final result = await _authService.signInWithGoogle();
    if (result['success'] == true) {
      // Load user from SharedPreferences (saved by auth_service)
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(AppConstants.userEmailKey) ?? '';
      final displayName = prefs.getString(AppConstants.userDisplayNameKey) ?? '';
      final roleString = prefs.getString(AppConstants.userRoleKey) ?? 'User';
      final role = UserRole.fromString(roleString);
      
      state = User(
        email: email,
        displayName: displayName,
        role: role,
      );
      return true;
    }
    _lastError = result['error'] as String?;
    return false;
  }

  /// Đăng xuất khỏi hệ thống
  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }
}

