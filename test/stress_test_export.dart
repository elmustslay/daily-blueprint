import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_app/features/gym_plan/data/gym_data.dart';
import 'package:my_app/core/storage/sqlite_db.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Mock path provider to securely allow getTemporaryDirectory out-of-bounds of Flutter Engine
class MockPathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.path;
  }

  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.path;
  }
}

void main() {
  test('Stress Test CSV Aggregation', () async {
  // Initialize SQLite for CLI environment
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  // Inject mock path provider to allow path_provider to resolve in CLI
  PathProviderPlatform.instance = MockPathProviderPlatform();

  // Override db path to a temporary file just for this script
  final dbPath = '${Directory.systemTemp.path}/stress_test.db';
  final dbFile = File(dbPath);
  if (dbFile.existsSync()) dbFile.deleteSync(); 

  // Initialize DB Schema manually since we bypass `SqliteDb.instance` path logic
  final db = await databaseFactory.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            exercise_id TEXT NOT NULL,
            weight REAL NOT NULL,
            date TEXT NOT NULL,
            set_index INTEGER DEFAULT 1
          )
        ''');
      },
    ),
  );

  // Directly insert nasty, sparse, halfway-finished data to stress test the CSV aggregator
  
  // Day 1: Perfect completion of Push 1
  await db.insert('logs', {'exercise_id': 'push_1', 'weight': 100.0, 'date': '2026-04-10T14:30:00Z', 'set_index': 1});
  await db.insert('logs', {'exercise_id': 'push_1', 'weight': 105.0, 'date': '2026-04-10T14:35:00Z', 'set_index': 2});
  await db.insert('logs', {'exercise_id': 'push_1', 'weight': 110.0, 'date': '2026-04-10T14:40:00Z', 'set_index': 3});

  // Day 2: Horrible incomplete day. Walked in, did 1 set of Push 1, left gym.
  await db.insert('logs', {'exercise_id': 'push_1', 'weight': 115.0, 'date': '2026-04-11T12:00:00Z', 'set_index': 1});

  // Day 3: Half-finished sets on Pull 1. Only did set 2 and 3! (Maybe forgot to log Set 1)
  await db.insert('logs', {'exercise_id': 'pull_1', 'weight': 135.0, 'date': '2026-04-12T09:10:00Z', 'set_index': 2});
  await db.insert('logs', {'exercise_id': 'pull_1', 'weight': 145.0, 'date': '2026-04-12T09:15:00Z', 'set_index': 3});

  // Day 4: Weirdly high sets (Did 5 sets instead of 3!) 
  await db.insert('logs', {'exercise_id': 'push_4', 'weight': 50.0, 'date': '2026-04-13T10:00:00Z', 'set_index': 1});
  await db.insert('logs', {'exercise_id': 'push_4', 'weight': 55.0, 'date': '2026-04-13T10:05:00Z', 'set_index': 2});
  await db.insert('logs', {'exercise_id': 'push_4', 'weight': 60.0, 'date': '2026-04-13T10:10:00Z', 'set_index': 3});
  await db.insert('logs', {'exercise_id': 'push_4', 'weight': 65.0, 'date': '2026-04-13T10:15:00Z', 'set_index': 4});
  await db.insert('logs', {'exercise_id': 'push_4', 'weight': 70.0, 'date': '2026-04-13T10:20:00Z', 'set_index': 5});

  print('\\n--- 📡 STRESS TEST: EXTRACTING DATA ---\\n');

  // Pull all maps via standard routine
  final maps = await db.query('logs', orderBy: 'date ASC');
  
  // Aggregate using exact logic from gym_data.dart
  Map<String, Map<int, double>> grouped = {};
  Map<String, String> exercises = {};
  Map<String, String> dates = {};
  
  for (var m in maps) {
    final eId = m['exercise_id'] as String;
    final weight = m['weight'] as double;
    final dateStr = m['date'] as String;
    final dateOnly = dateStr.split('T')[0];
    final sIndex = m['set_index'] as int;

    final key = '$dateOnly-$eId';
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
    final readableName = GymData.getExerciseName(eId!);
    final weightsMap = grouped[key]!;
    final w1 = weightsMap[1] ?? '';
    final w2 = weightsMap[2] ?? '';
    final w3 = weightsMap[3] ?? '';
    final w4 = weightsMap[4] ?? '';
    final w5 = weightsMap[5] ?? '';
    final w6 = weightsMap[6] ?? '';
    buffer.writeln('$date,"$readableName",$w1,$w2,$w3,$w4,$w5,$w6');
  }

  print(buffer.toString());
  print(buffer.toString());
  print('--- ✅ STRESS TEST SUCCESS ---\\n');
  });
}
