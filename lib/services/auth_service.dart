import 'package:firebase_auth/firebase_auth.dart';

/// Single "front desk" for every auth operation. Widgets never call
/// FirebaseAuth directly, so error handling and rules live in one place.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Stable stream: emits the current user on listen, then on every
  /// sign-in / sign-out. Used by AuthGate to route the UI.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Updates the password. If Firebase says the login is too old, throws
  /// [AuthFailure] with [AuthFailure.requiresRecentLogin] = true so the UI
  /// can ask for the current password and call [reauthenticateAndUpdate].
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthFailure('You are signed out. Please sign in again.');
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    }
  }

  /// Reauthenticate with the current password, then retry the update.
  Future<void> reauthenticateAndUpdate({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw const AuthFailure('You are signed out. Please sign in again.');
    }
    try {
      final credential =
          EmailAuthProvider.credential(email: email, password: currentPassword);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromCode(e.code);
    }
  }
}

/// User-safe error. Never shows raw exception text.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.requiresRecentLogin = false});

  final String message;
  final bool requiresRecentLogin;

  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const AuthFailure('That email address doesn\'t look valid.');
      case 'email-already-in-use':
        return const AuthFailure(
            'An account already exists for that email. Try signing in instead.');
      case 'weak-password':
        return const AuthFailure('Password is too weak. Use at least 6 characters.');
      // Grouped on purpose: don't reveal whether the email exists.
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure('Email or password is incorrect.');
      case 'user-disabled':
        return const AuthFailure('This account has been disabled.');
      case 'too-many-requests':
        return const AuthFailure('Too many attempts. Wait a moment and try again.');
      case 'network-request-failed':
        return const AuthFailure('No connection. Check your internet and retry.');
      case 'requires-recent-login':
        return const AuthFailure(
          'For security, confirm your current password to continue.',
          requiresRecentLogin: true,
        );
      case 'operation-not-allowed':
        return const AuthFailure('Email/password sign-in is not enabled for this app.');
      default:
        return const AuthFailure('Something went wrong. Please try again.');
    }
  }

  @override
  String toString() => message;
}
