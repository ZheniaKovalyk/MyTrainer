import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
    Future.delayed(const Duration(milliseconds: 800), _goNext);
  }

  void _goNext() {
    final auth = context.read<AuthProvider>();
    final u = auth.user;
    if (u == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const ClientsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
      Image.asset('assets/logo.png', width: 120, height: 120),
      const SizedBox(height: 12),
      Text('MyTrainer', style: Theme.of(context).textTheme.headlineMedium)
    ])));
  }
}
