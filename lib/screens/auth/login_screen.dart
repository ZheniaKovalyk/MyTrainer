import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_background.dart';
import '../../widgets/input_field.dart';
import '../../widgets/primary_button.dart';
import 'register_screen.dart';
import '../home/clients_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        imageAsset: 'assets/bg_main.jpg',
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.92),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 16,
                  )
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', width: 72),
                    const SizedBox(height: 8),
                    Text('Вхід', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    InputField(
                      controller: _email,
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Введіть email' : null,
                    ),
                    const SizedBox(height: 12),
                    InputField(
                      controller: _password,
                      hint: 'Пароль',
                      obscure: true,
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Мін. 6 символів'
                          : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.red))
                    ],
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PrimaryButton(
                          text: _loading ? '...' : 'Ввійти',
                          icon: Icons.login,
                          onPressed: _loading
                              ? () {}
                              : () async {
                                  if (!_formKey.currentState!.validate()) {
                                    return;
                                  }
                                  setState(() {
                                    _loading = true;
                                    _error = null;
                                  });
                                  try {
                                    await context.read<AuthProvider>().signIn(
                                          _email.text.trim(),
                                          _password.text.trim(),
                                        );
                                    if (!mounted) return;
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const ClientsScreen(),
                                        ),
                                      );
                                    });
                                  } catch (e) {
                                    setState(() => _error = e.toString());
                                  } finally {
                                    setState(() => _loading = false);
                                  }
                                },
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: _loading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                          child: const Text('Реєстрація'),
                        ),
                        const SizedBox(width: 12),
                        // forgot-password removed per request
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
