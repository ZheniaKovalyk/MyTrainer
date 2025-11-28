import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/local_photo_service.dart';
import '../../widgets/avatar_picker_local.dart';
import '../home/clients_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _name = TextEditingController();
  DateTime? _birthDate;
  File? _photo;
  bool _saving = false;
  String? _error;
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime(now.year - 20),
        firstDate: DateTime(1940),
        lastDate: now);
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fs = context.read<FirestoreService>();
    final local = context.read<LocalPhotoService>();
    return Scaffold(
        appBar: AppBar(title: const Text('Налаштування профілю')),
        body: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      AvatarPickerLocal(
                          size: 120, onChanged: (f) => _photo = f),
                      const SizedBox(height: 16),
                      TextField(
                          controller: _name,
                          decoration:
                              const InputDecoration(hintText: 'Ваше ім’я')),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                          icon: const Icon(Icons.date_range),
                          label: Text(_birthDate == null
                              ? 'Дата народження'
                              : DateFormat('dd.MM.yyyy').format(_birthDate!)),
                          onPressed: _pickDate),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Text(_error!,
                            style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle),
                          label:
                              Text(_saving ? 'Зберігаємо...' : 'Підтвердити'),
                          onPressed: _saving
                              ? null
                              : () async {
                                  final u = auth.user;
                                  if (u == null) return;
                                  if (_name.text.trim().isEmpty ||
                                      _birthDate == null) {
                                    setState(() => _error =
                                        'Заповніть ім’я і дату народження');
                                    return;
                                  }
                                  setState(() => _saving = true);
                                  try {
                                    String? photoPath;
                                    if (_photo != null) {
                                      photoPath = await local.savePhoto(
                                          _photo!, 'trainer_${u.uid}.jpg');
                                    }
                                      await fs.setTrainer(u.uid, {
                                      'email': u.email,
                                      'name': _name.text.trim(),
                                      'birthDate':
                                          _birthDate!.toIso8601String(),
                                      'photo': photoPath
                                    });
                                      if (!mounted) return;
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                              const ClientsScreen()));
                                      });
                                  } catch (e) {
                                    setState(() => _error = e.toString());
                                  } finally {
                                    setState(() => _saving = false);
                                  }
                                })
                    ])))));
  }
}
