import 'dart:math';
import 'tigrinya_models.dart';
import '../data/tigrinya_drills_data.dart';
import 'conjugator.dart';

/// Represents a single part of an integration sentence.
/// Each part is a tappable word that reveals its Tigrinya translation.
class SentencePart {
  final String english;
  final String tigrinya;
  final String category; // e.g. 'pronoun', 'verb', 'object', 'time', 'adjective', etc.

  const SentencePart({
    required this.english,
    required this.tigrinya,
    required this.category,
  });
}

/// A full integration sentence with individual tappable parts.
class IntegrationSentence {
  final List<SentencePart> parts;
  final String fullEnglish;
  final String fullTigrinya;

  const IntegrationSentence({
    required this.parts,
    required this.fullEnglish,
    required this.fullTigrinya,
  });
}

/// Generates integration sentences for end-of-unit composition drills.
///
/// Each integration level (1-7) uses only grammar categories that have
/// been covered up to that unit. Sentences grow in complexity with each level.
class IntegrationEngine {
  final int integrationLevel;
  final Random _rng = Random();

  IntegrationEngine({required this.integrationLevel});

  /// Generate a list of integration sentences for the current level.
  List<IntegrationSentence> generateSentences({int count = 10}) {
    final sentences = <IntegrationSentence>[];
    final generators = _getGeneratorsForLevel();

    for (int i = 0; i < count; i++) {
      // Pick a random generator from the available ones for this level
      final generator = generators[_rng.nextInt(generators.length)];
      final sentence = generator();
      if (sentence != null) {
        sentences.add(sentence);
      }
    }

    return sentences;
  }

  List<IntegrationSentence? Function()> _getGeneratorsForLevel() {
    switch (integrationLevel) {
      case 1:
        return [_genPronounDemo, _genGreetingNumber, _genPronounDemonstrative];
      case 2:
        return [_genSubjectObjectVerb, _genPronounDemo, _genFamilyVerb];
      case 3:
        return [_genSubjectObjectVerb, _genPronounAdjectiveBe, _genPossessionSentence, _genSubjectObjectVerbWithIdentity];
      case 4:
        return [_genSubjectObjectVerb, _genQuestionWordSentence, _genPronounAdjectiveBe, _genPossessionSentence];
      case 5:
        return [_genTimeSubjectObjectVerb, _genPossessiveNounSentence, _genSubjectObjectVerb, _genQuestionWordSentence, _genLocationSentence];
      case 6:
        return [_genTimeSubjectObjectVerb, _genImperativeSentence, _genEmotionSentence, _genTensedSentence, _genQuestionWordSentence];
      case 7:
      default:
        return [_genTimeSubjectObjectVerb, _genWithConstruction, _genTensedSentence, _genQuestionWordSentence, _genImperativeSentence, _genEmotionSentence, _genPossessiveNounSentence];
    }
  }

  // ── Level 1 Generators ──

  /// "I" → ኣነ (pronoun only + demonstrative + number)
  IntegrationSentence? _genPronounDemo() {
    final pronoun = _randomPronoun();
    final dem = TigrinyaDrillsData.demonstratives[_rng.nextInt(TigrinyaDrillsData.demonstratives.length)];

    final parts = [
      SentencePart(english: pronoun.english, tigrinya: pronoun.tigrinya, category: 'pronoun'),
      SentencePart(english: dem.english, tigrinya: dem.tigrinya, category: 'demonstrative'),
    ];

    return IntegrationSentence(
      parts: parts,
      fullEnglish: '${pronoun.english} ${dem.english}',
      fullTigrinya: '${pronoun.tigrinya} ${dem.tigrinya}',
    );
  }

  /// Greeting + number: e.g. "Hello, one" (for very basic combos)
  IntegrationSentence? _genGreetingNumber() {
    final greetings = TigrinyaDrillsData.greetings;
    final greeting = greetings[_rng.nextInt(greetings.length)];
    final number = TigrinyaDrillsData.numbers[_rng.nextInt(min(10, TigrinyaDrillsData.numbers.length))];

    final parts = [
      SentencePart(english: greeting.english, tigrinya: greeting.tigrinya, category: 'greeting'),
      SentencePart(english: number.english, tigrinya: number.tigrinya, category: 'number'),
    ];

    return IntegrationSentence(
      parts: parts,
      fullEnglish: '${greeting.english}, ${number.english}',
      fullTigrinya: '${greeting.tigrinya} ${number.tigrinya}',
    );
  }

