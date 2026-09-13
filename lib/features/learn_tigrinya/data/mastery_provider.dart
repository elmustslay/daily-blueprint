import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/shared_prefs.dart';
import '../domain/tigrinya_models.dart';
import 'srs_storage.dart';

/// Persists per-module, per-tense, per-stage mastery scores.
///
/// Key format: `tigrinya_mastery_{moduleId}_{tense}_{stage}`
/// Value: double 0.0–1.0
class MasteryStorage {
  static const double unlockThreshold = 0.85;
  static const String _auditorKey = 'tigrinya_auditor_mode';

  /// Auditor mode: when true, all modules and tenses are unlocked.
  static bool _auditorMode = false;
  static bool get auditorMode => _auditorMode;

  static void loadAuditorMode() {
    final prefs = SharedPrefsLogic.instance;
    _auditorMode = prefs.getBool(_auditorKey) ?? false;
  }

  static Future<void> setAuditorMode(bool value) async {
    _auditorMode = value;
    final prefs = SharedPrefsLogic.instance;
    await prefs.setBool(_auditorKey, value);
  }

  static String _key(String moduleId, Tense tense, DrillStage stage) =>
      'tigrinya_mastery_${moduleId}_${tense.name}_${stage.name}';

  static double getMastery(String moduleId, Tense tense, DrillStage stage) {
    final prefs = SharedPrefsLogic.instance;
    return prefs.getDouble(_key(moduleId, tense, stage)) ?? 0.0;
  }

  static Future<void> setMastery(
      String moduleId, Tense tense, DrillStage stage, double score) async {
    final prefs = SharedPrefsLogic.instance;
    // Only save if it's a new high score
    final current = getMastery(moduleId, tense, stage);
    if (score > current) {
      await prefs.setDouble(_key(moduleId, tense, stage), score);
    }
  }

  // Stage transition checks
  static bool isTeachComplete(String moduleId, Tense tense) =>
      getMastery(moduleId, tense, DrillStage.teach) >= 1.0;

  static bool isMcqPassed(String moduleId, Tense tense) =>
      getMastery(moduleId, tense, DrillStage.mcq) >= unlockThreshold;

  static bool isTypingPassed(String moduleId, Tense tense) =>
      getMastery(moduleId, tense, DrillStage.typing) >= unlockThreshold;

  /// Sequential lock logic for modules:
  /// Module 0 (Pronouns) always unlocked.
  /// Module N requires Module N-1 present tense MCQ at >= 85%.
  static bool isModuleUnlocked(int moduleIndex, List<DrillModule> allModules) {
    if (_auditorMode) return true;
    if (moduleIndex <= 0) return true;
    
    // Check if question word module (must pass both present & past MCQ for all previous verb modules)
    if (allModules[moduleIndex].type == DrillModuleType.questionWord) {
      for (int i = 1; i < moduleIndex; i++) {
        if (!isMcqPassed(allModules[i].id, Tense.present) ||
            !isMcqPassed(allModules[i].id, Tense.past)) {
          return false;
        }
      }
      return true;
    }
    
    final prevModule = allModules[moduleIndex - 1];
    return isMcqPassed(prevModule.id, Tense.present);
  }

  /// Tense progression within a module:
  /// Present is always available if module is unlocked.
  /// Past requires Present MCQ >= 85%.
  /// Continuous requires Past MCQ >= 85%.
  /// Future requires Continuous MCQ >= 85%.
  /// Negative requires Future MCQ >= 85%.
  static bool isTenseUnlocked(String moduleId, Tense tense) {
    if (_auditorMode) return true;
    if (tense == Tense.present) return true;
    if (tense == Tense.past) return isMcqPassed(moduleId, Tense.present);
    if (tense == Tense.continuous) return isMcqPassed(moduleId, Tense.past);
    if (tense == Tense.future) return isMcqPassed(moduleId, Tense.continuous);
    if (tense == Tense.negative) return isMcqPassed(moduleId, Tense.future);
    return false;
  }
}

/// Tracks chunk-level progression within modules.
///
/// For large modules (e.g. Noun Suffixes with 43 items), items are split into
/// chunks of 6-10. The learner must pass each chunk at ≥85% before moving on.
/// The overall module mastery is updated as completedChunks / totalChunks,
/// so the module only counts as "passed" when all chunks are complete.
class ChunkStorage {
  static String _chunkKey(String moduleId, DrillStage stage) =>
      'tigrinya_chunk_${moduleId}_${stage.name}';

