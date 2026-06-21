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
    // Tue: 1 banana
    final tueSchedule = DailyPlanData.schedules[DailyPlanData.tue]!;
    final tueGrab = tueSchedule.firstWhere((item) => item.title.contains('Grab things'));
    expect(tueGrab.details, contains('1 banana'));

    // Wed: 0 bananas
    final wedSchedule = DailyPlanData.schedules[DailyPlanData.wed]!;
    final wedGrab = wedSchedule.firstWhere((item) => item.title.contains('Grab things'));
    expect(wedGrab.details.any((d) => d.contains('banana')), isFalse);

    // Fri: 1 banana
    final friSchedule = DailyPlanData.schedules[DailyPlanData.fri]!;
    final friGrab = friSchedule.firstWhere((item) => item.title.contains('Grab things'));
    expect(friGrab.details, contains('1 banana'));
  });

  test('Pre-workout banana schedule timing is correct on gym days', () {
    for (final day in [DailyPlanData.mon, DailyPlanData.tue, DailyPlanData.thu, DailyPlanData.fri]) {
      final schedule = DailyPlanData.schedules[day]!;
      
      // Banana should be at 4:45 pm
      final banana = schedule.firstWhere((item) => item.title == 'Pre-Workout Banana');
      expect(banana.time, '4:45-4:50 pm');
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
}
