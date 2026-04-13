import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/gym_data.dart';
import '../../daily_plan/data/daily_plan_data.dart';
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
  static const String upperAdvice = '''• WARM-UP: Do 1-2 light sets on your first compound lift (chest press or rows). Gets blood flowing and "greases the groove" before heavy sets.

• FORM OVER WEIGHT (NO EGO LIFTING): The plan calls for 6-8 reps on compounds. Form-fail around the 7th or 8th rep. If you can only do 4, it's too heavy. If 10 is easy, it's too light.

• CONTROL THE "NEGATIVE": Don't let the weight slam back. Use a 1-second push (concentric) and a 3-second controlled return (eccentric). Growth happens on the negative!

• PULL WITH YOUR ELBOWS: For back exercises, treat your hands as "meat hooks" and drive from your elbows. Try a "thumbless grip" to stop your biceps from taking over.''';

  static const String lowerAdvice = '''• WARM-UP: Extremely important on leg day to prepare your knees and hips. Do lighter warm-up sets on the Leg Press.

• BRACE YOUR CORE: Keep your core tight (like taking a punch) for every exercise. It protects your lower back and makes lifts infinitely more powerful.

• FULL RANGE OF MOTION (ROM): No "half reps." Grow best through full range—deep on presses (safely), and full stretches on curls/extensions.

• DON'T LOCK YOUR KNEES: When pushing leg weight, extend until almost straight, but never "lock out" the joint hard. Keep a soft bend.''';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
              if (index == 0) _showDayAdvice(context, 'Upper A Guide', upperAdvice);
              if (index == 1) _showDayAdvice(context, 'Lower A Guide', lowerAdvice);
              if (index == 2) _showDayAdvice(context, 'Upper B Guide', upperAdvice);
              if (index == 3) _showDayAdvice(context, 'Lower B Guide', lowerAdvice);
            }
          },
          tabs: const [
            Tab(text: 'Upper A'),
            Tab(text: 'Lower A'),
            Tab(text: 'Upper B'),
            Tab(text: 'Lower B'),
            Tab(text: 'Cardio'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorkoutList(GymData.upperADay),
          _buildWorkoutList(GymData.lowerADay),
          _buildWorkoutList(GymData.upperBDay),
          _buildWorkoutList(GymData.lowerBDay),
          _buildCardioTab(),
        ],
      ),
    );
  }

  Widget _buildWorkoutList(List<Exercise> exercises) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length + (DailyPlanData.isDeloadWeek() ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (DailyPlanData.isDeloadWeek() && index == 0) {
          return _buildGymDeloadAlert();
        }
        final exerciseIndex = DailyPlanData.isDeloadWeek() ? index - 1 : index;
        return ExerciseCard(exercise: exercises[exerciseIndex]);
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
                Row(
                  children: [
                    const Expanded(
                      child: Text('🔥 HIIT (High-Intensity Interval Training)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                      ),
                      child: const Text('Saturday', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.redAccent)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('⌚ Apple Watch: Start an "HIIT" workout. Track Heart Rate Zones.', style: TextStyle(color: Colors.cyanAccent, fontSize: 13)),
                const SizedBox(height: 12),
                const Text('Step-by-Step:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                const SizedBox(height: 8),
                const Text(
                  '1️⃣ WARM-UP (5 min)\n'
                  '   • Brisk walk on treadmill, speed 3.0-3.5 mph\n'
                  '   • Goal: Heart Rate Zone 2 (110-130 bpm)\n'
                  '   • Loosen up legs, get blood flowing\n\n'
                  '2️⃣ SPRINT INTERVALS — 8 Rounds (20 min)\n'
                  '   For each round:\n'
                  '   • 🏃 SPRINT 30 sec: Treadmill speed 8-10 mph (or outdoor all-out sprint)\n'
                  '   • Goal: Heart Rate Zone 4-5 (160-180+ bpm)\n'
                  '   • 🚶 WALK 90 sec: Drop speed to 3.0 mph\n'
                  '   • Goal: Let HR drop to Zone 2-3 (120-140 bpm) before next sprint\n'
                  '   • If HR doesn\'t drop below 150 by the walk end, rest 30 sec longer\n\n'
                  '3️⃣ COOL-DOWN (5 min)\n'
                  '   • Walk at 2.5-3.0 mph, gradually slowing\n'
                  '   • Goal: Heart Rate back to Zone 1 (<110 bpm)\n'
                  '   • Light static stretches for quads, hamstrings, calves\n\n'
                  '📊 After: Check Apple Watch summary — aim for 15+ min in Zone 4-5 over time.',
                  style: TextStyle(color: Colors.white70, height: 1.6),
                ),
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
                Row(
                  children: [
                    const Expanded(
                      child: Text('🚶 LISS (Low-Intensity Steady State)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                      ),
                      child: const Text('Tue & Sun', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.greenAccent)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('⌚ Apple Watch: Start an "Outdoor Walk" or "Indoor Walk" workout.', style: TextStyle(color: Colors.cyanAccent, fontSize: 13)),
                const SizedBox(height: 12),
                const Text('Step-by-Step:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                const SizedBox(height: 8),
                const Text(
                  '1️⃣ INCLINE WALK (30 min)\n'
                  '   • Treadmill: Speed 3.0-3.5 mph, Incline 8-12%\n'
                  '   • OR outdoor: Find a hilly route or walk briskly\n'
                  '   • Goal: Stay in Heart Rate Zone 2 the ENTIRE time (120-140 bpm)\n'
                  '   • You should be able to hold a conversation but feel slightly winded\n'
                  '   • ⚠️ If HR goes above 150, you\'re going too fast — slow down\n'
                  '   • ⚠️ If HR stays below 110, bump incline up or walk faster\n\n'
                  '2️⃣ STRETCH & MOBILITY (15 min)\n'
                  '   • Quad stretch (30 sec/side) — pull heel to glute\n'
                  '   • Hamstring stretch (30 sec/side) — foot on bench, lean forward\n'
                  '   • Hip flexor lunge stretch (30 sec/side)\n'
                  '   • Calf stretch against wall (30 sec/side)\n'
                  '   • Cat-cow spinal mobility (10 reps)\n'
                  '   • World\'s greatest stretch (5/side)\n\n'
                  '📊 After: Check Apple Watch — you want 25+ min in Zone 2. Fat burn is maximized here.',
                  style: TextStyle(color: Colors.white70, height: 1.6),
                ),
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
                const Text('⌚ Heart Rate Zones Reference', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                const SizedBox(height: 12),
                const Text(
                  'Zone 1 (50-60%): < 110 bpm — Very light, warm-up/cool-down\n'
                  'Zone 2 (60-70%): 110-140 bpm — Fat burning, conversation pace\n'
                  'Zone 3 (70-80%): 140-160 bpm — Moderate effort, breathing harder\n'
                  'Zone 4 (80-90%): 160-175 bpm — Hard effort, can\'t talk much\n'
                  'Zone 5 (90-100%): 175-198 bpm — Max effort, sprint pace\n\n'
                  '(Based on max HR ~198 bpm for age 22)',
                  style: TextStyle(color: Colors.white70, height: 1.6),
                ),
              ],
            ),
          ),
        ),
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

  Widget _buildGymDeloadAlert() {
    return GestureDetector(
      onTap: () => _showDeloadDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent, width: 2),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_rounded, color: Colors.redAccent, size: 22),
            SizedBox(width: 8),
            Text(
              'DELOAD WEEK',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(width: 8),
            Text('Tap for details', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showDeloadDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fitness_center, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Deload Protocol', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            '🔴 DELOAD WEEK — Recovery Protocol\n'
            'Your body recovers and supercompensates this week. Still train, but lighter.\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'LIFTING (Mon / Wed / Thu / Fri):\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Use 50% of your normal working weight\n'
            '• Do 2 sets instead of 3-4 per exercise\n'
            '• Same rep ranges, same rest periods\n'
            '• Focus on perfect form & mind-muscle connection\n'
            '• Stop every set 4-5 reps short of failure\n\n'
            'Example:\n'
            '  If you normally Chest Press 120 lbs × 4 sets × 8 reps\n'
            '  → This week: 60 lbs × 2 sets × 8 reps\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'CARDIO:\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Tuesday LISS: Same 30 min walk, drop incline to 4-6%\n'
            '• Saturday HIIT → Replace with LISS (30 min easy walk, no sprints)\n'
            '• Sunday LISS: Keep as is\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'PLANK HOLD:\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Do 2 sets × 20-30 sec (instead of 3 × 30-60 sec)\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'NUTRITION & SUPPLEMENTS:\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Keep protein intake the same\n'
            '• Keep creatine at 5g/day (never cycle creatine)\n'
            '• Keep all other supplements unchanged\n'
            '• If hungrier than usual — that\'s normal, don\'t overeat\n\n'
            '⚡ You\'ll come back STRONGER next week. Trust the process.',
            style: TextStyle(height: 1.5, fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it — light week! 💪'),
          ),
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
