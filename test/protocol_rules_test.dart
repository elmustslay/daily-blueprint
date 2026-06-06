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
            // Note: Saturday afternoon snack has whey, which is an exception we verified with the user
            final isSatSnack = entry.key == DailyPlanData.sat && item.title.toLowerCase().contains('snack');
            if (!isDinner && !isSatSnack) {
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
  });
}
