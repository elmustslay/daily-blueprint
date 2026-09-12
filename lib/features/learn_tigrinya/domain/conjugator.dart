import 'package:my_app/features/learn_tigrinya/domain/tigrinya_models.dart';

class VerbConjugator {
  /// The "to have" verb is used to build the continuous tense.
  static const Map<String, String> _havePositive = {
    'p1': '{ኣለኹ}', 'p2': '{ኣለኻ}', 'p3': '{ኣለኺ}', 'p4': '{ኣሎ}', 'p5': '{ኣላ}',
    'p6': '{ኣለና}', 'p7': '{ኣለኹም}', 'p8': '{ኣለኽን}', 'p9': '{ኣለዉ}', 'p10': '{ኣለዋ}',
  };

  /// The "to be" verb is used to build the future tense and adjective sentences.
  static const Map<String, String> bePositive = {
    'p1': '{እየ}', 'p2': '{ኢኻ}', 'p3': '{ኢኺ}', 'p4': '{እዩ}', 'p5': '{እያ}',
    'p6': '{ኢና}', 'p7': '{ኢኹም}', 'p8': '{ኢኽን}', 'p9': '{እዮም}', 'p10': '{እየን}',
  };

  /// The negative "to be" verb.
  static const Map<String, String> beNegative = {
    'p1': '{ኣይኮንኩን}', 'p2': '{ኣይኮንካን}', 'p3': '{ኣይኮንክን}', 'p4': '{ኣይኮነን}', 'p5': '{ኣይኮነትን}',
    'p6': '{ኣይኮንናን}', 'p7': '{ኣይኮንኩምን}', 'p8': '{ኣይኮንክንን}', 'p9': '{ኣይኮኑን}', 'p10': '{ኣይኮናን}',
  };

  /// Generates a fully populated Verb given the present and past conjugations.
  static Verb generate({
    required String id,
    required String lemma,
    required String translit,
    required String english,
    required String amharic,
    required List<String> categories,
    required ConjugationMap present,
    required ConjugationMap past,
  }) {
    final continuousForms = <String, String>{};
    final futureForms = <String, String>{};
    final negativeForms = <String, String>{};

    for (final p in present.forms.keys) {
      final presentForm = present.forms[p]!;
      
      // CONTINUOUS: Present + '{ኣለኹ/ኣለኻ...}'
      continuousForms[p] = '$presentForm ${_havePositive[p]!}';

      // Parse the present prefix and the rest of the word
      // e.g. '{እ}በልዕ' -> prefix='እ', rest='በልዕ'
      final match = RegExp(r'^\{([^}]+)\}(.*)$').firstMatch(presentForm);
      if (match == null) {
        throw Exception('Present form must start with a brace-enclosed prefix for $id $p');
      }
      final presentPrefix = match.group(1)!;
      final stem = match.group(2)!;

      // Determine Future and Negative prefixes based on the Present prefix
      String futurePrefix;
      String negativePrefix;

      switch (presentPrefix) {
        case 'እ':
          futurePrefix = '{ክ}';
          negativePrefix = '{ኣይ}';
          break;
        case 'ት':
          futurePrefix = '{ክት}';
          negativePrefix = '{ኣይት}';
          break;
        case 'ይ':
          futurePrefix = '{ክ}';
          negativePrefix = '{ኣይ}';
          break;
        case 'ን':
          futurePrefix = '{ክን}';
          negativePrefix = '{ኣይን}';
          break;
        
        // Variants for verbs like "to read" (ምንባብ) that use ኣ, ተ, የ, ነ
        case 'ኣ':
          futurePrefix = '{ከ}';
          negativePrefix = '{ኣየ}';
          break;
        case 'ተ':
          futurePrefix = '{ክተ}';
          negativePrefix = '{ኣይተ}';
          break;
        case 'የ':
          futurePrefix = '{ከ}';
          negativePrefix = '{ኣየ}';
          break;
        case 'ነ':
          futurePrefix = '{ክነ}';
          negativePrefix = '{ኣይነ}';
          break;
        default:
          throw Exception('Unknown present prefix: $presentPrefix in $id $p');
      }

      // FUTURE: FuturePrefix + stem + ' {እየ/ኢኻ...}'
      futureForms[p] = '$futurePrefix$stem ${bePositive[p]!}';

      // NEGATIVE: NegativePrefix + stem + '{ን}'
      String rawNegative = '$negativePrefix$stem{ን}';
      negativeForms[p] = rawNegative.replaceAll('}{', '');
    }

    return Verb(
      id: id,
      lemma: lemma,
      translit: translit,
      english: english,
      amharic: amharic,
      categories: categories,
      present: present,
      past: past,
      continuous: ConjugationMap(continuousForms),
      future: ConjugationMap(futureForms),
      negative: ConjugationMap(negativeForms),
    );
  }
}

/// Dynamic Noun Possessor Engine for Tigrinya morphophonemics.
class NounPossessor {
  static const Map<String, String> pronounEnglishMap = {
    'p1': 'my',
    'p2': 'your (m.)',
    'p3': 'your (f.)',
    'p4': 'his',
    'p5': 'her',
    'p6': 'our',
    'p7': 'your (pl.)',
    'p8': 'your (pl. f.)',
    'p9': 'their (m.)',
    'p10': 'their (f.)',
  };

