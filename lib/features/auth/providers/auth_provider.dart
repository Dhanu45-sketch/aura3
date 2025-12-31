import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Listen to auth state changes to keep the local user in sync
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // --- REFACTORED FOR 2025 STANDARDS (All methods return AuthResult) ---

  /// Sign up with email and password
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (result is AuthFailure) {
        _setError(result.message);
      }

      _setLoading(false);
      return result;
    } catch (e) {
      final failure = AuthFailure(e.toString());
      _setError(failure.message);
      _setLoading(false);
      return failure;
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (result is AuthFailure) {
        _setError(result.message);
      }

      _setLoading(false);
      return result;
    } catch (e) {
      final failure = AuthFailure(e.toString());
      _setError(failure.message);
      _setLoading(false);
      return failure;
    }
  }

  /// Sign in with Google (using 2025 handoff logic)
  Future<AuthResult> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.signInWithGoogle();

      if (result is AuthFailure) {
        _setError(result.message);
      }

      _setLoading(false);
      return result;
    } catch (e) {
      final failure = AuthFailure(e.toString());
      _setError(failure.message);
      _setLoading(false);
      return failure;
    }
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.sendPasswordResetEmail(email);

      if (result is AuthFailure) {
        _setError(result.message);
      }

      _setLoading(false);
      return result;
    } catch (e) {
      final failure = AuthFailure(e.toString());
      _setError(failure.message);
      _setLoading(false);
      return failure;
    }
  }

  /// Update user profile (name or photo)
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      if (result is AuthFailure) {
        _setError(result.message);
      } else {
        // Sync local user after successful profile update
        _user = _authService.currentUser;
      }

      _setLoading(false);
      return result;
    } catch (e) {
      final failure = AuthFailure(e.toString());
      _setError(failure.message);
      _setLoading(false);
      return failure;
    }
  }

  /// Completely delete the user account
  Future<AuthResult> deleteAccount() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.deleteAccount();

      if (result is AuthFailure) {
        _setError(result.message);
      } else {
        // Clear local user state on successful deletion
        _user = null;
      }

      _setLoading(false);
      return result;
    } catch (e) {
      final failure = AuthFailure(e.toString());
      _setError(failure.message);
      _setLoading(false);
      return failure;
    }
  }

  // --- HELPER & STATE METHODS (Preserved) ---

  /// Sign out from all providers
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      _user = null;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}