  /// Pronoun + demonstrative
  IntegrationSentence? _genPronounDemonstrative() {
    final pronoun = _randomPronoun();
    final prep = TigrinyaDrillsData.prepositions[_rng.nextInt(TigrinyaDrillsData.prepositions.length)];

    final parts = [
      SentencePart(english: pronoun.english, tigrinya: pronoun.tigrinya, category: 'pronoun'),
      SentencePart(english: prep.english, tigrinya: prep.tigrinya, category: 'preposition'),
    ];

    return IntegrationSentence(
      parts: parts,
      fullEnglish: '${pronoun.english} ${prep.english}',
      fullTigrinya: '${pronoun.tigrinya} ${prep.tigrinya}',
    );
  }

  // ── Level 2+ Generators ──

  /// Subject + Object + Verb (SOV) — core sentence pattern
  IntegrationSentence? _genSubjectObjectVerb() {
    final pronoun = _randomPronoun();
    final verbIds = _getAvailableVerbIds();
    if (verbIds.isEmpty) return _genPronounDemo();

    final verbId = verbIds[_rng.nextInt(verbIds.length)];
    final verb = TigrinyaDrillsData.getVerbById(verbId);
    final conjugated = verb.conjugate(pronoun.id, Tense.present);
    if (conjugated == null) return _genPronounDemo();

    final cleanConj = conjugated.replaceAll('{', '').replaceAll('}', '');

    TigrinyaObject? obj;
    if (verb.categories.isNotEmpty) {
      final cat = verb.categories[_rng.nextInt(verb.categories.length)];
      final objs = TigrinyaDrillsData.compatibleObjects[cat] ?? [];
      if (objs.isNotEmpty) {
        obj = objs[_rng.nextInt(objs.length)];
      }
    }

    final parts = <SentencePart>[
      SentencePart(english: pronoun.english, tigrinya: pronoun.tigrinya, category: 'pronoun'),
    ];
    if (obj != null) {
      parts.add(SentencePart(english: obj.english, tigrinya: obj.tigrinya, category: 'object'));
    }
    parts.add(SentencePart(
      english: verb.english.replaceAll('To ', '').toLowerCase(),
      tigrinya: cleanConj,
      category: 'verb',
    ));

    final fullEn = parts.map((p) => p.english).join(' ');
    final fullTi = parts.map((p) => p.tigrinya).join(' ');

    return IntegrationSentence(parts: parts, fullEnglish: fullEn, fullTigrinya: fullTi);
  }

  /// Family vocab with verb
  IntegrationSentence? _genFamilyVerb() {
    final familyMembers = TigrinyaDrillsData.compatibleObjects['family'];
    if (familyMembers == null || familyMembers.isEmpty) return _genSubjectObjectVerb();

    final family = familyMembers[_rng.nextInt(familyMembers.length)];
    final pronoun = _randomPronoun();
    final verbIds = _getAvailableVerbIds();
    if (verbIds.isEmpty) return _genPronounDemo();

    final verbId = verbIds[_rng.nextInt(verbIds.length)];
    final verb = TigrinyaDrillsData.getVerbById(verbId);
    final conjugated = verb.conjugate(pronoun.id, Tense.present);
    if (conjugated == null) return _genPronounDemo();
    final cleanConj = conjugated.replaceAll('{', '').replaceAll('}', '');

    final parts = [
      SentencePart(english: pronoun.english, tigrinya: pronoun.tigrinya, category: 'pronoun'),
      SentencePart(english: family.english, tigrinya: family.tigrinya, category: 'family'),
      SentencePart(
        english: verb.english.replaceAll('To ', '').toLowerCase(),
        tigrinya: cleanConj,
        category: 'verb',
      ),
    ];

    return IntegrationSentence(
      parts: parts,
      fullEnglish: parts.map((p) => p.english).join(' '),
      fullTigrinya: parts.map((p) => p.tigrinya).join(' '),
    );
  }

  // ── Level 3+ Generators ──

