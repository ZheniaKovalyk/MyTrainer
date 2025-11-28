import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';

class WorkoutEditorScreen extends StatefulWidget {
  final String trainerId;
  final String clientId;
  final String? workoutId;
  final Map<String, dynamic>? initialData;
  const WorkoutEditorScreen(
      {super.key,
      required this.trainerId,
      required this.clientId,
      this.workoutId,
      this.initialData});
  @override
  State<WorkoutEditorScreen> createState() => _WorkoutEditorScreenState();
}

class _WorkoutEditorScreenState extends State<WorkoutEditorScreen> {
  DateTime _date = DateTime.now();
  final _desc = TextEditingController();
  final _duration = TextEditingController();
  final _type = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final d = widget.initialData!;
      _date = DateTime.parse(d['date']);
      _desc.text = d['description'] ?? '';
      _duration.text = (d['duration']?.toString() ?? '');
      _type.text = d['type'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.read<FirestoreService>();
    return Scaffold(
        appBar: AppBar(
            title: Text(
                widget.workoutId == null ? 'Нове тренування' : 'Редагування'),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context))),
        body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(_date.toIso8601String().substring(0, 10)),
                  onPressed: () async {
                    final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)));
                    if (picked != null) setState(() => _date = picked);
                  }),
              const SizedBox(height: 12),
              TextField(
                  controller: _desc,
                  maxLines: 4,
                  decoration:
                      const InputDecoration(hintText: 'Опис тренування')),
              const SizedBox(height: 12),
              TextField(
                  controller: _duration,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(hintText: 'Тривалість (хв)')),
              const SizedBox(height: 12),
              TextField(
                  controller: _type,
                  decoration: const InputDecoration(hintText: 'Тип')),
              const Spacer(),
              ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Зберегти'),
                  onPressed: () async {
                    final data = {
                      'date': _date.toIso8601String(),
                      'description': _desc.text.trim(),
                      'duration': int.tryParse(_duration.text.trim()),
                      'type': _type.text.trim(),
                    };
                    if (widget.workoutId == null) {
                      await fs.addWorkout(
                          widget.trainerId, widget.clientId, data);
                    } else {
                      await fs.updateWorkout(widget.trainerId, widget.clientId,
                          widget.workoutId!, data);
                    }
                    if (!mounted) return;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pop(context);
                    });
                  })
            ])));
  }
}
