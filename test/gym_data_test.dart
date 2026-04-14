import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:my_app/features/gym_plan/data/gym_data.dart';
import 'package:my_app/core/storage/sqlite_db.dart';

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
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    PathProviderPlatform.instance = MockPathProviderPlatform();
    final db = await SqliteDb.instance;
    await db.delete('logs');
  });

  test('logWeights correctly inserts multiple sets sequentially', () async {
    final repo = GymRepositoryImpl();
    
    await repo.logWeights('push_1', [100.0, 105.0, 110.0], startIndex: 1);
    
    final logs = await repo.getLogs('push_1');
    expect(logs.length, 3);
    
    expect(logs[0].setIndex, 1);
    expect(logs[0].weight, 100.0);
    
    expect(logs[1].setIndex, 2);
    expect(logs[1].weight, 105.0);
    
    expect(logs[2].setIndex, 3);
    expect(logs[2].weight, 110.0);
    
    final maxSet1 = await repo.getMaxWeight('push_1', 1);
    expect(maxSet1, 100.0);
    
    final maxSet2 = await repo.getMaxWeight('push_1', 2);
    expect(maxSet2, 105.0);
  });
  
  test('exportAllTrendsCsv returns correctly formatted CSV file with right columns', () async {
    final repo = GymRepositoryImpl();
    
    await repo.logWeights('legs_1a', [200.0, 210.0, 220.0, 230.0], startIndex: 1);
    
    final csvPath = await repo.exportAllTrendsCsv();
    expect(csvPath.endsWith('workout_trends.csv'), true);
    
    final file = File(csvPath);
    final content = await file.readAsString();
    
    expect(content.contains('Date,Exercise,Set 1 (lbs),Set 2 (lbs),Set 3 (lbs),Set 4 (lbs),Set 5 (lbs),Set 6 (lbs)'), true);
    expect(content.contains('"Leg Press Machine",200.0,210.0,220.0,230.0,,'), true);
  });

  test('exportAllTrendsCsv handles sparse data properly', () async {
    final repo = GymRepositoryImpl();
    
    // Log Set 1
    await repo.logWeights('pull_1', [150.0], startIndex: 1);
    // Log Set 3 directly
    await repo.logWeights('pull_1', [160.0], startIndex: 3);
    
    final csvPath = await repo.exportAllTrendsCsv();
    final content = await File(csvPath).readAsString();
    
    // Should have 150.0 in Set 1, empty Set 2 (indicated by double comma), and 160.0 in Set 3
    expect(content.contains('"Lat Pulldown Machine",150.0,,160.0,,,'), true);
  });

  test('getMaxWeight specifically isolates by set_index across multiple dates', () async {
    final repo = GymRepositoryImpl();
    
    // Session 1
    await repo.logWeights('legs_3b', [400.0, 410.0, 420.0], startIndex: 1);
    
    // Backdate the session to simulate an older workout
    final db = await SqliteDb.instance;
    await db.rawUpdate("UPDATE logs SET date = '2026-04-01T10:00:00' WHERE exercise_id = 'legs_3b'");
    
    // Session 2 (Current date)
    await repo.logWeights('legs_3b', [390.0, 450.0, 400.0], startIndex: 1);
    
    // Max of Set 1 is 400.0 (Session 1)
    expect(await repo.getMaxWeight('legs_3b', 1), 400.0);
    // Max of Set 2 is 450.0 (Session 2)
    expect(await repo.getMaxWeight('legs_3b', 2), 450.0);
    
    // Prev of Set 1 should be 390.0 (Session 2 is the most recent date)
    expect(await repo.getPrevWeight('legs_3b', 1), 390.0);
  });
}
