import '../domain/nutrition.dart';

class IngredientsData {
  // Macros/Micros are mock values based on typical averages, you can replace these with real facts.

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
        'Calcium (mg)': 320,
        'Iron (mg)': 9.2,
        'Magnesium (mg)': 268, // USDA average (not usually on basic nutrition labels)
        'Vitamin A (mcg)': 1580, // USDA average (not usually on basic nutrition labels)
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
        'Calcium (mg)': 28,
        'Iron (mg)': 0.9,
        'Vitamin A (mcg)': 80,
      },
    ), // #default value
  );

  static const Ingredient avocadoOil = Ingredient(
    id: 'avocado_oil',
    name: 'Avocado Oil',
    baseUnit: 'tsp', // Converted from 1 Tbsp (3 tsp) serving
    nutritionPerBaseUnit: NutritionFact(
      calories: 40,
      protein: 0,
      carbs: 0,
      fat: 4.67,
      microNutrients: {
        'Saturated Fat (g)': 0.5,
        'Polyunsaturated Fat (g)': 0.67,
        'Monounsaturated Fat (g)': 3.33,
      },
    ),
  );

  static const Ingredient peanutButter = Ingredient(
    id: 'pb',
    name: 'Peanut Butter',
    baseUnit: 'tbsp',
    nutritionPerBaseUnit: NutritionFact(
      calories: 95, 
      protein: 3.5, 
      carbs: 4.0,   
      fat: 7.5,     
      microNutrients: {
        'Saturated Fat (g)': 1.5,
        'Polyunsaturated Fat (g)': 1.5,
        'Monounsaturated Fat (g)': 4.0,
        'Fiber (g)': 1.0,
        'Sugar (g)': 1.5,
        'Sodium (mg)': 65,
        'Calcium (mg)': 13, // 1% of 1300mg DV
        'Iron (mg)': 0.18,  // 1% of 18mg DV
        'Potassium (mg)': 94, // 2% of 4700mg DV
      },
    ),
  );

  static const Ingredient almondMilk = Ingredient(
    id: 'almond_milk',
    name: 'Unsweetened Almond Milk',
    baseUnit: 'cup',
    nutritionPerBaseUnit: NutritionFact(
      calories: 30,
      protein: 1,
      carbs: 1,
      fat: 2.5,
      microNutrients: {
        'Saturated Fat (g)': 0,
        'Sodium (mg)': 130,
        'Fiber (g)': 0,
        'Sugar (g)': 0,
        'Vitamin D3 (mcg)': 5, // D2 usually, but we'll group as D3 for tracking unless user wants otherwise
        'Calcium (mg)': 450,
        'Iron (mg)': 0.5,
        'Potassium (mg)': 160,
        'Vitamin A (mcg)': 90,
        'Vitamin E (mg)': 7.5,
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
        'Iron (mg)': 1.8,
        'Potassium (mg)': 46,
        'Calcium (mg)': 11,
      },
    ),
  );

  static const Ingredient salmon = Ingredient(
    id: 'salmon',
    name: 'Wild Sockeye Salmon',
    baseUnit: 'lb',
    nutritionPerBaseUnit: NutritionFact(
      calories: 650, 
      protein: 95, 
      carbs: 0, 
      fat: 25,
      microNutrients: {
        'Sodium (mg)': 200,
        'Potassium (mg)': 1700,
        'Magnesium (mg)': 130,
        'Vitamin D3 (mcg)': 50,
        'Vitamin A (mcg)': 200,
        'Vitamin B12 (mcg)': 20,
      },
    ), // #default value
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
        'Calcium (mg)': 110,
        'Iron (mg)': 0.2,
        'Potassium (mg)': 120,
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
        'Calcium (mg)': 580,
        'Iron (mg)': 1.3,
        'Potassium (mg)': 200,
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
        'Calcium (mg)': 78,
        'Iron (mg)': 1.08,
        'Potassium (mg)': 37.6,
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
        'Calcium (mg)': 80,
        'Iron (mg)': 7.6,
        'Potassium (mg)': 960,
      },
    ),
  );

  static const Ingredient chickenBreast = Ingredient(
    id: 'chicken_breast',
    name: 'Chicken Breast',
    baseUnit: 'lb',
    nutritionPerBaseUnit: NutritionFact(
      calories: 750, 
      protein: 140, 
      carbs: 0, 
      fat: 16,
      microNutrients: {
        'Sodium (mg)': 300,
        'Potassium (mg)': 1100,
        'Magnesium (mg)': 130,
        'Iron (mg)': 4,
      },
    ), // #default value
  );

  static const Ingredient almonds = Ingredient(
    id: 'almonds',
    name: 'Almonds',
    baseUnit: 'cup', // normally user says 1/4 cup
    nutritionPerBaseUnit: NutritionFact(calories: 825, protein: 30, carbs: 30, fat: 71), // #default value
  );

  static const Ingredient raspberries = Ingredient(
    id: 'raspberries',
    name: 'Raspberries',
    baseUnit: 'container (6oz)',
    nutritionPerBaseUnit: NutritionFact(
      calories: 90, 
      protein: 2, 
      carbs: 20, 
      fat: 1.1,
      microNutrients: {
        'Fiber (g)': 11,
        'Potassium (mg)': 256,
        'Magnesium (mg)': 37,
      },
    ), // #default value
  );

  static const Ingredient mushroom = Ingredient(
    id: 'mushroom',
    name: 'Mushroom',
    baseUnit: 'container (8oz)', // 8oz standard grocery pack
    nutritionPerBaseUnit: NutritionFact(
      calories: 50, 
      protein: 7, 
      carbs: 7, 
      fat: 0.7,
      microNutrients: {
        'Potassium (mg)': 720,
        'Magnesium (mg)': 20,
      },
    ), // #default value
  );
  
  static const Ingredient ribeye = Ingredient(
    id: 'ribeye',
    name: 'Ribeye Steak',
    baseUnit: 'lb', // Converted from 4 oz serving
    nutritionPerBaseUnit: NutritionFact(
      calories: 1080,
      protein: 84,
      carbs: 0,
      fat: 84,
      microNutrients: {
        'Saturated Fat (g)': 36,
        'Cholesterol (mg)': 320,
        'Sodium (mg)': 240,
        'Iron (mg)': 7.2,
        'Potassium (mg)': 1040,
      },
    ),
  );

  static const Ingredient chickpeaPasta = Ingredient(
    id: 'chickpea_pasta',
    name: 'Chickpea Fusilli',
    baseUnit: 'oz', // Converted from 56g (2 oz) serving
    nutritionPerBaseUnit: NutritionFact(
      calories: 95,
      protein: 5.5,
      carbs: 18,
      fat: 1.25,
      microNutrients: {
        'Saturated Fat (g)': 0,
        'Sodium (mg)': 0,
        'Fiber (g)': 3,
        'Sugar (g)': 0.5,
        'Calcium (mg)': 20,
        'Iron (mg)': 1.05,
        'Potassium (mg)': 225,
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
        'Iron (mg)': 4.4,
        'Sodium (mg)': 300,
        'Potassium (mg)': 920,
      },
    ),
  );

  static const Ingredient marinaraSauce = Ingredient(
    id: 'marinara',
    name: 'Marinara Sauce',
    baseUnit: 'oz', // Converted from 1/2 cup (4 oz) serving
    nutritionPerBaseUnit: NutritionFact(
      calories: 22.5,
      protein: 0.5,
      carbs: 2.5,
      fat: 1.25,
      microNutrients: {
        'Saturated Fat (g)': 0.25,
        'Sodium (mg)': 137.5,
        'Fiber (g)': 0.5,
        'Sugar (g)': 1.5,
        'Calcium (mg)': 10,
        'Iron (mg)': 0.15,
        'Potassium (mg)': 105,
      },
    ),
  );

  static const Ingredient cannedLentils = Ingredient(
    id: 'lentils',
    name: 'Canned Lentils',
    baseUnit: 'container', // Converted from 3.5 servings (2/3 cup each)
    nutritionPerBaseUnit: NutritionFact(
      calories: 280,
      protein: 21,
      carbs: 56,
      fat: 1.75,
      microNutrients: {
        'Sodium (mg)': 1015,
        'Fiber (g)': 10.5,
        'Sugar (g)': 0,
        'Calcium (mg)': 70,
        'Iron (mg)': 5.95,
        'Potassium (mg)': 700,
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
        'Iron (mg)': 0.3,
        'Potassium (mg)': 100,
        'Thiamin (mg)': 3.82,
        'Riboflavin (mg)': 3.35,
        'Niacin (mg)': 16.6,
        'Vitamin B6 (mg)': 2.21,
        'Folate (mcg DFE)': 605,
        'Vitamin B12 (mcg)': 4.48,
        'Zinc (mg)': 0.6,
      },
    ),
  );

  static const Ingredient bellPeppers = Ingredient(
    id: 'bell_pepper',
    name: 'Bell Pepper',
    baseUnit: 'medium',
    nutritionPerBaseUnit: NutritionFact(calories: 24, protein: 1, carbs: 6, fat: 0.2), // #default value
  );

  // SUPPLEMENTS
  static const Ingredient nac = Ingredient(
    id: 'nac',
    name: 'NAC + Selenium',
    baseUnit: 'capsule',
    nutritionPerBaseUnit: NutritionFact(
      microNutrients: {
        'NAC (mg)': 600,
        'Selenium (mcg)': 25,
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
        'Tyrosine (mg)': 25,
      },
    ),
  );
  
  static const Ingredient copperGlycinate = Ingredient(
    id: 'copper_glycinate',
    name: 'Copper Glycinate (3mg)',
    baseUnit: 'capsule',
    nutritionPerBaseUnit: NutritionFact(microNutrients: {'Copper': 3}),
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
        'EPA (mg)': 433.3,
        'DHA (mg)': 286.7,
        'Total Omega-3 (mg)': 720,
      },
    ),
  );
  
  static const Ingredient zincPicolinate = Ingredient(
    id: 'zinc_picolinate',
    name: 'Zinc Picolinate (30mg)',
    baseUnit: 'capsule',
    nutritionPerBaseUnit: NutritionFact(
      microNutrients: {
        'Zinc (mg)': 30,
      },
    ),
  );

  static const Ingredient d3K2 = Ingredient(
    id: 'd3k2',
    name: 'D3-K2',
    baseUnit: 'capsule',
    nutritionPerBaseUnit: NutritionFact(
      microNutrients: {
        'Vitamin D3 (mcg)': 125,
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
}
