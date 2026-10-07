import 'dart:math';
import 'tigrinya_models.dart';
import '../data/tigrinya_drills_data.dart';
import '../data/mastery_provider.dart';
import '../data/srs_storage.dart';
import 'conjugator.dart';

/// Pure-Dart drill engine. No Flutter dependency.
///
/// Manages card generation, interleaving, SOV sentence assembly,
/// and the spaced-repetition mistake queue.
class DrillEngine {
  final DrillModule module;
  final Tense tense;
  final int chunkIndex;
  final int totalChunks;
  final Random _rng = Random();

  /// The main card deck (includes retry insertions).
  final List<DrillCard> _deck = [];

  /// Tracks how many consecutive correct answers a failed card has accumulated.
  /// Key = card identity string, Value = consecutive-correct count.
  /// A card is cleared from the retry loop after 2 consecutive correct answers.
  final Map<String, int> _retryCorrectStreak = {};

  /// Cards waiting for a retry insertion. Each entry is (card, targetIndex).
  final List<_RetryEntry> _pendingRetries = [];

  int _currentIndex = 0;
  int _totalAnswered = 0;
  int _totalCorrect = 0;
  bool _isReviewDeck = false;

  DrillEngine({required this.module, required this.tense, this.chunkIndex = 0, this.totalChunks = 1});

  // ───────────────── CHUNK DEFINITIONS ─────────────────
  // Returns list of (startIndex, endIndex) pairs for each chunk.
  // Modules with ≤10 items return a single chunk.

  /// Returns the list of items and their chunk boundaries for a given module.
  /// Returns null if the module doesn't use the chunked flashcard system.
  static ({List<TigrinyaObject> items, List<List<int>> chunks})? getChunkInfo(DrillModuleType type) {
    switch (type) {
      // ── Noun Suffixes: 43 items → 7 semantic chunks ──
      case DrillModuleType.nounPossession:
        final items = TigrinyaDrillsData.nounPossessionItems;
        return (items: items, chunks: [
          [0, 7],    // House (8 items)
          [8, 13],   // Father (6 items)
          [14, 18],  // Mother (5 items)
          [19, 23],  // Brother (5 items)
          [24, 28],  // Sister (5 items)
          [29, 33],  // Head (5 items)
          [34, 42],  // Car + Friend (9 items)
        ]);

      // ── Numbers: 19 items → 2 chunks ──
      case DrillModuleType.number:
        final items = TigrinyaDrillsData.numbers;
        return (items: items, chunks: [
          [0, 9],    // 1-10
          [10, 18],  // 20-1000
        ]);

      // ── Time/Days: 17 items → 2 chunks ──
      case DrillModuleType.time:
        final items = TigrinyaDrillsData.timeWords;
        return (items: items, chunks: [
          [0, 8],    // Days + basic time words
          [9, 16],   // Months & more time words
        ]);

      // ── Greetings: 12 items → 2 chunks ──
      case DrillModuleType.greeting:
        final items = TigrinyaDrillsData.greetings;
        return (items: items, chunks: [
          [0, 5],    // Core greetings
          [6, 11],   // Extended greetings
        ]);

      // ── Verb Object Suffixes: 30 items → 4 chunks ──
      case DrillModuleType.verbObjectSuffix:
        final items = TigrinyaDrillsData.verbObjectSuffixItems;
        return (items: items, chunks: [
          [0, 7],    // "He gave" forms (8 items)
          [8, 13],   // "He saw" forms (6 items)
          [14, 18],  // "He told" forms (5 items)
          [19, 29],  // "I gave/saw/told" forms (11 items)
        ]);

      // ── Imperatives: 16 items → 2 chunks ──
      case DrillModuleType.imperative:
        final items = TigrinyaDrillsData.imperativeItems;
        return (items: items, chunks: [
          [0, 7],    // First group
          [8, 15],   // Second group
        ]);

      // ── Compound Subjects: 18 items → 3 chunks (by subject type) ──
      case DrillModuleType.compoundSubject:
        final items = TigrinyaDrillsData.compoundSubjectItems;
        return (items: items, chunks: [
          [0, 5],    // I + family → We
          [6, 11],   // You + someone → You pl.
          [12, 17],  // He/She + someone → They
        ]);

      // ── Identity Items: 12 items → 2 chunks ──
      case DrillModuleType.identityToBe:
        final items = TigrinyaDrillsData.identityItems;
        return (items: items, chunks: [
          [0, 7],    // Positive identity
          [8, 11],   // Negative identity
        ]);

      case DrillModuleType.advancedNumber:
        final items = TigrinyaDrillsData.advancedNumbers;
        return (items: items, chunks: [
          [0, 3],    // 20-50
          [4, 7],    // 60-90
          [8, 8],    // 100
        ]);

      // ── Existential: 10 items → single chunk (small enough) ──
      // ── All other flashcard modules ≤10 items: single chunk ──
      default:
        return null; // No chunking needed
    }
  }

  /// Returns total number of chunks for this module type.
  /// Returns 1 for modules that don't need chunking.
  static int getTotalChunks(DrillModuleType type) {
    final info = getChunkInfo(type);
    return info?.chunks.length ?? 1;
  }

  // ───────────────────── PUBLIC API ─────────────────────

  int get currentIndex => _currentIndex;
  int get deckLength => _deck.length;
  int get totalAnswered => _totalAnswered;
  int get totalCorrect => _totalCorrect;
  double get scorePercent =>
      _totalAnswered == 0 ? 0 : _totalCorrect / _totalAnswered;
  bool get isComplete => _currentIndex >= _deck.length;

  DrillCard? get currentCard =>
      _currentIndex < _deck.length ? _deck[_currentIndex] : null;

