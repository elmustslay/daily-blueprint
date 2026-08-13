import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/core/storage/shared_prefs.dart';
import 'package:my_app/features/daily_plan/data/daily_plan_data.dart';
import 'package:my_app/features/shopping_list/presentation/shopping_list_screen.dart';

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
    final faceTowelsItem = monSchedule.firstWhere((item) => item.details.any((d) => d.contains('Bamboo Washcloths')));
    final bathTowelsItem = monSchedule.firstWhere((item) => item.details.any((d) => d.contains('Bath Towels')));

    final faceTowelsDetail = faceTowelsItem.details.firstWhere((d) => d.contains('Bamboo Washcloths'));
    final bathTowelsDetail = bathTowelsItem.details.firstWhere((d) => d.contains('Bath Towels'));

    expect(faceTowelsDetail, contains('Dry on LOW heat'));
    expect(bathTowelsDetail, contains('Dry on LOW heat'));
  });

  test('Bath towels use Bleach', () {
    DailyPlanData.mockCurrentDate = DateTime(2026, 4, 15);
    final monSchedule = DailyPlanData.schedules[DailyPlanData.mon]!;
    final bathTowelsItem = monSchedule.firstWhere((item) => item.details.any((d) => d.contains('Bath Towels')));
    final bathTowelsDetail = bathTowelsItem.details.firstWhere((d) => d.contains('Bath Towels'));
    
    expect(bathTowelsDetail, contains('Bleach'));
  });

  test('Wednesday grab list contains Calcium Citrate capsules', () {
    final wedSchedule = DailyPlanData.schedules[DailyPlanData.wed]!;
    final grabItem = wedSchedule.firstWhere((item) => item.title.contains('Grab things'));
    
    final grabDetails = grabItem.details.join(' ');
    expect(grabDetails, contains('Calcium Citrate'));
  });

  test('Tuesday grab list does not contain Calcium Citrate capsules', () {
    final tueSchedule = DailyPlanData.schedules[DailyPlanData.tue]!;
    final grabItem = tueSchedule.firstWhere((item) => item.title.contains('Grab things'));
    
    final grabDetails = grabItem.details.join(' ');
    expect(grabDetails, isNot(contains('Calcium Citrate')));
  });

  test('Dextrin counts and presence in grab lists are correct', () {
    expect(
        DailyPlanData.schedules[DailyPlanData.tue]!.any((item) =>
            item.title.contains('Grab') && item.details.any((d) => d.contains('1 scoop Cluster Dextrin'))),
        isFalse);
    expect(
        DailyPlanData.schedules[DailyPlanData.wed]!.any((item) =>
            item.title.contains('Grab') && item.details.any((d) => d.contains('1 scoop Cluster Dextrin'))),
        isFalse);
    expect(
        DailyPlanData.schedules[DailyPlanData.fri]!.any((item) =>
            item.title.contains('Grab') && item.details.any((d) => d.contains('1 scoop Cluster Dextrin'))),
        isFalse);
  });

  test('Pre-workout dextrin schedule timing is correct on gym days', () {
    for (final day in [DailyPlanData.mon, DailyPlanData.tue, DailyPlanData.thu, DailyPlanData.fri]) {
      final schedule = DailyPlanData.schedules[day]!;
      
      final commute = schedule.firstWhere((item) => item.title.contains('Commute to Gym'));
      expect(commute.time.contains('5:'), isTrue);
      expect(commute.details.any((d) => d.contains('Mix 1 scoop Cluster Dextrin in water')), isTrue);
    }
  });

  test('Every day fall asleep details include todo list reminder and default instructions', () {
    for (final day in DailyPlanData.schedules.keys) {
      final schedule = DailyPlanData.schedules[day]!;
      final fallAsleep = schedule.firstWhere((item) => item.title == 'Fall Asleep');
      expect(fallAsleep.details, contains('Lights out, try to fall asleep within 30 min'));
      expect(fallAsleep.details, contains('Come up with todo list for tom'));
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
          int requiredCalcium = 0;
          
          for (int i = commuteToWorkIdx + 1; i < workEnd; i++) {
            final item = schedule[i];
            if (item.mealRecord != null) {
              for (final portion in item.mealRecord!.items) {
                if (portion.ingredient.id == 'egg') requiredEggs += portion.amount.toInt();
                if (portion.ingredient.id == 'cluster_dextrin') requiredDextrins += portion.amount.toInt();
                if (portion.ingredient.id == 'banana') requiredBananas += portion.amount.toInt();
                if (portion.ingredient.id == 'zinc') needsZinc = true;
                if (portion.ingredient.id == 'copper_glycinate') needsCopper = true;
                if (portion.ingredient.id == 'calcium_citrate') requiredCalcium += portion.amount.toInt();
              }
            }
          }
          
          final grabDetails = grabThings.details.join(' ');
          if (requiredEggs > 0) expect(grabDetails, contains('$requiredEggs Boiled Eggs'), reason: '$day (refeed=$isRefeed) missing eggs in grab list');
          if (requiredDextrins > 0) expect(grabDetails, contains(requiredDextrins == 1 ? '1 scoop Cluster Dextrin' : '$requiredDextrins scoops Cluster Dextrin'), reason: '$day (refeed=$isRefeed) missing dextrins in grab list');
          if (requiredBananas > 0) expect(grabDetails, contains('Banana'), reason: '$day (refeed=$isRefeed) missing Banana in grab list');
          if (needsZinc) expect(grabDetails, contains('Zinc Picolinate'), reason: '$day (refeed=$isRefeed) missing Zinc in grab list');
          if (needsCopper) expect(grabDetails, contains('Copper Glycinate'), reason: '$day (refeed=$isRefeed) missing Copper in grab list');
          if (requiredCalcium > 0) expect(grabDetails, contains('Calcium Citrate'), reason: '$day (refeed=$isRefeed) missing Calcium in grab list');
        }
      } finally {
        DailyPlanData.mockCurrentDate = null;
      }
    }
  });

  test('Verify weekly fruit, dextrin, and egg consumption matches the shopping list quantities', () {
    int totalDextrins = 0;
    int totalKiwis = 0;
    int totalEggs = 0;
    int totalBananas = 0;
    
    for (final schedule in DailyPlanData.schedules.values) {
      for (final item in schedule) {
        if (item.mealRecord != null) {
          for (final portion in item.mealRecord!.items) {
            if (portion.ingredient.id == 'cluster_dextrin') totalDextrins += portion.amount.toInt();
            if (portion.ingredient.id == 'kiwi') totalKiwis += portion.amount.toInt();
            if (portion.ingredient.id == 'egg') totalEggs += portion.amount.toInt();
            if (portion.ingredient.id == 'banana') totalBananas += portion.amount.toInt();
          }
        }
      }
    }
    
    expect(totalDextrins, 4, reason: 'Total weekly dextrins should be exactly 4');
    expect(totalKiwis, 5, reason: 'Total weekly kiwis should be exactly 5 (Mon-Thu, 2 on Thu)');
    expect(totalEggs, 18, reason: 'Total weekly eggs should be exactly 18');
    expect(totalBananas, 7, reason: 'Total weekly bananas on regular cut weeks should be 7');
  });

  test('Verify weekly fruit, dextrin, and egg consumption on Refeed Week matches shopping list', () {
    try {
      DailyPlanData.mockCurrentDate = DailyPlanData.planStartDate.add(const Duration(days: 28));
      int totalDextrins = 0;
      int totalKiwis = 0;
      int totalEggs = 0;
      int totalBananas = 0;
      
      for (final day in DailyPlanData.schedules.keys) {
        final schedule = DailyPlanData.schedules[day]!;
        int dayBananas = 0;
        for (final item in schedule) {
          if (item.mealRecord != null) {
            for (final portion in item.mealRecord!.items) {
              if (portion.ingredient.id == 'cluster_dextrin') totalDextrins += portion.amount.toInt();
              if (portion.ingredient.id == 'kiwi') totalKiwis += portion.amount.toInt();
              if (portion.ingredient.id == 'egg') totalEggs += portion.amount.toInt();
              if (portion.ingredient.id == 'banana') {
                totalBananas += portion.amount.toInt();
                dayBananas += portion.amount.toInt();
              }
            }
          }
        }
        expect(dayBananas, 4, reason: '$day should have exactly 4 bananas on Refeed Week');
      }
      
      expect(totalDextrins, 4, reason: 'Workout dextrins remain 4 on lift days');
      expect(totalKiwis, 5, reason: 'Total weekly kiwis should be exactly 5');
      expect(totalEggs, 18, reason: 'Total weekly eggs should be exactly 18');
      expect(totalBananas, 28, reason: 'Total weekly bananas on Refeed Week should be exactly 28 (4/day across all 7 days)');
    } finally {
      DailyPlanData.mockCurrentDate = null;
    }
  });

  test('LISS Cardio is skipped on Refeed Weeks', () {
    try {
      // Set date to a known refeed week (Week 5: 28 days from plan start)
      DailyPlanData.mockCurrentDate = DailyPlanData.planStartDate.add(const Duration(days: 28));
      
      // Check Wednesday
      final wedSchedule = DailyPlanData.schedules[DailyPlanData.wed]!;
      final wedCardio = wedSchedule.firstWhere((item) => item.title.contains('Haircut / Rest (Refeed Week)'));
      expect(wedCardio.details.join(' '), contains('Skip LISS cardio'));
      
      // Check Saturday
      final satSchedule = DailyPlanData.schedules[DailyPlanData.sat]!;
      final satCardio = satSchedule.firstWhere((item) => item.title.contains('Haircut / Rest (Refeed Week)'));
      expect(satCardio.details.join(' '), contains('Skip LISS cardio'));
    } finally {
      DailyPlanData.mockCurrentDate = null;
    }
  });

  test('Shopping list includes 28 Bananas and Quinoa for upcoming Refeed weeks', () async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefsLogic.init();

    // 1. Normal cut week (e.g. Week 1 -> Week 2 is NOT refeed)
    DailyPlanData.mockCurrentDate = DailyPlanData.planStartDate;
    final normalItems = ShoppingListNotifier().build();
    expect(normalItems.any((item) => item.name == 'Quinoa'), isFalse, reason: 'Quinoa should not appear on normal cut weeks');
    final bananaItemNormal = normalItems.firstWhere((item) => item.name == 'Bananas');
    expect(bananaItemNormal.subtext, contains('4 Bananas (1/day on lift days)'));

    // 2. Upcoming Refeed week (e.g. Sunday of Week 4 -> Week 5 IS refeed, so day 27 from plan start)
    try {
      DailyPlanData.mockCurrentDate = DailyPlanData.planStartDate.add(const Duration(days: 27));
      final refeedItems = ShoppingListNotifier().build();
      
      final bananaItem = refeedItems.firstWhere((item) => item.name == 'Bananas');
      expect(bananaItem.subtext, contains('28 Bananas (4/day) (REFEED WEEK)'));

      final quinoaItem = refeedItems.firstWhere((item) => item.name == 'Quinoa');
      expect(quinoaItem.subtext, contains('1 bag (REFEED WEEK)'));
    } finally {
      DailyPlanData.mockCurrentDate = null;
    }
  });
}
