import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/gym_data.dart';
import 'gym_stats_screen.dart';

// Provides max and prev weight tuple
final pastWeightsProvider = FutureProvider.family<Map<String, double?>, String>((ref, exerciseId) async {
  final repo = ref.read(gymRepoProvider);
  final maxW = await repo.getMaxWeight(exerciseId);
  final prevW = await repo.getPrevWeight(exerciseId);
  return {'max': maxW, 'prev': prevW};
});

class GymPlanScreen extends StatefulWidget {
  const GymPlanScreen({super.key});

  @override
  State<GymPlanScreen> createState() => _GymPlanScreenState();
}

class _GymPlanScreenState extends State<GymPlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('El\'s Workout Plan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Push'),
            Tab(text: 'Legs'),
            Tab(text: 'Pull'),
            Tab(text: 'Cardio'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorkoutList(GymData.pushDay),
          _buildWorkoutList(GymData.legDay),
          _buildWorkoutList(GymData.pullDay),
          _buildCardioTab(),
        ],
      ),
    );
  }

  Widget _buildWorkoutList(List<Exercise> exercises) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return ExerciseCard(exercise: exercises[index]);
      },
    );
  }

  Widget _buildCardioTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔥 HIIT (High-Intensity Interval Training)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                const SizedBox(height: 8),
                const Text('8x Intervals: 30sec sprint, 90sec walk. Cool-down 5 min.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🚶 LISS (Low-Intensity Steady State)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                const SizedBox(height: 8),
                const Text('30 minutes. Brisk walk, incline 8-12% keeping heart rate in Zone 2.', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class ExerciseCard extends ConsumerWidget {
  final Exercise exercise;

  const ExerciseCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightsAsync = ref.watch(pastWeightsProvider(exercise.id));
    
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: exercise.tip != null ? () => _showTipDialog(context) : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.show_chart, color: Colors.blueAccent),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => GymStatsScreen(exercise: exercise)),
                    );
                  },
                )
              ],
            ),
            if (exercise.note != null) ...[
              const SizedBox(height: 4),
              Text(exercise.note!, style: const TextStyle(color: Colors.orangeAccent, fontSize: 13)),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('SETS', exercise.sets),
                _buildStat('REPS', exercise.reps),
                _buildStat('REST', exercise.rest),
              ],
            ),
            const Divider(height: 32),
            weightsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
              data: (weights) {
                final maxW = weights['max'];
                final prevW = weights['prev'];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Max: ${maxW != null ? '$maxW lbs' : '--'}', style: const TextStyle(color: Colors.grey)),
                        Text('Prev: ${prevW != null ? '$prevW lbs' : '--'}', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showLogDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Log Weight'),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showLogDialog(BuildContext context, WidgetRef ref) {
    final txtController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log ${exercise.name}'),
        content: TextField(
          controller: txtController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Weight (lbs)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = double.tryParse(txtController.text);
              if (val != null) {
                await ref.read(gymRepoProvider).logWeight(exercise.id, val);
                ref.invalidate(pastWeightsProvider(exercise.id));
                ref.invalidate(exerciseLogsProvider(exercise.id));
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  void _showTipDialog(BuildContext context) {
    if (exercise.tip == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${exercise.name} Tips'),
        content: SingleChildScrollView(
          child: Text(
            exercise.tip!,
            style: const TextStyle(height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it!'),
          )
        ],
      ),
    );
  }
}
