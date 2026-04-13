import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/sqlite_db.dart';

// --- Domain ---
class ExerciseLog {
  final int? id;
  final String exerciseId;
  final double weight;
  final DateTime date;

  ExerciseLog({this.id, required this.exerciseId, required this.weight, required this.date});
}

class Exercise {
  final String id;
  final String name;
  final String sets;
  final String reps;
  final String rest;
  final String? note;
  final String? tip;

  const Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
    this.note,
    this.tip,
  });
}

abstract class GymRepository {
  Future<void> logWeight(String exerciseId, double weight);
  Future<List<ExerciseLog>> getLogs(String exerciseId);
  Future<double?> getMaxWeight(String exerciseId);
  Future<double?> getPrevWeight(String exerciseId);
}

// --- Data ---
class GymRepositoryImpl implements GymRepository {
  @override
  Future<void> logWeight(String exerciseId, double weight) async {
    final db = await SqliteDb.instance;
    await db.insert('logs', {
      'exercise_id': exerciseId,
      'weight': weight,
      'date': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<ExerciseLog>> getLogs(String exerciseId) async {
    final db = await SqliteDb.instance;
    final maps = await db.query(
      'logs',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'date ASC',
    );
    return maps.map((e) => ExerciseLog(
      id: e['id'] as int,
      exerciseId: e['exercise_id'] as String,
      weight: e['weight'] as double,
      date: DateTime.parse(e['date'] as String),
    )).toList();
  }

  @override
  Future<double?> getMaxWeight(String exerciseId) async {
    final db = await SqliteDb.instance;
    final result = await db.rawQuery('SELECT MAX(weight) as max_w FROM logs WHERE exercise_id = ?', [exerciseId]);
    if (result.isNotEmpty && result.first['max_w'] != null) {
      return result.first['max_w'] as double;
    }
    return null;
  }

  @override
  Future<double?> getPrevWeight(String exerciseId) async {
    final db = await SqliteDb.instance;
    final result = await db.query(
      'logs',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['weight'] as double;
    }
    return null;
  }
}

final gymRepoProvider = Provider<GymRepository>((ref) => GymRepositoryImpl());

class GymData {
  // Upper A (Monday) - Chest & Shoulder emphasis
  static const List<Exercise> upperADay = [
    Exercise(
      id: 'push_1', name: 'Machine Chest Press', sets: '4', reps: '6-8', rest: '2-3 min',
      tip: '🎯 Focus: Feel it in your chest (pecs).\n\n💡 How to do it: Adjust seat height so handles are level with the middle of your chest. Drop your shoulders down and squeeze your shoulder blades back (like pinching a pencil).\n\n⚠️ Common Pitfall: Flaring elbows out to 90 degrees. Tuck your elbows slightly to a 45-60 degree angle to protect your shoulders.',
    ),
    Exercise(
      id: 'push_2', name: 'Machine Shoulder Press', sets: '3', reps: '6-8', rest: '2-3 min',
      tip: '🎯 Focus: Front and side of your shoulders.\n\n💡 How to do it: Keep your back flat against the pad without excessively arching your lower back. Brace your core tightly.\n\n⚠️ Common Pitfall: Setting the seat too low. Handles should start at or just above shoulder level. If they start at your chest, you are turning it into an incline chest press.',
    ),
    Exercise(
      id: 'pull_1', name: 'Lat Pulldown Machine', sets: '3', reps: '8-12', rest: '2-3 min',
      tip: '🎯 Focus: Your lats (the "wings" on the sides of your back).\n\n💡 How to do it: Grab bar wider than shoulders. Pull down by bringing your elbows straight down to your back pockets. Pull the bar to your upper chest.\n\n⚠️ Common Pitfall: Leaning back too far to use heavy momentum. Keep torso mostly upright. Never pull behind the neck.',
    ),
    Exercise(
      id: 'push_3', name: 'Pec Deck / Machine Fly', sets: '3', reps: '8-12', rest: '1-2 min',
      tip: '🎯 Focus: Isolation exercise to stretch and squeeze the chest.\n\n💡 How to do it: Think about bringing your elbows together, not your hands. Keep a slight, constant bend in your elbows—don\'t lock them out.\n\n⚠️ Common Pitfall: Using the front shoulders and biceps to pull the weight. Focus entirely on squeezing the chest muscles together.',
    ),
    Exercise(
      id: 'pull_4', name: 'Machine Reverse Fly / Rear Delt', sets: '3', reps: '15-20', rest: '1-2 min',
      tip: '🎯 Focus: Rear deltoids (back of shoulder).\n\n💡 How to do it: Keep weight light for the 15-20 rep range. Keep a slight but rigid bend in your elbows. Open arms wide and squeeze shoulder blades at the peak.\n\n⚠️ Common Pitfall: Bending elbows to 90 degrees making it a row. Keep arms relatively straight to isolate the small rear delt muscle.',
    ),
    Exercise(
      id: 'push_5', name: 'Tricep Pushdown/Press', sets: '3', reps: '8-12', rest: '1-2 min',
      tip: '🎯 Focus: The lateral and long heads of the triceps.\n\n💡 How to do it: Keep your chest up and shoulders back. Pin your elbows to your sides and push straight down until arms are fully extended.\n\n⚠️ Common Pitfall: Letting the cable pull your elbows fully forward on the way up. Keep the elbows strictly locked by your ribs.',
    ),
    Exercise(
      id: 'pull_5', name: 'Machine Bicep Curl', sets: '3', reps: '10-12', rest: '1-2 min',
      tip: '🎯 Focus: The main "peak" of your bicep.\n\n💡 How to do it: Adjust seat so your armpit is snug against the top of the pad. Your upper arm should be completely immobilized. Squeeze hard at the peak of the curl.\n\n⚠️ Common Pitfall: Lifting elbows off the pad or rocking your shoulders. Lock your upper arm firmly against the pad at all times.',
    ),
    Exercise(
      id: 'abs_1', name: 'Abdominal Crunch Machine', sets: '3', reps: '12-15', rest: '1 min',
      tip: '🎯 Focus: Upper and lower abs (rectus abdominis).\n\n💡 How to do it: Sit down, grab the handles, and curl your torso forward by contracting your abs — not by pulling with your arms. Exhale as you crunch, pause at peak contraction for 1 second, then slowly return.\n\n⚠️ Common Pitfall: Using your arms and hip flexors to yank the weight. Keep your arms locked in position and focus entirely on your abs doing the curling motion. Start light!',
    ),
  ];

  // Lower A (Wednesday) - Quad & Glute Focus
  static const List<Exercise> lowerADay = [
    Exercise(
      id: 'legs_1', name: 'Leg Press Machine', sets: '4', reps: '6-8', rest: '2-3 min',
      tip: '🎯 Focus: Big compound lift for quads and glutes.\n\n💡 How to do it: Place feet shoulder-width apart. As you lower the weight, aim to bring knees towards your chest. Push through the whole foot (especially the heel) to drive up.\n\n⚠️ Common Pitfall: "Butt wink" – lifting your lower back/hips off the seat at the bottom. Only go as deep as you can before your hips peel off the pad.',
    ),
    Exercise(
      id: 'legs_2', name: 'Seated Leg Curl Machine', sets: '3', reps: '8-10', rest: '2-3 min',
      tip: '🎯 Focus: Isolates hamstrings (back of thighs) in a lengthened position for max growth.\n\n💡 How to do it: Align knee joint perfectly with the machine\'s pivot point. Clamp the lap pad firmly against your thighs so they cannot move. Drive heels back and squeeze hard at the bottom.\n\n⚠️ Common Pitfall: If your knees can rise off the seat during the curl, the lap pad is too loose. Lock it down tight!',
    ),
    Exercise(
      id: 'legs_5', name: 'Leg Extension Machine', sets: '3', reps: '12-15', rest: '1-2 min',
      tip: '🎯 Focus: Isolating the quads (front of thighs).\n\n💡 How to do it: Line up knee joint with pivot point. Pad should lie on your lower shins. Squeeze quads hard at the top for a 1-second pause.\n\n⚠️ Common Pitfall: Swinging weight up with momentum (bad for knees). Control the movement, especially returning down. Focus on the muscle contraction rather than sheer weight.',
    ),
    Exercise(
      id: 'legs_4', name: 'Glute Kickback Machine', sets: '3', reps: '12-15', rest: '1-2 min',
      tip: '🎯 Focus: Gluteus Maximus (the main butt muscle).\n\n💡 How to do it: Chest against the pad, grip handles firmly. Core tight. Drive your heel back and up toward the ceiling. Squeeze your butt hard at the top.\n\n⚠️ Common Pitfall: Arching your lower back to get the leg higher. This turns off the glute entirely. Keep your spine perfectly neutral.',
    ),
    Exercise(
      id: 'legs_6', name: 'Machine Seated Calf Extension', sets: '4', reps: '15-20', rest: '1 min',
      tip: '🎯 Focus: Soleus (the wider chunk of your calf muscle).\n\n💡 How to do it: Focus on a deep, full stretch at the bottom (heels dropped low) and push up onto your big toes as high as mechanically possible at the top.\n\n⚠️ Common Pitfall: "Bouncy" fast partial reps. Do deliberate reps: Stretch, pause... Squeeze, pause. Control every inch of the movement for real growth.',
    ),
    Exercise(
      id: 'abs_1', name: 'Abdominal Crunch Machine', sets: '3', reps: '15-20', rest: '1 min',
      tip: '🎯 Focus: Upper and lower abs (rectus abdominis).\n\n💡 How to do it: Sit down, grab the handles, and curl your torso forward by contracting your abs — not by pulling with your arms. Exhale as you crunch, pause at peak contraction for 1 second, then slowly return.\n\n⚠️ Common Pitfall: Using your arms and hip flexors to yank the weight. Keep your arms locked in position and focus entirely on your abs doing the curling motion. Start light!',
    ),
  ];

  // Upper B (Thursday) - Back & Arms emphasis
  static const List<Exercise> upperBDay = [
    Exercise(
      id: 'pull_2', name: 'Machine Seated Row / Hammer MTS', sets: '3', reps: '8-12', rest: '2-3 min',
      tip: '🎯 Focus: Mid-back (rhomboids, traps) for "thickness".\n\n💡 How to do it: Keep back straight and chest up. Pull the handles toward your navel, squeezing shoulder blades together like cracking a walnut between them.\n\n⚠️ Common Pitfall: Rounding your lower back and yanking with your biceps. Use a controlled steady pull from your back muscles.',
    ),
    Exercise(
      id: 'pull_3', name: 'Hammer Strength MTS Front Pulldown', sets: '3', reps: '8-12', rest: '2-3 min', note: 'Replaces High Row',
      tip: '🎯 Focus: Upper back and rear shoulders (delts).\n\n💡 How to do it: Pull higher towards the upper chest, keeping elbows flared out slightly wider than a traditional lat-focused row.\n\n⚠️ Common Pitfall: Shrugging your shoulders up into your ears. Actively push your shoulders down and back during the pull.',
    ),
    Exercise(
      id: 'push_4', name: 'Machine Lateral Raise', sets: '3', reps: '10-15', rest: '1-2 min',
      tip: '🎯 Focus: Building the "cap" of your shoulder (side deltoid) for a wider look.\n\n💡 How to do it: Lock shoulder blades down and back. Lead with your elbows. Imagine pushing the pads out to the sides of the room, not up toward the ceiling.\n\n⚠️ Common Pitfall: Shrugging your shoulders up towards your ears (which over-activates the traps). Use lighter weight and maintain strict form.',
    ),
    Exercise(
      id: 'push_6', name: 'Machine Assisted Dip', sets: '3', reps: 'To Failure', rest: '1-2 min',
      tip: '🎯 Focus: Triceps and lower chest.\n\n💡 How to do it: On an assisted machine, more weight counter-balances you and makes it easier. Set it to easily get 8-10 reps with good form first.\n\n⚠️ Common Pitfall: Going too fast and using momentum. Control the negative (way up), get a full stretch at the top, and a hard squeeze at the bottom lockout.',
    ),
    Exercise(
      id: 'push_7', name: 'Machine Tricep Extension', sets: '3', reps: '10-12', rest: '1-2 min',
      tip: '🎯 Focus: Isolating the triceps (back of your arm).\n\n💡 How to do it: Pin your elbows to the table/pads. The only part of your body that should move is your forearm hinging at the elbow.\n\n⚠️ Common Pitfall: Letting your elbows flare out or using your shoulders/back to force the weight down. Lock everything in place.',
    ),
    Exercise(
      id: 'pull_6', name: 'Dumbbell Hammer Curl', sets: '3-4', reps: '12-15', rest: '1 min',
      tip: '🎯 Focus: The Brachialis (pushes bicep up) and Brachioradialis (forearm chunk).\n\n💡 How to do it: Use a neutral grip (palms facing body). Pin elbows strictly to your ribs. Curl weight toward the shoulder leading with the thumb. Grip the dumbbell tight to heavily activate the forearm. 3-seconds slow on the way down.\n\n⚠️ Common Pitfall: "The Elbow Drift". Letting elbows swing forward or outward to cheat the weight up. Drop the weight if your hips are swinging.',
    ),
    Exercise(
      id: 'abs_1', name: 'Abdominal Crunch Machine', sets: '3', reps: '15-20', rest: '1 min',
      tip: '🎯 Focus: Upper and lower abs (rectus abdominis).\n\n💡 How to do it: Sit down, grab the handles, and curl your torso forward by contracting your abs — not by pulling with your arms. Exhale as you crunch, pause at peak contraction for 1 second, then slowly return.\n\n⚠️ Common Pitfall: Using your arms and hip flexors to yank the weight. Keep your arms locked in position and focus entirely on your abs doing the curling motion. Start light!',
    ),
  ];

  // Lower B (Friday) - Hamstring & Glute Focus
  static const List<Exercise> lowerBDay = [
    Exercise(
      id: 'legs_3', name: 'Wide Stance Leg Press', sets: '4', reps: '8-10', rest: '2-3 min',
      tip: '🎯 Focus: Shifts emphasis to your glutes and inner thighs (adductors).\n\n💡 How to do it: Place feet wider than shoulders and point toes slightly outward (e.g., 11 and 1 o\'clock).\n\n⚠️ Common Pitfall: Knees caving inward as you push. Actively think about driving your knees outward so they stay in perfect alignment with your toes.',
    ),
    Exercise(
      id: 'legs_2', name: 'Seated Leg Curl Machine', sets: '3', reps: '10-12', rest: '2-3 min',
      tip: '🎯 Focus: Isolates hamstrings (back of thighs) in a lengthened position for max growth.\n\n💡 How to do it: Align knee joint perfectly with the machine\'s pivot point. Clamp the lap pad firmly against your thighs so they cannot move. Drive heels back and squeeze hard at the bottom.\n\n⚠️ Common Pitfall: If your knees can rise off the seat during the curl, the lap pad is too loose. Lock it down tight!',
    ),
    Exercise(
      id: 'legs_5', name: 'Leg Extension Machine', sets: '3', reps: '12-15', rest: '1-2 min',
      tip: '🎯 Focus: Isolating the quads (front of thighs).\n\n💡 How to do it: Line up knee joint with pivot point. Pad should lie on your lower shins. Squeeze quads hard at the top for a 1-second pause.\n\n⚠️ Common Pitfall: Swinging weight up with momentum (bad for knees). Control the movement, especially returning down. Focus on the muscle contraction rather than sheer weight.',
    ),
    Exercise(
      id: 'legs_4', name: 'Glute Kickback Machine', sets: '3', reps: '12-15', rest: '1-2 min',
      tip: '🎯 Focus: Gluteus Maximus (the main butt muscle).\n\n💡 How to do it: Chest against the pad, grip handles firmly. Core tight. Drive your heel back and up toward the ceiling. Squeeze your butt hard at the top.\n\n⚠️ Common Pitfall: Arching your lower back to get the leg higher. This turns off the glute entirely. Keep your spine perfectly neutral.',
    ),
    Exercise(
      id: 'legs_6', name: 'Machine Seated Calf Extension', sets: '4', reps: '15-20', rest: '1 min',
      tip: '🎯 Focus: Soleus (the wider chunk of your calf muscle).\n\n💡 How to do it: Focus on a deep, full stretch at the bottom (heels dropped low) and push up onto your big toes as high as mechanically possible at the top.\n\n⚠️ Common Pitfall: "Bouncy" fast partial reps. Do deliberate reps: Stretch, pause... Squeeze, pause. Control every inch of the movement for real growth.',
    ),
    Exercise(
      id: 'abs_2', name: 'Dumbbell Side Bend', sets: '3', reps: '12-15/side', rest: '1 min',
      tip: '🎯 Focus: Obliques (the muscles on the side of your abs that frame the "V").\n\n💡 How to do it: Hold one dumbbell in one hand. Stand straight, core tight. Slowly lean sideways toward the dumbbell, then contract your opposite oblique to pull yourself back upright and slightly past center. Do all reps on one side, then switch.\n\n⚠️ Common Pitfall: Holding a dumbbell in BOTH hands (this cancels out the resistance). Only hold weight in one hand. Also don\'t twist — keep the movement strictly in the side-to-side plane.',
    ),
  ];
}