  /// Build the initial shuffled deck.
  void generateDeck() {
    _deck.clear();
    _currentIndex = 0;
    _totalAnswered = 0;
    _totalCorrect = 0;
    _retryCorrectStreak.clear();
    _pendingRetries.clear();
    _isReviewDeck = false;

    if (module.type == DrillModuleType.pronoun) {
      _generatePronounDeck();
    } else if (module.type == DrillModuleType.questionWord) {
      _generateQuestionWordDeck();
    } else if (module.type == DrillModuleType.number) {
      _generateNumberDeck();
    } else if (module.type == DrillModuleType.advancedNumber) {
      _generateAdvancedNumberDeck();
    } else if (module.type == DrillModuleType.time) {
      _generateTimeDeck();
    } else if (module.type == DrillModuleType.adjective) {
      _generateAdjectiveDeck();
    } else if (module.type == DrillModuleType.greeting) {
      _generateGreetingDeck();
    } else if (module.type == DrillModuleType.possession) {
      _generatePossessionDeck();
    } else if (module.type == DrillModuleType.demonstrative) {
      _generateDemonstrativeDeck();
    } else if (module.type == DrillModuleType.family) {
      _generateFamilyDeck();
    } else if (module.type == DrillModuleType.preposition) {
      _generatePrepositionDeck();
    } else if (module.type == DrillModuleType.phrase) {
      _generatePhraseDeck();
    } else if (module.type == DrillModuleType.possessivePronoun) {
      _generatePossessivePronounDeck();
    } else if (module.type == DrillModuleType.sentence) {
      _generateSentenceDeck();
    } else if (module.type == DrillModuleType.nounPossession) {
      _generateNounPossessionDeck();
    } else if (module.type == DrillModuleType.verbObjectSuffix) {
      _generateVerbObjectSuffixDeck();
    } else if (module.type == DrillModuleType.imperative) {
      _generateImperativeDeck();
    } else if (module.type == DrillModuleType.locationWord) {
      _generateLocationWordDeck();
    } else if (module.type == DrillModuleType.existential) {
      _generateExistentialDeck();
    } else if (module.type == DrillModuleType.intimatePhrase) {
      _generateIntimatePhraseDeck();
    } else if (module.type == DrillModuleType.compoundSubject) {
      _generateCompoundSubjectDeck();
    } else if (module.type == DrillModuleType.identityToBe) {
      _generateIdentityDeck();
    } else if (module.type == DrillModuleType.emotion) {
      _generateEmotionDeck();
    } else if (module.type == DrillModuleType.withConstruction) {
      _generateWithConstructionDeck();
    } else if (module.type == DrillModuleType.questionWordBasic) {
      _generateQuestionWordBasicDeck();
    } else if (module.type == DrillModuleType.integration) {
      _generateIntegrationDeck();
    } else {
      _generateVerbDeck();
    }

    // Sprinkle in 3-4 review cards from previously completed modules
    _interleaveGlobalReview();

    _deck.shuffle(_rng);

    final vocabToUnlock = <String>{};
    for (final card in _deck) {
      if (card.verb != null) vocabToUnlock.add(card.verb!.id);
      if (card.object != null) vocabToUnlock.add(card.object!.tigrinya);
      if (card.questionWord != null) vocabToUnlock.add(card.questionWord!.id);
    }
    if (vocabToUnlock.isNotEmpty) {
      VocabStorage.unlockVocab(vocabToUnlock.toList());
    }
  }

  void generateReviewDeck() {
    _deck.clear();
    _currentIndex = 0;
    _totalAnswered = 0;
    _totalCorrect = 0;
    _retryCorrectStreak.clear();
    _pendingRetries.clear();
    _isReviewDeck = true;

    final allVerbs = TigrinyaDrillsData.verbs;
    final allTenses = Tense.values;
    final allPronouns = TigrinyaDrillsData.pronouns;

    // 1. Verb cards (8)
    for (int i = 0; i < 8; i++) {
      final verb = allVerbs[_rng.nextInt(allVerbs.length)];
      final tense = allTenses[_rng.nextInt(allTenses.length)];
      final pronoun = allPronouns[_rng.nextInt(allPronouns.length)];
      final conjugated = verb.conjugate(pronoun.id, tense)?.replaceAll('{', '').replaceAll('}', '');
      if (conjugated == null) continue;

      TigrinyaObject? obj;
      if (verb.categories.isNotEmpty) {
        final randomCategory = verb.categories[_rng.nextInt(verb.categories.length)];
        final objects = TigrinyaDrillsData.compatibleObjects[randomCategory] ?? [];
        if (objects.isNotEmpty) {
          obj = objects[_rng.nextInt(objects.length)];
        }
      }

      final tenseLabel = ' [${tense.name}]';
      final promptText =
          '${pronoun.english} (${pronoun.amharic})$tenseLabel → ${verb.english}';

      _deck.add(DrillCard(
        pronoun: pronoun,
        verb: verb,
        object: obj,
        tense: tense,
        correctAnswer: conjugated,
        promptText: promptText,
      ));
    }

    // 2. Sentences (4)
    for (int i = 0; i < 4; i++) {
      final verb = allVerbs[_rng.nextInt(allVerbs.length)];
      final pronoun = allPronouns[_rng.nextInt(allPronouns.length)];
      final conjugated = verb.conjugate(pronoun.id, Tense.present)?.replaceAll('{', '').replaceAll('}', '');
      if (conjugated == null) continue;

      TigrinyaObject obj = const TigrinyaObject(tigrinya: 'ማይ', amharic: 'ውሃ', english: 'water');
      if (verb.categories.isNotEmpty) {
        final cat = verb.categories[_rng.nextInt(verb.categories.length)];
        final objs = TigrinyaDrillsData.compatibleObjects[cat] ?? [];
        if (objs.isNotEmpty) {
          obj = objs[_rng.nextInt(objs.length)];
        }
      }

      final correctAnswer = '${pronoun.tigrinya} ${obj.tigrinya} $conjugated';
      final promptText =
          '${pronoun.english} ${verb.english.replaceAll("To ", "").toLowerCase()} ${obj.english} (${pronoun.amharic} ${obj.amharic} ...) [present]';

      _deck.add(DrillCard(
        pronoun: pronoun,
        verb: verb,
        object: obj,
        tense: Tense.present,
        correctAnswer: correctAnswer,
        promptText: promptText,
      ));
    }

    // 3. Noun Possession cards (4)
    final nounItems = List<TigrinyaObject>.from(TigrinyaDrillsData.nounPossessionItems)..shuffle(_rng);
    for (final item in nounItems.take(4)) {
      _deck.add(DrillCard(
        tense: Tense.present,
        correctAnswer: item.tigrinya,
        promptText: '${item.english} / ${item.amharic}',
        object: item,
      ));
    }

    // 4. Verb Object Suffix cards (4)
    final verbSuffixItems = List<TigrinyaObject>.from(TigrinyaDrillsData.verbObjectSuffixItems)..shuffle(_rng);
    for (final item in verbSuffixItems.take(4)) {
      _deck.add(DrillCard(
        tense: Tense.past,
        correctAnswer: item.tigrinya,
        promptText: '${item.english} / ${item.amharic}',
        object: item,
      ));
    }

    _deck.shuffle(_rng);

    final vocabToUnlock = <String>{};
    for (final card in _deck) {
      if (card.verb != null) vocabToUnlock.add(card.verb!.id);
      if (card.object != null) vocabToUnlock.add(card.object!.tigrinya);
      if (card.questionWord != null) vocabToUnlock.add(card.questionWord!.id);
    }
    if (vocabToUnlock.isNotEmpty) {
      VocabStorage.unlockVocab(vocabToUnlock.toList());
    }
  }

