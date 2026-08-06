import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/daily_plan/data/daily_plan_data.dart';
import 'package:my_app/features/micro_macro_calorie_track/data/ingredients_data.dart';

DateTime parseTime(String timeStr, {bool isEnd = false}) {
  final parts = timeStr.split('-');
  String part = isEnd ? parts[1].trim() : parts[0].trim();
  
  if (!part.contains('am') && !part.contains('pm')) {
    final amPm = parts[1].replaceAll(RegExp(r'[^a-zA-Z]'), '').trim();
    part = '$part $amPm';
  }
  
  final formatParts = part.split(' ');
  final timeParts = formatParts[0].split(':');
  int hour = int.parse(timeParts[0]);
  int min = int.parse(timeParts[1]);
  if (formatParts[1] == 'pm' && hour != 12) hour += 12;
  if (formatParts[1] == 'am' && hour == 12) hour = 0;
  
  return DateTime(2026, 1, 1, hour, min);
}

void main() {
  setUp(() {
    DailyPlanData.mockCurrentDate = null;
  });

  group('Protocol Rules based on reasoning.txt', () {

    test('Rule 1: Calcium explicitly at Lunch (to bind oxalates) and Whey explicitly at Dinner (to block iron)', () {
      for (final entry in DailyPlanData.schedules.entries) {
        final schedule = entry.value;
        for (final item in schedule) {
          final isLunch = item.title.toLowerCase().contains('lunch');
          final isDinner = item.title.toLowerCase().contains('dinner');
          
          final hasCalcium = item.details.any((d) => d.toLowerCase().contains('calcium citrate')) ||
              item.mealRecord?.items.any((i) => i.ingredient == IngredientsData.calciumCitrate) == true;
          
          final hasWhey = item.details.any((d) => d.toLowerCase().contains('whey isolate')) ||
              item.mealRecord?.items.any((i) => i.ingredient == IngredientsData.wheyIsolate) == true;

          if (hasCalcium && !isLunch) {
            final isGrabThings = item.title.toLowerCase().contains('grab things');
            if (!isGrabThings) { // grab things is allowed to have it since it's just packing
              fail('Calcium found outside of Lunch on ${entry.key} at ${item.time} (${item.title})');
            }
          }

          if (hasWhey) {
            // Note: Saturday afternoon snack or Wednesday pre-workout study has whey, which are verified exceptions
            final isSatSnack = entry.key == DailyPlanData.sat && item.title.toLowerCase().contains('snack');
            final isWedPreCardio = entry.key == DailyPlanData.wed && item.title.toLowerCase().contains('study');
            if (!isDinner && !isSatSnack && !isWedPreCardio) {
              fail('Whey found outside of Dinner on ${entry.key} at ${item.time} (${item.title})');
            }
          }
        }
      }
    });

    test('Rule 2: 0 calcium capsules on Tue/Fri', () {
      for (final day in [DailyPlanData.tue, DailyPlanData.fri]) {
        final schedule = DailyPlanData.schedules[day]!;
        for (final item in schedule) {
          final hasCalcium = item.details.any((d) => d.toLowerCase().contains('calcium citrate')) ||
              item.mealRecord?.items.any((i) => i.ingredient == IngredientsData.calciumCitrate) == true;
          expect(hasCalcium, isFalse, reason: 'Calcium found on $day at ${item.time}');
        }
      }
    });

    test('Rule 3: Copper vs Zinc isolation', () {
      for (final entry in DailyPlanData.schedules.entries) {
        final schedule = entry.value;
        for (final item in schedule) {
          final hasCopper = item.details.any((d) => d.toLowerCase().contains('copper'));
          final hasZinc = item.details.any((d) => d.toLowerCase().contains('zinc'));
          if (hasCopper && hasZinc) {
            fail('Copper and Zinc taken in the same time block on ${entry.key} at ${item.time}');
          }
        }
      }
    });

    test('Rule 4: NAC separated from Copper/Zinc by at least 2 hours', () {
      for (final entry in DailyPlanData.schedules.entries) {
        final schedule = entry.value;
        
        final nacItems = schedule.where((i) => i.details.any((d) => d.toLowerCase().contains('nac')));
        final mineralItems = schedule.where((i) => i.details.any((d) => d.toLowerCase().contains('copper') || d.toLowerCase().contains('zinc')));
        
        for (final nac in nacItems) {
          final nacTime = parseTime(nac.time, isEnd: true);
          for (final mineral in mineralItems) {
            final isGrabThings = mineral.title.toLowerCase().contains('grab things');
            if (isGrabThings) continue; // Packing doesn't count

            final mineralTime = parseTime(mineral.time);
            final diffMins = mineralTime.difference(nacTime).inMinutes.abs();
            
            // 2 hours = 120 mins
            expect(diffMins, greaterThanOrEqualTo(120), reason: 'NAC and Copper/Zinc too close on ${entry.key}');
          }
        }
      }
    });

    test('Rule 5: Calcium vs Bedtime Magnesium separated by at least 1.5 hours', () {
      for (final entry in DailyPlanData.schedules.entries) {
        final schedule = entry.value;
        
        final calciumItems = schedule.where((i) => i.details.any((d) => d.toLowerCase().contains('calcium citrate')));
        final magItems = schedule.where((i) => i.details.any((d) => d.toLowerCase().contains('magnesium')));
        
        for (final calc in calciumItems) {
           final isGrabThings = calc.title.toLowerCase().contains('grab things');
           if (isGrabThings) continue; // Packing doesn't count

          final calcTime = parseTime(calc.time, isEnd: true);
          for (final mag in magItems) {
            final magTime = parseTime(mag.time);
            final diffMins = magTime.difference(calcTime).inMinutes.abs();
            
            // 1.5 hours = 90 mins
            expect(diffMins, greaterThanOrEqualTo(90), reason: 'Calcium and Magnesium too close on ${entry.key}');
          }
        }
      }
    });

    test('Rule 6: Calcium vs Adderall IR by > 3 hours on Sat/Sun', () {
      for (final day in [DailyPlanData.sat, DailyPlanData.sun]) {
        final schedule = DailyPlanData.schedules[day]!;
        
        final calciumItems = schedule.where((i) => i.details.any((d) => d.toLowerCase().contains('calcium citrate')));
        final adderallItems = schedule.where((i) => i.details.any((d) => d.toLowerCase().contains('adderall')));
        
        for (final calc in calciumItems) {
          final calcTime = parseTime(calc.time);
          for (final add in adderallItems) {
            final addTime = parseTime(add.time);
            final diffMins = calcTime.difference(addTime).inMinutes.abs();
            
            // 3 hours = 180 mins
            expect(diffMins, greaterThanOrEqualTo(180), reason: 'Calcium and Adderall too close on $day');
          }
        }
      }
    });

    test('Rule 7: Psyllium Husk vs Any Supplement by > 1 hour before or 2 hours after', () {
      for (final entry in DailyPlanData.schedules.entries) {
        final schedule = entry.value;
        
        final fiberItems = schedule.where((i) => i.details.any((d) => d.toLowerCase().contains('husk')));
        
        final supplementKeywords = ['calcium', 'zinc', 'copper', 'nac', 'omega', 'magnesium', 'vitamin', 'd3'];
        final supplementItems = schedule.where((i) {
          if (i.title.toLowerCase().contains('grab things')) return false; // packing
          return i.details.any((d) => supplementKeywords.any((kw) => d.toLowerCase().contains(kw)));
        });

        for (final fiber in fiberItems) {
          final isFiberGrab = fiber.title.toLowerCase().contains('grab things');
          if (isFiberGrab) continue;

          final fiberStart = parseTime(fiber.time);
          final fiberEnd = parseTime(fiber.time, isEnd: true);

          for (final supp in supplementItems) {
            final suppStart = parseTime(supp.time);
            final suppEnd = parseTime(supp.time, isEnd: true);

            bool isValidBefore = suppEnd.isBefore(fiberStart.subtract(const Duration(minutes: 59))); // 1 hr before
            bool isValidAfter = suppStart.isAfter(fiberEnd.add(const Duration(minutes: 119))); // 2 hrs after

            expect(isValidBefore || isValidAfter, isTrue, 
              reason: 'Fiber at ${fiber.time} too close to supplement at ${supp.time} on ${entry.key}. Must be 1 hr before or 2 hrs after.');
          }
        }
      }
    });
    test('Rule 8: Amino acid & Anti-Catabolic protection coverage throughout the day', () {
      // We model protein digestion times and insulin spikes to ensure the user is "protected".
      // - Whey: Hits fast (0h delay), lasts ~2.5 hours.
      // - Whole Food (Meat/Eggs): Hits slower (0.5h delay), lasts ~6 hours.
      // - Fiber: Adds 1 hour to whole food digestion (lasts ~7 hours).
      // - Casein: Hits slower (0.5h delay), lasts ~7.5 hours (overnight protection).
      // - Cluster Dextrin: Provides an insulin spike (highly anti-catabolic), protecting muscle during workouts for ~2.5 hours.

      DateTime fixMidnight(DateTime time) {
        if (time.hour < 4) {
          return time.add(const Duration(days: 1));
        }
        return time;
      }

      for (final entry in DailyPlanData.schedules.entries) {
        final day = entry.key;
        final schedule = entry.value;
        
        List<Map<String, dynamic>> coverageWindows = [];
        final wakeupItem = schedule.firstWhere((i) => i.title.contains('Wakeup'));
        DateTime wakeupTime = fixMidnight(parseTime(wakeupItem.time, isEnd: true));
        
        for (final item in schedule) {
          final startTime = fixMidnight(parseTime(item.time));
          final mealRecord = item.mealRecord;
          
          if (mealRecord != null) {
            final nutrition = mealRecord.totalNutrition;
            final protein = nutrition.protein;
            
            final hasWhey = mealRecord.items.any((i) => i.ingredient == IngredientsData.wheyIsolate);
            final hasCasein = mealRecord.items.any((i) => i.ingredient == IngredientsData.casein);
            final hasDextrin = mealRecord.items.any((i) => i.ingredient == IngredientsData.clusterDextrin);
            
            final hasFiber = (nutrition.microNutrients['Fiber (g)'] ?? 0.0) >= 5.0;

            if (hasDextrin) {
              coverageWindows.add({
                'source': 'Cluster Dextrin Insulin Spike (${item.title})',
                'start': startTime,
                'end': startTime.add(const Duration(hours: 2, minutes: 30)),
              });
            }

            if (protein >= 10.0) {
              if (hasWhey) {
                coverageWindows.add({
                  'source': 'Fast Protein [Whey] (${item.title})',
                  'start': startTime,
                  'end': startTime.add(const Duration(hours: 2, minutes: 30)),
                });
              } else if (hasCasein) {
                coverageWindows.add({
                  'source': 'Slow Protein [Casein] (${item.title})',
                  'start': startTime.add(const Duration(minutes: 30)),
                  'end': startTime.add(const Duration(hours: 8)), // 0.5h delay + 7.5h duration
                });
              } else {
                final durationHours = hasFiber ? 7 : 6;
                coverageWindows.add({
                  'source': 'Whole Food Protein (${item.title}, ${protein.toStringAsFixed(1)}g)',
                  'start': startTime.add(const Duration(minutes: 30)),
                  'end': startTime.add(Duration(hours: durationHours, minutes: 30)), // 0.5h delay + duration
                });
              }
            }
          }
        }
        
        coverageWindows.sort((a, b) => (a['start'] as DateTime).compareTo(b['start'] as DateTime));
        
        // We start caring 1 hour after wakeup
        DateTime currentTime = wakeupTime.add(const Duration(hours: 1));
        DateTime endOfDay = wakeupTime.add(const Duration(hours: 24)); // Until next morning
        
        for (var window in coverageWindows) {
          final start = window['start'] as DateTime;
          final end = window['end'] as DateTime;

          if (start.isAfter(currentTime)) {
             final gap = start.difference(currentTime);
             // Since we now track dextrin/insulin protection, our test can be much stricter!
             // Maximum allowed completely unprotected gap is 1.5 hours.
             expect(gap.inMinutes, lessThanOrEqualTo(90), 
                 reason: 'Unprotected catabolic gap of ${gap.inHours}h ${gap.inMinutes % 60}m on $day between '
                         '${currentTime.hour}:${currentTime.minute.toString().padLeft(2, '0')} and '
                         '${start.hour}:${start.minute.toString().padLeft(2, '0')}. '
                         'Neither amino acids nor insulin spikes are protecting you here!');
          }
          if (end.isAfter(currentTime)) {
            currentTime = end;
          }
        }
      }
    });

    test('Rule 9: Fat-Soluble Vitamins must be taken with a fat source', () {
      for (final entry in DailyPlanData.schedules.entries) {
        for (final item in entry.value) {
          final mealRecord = item.mealRecord;
          if (mealRecord != null) {
            bool hasFatSoluble = mealRecord.items.any((i) => 
                i.ingredient == IngredientsData.d3K2 || 
                i.ingredient == IngredientsData.standaloneK2 || 
                i.ingredient == IngredientsData.vitaminE || 
                i.ingredient == IngredientsData.omega3);
                
            if (hasFatSoluble) {
              final fat = mealRecord.totalNutrition.fat;
              expect(fat, greaterThanOrEqualTo(5.0), reason: 'Fat-soluble vitamin taken without sufficient dietary fat (${fat.toStringAsFixed(1)}g fat) on ${entry.key} at ${item.time}');
            }
          }
        }
      }
    });

    test('Rule 10: Skincare Moisture Levels (Dry vs Damp)', () {
      for (final entry in DailyPlanData.schedules.entries) {
        for (final item in entry.value) {
          final details = item.details.join(' ').toLowerCase();
          
          if (details.contains('retinol') || details.contains('bha') || details.contains('aha')) {
            expect(details, contains('bone dry'), reason: 'Active acids/retinoids must be applied to BONE DRY skin to prevent irritation on ${entry.key}');
          }
          if (details.contains('ascorbyl') || details.contains('joseon') || details.contains('alpha-arbutin')) {
            expect(details, contains('slightly damp'), reason: 'Vitamin C and Arbutin must be applied to slightly damp skin for absorption on ${entry.key}');
          }
        }
      }
    });

    test('Rule 11: Kiwi Enamel Protection', () {
      for (final entry in DailyPlanData.schedules.entries) {
        for (final item in entry.value) {
          final details = item.details.join(' ').toLowerCase();
          
          final hasKiwi = item.mealRecord?.items.any((i) => i.ingredient.id == 'kiwi') ?? false;
          
          if (hasKiwi) {
            expect(details, contains('swish water'), reason: 'Eating kiwi must be followed by swishing water to protect tooth enamel from acidity on ${entry.key} at ${item.time}');
          }
        }
      }
    });

    test('Rule 12: Dehumidifier Protocol for Mold Prevention', () {
      for (final entry in DailyPlanData.schedules.entries) {
        final schedule = entry.value;
        
        // Ensure 55% before shower
        final showerItem = schedule.firstWhere((i) => i.title.toLowerCase().contains('shower') || i.title.toLowerCase().contains('get ready'));
        expect(showerItem.details.join(' ').toLowerCase(), contains('dehumidifier to 55%'), reason: 'Dehumidifier must be 55% during shower/prep on ${entry.key}');
        
        // Ensure ends with 45%
        final nightSupplement = schedule.firstWhere((i) => i.title.toLowerCase().contains('night supplement') || i.title.toLowerCase().contains('get ready'));
        expect(nightSupplement.details.join(' ').toLowerCase(), contains('dehumidifier to 45%'), reason: 'Dehumidifier must be set to 45% after prep/night to prevent mold on ${entry.key}');
      }
    });
  });
}
