import '../domain/nutrition.dart';

class IngredientsData {

  static const Ingredient spinach = Ingredient(
    id: 'spinach',
    name: 'Spinach',
    baseUnit: 'bag', // 1 bag = 4 servings
    nutritionPerBaseUnit: NutritionFact(
      calories: 80, 
      protein: 8, 
      carbs: 12, 
      fat: 0,
      microNutrients: {
        'Sodium (mg)': 260,
        'Potassium (mg)': 1880,
        'Fiber (g)': 8,
        'Calcium (Food) (mg)': 320,
        'Iron (Food) (mg)': 9.2,
        'Magnesium (mg)': 268, // #this is default assumed value 
        'Vitamin A (Food) (mcg)': 1580, // #this is default assumed value
        'Zinc (Food) (mg)': 0.6, // #this is default assumed value
      
        'Copper (mg)': 0.44, // #this is default assumed value
        'Selenium (Food) (mcg)': 3.4, // #this is default assumed value
        'Vitamin C (mg)': 95, // #this is default assumed value
        'Vitamin K (mcg)': 1640, // #this is default assumed value
        'Vitamin E (Food) (mg)': 6.9, // #this is default assumed value
        'Vitamin B12 (mcg)': 0, // #this is default assumed value
        'Thiamin (mg)': 0.26, // #this is default assumed value
        'Riboflavin (mg)': 0.64, // #this is default assumed value
        'Niacin (mg)': 2.4, // #this is default assumed value
        'Vitamin B5 (mg)': 0.22, // #this is default assumed value
        'Vitamin B6 (mg)': 0.66, // #this is default assumed value
        'Folate (Food) (mcg)': 660, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 0, // #this is default assumed value
        'Choline (mg)': 65, // #this is default assumed value
        'Tyrosine (Food) (mg)': 340, // #this is default assumed value
        'EPA (Food) (mg)': 0, // #this is default assumed value
        'DHA (Food) (mg)': 0, // #this is default assumed value
      },
    ),
  );

  static const Ingredient chipotleBowl = Ingredient(
    id: 'chipotle_bowl',
    name: 'Chipotle Chicken Bowl',
    baseUnit: 'bowl',
    nutritionPerBaseUnit: NutritionFact(
      calories: 740,
      protein: 78,
      carbs: 68,
      fat: 22,
      microNutrients: {
        'Saturated Fat (g)': 7,
        'Fiber (g)': 11,
        'Sugar (g)': 6,
        'Sodium (mg)': 1320,
        'Calcium (Food) (mg)': 195,
        'Iron (Food) (mg)': 6.12,
        'Vitamin A (Food) (mcg)': 108,
        'Vitamin C (mg)': 115.2,
        'Potassium (mg)': 1245.5, // #this is default assumed value
        'Magnesium (mg)': 193.0, // #this is default assumed value
        'Zinc (Food) (mg)': 6.5, // #this is default assumed value
        'Copper (mg)': 0.71, // #this is default assumed value
        'Selenium (Food) (mcg)': 71.6, // #this is default assumed value
        'Vitamin K (mcg)': 13.6, // #this is default assumed value
        'Vitamin E (Food) (mg)': 2.5, // #this is default assumed value
        'Vitamin B12 (mcg)': 0.9, // #this is default assumed value
        'Thiamin (mg)': 0.64, // #this is default assumed value
        'Riboflavin (mg)': 0.6, // #this is default assumed value
        'Niacin (mg)': 17.2, // #this is default assumed value
        'Vitamin B5 (mg)': 3.6, // #this is default assumed value
        'Vitamin B6 (mg)': 1.4, // #this is default assumed value
        'Folate (Food) (mcg)': 219.7, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 0, // #this is default assumed value
        'Choline (mg)': 199.5, // #this is default assumed value
        'Tyrosine (Food) (mg)': 2180, // #this is default assumed value
      },
    ),
  );

  static const Ingredient egg = Ingredient(
    id: 'egg',
    name: 'Egg',
    baseUnit: 'large egg',
    nutritionPerBaseUnit: NutritionFact(
      calories: 78, 
      protein: 6.3, 
      carbs: 0.6, 
      fat: 5.3,
      microNutrients: {
        'Cholesterol (mg)': 186,
        'Sodium (mg)': 71,
        'Potassium (mg)': 69,
        'Magnesium (mg)': 6,
        'Calcium (Food) (mg)': 28,
        'Iron (Food) (mg)': 0.9,
        'Vitamin A (Food) (mcg)': 80,
        'Zinc (Food) (mg)': 0.6, // #this is default assumed value
        'Total Omega-3 (Food) (mg)': 30, // #this is default assumed value
        'Selenium (Food) (mcg)': 15.4, // #this is default assumed value
        'Tyrosine (Food) (mg)': 250, // #this is default assumed value
      
        'Copper (mg)': 0.04, // #this is default assumed value
        'Vitamin C (mg)': 0, // #this is default assumed value
        'Vitamin D3 (Food) (mcg)': 1, // #this is default assumed value
        'Vitamin K (mcg)': 0.1, // #this is default assumed value
        'Vitamin E (Food) (mg)': 0.5, // #this is default assumed value
        'Vitamin B12 (mcg)': 0.4, // #this is default assumed value
        'Thiamin (mg)': 0.02, // #this is default assumed value
        'Riboflavin (mg)': 0.2, // #this is default assumed value
        'Niacin (mg)': 0.03, // #this is default assumed value
        'Vitamin B5 (mg)': 0.7, // #this is default assumed value
        'Vitamin B6 (mg)': 0.08, // #this is default assumed value
        'Folate (Food) (mcg)': 24, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 0, // #this is default assumed value
        'Choline (mg)': 147, // #this is default assumed value
        'EPA (Food) (mg)': 0, // #this is default assumed value
        'DHA (Food) (mg)': 30, // #this is default assumed value
      },
    ), // #default value
  );

