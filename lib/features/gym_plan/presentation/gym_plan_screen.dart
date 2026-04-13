import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/gym_data.dart';
import 'gym_stats_screen.dart';

// Provides max and prev weight tuple
final pastWeightsProvider = FutureProvider.family<Map<String, double?>, String>((ref, exerciseId) async {
  final repo = ref.watch(gymRepoProvider);
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
  // --- Advices ---
  static const String pushAdvice = '''• WARM-UP: Doing lighter, high-rep sets gets blood flowing and "greases the groove"—crucial before your heavy 6-8 rep sets.

• FORM OVER WEIGHT (NO EGO LIFTING): The #1 beginner pitfall! The plan calls for 6-8 reps. This means you should form-fail around the 7th or 8th rep. If you can only do 4, it's too heavy. If 10 is easy, it's too light.

• CONTROL THE "NEGATIVE": Don't let the weight slam back. Use a 1-second push (concentric) and a 3-second controlled return (eccentric). Growth happens on the negative!''';

  static const String legsAdvice = '''• WARM-UP: Extremely important on leg day to prepare your knees and hips. Do lighter warm-up sets on the Leg Press.

• BRACE YOUR CORE: Keep your core tight (like taking a punch) for every exercise here. It protects your lower back and makes lifts infinitely more powerful.

• FULL RANGE OF MOTION (ROM): No "half reps." Grow best through full range—deep on presses (safely), and full stretches on curls/extensions.

• DON'T LOCK YOUR KNEES: When pushing leg weight, extend until almost straight, but never "lock out" the joint hard. Keep a soft bend.''';

  static const String pullAdvice = '''• WARM-UP: Get the blood strictly to your back first with lighter Lat Pulldowns.

• PULL WITH YOUR ELBOWS: The golden rule of back exercises! Treat your hands as "meat hooks" and drive from your elbows. Try a "thumbless grip" (thumb over the bar) to stop your biceps from taking over.

• MIND-MUSCLE CONNECTION: Squeeze your shoulder blades together like you're pinching a walnut on every single row and pulldown.

• KEEP YOUR CHEST UP: Resist the urge to round your back. Keep a proud chest and a rigid straight spine to protect your lower back.''';

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
          onTap: (index) {
            if (index == _tabController.index) {
              if (index == 0) _showDayAdvice(context, 'Push Day Guide', pushAdvice);
              if (index == 1) _showDayAdvice(context, 'Leg Day Guide', legsAdvice);
              if (index == 2) _showDayAdvice(context, 'Pull Day Guide', pullAdvice);
            }
          },
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
                const Text('⚠️ WARM-UP: 5 min brisk walk before your first sprint interval. Never sprint cold.', style: TextStyle(color: Colors.orangeAccent)),
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

  void _showDayAdvice(BuildContext context, String title, String advice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(
            advice,
            style: const TextStyle(height: 1.5, fontSize: 15),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Let\'s crush it!'),
          )
        ],
      ),
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
