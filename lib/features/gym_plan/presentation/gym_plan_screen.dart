import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../data/gym_data.dart';
import '../../daily_plan/data/daily_plan_data.dart';
import 'gym_stats_screen.dart';
import 'gym_logs_editor_screen.dart';


// Provides max and prev weight tuple
typedef PastWeightArg = ({String exerciseId, int setIndex});

final pastWeightsProvider = FutureProvider.family<Map<String, double?>, PastWeightArg>((ref, arg) async {
  final repo = ref.watch(gymRepoProvider);
  final maxW = await repo.getMaxWeight(arg.exerciseId, arg.setIndex);
  final prevW = await repo.getPrevWeight(arg.exerciseId, arg.setIndex);
  return {'max': maxW, 'prev': prevW};
});

final todayLogCountProvider = FutureProvider.family<int, String>((ref, exerciseId) async {
  final repo = ref.watch(gymRepoProvider);
  final logs = await repo.getLogs(exerciseId);
  final today = DateTime.now().toIso8601String().split('T')[0];
  
  int count = 0;
  for (var log in logs) {
    if (log.date.toIso8601String().split('T')[0] == today) {
      count++;
    }
  }
  return count;
});

class SelectedFirstExerciseNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  
  void setExercise(String id) {
    state = id;
  }
}

final selectedFirstExerciseProvider = NotifierProvider<SelectedFirstExerciseNotifier, String?>(SelectedFirstExerciseNotifier.new);

class GymPlanScreen extends ConsumerStatefulWidget {
  const GymPlanScreen({super.key});

  @override
  ConsumerState<GymPlanScreen> createState() => _GymPlanScreenState();
}

class _GymPlanScreenState extends ConsumerState<GymPlanScreen> with SingleTickerProviderStateMixin {
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