  static const Ingredient avocadoOil = Ingredient(
    id: 'avocado_oil',
    name: 'Avocado Oil',
    baseUnit: 'tsp',
    nutritionPerBaseUnit: NutritionFact(
      calories: 40,
      protein: 0,
      carbs: 0,
      fat: 4.67,
      microNutrients: {
        'Saturated Fat (g)': 0.5,
        'Polyunsaturated Fat (g)': 0.67,
        'Monounsaturated Fat (g)': 3.33,
      
        'Potassium (mg)': 0, // #this is default assumed value
        'Magnesium (mg)': 0, // #this is default assumed value
        'Calcium (Food) (mg)': 0, // #this is default assumed value
        'Iron (Food) (mg)': 0, // #this is default assumed value
        'Zinc (Food) (mg)': 0, // #this is default assumed value
        'Copper (mg)': 0, // #this is default assumed value
        'Selenium (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin A (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin C (mg)': 0, // #this is default assumed value
        'Vitamin D3 (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin K (mcg)': 0, // #this is default assumed value
        'Vitamin E (Food) (mg)': 1.9, // #this is default assumed value
        'Vitamin B12 (mcg)': 0, // #this is default assumed value
        'Thiamin (mg)': 0, // #this is default assumed value
        'Riboflavin (mg)': 0, // #this is default assumed value
        'Niacin (mg)': 0, // #this is default assumed value
        'Vitamin B5 (mg)': 0, // #this is default assumed value
        'Vitamin B6 (mg)': 0, // #this is default assumed value
        'Folate (Food) (mcg)': 0, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 0, // #this is default assumed value
        'Choline (mg)': 0, // #this is default assumed value
        'Tyrosine (Food) (mg)': 0, // #this is default assumed value
        'EPA (Food) (mg)': 0, // #this is default assumed value
        'DHA (Food) (mg)': 0, // #this is default assumed value
      },
    ),
  );



  static const Ingredient banana = Ingredient(
    id: 'banana',
    name: 'Banana',
    baseUnit: 'medium',
    nutritionPerBaseUnit: NutritionFact(
      calories: 105, 
      protein: 1.3, 
      carbs: 27, 
      fat: 0.3,
      microNutrients: {
        'Potassium (mg)': 422,
        'Magnesium (mg)': 32,
      
        'Calcium (Food) (mg)': 6, // #this is default assumed value
        'Iron (Food) (mg)': 0.3, // #this is default assumed value
        'Zinc (Food) (mg)': 0.2, // #this is default assumed value
        'Copper (mg)': 0.1, // #this is default assumed value
        'Selenium (Food) (mcg)': 1.2, // #this is default assumed value
        'Vitamin A (Food) (mcg)': 3, // #this is default assumed value
        'Vitamin C (mg)': 10, // #this is default assumed value
        'Vitamin D3 (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin K (mcg)': 0.6, // #this is default assumed value
        'Vitamin E (Food) (mg)': 0.1, // #this is default assumed value
        'Vitamin B12 (mcg)': 0, // #this is default assumed value
        'Thiamin (mg)': 0.04, // #this is default assumed value
        'Riboflavin (mg)': 0.09, // #this is default assumed value
        'Niacin (mg)': 0.8, // #this is default assumed value
        'Vitamin B5 (mg)': 0.4, // #this is default assumed value
        'Vitamin B6 (mg)': 0.43, // #this is default assumed value
        'Folate (Food) (mcg)': 24, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 0, // #this is default assumed value
        'Choline (mg)': 12, // #this is default assumed value
        'Tyrosine (Food) (mg)': 10, // #this is default assumed value
        'EPA (Food) (mg)': 0, // #this is default assumed value
        'DHA (Food) (mg)': 0, // #this is default assumed value
      },
    ), // #default value
  );

