import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/sqlite_db.dart';

class BodyWeightEntry {
  final int? id;
  final double weight;
  final DateTime date;

  BodyWeightEntry({this.id, required this.weight, required this.date});
}

class BodyWeightRepository {
  Future<void> log(double weight, DateTime date) async {
    final db = await SqliteDb.instance;
    final dateStr = _dateOnly(date);
    // Upsert: replace if same date exists
    await db.rawInsert(
      'INSERT OR REPLACE INTO body_weight (weight, date) VALUES (?, ?)',
      [weight, dateStr],
    );
  }

  Future<List<BodyWeightEntry>> getAll() async {
    final db = await SqliteDb.instance;
    final maps = await db.query('body_weight', orderBy: 'date ASC');
    return maps.map((e) => BodyWeightEntry(
      id: e['id'] as int,
      weight: e['weight'] as double,
      date: DateTime.parse(e['date'] as String),
    )).toList();
  }

  Future<BodyWeightEntry?> getLatest() async {
    final db = await SqliteDb.instance;
    final maps = await db.query('body_weight', orderBy: 'date DESC', limit: 1);
    if (maps.isEmpty) return null;
    return BodyWeightEntry(
      id: maps.first['id'] as int,
      weight: maps.first['weight'] as double,
      date: DateTime.parse(maps.first['date'] as String),
    );
  }

  Future<void> delete(int id) async {
    final db = await SqliteDb.instance;
    await db.delete('body_weight', where: 'id = ?', whereArgs: [id]);
  }

  String _dateOnly(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

final bodyWeightRepoProvider = Provider<BodyWeightRepository>((ref) => BodyWeightRepository());

final bodyWeightEntriesProvider = FutureProvider<List<BodyWeightEntry>>((ref) {
  return ref.read(bodyWeightRepoProvider).getAll();
});
