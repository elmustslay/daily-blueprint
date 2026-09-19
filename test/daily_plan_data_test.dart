import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/core/storage/shared_prefs.dart';
import 'package:my_app/features/daily_plan/data/daily_plan_data.dart';
import 'package:my_app/features/shopping_list/presentation/shopping_list_screen.dart';
import 'package:my_app/features/micro_macro_calorie_track/data/ingredients_data.dart';

void main() {
  setUp(() {
    DailyPlanData.mockCurrentDate = null;
  });

  tearDown(() {
    DailyPlanData.mockCurrentDate = null;
  });

  test('Laundry cycle instructions contain dry on low heat', () {
    final monSchedule = DailyPlanData.schedules[DailyPlanData.mon]!;
    
    // Find items related to laundry face towels and bath towels
    final faceTowelsItem = monSchedule.firstWhere((item) => item.details.any((d) => d.text.contains('Bamboo Washcloths')));
    final bathTowelsItem = monSchedule.firstWhere((item) => item.details.any((d) => d.text.contains('Bath Towels')));

    final faceTowelsDetail = faceTowelsItem.details.firstWhere((d) => d.text.contains('Bamboo Washcloths'));
    final bathTowelsDetail = bathTowelsItem.details.firstWhere((d) => d.text.contains('Bath Towels'));

    expect(faceTowelsDetail.text, contains('Dry on LOW heat'));
    expect(bathTowelsDetail.text, contains('Dry on LOW heat'));
  });

  test('Bath towels use Bleach', () {
    DailyPlanData.mockCurrentDate = DateTime(2026, 4, 15);
    final monSchedule = DailyPlanData.schedules[DailyPlanData.mon]!;
    final bathTowelsItem = monSchedule.firstWhere((item) => item.details.any((d) => d.text.contains('Bath Towels')));
    final bathTowelsDetail = bathTowelsItem.details.firstWhere((d) => d.text.contains('Bath Towels'));
    
    expect(bathTowelsDetail.text, contains('Bleach'));
  });



  test('Dextrin counts and presence in grab lists are correct', () {
    expect(
        DailyPlanData.schedules[DailyPlanData.tue]!.any((item) =>
            item.title.contains('Grab') && item.details.any((d) => d.text.contains('1 scoop Cluster Dextrin'))),
        isFalse);
    expect(
        DailyPlanData.schedules[DailyPlanData.wed]!.any((item) =>
            item.title.contains('Grab') && item.details.any((d) => d.text.contains('1 scoop Cluster Dextrin'))),
        isFalse);
    expect(
        DailyPlanData.schedules[DailyPlanData.fri]!.any((item) =>
            item.title.contains('Grab') && item.details.any((d) => d.text.contains('1 scoop Cluster Dextrin'))),
        isFalse);
  });

  test('Pre-workout dextrin schedule timing is correct on gym days', () {
    for (final day in [DailyPlanData.mon, DailyPlanData.tue, DailyPlanData.thu, DailyPlanData.fri]) {
      final schedule = DailyPlanData.schedules[day]!;
      
      final commute = schedule.firstWhere((item) => item.title.contains('Commute to Gym'));
      expect(commute.time.contains('5:'), isTrue);
      expect(commute.details.any((d) => d.text.contains('Mix 1 scoop whey isolate')), isTrue);
    }
  });

  test('Every day fall asleep details include todo list reminder and default instructions', () {
    for (final day in DailyPlanData.schedules.keys) {
      final schedule = DailyPlanData.schedules[day]!;
      final fallAsleep = schedule.firstWhere((item) => item.title == 'Fall Asleep');
      expect(fallAsleep.details.map((d) => d.text), contains('Lights completely out (pitch black). Close eyes and allow sleep to happen naturally.'));
      expect(fallAsleep.details.map((d) => d.text), contains('📝 Brain dump: Write down your to-do list for tomorrow on paper so you aren\'t thinking about it in bed.'));
    }
  });

  test('Verify work snacks and supplements are accurately packed in _grabThings for cut and refeed weeks', () {
    for (final isRefeed in [false, true]) {
      try {
        if (isRefeed) {
          DailyPlanData.mockCurrentDate = DailyPlanData.planStartDate.add(const Duration(days: 28));
        } else {
          DailyPlanData.mockCurrentDate = null;
        }

        for (final day in DailyPlanData.schedules.keys) {
          final schedule = DailyPlanData.schedules[day]!;
          
          final commuteToWorkIdx = schedule.indexWhere((item) => item.title == 'Commute to Work');
          if (commuteToWorkIdx == -1) continue; // WFH or weekend
          
          final endWorkIdx = schedule.indexWhere((item) => item.title.startsWith('Commute to Gym') || item.title == 'Commute Home');
          final workEnd = endWorkIdx != -1 ? endWorkIdx : schedule.length;
          
          final grabThings = schedule.firstWhere((item) => item.title.contains('Grab things'));
          
          int requiredEggs = 0;
          int requiredDextrins = 0;
          int requiredBananas = 0;
          bool needsZinc = false;
          bool needsCopper = false;

          
          for (int i = commuteToWorkIdx + 1; i < workEnd; i++) {
            final item = schedule[i];
            if (item.mealRecord != null) {
              for (final portion in item.mealRecord!.items) {
                if (portion.ingredient.id == 'egg') requiredEggs += portion.amount.toInt();
                if (portion.ingredient.id == 'cluster_dextrin') requiredDextrins += portion.amount.toInt();
                if (portion.ingredient.id == 'banana') requiredBananas += portion.amount.toInt();
                if (portion.ingredient.id == 'zinc') needsZinc = true;
                if (portion.ingredient.id == 'copper_glycinate') needsCopper = true;

              }
            }
          }
          
          final grabDetails = grabThings.details.map((d) => d.text).join(' ');
          if (requiredEggs > 0) expect(grabDetails, contains('$requiredEggs Boiled Eggs'), reason: '$day (refeed=$isRefeed) missing eggs in grab list');
          if (requiredDextrins > 0) expect(grabDetails, contains(requiredDextrins == 1 ? '1 scoop Cluster Dextrin' : '$requiredDextrins scoops Cluster Dextrin'), reason: '$day (refeed=$isRefeed) missing dextrins in grab list');
          if (requiredBananas > 0) expect(grabDetails, contains('Banana'), reason: '$day (refeed=$isRefeed) missing Banana in grab list');
          if (needsZinc) expect(grabDetails, contains('Zinc Picolinate'), reason: '$day (refeed=$isRefeed) missing Zinc in grab list');
          if (needsCopper) expect(grabDetails, contains('Copper Glycinate'), reason: '$day (refeed=$isRefeed) missing Copper in grab list');

        }
      } finally {
        DailyPlanData.mockCurrentDate = null;
      }
    }
  });


  test('LISS Cardio becomes Zone 1 Recovery Walk on Refeed Weeks', () {
    try {
      // Set date to a known refeed week (Week 5: 28 days from plan start)
      DailyPlanData.mockCurrentDate = DailyPlanData.planStartDate.add(const Duration(days: 28));
      
      // Check Wednesday
      final wedSchedule = DailyPlanData.schedules[DailyPlanData.wed]!;
      final wedCardio = wedSchedule.firstWhere((item) => item.title.contains('Recovery Walk / Haircut (Refeed)'));
      expect(wedCardio.details.map((d) => d.text).join(' '), contains('UNDER 15k steps'));
      
      // Check Saturday
      final satSchedule = DailyPlanData.schedules[DailyPlanData.sat]!;
      final satCardio = satSchedule.firstWhere((item) => item.title.contains('Recovery Walk / Haircut (Refeed)'));
      expect(satCardio.details.map((d) => d.text).join(' '), contains('UNDER 26k steps'));
    } finally {
      DailyPlanData.mockCurrentDate = null;
    }
  });

  test('Shopping list includes 37 Bananas and Quinoa for upcoming Refeed weeks', () async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefsLogic.init();

    // 1. Normal cut week
    DailyPlanData.mockCurrentDate = DateTime(2026, 8, 15);
    final normalItems = ShoppingListNotifier().build();
    expect(normalItems.any((item) => item.name == 'Quinoa'), isFalse, reason: 'Quinoa should not appear on normal cut weeks');
    final bananaItemNormal = normalItems.firstWhere((item) => item.name == 'Bananas');
    expect(bananaItemNormal.subtext, contains('13 Bananas (8 PW + 5 Snack/Morning)'));

    // 2. Upcoming Refeed week (e.g. Sunday of Week 4 -> Week 5 IS refeed, so day 27 from plan start)
    try {
      DailyPlanData.mockCurrentDate = DailyPlanData.planStartDate.add(const Duration(days: 27));
      final refeedItems = ShoppingListNotifier().build();
      
      final bananaItem = refeedItems.firstWhere((item) => item.name == 'Bananas');
      expect(bananaItem.subtext, contains('37 Bananas (REFEED WEEK)'));

      final quinoaItem = refeedItems.firstWhere((item) => item.name == 'Quinoa');
      expect(quinoaItem.subtext, contains('1 bag (REFEED WEEK: need 3 cups dry)'));
    } finally {
      DailyPlanData.mockCurrentDate = null;
    }
  });

  test('Rule 13: Strict Pre-Workout Fat Restriction (Gastric Emptying)', () {
    for (final isRefeed in [false, true]) {
      try {
        if (isRefeed) {
          DailyPlanData.mockCurrentDate = DailyPlanData.planStartDate.add(const Duration(days: 28));
        } else {
          DailyPlanData.mockCurrentDate = null;
        }
        for (final entry in DailyPlanData.schedules.entries) {
          final schedule = entry.value;
          for (final item in schedule) {
            final isGym = item.title.toLowerCase().contains('gym session') || item.isCardio;
            if (!isGym) continue;

            final gymStart = parseTime(item.time);
            
            for (final preWorkoutItem in schedule) {
              if (preWorkoutItem.mealRecord == null) continue;
              
              final mealEnd = parseTime(preWorkoutItem.time, isEnd: true);
              final minutesBeforeGym = gymStart.difference(mealEnd).inMinutes;

              if (minutesBeforeGym >= 0 && minutesBeforeGym <= 90) {
                final fat = preWorkoutItem.mealRecord!.totalNutrition.fat;
                expect(fat, lessThan(5.0), reason: 'Too much fat (${fat.toStringAsFixed(1)}g) within 90 mins of workout on ${entry.key} (refeed: $isRefeed). Fat delays gastric emptying of intra-workout nutrients.');
              }
            }
          }
        }
      } finally {
        DailyPlanData.mockCurrentDate = null;
      }
    }
  });

  test('Rule 14: Morning Leucine Threshold Spike', () {
    for (final isRefeed in [false, true]) {
      try {
        if (isRefeed) {
          DailyPlanData.mockCurrentDate = DailyPlanData.planStartDate.add(const Duration(days: 28));
        } else {
          DailyPlanData.mockCurrentDate = null;
        }
        int daysHittingThreshold = 0;
        List<String> failedDays = [];

        for (final entry in DailyPlanData.schedules.entries) {
          final schedule = entry.value;
          double morningProtein = 0.0;

          for (final item in schedule) {
            final time = parseTime(item.time);
            if (time.hour < 10) { 
               if (item.mealRecord != null) {
                  morningProtein += item.mealRecord!.totalNutrition.protein;
               }
            }
          }
          
          if (morningProtein >= 25.0) {
            daysHittingThreshold++;
          } else {
            failedDays.add('${entry.key} (${morningProtein.toStringAsFixed(1)}g)');
          }
          
          expect(morningProtein, greaterThanOrEqualTo(18.0), 
              reason: 'Morning protein fell below the absolute minimum of 18g on ${entry.key} (refeed: $isRefeed). Only consumed ${morningProtein.toStringAsFixed(1)}g.');
        }
        
        expect(daysHittingThreshold, greaterThanOrEqualTo(5), 
            reason: 'Failed to hit the optimal 25g Morning Leucine Threshold on at least 5 days (refeed: $isRefeed). Failed days: ${failedDays.join(', ')}');
      } finally {
        DailyPlanData.mockCurrentDate = null;
      }
    }
  });

  test('Rule 15: Deep Sleep Insulin Curfew (Growth Hormone & Fat Oxidation Protection)', () {
    for (final isRefeed in [false, true]) {
      try {
        if (isRefeed) {
          DailyPlanData.mockCurrentDate = DailyPlanData.planStartDate.add(const Duration(days: 28));
        } else {
          DailyPlanData.mockCurrentDate = null;
        }
        for (final entry in DailyPlanData.schedules.entries) {
          final schedule = entry.value;
          final sleepItem = schedule.firstWhere((i) => i.title.toLowerCase().contains('fall asleep'));
          final sleepStart = parseTime(sleepItem.time);
          DateTime fixedSleepStart = sleepStart.hour < 4 ? sleepStart.add(const Duration(days: 1)) : sleepStart;

          for (final item in schedule) {
            if (item.mealRecord == null) continue;

            final mealEnd = parseTime(item.time, isEnd: true);
            DateTime fixedMealEnd = mealEnd.hour < 4 ? mealEnd.add(const Duration(days: 1)) : mealEnd;
            
            final minutesBeforeSleep = fixedSleepStart.difference(fixedMealEnd).inMinutes;

            if (minutesBeforeSleep >= 0 && minutesBeforeSleep <= 120) {
              final hasBananas = item.mealRecord!.items.any((i) => i.ingredient == IngredientsData.banana);
              final hasDextrin = item.mealRecord!.items.any((i) => i.ingredient == IngredientsData.clusterDextrin);
              
              expect(hasBananas, isFalse, reason: 'High-glycemic Bananas found within 2 hours of sleep on ${entry.key} (refeed: $isRefeed). This will spike insulin and blunt GH/fat oxidation.');
              expect(hasDextrin, isFalse, reason: 'Cluster Dextrin found within 2 hours of sleep on ${entry.key} (refeed: $isRefeed).');
            }
          }
        }
      } finally {
        DailyPlanData.mockCurrentDate = null;
      }
    }
  });

  test('Rule 16: Pre-workout must contain carb, water, and sodium on resistance training days', () {
    for (final isRefeed in [false, true]) {
      try {
        if (isRefeed) {
          DailyPlanData.mockCurrentDate = DailyPlanData.planStartDate.add(const Duration(days: 28)); // Week 5
        } else {
          DailyPlanData.mockCurrentDate = null; // Normal week
        }

        final resistanceDays = [DailyPlanData.mon, DailyPlanData.tue, DailyPlanData.thu, DailyPlanData.fri];
        for (final day in resistanceDays) {
          final schedule = DailyPlanData.schedules[day]!;
          final commute = schedule.firstWhere((item) => item.title.contains('Commute to Gym (Resistance)'));
          
          final detailsString = commute.details.map((d) => d.text.toLowerCase()).join(' ');
          
          // Carb check
          double totalCarbs = 0.0;
          if (commute.mealRecord != null) {
            totalCarbs = commute.mealRecord!.totalNutrition.carbs;
          }
          expect(totalCarbs, greaterThanOrEqualTo(50.0), reason: '$day missing pre-workout carb (>50g) during ${isRefeed ? 'refeed' : 'cut'}');
          
          // Water check
          expect(detailsString, contains('21oz water bottle'), reason: '$day missing pre-workout water during ${isRefeed ? 'refeed' : 'cut'}');
          
          // Sodium check
          double totalSodium = 0.0;
          if (commute.mealRecord != null) {
            totalSodium = commute.mealRecord!.totalNutrition.microNutrients['Sodium (mg)'] ?? 0.0;
          }
          expect(totalSodium, greaterThanOrEqualTo(600.0), reason: '$day missing adequate pre-workout sodium (>=600mg) during ${isRefeed ? 'refeed' : 'cut'}');
        }
      } finally {
        DailyPlanData.mockCurrentDate = null;
      }
    }
  });
}

DateTime parseTime(String timeString, {bool isEnd = false}) {
  final parts = timeString.split(' ');
  final times = parts[0].split('-');
  final period = parts[1].toLowerCase();
  
  String targetTime = isEnd ? times[1] : times[0];
  final timeParts = targetTime.split(':');
  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);
  
  bool isPm = period == 'pm';
  
  if (!isEnd && isPm) {
     final endParts = times[1].split(':');
     int endHour = int.parse(endParts[0]);
     if (hour >= 7 && hour <= 11 && (endHour >= 1 && endHour <= 6 || endHour == 12)) {
       isPm = false;
     }
  }
  
  if (isPm && hour != 12) hour += 12;
  if (!isPm && hour == 12) hour = 0;
  
  return DateTime(2026, 1, 1, hour, minute);
}

