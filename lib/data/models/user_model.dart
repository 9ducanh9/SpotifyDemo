/// Data model for a user
class User {
  final int? id;
  final String email;
  final String role; // 'regular' or 'admin'

  User({
    this.id,
    required this.email,
    this.role = 'regular',
  });

  /// Create a copy of this user with updated fields
  User copyWith({
    int? id,
    String? email,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }

  /// Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }

  /// Create from Map (database retrieval)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      role: map['role'] as String? ?? 'regular',
    );
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  @override
  String toString() {
    return 'User(id: $id, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.role == role;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ role.hashCode;
}
