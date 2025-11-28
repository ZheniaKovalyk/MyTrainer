import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/local_photo_service.dart';
import '../../widgets/avatar_picker_local.dart';
import '../auth/login_screen.dart';
import 'account_delete_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  DateTime? _birthDate;
  String? _photoPath;
  File? _pickedPhoto;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthProvider>();
    final fs = context.read<FirestoreService>();
    final uid = auth.user?.uid;
    if (uid == null) return;
    final doc = await fs.getTrainer(uid);
    final data = doc.data();
    if (data != null) {
      setState(() {
        _name.text = (data['name'] ?? '');
        _email.text = (auth.user?.email ?? '');
        _photoPath = data['photo'];
        final bd = data['birthDate'];
        if (bd != null) _birthDate = DateTime.parse(bd);
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
        context: context,
        initialDate: _birthDate ?? DateTime(now.year - 20),
        firstDate: DateTime(1940),
        lastDate: now);
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fs = context.read<FirestoreService>();
    final local = context.read<LocalPhotoService>();
    final uid = auth.user?.uid ?? '';
    return Scaffold(
        appBar: AppBar(
            title: const Text('Налаштування'),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context))),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(children: [
              Center(
                  child: AvatarPickerLocal(
                      size: 120,
                      initialPath: _photoPath,
                      onChanged: (f) => _pickedPhoto = f)),
              const SizedBox(height: 16),
              TextField(
                  controller: _name,
                  decoration: const InputDecoration(hintText: 'Ім’я')),
              const SizedBox(height: 8),
              TextField(
                  controller: _email,
                  readOnly: true,
                  decoration: const InputDecoration(
                      hintText: 'Email (тільки перегляд)')),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(_birthDate == null
                      ? 'Дата народження'
                      : _birthDate!.toIso8601String().substring(0, 10)),
                  onPressed: _pickDate),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(_saving ? 'Зберігаємо...' : 'Зберегти'),
                  onPressed: _saving
                      ? null
                      : () async {
                          setState(() => _saving = true);
                          try {
                            String? path = _photoPath;
                            if (_pickedPhoto != null) {
                                path = await local.savePhoto(
                                  _pickedPhoto!, 'trainer_$uid.jpg');
                            }
                            await fs.setTrainer(uid, {
                              'name': _name.text.trim(),
                              'birthDate': _birthDate?.toIso8601String(),
                              'photo': path
                            });
                            if (!mounted) return;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(content: Text('Збережено')));
                            });
                          } catch (e) {
                            if (mounted) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(e.toString())));
                              });
                            }
                          } finally {
                            setState(() => _saving = false);
                          }
                        }),
              const Divider(height: 32),
              ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Вийти з акаунту'),
                  onPressed: () async {
                    await auth.signOut();
                    if (!mounted) return;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (_) => false);
                    });
                  }),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text('Видалити акаунт'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AccountDeleteScreen()));
                  }),
            ])));
  }
}
