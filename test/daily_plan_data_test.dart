import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/daily_plan/data/daily_plan_data.dart';

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
      
      final commute = schedule.firstWhere((item) => item.title == 'Get Dressed & Commute to Gym');
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

  test('Verify work snacks and supplements are accurately packed in _grabThings', () {
    for (final day in DailyPlanData.schedules.keys) {
      final schedule = DailyPlanData.schedules[day]!;
      
      final commuteToWorkIdx = schedule.indexWhere((item) => item.title == 'Commute to Work');
      if (commuteToWorkIdx == -1) continue; // WFH or weekend
      
      final endWorkIdx = schedule.indexWhere((item) => item.title.startsWith('Commute to Gym') || item.title == 'Commute Home');
      final workEnd = endWorkIdx != -1 ? endWorkIdx : schedule.length;
      
      final grabThings = schedule.firstWhere((item) => item.title.contains('Grab things'));
      
      int requiredEggs = 0;
      int requiredDextrins = 0;
      bool needsZinc = false;
      bool needsCopper = false;
      int requiredCalcium = 0;
      
      for (int i = commuteToWorkIdx + 1; i < workEnd; i++) {
        final item = schedule[i];
        if (item.mealRecord != null) {
          for (final portion in item.mealRecord!.items) {
            if (portion.ingredient.id == 'egg') requiredEggs += portion.amount.toInt();
            if (portion.ingredient.id == 'cluster_dextrin') requiredDextrins += portion.amount.toInt();
            if (portion.ingredient.id == 'zinc') needsZinc = true;
            if (portion.ingredient.id == 'copper_glycinate') needsCopper = true;
            if (portion.ingredient.id == 'calcium_citrate') requiredCalcium += portion.amount.toInt();
          }
        }
      }
      
      final grabDetails = grabThings.details.join(' ');
      if (requiredEggs > 0) expect(grabDetails, contains('$requiredEggs Boiled Eggs'), reason: '$day missing eggs in grab list');
      if (requiredDextrins > 0) expect(grabDetails, contains(requiredDextrins == 1 ? '1 scoop Cluster Dextrin' : '$requiredDextrins scoops Cluster Dextrin'), reason: '$day missing dextrins in grab list');
      if (needsZinc) expect(grabDetails, contains('Zinc Picolinate'), reason: '$day missing Zinc in grab list');
      if (needsCopper) expect(grabDetails, contains('Copper Glycinate'), reason: '$day missing Copper in grab list');
      if (requiredCalcium > 0) expect(grabDetails, contains('Calcium Citrate'), reason: '$day missing Calcium in grab list');
    }
  });

  test('Verify weekly fruit, dextrin, and egg consumption matches the shopping list quantities', () {
    int totalDextrins = 0;
    int totalKiwis = 0;
    int totalEggs = 0;
    
    for (final schedule in DailyPlanData.schedules.values) {
      for (final item in schedule) {
        if (item.mealRecord != null) {
          for (final portion in item.mealRecord!.items) {
            if (portion.ingredient.id == 'cluster_dextrin') totalDextrins += portion.amount.toInt();
            if (portion.ingredient.id == 'kiwi') totalKiwis += portion.amount.toInt();
            if (portion.ingredient.id == 'egg') totalEggs += portion.amount.toInt();
          }
        }
      }
    }
    
    // We expect exactly 5 dextrins, 6 kiwis, and 18 eggs based on the schedule design
    expect(totalDextrins, 5, reason: 'Total weekly dextrins should be exactly 5');
    expect(totalKiwis, 6, reason: 'Total weekly kiwis should be exactly 6');
    expect(totalEggs, 18, reason: 'Total weekly eggs should be exactly 18');
  });
}