  static const Ingredient psylliumHusk = Ingredient(
    id: 'husk',
    name: 'Psyllium Husk',
    baseUnit: 'tsp',
    nutritionPerBaseUnit: NutritionFact(
      calories: 10,
      protein: 0,
      carbs: 4,
      fat: 0,
      microNutrients: {
        'Fiber (g)': 4,
        'Soluble Fiber (g)': 4,
        'Sodium (mg)': 0,
        'Iron (Supplement) (mg)': 1.8,
        'Potassium (mg)': 46,
        'Calcium (Supplement) (mg)': 11,
      },
    ),
  );

  static const Ingredient salmon = Ingredient(
    id: 'salmon',
    name: 'Wild Sockeye Salmon',
    baseUnit: 'lb',
    nutritionPerBaseUnit: NutritionFact(
      calories: 640, 
      protein: 92, 
      carbs: 0, 
      fat: 28,
      microNutrients: {
        'Saturated Fat (g)': 10,
        'Cholesterol (mg)': 240,
        'Sodium (mg)': 320,
        'Potassium (mg)': 1504,
        'Magnesium (mg)': 130,
        'Vitamin D3 (Food) (mcg)': 64,
        'Vitamin A (Food) (mcg)': 200,
        'Vitamin B12 (mcg)': 20,
        'Iron (Food) (mg)': 2.88,
        'EPA (Food) (mg)': 2100, // #this is default assumed value
        'DHA (Food) (mg)': 3937, // #this is default assumed value
        'Total Omega-3 (Food) (mg)': 6037, // #this is default assumed value
        'Zinc (Food) (mg)': 2.0, // #this is default assumed value
        'Selenium (Food) (mcg)': 180, // #this is default assumed value
        'Tyrosine (Food) (mg)': 5284, // #this is default assumed value
      
        'Copper (mg)': 0.3, // #this is default assumed value
        'Vitamin C (mg)': 0, // #this is default assumed value
        'Vitamin K (mcg)': 0.5, // #this is default assumed value
        'Vitamin E (Food) (mg)': 6, // #this is default assumed value
        'Thiamin (mg)': 0.9, // #this is default assumed value
        'Riboflavin (mg)': 1.7, // #this is default assumed value
        'Niacin (mg)': 38, // #this is default assumed value
        'Vitamin B5 (mg)': 7.5, // #this is default assumed value
        'Vitamin B6 (mg)': 3.1, // #this is default assumed value
        'Folate (Food) (mcg)': 113, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 0, // #this is default assumed value
        'Choline (mg)': 400, // #this is default assumed value
      },
    ),
  );

  static const Ingredient wheyIsolate = Ingredient(
    id: 'whey',
    name: 'Whey Isolate',
    baseUnit: 'scoop',
    nutritionPerBaseUnit: NutritionFact(
      calories: 130,
      protein: 30,
      carbs: 1,
      fat: 0.5,
      microNutrients: {
        'Saturated Fat (g)': 0,
        'Cholesterol (mg)': 15,
        'Sodium (mg)': 85,
        'Fiber (g)': 0,
        'Sugar (g)': 1,
        'Calcium (Food) (mg)': 110,
        'Iron (Food) (mg)': 0.2,
        'Potassium (mg)': 120,
        'Tyrosine (Food) (mg)': 900, // #this is default assumed value
      
        'Magnesium (mg)': 25, // #this is default assumed value
        'Zinc (Food) (mg)': 0.2, // #this is default assumed value
        'Copper (mg)': 0.1, // #this is default assumed value
        'Selenium (Food) (mcg)': 5, // #this is default assumed value
        'Vitamin A (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin C (mg)': 0, // #this is default assumed value
        'Vitamin D3 (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin K (mcg)': 0, // #this is default assumed value
        'Vitamin E (Food) (mg)': 0, // #this is default assumed value
        'Vitamin B12 (mcg)': 0.3, // #this is default assumed value
        'Thiamin (mg)': 0, // #this is default assumed value
        'Riboflavin (mg)': 0.2, // #this is default assumed value
        'Niacin (mg)': 0, // #this is default assumed value
        'Vitamin B5 (mg)': 0, // #this is default assumed value
        'Vitamin B6 (mg)': 0, // #this is default assumed value
        'Folate (Food) (mcg)': 0, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 0, // #this is default assumed value
        'Choline (mg)': 60, // #this is default assumed value
        'EPA (Food) (mg)': 0, // #this is default assumed value
        'DHA (Food) (mg)': 0, // #this is default assumed value
      },
    ),
  );

  static const Ingredient creatine = Ingredient(
    id: 'creatine',
    name: 'Creatine Monohydrate',
    baseUnit: 'scoop',
    nutritionPerBaseUnit: NutritionFact(
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      microNutrients: {
        'Creatine Monohydrate (mg)': 5000,
      },
    ),
  );

