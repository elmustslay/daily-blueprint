import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'dart:io';
import '../../daily_plan/data/daily_plan_data.dart';
import 'package:intl/intl.dart';

class WorkoutLog {
  final DateTime date;
  final int stepsEquivalent;
  final int calories;
  
  WorkoutLog(this.date, this.stepsEquivalent, this.calories);
}

class StepsData {
  final int targetWeeklySteps;
  final int naturalSteps;
  final List<WorkoutLog> danceWorkouts;
  final List<WorkoutLog> lissWorkouts;
  final bool isLissDay;
  final String? errorMessage;

  StepsData({
    required this.targetWeeklySteps,
    required this.naturalSteps,
    required this.danceWorkouts,
    required this.lissWorkouts,
    this.isLissDay = false,
    this.errorMessage,
  });

  int get totalDanceSteps => danceWorkouts.fold(0, (sum, log) => sum + log.stepsEquivalent);
  int get totalLissSteps => lissWorkouts.fold(0, (sum, log) => sum + log.stepsEquivalent);
  int get currentWeeklySteps => naturalSteps + totalDanceSteps + totalLissSteps;
  int get stepsRemainingWeekly => targetWeeklySteps > currentWeeklySteps ? targetWeeklySteps - currentWeeklySteps : 0;
}

final stepsProvider = FutureProvider<StepsData>((ref) async {
  if (!Platform.isIOS) {
    return StepsData(targetWeeklySteps: 40000, naturalSteps: 0, danceWorkouts: [], lissWorkouts: []);
  }

  final now = DateTime.now();
  final dayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday
  bool isRefeed = DailyPlanData.isRefeedWeek();
  
  // During a Refeed week, there is no LISS. Steps count every day (6k/day * 7 = 42k).
  // During a Cut week, Wed and Sat are LISS days, so they don't count towards NEAT (8k/day * 5 = 40k).
  // Wait, if we are unifying LISS into steps, the weekly target should be higher to account for LISS!
  // If LISS is combined into steps: 2 days of LISS @ ~10,000 steps equivalent each = +20,000 steps.
  // Wait! The user's goal was 56,000 steps/week for Cut (8k * 7 days). 
  // CUT: 55,000 unified steps maps to ~1.55 multiplier (above 1.50, extra fat loss, 0 catabolism per py sim)
  // REFEED: 27,000 unified steps maps to ~1.375 multiplier (perfect hormonal reset)
  bool isLissDay = (dayOfWeek == DateTime.wednesday || dayOfWeek == DateTime.saturday);
  int weeklyTarget = isRefeed ? 27000 : 55000;

  // 🍕 Pizza Offset: Adding 20,000 steps this week to cleanly wipe out 1,000 calories (at 1:20 ratio)
  if (now.isAfter(DateTime(2026, 9, 15)) && now.isBefore(DateTime(2026, 9, 21))) {
    weeklyTarget = 75000;
  }

  int naturalSteps = 0;
  List<WorkoutLog> danceWorkouts = [];
  List<WorkoutLog> lissWorkouts = [];
  String? errorMsg;
  
  try {
    final types = [HealthDataType.STEPS, HealthDataType.WORKOUT];
    bool authorized = await Health().requestAuthorization(types);

    if (authorized) {
      int daysSinceMonday = now.weekday - 1;
      DateTime monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysSinceMonday));
      
      // 1. Fetch Natural Steps
      for (int i = 0; i <= daysSinceMonday; i++) {
        DateTime dayStart = monday.add(Duration(days: i));
        DateTime dayEnd = dayStart.add(const Duration(days: 1)); 
        if (i == daysSinceMonday) dayEnd = now;
        
        int daySteps = await Health().getTotalStepsInInterval(dayStart, dayEnd) ?? 0;
        naturalSteps += daySteps;
      }
      
      // 2. Fetch Workouts
      List<WorkoutLog> allTrackedWorkouts = [];
      List<HealthDataPoint> workouts = await Health().getHealthDataFromTypes(startTime: monday, endTime: now, types: [HealthDataType.WORKOUT]);
      for (var point in workouts) {
        if (point.value is WorkoutHealthValue) {
          WorkoutHealthValue workout = point.value as WorkoutHealthValue;
          
          // CONSERVATIVE MULTIPLIER: 1 Active Calorie = 20 steps.
          // Mathematically close to the "perfect" 22x (1000 steps / 45 kcal).
          // The 20x slightly under-credits Active Calories, forcing slightly more walking = safe err.
          int cals = workout.totalEnergyBurned ?? 0;
          int stepsEq = 0;
          
          if (cals > 0) {
            stepsEq = cals * 20;
          } else {
            // Fallback if calories aren't loaded: Conservative 100 steps/min
            stepsEq = point.dateTo.difference(point.dateFrom).inMinutes * 100;
          }
          
          if (stepsEq > 0) {
            String typeName = workout.workoutActivityType.toString().toUpperCase();
            if (typeName.contains('DANCE')) {
              danceWorkouts.add(WorkoutLog(point.dateFrom, stepsEq, cals));
              allTrackedWorkouts.add(WorkoutLog(point.dateFrom, stepsEq, cals));
            } else if (typeName.contains('WALK') || typeName.contains('ELLIPTICAL')) {
              lissWorkouts.add(WorkoutLog(point.dateFrom, stepsEq, cals));
              allTrackedWorkouts.add(WorkoutLog(point.dateFrom, stepsEq, cals));
            }
          }
        }
      }
      
      // 3. ANTI-DOUBLE-COUNT: Subtract natural steps that occurred during tracked workouts.
      // The pedometer counts steps during LISS/Dance, but we already credit those via Active Calories.
      // Without this, a 1-hour indoor walk would count ~4k pedometer steps AND ~10k equiv steps.
      for (var point in workouts) {
        if (point.value is WorkoutHealthValue) {
          WorkoutHealthValue workout = point.value as WorkoutHealthValue;
          String typeName = workout.workoutActivityType.toString().toUpperCase();
          if (typeName.contains('DANCE') || typeName.contains('WALK') || typeName.contains('ELLIPTICAL')) {
            int workoutSteps = await Health().getTotalStepsInInterval(point.dateFrom, point.dateTo) ?? 0;
            naturalSteps = naturalSteps - workoutSteps;
            if (naturalSteps < 0) naturalSteps = 0;
          }
        }
      }
      
      // Sort lists by date descending
      danceWorkouts.sort((a, b) => b.date.compareTo(a.date));
      lissWorkouts.sort((a, b) => b.date.compareTo(a.date));
    }
  } catch (e) {
    errorMsg = e.toString();
    print("HealthKit Error: $e");
  }

  return StepsData(
    targetWeeklySteps: weeklyTarget,
    naturalSteps: naturalSteps,
    danceWorkouts: danceWorkouts,
    lissWorkouts: lissWorkouts,
    isLissDay: isLissDay,
    errorMessage: errorMsg,
  );
});
