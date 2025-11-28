import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/app_background.dart';
import '../../widgets/search_filter_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/clients_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/local_photo_service.dart';
import '../settings/settings_screen.dart';
import 'client_details_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final trainerId = auth.user?.uid ?? '';
    if (trainerId.isEmpty) {
      return Scaffold(
        body: AppBackground(
          imageUrl:
              'https://images.unsplash.com/photo-1503264116251-35a269479413?auto=format&fit=crop&w=1350&q=80',
          child: const SafeArea(
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => ClientsProvider(context.read<FirestoreService>(), trainerId),
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Додати'),
          onPressed: () async {
            await _showAddClientDialog(context, trainerId);
          },
        ),
        body: AppBackground(
          imageAsset: 'assets/bg_detail.png',
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      Text('Клієнти',
                          style: Theme.of(context).textTheme.titleLarge),
                      const Spacer(),
                      const SizedBox(width: 48)
                    ],
                  ),
                  const SizedBox(height: 8),

                  Consumer<ClientsProvider>(
                    builder: (_, prov, __) => SearchFilterBar(
                      onQueryChanged: prov.setQuery,
                      onFilterTap: () => _showFilter(context),
                      showFilterButton: false,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Expanded(
                    child: Consumer<ClientsProvider>(
                      builder: (_, prov, __) {
                        final list = prov.filtered;
                        if (list.isEmpty) {
                          return const Center(
                            child: Text('Немає клієнтів. Додайте першого!'),
                          );
                        }
                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final d = list[i];
                            final data = d.data();
                            final photoPath = data['photo'] as String?;
                            final lastName = data['lastName'] as String? ?? '';
                            final firstName = data['firstName'] as String? ?? '';
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: (photoPath != null &&
                                          photoPath.isNotEmpty)
                                      ? FileImage(File(photoPath))
                                      : null,
                                  child:
                                      (photoPath == null || photoPath.isEmpty)
                                          ? const Icon(Icons.person)
                                          : null,
                                ),
                                title: Text('$lastName $firstName'),
                                subtitle: Text(
                                    'Народж.: ${(data['birthDate'] as String?)?.substring(0, 10) ?? 'N/A'}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showEditClientDialog(
                                        context,
                                        trainerId,
                                        d.id,
                                        data,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => _confirmDeleteClient(
                                        context,
                                        trainerId,
                                        d.id,
                                        data,
                                      ),
                                    )
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ClientDetailsScreen(
                                        trainerId: trainerId,
                                        clientId: d.id,
                                        clientName: '$lastName $firstName',
                                        clientPhotoPath: photoPath,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showFilter(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        builder: (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Фільтри (демо)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                  'Тут можна додати фільтр за датою народження, алфавітом тощо.'),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрити'))
            ])));
  }

  Future<void> _showAddClientDialog(
      BuildContext context, String trainerId) async {
    final firstName = TextEditingController();
    final lastName = TextEditingController();
    DateTime? dob;
    File? pickedFile;
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('Новий клієнт'),
                content: SingleChildScrollView(
                    child: Column(children: [
                  TextField(
                      controller: lastName,
                      decoration: const InputDecoration(hintText: 'Прізвище')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: firstName,
                      decoration: const InputDecoration(hintText: 'Ім’я')),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(dob == null
                          ? 'Дата народження'
                          : dob!.toIso8601String().substring(0, 10)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(1940),
                            lastDate: DateTime.now(),
                            initialDate: DateTime(2000, 1, 1));
                        if (picked != null) dob = picked;
                      }),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: OutlinedButton.icon(
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Фото з галереї'),
                            onPressed: () async {
                              final x = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 80);
                              if (x != null) pickedFile = File(x.path);
                            })),
                  ])
                ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Скасувати')),
                  ElevatedButton(
                      onPressed: () async {
                        if (firstName.text.trim().isEmpty ||
                            lastName.text.trim().isEmpty ||
                            dob == null) {
                          return;
                        }
                        try {
                          final fs = context.read<FirestoreService>();
                          final local = context.read<LocalPhotoService>();
                          final id = await fs.addClient(trainerId, {
                            'firstName': firstName.text.trim(),
                            'lastName': lastName.text.trim(),
                            'birthDate': dob!.toIso8601String(),
                          });
                          if (pickedFile != null) {
                            final path = await local.savePhoto(
                                pickedFile!, 'client_$id.jpg');
                            await fs.updateClient(trainerId, id, {'photo': path});
                          }
                          if (!mounted) return;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pop(context);
                          });
                        } catch (e) {
                          if (mounted) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Помилка додавання: $e')));
                            });
                          }
                        }
                      },
                      child: const Text('Додати'))
                ]));
  }

  Future<void> _showEditClientDialog(BuildContext context, String trainerId,
      String clientId, Map<String, dynamic> data) async {
    final firstName = TextEditingController(text: data['firstName']);
    final lastName = TextEditingController(text: data['lastName']);
    DateTime dob = DateTime.parse(data['birthDate']);
    File? pickedFile;
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('Редагувати клієнта'),
                content: SingleChildScrollView(
                    child: Column(children: [
                  TextField(
                      controller: lastName,
                      decoration: const InputDecoration(hintText: 'Прізвище')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: firstName,
                      decoration: const InputDecoration(hintText: 'Ім’я')),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(dob.toIso8601String().substring(0, 10)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(1940),
                            lastDate: DateTime.now(),
                            initialDate: dob);
                        if (picked != null) dob = picked;
                      }),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: OutlinedButton.icon(
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Замінити фото'),
                            onPressed: () async {
                              final x = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 80);
                              if (x != null) pickedFile = File(x.path);
                            }))
                  ])
                ])),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Скасувати')),
                  ElevatedButton(
                      onPressed: () async {
                        try {
                          final fs = context.read<FirestoreService>();
                          final local = context.read<LocalPhotoService>();
                          final update = {
                            'firstName': firstName.text.trim(),
                            'lastName': lastName.text.trim(),
                            'birthDate': dob.toIso8601String()
                          };
                          if (pickedFile != null) {
                            final path = await local.savePhoto(
                                pickedFile!, 'client_$clientId.jpg');
                            update['photo'] = path;
                          }
                          await fs.updateClient(trainerId, clientId, update);
                          if (!mounted) return;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pop(context);
                          });
                        } catch (e) {
                          if (mounted) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Помилка збереження: $e')));
                            });
                          }
                        }
                      },
                      child: const Text('Зберегти'))
                ]));
  }

  Future<void> _confirmDeleteClient(BuildContext context, String trainerId,
      String id, Map<String, dynamic> data) async {
    final fs = context.read<FirestoreService>();
    final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('Видалити клієнта?'),
                content: const Text('Цю дію не можна відмінити.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Ні')),
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Так'))
                ]));
    if (ok == true) {
      final photoPath = data['photo'] as String?;
      if (photoPath != null && photoPath.isNotEmpty) {
        final f = File(photoPath);
        if (f.existsSync()) {
          try {
            f.deleteSync();
          } catch (e) {
            debugPrint('Помилка видалення фото клієнта: $e');
          }
        }
      }
      await fs.deleteClient(trainerId, id);
    }
  }
}
