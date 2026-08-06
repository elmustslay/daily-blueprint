import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/storage/sqlite_db.dart';

// --- Domain ---
class ExerciseLog {
  final int? id;
  final String exerciseId;
  final double weight;
  final DateTime date;
  final int setIndex;

  ExerciseLog({this.id, required this.exerciseId, required this.weight, required this.date, this.setIndex = 1});
}

class Exercise {
  final String id;
  final String name;
  final String sets;
  final String reps;
  final String rest;
  final String primaryMuscleGroup;
  final String? note;
  final String? tip;

  const Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.primaryMuscleGroup,
    this.note,
    this.tip,
  });
}

abstract class GymRepository {
  Future<void> logWeights(String exerciseId, List<double> weights, {int startIndex = 1});
  Future<List<ExerciseLog>> getLogs(String exerciseId);
  Future<double?> getMaxWeight(String exerciseId, int setIndex);
  Future<double?> getPrevWeight(String exerciseId, int setIndex);
  Future<String> exportAllTrendsCsv();
  Future<void> updateLogWeight(int id, double newWeight);
  Future<void> deleteLog(int id);
  Future<List<ExerciseLog>> getAllLogs();
}

// --- Data ---
class GymRepositoryImpl implements GymRepository {
  @override
  Future<void> logWeights(String exerciseId, List<double> weights, {int startIndex = 1}) async {
    final db = await SqliteDb.instance;
    final now = DateTime.now().toIso8601String();
    
    await db.transaction((txn) async {
      for (int i = 0; i < weights.length; i++) {
        await txn.insert('logs', {
          'exercise_id': exerciseId,
          'weight': weights[i],
          'date': now,
          'set_index': startIndex + i,
        });
      }
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
      setIndex: e['set_index'] != null ? e['set_index'] as int : 1,
    )).toList();
  }

  @override
  Future<double?> getMaxWeight(String exerciseId, int setIndex) async {
    final db = await SqliteDb.instance;
    final result = await db.rawQuery('SELECT MAX(weight) as max_w FROM logs WHERE exercise_id = ? AND set_index = ?', [exerciseId, setIndex]);
    if (result.isNotEmpty && result.first['max_w'] != null) {
      return result.first['max_w'] as double;
    }
    return null;
  }

  @override
  Future<double?> getPrevWeight(String exerciseId, int setIndex) async {
    final db = await SqliteDb.instance;
    final result = await db.query(
      'logs',
      where: 'exercise_id = ? AND set_index = ?',
      whereArgs: [exerciseId, setIndex],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['weight'] as double;
    }
    return null;
  }