  int _getInitialTabIndex() {
    final weekday = DateTime.now().weekday;
    switch (weekday) {
      case DateTime.monday: return 0; // Upper A
      case DateTime.tuesday: return 1; // Lower A
      case DateTime.thursday: return 2; // Upper B
      case DateTime.friday: return 3; // Lower B
      case DateTime.wednesday:
      case DateTime.saturday:
      case DateTime.sunday:
      default:
        return 4; // Cardio
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: _getInitialTabIndex(),
      length: 5, 
      vsync: this
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('El\'s Workout Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Logs',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GymLogsEditorScreen()),
              ).then((_) {
                ref.invalidate(pastWeightsProvider);
                ref.invalidate(todayLogCountProvider);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Trends',
            onPressed: () async {
              try {
                final path = await ref.read(gymRepoProvider).exportAllTrendsCsv();
                final box = context.findRenderObject() as RenderBox?;
                await Share.shareXFiles(
                  [XFile(path)], 
                  text: 'My Workout Trends',
                  sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error exporting: $e')));
                }
              }
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            _buildLongPressTab('Upper A', 0, 'Upper A Guide', upperAdvice),
            _buildLongPressTab('Lower A', 1, 'Lower A Guide', lowerAdvice),
            _buildLongPressTab('Upper B', 2, 'Upper B Guide', upperAdvice),
            _buildLongPressTab('Lower B', 3, 'Lower B Guide', lowerAdvice),
            const Tab(text: 'Cardio'),
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

  Widget _buildLongPressTab(String label, int index, String title, String advice) {
    return GestureDetector(
      onLongPress: () => _showDayAdvice(context, title, advice),
      behavior: HitTestBehavior.opaque,
      child: Tab(text: label),
    );
  }

  Widget _buildWorkoutList(List<Exercise> exercises) {
    bool hasStartedWorkout = false;
    
    int getCategory(Exercise exercise) {
      int numSets = 3;
      final match = RegExp(r'(\d+)').allMatches(exercise.sets);
      if (match.isNotEmpty) {
        numSets = int.parse(match.last.group(0)!);
      }
      final count = ref.watch(todayLogCountProvider(exercise.id)).value ?? 0;
      if (count > 0) hasStartedWorkout = true;
      
      if (count >= numSets) return 2; // completed
      if (count > 0) return 0; // active
      return 1; // untouched
    }

    final indexedExercises = exercises.asMap().entries.toList();
    final categories = <int, int>{};
    for (var entry in indexedExercises) {
      categories[entry.key] = getCategory(entry.value);
    }

    indexedExercises.sort((a, b) {
      final catA = categories[a.key]!;
      final catB = categories[b.key]!;
      if (catA != catB) return catA.compareTo(catB);
      return a.key.compareTo(b.key);
    });

    final finalExercises = indexedExercises.map((e) => e.value).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: finalExercises.length + (DailyPlanData.isDeloadWeek() ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (DailyPlanData.isDeloadWeek() && index == 0) {
          return _buildGymDeloadAlert();
        }
        final exerciseIndex = DailyPlanData.isDeloadWeek() ? index - 1 : index;
        return ExerciseCard(exercise: finalExercises[exerciseIndex], hasStartedWorkout: hasStartedWorkout);
      },
    );
  }

  Widget _buildCardioTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── The Aesthetic Zone 2 Blueprint ──
        Card(
          elevation: 4,
          shadowColor: Colors.blueAccent.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('🚶 The Aesthetic Fat-Burner (Zone 2)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4)),
                      ),
                      child: const Text('Wed & Sat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueAccent)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('⌚ Apple Watch → Workout → Indoor Walk', style: TextStyle(color: Colors.cyanAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Step-by-Step Execution:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                const SizedBox(height: 8),
                const Text(
                  '1️⃣ THE SETUP (40 mins)\n'
                  '   • Machine: Incline Treadmill\n'
                  '   • Incline: 10% - 15% (as high as comfortable)\n'
                  '   • Speed: 2.5 - 3.2 mph (Do NOT jog, just a brisk walk)\n\n'
                  '2️⃣ THE GOLDEN RULES (Aesthetics)\n'
                  '   • 🚫 DO NOT hold the handrails. Pump your arms. Holding on burns 30% fewer calories.\n'
                  '   • Swipe left on your Apple Watch to view the live Heart Rate Zones.\n'
                  '   • Your target is strictly Zone 2 (120 - 140 bpm).\n\n'
                  '3️⃣ LIVE TROUBLESHOOTING\n'
                  '   • If your HR hits 145+ (Zone 3), flatten the incline slightly or slow down.\n'
                  '   • If your HR drops to 110 (Zone 1), crank the incline to MAX.\n'
                  '   • Result: You will sweat heavily but be able to hold a conversation without gasping. This strips pure facial/belly fat without burning muscle or causing cortisol bloating.',
                  style: TextStyle(color: Colors.white70, height: 1.6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // ── HR Zones Reference ──
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
                  'Zone 2 (60-70%): 110-140 bpm — FAT BURNING ZONE, conversation pace. Stay here!\n'
                  'Zone 3 (70-80%): 140-160 bpm — Sweets/Sugar burning. Spikes appetite.\n'
                  'Zone 4 (80-90%): 160-175 bpm — Hard effort, depletes muscle glycogen.\n'
                  'Zone 5 (90-100%): 175-198 bpm — Max effort, sprint pace.\n\n'
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
            '🔴 DELOAD WEEK — Intensity-Preservation\n'
            'Because you are on a caloric deficit, dropping weight will signal your body to shed muscle. Drop fatigue, not intensity.\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'LIFTING (Mon / Wed / Thu / Fri):\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Keep your working weight the SAME (100%)\n'
            '• Cut your volume in half (e.g., 2 sets instead of 4)\n'
            '• Keep the same rep ranges and rest periods\n'
            '• Stop 2-3 reps short of failure (RPE 7) on every set\n'
            '• Do absolutely zero forced reps or drop sets\n\n'
            'Example:\n'
            '  If you normally Leg Press 200 lbs × 4 sets to failure\n'
            '  → This week: 200 lbs × 2 sets (stopping 2 reps early)\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'CARDIO (Wed / Sat):\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Keep your 40-minute LISS schedule exactly same.\n'
            '• Since you track HR, just stay strictly in your target zone.\n'
            '• LISS does not tax the CNS, so no deload is needed here. Keep burning the fat.\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'PLANK HOLD:\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Do 2 sets × 20-30 sec (instead of 3-4 sets)\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'NUTRITION & SUPPLEMENTS:\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Keep protein intake the exact same\n'
            '• Keep creatine at 5g/day (never cycle it)\n'
            '• Expect sleep quality to drastically improve this week\n'
            '• If hungrier than usual — that\'s normal, hold the cut line\n\n'
            '⚡ Clear the CNS fatigue. Keep the muscle. Trust the math.',
            style: TextStyle(height: 1.5, fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it — heavy weight, low volume! 🧠'),
          ),
        ],
      ),
    );
  }
}

class ExerciseCard extends ConsumerWidget {
  final Exercise exercise;
  final bool hasStartedWorkout;

  const ExerciseCard({super.key, required this.exercise, this.hasStartedWorkout = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int numSets = 3;
    final match = RegExp(r'(\d+)').allMatches(exercise.sets);
    if (match.isNotEmpty) {
      numSets = int.parse(match.last.group(0)!);
    }

    final todayLogCountAsync = ref.watch(todayLogCountProvider(exercise.id));
    final todayLogCount = todayLogCountAsync.value ?? 0;
    
    final isCompleted = todayLogCount >= numSets;
    final nextSetIndex = isCompleted ? numSets : (todayLogCount + 1);

    final weightsAsync = ref.watch(pastWeightsProvider((exerciseId: exercise.id, setIndex: nextSetIndex)));
    
    final baselineWeightsAsync = ref.watch(pastWeightsProvider((exerciseId: exercise.id, setIndex: 1)));
    final baselinePrevW = baselineWeightsAsync.value?['prev'];
    final workingWeight = baselinePrevW ?? baselineWeightsAsync.value?['max'];

    final selectedStartId = ref.watch(selectedFirstExerciseProvider);
    final isPrimaryWarmup = selectedStartId == exercise.id;

    return Opacity(
      opacity: isCompleted ? 0.6 : 1.0,
      child: Card(
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
            if (todayLogCount == 0 && !hasStartedWorkout) ...[
              if (isPrimaryWarmup)
                _buildWarmupSuggestion(workingWeight),
              if (!isPrimaryWarmup)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      ref.read(selectedFirstExerciseProvider.notifier).setExercise(exercise.id);
                    },
                    icon: const Icon(Icons.local_fire_department, size: 16, color: Colors.orangeAccent),
                    label: const Text('Set as Start', style: TextStyle(color: Colors.orangeAccent)),
                  ),
                ),
            ],
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
                        Text('Set $nextSetIndex Max: ${maxW != null ? '$maxW lbs' : '--'}', style: const TextStyle(color: Colors.grey)),
                        Text('Set $nextSetIndex Prev: ${prevW != null ? '$prevW lbs' : '--'}', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: isCompleted ? null : () => _showLogDialog(context, ref, todayLogCount, numSets),
                      icon: Icon(isCompleted ? Icons.check : Icons.add),
                      label: Text(isCompleted ? 'Completed' : 'Log Weight'),
                    )
                  ],
                );
              },
            ),
          ],
        ),
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

  Widget _buildWarmupSuggestion(double? workingWeight) {
    if (workingWeight == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 18),
                SizedBox(width: 8),
                Text('Smart Warm-up', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
              ],
            ),
            SizedBox(height: 8),
            Text('1. Very light weight for 10-15 reps', style: TextStyle(fontSize: 13, color: Colors.white70)),
            SizedBox(height: 4),
            Text('2. Moderate light weight for 8-10 reps', style: TextStyle(fontSize: 13, color: Colors.white)),
          ],
        ),
      );
    }

    double roundTo5(double w) => (w / 5).round() * 5.0;

    final w0 = roundTo5(workingWeight * 0.3);
    final w1 = roundTo5(workingWeight * 0.5);
    final w2 = roundTo5(workingWeight * 0.7);
    final w3 = roundTo5(workingWeight * 0.85);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 18),
              SizedBox(width: 8),
              Text('Smart Warm-up', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
            ],
          ),
          const SizedBox(height: 8),
          Text('1. ~${w0.toStringAsFixed(0)} lbs for 10-15 reps (30%)', style: const TextStyle(fontSize: 13, color: Colors.white)),
          const SizedBox(height: 4),
          Text('2. ~${w1.toStringAsFixed(0)} lbs for 8-10 reps (50%)', style: const TextStyle(fontSize: 13, color: Colors.white)),
          const SizedBox(height: 4),
          Text('3. ~${w2.toStringAsFixed(0)} lbs for 4-6 reps (70%)', style: const TextStyle(fontSize: 13, color: Colors.white)),
          const SizedBox(height: 4),
          Text('4. ~${w3.toStringAsFixed(0)} lbs for 1-2 reps (Primer)', style: const TextStyle(fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }

  void _showLogDialog(BuildContext context, WidgetRef ref, int loggedToday, int totalSets) {
    final remainingSets = totalSets - loggedToday;
    if (remainingSets <= 0) return;
    
    final controllers = List.generate(remainingSets, (index) => TextEditingController());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log ${exercise.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: remainingSets,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: TextField(
                  controller: controllers[index],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Set ${loggedToday + index + 1} (lbs)',
                    border: const OutlineInputBorder(),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final weights = <double>[];
              for (var c in controllers) {
                final w = double.tryParse(c.text);
                if (w != null) weights.add(w);
              }
              if (weights.isNotEmpty) {
                await ref.read(gymRepoProvider).logWeights(exercise.id, weights, startIndex: loggedToday + 1);
                ref.invalidate(pastWeightsProvider);
                ref.invalidate(todayLogCountProvider(exercise.id));
                // ignore: invalid_use_of_visible_for_testing_member
                try {
                  ref.invalidate(exerciseLogsProvider(exercise.id));
                } catch (_) {}
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