  /// Check an answer. Returns result and manages retry queue.
  AnswerResult checkAnswer(String userInput) {
    final card = currentCard;
    if (card == null) {
      return const AnswerResult(
        isCorrect: false,
        userAnswer: '',
        expectedAnswer: '',
      );
    }

    final normalizedInput = userInput.trim();
    final normalizedExpected = card.correctAnswer.replaceAll('{', '').replaceAll('}', '').trim();
    final isCorrect = normalizedInput == normalizedExpected;
    final cardKey = _cardKey(card);

    if (isCorrect) {
      _totalCorrect++;
      // If this card is in the retry system, increment its streak
      if (_retryCorrectStreak.containsKey(cardKey)) {
        _retryCorrectStreak[cardKey] = _retryCorrectStreak[cardKey]! + 1;
        // Need 2 consecutive correct to fully clear (3 for pronoun drills)
        int requiredStreak = module.type == DrillModuleType.pronoun ? 3 : 2;
        if (_retryCorrectStreak[cardKey]! >= requiredStreak) {
          _retryCorrectStreak.remove(cardKey);
        }
      }
    } else {
      // Reset streak if it was being retried
      _retryCorrectStreak[cardKey] = 0;

      // Schedule retries at current+2 and current+5
      final retryAt2 = _currentIndex + 2 + 1; // +1 because we'll advance
      final retryAt5 = _currentIndex + 5 + 1;
      _pendingRetries.add(_RetryEntry(card: card, insertAt: retryAt2));
      _pendingRetries.add(_RetryEntry(card: card, insertAt: retryAt5));
      
      if (module.type == DrillModuleType.pronoun) {
        final retryAt8 = _currentIndex + 8 + 1;
        _pendingRetries.add(_RetryEntry(card: card, insertAt: retryAt8));
      }
    }

    _totalAnswered++;

    // Record SRS review for this card
    SrsStorage.recordReview(cardKey, isCorrect);

    // Build diff highlight for wrong answers
    String? diffHighlight;
    if (!isCorrect) {
      diffHighlight = 'Expected: $normalizedExpected';
    }

    return AnswerResult(
      isCorrect: isCorrect,
      userAnswer: normalizedInput,
      expectedAnswer: normalizedExpected,
      diffHighlight: diffHighlight,
    );
  }

  /// Advance to next card, inserting any pending retries.
  void advance() {
    _currentIndex++;
    _insertPendingRetries();

    // If we've reached the end but still have uncleared retries, extend
    if (_currentIndex >= _deck.length && _retryCorrectStreak.isNotEmpty) {
      // Re-add all uncleared cards
      for (final key in _retryCorrectStreak.keys.toList()) {
        final card = _findCardByKey(key);
        if (card != null) {
          _deck.add(card);
        }
      }
    }
  }