  @override
  Future<String> exportAllTrendsCsv() async {
    final db = await SqliteDb.instance;
    final logs = await db.query('logs', orderBy: 'date ASC, set_index ASC');
    
    final grouped = <String, Map<int, double>>{};
    final exercises = <String, String>{}; 
    final dates = <String, String>{};
    
    for (var row in logs) {
      final dateIso = row['date'] as String;
      final eId = row['exercise_id'] as String;
      final weight = row['weight'] as double;
      final int sIndex = row['set_index'] != null ? row['set_index'] as int : 1;
      
      final dateOnly = dateIso.split('T')[0];
      final key = '$dateOnly|$eId';
      if (!grouped.containsKey(key)) {
        grouped[key] = {};
        exercises[key] = eId;
        dates[key] = dateOnly;
      }
      grouped[key]![sIndex] = weight;
    }
    
    final buffer = StringBuffer();
    buffer.writeln('Date,Exercise,Set 1 (lbs),Set 2 (lbs),Set 3 (lbs),Set 4 (lbs),Set 5 (lbs),Set 6 (lbs)');
    for (var key in grouped.keys) {
      final date = dates[key];
      final eId = exercises[key];
      final readableName = GymData.getExerciseNameWithReps(eId!);
      final weightsMap = grouped[key]!;
      final w1 = weightsMap[1] ?? '';
      final w2 = weightsMap[2] ?? '';
      final w3 = weightsMap[3] ?? '';
      final w4 = weightsMap[4] ?? '';
      final w5 = weightsMap[5] ?? '';
      final w6 = weightsMap[6] ?? '';
      buffer.writeln('$date,"$readableName",$w1,$w2,$w3,$w4,$w5,$w6');
    }
    
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/workout_trends.csv');
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  @override
  Future<void> updateLogWeight(int id, double newWeight) async {
    final db = await SqliteDb.instance;
    await db.update('logs', {'weight': newWeight}, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteLog(int id) async {
    final db = await SqliteDb.instance;
    await db.delete('logs', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<ExerciseLog>> getAllLogs() async {
    final db = await SqliteDb.instance;
    final maps = await db.query('logs', orderBy: 'date DESC');
    return maps.map((e) => ExerciseLog(
      id: e['id'] as int,
      exerciseId: e['exercise_id'] as String,
      weight: e['weight'] as double,
      date: DateTime.parse(e['date'] as String),
      setIndex: e['set_index'] != null ? e['set_index'] as int : 1,
    )).toList();
  }
}

final gymRepoProvider = Provider<GymRepository>((ref) => GymRepositoryImpl());

class GymData {
  static String getExerciseName(String id) {
    for (var list in [upperADay, lowerADay, upperBDay, lowerBDay]) {
      for (var ex in list) {
        if (ex.id == id) return ex.name;
      }
    }
    return id; // fallback
  }

  static String getExerciseNameWithReps(String id) {
    for (var list in [upperADay, lowerADay, upperBDay, lowerBDay]) {
      for (var ex in list) {
        if (ex.id == id) return '${ex.name} (${ex.reps})';
      }
    }
    return id; // fallback
  }

  static Exercise? getExerciseById(String id) {
    for (var list in [upperADay, lowerADay, upperBDay, lowerBDay]) {
      for (var ex in list) {
        if (ex.id == id) return ex;
      }
    }
    return null;
  }

  // Upper A (Monday) - Chest & Shoulder emphasis
  static const List<Exercise> upperADay = [
    Exercise(
      id: 'push_1', name: 'Hammer Strength MTS Incline Press', sets: '4', reps: '6-8', rest: '2-3 min', primaryMuscleGroup: 'Chest',
      tip: '🎯 Focus: Upper chest (clavicular head) for that "armor-plate" look.\n\n💡 How to do it: Adjust seat height so handles align near your upper chest/collarbone. Keep shoulders pinned back. The MTS allows each arm to work independently and converges inward—squeeze hard at the peak!\n\n⚠️ Common Pitfall: Letting your shoulders roll forward at the top of the press. Keep your chest up and shoulder blades bolted into the pad the entire time.',
    ),
    Exercise(
      id: 'pull_1', name: 'Lat Pulldown Machine', sets: '3', reps: '8-12', rest: '2-3 min', primaryMuscleGroup: 'Lats',
      tip: '🎯 Focus: Your lats (the "wings" on the sides of your back).\n\n💡 How to do it: Grab bar wider than shoulders. Pull down by bringing your elbows straight down to your back pockets. Pull the bar to your upper chest.\n\n⚠️ Common Pitfall: Leaning back too far to use heavy momentum. Keep torso mostly upright. Never pull behind the neck.',
    ),
    Exercise(
      id: 'push_3', name: 'Pec Deck / Machine Fly', sets: '3', reps: '8-12', rest: '1-2 min', primaryMuscleGroup: 'Chest',
      tip: '🎯 Focus: Isolation exercise to stretch and squeeze the chest.\n\n💡 How to do it: Think about bringing your elbows together, not your hands. Keep a slight, constant bend in your elbows—don\'t lock them out.\n\n⚠️ Common Pitfall: Using the front shoulders and biceps to pull the weight. Focus entirely on squeezing the chest muscles together.',
    ),
    Exercise(
      id: 'pull_4', name: 'Machine Reverse Fly / Rear Delt', sets: '3', reps: '15-20', rest: '1-2 min', primaryMuscleGroup: 'Rear Delts',
      tip: '🎯 Focus: Rear deltoids (back of shoulder).\n\n💡 How to do it: Keep weight light for the 15-20 rep range. Keep a slight but rigid bend in your elbows. Open arms wide and squeeze shoulder blades at the peak.\n\n⚠️ Common Pitfall: Bending elbows to 90 degrees making it a row. Keep arms relatively straight to isolate the small rear delt muscle.',
    ),
    Exercise(
      id: 'push_4', name: 'Machine Lateral Raise', sets: '3', reps: '10-15', rest: '1-2 min', primaryMuscleGroup: 'Side Delts',
      tip: '🎯 Focus: Building the "cap" of your shoulder (side deltoid) for a wider look and classic V-Taper.\n\n💡 How to do it: Lock shoulder blades down and back. Lead with your elbows. Imagine pushing the pads out to the sides of the room, not up toward the ceiling. Squeeze at peak contraction and control the 3-second negative.\n\n⚠️ Common Pitfall: Shrugging your shoulders up towards your ears (which over-activates the traps). Use moderate weight and maintain strict form.\n\n🔥 AESTHETIC NOTE: Never skip these! Side delts are the entire secret to an attractive, broad upper body on a 5\'7" frame. Because you are doing only 3 sets, you MUST take them to absolute, grueling failure. If you can do another rep, the set doesn\'t count.',
    ),
    Exercise(
      id: 'push_5', name: 'Tricep Pushdown/Press', sets: '3', reps: '8-12', rest: '1-2 min', primaryMuscleGroup: 'Triceps',
      tip: '🎯 Focus: The lateral and long heads of the triceps.\n\n💡 How to do it: Your brother is right! Set the seat VERY LOW so the handles are right at your shoulders (just above chest level). This gives your triceps a massive stretch at the top. Keep your chest up, pin your elbows tight to your ribs, and press straight down until your arms are fully locked.\n\n⚠️ Common Pitfall: Letting your elbows flare out to the sides or your shoulders shrug up to your ears. Keep your posture tall and elbows tucked in.',
    ),
    Exercise(
      id: 'pull_5', name: 'Machine Bicep Curl', sets: '3', reps: '10-12', rest: '1-2 min', primaryMuscleGroup: 'Biceps',
      tip: '🎯 Focus: The main "peak" of your bicep.\n\n💡 How to do it: Adjust seat so your armpit is snug against the top of the pad. Your upper arm should be completely immobilized. Squeeze hard at the peak of the curl.\n\n⚠️ Common Pitfall: Lifting elbows off the pad or rocking your shoulders. Lock your upper arm firmly against the pad at all times.',
    ),
    Exercise(
      id: 'stretch_upper_a', name: 'Post-Workout Mobility', sets: '1', reps: '5 mins', rest: 'None', primaryMuscleGroup: 'Mobility',
      tip: 'Upper Body Cool-down (Hold each for 30s-60s):\n\n1️⃣ Pec/Chest Stretch: Place forearm on a doorframe/rack at 90 degrees and lean forward until you feel a deep stretch in your chest.\n2️⃣ Lat/Back Stretch: Grab a vertical pole with one hand, sit hips back, and let it pull your arm overhead.\n3️⃣ Tricep Stretch: Reach hand behind your neck and gently pull the elbow back with your other hand.\n4️⃣ Posture Reset: Dead hang from a pull-up bar for 30-45 seconds to decompress your spine.',
    ),
  ];

  // Lower A (Wednesday) - Quad & Glute Focus
  static const List<Exercise> lowerADay = [
    Exercise(
      id: 'legs_1a', name: 'Leg Press Machine', sets: '4', reps: '6-8', rest: '2-3 min', primaryMuscleGroup: 'Quads',
      tip: '🎯 Focus: Big compound lift for quads and glutes.\n\n💡 How to do it: Place feet shoulder-width apart. As you lower the weight, aim to bring knees towards your chest. Push through the whole foot (especially the heel) to drive up.\n\n⚠️ Common Pitfall: "Butt wink" – lifting your lower back/hips off the seat at the bottom. Only go as deep as you can before your hips peel off the pad.',
    ),
    Exercise(
      id: 'legs_4a', name: 'Dumbbell Reverse Lunges', sets: '3', reps: '10-12', rest: '1-2 min', primaryMuscleGroup: 'Glutes',
      tip: '🎯 Focus: Gluteus Maximus (the main butt muscle) and Quads.\n\n💡 How to do it: Hold dumbbells at your sides. Step one foot backwards and sink your hips down until your back knee almost touches the floor. Lean your torso slightly forward to put the maximum stretch and load on your front glute. Push off the front heel to return to standing.\n\n⚠️ Common Pitfall: Pushing off the back foot. The back leg is just a kickstand; 90% of the weight should be driven up by the front heel/glute.\n\n🔥 SYMMETRY FIX: Because your right leg is 1.3 lbs heavier, ALWAYS start your set by stepping your right leg back so your LEFT (weak) leg is doing the pushing. Go to failure on the left leg, then match that exact number of reps on the right leg (even if the right leg could do more).',
    ),
    Exercise(
      id: 'legs_2a', name: 'Seated Leg Curl Machine', sets: '3', reps: '8-10', rest: '2-3 min', primaryMuscleGroup: 'Hamstrings',
      tip: '🎯 Focus: Isolates hamstrings (back of thighs) in a lengthened position for max growth.\n\n💡 How to do it: Align knee joint perfectly with the machine\'s pivot point. Clamp the lap pad firmly against your thighs so they cannot move. Drive heels back and squeeze hard at the bottom.\n\n⚠️ Common Pitfall: If your knees can rise off the seat during the curl, the lap pad is too loose. Lock it down tight!',
    ),
    Exercise(
      id: 'legs_5a', name: 'Leg Extension Machine', sets: '3', reps: '12-15', rest: '1-2 min', primaryMuscleGroup: 'Quads',
      tip: '🎯 Focus: Isolating the quads (front of thighs).\n\n💡 How to do it: Line up knee joint with pivot point. Pad should lie on your lower shins. Squeeze quads hard at the top for a 1-second pause.\n\n⚠️ Common Pitfall: Swinging weight up with momentum (bad for knees). Control the movement, especially returning down. Focus on the muscle contraction rather than sheer weight.',
    ),
    Exercise(
      id: 'legs_6a', name: 'Seated Calf Press', sets: '4', reps: '15-20', rest: '1 min', primaryMuscleGroup: 'Calves',
      tip: '🎯 Focus: Gastrocnemius and Soleus (targeting the visible "heart" shaped muscle and the deeper inner calf).\n\n💡 How to do it: Place the balls of your feet on the bottom edge of the platform/sled. Keep your legs straight with a *soft* bend in the knee (never fully locked). Let the weight push your heels down for a massive stretch and pause for 2 full seconds at the bottom. Push up onto your big toes as high as possible and squeeze for 1 second at the top.\n\n⚠️ Common Pitfall: "Bouncing" at the bottom. If you bounce, your Achilles tendon acts like a rubber band and takes the load instead of your muscles. Maintain a full range of motion and pause at the deepest stretch to ensure the calves do the work.',
    ),
    Exercise(
      id: 'abs_1_high', name: 'Abdominal Crunch Machine', sets: '3', reps: '15-20', rest: '1 min', primaryMuscleGroup: 'Abs',
      tip: '🎯 Focus: Upper and lower abs (rectus abdominis).\n\n💡 How to do it: Sit down, grab the handles, and curl your torso forward by contracting your abs — not by pulling with your arms. Exhale as you crunch, pause at peak contraction for 1 second, then slowly return.\n\n⚠️ Common Pitfall: Using your arms and hip flexors to yank the weight. Keep your arms locked in position and focus entirely on your abs doing the curling motion. Start light!',
    ),
    Exercise(
      id: 'bw_1a', name: 'Plank Hold', sets: '3', reps: '30-60 sec', rest: '1 min', primaryMuscleGroup: 'Abs',
      tip: '🎯 Focus: Deep core stability — transverse abdominis, obliques, and lower back.\n\n💡 How to do it: Rest on your forearms in a push-up position. Keep your body in a perfectly straight line from head to heels. Squeeze your glutes, brace your abs like you\'re about to get punched, and breathe steadily.\n\n⚠️ Common Pitfall: Letting your hips sag (stresses lower back) or piking them up (too easy). Your body should be one straight plank. Film yourself from the side to check.',
    ),
    Exercise(
      id: 'pull_bicep_1a', name: 'Alternating Dumbbell Curl', sets: '3', reps: '8-12', rest: '1-2 min', primaryMuscleGroup: 'Biceps',
      tip: '🎯 Focus: Biceps (filling out t-shirt sleeves).\n\n💡 How to do it: Stand with dumbbells. Curl one arm up, twisting your wrist so your pinky turns toward your shoulder at the peak. Lower under control, then alternate.\n\n⚠️ Common Pitfall: Swinging your torso or letting your elbows drift forward. Keep your elbows pinned strictly to your sides.',
    ),
    Exercise(
      id: 'stretch_lower_a', name: 'Post-Workout Mobility', sets: '1', reps: '5 mins', rest: 'None', primaryMuscleGroup: 'Mobility',
      tip: 'Lower Body Cool-down (Hold each for 30s-60s):\n\n1️⃣ Hip Flexor Lunge: Kneel on one knee, squeeze the glute on the grounded leg, and push hips forward.\n2️⃣ Hamstring Stretch: Put foot on a low bench and gently hinge forward at the hips with a flat back.\n3️⃣ Couch Stretch (Quads): Put shin against a wall/bench, knee on the floor, and sit upright.\n4️⃣ Calf/Ankle Mobilization: Stand on a ledge, let heels drop deep, and hold the stretch to prevent Achilles tightness.',
    ),
  ];

  // Upper B (Thursday) - Back & Arms emphasis
  static const List<Exercise> upperBDay = [
    Exercise(
      id: 'pull_3', name: 'Hammer Strength MTS Front Pulldown', sets: '3', reps: '8-12', rest: '2-3 min', primaryMuscleGroup: 'Lats',
      tip: '🎯 Focus: Upper back and rear shoulders (delts).\n\n💡 How to do it: Pull higher towards the upper chest, keeping elbows flared out slightly wider than a traditional lat-focused row.\n\n⚠️ Common Pitfall: Shrugging your shoulders up into your ears. Actively push your shoulders down and back during the pull.',
    ),
    Exercise(
      id: 'push_6', name: 'Machine Assisted Dip', sets: '3', reps: '10-12', rest: '1-2 min', primaryMuscleGroup: 'Triceps',
      tip: '🎯 Focus: Triceps and lower chest.\n\n💡 How to do it: Adjust the counter-weight so that you reach failure between 8-12 reps. Remember, less weight on the machine makes it harder, as you are lifting more of your body weight.\n\n⚠️ Common Pitfall: Going too fast and using momentum. Control the negative (way down), get a full stretch at the bottom, and a hard squeeze at the top lockout.',
    ),
    Exercise(
      id: 'pull_2', name: 'Machine Seated Row', sets: '3', reps: '8-12', rest: '2-3 min', primaryMuscleGroup: 'Mid-Back',
      tip: '🎯 Focus: Lats and Mid-back for V-taper width and back thickness.\n\n💡 How to do it: Adjust the chest pad so you get a deep stretch when reaching for the handles. Keep your chest firmly glued to the pad. Drive your elbows straight back and down toward your hips (think of your hands as just hooks).\n\n⚠️ Common Pitfall: Pulling your chest off the pad to use momentum, or shrugging your shoulders up. Keep shoulders pinned down and torso completely frozen against the pad.',
    ),
    Exercise(
      id: 'push_4', name: 'Machine Lateral Raise', sets: '3', reps: '10-15', rest: '1-2 min', primaryMuscleGroup: 'Side Delts',
      tip: '🎯 Focus: Building the "cap" of your shoulder (side deltoid) for a wider look.\n\n💡 How to do it: Lock shoulder blades down and back. Lead with your elbows. Imagine pushing the pads out to the sides of the room, not up toward the ceiling.\n\n⚠️ Common Pitfall: Shrugging your shoulders up towards your ears (which over-activates the traps). Use lighter weight and maintain strict form.\n\n🔥 AESTHETIC NOTE: Never skip these! Side delts are the entire secret to an attractive, broad upper body on a 5\'7" frame. Because you are doing only 3 sets, you MUST take them to absolute, grueling failure. If you can do another rep, the set doesn\'t count.\n\n💡 Machine Choice: Can be done on both Upper A and Upper B for superior constant-tension isolation.',
    ),
    Exercise(
      id: 'push_7', name: 'Machine Tricep Extension', sets: '3', reps: '10-12', rest: '1-2 min', primaryMuscleGroup: 'Triceps',
      tip: '🎯 Focus: Isolating the triceps (back of your arm).\n\n💡 How to do it: Pin your elbows to the table/pads. The only part of your body that should move is your forearm hinging at the elbow.\n\n⚠️ Common Pitfall: Letting your elbows flare out or using your shoulders/back to force the weight down. Lock everything in place.',
    ),
    Exercise(
      id: 'pull_6', name: 'Dumbbell Hammer Curl', sets: '3-4', reps: '12-15', rest: '1 min', primaryMuscleGroup: 'Biceps',
      tip: '🎯 Focus: The Brachialis (pushes bicep up) and Brachioradialis (forearm chunk).\n\n💡 How to do it: Use a neutral grip (palms facing body). Pin elbows strictly to your ribs. Curl weight toward the shoulder leading with the thumb. Grip the dumbbell tight to heavily activate the forearm. 3-seconds slow on the way down.\n\n⚠️ Common Pitfall: "The Elbow Drift". Letting elbows swing forward or outward to cheat the weight up. Drop the weight if your hips are swinging.',
    ),
    Exercise(
      id: 'stretch_upper_b', name: 'Post-Workout Mobility', sets: '1', reps: '5 mins', rest: 'None', primaryMuscleGroup: 'Mobility',
      tip: 'Upper Body Cool-down (Hold each for 30s-60s):\n\n1️⃣ Pec/Chest Stretch: Place forearm on a doorframe/rack at 90 degrees and lean forward until you feel a deep stretch in your chest.\n2️⃣ Lat/Back Stretch: Grab a vertical pole with one hand, sit hips back, and let it pull your arm overhead.\n3️⃣ Tricep Stretch: Reach hand behind your neck and gently pull the elbow back with your other hand.\n4️⃣ Posture Reset: Dead hang from a pull-up bar for 30-45 seconds to decompress your spine.',
    ),
  ];

  // Lower B (Friday) - Hamstring & Glute Focus
  static const List<Exercise> lowerBDay = [
    Exercise(
      id: 'legs_7b', name: 'Dumbbell Romanian Deadlift', sets: '3', reps: '8-10', rest: '2-3 min', primaryMuscleGroup: 'Hamstrings',
      tip: '🎯 Focus: Glutes and hamstrings through a hip hinge — the #1 movement pattern for building a great butt.\n\n💡 How to do it: Hold dumbbells in front of your thighs with a neutral grip. Stand with feet hip-width apart. Push your hips BACK (not down) like you\'re closing a car door with your butt. Keep the dumbbells gliding along your legs. Lower until you feel a deep stretch in your hamstrings (roughly mid-shin). Drive your hips forward to stand up, squeezing your glutes hard at the top.\n\n⚠️ Common Pitfall: Rounding your lower back — this is dangerous. Keep your chest proud, shoulders back, and maintain a slight arch in your lower back the entire time. If your back rounds, the weight is too heavy or you\'re going too deep.',
    ),
    Exercise(
      id: 'legs_3b', name: 'Wide Stance Leg Press', sets: '4', reps: '8-10', rest: '2-3 min', primaryMuscleGroup: 'Glutes',
      tip: '🎯 Focus: Shifts emphasis to your glutes and inner thighs (adductors).\n\n💡 How to do it (seat 3, high feet placement): Place feet wider than shoulders and point toes slightly outward (e.g., 11 and 1 o\'clock).\n\n⚠️ Common Pitfall: Knees caving inward as you push. Actively think about driving your knees outward so they stay in perfect alignment with your toes.',
    ),
     Exercise(
      id: 'legs_2b', name: 'Seated Leg Curl Machine', sets: '3', reps: '10-12', rest: '2-3 min', primaryMuscleGroup: 'Hamstrings',
      tip: '🎯 Focus: Isolates hamstrings (back of thighs) in a lengthened position for max growth.\n\n💡 How to do it (2-3 tight, 4max pad angle, 2 metal angle/marsh, 3 back angle): Align knee joint perfectly with the machine\'s pivot point. Clamp the lap pad firmly against your thighs so they cannot move. Drive heels back and squeeze hard at the bottom.\n\n⚠️ Common Pitfall: If your knees can rise off the seat during the curl, the lap pad is too loose. Lock it down tight!',
    ),
    Exercise(
      id: 'legs_4b', name: 'Floor Glute Bridges', sets: '3', reps: '10-15', rest: '1-2 min', primaryMuscleGroup: 'Glutes',
      tip: '🎯 Focus: Gluteus Maximus (the main butt muscle).\n\n💡 How to do it: Lie flat on your back, knees bent, feet flat on the floor (as far possible from butt -- think 90 deg) shoulder-width apart. Rest a heavy dumbbell or barbell across your hip crease. Drive through your heels to thrust your hips straight up into the air. Squeeze your glutes at the absolute top for a full 1-2 seconds.\n\n⚠️ Common Pitfall: Hyperextending your lower back. Your ribs should stay tucked down. The movement comes entirely from squeezing the glutes, not arching your spine.',
    ),
    Exercise(
      id: 'legs_5b', name: 'Leg Extension Machine', sets: '3', reps: '12-15', rest: '1-2 min', primaryMuscleGroup: 'Quads',
      tip: '🎯 Focus: Isolating the quads (front of thighs).\n\n💡 How to do it: Line up knee joint with pivot point. Pad should lie on your lower shins. Squeeze quads hard at the top for a 1-second pause.\n\n⚠️ Common Pitfall: Swinging weight up with momentum (bad for knees). Control the movement, especially returning down. Focus on the muscle contraction rather than sheer weight.',
    ),
    Exercise(
      id: 'legs_6b', name: 'Seated Calf Press', sets: '4', reps: '15-20', rest: '1 min', primaryMuscleGroup: 'Calves',
      tip: '🎯 Focus: Gastrocnemius and Soleus (targeting the visible "heart" shaped muscle and the deeper inner calf).\n\n💡 How to do it (at 6, with 4 visible): Place the balls of your feet on the bottom edge of the platform/sled. Keep your legs straight with a *soft* bend in the knee (never fully locked). Let the weight push your heels down for a massive stretch and pause for 2 full seconds at the bottom. Push up onto your big toes as high as possible and squeeze for 1 second at the top.\n\n⚠️ Common Pitfall: "Bouncing" at the bottom. If you bounce, your Achilles tendon acts like a rubber band and takes the load instead of your muscles. Maintain a full range of motion and pause at the deepest stretch to ensure the calves do the work.',
    ),
    Exercise(
      id: 'abs_2b', name: 'Bicycle Crunches', sets: '2', reps: '15-20/side', rest: '1 min', primaryMuscleGroup: 'Abs',
      tip: '🎯 Focus: Obliques and overall core definition without widening the waist.\n\n💡 How to do it: Keep your lower back pressed firmly into the floor. Bring your opposite elbow to your opposite knee, fully extending the other leg straight out. Move slowly and control the twist.\n\n⚠️ Common Pitfall: Pulling on your neck or rushing through the reps. The slower you twist, the harder the obliques have to work to stabilize you.',
    ),
    Exercise(
      id: 'bw_1c', name: 'Plank Hold', sets: '3', reps: '30-60 sec', rest: '1 min', primaryMuscleGroup: 'Abs',
      tip: '🎯 Focus: Deep core stability — transverse abdominis, obliques, and lower back.\n\n💡 How to do it: Rest on your forearms in a push-up position. Keep your body in a perfectly straight line from head to heels. Squeeze your glutes, brace your abs like you\'re about to get punched, and breathe steadily.\n\n⚠️ Common Pitfall: Letting your hips sag (stresses lower back) or piking them up (too easy). Your body should be one straight plank. Film yourself from the side to check.',
    ),
    Exercise(
      id: 'stretch_lower_b', name: 'Post-Workout Mobility', sets: '1', reps: '5 mins', rest: 'None', primaryMuscleGroup: 'Mobility',
      tip: 'Lower Body Cool-down (Hold each for 30s-60s):\n\n1️⃣ Hip Flexor Lunge: Kneel on one knee, squeeze the glute on the grounded leg, and push hips forward.\n2️⃣ Hamstring Stretch: Put foot on a low bench and gently hinge forward at the hips with a flat back.\n3️⃣ Couch Stretch (Quads): Put shin against a wall/bench, knee on the floor, and sit upright.\n4️⃣ Calf/Ankle Mobilization: Stand on a ledge, let heels drop deep, and hold the stretch to prevent Achilles tightness.',
    ),
  ];
}
