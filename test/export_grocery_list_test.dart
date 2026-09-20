import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/daily_plan/data/daily_plan_data.dart';
import 'package:my_app/features/micro_macro_calorie_track/domain/nutrition.dart';

void main() {
  Map<String, double> getGroceryListForOffset(int daysOffset, Map<String, String> ingredientUnits) {
    DailyPlanData.mockCurrentDate = DailyPlanData.planStartDate.add(Duration(days: daysOffset));
    final Map<String, double> ingredientTotals = {};

    final days = [
      DailyPlanData.mon,
      DailyPlanData.tue,
      DailyPlanData.wed,
      DailyPlanData.thu,
      DailyPlanData.fri,
      DailyPlanData.sat,
      DailyPlanData.sun
    ];

    for (final dayKey in days) {
      final dayItems = DailyPlanData.schedules[dayKey] ?? [];
      for (var item in dayItems) {
        if (item.mealRecord != null) {
          for (var portion in item.mealRecord!.items) {
            final name = portion.ingredient.name;
            ingredientTotals[name] = (ingredientTotals[name] ?? 0.0) + portion.amount;
            ingredientUnits[name] = portion.ingredient.baseUnit;
          }
          for (var rPortion in item.mealRecord!.recipeItems) {
            if (rPortion.recipe.servings > 0) {
              double recipeScale = rPortion.servings / rPortion.recipe.servings;
              for (var portion in rPortion.recipe.ingredients) {
                final name = portion.ingredient.name;
                final amount = portion.amount * recipeScale;
                ingredientTotals[name] = (ingredientTotals[name] ?? 0.0) + amount;
                ingredientUnits[name] = portion.ingredient.baseUnit;
              }
            }
          }
        }
      }
    }
    return ingredientTotals;
  }

  String formatAmount(double total) {
    if (total == 0) return '0';
    String str = total.toStringAsFixed(2);
    if (str.endsWith('.00')) {
      return total.round().toString();
    }
    return str;
  }

  test('Calculate and export consolidated weekly grocery list via simulation', () async {
    final Map<String, String> units = {};
    
    // We will store the grocery list for each unique combination of (isRefeed, isAshwaOff)
    // that naturally occurs during a 24-week simulation.
    Map<String, double>? stdOn;
    Map<String, double>? stdOff;

    // Simulate 24 weeks (about 6 months) to capture all cycle variations
    for (int w = 0; w < 24; w++) {
      int daysOffset = w * 7;
      DailyPlanData.mockCurrentDate = DailyPlanData.planStartDate.add(Duration(days: daysOffset));
      
      bool isAshwaOff = DailyPlanData.isAshwagandhaOff();
      
      var list = getGroceryListForOffset(daysOffset, units);
      
      if (!isAshwaOff) stdOn ??= list;
      if (isAshwaOff) stdOff ??= list;
    }
    
    // Fallback to empty maps if a combination never naturally occurred in 24 weeks
    stdOn ??= {};
    stdOff ??= {};
    
    // Get all unique ingredients across all found scenarios
    final allIngredients = {...stdOn.keys, ...stdOff.keys}.toList()..sort();
    
    final buffer = StringBuffer();
    buffer.writeln('=== CONSOLIDATED WEEKLY GROCERY LIST ===');
    buffer.writeln('');

    for (final key in allIngredients) {
      final unit = units[key]!;
      final vStdOn = stdOn[key] ?? 0.0;
      final vStdOff = stdOff[key] ?? 0.0;
      
      final strStdOn = formatAmount(vStdOn);
      final strStdOff = formatAmount(vStdOff);

      if (vStdOn == vStdOff) {
        // Same across all scenarios
        buffer.writeln('- $key: $strStdOn $unit');
      } else {
        // Changes only by Ashwagandha On vs Off
        buffer.writeln('- $key: $strStdOn $unit (On), $strStdOff $unit (Off)');
      }
    }

    final file = File('outputs/shopping_list.txt');
    await file.writeAsString(buffer.toString());
    print('Successfully exported consolidated grocery list to outputs/shopping_list.txt');
    
    DailyPlanData.mockCurrentDate = null;
  });
}
