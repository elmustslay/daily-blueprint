import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/features/gym_plan/presentation/gym_plan_screen.dart';
import 'package:my_app/features/gym_plan/data/gym_data.dart';

class FakeGymRepository implements GymRepository {
  int logsToday = 0;
  double? mockedMax;
  double? mockedPrev;

  @override
  Future<void> logWeights(String exerciseId, List<double> weights, {int startIndex = 1}) async {
    logsToday += weights.length;
  }

  @override
  Future<List<ExerciseLog>> getLogs(String exerciseId) async {
    List<ExerciseLog> fakeLogs = [];
    final today = DateTime.now();
    for (int i = 0; i < logsToday; i++) {
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
    repo.logsToday = 1;

    await tester.pumpWidget(buildTestableWidget(repo, testExercise, hasStartedWorkout: true));
    await tester.pumpAndSettle();

    expect(find.text('Smart Warm-up'), findsNothing);
    expect(find.text('Set as Start'), findsNothing);
  });

  testWidgets('Card fades (Opacity 0.6) and button disables with label Completed when sets are fulfilled', (WidgetTester tester) async {
    final repo = FakeGymRepository();
    repo.logsToday = 3; 

    await tester.pumpWidget(buildTestableWidget(repo, testExercise));
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Log Weight'), findsNothing);
    
    final opacityWidget = tester.widgetList<Opacity>(find.byType(Opacity)).first;
    expect(opacityWidget.opacity, 0.6);
  });

  testWidgets('Dialog generates appropriate remaining sets out of original sets', (WidgetTester tester) async {
    final repo = FakeGymRepository();
    repo.logsToday = 1; 

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
}
