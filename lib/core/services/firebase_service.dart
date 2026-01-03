import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase service for authentication and Firestore operations
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // ========== AUTHENTICATION ==========

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Get auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Register with email and password
  static Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name if provided
    if (displayName != null && credential.user != null) {
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();
    }

    // Create user document in Firestore
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'email': email,
      'displayName': displayName ?? '',
      'role': 'regular', // Default role
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  /// Sign in with Google
  static Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled');
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    final userCredential = await _auth.signInWithCredential(credential);

    // Create or update user document in Firestore
    if (userCredential.user != null) {
      final userDoc = _firestore
          .collection('users')
          .doc(userCredential.user!.uid);
      final userData = await userDoc.get();

      if (!userData.exists) {
        await userDoc.set({
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName ?? '',
          'role': 'regular', // Default role
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    return userCredential;
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Sign out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ========== FIRESTORE OPERATIONS ==========

  /// Get user document
  static Future<DocumentSnapshot> getUserDocument(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  /// Update user role (admin only)
  static Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({'role': role});
  }

  /// Sync track to Firestore
  static Future<void> syncTrackToCloud({
    required String trackId,
    required Map<String, dynamic> trackData,
    required String userId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tracks')
        .doc(trackId)
        .set(trackData, SetOptions(merge: true));
  }

  /// Get tracks from Firestore
  static Stream<QuerySnapshot> getTracksFromCloud(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tracks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Delete track from Firestore
  static Future<void> deleteTrackFromCloud(String userId, String trackId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tracks')
        .doc(trackId)
        .delete();
  }

  /// Get all tracks for admin (all users)
  static Stream<QuerySnapshot> getAllTracksForAdmin() {
    return _firestore
        .collectionGroup('tracks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
