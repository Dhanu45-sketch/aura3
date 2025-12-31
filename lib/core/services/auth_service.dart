import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

// REFINED SEALED CLASS: Added ActionSuccess for non-credential tasks
sealed class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  final User user;
  final UserCredential credential;
  const AuthSuccess(this.user, this.credential);
}

/// Use this for successful actions that don't return a new user (like password reset)
class ActionSuccess extends AuthResult {
  const ActionSuccess();
}

class AuthFailure extends AuthResult {
  final String message;
  const AuthFailure(this.message);
}

class AuthCanceled extends AuthResult {
  const AuthCanceled();
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // CORRECTED: The modern API uses the constructor directly.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- SIGN IN / SIGN UP (MODERNIZED) ---

  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return const AuthCanceled();

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) return AuthSuccess(userCredential.user!, userCredential);

      return const AuthFailure("Firebase user creation failed.");
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_handleAuthException(e));
    } catch (e) {
      return AuthFailure('Google Auth Error: ${e.toString()}');
    }
  }

  Future<AuthResult> signInWithEmail({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return AuthSuccess(credential.user!, credential);
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_handleAuthException(e));
    }
  }

  Future<AuthResult> signUpWithEmail({required String email, required String password, required String displayName}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();
      return AuthSuccess(_auth.currentUser!, credential);
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_handleAuthException(e));
    }
  }

  // --- RESTORED & UPDATED AUXILIARY METHODS ---

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const ActionSuccess();
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_handleAuthException(e));
    }
  }

  Future<AuthResult> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (displayName != null) await currentUser?.updateDisplayName(displayName);
      if (photoURL != null) await currentUser?.updatePhotoURL(photoURL);
      await currentUser?.reload();
      return const ActionSuccess();
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_handleAuthException(e));
    }
  }

  Future<AuthResult> deleteAccount() async {
    try {
      await currentUser?.delete();
      return const ActionSuccess();
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_handleAuthException(e));
    }
  }

  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  String _handleAuthException(FirebaseAuthException e) {
    return switch (e.code) {
      'weak-password' => 'The password is too weak.',
      'email-already-in-use' => 'An account already exists.',
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect password.',
      'requires-recent-login' => 'Please log in again to perform this sensitive action.',
      _ => e.message ?? 'An unknown error occurred.',
    };
  }
}
