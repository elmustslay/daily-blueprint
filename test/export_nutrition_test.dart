import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/daily_plan/data/daily_plan_data.dart';
import 'package:my_app/features/micro_macro_calorie_track/domain/nutrition.dart';

void main() {
  test('Calculate and export nutrition to mynutrition.json', () async {
    NutritionFact weeklyTotals = const NutritionFact();
    final Map<String, NutritionFact> dailyTotalsMap = {};
    
    final days = [
      DailyPlanData.mon,
      DailyPlanData.tue,
      DailyPlanData.wed,
      DailyPlanData.thu,
      DailyPlanData.fri,
      DailyPlanData.sat,
      DailyPlanData.sun
    ];
    
    for (int i = 0; i < 7; i++) {
      final dayKey = days[i];
      final dayItems = DailyPlanData.schedules[dayKey] ?? [];
      NutritionFact dayTotal = const NutritionFact();
      
      for (var item in dayItems) {
        if (item.mealRecord != null) {
          dayTotal += item.mealRecord!.totalNutrition;
          weeklyTotals += item.mealRecord!.totalNutrition;
        }
      }
      dailyTotalsMap[dayKey] = dayTotal;
    }
    
    final exportData = {
      'weeklyTotals': weeklyTotals.toJson(),
      'dailyTotals': dailyTotalsMap.map((k, v) => MapEntry(k, v.toJson())),
    };
    
    // Write formatted JSON to mynutrition.json
    final jsonString = const JsonEncoder.withIndent('    ').convert(exportData);
    final file = File('mynutrition.json');
    await file.writeAsString(jsonString);
    
    print('Successfully exported nutrition data to mynutrition.json');
    expect(file.existsSync(), isTrue);

    // Trigger python script to update CSV, or fallback to generating it in Dart
    bool csvUpdatedByPython = false;
    try {
      ProcessResult result = await Process.run('python3', ['json_to_csv.py']);
      if (result.exitCode != 0) {
        result = await Process.run('python', ['json_to_csv.py']);
      }
      if (result.exitCode == 0) {
        print(result.stdout.toString().trim());
        csvUpdatedByPython = true;
      } else {
        print('Warning: Python script returned exit code ${result.exitCode}. Error: ${result.stderr}');
      }
    } catch (e) {
      print('Warning: Failed to execute python converter script: $e');
    }

    if (!csvUpdatedByPython) {
      print('Generating mynutrition.csv directly via Dart fallback...');
      try {
        final metrics = ['Calories', 'Protein', 'Carbs', 'Fat'];
        final Set<String> allMicros = {};
        
        final weeklyTotalsMap = exportData['weeklyTotals'] as Map<String, dynamic>? ?? {};
        final weeklyMicros = weeklyTotalsMap['Micros'] as Map<String, dynamic>? ?? {};
        allMicros.addAll(weeklyMicros.keys);
        
        final dailyTotals = exportData['dailyTotals'] as Map<String, dynamic>? ?? {};
        for (final day in days) {
          final dayData = dailyTotals[day] as Map<String, dynamic>? ?? {};
          final dayMicros = dayData['Micros'] as Map<String, dynamic>? ?? {};
          allMicros.addAll(dayMicros.keys);
        }
        
        final sortedMicros = allMicros.toList()..sort();
        final allMetrics = [...metrics, ...sortedMicros];
        
        final csvBuffer = StringBuffer();
        csvBuffer.writeln('Metric,Weekly Total,Mon,Tue,Wed,Thu,Fri,Sat,Sun');
        
        for (final metric in allMetrics) {
          final List<String> row = [];
          row.add(metric);
          
          if (metrics.contains(metric)) {
            row.add((weeklyTotalsMap[metric] ?? 0).toString());
          } else {
            row.add((weeklyMicros[metric] ?? 0).toString());
          }
          
          for (final day in days) {
            final dayData = dailyTotals[day] as Map<String, dynamic>? ?? {};
            if (metrics.contains(metric)) {
              row.add((dayData[metric] ?? 0).toString());
            } else {
              final dayMicros = dayData['Micros'] as Map<String, dynamic>? ?? {};
              row.add((dayMicros[metric] ?? 0).toString());
            }
          }
          csvBuffer.writeln(row.join(','));
        }
        
        final csvFile = File('mynutrition.csv');
        await csvFile.writeAsString(csvBuffer.toString());
        print('Success: Spreadsheet updated at ${csvFile.absolute.path}');
      } catch (e) {
        print('Error: Failed to generate mynutrition.csv directly: $e');
      }
    }
  });
}
