import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../auth/login_screen.dart';

class AccountDeleteScreen extends StatefulWidget {
  const AccountDeleteScreen({super.key});
  @override
  State<AccountDeleteScreen> createState() => _AccountDeleteScreenState();
}

class _AccountDeleteScreenState extends State<AccountDeleteScreen> {
  bool _processing = false;
  String? _error;
  Future<void> _deleteTrainerAndClients(String uid) async {
    final fs = context.read<FirestoreService>();
    final trainerDoc = await fs.getTrainer(uid);
    final trainerData = trainerDoc.data();
    if (trainerData != null && trainerData['photo'] != null) {
      final path = trainerData['photo'] as String;
      final file = File(path);
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (e) {
          debugPrint('Помилка видалення фото тренера: $e');
        }
      }
    }
    final clientsSnap = await fs.clientsCol(uid).get();
    for (final doc in clientsSnap.docs) {
      final data = doc.data();
      if (data['photo'] != null) {
        final path = data['photo'] as String;
        final file = File(path);
        if (file.existsSync()) {
          try {
            file.deleteSync();
          } catch (e) {
            debugPrint('Помилка видалення фото клієнта: $e');
          }
        }
      }
    }
    for (final doc in clientsSnap.docs) {
      await doc.reference.delete();
    }
    await fs.trainerDoc(uid).delete();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final uid = auth.user?.uid ?? '';
    return Scaffold(
        appBar: AppBar(title: const Text('Видалення облікового запису')),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Text(
                  'Це безповоротна дія. Будуть видалені ваші дані та фото.'),
              const SizedBox(height: 12),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const Spacer(),
              ElevatedButton.icon(
                  icon: const Icon(Icons.delete_forever),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  label: Text(
                      _processing ? 'Видаляємо...' : 'Підтвердити видалення'),
                  onPressed: _processing
                      ? null
                      : () async {
                          setState(() => _processing = true);
                          try {
                            await _deleteTrainerAndClients(uid);
                            await auth.deleteAccount();
                            if (!mounted) return;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                                (_) => false);
                            });
                          } catch (e) {
                            setState(() => _error = e.toString());
                          } finally {
                            setState(() => _processing = false);
                          }
                        }),
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Назад'))
            ])));
  }
}
