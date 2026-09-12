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
    String query = 'SELECT MAX(weight) as max_w FROM logs WHERE exercise_id = ? AND set_index = ?';
    if (exerciseId == 'legs_1a') {
      query += " AND date > '2026-09-07'";
    }
    final result = await db.rawQuery(query, [exerciseId, setIndex]);
    if (result.isNotEmpty && result.first['max_w'] != null) {
      return result.first['max_w'] as double;
    }
    return null;
  }

  @override
  Future<double?> getPrevWeight(String exerciseId, int setIndex) async {
    final db = await SqliteDb.instance;
    String whereClause = 'exercise_id = ? AND set_index = ?';
    if (exerciseId == 'legs_1a') {
      whereClause += " AND date > '2026-09-07'";
    }
    final result = await db.query(
      'logs',
      where: whereClause,
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
      id: 'push_1', name: 'Hammer Strength MTS Incline Press', sets: '4', reps: '6-8', rest: '3 min', primaryMuscleGroup: 'Chest',
      tip: '🎯 Focus: Upper chest (clavicular head) for that "armor-plate" look.\n\n💡 How to do it: Adjust seat height so handles align near your upper chest/collarbone.\n\n🔒 NON-NEGOTIABLE: Ass planted firmly in the deepest crease of the seat. Shoulder blades retracted (pinched together) and bolted to the back pad. (A slight lower back arch is completely fine and actually helps anchor you).\n\n⚠️ Common Pitfall: Lifting your butt off the seat (which flattens the angle and turns it into a flat press, ignoring upper chest) or letting your shoulders peel forward off the pad (which shifts the tension entirely to your front deltoids).',
    ),
    Exercise(
      id: 'pull_1', name: 'Lat Pulldown Machine', sets: '3', reps: '8-12', rest: '3 min', primaryMuscleGroup: 'Lats',
      tip: '🎯 Focus: Your lats (the "wings" on the sides of your back).\n\n💡 How to do it: Grab bar wider than shoulders. Pull elbows straight down to your back pockets.\n\n🔒 NON-NEGOTIABLE: Thighs locked firmly under the pads so you cannot lift off the seat. Torso angle remains rigidly locked.\n\n⚠️ Common Pitfall: Leaning your torso way back horizontally as you pull. You are just using your body weight falling backward to move the bar, turning off the lats entirely.',
    ),
    Exercise(
      id: 'push_3', name: 'Pec Deck / Machine Fly', sets: '3', reps: '8-12', rest: '2 min', primaryMuscleGroup: 'Chest',
      tip: '🎯 Focus: Isolation exercise to stretch and squeeze the chest.\n\n💡 How to do it: Think about bringing your elbows together, not your hands.\n\n🔒 NON-NEGOTIABLE: Back flat against the pad. Elbow bend stays at the exact same slight angle for the entire rep.\n\n⚠️ Common Pitfall: Bending your elbows more as you bring your hands together. If the elbow angle changes, you are pressing the weight with your triceps and front shoulders instead of flying it with your chest.',
    ),
    Exercise(
      id: 'pull_4', name: 'Machine Reverse Fly / Rear Delt', sets: '3', reps: '15-20', rest: '2 min', primaryMuscleGroup: 'Rear Delts',
      tip: '🎯 Focus: Rear deltoids (back of shoulder).\n\n💡 How to do it: Keep weight light. Open arms wide and squeeze shoulder blades.\n\n🔒 NON-NEGOTIABLE: Chest physically glued to the pad. Arms remain mostly straight.\n\n⚠️ Common Pitfall: Bending your elbows to 90 degrees and pulling straight back. This mechanically turns it into a mid-back row. It feels much easier, but it completely bypasses the tiny rear delt muscle you are trying to isolate.',
    ),
    Exercise(
      id: 'push_4', name: 'Machine Lateral Raise', sets: '3', reps: '10-15', rest: '2 min', primaryMuscleGroup: 'Side Delts',
      tip: '🎯 Focus: Building the "cap" of your shoulder (side deltoid) for a wider look.\n\n💡 How to do it: Lead with elbows, push pads out to the sides.\n\n🔒 NON-NEGOTIABLE: Shoulders pressed DOWN, actively pushed away from your ears.\n\n⚠️ Common Pitfall: Shrugging your traps up toward your ears to lift the weight. The weight will go up, but your side delts will do zero work.\n\n🔥 AESTHETIC NOTE: Because you do only 3 sets, you MUST take them to absolute, grueling failure. If you can do another rep, it doesn\'t count.',
    ),
    Exercise(
      id: 'push_5', name: 'Tricep Pushdown/Press', sets: '3', reps: '8-12', rest: '2 min', primaryMuscleGroup: 'Triceps',
      tip: '🎯 Focus: The lateral and long heads of the triceps.\n\n💡 How to do it: Set seat VERY LOW so handles are right at shoulders. Press straight down.\n\n🔒 NON-NEGOTIABLE: Elbows physically pinned tightly against your ribcage. ONLY the forearms move.\n\n⚠️ Common Pitfall: Letting your elbows flare outward or drift forward away from your ribs. Once the elbow leaves the torso, the chest and front shoulders take over the pressing motion.',
    ),
    Exercise(
      id: 'pull_5', name: 'Machine Bicep Curl', sets: '3', reps: '10-12', rest: '2 min', primaryMuscleGroup: 'Biceps',
      tip: '🎯 Focus: The main "peak" of your bicep.\n\n💡 How to do it: Squeeze hard at the peak of the curl.\n\n🔒 NON-NEGOTIABLE: Armpit wedged snug over the top edge of the pad. Triceps remain totally flat against the pad at all times.\n\n⚠️ Common Pitfall: Lifting your elbows off the pad or leaning your torso back to use body leverage to hoist the weight up.',
    ),
    Exercise(
      id: 'stretch_upper_a', name: 'Post-Workout Mobility', sets: '1', reps: '5 mins', rest: 'None', primaryMuscleGroup: 'Mobility',
      tip: 'Upper Body Cool-down (Hold each for 30s-60s):\n\n1️⃣ Pec/Chest Stretch: Place forearm on a doorframe/rack at 90 degrees and lean forward until you feel a deep stretch in your chest.\n2️⃣ Lat/Back Stretch: Grab a vertical pole with one hand, sit hips back, and let it pull your arm overhead.\n3️⃣ Tricep Stretch: Reach hand behind your neck and gently pull the elbow back with your other hand.\n4️⃣ Posture Reset: Dead hang from a pull-up bar for 30-45 seconds to decompress your spine.',
    ),
  ];

  // Lower A (Wednesday) - Quad & Glute Focus
  static const List<Exercise> lowerADay = [
    Exercise(
      id: 'legs_1a', name: 'Leg Press Machine', sets: '4', reps: '6-8', rest: '3 min', primaryMuscleGroup: 'Quads',
      tip: '🎯 Focus: Big compound lift for quads and glutes.\n\n💡 How to do it: Try seat 3. Place feet shoulder-width apart.\n\n🔒 NON-NEGOTIABLE: Butt forcefully planted deeply into the bottom crease of the seat throughout the entire rep.\n\n⚠️ Common Pitfall: "Butt wink". If you go so deep that your lower back rounds and your butt peels off the seat, hundreds of pounds of tension transfer instantly from your leg muscles directly onto your lumbar spine discs.',
    ),
    Exercise(
      id: 'legs_4a', name: 'Dumbbell Reverse Lunges', sets: '3', reps: '10-12', rest: '3 min', primaryMuscleGroup: 'Glutes',
      tip: '🎯 Focus: Gluteus Maximus and Quads.\n\n💡 How to do it: Step back, sink hips down. Lean torso slightly forward.\n\n🔒 NON-NEGOTIABLE: 90% of the weight and pushing force must go through the front foot\'s heel.\n\n⚠️ Common Pitfall: Pushing off the back toe to stand up. The back foot is strictly a kickstand for balance. Pushing with it ruins the glute isolation for the working front leg.\n\n🔥 SYMMETRY FIX: ALWAYS start by stepping right leg back so LEFT (weak) leg pushes first. Go to failure, then match that exact number on the right leg.',
    ),
    Exercise(
      id: 'legs_2a', name: 'Seated Leg Curl Machine', sets: '3', reps: '8-10', rest: '2 min', primaryMuscleGroup: 'Hamstrings',
      tip: '🎯 Focus: Isolates hamstrings in a lengthened position.\n\n💡 How to do it: Align knee joint with pivot point.\n\n🔒 NON-NEGOTIABLE: Lap pad must be cranked down painfully tight so your thighs cannot move 1 single millimeter.\n\n⚠️ Common Pitfall: Hips sliding forward or butt lifting up off the seat. If you aren\'t bolted down, your body uses hip leverage and the lower back to cheat the weight down.',
    ),
    Exercise(
      id: 'legs_5a', name: 'Leg Extension Machine', sets: '3', reps: '12-15', rest: '2 min', primaryMuscleGroup: 'Quads',
      tip: '🎯 Focus: Isolating the quads (front of thighs).\n\n💡 How to do it: Set it to 2. Pad on lower shins.\n\n🔒 NON-NEGOTIABLE: Butt fully back in the seat. You must be able to hold a dead-stop 1-second pause at the absolute top of the rep.\n\n⚠️ Common Pitfall: Kicking the weight up with sheer momentum and dropping it. If you can\'t pause at the top, your quads aren\'t lifting the load; momentum is.',
    ),
    Exercise(
      id: 'legs_6a', name: 'Seated Calf Press', sets: '4', reps: '15-20', rest: '2 min', primaryMuscleGroup: 'Calves',
      tip: '🎯 Focus: Gastrocnemius and Soleus.\n\n💡 How to do it: Try seat 4. Balls of feet on bottom edge. Soft knee bend.\n\n🔒 NON-NEGOTIABLE: A full 2-second dead-stop pause at the absolute deepest stretch at the bottom of EVERY rep.\n\n⚠️ Common Pitfall: Bouncing at the bottom. Your Achilles tendon acts like a giant rubber band. If you bounce, the tendon reflects the weight back up, making the exercise feel easier because the calf muscle is literally bypassed.',
    ),
    Exercise(
      id: 'abs_1_high', name: 'Abdominal Crunch Machine', sets: '3', reps: '15-20', rest: '2 min', primaryMuscleGroup: 'Abs',
      tip: '🎯 Focus: Upper and lower abs.\n\n💡 How to do it: Sit down, grab handles.\n\n🔒 NON-NEGOTIABLE: Your spine must actually physically round (curl) forward.\n\n⚠️ Common Pitfall: Keeping your back totally straight and hinging at the hips while yanking the handles with your arms. This works your hip flexors and lats, doing zero for your abs.',
    ),
    Exercise(
      id: 'bw_1a', name: 'Plank Hold', sets: '3', reps: '30-60 sec', rest: '2 min', primaryMuscleGroup: 'Abs',
      tip: '🎯 Focus: Deep core stability.\n\n💡 How to do it: Forearms down.\n\n🔒 NON-NEGOTIABLE: Glutes forcefully squeezed. Body in a perfectly straight line from head to heel.\n\n⚠️ Common Pitfall: Piking your hips high up into the air. This vertically stacks your skeleton against gravity, giving your core muscles a rest break and making the plank useless.',
    ),
    Exercise(
      id: 'pull_bicep_1a', name: 'Alternating Dumbbell Curl', sets: '3', reps: '8-12', rest: '2 min', primaryMuscleGroup: 'Biceps',
      tip: '🎯 Focus: Biceps.\n\n💡 How to do it: Twist wrist so pinky turns to shoulder at peak.\n\n🔒 NON-NEGOTIABLE: Elbows physically bolted to the sides of your ribcage.\n\n⚠️ Common Pitfall: "Elbow Drift". If your elbow swings forward in front of your ribs, your front shoulder is lifting the weight, completely removing tension from the bicep.',
    ),
    Exercise(
      id: 'stretch_lower_a', name: 'Post-Workout Mobility', sets: '1', reps: '5 mins', rest: 'None', primaryMuscleGroup: 'Mobility',
      tip: 'Lower Body Cool-down (Hold each for 30s-60s):\n\n1️⃣ Hip Flexor Lunge: Kneel on one knee, squeeze the glute on the grounded leg, and push hips forward.\n2️⃣ Hamstring Stretch: Put foot on a low bench and gently hinge forward at the hips with a flat back.\n3️⃣ Couch Stretch (Quads): Put shin against a wall/bench, knee on the floor, and sit upright.\n4️⃣ Calf/Ankle Mobilization: Stand on a ledge, let heels drop deep, and hold the stretch to prevent Achilles tightness.',
    ),
  ];

  // Upper B (Thursday) - Back & Arms emphasis
  static const List<Exercise> upperBDay = [
    Exercise(
      id: 'pull_3', name: 'Hammer Strength MTS Front Pulldown', sets: '3', reps: '8-12', rest: '3 min', primaryMuscleGroup: 'Lats',
      tip: '🎯 Focus: Upper back and rear shoulders.\n\n💡 How to do it: Pull higher towards the upper chest, elbows flared.\n\n🔒 NON-NEGOTIABLE: Shoulders actively pushed DOWN during the pull.\n\n⚠️ Common Pitfall: Shrugging your shoulders up into your ears. This shifts the workload onto your upper traps and neck, defeating the back-building purpose.',
    ),
    Exercise(
      id: 'push_6', name: 'Machine Assisted Dip', sets: '3', reps: '10-12', rest: '3 min', primaryMuscleGroup: 'Triceps',
      tip: '🎯 Focus: Triceps and lower chest.\n\n💡 How to do it: Less weight on machine = harder.\n\n🔒 NON-NEGOTIABLE: A slow, controlled 3-second descent on the way down.\n\n⚠️ Common Pitfall: Dropping down too fast and bouncing out of the bottom. Bouncing skips the stretching/eccentric phase entirely (which is what builds muscle) and wrecks your shoulder joints.',
    ),
    Exercise(
      id: 'pull_2', name: 'Machine Seated Row', sets: '3', reps: '8-12', rest: '3 min', primaryMuscleGroup: 'Mid-Back',
      tip: '🎯 Focus: Lats and Mid-back thickness.\n\n💡 How to do it: Drive elbows straight back.\n\n🔒 NON-NEGOTIABLE: Chest bolted firmly against the chest pad at all times.\n\n⚠️ Common Pitfall: Peeling your chest backward off the pad to lean back as you pull. This turns the movement into a lower-back extension. The weight will feel lighter, but your mid-back stops doing the work.',
    ),
    Exercise(
      id: 'push_4', name: 'Machine Lateral Raise', sets: '3', reps: '10-15', rest: '2 min', primaryMuscleGroup: 'Side Delts',
      tip: '🎯 Focus: Building the "cap" of your shoulder.\n\n💡 How to do it: Lead with elbows, push pads out to the sides.\n\n🔒 NON-NEGOTIABLE: Shoulders pressed DOWN away from ears.\n\n⚠️ Common Pitfall: Shrugging traps up to lift the weight. The weight goes up, but side delts do zero work.\n\n🔥 AESTHETIC NOTE: Never skip these! Take them to absolute failure.',
    ),
    Exercise(
      id: 'push_7', name: 'Machine Tricep Extension', sets: '3', reps: '10-12', rest: '2 min', primaryMuscleGroup: 'Triceps',
      tip: '🎯 Focus: Isolating the triceps.\n\n💡 How to do it: Only the forearm moves.\n\n🔒 NON-NEGOTIABLE: Elbows stay glued absolutely perfectly to the arm pads.\n\n⚠️ Common Pitfall: Letting your elbows slide forward on the pad, or leaning your whole torso down onto the handles to push. This recruits back and shoulder muscles, negating tricep isolation.',
    ),
    Exercise(
      id: 'pull_6', name: 'Dumbbell Hammer Curl', sets: '3-4', reps: '12-15', rest: '2 min', primaryMuscleGroup: 'Biceps',
      tip: '🎯 Focus: Brachialis and Brachioradialis (forearm).\n\n💡 How to do it: Neutral grip. Curl toward shoulder.\n\n🔒 NON-NEGOTIABLE: Elbows bolted to your ribs. Torso perfectly still.\n\n⚠️ Common Pitfall: Swinging your elbows forward to cheat the weight up using front deltoids. If the elbow leaves the ribcage, the rep is essentially useless.',
    ),
    Exercise(
      id: 'stretch_upper_a', name: 'Post-Workout Mobility', sets: '1', reps: '5 mins', rest: 'None', primaryMuscleGroup: 'Mobility',
      tip: 'Upper Body Cool-down (Hold each for 30s-60s):\n\n1️⃣ Pec/Chest Stretch: Place forearm on a doorframe/rack at 90 degrees and lean forward until you feel a deep stretch in your chest.\n2️⃣ Lat/Back Stretch: Grab a vertical pole with one hand, sit hips back, and let it pull your arm overhead.\n3️⃣ Tricep Stretch: Reach hand behind your neck and gently pull the elbow back with your other hand.\n4️⃣ Posture Reset: Dead hang from a pull-up bar for 30-45 seconds to decompress your spine.',
    ),
  ];

  // Lower B (Friday) - Hamstring & Glute Focus
  static const List<Exercise> lowerBDay = [
    Exercise(
      id: 'legs_7b', name: 'Dumbbell Romanian Deadlift', sets: '3', reps: '8-10', rest: '3 min', primaryMuscleGroup: 'Hamstrings',
      tip: '🎯 Focus: Glutes and hamstrings via hip hinge.\n\n💡 How to do it: Keep dumbbells gliding against legs.\n\n🔒 NON-NEGOTIABLE: Shins stay mostly vertical. Hips must travel straight BACKWARD.\n\n⚠️ Common Pitfall: Bending at the waist and rounding the lower back instead of pushing the hips back. This shifts the mechanical tension entirely off the hamstrings and puts dangerous sheer force directly onto your spine.',
    ),
    Exercise(
      id: 'legs_3b', name: 'Wide Stance Leg Press', sets: '4', reps: '8-10', rest: '3 min', primaryMuscleGroup: 'Glutes',
      tip: '🎯 Focus: Glutes and inner thighs.\n\n💡 How to do it (seat 3, high feet): Feet wider than shoulders, toes out.\n\n🔒 NON-NEGOTIABLE: Butt firmly planted in the seat crease. Knees must track actively outward over your toes.\n\n⚠️ Common Pitfall: Letting your knees cave inward toward each other as you push up. This takes the muscular load off the glutes/adductors and places severe, unhealthy stress on the knee ligaments.',
    ),
     Exercise(
      id: 'legs_2b', name: 'Seated Leg Curl Machine', sets: '3', reps: '10-12', rest: '2 min', primaryMuscleGroup: 'Hamstrings',
      tip: '🎯 Focus: Isolates hamstrings in a lengthened position.\n\n💡 How to do it (2-3 tight, 4max pad, 2 metal, 3 back):\n\n🔒 NON-NEGOTIABLE: Lap pad cranked down completely tight. Thighs immobilized.\n\n⚠️ Common Pitfall: Sitting forward or leaning away from the back pad to gain leverage. If the pad doesn\'t lock your legs down perfectly, your body uses hip flexors to cheat the weight.',
    ),
    Exercise(
      id: 'legs_4b', name: 'Floor Glute Bridges', sets: '3', reps: '10-15', rest: '2 min', primaryMuscleGroup: 'Glutes',
      tip: '🎯 Focus: Gluteus Maximus.\n\n💡 How to do it: Lie flat, knees bent, feet 90 deg. Drive through heels.\n\n🔒 NON-NEGOTIABLE: Ribs kept tucked down. Lift comes 100% from squeezing the glutes.\n\n⚠️ Common Pitfall: Arching your lower back (hyperextending) to get your hips higher. This does absolutely zero extra work for your butt, but severely risks lumbar spine injury.',
    ),
    Exercise(
      id: 'legs_5a', name: 'Leg Extension Machine', sets: '3', reps: '12-15', rest: '2 min', primaryMuscleGroup: 'Quads',
      tip: '🎯 Focus: Isolating the quads.\n\n💡 How to do it: Set to 2.\n\n🔒 NON-NEGOTIABLE: Butt fully back in seat. Dead-stop 1-second pause/squeeze at the top.\n\n⚠️ Common Pitfall: Relying on momentum to swing the weight up. If you cannot pause at the top of the rep, the weight is too heavy.',
    ),
    Exercise(
      id: 'legs_6a', name: 'Seated Calf Press', sets: '4', reps: '15-20', rest: '2 min', primaryMuscleGroup: 'Calves',
      tip: '🎯 Focus: Gastrocnemius and Soleus.\n\n💡 How to do it (at 6, 4 visible): Balls of feet on bottom edge.\n\n🔒 NON-NEGOTIABLE: A full 2-second dead-stop pause at the absolute deepest stretch at the bottom of EVERY rep.\n\n⚠️ Common Pitfall: Bouncing at the bottom. The Achilles tendon recoils the weight back up, meaning the calf muscle is literally bypassed and does no work.',
    ),
    Exercise(
      id: 'abs_2b', name: 'Bicycle Crunches', sets: '2', reps: '15-20/side', rest: '2 min', primaryMuscleGroup: 'Abs',
      tip: '🎯 Focus: Obliques and core definition.\n\n💡 How to do it: Opposite elbow to opposite knee.\n\n🔒 NON-NEGOTIABLE: Shoulder blades physically leaving the floor to twist.\n\n⚠️ Common Pitfall: Speeding through reps and just flapping your elbows back and forth while your back stays flat on the ground. If the torso doesn\'t rotate upward, the oblique isn\'t engaged.',
    ),
    Exercise(
      id: 'bw_1a', name: 'Plank Hold', sets: '3', reps: '30-60 sec', rest: '2 min', primaryMuscleGroup: 'Abs',
      tip: '🎯 Focus: Deep core stability.\n\n💡 How to do it: Forearms down.\n\n🔒 NON-NEGOTIABLE: Glutes forcefully squeezed. Straight line head to heel.\n\n⚠️ Common Pitfall: Letting your hips sag toward the floor. This completely disengages the abdominal wall and dumps all the structural stress onto your lower back ligaments.',
    ),
    Exercise(
      id: 'stretch_lower_a', name: 'Post-Workout Mobility', sets: '1', reps: '5 mins', rest: 'None', primaryMuscleGroup: 'Mobility',
      tip: 'Lower Body Cool-down (Hold each for 30s-60s):\n\n1️⃣ Hip Flexor Lunge: Kneel on one knee, squeeze the glute on the grounded leg, and push hips forward.\n2️⃣ Hamstring Stretch: Put foot on a low bench and gently hinge forward at the hips with a flat back.\n3️⃣ Couch Stretch (Quads): Put shin against a wall/bench, knee on the floor, and sit upright.\n4️⃣ Calf/Ankle Mobilization: Stand on a ledge, let heels drop deep, and hold the stretch to prevent Achilles tightness.',
    ),
  ];
}
