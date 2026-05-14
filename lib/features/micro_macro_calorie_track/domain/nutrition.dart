class NutritionFact {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final Map<String, double> microNutrients;

  const NutritionFact({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.microNutrients = const {},
  });

  NutritionFact operator +(NutritionFact other) {
    var newMicros = Map<String, double>.from(microNutrients);
    other.microNutrients.forEach((k, v) {
      newMicros[k] = (newMicros[k] ?? 0) + v;
    });
    return NutritionFact(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
      microNutrients: newMicros,
    );
  }

  NutritionFact operator *(double multiplier) {
    var newMicros = microNutrients.map((k, v) => MapEntry(k, v * multiplier));
    return NutritionFact(
      calories: calories * multiplier,
      protein: protein * multiplier,
      carbs: carbs * multiplier,
      fat: fat * multiplier,
      microNutrients: newMicros,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': double.parse(calories.toStringAsFixed(1)),
      'protein': double.parse(protein.toStringAsFixed(1)),
      'carbs': double.parse(carbs.toStringAsFixed(1)),
      'fat': double.parse(fat.toStringAsFixed(1)),
      'microNutrients': microNutrients.map((k, v) => MapEntry(k, double.parse(v.toStringAsFixed(2)))),
    };
  }
}

class Ingredient {
  final String id;
  final String name;
  final String baseUnit; 
  final NutritionFact nutritionPerBaseUnit;

  const Ingredient({
    required this.id,
    required this.name,
    required this.baseUnit,
    this.nutritionPerBaseUnit = const NutritionFact(),
  });
}

class IngredientPortion {
  final Ingredient ingredient;
  final double amount;
  
  const IngredientPortion({
    required this.ingredient,
    required this.amount,
  });

  NutritionFact get totalNutrition => ingredient.nutritionPerBaseUnit * amount;
}

class Recipe {
  final String id;
  final String name;
  final String yields;
  final List<String> textIngredients;
  final List<IngredientPortion> ingredients;
  final int servings;
  final String icon;
  final List<String> equipment;
  final List<String> instructions;
  final bool isOutdated;

  const Recipe({
    required this.id,
    required this.name,
    this.yields = '',
    this.textIngredients = const [],
    required this.ingredients,
    required this.servings,
    this.icon = '',
    this.equipment = const [],
    this.instructions = const [],
    this.isOutdated = false,
  });

  NutritionFact get nutritionPerServing {
    NutritionFact total = const NutritionFact();
    for (var portion in ingredients) {
      total += portion.totalNutrition;
    }
    if (servings > 0) {
      return total * (1 / servings);
    }
    return total;
  }
}

class RecipePortion {
  final Recipe recipe;
  final double servings;

  const RecipePortion({
    required this.recipe,
    required this.servings,
  });

  NutritionFact get totalNutrition => recipe.nutritionPerServing * servings;
}

class MealRecord {
  final List<IngredientPortion> items;
  final List<RecipePortion> recipeItems;

  const MealRecord({
    this.items = const [],
    this.recipeItems = const [],
  });

  NutritionFact get totalNutrition {
    NutritionFact total = const NutritionFact();
    for (var portion in items) {
      total += portion.totalNutrition;
    }
    for (var rPortion in recipeItems) {
      total += rPortion.totalNutrition;
    }
    return total;
  }
}