  /// Generate 4 MCQ options for the current card.
  /// One correct + 3 distractors from the same domain.
  List<String> generateMcqOptions() {
    final card = currentCard;
    if (card == null) return [];

    final correct = card.correctAnswer;
    final distractors = <String>{};

    if (_isReviewDeck) {
      if (card.verb != null && card.pronoun != null && correct.contains(' ')) {
        final allVerbs = TigrinyaDrillsData.verbs;
        for (int i = 0; i < 50; i++) {
          final rv = allVerbs[_rng.nextInt(allVerbs.length)];
          final conj = rv.conjugate(card.pronoun!.id, card.tense)?.replaceAll('{', '').replaceAll('}', '');
          if (conj == null) continue;
          final objTigrinya = card.object?.tigrinya ?? 'ማይ';
          final distractor = '${card.pronoun!.tigrinya} $objTigrinya $conj';
          if (distractor != correct && !distractors.contains(distractor)) {
            distractors.add(distractor);
            if (distractors.length >= 7) break;
          }
        }
      } else if (card.verb != null && card.pronoun != null) {
        final verb = card.verb!;
        final conjugationMap = verb.getMap(card.tense);
        final allForms = conjugationMap.allForms.toList();
        allForms.remove(correct);
        final uniqueDistractors = allForms.toSet().toList();
        uniqueDistractors.remove(correct);
        uniqueDistractors.shuffle(_rng);
        distractors.addAll(uniqueDistractors.take(7));

        if (distractors.length < 7) {
          final allVerbs = TigrinyaDrillsData.verbs;
          for (int i = 0; i < 20; i++) {
            if (distractors.length >= 7) break;
            final otherVerb = allVerbs[_rng.nextInt(allVerbs.length)];
            if (otherVerb.id == verb.id) continue;
            final otherMap = otherVerb.getMap(card.tense);
            final otherForms = otherMap.allForms.toSet().toList();
            otherForms.shuffle(_rng);
            for (final f in otherForms) {
              if (f != correct && !distractors.contains(f)) {
                distractors.add(f);
                if (distractors.length >= 7) break;
              }
            }
          }
        }
      } else if (TigrinyaDrillsData.nounPossessionItems.contains(card.object)) {
        final allItems = TigrinyaDrillsData.nounPossessionItems.map((n) => n.tigrinya).toList();
        allItems.remove(correct);
        allItems.shuffle(_rng);
        distractors.addAll(allItems.take(7));
      } else if (TigrinyaDrillsData.verbObjectSuffixItems.contains(card.object)) {
        final allItems = TigrinyaDrillsData.verbObjectSuffixItems.map((v) => v.tigrinya).toList();
        allItems.remove(correct);
        allItems.shuffle(_rng);
        distractors.addAll(allItems.take(7));
      }
    } else if (module.type == DrillModuleType.pronoun) {
      final allForms =
          TigrinyaDrillsData.pronouns.map((p) => p.tigrinya).toList();
      allForms.remove(correct);
      allForms.shuffle(_rng);
      distractors.addAll(allForms.take(7));
    } else if (module.type == DrillModuleType.number) {
      final allForms = TigrinyaDrillsData.numbers.map((n) => n.tigrinya).toList();
      allForms.remove(correct);
      allForms.shuffle(_rng);
      distractors.addAll(allForms.take(7));
    } else if (module.type == DrillModuleType.time) {
      final allForms = TigrinyaDrillsData.timeWords.map((t) => t.tigrinya).toList();
      allForms.remove(correct);
      allForms.shuffle(_rng);
      distractors.addAll(allForms.take(7));
    } else if (module.type == DrillModuleType.greeting) {
      final allForms = TigrinyaDrillsData.greetings.map((g) => g.tigrinya).toList();
      allForms.remove(correct);
      allForms.shuffle(_rng);
      distractors.addAll(allForms.take(7));
    } else if (module.type == DrillModuleType.possession) {
      // Mix positive and negative possession forms
      final allForms = <String>[];
      for (final p in TigrinyaDrillsData.pronouns) {
        allForms.add(TigrinyaDrillsData.possession['positive']![p.id]!);
        allForms.add(TigrinyaDrillsData.possession['negative']![p.id]!);
      }
      allForms.remove(correct);
      allForms.shuffle(_rng);
      distractors.addAll(allForms.take(7));
    } else if (module.type == DrillModuleType.demonstrative) {
      final allForms = TigrinyaDrillsData.demonstratives.map((d) => d.tigrinya).toList();
      allForms.remove(correct);
      allForms.shuffle(_rng);
      distractors.addAll(allForms.take(7));
    } else if (module.type == DrillModuleType.family) {
      final allForms = TigrinyaDrillsData.compatibleObjects['family']!.map((f) => f.tigrinya).toList();
      allForms.remove(correct);
      allForms.shuffle(_rng);
      distractors.addAll(allForms.take(7));
    } else if (module.type == DrillModuleType.preposition) {
      final allForms = TigrinyaDrillsData.prepositions.map((p) => p.tigrinya).toList();
      allForms.remove(correct);
      allForms.shuffle(_rng);
      distractors.addAll(allForms.take(7));
    } else if (module.type == DrillModuleType.phrase) {
      final allForms = TigrinyaDrillsData.commonPhrases.map((p) => p.tigrinya).toList();
      allForms.remove(correct);
      allForms.shuffle(_rng);
      distractors.addAll(allForms.take(7));
    } else if (module.type == DrillModuleType.possessivePronoun) {
      final allForms = TigrinyaDrillsData.possessivePronouns.map((p) => p.tigrinya).toList();
      allForms.remove(correct);
      allForms.shuffle(_rng);
      distractors.addAll(allForms.take(7));
    } else if (module.type == DrillModuleType.questionWord) {
      // For question words, the correct answer is the full string (e.g. "እንታይ ይበልዕ")
      // We will generate distractors by changing either the question word or the conjugation
      final currentVerb = card.verb!;
      
      final allQWs = TigrinyaDrillsData.questionWords;
      final allPronouns = TigrinyaDrillsData.pronouns;
      
      for(int i = 0; i < 20; i++) { // try generating combinations
        final rw = allQWs[_rng.nextInt(allQWs.length)];
        final rp = allPronouns[_rng.nextInt(allPronouns.length)];
        final distractor = '${rw.tigrinya} ${currentVerb.conjugate(rp.id, card.tense)}';
        if (distractor != correct && !distractors.contains(distractor)) {
           distractors.add(distractor);
           if (distractors.length >= 7) break;
        }
      }
    } else if (module.type == DrillModuleType.adjective) {
      final allPronouns = TigrinyaDrillsData.pronouns;
      final allAdjectives = TigrinyaDrillsData.adjectives;
      final isPositive = card.correctAnswer.contains(VerbConjugator.bePositive[card.pronoun!.id]!.replaceAll('{', '').replaceAll('}', ''));
      
      for(int i = 0; i < 50; i++) {
        final rp = allPronouns[_rng.nextInt(allPronouns.length)];
        final ra = allAdjectives[_rng.nextInt(allAdjectives.length)];
        
        String adjForm;
        if (['p6', 'p7', 'p8', 'p9', 'p10'].contains(rp.id)) {
          adjForm = ra.plural;
        } else if (['p3', 'p5'].contains(rp.id)) {
          adjForm = ra.female;
        } else {
          adjForm = ra.male;
        }
        
        final beVerb = isPositive ? VerbConjugator.bePositive[rp.id]! : VerbConjugator.beNegative[rp.id]!;
        final cleanBeVerb = beVerb.replaceAll('{', '').replaceAll('}', '');
        
        final distractor = '${rp.tigrinya} $adjForm $cleanBeVerb';
        if (distractor != correct && !distractors.contains(distractor)) {
           distractors.add(distractor);
           if (distractors.length >= 7) break;
        }
      }
    } else if (module.type == DrillModuleType.sentence) {
      final allVerbs = TigrinyaDrillsData.verbs;

      for (int i = 0; i < 50; i++) {
        final rv = allVerbs[_rng.nextInt(allVerbs.length)];
        final conj = rv.conjugate(card.pronoun!.id, card.tense)?.replaceAll('{', '').replaceAll('}', '');
        if (conj == null) continue;

        final objTigrinya = card.object?.tigrinya ?? 'ማይ';
        final distractor = '${card.pronoun!.tigrinya} $objTigrinya $conj';
        if (distractor != correct && !distractors.contains(distractor)) {
          distractors.add(distractor);
          if (distractors.length >= 7) break;
        }
      }
    } else if (module.type == DrillModuleType.nounPossession) {
      final allItems = TigrinyaDrillsData.nounPossessionItems.map((n) => n.tigrinya).toList();
      allItems.remove(correct);
      allItems.shuffle(_rng);
      distractors.addAll(allItems.take(7));
    } else if (module.type == DrillModuleType.verbObjectSuffix) {
      final allItems = TigrinyaDrillsData.verbObjectSuffixItems.map((v) => v.tigrinya).toList();
      allItems.remove(correct);
      allItems.shuffle(_rng);
      distractors.addAll(allItems.take(7));
    } else if (module.type == DrillModuleType.imperative) {
      final allItems = TigrinyaDrillsData.imperativeItems.map((i) => i.tigrinya).toList();
      allItems.remove(correct);
      allItems.shuffle(_rng);
      distractors.addAll(allItems.take(7));
    } else if (module.type == DrillModuleType.locationWord) {
      final allItems = TigrinyaDrillsData.locationWords.map((l) => l.tigrinya).toList();
      allItems.remove(correct);
      allItems.shuffle(_rng);
      distractors.addAll(allItems.take(7));
    } else if (module.type == DrillModuleType.existential) {
      final allItems = TigrinyaDrillsData.existentialItems.map((e) => e.tigrinya).toList();
      allItems.remove(correct);
      allItems.shuffle(_rng);
      distractors.addAll(allItems.take(7));
    } else if (module.type == DrillModuleType.intimatePhrase) {
      final allItems = TigrinyaDrillsData.intimatePhraseItems.map((i) => i.tigrinya).toList();
      allItems.remove(correct);
      allItems.shuffle(_rng);
      distractors.addAll(allItems.take(7));
    } else if (module.type == DrillModuleType.identityToBe) {
      final allItems = TigrinyaDrillsData.identityItems.map((i) => i.tigrinya).toList();
      allItems.remove(correct);
      allItems.shuffle(_rng);
      distractors.addAll(allItems.take(7));
    } else if (module.type == DrillModuleType.emotion) {
      final allItems = TigrinyaDrillsData.emotionItems.map((i) => i.tigrinya).toList();
      allItems.remove(correct);
      allItems.shuffle(_rng);
      distractors.addAll(allItems.take(7));
    } else if (module.type == DrillModuleType.withConstruction) {
      final allItems = TigrinyaDrillsData.withConstructionItems.map((i) => i.tigrinya).toList();
      allItems.remove(correct);
      allItems.shuffle(_rng);
      distractors.addAll(allItems.take(7));
    } else if (module.type == DrillModuleType.questionWordBasic) {
      final allItems = TigrinyaDrillsData.questionWordBasicItems.map((i) => i.tigrinya).toList();
      allItems.remove(correct);
      allItems.shuffle(_rng);
      distractors.addAll(allItems.take(7));
    } else {
      // Distractors from the same verb's conjugation table
      final verb = card.verb;
      if (verb != null) {
        final conjugationMap = verb.getMap(tense);
        final allForms = conjugationMap.allForms.toList();
        allForms.remove(correct);

        final uniqueDistractors = allForms.toSet().toList();
        uniqueDistractors.remove(correct);
        uniqueDistractors.shuffle(_rng);
        distractors.addAll(uniqueDistractors.take(7));
      }

      // If we don't have enough, pull from other active verbs
      if (distractors.length < 7) {
        for (final verbId in module.verbIds) {
          if (distractors.length >= 7) break;
          final otherVerb = TigrinyaDrillsData.getVerbById(verbId);
          if (otherVerb.id == verb?.id) continue;
          final otherMap = otherVerb.getMap(tense);
          final otherForms = otherMap.allForms.toSet().toList();
          otherForms.shuffle(_rng);
          for (final f in otherForms) {
            if (f != correct && !distractors.contains(f)) {
              distractors.add(f);
              if (distractors.length >= 7) break;
            }
          }
        }
      }
    }

    final maxDistractors = 7;
    int blankCount = 1;
    while (distractors.length < maxDistractors) {
      distractors.add('—${' ' * blankCount}');
      blankCount++;
    }

    final options = [correct, ...distractors.take(maxDistractors)];
    options.shuffle(_rng);
    return options;
  }