  /// Pronoun + Adjective + "to be" verb
  IntegrationSentence? _genPronounAdjectiveBe() {
    final pronoun = _randomPronoun();
    final adjectives = TigrinyaDrillsData.adjectives;
    if (adjectives.isEmpty) return _genSubjectObjectVerb();

    final adj = adjectives[_rng.nextInt(adjectives.length)];
    final isPositive = _rng.nextBool();

    // Resolve gender/number for adjective
    String adjForm;
    if (['p6', 'p7', 'p8', 'p9', 'p10'].contains(pronoun.id)) {
      adjForm = adj.plural;
    } else if (['p3', 'p5'].contains(pronoun.id)) {
      adjForm = adj.female;
    } else {
      adjForm = adj.male;
    }

    final beVerb = isPositive
        ? VerbConjugator.bePositive[pronoun.id]!
        : VerbConjugator.beNegative[pronoun.id]!;
    final cleanBe = beVerb.replaceAll('{', '').replaceAll('}', '');

    final posNeg = isPositive ? 'is' : 'is not';
    final parts = [
      SentencePart(english: pronoun.english, tigrinya: pronoun.tigrinya, category: 'pronoun'),
      SentencePart(english: adj.english, tigrinya: adjForm, category: 'adjective'),
      SentencePart(english: posNeg, tigrinya: cleanBe, category: 'verb'),
    ];

    return IntegrationSentence(
      parts: parts,
      fullEnglish: '${pronoun.english} $posNeg ${adj.english}',
      fullTigrinya: '${pronoun.tigrinya} $adjForm $cleanBe',
    );
  }

  /// Possession sentence: "I have" / "I don't have"
  IntegrationSentence? _genPossessionSentence() {
    final pronoun = _randomPronoun();
    final isPositive = _rng.nextBool();
    final formKey = isPositive ? 'positive' : 'negative';
    final form = TigrinyaDrillsData.possession[formKey]![pronoun.id];
    if (form == null) return _genSubjectObjectVerb();

    final label = isPositive ? 'have' : "don't have";
    final parts = [
      SentencePart(english: pronoun.english, tigrinya: pronoun.tigrinya, category: 'pronoun'),
      SentencePart(english: label, tigrinya: form, category: 'possession'),
    ];

    return IntegrationSentence(
      parts: parts,
      fullEnglish: '${pronoun.english} $label',
      fullTigrinya: '${pronoun.tigrinya} $form',
    );
  }

  /// Identity: "I am a student"
  IntegrationSentence? _genSubjectObjectVerbWithIdentity() {
    if (TigrinyaDrillsData.identityItems.isEmpty) return _genSubjectObjectVerb();
    final item = TigrinyaDrillsData.identityItems[_rng.nextInt(TigrinyaDrillsData.identityItems.length)];

    return IntegrationSentence(
      parts: [SentencePart(english: item.english, tigrinya: item.tigrinya, category: 'identity')],
      fullEnglish: item.english,
      fullTigrinya: item.tigrinya,
    );
  }

  // ── Level 4+ Generators ──

  /// Question word + verb: "What does he eat?"
  IntegrationSentence? _genQuestionWordSentence() {
    final qws = TigrinyaDrillsData.questionWords;
    final qw = qws[_rng.nextInt(qws.length)];
    final pronoun = _randomPronoun();
    final verbIds = _getAvailableVerbIds();
    if (verbIds.isEmpty) return _genSubjectObjectVerb();

    final verbId = verbIds[_rng.nextInt(verbIds.length)];
    final verb = TigrinyaDrillsData.getVerbById(verbId);
    final conjugated = verb.conjugate(pronoun.id, Tense.present);
    if (conjugated == null) return _genSubjectObjectVerb();
    final cleanConj = conjugated.replaceAll('{', '').replaceAll('}', '');

    final parts = [
      SentencePart(english: qw.english, tigrinya: qw.tigrinya, category: 'questionWord'),
      SentencePart(english: pronoun.english, tigrinya: pronoun.tigrinya, category: 'pronoun'),
      SentencePart(
        english: verb.english.replaceAll('To ', '').toLowerCase(),
        tigrinya: cleanConj,
        category: 'verb',
      ),
    ];

    return IntegrationSentence(
      parts: parts,
      fullEnglish: '${qw.english} does ${pronoun.english.toLowerCase()} ${verb.english.replaceAll("To ", "").toLowerCase()}?',
      fullTigrinya: '${qw.tigrinya} $cleanConj',
    );
  }

  // ── Level 5+ Generators ──

