import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login_screen.dart';
import 'home/clients_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for the first authStateChanges event (or timeout) then navigate.
    _decide();
  }

  void _navigate(User? firebaseUser) {
    debugPrint('SplashScreen: navigate -> user ${firebaseUser?.uid}');
    if (!mounted) return;
    if (firebaseUser == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ClientsScreen()));
    }
  }

  Future<void> _decide() async {
    try {
      final firebaseUser = await FirebaseAuth.instance
          .authStateChanges()
          .first
          .timeout(const Duration(seconds: 10));
      debugPrint('SplashScreen: authStateChanges.first -> ${firebaseUser?.uid}');
      _navigate(firebaseUser);
    } catch (e) {
      // Timeout or error - fallback to currentUser
      final current = FirebaseAuth.instance.currentUser;
      debugPrint('SplashScreen: authStateChanges timeout/error -> $e, currentUser=${current?.uid}');
      _navigate(current);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
      Image.asset('assets/logo.png', width: 200, height: 200),
      const SizedBox(height: 12),
      Text('MyTrainer', style: Theme.of(context).textTheme.headlineMedium)
    ])));
  }
}
