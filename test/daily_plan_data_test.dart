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
    final faceTowelsItem = monSchedule.firstWhere((item) => item.details.any((d) => d.contains('Face Towels')));
    final bathTowelsItem = monSchedule.firstWhere((item) => item.details.any((d) => d.contains('Bath Towels')));

    final faceTowelsDetail = faceTowelsItem.details.firstWhere((d) => d.contains('Face Towels'));
    final bathTowelsDetail = bathTowelsItem.details.firstWhere((d) => d.contains('Bath Towels'));

    expect(faceTowelsDetail, contains('Dry on LOW heat'));
    expect(bathTowelsDetail, contains('Dry on LOW heat'));
  });

  test('Bath towels use Bleach and OxiClean', () {
    DailyPlanData.mockCurrentDate = DateTime(2026, 4, 15);
    final monSchedule = DailyPlanData.schedules[DailyPlanData.mon]!;
    final bathTowelsItem = monSchedule.firstWhere((item) => item.details.any((d) => d.contains('Bath Towels')));
    final bathTowelsDetail = bathTowelsItem.details.firstWhere((d) => d.contains('Bath Towels'));
    
    expect(bathTowelsDetail, contains('OxiClean'));
    expect(bathTowelsDetail, contains('Bleach'));
  });

  test('Wednesday grab list contains Calcium Citrate capsules', () {
    final wedSchedule = DailyPlanData.schedules[DailyPlanData.wed]!;
    final grabItem = wedSchedule.firstWhere((item) => item.title.contains('Grab things'));
    final supplementsDetail = grabItem.details.firstWhere((d) => d.startsWith('Supplements'));

    expect(supplementsDetail, contains('Calcium Citrate'));
    expect(supplementsDetail, isNot(contains('3 Calcium Citrate')));
    expect(supplementsDetail, contains('K2'));
    expect(supplementsDetail, isNot(contains('1 K2')));
  });

  test('Tuesday grab list does not contain Calcium Citrate capsules', () {
    final tueSchedule = DailyPlanData.schedules[DailyPlanData.tue]!;
    final grabItem = tueSchedule.firstWhere((item) => item.title.contains('Grab things'));
    final supplementsDetail = grabItem.details.firstWhere((d) => d.startsWith('Supplements'));

    expect(supplementsDetail, isNot(contains('Calcium Citrate')));
  });

  test('Banana counts and presence in grab lists are correct', () {
    // Tue: 0 bananas (pre-workout banana eaten at home now)
    final tueSchedule = DailyPlanData.schedules[DailyPlanData.tue]!;
    final tueGrab = tueSchedule.firstWhere((item) => item.title.contains('Grab things'));
    expect(tueGrab.details.any((d) => d.contains('banana')), isFalse);

    // Wed: 1 banana (for afternoon snack)
    final wedSchedule = DailyPlanData.schedules[DailyPlanData.wed]!;
    final wedGrab = wedSchedule.firstWhere((item) => item.title.contains('Grab things'));
    expect(wedGrab.details, contains('1 banana'));

    // Fri: 0 bananas (pre-workout banana eaten at home now)
    final friSchedule = DailyPlanData.schedules[DailyPlanData.fri]!;
    final friGrab = friSchedule.firstWhere((item) => item.title.contains('Grab things'));
    expect(friGrab.details.any((d) => d.contains('banana')), isFalse);
  });

  test('Pre-workout banana schedule timing is correct on gym days', () {
    for (final day in [DailyPlanData.mon, DailyPlanData.tue, DailyPlanData.thu, DailyPlanData.fri]) {
      final schedule = DailyPlanData.schedules[day]!;
      
      // Banana should be around 5:35 or 5:55 pm
      final banana = schedule.firstWhere((item) => item.title == 'Pre-Workout Banana & Get Dressed');
      expect(banana.time.contains('5:'), isTrue);
      expect(banana.details, contains('Eat banana (30-45m pre-workout) -> Swish/drink water after'));

      // Commute should NOT have a second banana
      final commute = schedule.firstWhere((item) => item.title == 'Commute to Gym');
      expect(commute.details.any((d) => d.contains('banana')), isFalse);
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
      int requiredBananas = 0;
      bool needsZinc = false;
      bool needsCopper = false;
      int requiredCalcium = 0;
      
      for (int i = commuteToWorkIdx + 1; i < workEnd; i++) {
        final item = schedule[i];
        if (item.mealRecord != null) {
          for (final portion in item.mealRecord!.items) {
            if (portion.ingredient.id == 'egg') requiredEggs += portion.amount.toInt();
            if (portion.ingredient.id == 'banana') requiredBananas += portion.amount.toInt();
            if (portion.ingredient.id == 'zinc') needsZinc = true;
            if (portion.ingredient.id == 'copper_glycinate') needsCopper = true;
            if (portion.ingredient.id == 'calcium_citrate') requiredCalcium += portion.amount.toInt();
          }
        }
      }
      
      final grabDetails = grabThings.details.join(' ');
      if (requiredEggs > 0) expect(grabDetails, contains('$requiredEggs Boiled Eggs'), reason: '$day missing eggs in grab list');
      if (requiredBananas > 0) expect(grabDetails, contains(requiredBananas == 1 ? '1 banana' : '$requiredBananas bananas'), reason: '$day missing bananas in grab list');
      if (needsZinc) expect(grabDetails, contains('Zinc Picolinate'), reason: '$day missing Zinc in grab list');
      if (needsCopper) expect(grabDetails, contains('Copper Glycinate'), reason: '$day missing Copper in grab list');
      if (requiredCalcium > 0) expect(grabDetails, contains('Calcium Citrate'), reason: '$day missing Calcium in grab list');
    }
  });

  test('Verify weekly fruit and egg consumption matches the shopping list quantities', () {
    int totalBananas = 0;
    int totalKiwis = 0;
    int totalEggs = 0;
    
    for (final schedule in DailyPlanData.schedules.values) {
      for (final item in schedule) {
        if (item.mealRecord != null) {
          for (final portion in item.mealRecord!.items) {
            if (portion.ingredient.id == 'banana') totalBananas += portion.amount.toInt();
            if (portion.ingredient.id == 'kiwi') totalKiwis += portion.amount.toInt();
            if (portion.ingredient.id == 'egg') totalEggs += portion.amount.toInt();
          }
        }
      }
    }
    
    // We expect exactly 14 bananas, 8 kiwis, and 24 eggs based on the schedule design
    expect(totalBananas, 14, reason: 'Total weekly bananas should be exactly 14');
    expect(totalKiwis, 8, reason: 'Total weekly kiwis should be exactly 8');
    expect(totalEggs, 24, reason: 'Total weekly eggs should be exactly 24');
  });
}
