import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/search_filter_bar.dart';
import '../../widgets/app_background.dart';
import '../../providers/workouts_provider.dart';
import '../../services/firestore_service.dart';
import 'workout_editor_screen.dart';
import '../settings/settings_screen.dart';

class ClientDetailsScreen extends StatelessWidget {
  final String trainerId;
  final String clientId;
  final String clientName;
  final String? clientPhotoPath;

  const ClientDetailsScreen({
    super.key,
    required this.trainerId,
    required this.clientId,
    required this.clientName,
    this.clientPhotoPath,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WorkoutsProvider(
        context.read<FirestoreService>(),
        trainerId,
        clientId,
      ),
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text('Додати тренування'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutEditorScreen(
                  trainerId: trainerId,
                  clientId: clientId,
                ),
              ),
            );
          },
        ),
        body: AppBackground(
          imageAsset: 'assets/bg_detail.png',
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // header (back + title + settings)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        'Історія тренувань',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
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
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Search + filter bar for workouts (placed under header)
                  Consumer<WorkoutsProvider>(builder: (_, prov, __) {
                    return Column(children: [
                      SearchFilterBar(
                        onQueryChanged: prov.setQuery,
                        onFilterTap: () async {
                          await showModalBottomSheet(
                              context: context,
                              builder: (_) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                                    const Text('Сортування тренувань', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 12),
                                    SegmentedButton<int>(
                                      segments: const <ButtonSegment<int>>[
                                        ButtonSegment<int>(value: 0, label: Text('Дата: від нових до старих')),
                                        ButtonSegment<int>(value: 1, label: Text('Дата: від старих до нових')),
                                        ButtonSegment<int>(value: 2, label: Text('Опис: від А до Я')),
                                        ButtonSegment<int>(value: 3, label: Text('Опис: від Я до А')),
                                        ButtonSegment<int>(value: 4, label: Text('Тривалість: від найбільшої')),
                                        ButtonSegment<int>(value: 5, label: Text('Тривалість: від найменшої')),
                                      ],
                                      selected: <int>{prov.sortMode},
                                      onSelectionChanged: (newSelection) {
                                        final selected = newSelection.isNotEmpty ? newSelection.first : prov.sortMode;
                                        prov.setSortMode(selected);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Закрити'))
                                  ]),
                                );
                              });
                        },
                      ),
                      const SizedBox(height: 8),
                    ]);
                  }),

                  const SizedBox(height: 8),
                  Expanded(
                    child: Consumer<WorkoutsProvider>(
                      builder: (_, prov, __) {
                          final list = prov.filtered;
                        if (list.isEmpty) {
                          return const Center(
                            child: Text('Немає тренувань'),
                          );
                        }
                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final d = list[i];
                            final data = d.data();
                            return Card(
                              child: ListTile(
                                title: Text(data['description'] ?? ''),
                                subtitle: Text(
                                  'Дата: ${(data['date'] as String?)?.substring(0, 10) ?? 'N/A'}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => WorkoutEditorScreen(
                                              trainerId: trainerId,
                                              clientId: clientId,
                                              workoutId: d.id,
                                              initialData: data,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        await context
                                            .read<FirestoreService>()
                                            .deleteWorkout(
                                              trainerId,
                                              clientId,
                                              d.id,
                                            );
                                      },
                                    )
                                  ],
                                ),
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
}