  static const Map<String, String> pronounAmharicMap = {
    'p1': 'የኔ',
    'p2': 'የአንተ',
    'p3': 'የአንቺ',
    'p4': 'የሱ',
    'p5': 'የሷ',
    'p6': 'የኛ',
    'p7': 'የእናንተ',
    'p8': 'የእናንተ (ሴ)',
    'p9': 'የነሱ',
    'p10': 'የነሱ (ሴ)',
  };

  /// Returns a map of pronounId -> possessed Tigrinya noun string for explicit irregular nouns.
  static Map<String, String> getPossessedForms(String nounId) {
    switch (nounId) {
      case 'father': // ኣቦ
        return const {
          'p1': 'ኣቦይ', 'p2': 'ኣቦኻ', 'p3': 'ኣቦኺ', 'p4': 'ኣቦኡ', 'p5': 'ኣቦኣ',
          'p6': 'ኣቦና', 'p7': 'ኣቦኹም', 'p8': 'ኣቦኽን', 'p9': 'ኣቦኦም', 'p10': 'ኣቦአን',
        };
      case 'mother': // ኣደ -> ኣዲ- before vowel suffixes
        return const {
          'p1': 'ኣደይ', 'p2': 'ኣደኻ', 'p3': 'ኣደኺ', 'p4': 'ኣዲኡ', 'p5': 'ኣዲኣ',
          'p6': 'ኣደና', 'p7': 'ኣደኹም', 'p8': 'ኣደኽን', 'p9': 'ኣዲኦም', 'p10': 'ኣዲአን',
        };
      case 'brother': // ሓው
        return const {
          'p1': 'ሓወይ', 'p2': 'ሓውኻ', 'p3': 'ሓውኺ', 'p4': 'ሓዉ', 'p5': 'ሓዋ',
          'p6': 'ሓውና', 'p7': 'ሓውኹም', 'p8': 'ሓውኽን', 'p9': 'ሓዎም', 'p10': 'ሓወን',
        };
      case 'sister': // ሓፍቲ
        return const {
          'p1': 'ሓፍተይ', 'p2': 'ሓፍትኻ', 'p3': 'ሓፍትኺ', 'p4': 'ሓፍቱ', 'p5': 'ሓፍታ',
          'p6': 'ሓፍትና', 'p7': 'ሓፍትኹም', 'p8': 'ሓፍትኽን', 'p9': 'ሓፍቶም', 'p10': 'ሓፍተን',
        };
      case 'head': // ርእሲ
        return const {
          'p1': 'ርእሰይ', 'p2': 'ርእስኻ', 'p3': 'ርእስኺ', 'p4': 'ርእሱ', 'p5': 'ርእሳ',
          'p6': 'ርእስና', 'p7': 'ርእስኹም', 'p8': 'ርእስኽን', 'p9': 'ርእሶም', 'p10': 'ርእሰን',
        };
      case 'house': // ገዛ
        return const {
          'p1': 'ገዛይ', 'p2': 'ገዛኻ', 'p3': 'ገዛኺ', 'p4': 'ገዛኡ', 'p5': 'ገዛኣ',
          'p6': 'ገዛና', 'p7': 'ገዛኹም', 'p8': 'ገዛኽን', 'p9': 'ገዛኦም', 'p10': 'ገዛአን',
        };
      case 'car': // መኪና
        return const {
          'p1': 'መኪናይ', 'p2': 'መኪናኻ', 'p3': 'መኪናኺ', 'p4': 'መኪናኡ', 'p5': 'መኪናኣ',
          'p6': 'መኪናና', 'p7': 'መኪናኹም', 'p8': 'መኪናኽን', 'p9': 'መኪናኦም', 'p10': 'መኪናአን',
        };
      case 'hand': // ኢድ
        return const {
          'p1': 'ኢደይ', 'p2': 'ኢድካ', 'p3': 'ኢድኪ', 'p4': 'ኢዱ', 'p5': 'ኢዳ',
          'p6': 'ኢድና', 'p7': 'ኢድኩም', 'p8': 'ኢድክን', 'p9': 'ኢዶም', 'p10': 'ኢደን',
        };
      case 'heart': // ልቢ
        return const {
          'p1': 'ልበይ', 'p2': 'ልብኻ', 'p3': 'ልብኺ', 'p4': 'ልቡ', 'p5': 'ልባ',
          'p6': 'ልብና', 'p7': 'ልብኹም', 'p8': 'ልብኽን', 'p9': 'ልቦም', 'p10': 'ልበን',
        };
      case 'eye': // ዓይኒ
        return const {
          'p1': 'ዓይነይ', 'p2': 'ዓይንኻ', 'p3': 'ዓይንኺ', 'p4': 'ዓይኑ', 'p5': 'ዓይና',
          'p6': 'ዓይንና', 'p7': 'ዓይንኹም', 'p8': 'ዓይንኽን', 'p9': 'ዓይኖም', 'p10': 'ዓይነን',
        };
      default:
        throw Exception('Unknown nounId for possession: $nounId');
    }
  }
}
