import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/features/gym_plan/presentation/gym_plan_screen.dart';
import 'package:my_app/features/gym_plan/data/gym_data.dart';
import 'package:my_app/features/daily_plan/data/daily_plan_data.dart';

class FakeGymRepository implements GymRepository {
  Map<String, int> logsTodayMap = {};
  double? mockedMax;
  double? mockedPrev;

  @override
  Future<void> logWeights(String exerciseId, List<double> weights, {int startIndex = 1}) async {
    logsTodayMap[exerciseId] = (logsTodayMap[exerciseId] ?? 0) + weights.length;
  }

  @override
  Future<List<ExerciseLog>> getLogs(String exerciseId) async {
    List<ExerciseLog> fakeLogs = [];
    final today = DateTime.now();
    final count = logsTodayMap[exerciseId] ?? 0;
    for (int i = 0; i < count; i++) {
       fakeLogs.add(ExerciseLog(id: i, exerciseId: exerciseId, date: today, weight: 100.0, setIndex: i + 1));
    }
    return fakeLogs;
  }

  @override
  Future<double?> getMaxWeight(String exerciseId, int setIndex) async => mockedMax;

  @override
  Future<double?> getPrevWeight(String exerciseId, int setIndex) async => mockedPrev;

  @override
  Future<String> exportAllTrendsCsv() async => "path/to/csv";

  @override
  Future<void> updateLogWeight(int id, double newWeight) async {}

  @override
  Future<void> deleteLog(int id) async {}

  @override
  Future<List<ExerciseLog>> getAllLogs() async => [];
}

void main() {
  Widget buildTestableWidget(FakeGymRepository repo, Exercise exercise, {bool hasStartedWorkout = false}) {
    return ProviderScope(
      overrides: [
        gymRepoProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: ExerciseCard(
            exercise: exercise,
            hasStartedWorkout: hasStartedWorkout,
          ),
        ),
      ),
    );
  }

  final testExercise = const Exercise(
    id: 'test_1',
    name: 'Test Chest Press',
    tip: 'Some tip',
    sets: '3',
    reps: '10-12',
    rest: '1 min',
  );

  testWidgets('Renders Set as Start button by default and triggers Smart Warm-up on tap', (WidgetTester tester) async {
    final repo = FakeGymRepository();
    repo.mockedPrev = 200.0; 

    await tester.pumpWidget(buildTestableWidget(repo, testExercise));
    await tester.pumpAndSettle();

    expect(find.text('Set as Start'), findsOneWidget);
    expect(find.text('Smart Warm-up'), findsNothing);

    await tester.tap(find.text('Set as Start'));
    await tester.pumpAndSettle();

    expect(find.text('Smart Warm-up'), findsOneWidget);
    // 50% of 200 = 100
    expect(find.textContaining('100 lbs'), findsOneWidget);
    // 70% of 200 = 140
    expect(find.textContaining('140 lbs'), findsOneWidget);
    // 85% of 200 = 170
    expect(find.textContaining('170 lbs'), findsOneWidget);
    
    expect(find.text('Set as Start'), findsNothing);
  });

  testWidgets('Does NOT display Smart Warm-up or Set as Start if todayLogCount > 0', (WidgetTester tester) async {
    final repo = FakeGymRepository();
    repo.mockedPrev = 200.0;
    repo.logsTodayMap[testExercise.id] = 1;

    await tester.pumpWidget(buildTestableWidget(repo, testExercise, hasStartedWorkout: true));
    await tester.pumpAndSettle();

    expect(find.text('Smart Warm-up'), findsNothing);
    expect(find.text('Set as Start'), findsNothing);
  });

  testWidgets('Card fades (Opacity 0.6) and button disables with label Completed when sets are fulfilled', (WidgetTester tester) async {
    final repo = FakeGymRepository();
    repo.logsTodayMap[testExercise.id] = 3; 

    await tester.pumpWidget(buildTestableWidget(repo, testExercise));
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Log Weight'), findsNothing);
    
    final opacityWidget = tester.widgetList<Opacity>(find.byType(Opacity)).first;
    expect(opacityWidget.opacity, 0.6);
  });

  testWidgets('Dialog generates appropriate remaining sets out of original sets', (WidgetTester tester) async {
    final repo = FakeGymRepository();
    repo.logsTodayMap[testExercise.id] = 1; 

    await tester.pumpWidget(buildTestableWidget(repo, testExercise));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log Weight'));
    await tester.pumpAndSettle(); 

    expect(find.text('Log Test Chest Press'), findsOneWidget);

    expect(find.text('Set 2 (lbs)'), findsOneWidget);
    expect(find.text('Set 3 (lbs)'), findsOneWidget);
    expect(find.text('Set 1 (lbs)'), findsNothing);
    expect(find.text('Set 4 (lbs)'), findsNothing);
    
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('GymPlanScreen sorts active workouts to top, untouched in middle, completed at bottom', (WidgetTester tester) async {
    final repo = FakeGymRepository();
    // GymData.upperADay has 8 exercises.
    // [0] push_1: 'Hammer Strength MTS Incline Press'
    // [1] pull_1: 'Lat Pulldown Machine'
    // [2] push_3: 'Pec Deck / Machine Fly' (we will set to ACTIVE)
    // [3] pull_4: 'Machine Reverse Fly / Rear Delt'
    // [4] push_2: 'Dumbbell Lateral Raise' (we will set to COMPLETED)
    // [5] push_5: 'Tricep Pushdown/Press'
    // [6] pull_5: 'Machine Bicep Curl'
    // [7] stretch_upper_a: 'Post-Workout Mobility'
    
    repo.logsTodayMap['push_2'] = 3; // Completed (3 sets)
    repo.logsTodayMap['push_3'] = 1; // Active (1 set out of 3)

    tester.view.physicalSize = const Size(1080, 4800);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gymRepoProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(
          home: GymPlanScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    
    // Explicitly navigate to Upper A so the test checks the expected workout list,
    // otherwise the new default tab feature will open to today's workout (e.g. Lower A).
    await tester.tap(find.text('Upper A'));
    await tester.pumpAndSettle();
    
    final exerciseCards = tester.widgetList<ExerciseCard>(find.byType(ExerciseCard)).toList();
    final titles = exerciseCards.map((card) => card.exercise.name).toList();
    
    // We expect the new sorted sequence based on Active -> Untouched -> Completed
    expect(titles.first, 'Pec Deck / Machine Fly'); 
    expect(titles[1], 'Hammer Strength MTS Incline Press');
    expect(titles[2], 'Lat Pulldown Machine');
    expect(titles[3], 'Machine Reverse Fly / Rear Delt');
    expect(titles[4], 'Tricep Pushdown/Press');
    expect(titles[5], 'Machine Bicep Curl');
    expect(titles[6], 'Post-Workout Mobility');
    expect(titles.last, 'Dumbbell Lateral Raise'); 

    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('GymPlanScreen opens to the correct default tab based on current weekday', (WidgetTester tester) async {
    final repo = FakeGymRepository();
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gymRepoProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(
          home: GymPlanScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    final controller = tabBar.controller!;
    
    final weekday = DateTime.now().weekday;
    int expectedIndex;
    switch (weekday) {
      case DateTime.monday: expectedIndex = 0; break;
      case DateTime.tuesday: expectedIndex = 1; break;
      case DateTime.thursday: expectedIndex = 2; break;
      case DateTime.friday: expectedIndex = 3; break;
      default: expectedIndex = 4; break;
    }
    
    expect(controller.index, expectedIndex);
  });
}
