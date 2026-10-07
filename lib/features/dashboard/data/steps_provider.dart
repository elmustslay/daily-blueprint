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
  final int currentDailySteps;

  StepsData({
    required this.targetWeeklySteps,
    required this.naturalSteps,
    required this.danceWorkouts,
    required this.lissWorkouts,
    this.isLissDay = false,
    this.errorMessage,
    this.currentDailySteps = 0,
  });

  int get totalDanceSteps => danceWorkouts.fold(0, (sum, log) => sum + log.stepsEquivalent);
  int get totalLissSteps => lissWorkouts.fold(0, (sum, log) => sum + log.stepsEquivalent);
  int get currentWeeklySteps => naturalSteps + totalDanceSteps + totalLissSteps;
  int get stepsRemainingWeekly => targetWeeklySteps > currentWeeklySteps ? targetWeeklySteps - currentWeeklySteps : 0;
}

final stepsProvider = FutureProvider<StepsData>((ref) async {
  if (!Platform.isIOS) {
    return StepsData(targetWeeklySteps: 50000, naturalSteps: 0, danceWorkouts: [], lissWorkouts: []);
  }

  final now = DateTime.now();
  final dayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday
  
  // The physics engine sweet spot (matches Python simulation DAILY_STEPS array)
  // [6000, 8000, 10000, 4000, 4000, 10000, 8000] = 50,000 steps/week
  bool isLissDay = (dayOfWeek == DateTime.wednesday || dayOfWeek == DateTime.saturday);
  int weeklyTarget = 50000;

  // 🍝🍰 Pasta + Cake Offset: Added 14,000 steps for this week (700 cals extra)
  if (now.isAfter(DateTime(2026, 9, 28)) && now.isBefore(DateTime(2026, 10, 5))) {
    weeklyTarget = 64000;
  }

  int naturalSteps = 0;
  int stepsToday = 0;
  List<WorkoutLog> danceWorkouts = [];
  List<WorkoutLog> lissWorkouts = [];
  String? errorMsg;
  
  try {
    final types = [HealthDataType.STEPS, HealthDataType.WORKOUT];
    bool authorized = await Health().requestAuthorization(types);

    if (authorized) {
      int daysSinceMonday = now.weekday - 1;
      DateTime monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysSinceMonday));
      DateTime todayStart = DateTime(now.year, now.month, now.day);
      
      // 1. Fetch Natural Steps
      for (int i = 0; i <= daysSinceMonday; i++) {
        DateTime dayStart = monday.add(Duration(days: i));
        DateTime dayEnd = dayStart.add(const Duration(days: 1)); 
        if (i == daysSinceMonday) dayEnd = now;
        
        int daySteps = await Health().getTotalStepsInInterval(dayStart, dayEnd) ?? 0;
        naturalSteps += daySteps;
        if (i == daysSinceMonday) {
          stepsToday += daySteps;
        }
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
            if (point.dateFrom.isAfter(todayStart) || point.dateFrom.isAtSameMomentAs(todayStart)) {
              stepsToday += stepsEq;
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
            if (point.dateFrom.isAfter(todayStart) || point.dateFrom.isAtSameMomentAs(todayStart)) {
              stepsToday = stepsToday - workoutSteps;
              if (stepsToday < 0) stepsToday = 0;
            }
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
    currentDailySteps: stepsToday,
  );
});
