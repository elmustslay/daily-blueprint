import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/gym_data.dart';

final allLogsProvider = FutureProvider<List<ExerciseLog>>((ref) async {
  return ref.read(gymRepoProvider).getAllLogs();
});

class GymLogsEditorScreen extends ConsumerWidget {
  const GymLogsEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Logs'),
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('No logs to edit.'));
          }
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final exName = GymData.getExerciseName(log.exerciseId);
              final dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(log.date);

              return ListTile(
                title: Text('$exName (Set ${log.setIndex})'),
                subtitle: Text('$dateStr\nWeight: ${log.weight} lbs'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => _showEditDialog(context, ref, log),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteLog(context, ref, log),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, ExerciseLog log) {
    final controller = TextEditingController(text: log.weight.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Weight'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Weight (lbs)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(controller.text);
              if (val != null && log.id != null) {
                await ref.read(gymRepoProvider).updateLogWeight(log.id!, val);
                ref.invalidate(allLogsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  void _deleteLog(BuildContext context, WidgetRef ref, ExerciseLog log) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Log?'),
        content: const Text('Are you sure you want to delete this log?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (log.id != null) {
                await ref.read(gymRepoProvider).deleteLog(log.id!);
                ref.invalidate(allLogsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
