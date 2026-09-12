import 'dart:math';
import 'tigrinya_models.dart';
import '../data/tigrinya_drills_data.dart';
import '../data/mastery_provider.dart';
import 'conjugator.dart';

/// Pure-Dart drill engine. No Flutter dependency.
///
/// Manages card generation, interleaving, SOV sentence assembly,
/// and the spaced-repetition mistake queue.
class DrillEngine {
  final DrillModule module;
  final Tense tense;
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

  DrillEngine({required this.module, required this.tense});

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

    if (module.type == DrillModuleType.pronoun) {
      _generatePronounDeck();
    } else if (module.type == DrillModuleType.questionWord) {
      _generateQuestionWordDeck();
    } else if (module.type == DrillModuleType.number) {
      _generateNumberDeck();
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
    } else {
      _generateVerbDeck();
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

  void generateReviewDeck() {
    _deck.clear();
    _currentIndex = 0;
    _totalAnswered = 0;
    _totalCorrect = 0;
    _retryCorrectStreak.clear();
    _pendingRetries.clear();

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

    if (module.type == DrillModuleType.pronoun) {
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
      final allPronouns = TigrinyaDrillsData.pronouns;
      final allVerbs = TigrinyaDrillsData.verbs;

      for (int i = 0; i < 50; i++) {
        final rp = allPronouns[_rng.nextInt(allPronouns.length)];
        final rv = allVerbs[_rng.nextInt(allVerbs.length)];
        final conj = rv.conjugate(rp.id, card.tense)?.replaceAll('{', '').replaceAll('}', '');
        if (conj == null) continue;

        TigrinyaObject? obj;
        if (rv.categories.isNotEmpty) {
          final cat = rv.categories[_rng.nextInt(rv.categories.length)];
          final objs = TigrinyaDrillsData.compatibleObjects[cat] ?? [];
          if (objs.isNotEmpty) {
            obj = objs[_rng.nextInt(objs.length)];
          }
        }
        obj ??= card.object ?? const TigrinyaObject(tigrinya: 'ማይ', amharic: 'ውሃ', english: 'water');

        final distractor = '${rp.tigrinya} ${obj.tigrinya} $conj';
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
    while (distractors.length < maxDistractors) {
      distractors.add('—');
    }

    final options = [correct, ...distractors.take(maxDistractors)];
    options.shuffle(_rng);
    return options;
  }

  // ───────────────────── PRIVATE ─────────────────────

  void _generatePronounDeck() {
    for (int i = 0; i < 100; i++) {
      final pronoun = TigrinyaDrillsData.pronouns[_rng.nextInt(TigrinyaDrillsData.pronouns.length)];
      _deck.add(DrillCard(
        pronoun: pronoun,
        tense: tense,
        correctAnswer: pronoun.tigrinya,
        promptText: '${pronoun.english} / ${pronoun.amharic}',
      ));
    }
  }

  void _generateNumberDeck() {
    for (final number in TigrinyaDrillsData.numbers) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: number.tigrinya,
        promptText: '${number.english} / ${number.amharic}',
        object: number,
      ));
    }
  }

  void _generateTimeDeck() {
    for (final timeWord in TigrinyaDrillsData.timeWords) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: timeWord.tigrinya,
        promptText: '${timeWord.english} / ${timeWord.amharic}',
        object: timeWord,
      ));
    }
  }

  void _generateGreetingDeck() {
    for (final greeting in TigrinyaDrillsData.greetings) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: greeting.tigrinya,
        promptText: '${greeting.english} / ${greeting.amharic}',
        object: greeting,
      ));
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
    for (final item in TigrinyaDrillsData.nounPossessionItems) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: item.tigrinya,
        promptText: '${item.english} / ${item.amharic}',
        object: item,
      ));
    }
  }

  void _generateVerbObjectSuffixDeck() {
    for (final item in TigrinyaDrillsData.verbObjectSuffixItems) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: item.tigrinya,
        promptText: '${item.english} / ${item.amharic}',
        object: item,
      ));
    }
  }

  void _generateImperativeDeck() {
    for (final item in TigrinyaDrillsData.imperativeItems) {
      _deck.add(DrillCard(
        tense: tense,
        correctAnswer: item.tigrinya,
        promptText: '${item.english} / ${item.amharic}',
        object: item,
      ));
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
