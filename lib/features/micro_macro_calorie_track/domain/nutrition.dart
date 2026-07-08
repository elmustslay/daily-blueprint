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
      'Calories': double.parse(calories.toStringAsFixed(1)),
      'Protein': double.parse(protein.toStringAsFixed(1)),
      'Carbs': double.parse(carbs.toStringAsFixed(1)),
      'Fat': double.parse(fat.toStringAsFixed(1)),
      'Micros': microNutrients.map((k, v) => MapEntry(k, double.parse(v.toStringAsFixed(2)))),
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

  double calculateAbsorbedIron() {
    double hemeIron = 0.0;
    double nonHemeIron = 0.0;
    final totalNut = totalNutrition;
    
    double calcium = (totalNut.microNutrients['Calcium (Food) (mg)'] ?? 0.0) +
        (totalNut.microNutrients['Calcium (Supplement) (mg)'] ?? 0.0);
    double vitaminC = totalNut.microNutrients['Vitamin C (mg)'] ?? 0.0;

    final hemeIds = {'salmon', 'ground_turkey', 'ground_beef_96', 'chipotle_bowl'};

    void processPortion(IngredientPortion portion, double scale) {
      double ironFood = (portion.ingredient.nutritionPerBaseUnit.microNutrients['Iron (Food) (mg)'] ?? 0.0) * scale;
      double ironSupp = (portion.ingredient.nutritionPerBaseUnit.microNutrients['Iron (Supplement) (mg)'] ?? 0.0) * scale;
      double iron = ironFood + ironSupp;
      
      if (iron > 0) {
        if (hemeIds.contains(portion.ingredient.id)) {
          hemeIron += iron;
        } else {
          nonHemeIron += iron;
        }
      }
    }

    for (var portion in items) {
      processPortion(portion, portion.amount);
    }

    for (var rPortion in recipeItems) {
      if (rPortion.recipe.servings > 0) {
        double recipeScale = rPortion.servings / rPortion.recipe.servings;
        for (var portion in rPortion.recipe.ingredients) {
          processPortion(portion, portion.amount * recipeScale);
        }
      }
    }

    double baseHemeAbsorbed = hemeIron * 0.20;

    double vitCModifier = 1.0;
    if (vitaminC > 0) {
      vitCModifier += (vitaminC / 10.0) * 0.05;
      if (vitCModifier > 3.0) vitCModifier = 3.0;
    }
    double baseNonHemeAbsorbed = nonHemeIron * 0.05 * vitCModifier;

    double totalAbsorbed = baseHemeAbsorbed + baseNonHemeAbsorbed;

    double inhibitionFactor = 0.0;
    if (calcium >= 50 && calcium <= 300) {
      inhibitionFactor = ((calcium - 50) / 250) * 0.50;
    } else if (calcium > 300) {
      inhibitionFactor = 0.50;
    }

    return totalAbsorbed * (1.0 - inhibitionFactor);
  }
}
