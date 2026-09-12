import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/core/storage/shared_prefs.dart';
import 'package:my_app/features/learn_tigrinya/data/tigrinya_drills_data.dart';
import 'package:my_app/features/learn_tigrinya/domain/drill_engine.dart';
import 'package:my_app/features/learn_tigrinya/data/hardcoded_verbs.dart';
import 'package:my_app/features/learn_tigrinya/domain/tigrinya_models.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await SharedPrefsLogic.init();

  group('Tigrinya Drills & Spirantization Data Integrity Tests', () {
    test('All verbs with hardcoded entries match dynamic conjugator output', () {
      final hardcodedMap = {for (final v in HardcodedVerbs.verbs) v.id: v};
      final unverified = <String>[];

      for (final dynamicVerb in TigrinyaDrillsData.verbs) {
        final hardcodedVerb = hardcodedMap[dynamicVerb.id];

        if (hardcodedVerb == null) {
          unverified.add(dynamicVerb.id);
          continue;
        }

        for (final tense in Tense.values) {
          final dynamicForms = dynamicVerb.getMap(tense);
          final hardcodedForms = hardcodedVerb.getMap(tense);

          expect(dynamicForms.allForms.length, equals(10),
              reason: 'Verb ${dynamicVerb.id} missing forms in ${tense.name}');

          for (final p in dynamicForms.forms.keys) {
            expect(dynamicForms.forms[p], equals(hardcodedForms.forms[p]),
                reason: '${dynamicVerb.id} ${tense.name} $p mismatch: dynamic=${dynamicForms.forms[p]}, hardcoded=${hardcodedForms.forms[p]}');
          }
        }
      }

      if (unverified.isNotEmpty) {
        // ignore: avoid_print
        print('⚠️  UNVERIFIED VERBS (not in hardcoded_verbs.dart): ${unverified.join(', ')}');
        print('   Add these to hardcoded_verbs.dart and have them reviewed by a native speaker.');
      }

      // Confirm we verified at least the ones we have
      final verified = TigrinyaDrillsData.verbs.length - unverified.length;
      // ignore: avoid_print
      print('✅ $verified/${TigrinyaDrillsData.verbs.length} verbs cross-checked against hardcoded reference.');
    });

    test('Post-consonantal past tense conjugations use unspirantized hard K (-ካ, -ኪ, -ኩም, -ክን)', () {
      final consonantVerbs = ['v_go', 'v_read', 'v_ride', 'v_speak', 'v_know', 'v_meet', 'v_pay'];
      
      for (final verbId in consonantVerbs) {
        final verb = TigrinyaDrillsData.getVerbById(verbId);
        final p2 = verb.past.forms['p2']!; // You (m.)
        final p3 = verb.past.forms['p3']!; // You (f.)
        final p7 = verb.past.forms['p7']!; // You (pl. m.)
        final p8 = verb.past.forms['p8']!; // You (pl. f.)

        expect(p2, contains('ካ'), reason: '$verbId p2 past should use hard -ካ');
        expect(p3, contains('ኪ'), reason: '$verbId p3 past should use hard -ኪ');
        expect(p7, contains('ኩም'), reason: '$verbId p7 past should use hard -ኩም');
        expect(p8, contains('ክን'), reason: '$verbId p8 past should use hard -ክን');
      }
    });

    test('Post-vocalic past tense conjugations use spirantized soft K (-ኻ, -ኺ, -ኹም, -ኽን)', () {
      final vocalicVerbs = ['v_drink', 'v_see', 'v_want', 'v_wait'];
      
      for (final verbId in vocalicVerbs) {
        final verb = TigrinyaDrillsData.getVerbById(verbId);
        final p2 = verb.past.forms['p2']!;
        final p3 = verb.past.forms['p3']!;

        expect(p2, contains('ኻ'), reason: '$verbId p2 past should use soft -ኻ');
        expect(p3, contains('ኺ'), reason: '$verbId p3 past should use soft -ኺ');
      }
    });

    test('Every module generates deck without errors and MCQ options are valid', () {
      for (final module in TigrinyaDrillsData.modules) {
        for (final tense in Tense.values) {
          final engine = DrillEngine(module: module, tense: tense);
          engine.generateDeck();

          expect(engine.deckLength, greaterThan(0),
              reason: 'Module ${module.id} produced empty deck in ${tense.name}');

          final expectedLen = 8;
          final mcq = engine.generateMcqOptions();
          expect(mcq.length, equals(expectedLen),
              reason: 'MCQ options should return exactly $expectedLen options');
          expect(mcq.toSet().length, equals(expectedLen),
              reason: 'MCQ options should be $expectedLen distinct choices');
        }
      }
    });

    test('SRS Review deck generates mixed cards without errors', () {
      final dummyModule = TigrinyaDrillsData.modules.first;
      final engine = DrillEngine(module: dummyModule, tense: Tense.present);
      engine.generateReviewDeck();

      expect(engine.deckLength, equals(20),
          reason: 'Review deck should generate exactly 20 cards');
    });
  });
}
