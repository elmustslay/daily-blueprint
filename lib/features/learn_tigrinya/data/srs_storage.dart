import 'dart:convert';
import '../../../core/storage/shared_prefs.dart';

/// Represents a single card's SRS (Spaced Repetition System) state.
///
/// Tracks timestamps, accuracy, hint usage, and SM-2 scheduling parameters
/// to implement a real forgetting curve.
class SrsCardRecord {
  final String cardKey;
  int lastSeenTimestamp; // Unix ms
  int correctCount;
  int incorrectCount;
  int consecutiveCorrect;
  int hintPeekCount;
  double easeFactor; // SM-2 ease factor (min 1.3, default 2.5)
  double intervalDays; // Current review interval in days

  SrsCardRecord({
    required this.cardKey,
    this.lastSeenTimestamp = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.consecutiveCorrect = 0,
    this.hintPeekCount = 0,
    this.easeFactor = 2.5,
    this.intervalDays = 1.0,
  });

  /// Error rate: fraction of total answers that were incorrect.
  double get errorRate {
    final total = correctCount + incorrectCount;
    if (total == 0) return 0.0;
    return incorrectCount / total;
  }

  /// Priority score for sorting due cards. Higher = more urgent.
  /// Factors: days overdue, error rate, hint peeks.
  double priorityScore(DateTime now) {
    if (lastSeenTimestamp == 0) return 100.0; // Never seen = high priority

    final lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeenTimestamp);
    final daysSinceSeen = now.difference(lastSeen).inHours / 24.0;
    final overdueRatio = daysSinceSeen / intervalDays;

    // Base priority: how overdue it is
    double score = overdueRatio;

    // Boost for high error rate
    if (errorRate > 0.4) score += 3.0;
    else if (errorRate > 0.2) score += 1.5;

    // Boost for frequent hint peeks
    if (hintPeekCount > 5) score += 2.0;
    else if (hintPeekCount > 2) score += 1.0;

    return score;
  }

  /// Whether this card is due for review.
  bool isDue(DateTime now) {
    if (lastSeenTimestamp == 0) return true; // Never reviewed
    final lastSeen = DateTime.fromMillisecondsSinceEpoch(lastSeenTimestamp);
    final daysSinceSeen = now.difference(lastSeen).inHours / 24.0;
    return daysSinceSeen >= intervalDays;
  }

  Map<String, dynamic> toJson() => {
    'k': cardKey,
    'ts': lastSeenTimestamp,
    'cc': correctCount,
    'ic': incorrectCount,
    'cs': consecutiveCorrect,
    'hp': hintPeekCount,
    'ef': easeFactor,
    'id': intervalDays,
  };

  factory SrsCardRecord.fromJson(Map<String, dynamic> json) => SrsCardRecord(
    cardKey: json['k'] as String,
    lastSeenTimestamp: json['ts'] as int? ?? 0,
    correctCount: json['cc'] as int? ?? 0,
    incorrectCount: json['ic'] as int? ?? 0,
    consecutiveCorrect: json['cs'] as int? ?? 0,
    hintPeekCount: json['hp'] as int? ?? 0,
    easeFactor: (json['ef'] as num?)?.toDouble() ?? 2.5,
    intervalDays: (json['id'] as num?)?.toDouble() ?? 1.0,
  );
}

/// Persists SRS data via SharedPreferences.
///
/// Each card record is stored as a JSON string under key `srs_{cardKey}`.
/// We also maintain an index key `srs_index` with all known card keys.
class SrsStorage {
  static const String _indexKey = 'srs_index';
  static const String _prefix = 'srs_';

  /// Record a review for a card. Updates SM-2 scheduling.
  static Future<void> recordReview(String cardKey, bool isCorrect) async {
    final parts = cardKey.split('_');
    if (parts.length >= 3 && parts[1].isEmpty && parts[2] == 'pronoun') {
      // Ignore complex grammar strings that lack an object and a verb.
      // They cannot be reconstructed by the Daily Review screen and will become ghost cards.
      return;
    }

    final record = getCardRecord(cardKey) ?? SrsCardRecord(cardKey: cardKey);
    record.lastSeenTimestamp = DateTime.now().millisecondsSinceEpoch;

    if (isCorrect) {
      record.correctCount++;
      record.consecutiveCorrect++;

      // SM-2 algorithm: update ease factor and interval
      // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
      // where q = 5 for correct (quality = perfect recall)
      final q = 5; // correct = quality 5
      record.easeFactor = record.easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      if (record.easeFactor < 1.3) record.easeFactor = 1.3;

      // Update interval based on consecutive correct count
      if (record.consecutiveCorrect == 1) {
        record.intervalDays = 1.0;
      } else if (record.consecutiveCorrect == 2) {
        record.intervalDays = 3.0;
      } else {
        record.intervalDays = record.intervalDays * record.easeFactor;
      }
    } else {
      record.incorrectCount++;
      record.consecutiveCorrect = 0;

      // SM-2: reduce ease factor for wrong answers (quality = 1)
      final q = 1;
      record.easeFactor = record.easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
      if (record.easeFactor < 1.3) record.easeFactor = 1.3;

      // Reset interval to 1 day (lapse)
      record.intervalDays = 1.0;
    }

    await _saveRecord(record);
  }