  static const Ingredient casein = Ingredient(
    id: 'casein',
    name: 'Casein',
    baseUnit: 'scoop',
    nutritionPerBaseUnit: NutritionFact(
      calories: 120,
      protein: 25,
      carbs: 3,
      fat: 0.5,
      microNutrients: {
        'Saturated Fat (g)': 0,
        'Sodium (mg)': 190,
        'Cholesterol (mg)': 20,
        'Fiber (g)': 1,
        'Sugar (g)': 1,
        'Calcium (Food) (mg)': 580,
        'Iron (Food) (mg)': 1.3,
        'Potassium (mg)': 200,
        'Tyrosine (Food) (mg)': 1300, // #this is default assumed value
      
        'Zinc (Food) (mg)': 1, // #this is default assumed value
        'Copper (mg)': 0.1, // #this is default assumed value
        'Selenium (Food) (mcg)': 8, // #this is default assumed value
        'Vitamin A (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin C (mg)': 0, // #this is default assumed value
        'Vitamin D3 (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin K (mcg)': 0, // #this is default assumed value
        'Vitamin E (Food) (mg)': 0, // #this is default assumed value
        'Vitamin B12 (mcg)': 0.5, // #this is default assumed value
        'Thiamin (mg)': 0, // #this is default assumed value
        'Riboflavin (mg)': 0.3, // #this is default assumed value
        'Niacin (mg)': 0.1, // #this is default assumed value
        'Vitamin B5 (mg)': 0, // #this is default assumed value
        'Vitamin B6 (mg)': 0, // #this is default assumed value
        'Folate (Food) (mcg)': 0, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 0, // #this is default assumed value
        'Choline (mg)': 80, // #this is default assumed value
        'EPA (Food) (mg)': 0, // #this is default assumed value
        'DHA (Food) (mg)': 0, // #this is default assumed value
      },
    ),
  );

  static const Ingredient chiaSeeds = Ingredient(
    id: 'chia',
    name: 'Chia Seeds',
    baseUnit: 'tbsp', // Converted from 2.5 tbsp serving
    nutritionPerBaseUnit: NutritionFact(
      calories: 60,
      protein: 2,
      carbs: 5.2,
      fat: 3.6,
      microNutrients: {
        'Saturated Fat (g)': 0.4,
        'Polyunsaturated Fat (g)': 2.8,
        'Monounsaturated Fat (g)': 0.2,
        'Fiber (g)': 4,
        'Sugar (g)': 0,
        'Calcium (Food) (mg)': 78,
        'Iron (Food) (mg)': 1.08,
        'Potassium (mg)': 37.6,
        'Total Omega-3 (Food) (mg)': 1800, // #this is default assumed value
      
        'Zinc (Food) (mg)': 0.5, // #this is default assumed value
        'Copper (mg)': 0.1, // #this is default assumed value
        'Selenium (Food) (mcg)': 5.5, // #this is default assumed value
        'Vitamin A (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin C (mg)': 0.2, // #this is default assumed value
        'Vitamin D3 (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin K (mcg)': 0, // #this is default assumed value
        'Vitamin E (Food) (mg)': 0.1, // #this is default assumed value
        'Vitamin B12 (mcg)': 0, // #this is default assumed value
        'Thiamin (mg)': 0.06, // #this is default assumed value
        'Riboflavin (mg)': 0.02, // #this is default assumed value
        'Niacin (mg)': 0.9, // #this is default assumed value
        'Vitamin B5 (mg)': 0, // #this is default assumed value
        'Vitamin B6 (mg)': 0, // #this is default assumed value
        'Folate (Food) (mcg)': 5, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 0, // #this is default assumed value
        'Choline (mg)': 8, // #this is default assumed value
        'Tyrosine (Food) (mg)': 40, // #this is default assumed value
        'EPA (Food) (mg)': 0, // #this is default assumed value
        'DHA (Food) (mg)': 0, // #this is default assumed value
      },
    ),
  );

  static const Ingredient quinoa = Ingredient(
    id: 'quinoa',
    name: 'Quinoa',
    baseUnit: 'cup (dry)', // Converted from 1/4 cup (dry) serving
    nutritionPerBaseUnit: NutritionFact(
      calories: 600,
      protein: 24,
      carbs: 108,
      fat: 10,
      microNutrients: {
        'Saturated Fat (g)': 0,
        'Sodium (mg)': 0,
        'Fiber (g)': 12,
        'Sugar (g)': 4,
        'Calcium (Food) (mg)': 80,
        'Iron (Food) (mg)': 7.6,
        'Potassium (mg)': 960,
      
        'Zinc (Food) (mg)': 1.3, // #this is default assumed value
        'Copper (mg)': 0.25, // #this is default assumed value
        'Selenium (Food) (mcg)': 3.6, // #this is default assumed value
        'Vitamin A (Food) (mcg)': 1, // #this is default assumed value
        'Vitamin C (mg)': 0, // #this is default assumed value
        'Vitamin D3 (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin K (mcg)': 0, // #this is default assumed value
        'Vitamin E (Food) (mg)': 1, // #this is default assumed value
        'Vitamin B12 (mcg)': 0, // #this is default assumed value
        'Thiamin (mg)': 0.15, // #this is default assumed value
        'Riboflavin (mg)': 0.13, // #this is default assumed value
        'Niacin (mg)': 0.6, // #this is default assumed value
        'Vitamin B5 (mg)': 0.3, // #this is default assumed value
        'Vitamin B6 (mg)': 0.2, // #this is default assumed value
        'Folate (Food) (mcg)': 78, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 0, // #this is default assumed value
        'Choline (mg)': 30, // #this is default assumed value
        'Tyrosine (Food) (mg)': 150, // #this is default assumed value
        'EPA (Food) (mg)': 0, // #this is default assumed value
        'DHA (Food) (mg)': 0, // #this is default assumed value
      },
    ),
  );




  


