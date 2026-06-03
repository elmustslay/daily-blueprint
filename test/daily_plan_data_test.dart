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

  test('Bath towels alternate between Bleach and OxiClean based on week parity', () {
    // Week 1 (Odd Week): planStartDate is 2026-04-13.
    // 2026-04-15 is diff of 2 days -> diff ~/ 7 = 0 -> week 1 (Odd)
    DailyPlanData.mockCurrentDate = DateTime(2026, 4, 15);
    final monScheduleOdd = DailyPlanData.schedules[DailyPlanData.mon]!;
    final bathTowelsItemOdd = monScheduleOdd.firstWhere((item) => item.details.any((d) => d.contains('Bath Towels')));
    final bathTowelsDetailOdd = bathTowelsItemOdd.details.firstWhere((d) => d.contains('Bath Towels'));
    
    expect(bathTowelsDetailOdd, contains('OxiClean'));
    expect(bathTowelsDetailOdd, isNot(contains('Bleach')));

    // Week 2 (Even Week):
    // 2026-04-22 is diff of 9 days -> diff ~/ 7 = 1 -> week 2 (Even)
    DailyPlanData.mockCurrentDate = DateTime(2026, 4, 22);
    final monScheduleEven = DailyPlanData.schedules[DailyPlanData.mon]!;
    final bathTowelsItemEven = monScheduleEven.firstWhere((item) => item.details.any((d) => d.contains('Bath Towels')));
    final bathTowelsDetailEven = bathTowelsItemEven.details.firstWhere((d) => d.contains('Bath Towels'));

    expect(bathTowelsDetailEven, contains('1/3 cup Bleach'));
    expect(bathTowelsDetailEven, contains('OxiClean'));
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
    // Tue: 2 bananas
    final tueSchedule = DailyPlanData.schedules[DailyPlanData.tue]!;
    final tueGrab = tueSchedule.firstWhere((item) => item.title.contains('Grab things'));
    expect(tueGrab.details, contains('2 bananas'));

    // Wed: 0 bananas
    final wedSchedule = DailyPlanData.schedules[DailyPlanData.wed]!;
    final wedGrab = wedSchedule.firstWhere((item) => item.title.contains('Grab things'));
    expect(wedGrab.details.any((d) => d.contains('banana')), isFalse);

    // Fri: 2 bananas
    final friSchedule = DailyPlanData.schedules[DailyPlanData.fri]!;
    final friGrab = friSchedule.firstWhere((item) => item.title.contains('Grab things'));
    expect(friGrab.details, contains('2 bananas'));
  });

  test('Pre-workout banana schedule timing is correct on gym days', () {
    for (final day in [DailyPlanData.mon, DailyPlanData.tue, DailyPlanData.thu, DailyPlanData.fri]) {
      final schedule = DailyPlanData.schedules[day]!;
      
      // Banana 1 should be at 4:45 pm
      final banana1 = schedule.firstWhere((item) => item.title == 'Pre-Workout Banana 1');
      expect(banana1.time, '4:45-4:50 pm');
      expect(banana1.details, contains('Eat 1st banana (45m pre-workout)'));

      // Banana 2 should be in commute details
      final commute = schedule.firstWhere((item) => item.title == 'Commute to Gym');
      expect(commute.details, contains('Eat 2nd banana (15m pre-workout)'));
    }
  });
}
