import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/shared_prefs.dart';

// Key: Book ID, Value: Current Progress Percent (0-100)
class BookProgressNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() {
    final prefs = SharedPrefsLogic.instance;
    final Map<String, int> stateMap = {};
    
    // We can just load all keys matching "book_prog_"
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('book_prog_')) {
        final bookId = key.replaceFirst('book_prog_', '');
        stateMap[bookId] = prefs.getInt(key) ?? 0;
      }
    }
    return stateMap;
  }

  void updateProgress(String bookId, int percent) {
    if (percent < 0) percent = 0;
    if (percent > 100) percent = 100;
    
    final newStateMap = Map<String, int>.from(state);
    newStateMap[bookId] = percent;
    state = newStateMap;
    
    SharedPrefsLogic.instance.setInt('book_prog_$bookId', percent);
  }
}

final bookProgressProvider = NotifierProvider<BookProgressNotifier, Map<String, int>>(BookProgressNotifier.new);