  static const Ingredient carbeDiemPasta = Ingredient(
    id: 'carbe_diem_pasta',
    name: 'Carbe Diem Pasta',
    baseUnit: 'oz',
    nutritionPerBaseUnit: NutritionFact(
      calories: 55.0,
      protein: 4.0,
      carbs: 20.0,
      fat: 0.25,
      microNutrients: {
        'Saturated Fat (g)': 0.0,
        'Sodium (mg)': 37.5,
        'Fiber (g)': 12.0,
        'Sugar (g)': 0.0,
        'Added Sugar (g)': 0.0,
        'Calcium (Food) (mg)': 0.0,
        'Iron (Food) (mg)': 0.35,
        'Potassium (mg)': 0.0,
      },
    ),
  );

  static const Ingredient groundTurkey = Ingredient(
    id: 'ground_turkey',
    name: 'Ground Turkey (93% Lean)',
    baseUnit: 'lb',
    nutritionPerBaseUnit: NutritionFact( // #default value
      calories: 600,
      protein: 88,
      carbs: 0,
      fat: 32,
      microNutrients: {
        'Iron (Food) (mg)': 4.4,
        'Sodium (mg)': 300,
        'Potassium (mg)': 920,
        'Zinc (Food) (mg)': 10.0, // #this is default assumed value
        'Magnesium (mg)': 110, // #this is default assumed value
        'Vitamin B12 (mcg)': 6.0, // #this is default assumed value
        'Tyrosine (Food) (mg)': 5171, // #this is default assumed value
      
        'Calcium (Food) (mg)': 65, // #this is default assumed value
        'Copper (mg)': 0.3, // #this is default assumed value
        'Selenium (Food) (mcg)': 110, // #this is default assumed value
        'Vitamin A (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin C (mg)': 0, // #this is default assumed value
        'Vitamin D3 (Food) (mcg)': 1, // #this is default assumed value
        'Vitamin K (mcg)': 0, // #this is default assumed value
        'Vitamin E (Food) (mg)': 1.5, // #this is default assumed value
        'Thiamin (mg)': 0.2, // #this is default assumed value
        'Riboflavin (mg)': 0.8, // #this is default assumed value
        'Niacin (mg)': 28, // #this is default assumed value
        'Vitamin B5 (mg)': 4, // #this is default assumed value
        'Vitamin B6 (mg)': 2, // #this is default assumed value
        'Folate (Food) (mcg)': 30, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 0, // #this is default assumed value
        'Choline (mg)': 350, // #this is default assumed value
        'EPA (Food) (mg)': 10, // #this is default assumed value
        'DHA (Food) (mg)': 10, // #this is default assumed value
      },
    ),
  );

  static const Ingredient leanGroundBeef96 = Ingredient(
    id: 'ground_beef_96',
    name: 'Ground Beef (96% Lean)',
    baseUnit: 'lb',
    nutritionPerBaseUnit: NutritionFact(
      calories: 520, 
      protein: 84, 
      carbs: 0, 
      fat: 16,
      microNutrients: {
        'Saturated Fat (g)': 8,
        'Cholesterol (mg)': 240,
        'Sodium (mg)': 260,
        'Iron (Food) (mg)': 10.8,
        'Zinc (Food) (mg)': 25.0, // #this is default assumed value
        'Magnesium (mg)': 100, // #this is default assumed value
        'Vitamin B12 (mcg)': 11.0, // #this is default assumed value
        'Potassium (mg)': 1500, // #this is default assumed value
        'Selenium (Food) (mcg)': 112, // #this is default assumed value
        'Tyrosine (Food) (mg)': 4717, // #this is default assumed value
      
        'Calcium (Food) (mg)': 30, // #this is default assumed value
        'Copper (mg)': 0.3, // #this is default assumed value
        'Vitamin A (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin C (mg)': 0, // #this is default assumed value
        'Vitamin D3 (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin K (mcg)': 4, // #this is default assumed value
        'Vitamin E (Food) (mg)': 1.5, // #this is default assumed value
        'Thiamin (mg)': 0.2, // #this is default assumed value
        'Riboflavin (mg)': 0.9, // #this is default assumed value
        'Niacin (mg)': 25, // #this is default assumed value
        'Vitamin B5 (mg)': 2.5, // #this is default assumed value
        'Vitamin B6 (mg)': 1.8, // #this is default assumed value
        'Folate (Food) (mcg)': 35, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 0, // #this is default assumed value
        'Choline (mg)': 370, // #this is default assumed value
        'EPA (Food) (mg)': 15, // #this is default assumed value
        'DHA (Food) (mg)': 10, // #this is default assumed value
      },
    ),
  );

