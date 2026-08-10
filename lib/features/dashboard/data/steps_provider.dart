import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'dart:io';
import '../../daily_plan/data/daily_plan_data.dart';

class StepsData {
  final int currentSteps;
  final int targetSteps;
  final bool isLissDay;
  final String? errorMessage;

  StepsData({
    required this.currentSteps,
    required this.targetSteps,
    this.isLissDay = false,
    this.errorMessage,
  });

  int get stepsRemaining => targetSteps > currentSteps ? targetSteps - currentSteps : 0;
}

final stepsProvider = FutureProvider<StepsData>((ref) async {
  if (!Platform.isIOS) {
    return StepsData(currentSteps: 0, targetSteps: 8000);
  }

  final now = DateTime.now();
  final dayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday
  
  bool isLissDay = (dayOfWeek == DateTime.tuesday || dayOfWeek == DateTime.thursday);
  
  int target = 8000;
  if (isLissDay) {
    target = 0; // LISS days are covered by 2 hours of LISS cardio (135bpm)
  } else if (DailyPlanData.isRefeedWeek()) {
    target = 6000; // Refeed week target
  }

  int steps = 0;
  
  String? errorMsg;
  try {
    final types = [HealthDataType.STEPS];
    
    // On iOS, hasPermissions often fails or returns false. 
    // It's recommended to just call requestAuthorization directly.
    bool authorized = await Health().requestAuthorization(types);

    if (authorized) {
      final startOfDay = DateTime(now.year, now.month, now.day);
      steps = await Health().getTotalStepsInInterval(startOfDay, now) ?? 0;
    }
  } catch (e) {
    errorMsg = e.toString();
    print("HealthKit Error: $e");
  }

  return StepsData(
    currentSteps: steps,
    targetSteps: target,
    isLissDay: isLissDay,
    errorMessage: errorMsg,
  );
});