  /// Time + Subject + Object + Verb
  IntegrationSentence? _genTimeSubjectObjectVerb() {
    final timeWord = TigrinyaDrillsData.timeWords[_rng.nextInt(TigrinyaDrillsData.timeWords.length)];
    final pronoun = _randomPronoun();
    final verbIds = _getAvailableVerbIds();
    if (verbIds.isEmpty) return _genSubjectObjectVerb();

    final verbId = verbIds[_rng.nextInt(verbIds.length)];
    final verb = TigrinyaDrillsData.getVerbById(verbId);
    final conjugated = verb.conjugate(pronoun.id, Tense.present);
    if (conjugated == null) return _genSubjectObjectVerb();
    final cleanConj = conjugated.replaceAll('{', '').replaceAll('}', '');

    TigrinyaObject? obj;
    if (verb.categories.isNotEmpty) {
      final cat = verb.categories[_rng.nextInt(verb.categories.length)];
      final objs = TigrinyaDrillsData.compatibleObjects[cat] ?? [];
      if (objs.isNotEmpty) obj = objs[_rng.nextInt(objs.length)];
    }

    final parts = <SentencePart>[
      SentencePart(english: timeWord.english, tigrinya: timeWord.tigrinya, category: 'time'),
      SentencePart(english: pronoun.english, tigrinya: pronoun.tigrinya, category: 'pronoun'),
    ];
    if (obj != null) {
      parts.add(SentencePart(english: obj.english, tigrinya: obj.tigrinya, category: 'object'));
    }
    parts.add(SentencePart(
      english: verb.english.replaceAll('To ', '').toLowerCase(),
      tigrinya: cleanConj,
      category: 'verb',
    ));

    return IntegrationSentence(
      parts: parts,
      fullEnglish: parts.map((p) => p.english).join(' '),
      fullTigrinya: parts.map((p) => p.tigrinya).join(' '),
    );
  }

  /// Possessive noun: "my house", "your father"
  IntegrationSentence? _genPossessiveNounSentence() {
    final items = TigrinyaDrillsData.nounPossessionItems;
    if (items.isEmpty) return _genSubjectObjectVerb();

    final item = items[_rng.nextInt(items.length)];
    final pronoun = _randomPronoun();
    final verbIds = _getAvailableVerbIds();
    if (verbIds.isEmpty) {
      return IntegrationSentence(
        parts: [SentencePart(english: item.english, tigrinya: item.tigrinya, category: 'nounPossession')],
        fullEnglish: item.english,
        fullTigrinya: item.tigrinya,
      );
    }

    final verbId = verbIds[_rng.nextInt(verbIds.length)];
    final verb = TigrinyaDrillsData.getVerbById(verbId);
    final conjugated = verb.conjugate(pronoun.id, Tense.present);
    if (conjugated == null) {
      return IntegrationSentence(
        parts: [SentencePart(english: item.english, tigrinya: item.tigrinya, category: 'nounPossession')],
        fullEnglish: item.english,
        fullTigrinya: item.tigrinya,
      );
    }
    final cleanConj = conjugated.replaceAll('{', '').replaceAll('}', '');

    final parts = [
      SentencePart(english: pronoun.english, tigrinya: pronoun.tigrinya, category: 'pronoun'),
      SentencePart(english: item.english, tigrinya: item.tigrinya, category: 'nounPossession'),
      SentencePart(
        english: verb.english.replaceAll('To ', '').toLowerCase(),
        tigrinya: cleanConj,
        category: 'verb',
      ),
    ];

    return IntegrationSentence(
      parts: parts,
      fullEnglish: parts.map((p) => p.english).join(' '),
      fullTigrinya: parts.map((p) => p.tigrinya).join(' '),
    );
  }

  /// Location sentence
  IntegrationSentence? _genLocationSentence() {
    final locations = TigrinyaDrillsData.locationWords;
    if (locations.isEmpty) return _genTimeSubjectObjectVerb();

    final location = locations[_rng.nextInt(locations.length)];
    final pronoun = _randomPronoun();

    final parts = [
      SentencePart(english: pronoun.english, tigrinya: pronoun.tigrinya, category: 'pronoun'),
      SentencePart(english: location.english, tigrinya: location.tigrinya, category: 'location'),
    ];

    return IntegrationSentence(
      parts: parts,
      fullEnglish: parts.map((p) => p.english).join(' '),
      fullTigrinya: parts.map((p) => p.tigrinya).join(' '),
    );
  }

  // ── Level 6+ Generators ──