  static const Ingredient liteSalt = Ingredient(
    id: 'lite_salt',
    name: 'Morton Lite Salt',
    baseUnit: 'tsp',
    nutritionPerBaseUnit: NutritionFact(
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      microNutrients: {
        'Sodium (mg)': 1160,
        'Potassium (mg)': 1400,
        'Iodine (mcg)': 240,
      },
    ),
  );


static const Ingredient marinaraSauce = Ingredient(
  id: 'marinara',
  name: 'Marinara Sauce',
  baseUnit: 'oz', // Scaled exactly from a 125g (4.4092 oz) label serving
  nutritionPerBaseUnit: NutritionFact(
    calories: 20.4117,
    protein: 0.4536,
    carbs: 2.2680,
    fat: 1.1340,
    microNutrients: {
      'Saturated Fat (g)': 0.2268,
      'Sodium (mg)': 124.7379,
      'Fiber (g)': 0.4536,
      'Sugar (g)': 1.3608,
      'Added Sugar (g)': 0.2268,
      'Calcium (Food) (mg)': 9.0718,
      'Iron (Food) (mg)': 0.1361,
      'Potassium (mg)': 95.2544,
    
      'Magnesium (mg)': 3.17, // #this is default assumed value
      'Zinc (Food) (mg)': 0.05, // #this is default assumed value
      'Copper (mg)': 0.03, // #this is default assumed value
      'Selenium (Food) (mcg)': 0.1, // #this is default assumed value
      'Vitamin A (Food) (mcg)': 11.0, // #this is default assumed value
      'Vitamin C (mg)': 1.6, // #this is default assumed value
      'Vitamin D3 (Food) (mcg)': 0.0, // #this is default assumed value
      'Vitamin K (mcg)': 1.2, // #this is default assumed value
      'Vitamin E (Food) (mg)': 0.35, // #this is default assumed value
      'Vitamin B12 (mcg)': 0.0, // #this is default assumed value
      'Thiamin (mg)': 0.01, // #this is default assumed value
      'Riboflavin (mg)': 0.02, // #this is default assumed value
      'Niacin (mg)': 0.27, // #this is default assumed value
      'Vitamin B5 (mg)': 0.09, // #this is default assumed value
      'Vitamin B6 (mg)': 0.03, // #this is default assumed value
      'Folate (Food) (mcg)': 2.2, // #this is default assumed value
      'Folic Acid (Supplement) (mcg)': 0.0, // #this is default assumed value
      'Choline (mg)': 2.72, // #this is default assumed value
      'Tyrosine (Food) (mg)': 10.8, // #this is default assumed value
      'EPA (Food) (mg)': 0.0, // #this is default assumed value
      'DHA (Food) (mg)': 0.0, // #this is default assumed value
    },
  ),
);

  static const Ingredient cannedLentils = Ingredient(
    id: 'lentils',
    name: 'Canned Lentils',
    baseUnit: 'container', // Converted from 3.5 servings (130g / 2/3 cup each)
    nutritionPerBaseUnit: NutritionFact(
      calories: 280.0,
      protein: 21.0,
      carbs: 56.0,
      fat: 1.75,
      microNutrients: {
        'Saturated Fat (g)': 0.0,
        'Sodium (mg)': 1015.0,
        'Fiber (g)': 10.5,
        'Sugar (g)': 0.0,
        'Added Sugar (g)': 0.0,
        'Calcium (Food) (mg)': 70.0,
        'Iron (Food) (mg)': 5.95,
        'Potassium (mg)': 700.0,
        
        'Magnesium (mg)': 350.0, // #this is default assumed value
        'Zinc (Food) (mg)': 13.3, // #this is default assumed value
        'Copper (mg)': 0.88, // #this is default assumed value
        'Selenium (Food) (mcg)': 10.5, // #this is default assumed value
        'Vitamin A (Food) (mcg)': 0.0, // #this is default assumed value
        'Vitamin C (mg)': 3.5, // #this is default assumed value
        'Vitamin D3 (Food) (mcg)': 0.0, // #this is default assumed value
        'Vitamin K (mcg)': 5.95, // #this is default assumed value
        'Vitamin E (Food) (mg)': 0.35, // #this is default assumed value
        'Vitamin B12 (mcg)': 0.0, // #this is default assumed value
        'Thiamin (mg)': 0.56, // #this is default assumed value
        'Riboflavin (mg)': 0.25, // #this is default assumed value
        'Niacin (mg)': 3.5, // #this is default assumed value
        'Vitamin B5 (mg)': 2.1, // #this is default assumed value
        'Vitamin B6 (mg)': 0.6, // #this is default assumed value
        'Folate (Food) (mcg)': 630.0, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 0.0, // #this is default assumed value
        'Choline (mg)': 105.0, // #this is default assumed value
        'Tyrosine (Food) (mg)': 700.0, // #this is default assumed value
        'EPA (Food) (mg)': 0.0, // #this is default assumed value
        'DHA (Food) (mg)': 0.0, // #this is default assumed value
      },
    ),
  );