  // ───────────────────── PRIVATE ─────────────────────

  void _generateIntegrationDeck() {
    if (module.integrationLevel == 1) {
      _generateGreetingDeck();
      _generatePronounDeck();
      _generateDemonstrativeDeck();
      _generatePrepositionDeck();
    } else if (module.integrationLevel == 2) {
      _generateVerbDeck();
      _generateFamilyDeck();
    } else if (module.integrationLevel == 3) {
      _generateAdjectiveDeck();
      _generateIdentityDeck();
      _generateSentenceDeck();
      _generatePossessionDeck();
      _generateExistentialDeck();
      _generateQuestionWordBasicDeck();
      _generateNumberDeck();
    } else if (module.integrationLevel == 4) {
      _generateVerbDeck();
      _generateQuestionWordDeck();
    } else if (module.integrationLevel == 5) {
      _generatePossessivePronounDeck();
      _generateNounPossessionDeck();
      _generateTimeDeck();
      _generateLocationWordDeck();
      _generateCompoundSubjectDeck();
      _generateAdvancedNumberDeck();
    } else if (module.integrationLevel == 6) {
      _generateVerbDeck();
      _generateEmotionDeck();
      _generateImperativeDeck();
    } else if (module.integrationLevel == 7) {
      _generateVerbDeck();
      _generateWithConstructionDeck();
      _generateVerbObjectSuffixDeck();
      _generatePhraseDeck();
      _generateIntimatePhraseDeck();
    } else {
      _generatePronounDeck();
    }
  }

  void _generatePronounDeck() {
    for (int i = 0; i < 30; i++) {
      final pronoun = TigrinyaDrillsData.pronouns[_rng.nextInt(TigrinyaDrillsData.pronouns.length)];
      _deck.add(DrillCard(
        pronoun: pronoun,
        tense: tense,
        correctAnswer: pronoun.tigrinya,
        promptText: '${pronoun.english} / ${pronoun.amharic}',
      ));
    }
  }

