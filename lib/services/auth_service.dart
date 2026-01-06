import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../utils/constants.dart';

/// Service xử lý xác thực người dùng (đăng nhập, đăng ký, Google Sign-In)
class AuthService {
  /// Đăng nhập với email và mật khẩu
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Thêm timeout để tránh đợi quá lâu
      final response = await http.post(
        Uri.parse(AppConstants.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - Backend không phản hồi');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;

        // Lưu token và thông tin user vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        await prefs.setString(
            AppConstants.userEmailKey, userData['email'] ?? email);
        await prefs.setString(
            AppConstants.userDisplayNameKey, userData['name'] ?? '');
        await prefs.setString(
            AppConstants.userRoleKey, userData['role'] ?? 'User');
        return {
          'success': true,
          'token': token,
          'user': {
            'email': userData['email'] ?? email,
            'displayName': userData['name'] ?? '',
            'role': userData['role'] ?? 'User',
          },
        };
      }

      // Parse thông báo lỗi từ response nếu có
      try {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Login failed (${response.statusCode})',
        };
      } catch (_) {
        return {
          'success': false,
          'error': 'Login failed (${response.statusCode})',
        };
      }
    } catch (e) {
      String errorMessage = e.toString();
      final baseUrl = AppConstants.baseUrl;
      
      if (errorMessage.contains('timeout')) {
        errorMessage = 'Kết nối timeout. Vui lòng kiểm tra backend server tại $baseUrl';
      } else if (errorMessage.contains('SocketException') || errorMessage.contains('Failed host lookup')) {
        errorMessage = 'Không thể kết nối đến server tại $baseUrl.\n\n'
            '💡 Kiểm tra:\n'
            '1. Backend server đang chạy? (Chạy: start_backend.bat)\n'
            '2. URL đúng với platform? ($baseUrl)\n'
            '3. Firewall/Antivirus có chặn không?';
      } else if (errorMessage.contains('Connection refused')) {
        errorMessage = 'Backend server chưa chạy tại $baseUrl.\n\n'
            '💡 Chạy backend: start_backend.bat';
      }
      return {'success': false, 'error': errorMessage};
    }
  }

  /// Đăng nhập bằng Google (sử dụng google_sign_in package)
  Future<Map<String, dynamic>> signInWithGoogle() async {
    // #region agent log
    final logFile = File(r'c:\SpotifyDemo\.cursor\debug.log');
    logFile.writeAsStringSync('', mode: FileMode.write);
    logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"A","location":"auth_service.dart:91","message":"signInWithGoogle started","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
    // #endregion
    
    try {
      // GoogleSignIn là singleton trong version 7.2.0 - dùng instance
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      
      // #region agent log
      logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"B","location":"auth_service.dart:99","message":"Got GoogleSignIn.instance","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      // #endregion
      
      // Khởi tạo GoogleSignIn với clientId phù hợp theo platform
      // initialize() không nhận scopes parameter trong version 7.2.0
      if (kIsWeb) {
        // #region agent log
        logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"C","location":"auth_service.dart:107","message":"Initializing for Web","data":{"platform":"web"},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        // #endregion
        
        await googleSignIn.initialize(
          clientId: '1037806169280-1ci6j5apvprguqshkhglt07r02kiorov.apps.googleusercontent.com',
        );
      } else {
        // #region agent log
        logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"C","location":"auth_service.dart:115","message":"Initializing for Mobile","data":{"platform":"mobile"},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        // #endregion
        
        await googleSignIn.initialize(
          serverClientId: '1037806169280-oecsdc511ggv3b5ukj50tobvts78rjpf.apps.googleusercontent.com',
          clientId: '1037806169280-1ci6j5apvprguqshkhglt07r02kiorov.apps.googleusercontent.com',
        );
      }
      
      // #region agent log
      logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"D","location":"auth_service.dart:118","message":"Initialize completed","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      // #endregion

      debugPrint('🔍 Bắt đầu đăng nhập Google...');
      
      // Trong google_sign_in 7.2.0, sau khi initialize(), dùng dynamic invocation để gọi signIn()
      // vì method có thể không được expose trực tiếp trong type definition
      // #region agent log
      logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"E","location":"auth_service.dart:133","message":"Calling signIn via dynamic","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      // #endregion
      
      GoogleSignInAccount? account;
      
      try {
        // Dùng dynamic invocation để gọi signIn() method
        // Method này tồn tại trong runtime nhưng có thể không được expose trong type
        account = await (googleSignIn as dynamic).signIn() as GoogleSignInAccount?;
        
        // #region agent log
        logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"E","location":"auth_service.dart:140","message":"signIn result","data":{"accountEmail":account?.email ?? "null","accountIsNull":account == null},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        // #endregion
        
        debugPrint('🔍 signIn() result: ${account?.email ?? "null"}');
      } catch (e) {
        // #region agent log
        logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"E_ERROR","location":"auth_service.dart:145","message":"signIn failed","data":{"error":e.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        // #endregion
        
        debugPrint('❌ signIn() error: $e');
        return {
          'success': false,
          'error': 'Lỗi khi đăng nhập Google: $e\n\nVui lòng kiểm tra lại cấu hình.',
        };
      }

      // Kiểm tra xem user có hủy đăng nhập không
      if (account == null) {
        // #region agent log
        logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"G","location":"auth_service.dart:142","message":"Account is null - user cancelled","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        // #endregion
        
        debugPrint('⚠️ Account is null - user đã hủy đăng nhập');
        return {
          'success': false,
          'error': 'Đăng nhập Google đã bị hủy.',
        };
      }
      
      debugPrint('✅ Account selected: ${account.email}');
      
      // #region agent log
      logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"H","location":"auth_service.dart:152","message":"Account selected successfully","data":{"email":account.email,"displayName":account.displayName ?? "null"},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      // #endregion

      // Kiểm tra email có tồn tại không
      if (account.email.isEmpty) {
        // #region agent log
        logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"I","location":"auth_service.dart:156","message":"Email is empty","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        // #endregion
        
        return {
          'success': false,
          'error': 'Không thể lấy email từ tài khoản Google.',
        };
      }

      // Lấy thông tin xác thực từ Google - authentication là getter, có thể là Future hoặc không
      // #region agent log
      logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"J","location":"auth_service.dart:179","message":"Getting authentication","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      // #endregion
      
      // authentication là getter trả về Future<GoogleSignInAuthentication>
      final GoogleSignInAuthentication auth = await account.authentication;
      
      // #region agent log
      logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"J","location":"auth_service.dart:197","message":"Got authentication","data":{"hasIdToken":auth.idToken != null},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      // #endregion

      // Gửi thông tin đến backend
      // #region agent log
      logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"K","location":"auth_service.dart:201","message":"Sending request to backend","data":{"endpoint":AppConstants.googleSignInEndpoint,"email":account.email},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      // #endregion
      
      final response = await http.post(
        Uri.parse(AppConstants.googleSignInEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': account.email,
          'display_name': account.displayName ?? '',
          'avatar_url': account.photoUrl,
          'id_token': auth.idToken,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // #region agent log
          logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"L","location":"auth_service.dart:216","message":"Request timeout","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
          // #endregion
          throw Exception('Request timeout - Backend không phản hồi');
        },
      );
      
      // #region agent log
      logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"K","location":"auth_service.dart:220","message":"Backend response received","data":{"statusCode":response.statusCode,"bodyLength":response.body.length},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      // #endregion

      if (response.statusCode == 200) {
        // #region agent log
        logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"M","location":"auth_service.dart:233","message":"Response status 200","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        // #endregion
        
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['token'] as String?;
        final userData = data['user'] as Map<String, dynamic>?;
        
        // #region agent log
        logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"M","location":"auth_service.dart:238","message":"Parsed response data","data":{"hasToken":token != null && token.isNotEmpty,"hasUserData":userData != null},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        // #endregion
        
        if (token == null || token.isEmpty) {
          // #region agent log
          logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"N","location":"auth_service.dart:242","message":"Token is null or empty","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
          // #endregion
          return {
            'success': false,
            'error': 'Backend không trả về token',
          };
        }
        
        if (userData == null) {
          // #region agent log
          logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"O","location":"auth_service.dart:250","message":"UserData is null","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
          // #endregion
          return {
            'success': false,
            'error': 'Backend không trả về thông tin user',
          };
        }

        // Lưu token và user data vào SharedPreferences
        // #region agent log
        logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"P","location":"auth_service.dart:259","message":"Saving to SharedPreferences","data":{"email":userData['email'] ?? account.email},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        // #endregion
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        await prefs.setString(
            AppConstants.userEmailKey, userData['email'] ?? account.email);
        await prefs.setString(
            AppConstants.userDisplayNameKey,
            userData['name'] ?? account.displayName ?? '');
        await prefs.setString(
            AppConstants.userRoleKey, userData['role'] ?? 'User');

        // #region agent log
        logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"P","location":"auth_service.dart:272","message":"Successfully saved, returning success","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        // #endregion

        return {
          'success': true,
          'token': token,
        };
      }

      // Xử lý lỗi từ backend
      // #region agent log
      logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"Q","location":"auth_service.dart:282","message":"Response status not 200","data":{"statusCode":response.statusCode},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      // #endregion
      
      try {
        final errorData = jsonDecode(response.body);
        // #region agent log
        logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"Q","location":"auth_service.dart:286","message":"Parsed error from backend","data":{"error":errorData['error']},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        // #endregion
        return {
          'success': false,
          'error': errorData['error'] ?? 'Google login failed',
        };
      } catch (_) {
        // #region agent log
        logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"Q","location":"auth_service.dart:293","message":"Failed to parse error response","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
        // #endregion
        return {
          'success': false,
          'error': 'Google login failed (${response.statusCode})',
        };
      }
    } catch (e) {
      // #region agent log
      logFile.writeAsStringSync('${jsonEncode({"sessionId":"debug-session","runId":"run1","hypothesisId":"R","location":"auth_service.dart:314","message":"Exception caught","data":{"error":e.toString(),"errorType":e.runtimeType.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch})}\n', mode: FileMode.append);
      // #endregion
      // Xử lý lỗi chung
      String errorMessage = e.toString();
      
      // Kiểm tra các loại lỗi phổ biến
      if (errorMessage.contains('clientConfigurationError') || 
          errorMessage.contains('serverClientId must be provided')) {
        errorMessage = 'Google Sign-In chưa được cấu hình trên Android.\n\n'
            '💡 Tính năng này cần cấu hình Google OAuth Client.\n'
            '   Hiện tại bạn có thể dùng đăng nhập thông thường.';
      } else if (errorMessage.contains('PlatformException')) {
        errorMessage = 'Google Sign-In chưa được cấu hình đúng. Vui lòng kiểm tra cấu hình.';
      } else if (errorMessage.contains('sign_in_failed')) {
        errorMessage = 'Đăng nhập Google thất bại. Vui lòng thử lại.';
      } else if (errorMessage.contains('canceled') || errorMessage.contains('Cancelled')) {
        errorMessage = 'Đăng nhập Google đã bị hủy.';
      } else {
        errorMessage = 'Google Sign-In error: $errorMessage';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    }
  }

  /// Đăng ký tài khoản mới
  Future<Map<String, dynamic>> register(
      String emailOrUsername, String password, String displayName) async {
    try {
      // Thêm timeout để tránh đợi quá lâu
      final response = await http.post(
        Uri.parse(AppConstants.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailOrUsername,
          'password': password,
          'display_name': displayName,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - Backend không phản hồi');
        },
      );

      if (response.statusCode == 200) {
        // Tự động đăng nhập sau khi đăng ký thành công
        return await login(emailOrUsername, password);
      }

      try {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Đăng ký thất bại',
        };
      } catch (_) {
        return {
          'success': false,
          'error': 'Đăng ký thất bại (${response.statusCode})',
        };
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('timeout')) {
        errorMessage = 'Kết nối timeout. Vui lòng kiểm tra backend server.';
      } else if (errorMessage.contains('SocketException') || errorMessage.contains('Failed host lookup')) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng và URL.';
      }
      return {
        'success': false,
        'error': 'Lỗi kết nối: $errorMessage',
      };
    }
  }

  /// Đăng xuất khỏi hệ thống
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Xóa tất cả dữ liệu đã lưu trong SharedPreferences
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userRoleKey);
    await prefs.remove(AppConstants.userEmailKey);
    await prefs.remove(AppConstants.userDisplayNameKey);

    // Đăng xuất khỏi Google session nếu có
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut();
    } catch (_) {
      // Bỏ qua lỗi nếu không có Google session
    }
  }

  /// Kiểm tra trạng thái đăng nhập
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Lấy vai trò người dùng đã lưu
  Future<UserRole?> getStoredRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString(AppConstants.userRoleKey);
    if (roleString != null) {
      return UserRole.fromString(roleString);
    }
    return null;
  }

  /// Lấy token xác thực đã lưu
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  /// Gửi yêu cầu quên mật khẩu
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - Backend không phản hồi');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Mã khôi phục đã được gửi',
        };
      }

      try {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Không thể gửi email khôi phục',
        };
      } catch (_) {
        return {
          'success': false,
          'error': 'Không thể gửi email khôi phục (${response.statusCode})',
        };
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('timeout')) {
        errorMessage = 'Kết nối timeout. Vui lòng kiểm tra backend server.';
      } else if (errorMessage.contains('SocketException') || errorMessage.contains('Failed host lookup')) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng và URL.';
      }
      return {
        'success': false,
        'error': 'Lỗi kết nối: $errorMessage',
      };
    }
  }

  /// Đặt lại mật khẩu với mã xác nhận
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String resetCode,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'reset_code': resetCode,
          'new_password': newPassword,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - Backend không phản hồi');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Đặt lại mật khẩu thành công',
        };
      }

      try {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Không thể đặt lại mật khẩu',
        };
      } catch (_) {
        return {
          'success': false,
          'error': 'Không thể đặt lại mật khẩu (${response.statusCode})',
        };
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('timeout')) {
        errorMessage = 'Kết nối timeout. Vui lòng kiểm tra backend server.';
      } else if (errorMessage.contains('SocketException') || errorMessage.contains('Failed host lookup')) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng và URL.';
      }
      return {
        'success': false,
        'error': 'Lỗi kết nối: $errorMessage',
      };
    }
  }
}