  static const Ingredient nutritionalYeast = Ingredient(
    id: 'nutritional_yeast',
    name: 'Nutritional Yeast',
    baseUnit: 'tbsp',
    nutritionPerBaseUnit: NutritionFact(
      calories: 20,
      protein: 3,
      carbs: 2,
      fat: 0,
      microNutrients: {
        'Sodium (mg)': 10,
        'Fiber (g)': 1,
        'Sugar (g)': 0,
        'Iron (Food) (mg)': 0.3,
        'Potassium (mg)': 100,
        'Thiamin (mg)': 3.82,
        'Riboflavin (mg)': 3.35,
        'Niacin (mg)': 16.6,
        'Vitamin B6 (mg)': 2.21,
        'Folate (Food) (mcg)': 0, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 605, // #this is default assumed value
        'Vitamin B12 (mcg)': 4.48,
        'Zinc (Food) (mg)': 0.6,
      
        'Magnesium (mg)': 15, // #this is default assumed value
        'Calcium (Food) (mg)': 5, // #this is default assumed value
        'Copper (mg)': 0.1, // #this is default assumed value
        'Selenium (Food) (mcg)': 2, // #this is default assumed value
        'Vitamin A (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin C (mg)': 0, // #this is default assumed value
        'Vitamin D3 (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin K (mcg)': 0, // #this is default assumed value
        'Vitamin E (Food) (mg)': 0, // #this is default assumed value
        'Vitamin B5 (mg)': 1.5, // #this is default assumed value
        'Choline (mg)': 10, // #this is default assumed value
        'Tyrosine (Food) (mg)': 100, // #this is default assumed value
        'EPA (Food) (mg)': 0, // #this is default assumed value
        'DHA (Food) (mg)': 0, // #this is default assumed value
      },
    ),
  );

  static const Ingredient bellPeppers = Ingredient(
    id: 'bell_pepper',
    name: 'Bell Pepper',
    baseUnit: 'medium',
    nutritionPerBaseUnit: NutritionFact(
      calories: 24, 
      protein: 1, 
      carbs: 6, 
      fat: 0.2,
      microNutrients: {
        'Vitamin C (mg)': 152,
        'Fiber (g)': 2.5,
        'Potassium (mg)': 211,
        'Vitamin A (Food) (mcg)': 1100,
      
        'Magnesium (mg)': 12, // #this is default assumed value
        'Calcium (Food) (mg)': 8, // #this is default assumed value
        'Iron (Food) (mg)': 0.5, // #this is default assumed value
        'Zinc (Food) (mg)': 0.3, // #this is default assumed value
        'Copper (mg)': 0.1, // #this is default assumed value
        'Selenium (Food) (mcg)': 0.1, // #this is default assumed value
        'Vitamin D3 (Food) (mcg)': 0, // #this is default assumed value
        'Vitamin K (mcg)': 5.8, // #this is default assumed value
        'Vitamin E (Food) (mg)': 1.8, // #this is default assumed value
        'Vitamin B12 (mcg)': 0, // #this is default assumed value
        'Thiamin (mg)': 0.06, // #this is default assumed value
        'Riboflavin (mg)': 0.1, // #this is default assumed value
        'Niacin (mg)': 1.1, // #this is default assumed value
        'Vitamin B5 (mg)': 0.3, // #this is default assumed value
        'Vitamin B6 (mg)': 0.3, // #this is default assumed value
        'Folate (Food) (mcg)': 54, // #this is default assumed value
        'Folic Acid (Supplement) (mcg)': 0, // #this is default assumed value
        'Choline (mg)': 6, // #this is default assumed value
        'Tyrosine (Food) (mg)': 15, // #this is default assumed value
        'EPA (Food) (mg)': 0, // #this is default assumed value
        'DHA (Food) (mg)': 0, // #this is default assumed value
      },
    ),
  );

  // SUPPLEMENTS
  static const Ingredient nac = Ingredient(
    id: 'nac',
    name: 'NAC + Selenium',
    baseUnit: 'capsule',
    nutritionPerBaseUnit: NutritionFact(
      microNutrients: {
        'NAC (mg)': 600,
        'Selenium (Supplement) (mcg)': 25,
      },
    ),
  );

