import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_background.dart';
import '../../widgets/input_field.dart';
import 'profile_setup_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
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
                color: const Color.fromRGBO(255, 255, 255, 0.95),
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
                    const Icon(Icons.fitness_center,
                        size: 48, color: Color(0xFF2E7D32)),
                    const SizedBox(height: 8),
                    Text('Реєстрація',
                        style: Theme.of(context).textTheme.titleLarge),
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
                    const SizedBox(height: 12),
                    InputField(
                      controller: _confirm,
                      hint: 'Підтвердити пароль',
                      obscure: true,
                      validator: (v) => (v != _password.text)
                          ? 'Паролі не співпадають'
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
                        OutlinedButton(
                          onPressed:
                              _loading ? null : () => Navigator.pop(context),
                          child: const Text('Назад'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: Text(_loading ? '...' : 'Зареєструватися'),
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
                                    await context.read<AuthProvider>().register(
                                          _email.text.trim(),
                                          _password.text.trim(),
                                        );
                                    if (!mounted) return;
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ProfileSetupScreen(),
                                        ),
                                      );
                                    });
                                  } catch (e) {
                                    setState(() => _error = e.toString());
                                  } finally {
                                    setState(() => _loading = false);
                                  }
                                },
                        )
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
