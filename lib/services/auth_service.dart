import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class AuthService {
  final _auth = FirebaseAuth.instance;
  /// Initialize AuthService. On web set persistence to LOCAL so the user
  /// stays signed in across reloads and restarts.
  Future<void> init() async {
    if (kIsWeb) {
      try {
        await _auth.setPersistence(Persistence.LOCAL);
        debugPrint('AuthService.init -> setPersistence(Persistence.LOCAL) OK');
      } catch (e, st) {
        // If setting persistence fails, log the error for diagnosis.
        debugPrint('AuthService.init -> setPersistence FAILED: $e\n$st');
      }
    }
  }
  Stream<User?> get authState => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  Future<UserCredential> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return cred;
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}
