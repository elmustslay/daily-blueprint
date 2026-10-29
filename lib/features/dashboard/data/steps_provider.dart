import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'dart:io';
import 'dart:math' as math;
import '../../daily_plan/data/daily_plan_data.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Daily step targets indexed [Mon..Sun] = 60,000/week.
/// Keep in sync with the LAST entry of DAILY_STEPS_SCHEDULE in
/// personal_py_simulation/body_fat_calculator.py.
const List<int> kDailyStepTargets = [8500, 5000, 15000, 4000, 4000, 15000, 8500];

/// Thu/Fri are recovery days: the daily number is a CAP, not a goal.
const Set<int> kStepLimitDays = {DateTime.thursday, DateTime.friday};

/// On Saturday, leave at most this many steps for Sunday.
const int kSundayReserveSteps = 5000;

const int kDefaultWeeklySteps = 60000;
/// The old default; upgraded to 60k ONCE (see _migratedKey), never again.
const int _kLegacyWeeklySteps = 50000;

class TargetWeeklyStepsNotifier extends Notifier<int> {
  static const _key = 'target_weekly_steps';
  static const _migratedKey = 'target_weekly_steps_60k_migrated';
  SharedPreferences? _prefs;

  @override
  int build() {
    _load();
    return kDefaultWeeklySteps;
  }

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    // One-time upgrade of the old 50k default to 60k. After this runs, any value
    // you set yourself (including 50k) is kept as-is.
    if (!(_prefs!.getBool(_migratedKey) ?? false)) {
      if (_prefs!.getInt(_key) == _kLegacyWeeklySteps) {
        await _prefs!.setInt(_key, kDefaultWeeklySteps);
      }
      await _prefs!.setBool(_migratedKey, true);
    }
    if (_prefs!.containsKey(_key)) {
      state = _prefs!.getInt(_key)!;
    }
  }

  Future<void> updateTarget(int newTarget) async {
    state = newTarget;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setInt(_key, newTarget);
  }

  Future<void> resetToDefault() async {
    await updateTarget(kDefaultWeeklySteps);
  }
}

final targetWeeklyStepsProvider = NotifierProvider<TargetWeeklyStepsNotifier, int>(() {
  return TargetWeeklyStepsNotifier();
});
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

  bool get isDailyLimit => kStepLimitDays.contains(DateTime.now().weekday);

  /// Weekly steps still needed as of the START of today (today's steps excluded),
  /// so today's goal stays stable while you walk.
  int get _remainingAtDayStart =>
      math.max(0, targetWeeklySteps - (currentWeeklySteps - currentDailySteps));

  /// Today's goal:
  /// - Thu/Fri: fixed cap.
  /// - Saturday: what's left for the week minus [kSundayReserveSteps]; if that
  ///   would be <= 0, just whatever is left for the week.
  /// - Other days: the day's target, but never more than what's left for the week.
  int get dailyTarget {
    final wd = DateTime.now().weekday;
    final base = kDailyStepTargets[wd - 1];
    if (isDailyLimit) return base;
    final left = _remainingAtDayStart;
    if (wd == DateTime.saturday) {
      final t = left - kSundayReserveSteps;
      return t > 0 ? t : left;
    }
    return math.min(base, left);
  }

  int get stepsRemainingToday => math.max(0, dailyTarget - currentDailySteps);
}

final stepsProvider = FutureProvider<StepsData>((ref) async {
  final targetWeeklySteps = ref.watch(targetWeeklyStepsProvider);

  if (!Platform.isIOS) {
    return StepsData(targetWeeklySteps: targetWeeklySteps, naturalSteps: 0, danceWorkouts: [], lissWorkouts: []);
  }

  final now = DateTime.now();
  final dayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday
  
  // The physics engine sweet spot (matches Python simulation DAILY_STEPS array)
  // [6000, 8000, 10000, 4000, 4000, 10000, 8000] = 50,000 steps/week
  bool isLissDay = (dayOfWeek == DateTime.wednesday || dayOfWeek == DateTime.saturday);
  int weeklyTarget = targetWeeklySteps;

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
