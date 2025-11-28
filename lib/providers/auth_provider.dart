import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth;
  User? user;
  AuthProvider(this._auth) {
    _auth.authState.listen((u) {
      user = u;
      debugPrint('AuthProvider: authState changed -> user id: ${u?.uid}');
      notifyListeners();
    }, onError: (e, st) {
      debugPrint('AuthProvider: authState listen ERROR: $e\n$st');
    });
  }
  Future<void> signIn(String email, String password) async {
    debugPrint('AuthProvider.signIn -> email: $email');
    try {
      await _auth.signIn(email, password);
      debugPrint('AuthProvider.signIn -> success for $email');
    } catch (e, st) {
      debugPrint('AuthProvider.signIn ERROR: $e\n$st');
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    debugPrint('AuthProvider.register -> email: $email');
    try {
      await _auth.register(email, password);
      debugPrint('AuthProvider.register -> success for $email');
    } catch (e, st) {
      debugPrint('AuthProvider.register ERROR: $e\n$st');
      rethrow;
    }
  }

  Future<void> sendPasswordReset(String email) async {
    debugPrint('AuthProvider.sendPasswordReset -> email: $email');
    try {
      await _auth.sendPasswordReset(email);
      debugPrint('AuthProvider.sendPasswordReset -> sent for $email');
    } catch (e, st) {
      debugPrint('AuthProvider.sendPasswordReset ERROR: $e\n$st');
      rethrow;
    }
  }

  Future<void> signOut() async {
    debugPrint('AuthProvider.signOut -> starting');
    try {
      await _auth.signOut();
      debugPrint('AuthProvider.signOut -> success');
    } catch (e, st) {
      debugPrint('AuthProvider.signOut ERROR: $e\n$st');
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    debugPrint('AuthProvider.deleteAccount -> starting');
    try {
      await _auth.deleteAccount();
      debugPrint('AuthProvider.deleteAccount -> success');
    } catch (e, st) {
      debugPrint('AuthProvider.deleteAccount ERROR: $e\n$st');
      rethrow;
    }
  }
}