  static const Ingredient finasteride = Ingredient(
    id: 'finasteride',
    name: 'Finasteride (1mg)',
    baseUnit: 'tablet',
    nutritionPerBaseUnit: NutritionFact(
      microNutrients: {
        'Finasteride (mg)': 1,
      },
    ),
  );



  static const Ingredient citicoline = Ingredient(
    id: 'citicoline',
    name: 'Citicoline',
    baseUnit: 'capsule', // Converted from 2-capsule serving
    nutritionPerBaseUnit: NutritionFact(
      microNutrients: {
        'Citicoline (mg)': 250,
        'Tyrosine (Supplement) (mg)': 25,
      },
    ),
  );
  
  static const Ingredient copperGlycinate = Ingredient(
    id: 'copper_glycinate',
    name: 'Copper Glycinate (3mg)',
    baseUnit: 'capsule',
    nutritionPerBaseUnit: NutritionFact(microNutrients: {'Copper (mg)': 3}),
  );
  
  static const Ingredient biotinKeratin = Ingredient(
    id: 'biotin_keratin',
    name: 'Biotin+Keratin',
    baseUnit: 'capsule',
    nutritionPerBaseUnit: NutritionFact(
      microNutrients: {
        'Biotin (mg)': 10,
        'Keratin (mg)': 500,
      },
    ),
  );

  static const Ingredient omega3 = Ingredient(
    id: 'omega3',
    name: 'Omega-3',
    baseUnit: 'softgel', // Converted from 3-softgel serving
    nutritionPerBaseUnit: NutritionFact(
      calories: 10,
      protein: 0,
      carbs: 0,
      fat: 1.17,
      microNutrients: {
        'EPA (Supplement) (mg)': 433.3,
        'DHA (Supplement) (mg)': 286.7,
        'Total Omega-3 (Supplement) (mg)': 720,
      },
    ),
  );
  
  static const Ingredient zincPicolinate = Ingredient(
    id: 'zinc_picolinate',
    name: 'Zinc Picolinate (30mg)',
    baseUnit: 'capsule',
    nutritionPerBaseUnit: NutritionFact(
      microNutrients: {
        'Zinc (Supplement) (mg)': 30,
      },
    ),
  );

  static const Ingredient d3K2 = Ingredient(
    id: 'd3k2',
    name: 'D3-K2',
    baseUnit: 'capsule',
    nutritionPerBaseUnit: NutritionFact(
      microNutrients: {
        'Vitamin D3 (Supplement) (mcg)': 125,
        'Vitamin K2 (mcg)': 100,
      },
    ),
  );

  static const Ingredient ashwagandha = Ingredient(
    id: 'ashwagandha',
    name: 'Ashwagandha',
    baseUnit: 'capsule', // Converted from 2-capsule serving
    nutritionPerBaseUnit: NutritionFact(
      microNutrients: {
        'Ashwagandha Extract (mg)': 250,
        'Black Pepper Extract (mg)': 2.5,
      },
    ),
  );
  
  static const Ingredient rMagnesium = Ingredient(
    id: 'magnesium',
    name: 'Magnesium Glycinate',
    baseUnit: 'capsule',
    nutritionPerBaseUnit: NutritionFact(
      microNutrients: {
        'Magnesium (mg)': 90,
      },
    ),
  );

  static const Ingredient standaloneK2 = Ingredient(
    id: 'standaloneK2',
    name: 'Vitamin K2 (MK-7)',
    baseUnit: 'capsule',
    nutritionPerBaseUnit: NutritionFact(
      microNutrients: {
        'Vitamin K2 (mcg)': 100,
      },
    ),
  );

  static const Ingredient vitaminE = Ingredient(
    id: 'vitaminE',
    name: 'Vitamin E',
    baseUnit: 'capsule',
    nutritionPerBaseUnit: NutritionFact(
      microNutrients: {
        'Vitamin E (Supplement) (mg)': 267,
      },
    ),
  );

  static const Ingredient calciumCitrate = Ingredient(
    id: 'calciumCitrate',
    name: 'Calcium Citrate',
    baseUnit: 'capsule',
    nutritionPerBaseUnit: NutritionFact(
      microNutrients: {
        'Calcium (Supplement) (mg)': 146.66,
      },
    ),
  );

  static const List<Ingredient> allIngredients = [
    spinach,
    chipotleBowl,
    egg,
    avocadoOil,
    banana,
    psylliumHusk,
    salmon,
    wheyIsolate,
    creatine,
    casein,
    chiaSeeds,
    quinoa,
    carbeDiemPasta,
    groundTurkey,
    leanGroundBeef96,
    liteSalt,
    marinaraSauce,
    cannedLentils,
    nutritionalYeast,
    bellPeppers,
    nac,
    finasteride,
    citicoline,
    copperGlycinate,
    biotinKeratin,
    omega3,
    zincPicolinate,
    d3K2,
    ashwagandha,
    rMagnesium,
    standaloneK2,
    vitaminE,
    calciumCitrate,
  ];
}
