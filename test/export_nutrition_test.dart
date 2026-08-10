import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/daily_plan/data/daily_plan_data.dart';
import 'package:my_app/features/micro_macro_calorie_track/domain/nutrition.dart';
import 'package:my_app/features/micro_macro_calorie_track/data/ingredients_data.dart';
import 'package:my_app/features/recipe/data/recipe_data.dart';

void main() {
  Future<void> generateNutritionFiles(String prefix, {bool isRefeed = false}) async {
    if (isRefeed) {
      // Mock date to Week 5 (Refeed Week)
      DailyPlanData.mockCurrentDate = DailyPlanData.planStartDate.add(const Duration(days: 28)); // 4 weeks * 7 days
    } else {
      DailyPlanData.mockCurrentDate = null;
    }

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
          var nutrition = item.mealRecord!.totalNutrition;
          double absorbedIron = item.mealRecord!.calculateAbsorbedIron();
          if (absorbedIron > 0) {
            var newMicros = Map<String, double>.from(nutrition.microNutrients);
            newMicros['Absorbed Iron (mg)'] = absorbedIron;
            nutrition = NutritionFact(
              calories: nutrition.calories,
              protein: nutrition.protein,
              carbs: nutrition.carbs,
              fat: nutrition.fat,
              microNutrients: newMicros,
            );
          }
          dayTotal += nutrition;
          weeklyTotals += nutrition;
        }
      }
      dailyTotalsMap[dayKey] = dayTotal;
    }
    
    final exportData = {
      'weeklyTotals': weeklyTotals.toJson(),
      'dailyTotals': dailyTotalsMap.map((k, v) => MapEntry(k, v.toJson())),
    };
    
    // Write formatted JSON
    final jsonString = const JsonEncoder.withIndent('    ').convert(exportData);
    final file = File('${prefix}nutrition.json');
    await file.writeAsString(jsonString);
    
    print('Successfully exported nutrition data to ${prefix}nutrition.json');
    expect(file.existsSync(), isTrue);

    // Generate detailed nutrition
    final Map<String, dynamic> detailedExport = {};
    for (int i = 0; i < 7; i++) {
      final dayKey = days[i];
      final dayItems = DailyPlanData.schedules[dayKey] ?? [];
      final Map<String, dynamic> timePeriods = {};
      
      for (var item in dayItems) {
        if (item.mealRecord != null) {
          var nutrition = item.mealRecord!.totalNutrition;
          double absorbedIron = item.mealRecord!.calculateAbsorbedIron();
          if (absorbedIron > 0) {
            var newMicros = Map<String, double>.from(nutrition.microNutrients);
            newMicros['Absorbed Iron (mg)'] = absorbedIron;
            nutrition = NutritionFact(
              calories: nutrition.calories,
              protein: nutrition.protein,
              carbs: nutrition.carbs,
              fat: nutrition.fat,
              microNutrients: newMicros,
            );
          }
          if (nutrition.calories > 0 || nutrition.protein > 0 || nutrition.carbs > 0 || nutrition.fat > 0 || nutrition.microNutrients.isNotEmpty) {
            timePeriods[item.time] = {
              'title': item.title,
              'nutrition': nutrition.toJson(),
            };
          }
        }
      }
      detailedExport[dayKey] = timePeriods;
    }
    
    final detailedJsonString = const JsonEncoder.withIndent('    ').convert(detailedExport);
    final detailedFile = File('${prefix}detailednutrition.json');
    await detailedFile.writeAsString(detailedJsonString);
    print('Successfully exported detailed nutrition data to ${prefix}detailednutrition.json');

    if (isRefeed) return; // Skip CSV for refeed week to avoid complexity

    // Trigger python script to update CSV, or fallback to generating it in Dart
    bool csvUpdatedByPython = false;
    try {
      ProcessResult result = await Process.run('python3', ['personal_py_simulation/json_to_csv.py']);
      if (result.exitCode != 0) {
        result = await Process.run('python', ['personal_py_simulation/json_to_csv.py']);
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
        
        final csvFile = File('${prefix}nutrition.csv');
        await csvFile.writeAsString(csvBuffer.toString());
        print('Success: Spreadsheet updated at ${csvFile.absolute.path}');
      } catch (e) {
        print('Error: Failed to generate ${prefix}nutrition.csv directly: $e');
      }
    }
  }

  test('Calculate and export nutrition to JSON files', () async {
    await generateNutritionFiles('my');
    await generateNutritionFiles('myrefeed', isRefeed: true);

    // Reset mock date
    DailyPlanData.mockCurrentDate = null;

    // Export Recipes Nutrition
    try {
      final Map<String, dynamic> recipeExport = {};
      for (var recipe in RecipeData.recipes) {
        recipeExport[recipe.id] = {
          'name': recipe.name,
          'servings': recipe.servings,
          'nutrition': recipe.nutritionPerServing.toJson(),
        };
      }
      final recipeJsonString = const JsonEncoder.withIndent('    ').convert(recipeExport);
      final recipeJsonFile = File('recipe_nutrition.json');
      await recipeJsonFile.writeAsString(recipeJsonString);
      print('Successfully exported recipe nutrition to recipe_nutrition.json');
    } catch (e) {
      print('Error: Failed to export recipe nutrition: $e');
    }

    // Export Ingredients Nutrition
    try {
      final Map<String, dynamic> ingredientExport = {};
      for (var ingredient in IngredientsData.allIngredients) {
        ingredientExport[ingredient.id] = {
          'name': ingredient.name,
          'baseUnit': ingredient.baseUnit,
          'nutrition': ingredient.nutritionPerBaseUnit.toJson(),
        };
      }
      final ingredientJsonString = const JsonEncoder.withIndent('    ').convert(ingredientExport);
      final ingredientJsonFile = File('ingredient_nutrition.json');
      await ingredientJsonFile.writeAsString(ingredientJsonString);
      print('Successfully exported ingredient nutrition to ingredient_nutrition.json');
    } catch (e) {
      print('Error: Failed to export ingredient nutrition: $e');
    }

    // Export day-by-day simulation timeline directly from DailyPlanData
    try {
      final startDate = DateTime(2026, 7, 27);
      final targetDate = DateTime(2026, 12, 17);
      final totalDays = targetDate.difference(startDate).inDays;
      
      final List<Map<String, dynamic>> timeline = [];
      final dayNames = [
        DailyPlanData.mon,
        DailyPlanData.tue,
        DailyPlanData.wed,
        DailyPlanData.thu,
        DailyPlanData.fri,
        DailyPlanData.sat,
        DailyPlanData.sun
      ];

      for (int d = 0; d < totalDays; d++) {
        final date = startDate.add(Duration(days: d));
        DailyPlanData.mockCurrentDate = date;
        final dayKey = dayNames[date.weekday - 1];
        final isRefeed = DailyPlanData.isRefeedWeek();
        final schedule = DailyPlanData.schedules[dayKey] ?? [];
        
        NutritionFact dayTotal = const NutritionFact();
        List<Map<String, dynamic>> meals = [];
        for (var item in schedule) {
          if (item.mealRecord != null) {
            final nutrition = item.mealRecord!.totalNutrition;
            dayTotal += nutrition;
            if (nutrition.calories > 0 || nutrition.protein > 0 || nutrition.carbs > 0 || nutrition.fat > 0) {
              meals.add({
                'time': item.time,
                'title': item.title,
                'cal': nutrition.calories,
                'prot': nutrition.protein,
                'carb': nutrition.carbs,
                'fiber': nutrition.microNutrients['Fiber (g)'] ?? 0.0,
                'fat': nutrition.fat,
                'sodium': nutrition.microNutrients['Sodium (mg)'] ?? 0.0,
                'potassium': nutrition.microNutrients['Potassium (mg)'] ?? 0.0,
              });
            }
          }
        }
        
        timeline.add({
          'day': d,
          'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          'dayName': dayKey,
          'weekNumber': DailyPlanData.currentWeekNumber,
          'isRefeed': isRefeed,
          'cal': dayTotal.calories,
          'prot': dayTotal.protein,
          'carb': dayTotal.carbs,
          'fiber': dayTotal.microNutrients['Fiber (g)'] ?? 0.0,
          'fat': dayTotal.fat,
          'sodium': dayTotal.microNutrients['Sodium (mg)'] ?? 0.0,
          'potassium': dayTotal.microNutrients['Potassium (mg)'] ?? 0.0,
          'meals': meals,
        });
      }
      
      final timelineJson = const JsonEncoder.withIndent('    ').convert(timeline);
      final timelineFile = File('simulation_timeline.json');
      await timelineFile.writeAsString(timelineJson);
      print('Successfully exported simulation timeline to simulation_timeline.json (${timeline.length} days)');
    } catch (e) {
      print('Error: Failed to export simulation timeline: $e');
    } finally {
      DailyPlanData.mockCurrentDate = null;
    }
  });
}
