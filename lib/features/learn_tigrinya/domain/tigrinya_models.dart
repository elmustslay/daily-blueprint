// Domain models for the Tigrinya drill system.

enum Tense { present, past, continuous, future, negative }

enum DrillStage { teach, mcq, typing }

class Pronoun {
  final String id;
  final String tigrinya;
  final String translit;
  final String amharic;
  final String english;

  const Pronoun({
    required this.id,
    required this.tigrinya,
    required this.translit,
    required this.amharic,
    required this.english,
  });
}

class TigrinyaObject {
  final String tigrinya;
  final String? translit;
  final String amharic;
  final String english;

  const TigrinyaObject({
    required this.tigrinya,
    this.translit,
    required this.amharic,
    required this.english,
  });
}

class QuestionWord {
  final String id;
  final String tigrinya;
  final String translit;
  final String amharic;
  final String english;

  const QuestionWord({
    required this.id,
    required this.tigrinya,
    required this.translit,
    required this.amharic,
    required this.english,
  });
}

class ConjugationMap {
  final Map<String, String> forms;

  const ConjugationMap(this.forms);

  String? operator [](String pronounId) => forms[pronounId];

  List<String> get allForms => forms.values.toList();

  List<String> get availablePronounIds => forms.keys.toList();
}

class Adjective {
  final String id;
  final String english;
  final String amharic;
  final String male;
  final String female;
  final String plural;

  const Adjective({
    required this.id,
    required this.english,
    required this.amharic,
    required this.male,
    required this.female,
    required this.plural,
  });
}

class VerbStem {
  final String id;
  final String lemma;
  final String translit;
  final String english;
  final String amharic;
  final List<String> categories;
  final String presentStem;
  final String pastStem;
  final bool usesSoftK; // true if vocalic/pharyngeal (ኻ), false if consonant (ካ)

  const VerbStem({
    required this.id,
    required this.lemma,
    required this.translit,
    required this.english,
    required this.amharic,
    required this.categories,
    required this.presentStem,
    required this.pastStem,
    required this.usesSoftK,
  });
}

class Verb {
  final String id;
  final String lemma;
  final String translit;
  final String english;
  final String amharic;
  final List<String> categories;
  final ConjugationMap present;
  final ConjugationMap past;
  final ConjugationMap continuous;
  final ConjugationMap future;
  final ConjugationMap negative;

  const Verb({
    required this.id,
    required this.lemma,
    required this.translit,
    required this.english,
    required this.amharic,
    required this.categories,
    required this.present,
    required this.past,
    required this.continuous,
    required this.future,
    required this.negative,
  });

  ConjugationMap getMap(Tense tense) {
    switch (tense) {
      case Tense.present:
        return present;
      case Tense.past:
        return past;
      case Tense.continuous:
        return continuous;
      case Tense.future:
        return future;
      case Tense.negative:
        return negative;
    }
  }

  String? conjugate(String pronounId, Tense tense) {
    return getMap(tense)[pronounId];
  }
}

enum DrillModuleType { pronoun, verb, questionWord, number, time, adjective, greeting, possession, demonstrative, phrase, preposition, family, possessivePronoun, sentence, nounPossession, verbObjectSuffix, imperative, locationWord, existential, intimatePhrase, compoundSubject, identityToBe, emotion, withConstruction, questionWordBasic }

class DrillModule {
  final String id;
  final String name;
  final String description;
  final DrillModuleType type;
  final List<String> verbIds;
  final Map<Tense, String> patternRules;

  const DrillModule({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.verbIds = const [],
    this.patternRules = const {},
  });
}

class DrillCard {
  final Pronoun? pronoun;
  final Verb? verb;
  final TigrinyaObject? object;
  final QuestionWord? questionWord;
  final Adjective? adjective;
  final Tense tense;
  final String correctAnswer;
  final String promptText;

  const DrillCard({
    this.pronoun,
    this.verb,
    this.object,
    this.questionWord,
    this.adjective,
    required this.tense,
    required this.correctAnswer,
    required this.promptText,
  });
}

class AnswerResult {
  final bool isCorrect;
  final String userAnswer;
  final String expectedAnswer;
  final String? diffHighlight;

  const AnswerResult({
    required this.isCorrect,
    required this.userAnswer,
    required this.expectedAnswer,
    this.diffHighlight,
  });
}
