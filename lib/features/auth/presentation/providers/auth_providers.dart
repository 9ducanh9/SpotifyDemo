import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../data/models/user_model.dart';

/// Connectivity service provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseService.authStateChanges;
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});

/// User document provider
final userDocumentProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  try {
    final doc = await FirebaseService.getUserDocument(user.uid);
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return UserModel(
        id: user.uid,
        email: data['email'] as String? ?? user.email ?? '',
        role: data['role'] as String? ?? 'regular',
      );
    }
  } catch (e) {
    // Handle error
  }
  return null;
});

/// Auth actions provider
final authActionsProvider = Provider<AuthActions>((ref) {
  return AuthActions(ref);
});

/// Class to handle authentication actions
class AuthActions {
  final Ref _ref;

  AuthActions(this._ref);

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await FirebaseService.signInWithEmail(
      email: email,
      password: password,
    );
  }

  /// Register with email and password
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return await FirebaseService.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    return await FirebaseService.signInWithGoogle();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseService.sendPasswordResetEmail(email);
  }

  /// Sign out
  Future<void> signOut() async {
    await FirebaseService.signOut();
    _ref.invalidate(authStateProvider);
    _ref.invalidate(userDocumentProvider);
  }

  /// Check if user is admin
  bool isAdmin() {
    final userDoc = _ref.read(userDocumentProvider);
    return userDoc.value?.isAdmin ?? false;
  }
}