  /// Imperative sentence
  IntegrationSentence? _genImperativeSentence() {
    final items = TigrinyaDrillsData.imperativeItems;
    if (items.isEmpty) return _genTimeSubjectObjectVerb();

    final item = items[_rng.nextInt(items.length)];
    return IntegrationSentence(
      parts: [SentencePart(english: item.english, tigrinya: item.tigrinya, category: 'imperative')],
      fullEnglish: item.english,
      fullTigrinya: item.tigrinya,
    );
  }

  /// Emotion/endearment sentence
  IntegrationSentence? _genEmotionSentence() {
    final items = TigrinyaDrillsData.emotionItems;
    if (items.isEmpty) return _genTimeSubjectObjectVerb();

    final item = items[_rng.nextInt(items.length)];
    return IntegrationSentence(
      parts: [SentencePart(english: item.english, tigrinya: item.tigrinya, category: 'emotion')],
      fullEnglish: item.english,
      fullTigrinya: item.tigrinya,
    );
  }

  /// Full tensed sentence (past, continuous, future, negative)
  IntegrationSentence? _genTensedSentence() {
    final tenses = [Tense.past, Tense.continuous, Tense.future, Tense.negative];
    final tense = tenses[_rng.nextInt(tenses.length)];
    final pronoun = _randomPronoun();
    final verbIds = _getAvailableVerbIds();
    if (verbIds.isEmpty) return _genSubjectObjectVerb();

    final verbId = verbIds[_rng.nextInt(verbIds.length)];
    final verb = TigrinyaDrillsData.getVerbById(verbId);
    final conjugated = verb.conjugate(pronoun.id, tense);
    if (conjugated == null) return _genSubjectObjectVerb();
    final cleanConj = conjugated.replaceAll('{', '').replaceAll('}', '');

    TigrinyaObject? obj;
    if (verb.categories.isNotEmpty) {
      final cat = verb.categories[_rng.nextInt(verb.categories.length)];
      final objs = TigrinyaDrillsData.compatibleObjects[cat] ?? [];
      if (objs.isNotEmpty) obj = objs[_rng.nextInt(objs.length)];
    }

    final tenseLabel = '[${tense.name}]';
    final parts = <SentencePart>[
      SentencePart(english: pronoun.english, tigrinya: pronoun.tigrinya, category: 'pronoun'),
    ];
    if (obj != null) {
      parts.add(SentencePart(english: obj.english, tigrinya: obj.tigrinya, category: 'object'));
    }
    parts.add(SentencePart(
      english: '${verb.english.replaceAll("To ", "").toLowerCase()} $tenseLabel',
      tigrinya: cleanConj,
      category: 'verb',
    ));

    return IntegrationSentence(
      parts: parts,
      fullEnglish: parts.map((p) => p.english).join(' '),
      fullTigrinya: parts.map((p) => p.tigrinya).join(' '),
    );
  }

  // ── Level 7 Generators ──

  /// With (ምስ) construction
  IntegrationSentence? _genWithConstruction() {
    final items = TigrinyaDrillsData.withConstructionItems;
    if (items.isEmpty) return _genTensedSentence();

    final item = items[_rng.nextInt(items.length)];
    return IntegrationSentence(
      parts: [SentencePart(english: item.english, tigrinya: item.tigrinya, category: 'withConstruction')],
      fullEnglish: item.english,
      fullTigrinya: item.tigrinya,
    );
  }

  // ── Helpers ──

  Pronoun _randomPronoun() {
    return TigrinyaDrillsData.pronouns[_rng.nextInt(TigrinyaDrillsData.pronouns.length)];
  }

  /// Returns verb IDs available at the current integration level.
  List<String> _getAvailableVerbIds() {
    switch (integrationLevel) {
      case 1:
        return []; // No verbs in unit 1
      case 2:
        return ['v_eat', 'v_drink', 'v_go', 'v_come', 'v_wait'];
      case 3:
        return ['v_eat', 'v_drink', 'v_go', 'v_come', 'v_wait'];
      case 4:
        return ['v_eat', 'v_drink', 'v_go', 'v_come', 'v_wait', 'v_speak', 'v_hear', 'v_know', 'v_read', 'v_write'];
      case 5:
        return ['v_eat', 'v_drink', 'v_go', 'v_come', 'v_wait', 'v_speak', 'v_hear', 'v_know', 'v_read', 'v_write'];
      case 6:
      case 7:
      default:
        return TigrinyaDrillsData.verbs.map((v) => v.id).toList();
    }
  }
}