  /// Unified chunked deck generator for flashcard-style modules.
  /// Serves only the current chunk's items + interleaved review from prior chunks.
  void _generateChunkedDeck(List<TigrinyaObject> allItems, List<List<int>> chunks) {
    if (chunkIndex >= chunks.length) {
      // All chunks done — generate a cumulative review of 12 random items
      final shuffled = List<TigrinyaObject>.from(allItems)..shuffle(_rng);
      for (final item in shuffled.take(12)) {
        _deck.add(DrillCard(
          tense: tense,
          correctAnswer: item.tigrinya,
          promptText: '${item.english} / ${item.amharic}',
          object: item,
        ));
      }
      return;
    }

    final range = chunks[chunkIndex];
    final chunkItems = allItems.sublist(range[0], range[1] + 1);

    // Add all new items from this chunk
    for (final item in chunkItems) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: item.tigrinya,
        promptText: '${item.english} / ${item.amharic}',
        object: item,
      ));
    }

    // Interleave 3-4 review items from prior chunks (if any)
    if (chunkIndex > 0) {
      final reviewPool = <TigrinyaObject>[];
      for (int i = 0; i < chunkIndex; i++) {
        final prevRange = chunks[i];
        reviewPool.addAll(allItems.sublist(prevRange[0], prevRange[1] + 1));
      }
      reviewPool.shuffle(_rng);
      final reviewCount = min(4, reviewPool.length);
      for (final item in reviewPool.take(reviewCount)) {
        _deck.add(DrillCard(
          tense: tense,
          correctAnswer: item.tigrinya,
          promptText: '${item.english} / ${item.amharic}',
          object: item,
        ));
      }
    }
  }

  /// Adds 3-4 review cards from previously completed flashcard-style modules.
  /// This ensures items from past modules keep resurfacing (spaced repetition
  /// across the entire course, not just within one module).
  void _interleaveGlobalReview() {
    final moduleIndex = TigrinyaDrillsData.modules.indexOf(module);
    if (moduleIndex <= 0) return; // Nothing to review on the very first module

    // Collect items from all completed flashcard modules before this one
    final reviewPool = <TigrinyaObject>[];

    // Map of module types to their item lists
    final flashcardSources = <DrillModuleType, List<TigrinyaObject>>{
      DrillModuleType.greeting: TigrinyaDrillsData.greetings,
      DrillModuleType.family: TigrinyaDrillsData.compatibleObjects['family'] ?? [],
      DrillModuleType.demonstrative: TigrinyaDrillsData.demonstratives,
      DrillModuleType.preposition: TigrinyaDrillsData.prepositions,
      DrillModuleType.phrase: TigrinyaDrillsData.commonPhrases,
      DrillModuleType.nounPossession: TigrinyaDrillsData.nounPossessionItems,
      DrillModuleType.verbObjectSuffix: TigrinyaDrillsData.verbObjectSuffixItems,
      DrillModuleType.imperative: TigrinyaDrillsData.imperativeItems,
      DrillModuleType.existential: TigrinyaDrillsData.existentialItems,
      DrillModuleType.locationWord: TigrinyaDrillsData.locationWords,
      DrillModuleType.compoundSubject: TigrinyaDrillsData.compoundSubjectItems,
      DrillModuleType.intimatePhrase: TigrinyaDrillsData.intimatePhraseItems,
      DrillModuleType.identityToBe: TigrinyaDrillsData.identityItems,
      DrillModuleType.emotion: TigrinyaDrillsData.emotionItems,
      DrillModuleType.withConstruction: TigrinyaDrillsData.withConstructionItems,
      DrillModuleType.questionWordBasic: TigrinyaDrillsData.questionWordBasicItems,
    };

    for (int i = 0; i < moduleIndex; i++) {
      final prevModule = TigrinyaDrillsData.modules[i];
      // Only pull from modules that have been passed at MCQ level
      if (!MasteryStorage.isMcqPassed(prevModule.id, Tense.present)) continue;
      // Skip the current module type (we already have its items in the deck)
      if (prevModule.type == module.type) continue;

      final items = flashcardSources[prevModule.type];
      if (items != null && items.isNotEmpty) {
        reviewPool.addAll(items);
      }
    }

    // Also add pronouns if pronoun module is passed
    if (MasteryStorage.isMcqPassed('mod_pronouns', Tense.present) &&
        module.type != DrillModuleType.pronoun) {
      for (final p in TigrinyaDrillsData.pronouns) {
        reviewPool.add(TigrinyaObject(
          tigrinya: p.tigrinya,
          amharic: p.amharic,
          english: p.english,
        ));
      }
    }

    if (reviewPool.isEmpty) return;

    // Bias towards struggling cards using SRS data
    final strugglingKeys = SrsStorage.getStrugglingCardKeys(maxCount: 20);

    // Separate pool into struggling and normal
    final strugglingItems = <TigrinyaObject>[];
    final normalItems = <TigrinyaObject>[];
    for (final item in reviewPool) {
      // Check if this item's key pattern appears in struggling keys
      final isStruggling = strugglingKeys.any((k) => k.contains(item.tigrinya));
      if (isStruggling) {
        strugglingItems.add(item);
      } else {
        normalItems.add(item);
      }
    }

    // Prioritize struggling items: pick from struggling first, then fill with random
    strugglingItems.shuffle(_rng);
    normalItems.shuffle(_rng);

    final reviewCount = min(4, reviewPool.length);
    final selected = <TigrinyaObject>[];

    // Take up to 2 struggling items first (if available)
    final maxStruggling = min(2, strugglingItems.length);
    selected.addAll(strugglingItems.take(maxStruggling));

    // Fill remaining with normal items
    final remaining = reviewCount - selected.length;
    selected.addAll(normalItems.take(remaining));

    // If still not enough, add more from whatever's left
    if (selected.length < reviewCount) {
      final allLeft = [...strugglingItems.skip(maxStruggling), ...normalItems.skip(remaining)];
      selected.addAll(allLeft.take(reviewCount - selected.length));
    }

    for (final item in selected) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: item.tigrinya,
        promptText: '🔄 ${item.english} / ${item.amharic}',
        object: item,
      ));
    }
  }

  void _generateNumberDeck() {
    final info = DrillEngine.getChunkInfo(DrillModuleType.number);
    if (info != null) {
      _generateChunkedDeck(info.items, info.chunks);
    }
  }

  void _generateAdvancedNumberDeck() {
    final info = DrillEngine.getChunkInfo(DrillModuleType.advancedNumber);
    if (info != null) {
      _generateChunkedDeck(info.items, info.chunks);
    }
  }

  void _generateTimeDeck() {
    final info = DrillEngine.getChunkInfo(DrillModuleType.time);
    if (info != null) {
      _generateChunkedDeck(info.items, info.chunks);
    }
  }

  void _generateGreetingDeck() {
    final info = DrillEngine.getChunkInfo(DrillModuleType.greeting);
    if (info != null) {
      _generateChunkedDeck(info.items, info.chunks);
    }
  }

  void _generatePossessionDeck() {
    final allPronouns = TigrinyaDrillsData.pronouns;
    for (final pronoun in allPronouns) {
      // Positive: "I have", "You have", etc.
      final posForm = TigrinyaDrillsData.possession['positive']![pronoun.id]!;
      _deck.add(DrillCard(
        pronoun: pronoun,
        tense: tense,
        correctAnswer: posForm,
        promptText: '${pronoun.english} have / ${pronoun.amharic} ኣለ...',
      ));
      // Negative: "I don't have", "You don't have", etc.
      final negForm = TigrinyaDrillsData.possession['negative']![pronoun.id]!;
      _deck.add(DrillCard(
        pronoun: pronoun,
        tense: tense,
        correctAnswer: negForm,
        promptText: '${pronoun.english} don\'t have / ${pronoun.amharic} የብል...',
      ));
    }
  }

  void _generateDemonstrativeDeck() {
    for (final dem in TigrinyaDrillsData.demonstratives) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: dem.tigrinya,
        promptText: '${dem.english} / ${dem.amharic}',
        object: dem,
      ));
    }
  }

  void _generateFamilyDeck() {
    for (final fam in TigrinyaDrillsData.compatibleObjects['family']!) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: fam.tigrinya,
        promptText: '${fam.english} / ${fam.amharic}',
        object: fam,
      ));
    }
  }

  void _generatePrepositionDeck() {
    for (final prep in TigrinyaDrillsData.prepositions) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: prep.tigrinya,
        promptText: '${prep.english} / ${prep.amharic}',
        object: prep,
      ));
    }
  }

  void _generatePhraseDeck() {
    for (final phrase in TigrinyaDrillsData.commonPhrases) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: phrase.tigrinya,
        promptText: '${phrase.english} / ${phrase.amharic}',
        object: phrase,
      ));
    }
  }

  void _generatePossessivePronounDeck() {
    for (final pos in TigrinyaDrillsData.possessivePronouns) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: pos.tigrinya,
        promptText: '${pos.english} / ${pos.amharic}',
        object: pos,
      ));
    }
  }

  void _generateVerbDeck() {
    final moduleIndex = TigrinyaDrillsData.modules.indexOf(module);
    
    // 60/40 Split Logic
    // If module is >= 1 (index 1 is first verb module), 60% from current module, 40% from previous verb modules
    final currentModuleVerbs = module.verbIds;
    final previousModuleVerbs = <String>[];
    if (moduleIndex > 1) {
      for (int i = 1; i < moduleIndex; i++) {
        previousModuleVerbs.addAll(TigrinyaDrillsData.modules[i].verbIds);
      }
    }
    
    final allPronouns = TigrinyaDrillsData.pronouns;
    
    // Generate cards for current module verbs
    final currentCards = <DrillCard>[];
    for (final verbId in currentModuleVerbs) {
      final verb = TigrinyaDrillsData.getVerbById(verbId);
      for (final pronoun in allPronouns) {
        final conjugated = verb.conjugate(pronoun.id, tense);
        if (conjugated == null) continue;

        TigrinyaObject? obj;
        if (verb.categories.isNotEmpty) {
          final randomCategory = verb.categories[_rng.nextInt(verb.categories.length)];
          final objects = TigrinyaDrillsData.compatibleObjects[randomCategory] ?? [];
          if (objects.isNotEmpty) {
            obj = objects[_rng.nextInt(objects.length)];
          }
        }

        final tenseLabel = ' [${tense.name}]';
        final promptText =
            '${pronoun.english} (${pronoun.amharic})$tenseLabel → ${verb.english}';

        currentCards.add(DrillCard(
          pronoun: pronoun,
          verb: verb,
          object: obj,
          tense: tense,
          correctAnswer: conjugated,
          promptText: promptText,
        ));
      }
    }
    
    // Generate cards for previous module verbs (if any)
    final previousCards = <DrillCard>[];
    if (previousModuleVerbs.isNotEmpty) {
      for (final verbId in previousModuleVerbs) {
        final verb = TigrinyaDrillsData.getVerbById(verbId);
        for (final pronoun in allPronouns) {
          final conjugated = verb.conjugate(pronoun.id, tense);
          if (conjugated == null) continue;

          TigrinyaObject? obj;
          if (verb.categories.isNotEmpty) {
            final randomCategory = verb.categories[_rng.nextInt(verb.categories.length)];
            final objects = TigrinyaDrillsData.compatibleObjects[randomCategory] ?? [];
            if (objects.isNotEmpty) {
              obj = objects[_rng.nextInt(objects.length)];
            }
          }

          final tenseLabel = ' [${tense.name}]';
          final promptText =
              '${pronoun.english} (${pronoun.amharic})$tenseLabel → ${verb.english}';

          previousCards.add(DrillCard(
            pronoun: pronoun,
            verb: verb,
            object: obj,
            tense: tense,
            correctAnswer: conjugated,
            promptText: promptText,
          ));
        }
      }
    }
    
    // Apply 60/40 ratio
    currentCards.shuffle(_rng);
    previousCards.shuffle(_rng);
    
    if (previousCards.isEmpty) {
      _deck.addAll(currentCards);
    } else {
      // 60% current, 40% previous
      // Actually, standard drill is 10-20 cards. Let's make it fixed size of cards for a session.
      // E.g. 15 cards per session. 9 from current, 6 from previous.
      int numCurrent = min(currentCards.length, 9);
      int numPrev = min(previousCards.length, 6);
      
      _deck.addAll(currentCards.take(numCurrent));
      _deck.addAll(previousCards.take(numPrev));
    }
  }

  void _generateAdjectiveDeck() {
    final allPronouns = TigrinyaDrillsData.pronouns;
    final allAdjectives = TigrinyaDrillsData.adjectives;
    
    for (int i = 0; i < 15; i++) {
      final pronoun = allPronouns[_rng.nextInt(allPronouns.length)];
      final adjective = allAdjectives[_rng.nextInt(allAdjectives.length)];
      
      // Determine if positive or negative
      final isPositive = _rng.nextBool();
      
      // Resolve gender/number
      String adjForm;
      if (['p6', 'p7', 'p8', 'p9', 'p10'].contains(pronoun.id)) {
        adjForm = adjective.plural;
      } else if (['p3', 'p5'].contains(pronoun.id)) {
        adjForm = adjective.female;
      } else {
        // p1, p2, p4 -> male. Note: User requested male for p1.
        adjForm = adjective.male;
      }
      
      // Get 'to be' verb
      final beVerb = isPositive ? VerbConjugator.bePositive[pronoun.id]! : VerbConjugator.beNegative[pronoun.id]!;
      // Clean up braces
      final cleanBeVerb = beVerb.replaceAll('{', '').replaceAll('}', '');
      
      final correctAnswer = '${pronoun.tigrinya} $adjForm $cleanBeVerb';
      final posNeg = isPositive ? '(is/are)' : '(is not / are not)';
      final promptText = '${pronoun.english} $posNeg ${adjective.english}';
      
      _deck.add(DrillCard(
        pronoun: pronoun,
        adjective: adjective,
        tense: tense, 
        correctAnswer: correctAnswer,
        promptText: promptText,
      ));
    }
  }

  void _generateQuestionWordDeck() {
     // Question Words module pulls random verbs and pairs them with random question words
     final allVerbs = TigrinyaDrillsData.verbs;
     final allQWs = TigrinyaDrillsData.questionWords;
     final allPronouns = TigrinyaDrillsData.pronouns;
     
     for(int i = 0; i < 15; i++) {
        final verb = allVerbs[_rng.nextInt(allVerbs.length)];
        final qw = allQWs[_rng.nextInt(allQWs.length)];
        final pronoun = allPronouns[_rng.nextInt(allPronouns.length)];
        
        final conjugated = verb.conjugate(pronoun.id, tense);
        if (conjugated == null) continue;
        
        // Target answer: Question Word + Conjugated Verb
        final correctAnswer = '${qw.tigrinya} $conjugated';
        
        // Prompt format: English/Amharic translation of the question
        // Approximated prompt string
        final promptText = '${qw.english} is ${pronoun.english.toLowerCase()} ${verb.english.toLowerCase().replaceAll("to ", "")}ing? / ${qw.amharic} ${pronoun.amharic} ...?';
        
        _deck.add(DrillCard(
          pronoun: pronoun,
          verb: verb,
          questionWord: qw,
          tense: tense,
          correctAnswer: correctAnswer,
          promptText: promptText,
        ));
     }
  }

  void _generateSentenceDeck() {
    final targetVerbs = module.verbIds.isNotEmpty
        ? module.verbIds.map((id) => TigrinyaDrillsData.getVerbById(id)).toList()
        : TigrinyaDrillsData.verbs;
    final allPronouns = TigrinyaDrillsData.pronouns;

    for (int i = 0; i < 15; i++) {
      final verb = targetVerbs[_rng.nextInt(targetVerbs.length)];
      final pronoun = allPronouns[_rng.nextInt(allPronouns.length)];
      final conjugated = verb.conjugate(pronoun.id, tense)?.replaceAll('{', '').replaceAll('}', '');
      if (conjugated == null) continue;

      TigrinyaObject obj = const TigrinyaObject(tigrinya: 'ማይ', amharic: 'ውሃ', english: 'water');
      if (verb.categories.isNotEmpty) {
        final cat = verb.categories[_rng.nextInt(verb.categories.length)];
        final objs = TigrinyaDrillsData.compatibleObjects[cat] ?? [];
        if (objs.isNotEmpty) {
          obj = objs[_rng.nextInt(objs.length)];
        }
      }

      final correctAnswer = '${pronoun.tigrinya} ${obj.tigrinya} $conjugated';
      final tenseLabel = ' [${tense.name}]';
      final promptText =
          '${pronoun.english} ${verb.english.replaceAll("To ", "").toLowerCase()} ${obj.english} (${pronoun.amharic} ${obj.amharic} ...)$tenseLabel';

      _deck.add(DrillCard(
        pronoun: pronoun,
        verb: verb,
        object: obj,
        tense: tense,
        correctAnswer: correctAnswer,
        promptText: promptText,
      ));
    }
  }

  void _generateNounPossessionDeck() {
    final info = DrillEngine.getChunkInfo(DrillModuleType.nounPossession);
    if (info != null) {
      _generateChunkedDeck(info.items, info.chunks);
    }
  }

  void _generateVerbObjectSuffixDeck() {
    final info = DrillEngine.getChunkInfo(DrillModuleType.verbObjectSuffix);
    if (info != null) {
      _generateChunkedDeck(info.items, info.chunks);
    }
  }

  void _generateImperativeDeck() {
    final info = DrillEngine.getChunkInfo(DrillModuleType.imperative);
    if (info != null) {
      _generateChunkedDeck(info.items, info.chunks);
    }
  }

  void _generateLocationWordDeck() {
    for (final item in TigrinyaDrillsData.locationWords) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: item.tigrinya,
        promptText: '${item.english} / ${item.amharic}',
        object: item,
      ));
    }
  }

  void _generateExistentialDeck() {
    for (final item in TigrinyaDrillsData.existentialItems) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: item.tigrinya,
        promptText: '${item.english} / ${item.amharic}',
        object: item,
      ));
    }
  }

  void _generateIntimatePhraseDeck() {
    for (final item in TigrinyaDrillsData.intimatePhraseItems) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: item.tigrinya,
        promptText: '${item.english} / ${item.amharic}',
        object: item,
      ));
    }
  }

  void _generateCompoundSubjectDeck() {
    final info = DrillEngine.getChunkInfo(DrillModuleType.compoundSubject);
    if (info != null) {
      _generateChunkedDeck(info.items, info.chunks);
    }
  }

  void _generateIdentityDeck() {
    final info = DrillEngine.getChunkInfo(DrillModuleType.identityToBe);
    if (info != null) {
      _generateChunkedDeck(info.items, info.chunks);
    }
  }

  void _generateEmotionDeck() {
    for (final item in TigrinyaDrillsData.emotionItems) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: item.tigrinya,
        promptText: '${item.english} / ${item.amharic}',
        object: item,
      ));
    }
  }

  void _generateWithConstructionDeck() {
    for (final item in TigrinyaDrillsData.withConstructionItems) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: item.tigrinya,
        promptText: '${item.english} / ${item.amharic}',
        object: item,
      ));
    }
  }

  void _generateQuestionWordBasicDeck() {
    for (final item in TigrinyaDrillsData.questionWordBasicItems) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: item.tigrinya,
        promptText: '${item.english} / ${item.amharic}',
        object: item,
      ));
    }
  }

  String _cardKey(DrillCard card) {
    return '${card.pronoun?.id ?? 'flashcard'}_${card.object?.tigrinya ?? ''}_${card.verb?.id ?? 'pronoun'}_${card.tense.name}_${card.questionWord?.id ?? ''}';
  }

  DrillCard? _findCardByKey(String key) {
    for (final card in _deck) {
      if (_cardKey(card) == key) return card;
    }
    return null;
  }

  void _insertPendingRetries() {
    // Check if any pending retries should be inserted at the current position
    final toInsert = <_RetryEntry>[];
    _pendingRetries.removeWhere((entry) {
      if (entry.insertAt <= _currentIndex) {
        toInsert.add(entry);
        return true;
      }
      return false;
    });

    for (final entry in toInsert) {
      // Insert at current position (will be the next card seen)
      if (_currentIndex <= _deck.length) {
        _deck.insert(_currentIndex, entry.card);
      } else {
        _deck.add(entry.card);
      }
    }
  }
}

class _RetryEntry {
  final DrillCard card;
  final int insertAt;

  _RetryEntry({required this.card, required this.insertAt});
}