  /// Returns the number of chunks the learner has completed for this module+stage.
  static int getChunksCompleted(String moduleId, DrillStage stage) {
    final prefs = SharedPrefsLogic.instance;
    return prefs.getInt(_chunkKey(moduleId, stage)) ?? 0;
  }

  /// Marks a chunk as completed and updates the overall mastery score.
  /// The mastery score = completedChunks / totalChunks.
  static Future<void> completeChunk(
    String moduleId,
    Tense tense,
    DrillStage stage,
    int newCompletedCount,
    int totalChunks,
  ) async {
    final prefs = SharedPrefsLogic.instance;
    final current = getChunksCompleted(moduleId, stage);
    if (newCompletedCount > current) {
      await prefs.setInt(_chunkKey(moduleId, stage), newCompletedCount);
    }
    // Update overall mastery as fraction of chunks completed
    final effectiveCompleted = newCompletedCount > current ? newCompletedCount : current;
    final mastery = effectiveCompleted / totalChunks;
    await MasteryStorage.setMastery(moduleId, tense, stage, mastery);
  }

  /// Returns the current chunk index the learner should work on (0-indexed).
  /// If all chunks are complete, returns totalChunks (meaning done).
  static int getCurrentChunkIndex(String moduleId, DrillStage stage) {
    return getChunksCompleted(moduleId, stage);
  }
}

/// Riverpod provider that exposes mastery data reactively.
class MasteryNotifier extends Notifier<Map<String, double>> {
  @override
  Map<String, double> build() {
    return _loadAll();
  }

  Map<String, double> _loadAll() {
    final prefs = SharedPrefsLogic.instance;
    final allKeys = prefs.getKeys();
    final map = <String, double>{};
    for (final key in allKeys) {
      if (key.startsWith('tigrinya_mastery_')) {
        map[key] = prefs.getDouble(key) ?? 0.0;
      }
    }
    return map;
  }

  double getMastery(String moduleId, Tense tense, DrillStage stage) {
    final key = 'tigrinya_mastery_${moduleId}_${tense.name}_${stage.name}';
    return state[key] ?? 0.0;
  }

  Future<void> saveMastery(
      String moduleId, Tense tense, DrillStage stage, double score) async {
    await MasteryStorage.setMastery(moduleId, tense, stage, score);
    state = _loadAll(); // Refresh state
  }

  Future<void> resetAllProgress() async {
    final prefs = SharedPrefsLogic.instance;
    final allKeys = prefs.getKeys().toList();
    for (final key in allKeys) {
      if (key.startsWith('tigrinya_mastery_') ||
          key.startsWith('tigrinya_chunk_')) {
        await prefs.remove(key);
      }
    }
    // Clear SRS data
    await SrsStorage.resetAll();
    state = {}; // Clear state
  }
}

final masteryProvider =
    NotifierProvider<MasteryNotifier, Map<String, double>>(MasteryNotifier.new);

/// Persists unlocked vocabulary (Verbs, Objects, Question Words) organically.
class VocabStorage {
  static const String _key = 'tigrinya_unlocked_vocab';

  static Set<String> getUnlockedVocab() {
    final prefs = SharedPrefsLogic.instance;
    final list = prefs.getStringList(_key);
    return list?.toSet() ?? {};
  }

  static Future<void> unlockVocab(List<String> keys) async {
    final prefs = SharedPrefsLogic.instance;
    final current = getUnlockedVocab();
    final previousLength = current.length;
    current.addAll(keys);
    
    if (current.length > previousLength) {
      await prefs.setStringList(_key, current.toList());
    }
  }

  static Future<void> resetVocab() async {
    final prefs = SharedPrefsLogic.instance;
    await prefs.remove(_key);
  }
}

class VocabNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return VocabStorage.getUnlockedVocab();
  }

  Future<void> unlockKeys(List<String> keys) async {
    await VocabStorage.unlockVocab(keys);
    state = VocabStorage.getUnlockedVocab();
  }

  Future<void> resetVocab() async {
    await VocabStorage.resetVocab();
    state = {};
  }
}

final vocabProvider =
    NotifierProvider<VocabNotifier, Set<String>>(VocabNotifier.new);
