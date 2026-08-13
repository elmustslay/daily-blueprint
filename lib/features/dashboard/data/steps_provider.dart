import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'dart:io';
import '../../daily_plan/data/daily_plan_data.dart';

class StepsData {
  final int currentWeeklySteps;
  final int targetWeeklySteps;
  final bool isLissDay;
  final String? errorMessage;

  StepsData({
    required this.currentWeeklySteps,
    required this.targetWeeklySteps,
    this.isLissDay = false,
    this.errorMessage,
  });

  int get stepsRemainingWeekly => targetWeeklySteps > currentWeeklySteps ? targetWeeklySteps - currentWeeklySteps : 0;
}

final stepsProvider = FutureProvider<StepsData>((ref) async {
  if (!Platform.isIOS) {
    return StepsData(currentWeeklySteps: 0, targetWeeklySteps: 40000);
  }

  final now = DateTime.now();
  final dayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday
  
  bool isRefeed = DailyPlanData.isRefeedWeek();
  
  // During a Refeed week, there is no LISS. Steps count every day (6k/day * 7 = 42k).
  // During a Cut week, Wed and Sat are LISS days, so they don't count towards NEAT (8k/day * 5 = 40k).
  bool isLissDay = !isRefeed && (dayOfWeek == DateTime.wednesday || dayOfWeek == DateTime.saturday);
  
  int weeklyTarget = isRefeed ? 42000 : 40000;

  int weeklySteps = 0;
  String? errorMsg;
  
  try {
    final types = [HealthDataType.STEPS];
    bool authorized = await Health().requestAuthorization(types);

    if (authorized) {
      // Find Monday of the current week (start of day)
      int daysSinceMonday = now.weekday - 1;
      DateTime monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysSinceMonday));
      
      // Iterate from Monday up to Today
      for (int i = 0; i <= daysSinceMonday; i++) {
        DateTime dayStart = monday.add(Duration(days: i));
        DateTime dayEnd = dayStart.add(const Duration(days: 1)); 
        
        if (i == daysSinceMonday) {
          dayEnd = now; // For today, fetch up to current time
        }

        // On a Cut week, Wed and Sat have LISS from 5pm to 11pm. 
        // Only exclude that specific 6-hour window so we still count work/morning steps!
        bool isCutLissDay = !isRefeed && (dayStart.weekday == DateTime.wednesday || dayStart.weekday == DateTime.saturday);
        
        if (isCutLissDay) {
          DateTime beforeLissEnd = DateTime(dayStart.year, dayStart.month, dayStart.day, 17, 0);
          DateTime afterLissStart = DateTime(dayStart.year, dayStart.month, dayStart.day, 23, 0);
          
          // Fetch steps before 5 PM
          if (dayStart.isBefore(beforeLissEnd)) {
            DateTime end1 = beforeLissEnd.isBefore(dayEnd) ? beforeLissEnd : dayEnd;
            int steps1 = await Health().getTotalStepsInInterval(dayStart, end1) ?? 0;
            weeklySteps += steps1;
          }
          
          // Fetch steps after 11 PM
          if (afterLissStart.isBefore(dayEnd)) {
            int steps2 = await Health().getTotalStepsInInterval(afterLissStart, dayEnd) ?? 0;
            weeklySteps += steps2;
          }
        } else {
          int daySteps = await Health().getTotalStepsInInterval(dayStart, dayEnd) ?? 0;
          weeklySteps += daySteps;
        }
      }
    }
  } catch (e) {
    errorMsg = e.toString();
    print("HealthKit Error: $e");
  }

  return StepsData(
    currentWeeklySteps: weeklySteps,
    targetWeeklySteps: weeklyTarget,
    isLissDay: isLissDay,
    errorMessage: errorMsg,
  );
});
