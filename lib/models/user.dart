/// Enum định nghĩa các vai trò người dùng trong hệ thống
enum UserRole {
  user('User'),
  admin('Admin'),
  creator('Creator'),
  approver('Approver'),
  follower('Follower');

  final String value;
  const UserRole(this.value);
  
  /// Chuyển đổi chuỗi thành UserRole enum
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.user,
    );
  }
}

/// Model đại diện cho người dùng trong hệ thống
class User {
  final int? id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  User({
    this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.avatarUrl,
    this.createdAt,
    this.lastLoginAt,
  });

  /// Chuyển đổi từ Map (từ database hoặc API) sang User object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      displayName: map['display_name'] as String? ?? map['displayName'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String? ?? 'User'),
      avatarUrl: map['avatar_url'] as String? ?? map['avatarUrl'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : map['createdAt'] != null
              ? DateTime.parse(map['createdAt'] as String)
              : null,
      lastLoginAt: map['last_login_at'] != null
          ? DateTime.parse(map['last_login_at'] as String)
          : map['lastLoginAt'] != null
              ? DateTime.parse(map['lastLoginAt'] as String)
              : null,
    );
  }

  /// Chuyển đổi User object sang Map để lưu vào database hoặc gửi API
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'display_name': displayName,
      'role': role.value,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (lastLoginAt != null) 'last_login_at': lastLoginAt!.toIso8601String(),
    };
  }

  /// Kiểm tra người dùng có phải Admin không
  bool get isAdmin => role == UserRole.admin;
  
  /// Kiểm tra người dùng có phải Creator không
  bool get isCreator => role == UserRole.creator;
  
  /// Kiểm tra người dùng có quyền chỉnh sửa không
  bool get canEdit => isAdmin || isCreator;
  
  /// Kiểm tra người dùng có quyền xóa không
  bool get canDelete => isAdmin;
}