  /// Record a hint peek (user tapped to see translation).
  static Future<void> recordHintPeek(String cardKey) async {
    final parts = cardKey.split('_');
    if (parts.length >= 3 && parts[1].isEmpty && parts[2] == 'pronoun') return;

    final record = getCardRecord(cardKey) ?? SrsCardRecord(cardKey: cardKey);
    record.hintPeekCount++;

    // Peeking slightly reduces ease factor (indicates uncertainty)
    record.easeFactor = (record.easeFactor - 0.05).clamp(1.3, 3.0);

    await _saveRecord(record);
  }

  /// Get a single card record, or null if not tracked yet.
  static SrsCardRecord? getCardRecord(String cardKey) {
    final prefs = SharedPrefsLogic.instance;
    final json = prefs.getString('$_prefix$cardKey');
    if (json == null) return null;
    try {
      return SrsCardRecord.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Get all tracked SRS records.
  static List<SrsCardRecord> getAllRecords() {
    final prefs = SharedPrefsLogic.instance;
    final index = prefs.getStringList(_indexKey) ?? [];
    final records = <SrsCardRecord>[];
    
    final advancedWords = ['ዕስራ', 'ሰላሳ', 'ኣርብዓ', 'ሓምሳ', 'ሱሳ', 'ሰብዓ', 'ሰማንያ', 'ተስዓ', 'ሚእቲ'];

    for (final key in index) {
      final parts = key.split('_');
      // Actively ignore advanced numbers if they are still floating in memory
      if (parts.length > 1 && advancedWords.contains(parts[1])) {
        continue;
      }
      // Actively ignore unsupported grammar cards that lack an object and a verb
      if (parts.length > 2 && parts[1].isEmpty && parts[2] == 'pronoun') {
        continue;
      }
      
      final record = getCardRecord(key);
      if (record != null) records.add(record);
    }
    return records;
  }

  /// Get cards that are due for review, sorted by priority (most urgent first).
  ///
  /// Priority factors:
  /// 1. Cards overdue (interval has elapsed since last seen)
  /// 2. Cards with high error rates (> 40% incorrect)
  /// 3. Cards with many hint peeks (> 2)
  static List<SrsCardRecord> getDueCards({int maxCount = 20}) {
    final now = DateTime.now();
    final allRecords = getAllRecords();

    // Filter to due cards
    final dueCards = allRecords.where((r) => r.isDue(now)).toList();

    // Sort by priority (highest first)
    dueCards.sort((a, b) => b.priorityScore(now).compareTo(a.priorityScore(now)));

    // If we don't have enough due cards, also include struggling cards
    // even if not technically due
    if (dueCards.length < maxCount) {
      final struggling = allRecords
          .where((r) => !r.isDue(now) && (r.errorRate > 0.3 || r.hintPeekCount > 3))
          .toList();
      struggling.sort((a, b) => b.priorityScore(now).compareTo(a.priorityScore(now)));

      final needed = maxCount - dueCards.length;
      dueCards.addAll(struggling.take(needed));
    }

    return dueCards.take(maxCount).toList();
  }

  /// Get the total count of due cards (for badge display).
  static int getDueCardCount() {
    final now = DateTime.now();
    final allRecords = getAllRecords();
    return allRecords.where((r) => r.isDue(now)).length;
  }

  /// Get cards that the user struggles with most (for biasing global interleave).
  /// Returns card keys sorted by struggle score.
  static List<String> getStrugglingCardKeys({int maxCount = 10}) {
    final now = DateTime.now();
    final allRecords = getAllRecords();

    // Only consider cards that have been reviewed at least once
    final reviewed = allRecords.where((r) => r.lastSeenTimestamp > 0).toList();

    // Sort by a "struggle score": error rate + hint peeks + overdue ratio
    reviewed.sort((a, b) {
      final scoreA = a.errorRate * 3 + (a.hintPeekCount * 0.2) + (a.isDue(now) ? 2.0 : 0.0);
      final scoreB = b.errorRate * 3 + (b.hintPeekCount * 0.2) + (b.isDue(now) ? 2.0 : 0.0);
      return scoreB.compareTo(scoreA);
    });

    return reviewed.take(maxCount).map((r) => r.cardKey).toList();
  }

  /// Clear all SRS data. Called when user resets all progress.
  static Future<void> resetAll() async {
    final prefs = SharedPrefsLogic.instance;
    final index = prefs.getStringList(_indexKey) ?? [];
    for (final key in index) {
      await prefs.remove('$_prefix$key');
    }
    await prefs.remove(_indexKey);
  }

  // ── Private helpers ──

  static Future<void> _saveRecord(SrsCardRecord record) async {
    final prefs = SharedPrefsLogic.instance;
    await prefs.setString('$_prefix${record.cardKey}', jsonEncode(record.toJson()));

    // Update index
    final index = prefs.getStringList(_indexKey) ?? [];
    if (!index.contains(record.cardKey)) {
      index.add(record.cardKey);
      await prefs.setStringList(_indexKey, index);
    }
  }
}
