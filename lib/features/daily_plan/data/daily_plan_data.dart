import '../../micro_macro_calorie_track/domain/nutrition.dart';
import '../../micro_macro_calorie_track/data/ingredients_data.dart';
import '../../recipe/data/recipe_data.dart';

class TimelineItem {
  final String time;
  final String title;
  final String icon;
  final List<String> details;
  final MealRecord? mealRecord;

  const TimelineItem({
    required this.time,
    required this.title,
    required this.icon,
    this.details = const [],
    this.mealRecord,
  });
}

class DailyPlanData {
  /*
   * SUPPLEMENT DOSAGE & SAFETY LOG:
   * 
   * General Assessment: The stack is remarkably well-calibrated and safe. No individual
   * dosages exceed the tolerable upper intake limits. The combinations are smart (e.g., Zinc balanced with Copper).
   * 
   * Morning:
   * - NAC: 600mg + Selenium: 25mcg (Safe, supports glutathione)
   * - Citicoline: 250mg + Tyrosine: 25mg (Safe maintenance dose for focus)
   * 
   * Mid-Day:
   * - Zinc Picolinate: 30mg (Well within the 40mg upper limit, safely balanced by afternoon Copper)
   * - D3-K2: 1 capsule providing 5000 IU D3 + 100mcg K2 (MK-7) (Optimal, high dose for melanin-rich indoor lifestyle)
   * 
   * Afternoon (With Eggs):
   * - Copper Glycinate: 3mg (Balances the zinc at lunch without competing for absorption)
   * - Biotin/Keratin: 10mg / 500mg (Standard for hair/skin)
   * - Omega-3: 3 softgels containing 2160mg total (1300mg EPA / 860mg DHA) (Excellent therapeutic dose)
   * 
   * Evening/Night:
   * - Ashwagandha: 2 capsules = 500mg of 25:1 extract (equiv 12500mg root) + 5mg black pepper extract.
   *   [Safety Note: Research shows 500-600mg is the optimal clinical dose for maximizing testosterone, strength, and muscle hypertrophy. Because this is a high-potency dose, the 8-weeks on / 4-weeks off cycle is mandatory to prevent emotional blunting while keeping maximum gains.]
   * - Magnesium Glycinate: 2-3 capsules providing 180mg-270mg elemental magnesium (90mg elemental per capsule from 500mg mag glycinate). (Completely safe, well below the 350mg supplement upper limit).
   */

  static final DateTime planStartDate = DateTime(2026, 4, 13);

  static bool isDeloadWeek() {
    final now = DateTime.now();
    final diff = now.difference(planStartDate).inDays;
    if (diff < 0) return false;
    final weekNumber = (diff ~/ 7) + 1;
    return weekNumber % 6 == 0;
  }

  static bool isAshwagandhaOff() {
    final now = DateTime.now();
    final diff = now.difference(planStartDate).inDays;
    if (diff < 0) return false;
    final weekNumber = (diff ~/ 7) + 1;
    final posInCycle = ((weekNumber - 1) % 12) + 1;
    return posInCycle > 8;
  }

  // Phlebotomy is the clinical gold standard for managing high ferritin
  // from a continuous, high-heme iron athletic diet (beef).
  static bool isBloodDonationWeek() {
    final now = DateTime.now();
    final diff = now.difference(planStartDate).inDays;
    if (diff < 0) return false;
    final weekNumber = (diff ~/ 7) + 1;
    // 5 months is roughly 22 weeks
    return weekNumber % 22 == 0;
  }

  static const Map<String, int> waterBottles = {
    'mon': 7, 'tue': 7, 'wed': 7, 'thu': 7, 'fri': 7, 'sat': 7, 'sun': 7,
  };

  /*
   * LONG-TERM SKINCARE PLAN (Once Glow Screen runs out):
   * 1. Switch to Supergoop Mineral Mattescreen (perfect for oily/Ethiopian skin to kill shine).
   * 2. Move Joseon Alpha-Arbutin to EVERY morning (including no sunscreen days): Ascorbyl 12% -> wait 90s -> Joseon -> wait 2m -> Mattescreen (depending on day).
   * 3. On Sundays, bring back Dermaroller: Skip Joseon, use ONLY CeraVe (wait 30m after rolling to avoid flushing/hyperpigmentation).
   * 4. Mineral MatteScreen Sunset would be your only sunscreen going forward (both morning and pre-gym).
   */

  /*
   * FUTURE LAUNDRY PLAN:
   * If you ever decide to stop using small washcloths for your face and start using your large bath towels for both body AND face:
   * 1. You MUST wash them on a Quick Cycle every other day to prevent acne/bacteria from damp towels sitting around.
   * 2. This will wear the towels out in about a year, requiring you to buy a new $30-$40 set yearly (a worthwhile trade-off for clear skin and convenience).
   */
  static final Map<String, List<TimelineItem>> schedules = {
    'mon': [
      TimelineItem(time: '7:30-7:35 am', title: 'Wakeup', icon: '☀️', details: ['1. Use bathroom', '2. Weight (Step on scale)', '3. Take 250mg Citicoline (w/ 25mg Tyrosine)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.citicoline, amount: 1)])),
      TimelineItem(time: '7:35-8:15 am', title: 'Get Ready', icon: '🚿', details: ['1. Turn OFF Dehumidifier -> Brush teeth', '2. Shower: Hair (60s warm massage) -> Body (Lipikar AP+, NO WASHCLOTH) -> Face (CeraVe Foaming, LUKEWARM. DO NOT DOUBLE WASH) -> Finish: 15s full-body cold shock -> PAT DRY (Do Skincare immediately while bathroom is humid)' /* FUTURE PLAN: If itching returns from 2x showers, use Nivea In-Shower Lotion to seal barrier */, '3. Ascorbyl 12%: 3 tiny drops for face, 2 for neck -> WAIT 90s', '4. Supergoop Glow Screen: 1 squirt for face, 1 for neck', '5. Apply deodorant', '6. Get dressed (NK 9060/Bondi)']),
      TimelineItem(time: '8:15-8:30 am', title: 'Morning Reading', icon: '📖', details: ['Turn on Verilux HappyLight (45-degree angle to face)', 'reading']),
      TimelineItem(time: '8:30-8:35 am', title: 'Grab things to take to work', icon: '🗂️', details: ['kindle/laptop', '2 key/wallet/phone', 'airpods', 'gym outfit', 'micellar wipes', 'sunscreen', 'Pasta lunch', '3 Boiled Eggs', 'Supplements (D3/K2, Omega-3, Copper, Biotin)', 'Dry Mix: 2 tsp husk + 1/8 tsp Morton Lite Salt', '1 banana', 'water bottle']),
      TimelineItem(time: '8:35-9:00 am', title: 'Commute to Work', icon: '🚗'),
      TimelineItem(time: '9:00-11:30 am', title: 'Work', icon: '💻'),
      TimelineItem(time: '11:30-12:00 pm', title: 'Pre-Lunch Fiber', icon: '🥤', details: ['2 tsp husk + 1/8 tsp Morton Lite Salt in 16oz water (Drink 30m before lunch)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.psylliumHusk, amount: 2), IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 0.125)])),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🍝', details: ['1 serving of my pasta (Spinach is cooked inside)'], mealRecord: MealRecord(recipeItems: [RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'pasta'), servings: 1)])),
      TimelineItem(time: '12:30-3:30 pm', title: 'Work', icon: '💻'),
      TimelineItem(time: '3:30-3:45 pm', title: 'Afternoon Snack', icon: '🥚', details: ['3 Boiled Eggs', '3 softgel omega-3', '1 D3-K2', '1 standalone K2 (100mcg)', '1 cap Biotin+Keratin (10mg/500mg)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.egg, amount: 3), IngredientPortion(ingredient: IngredientsData.omega3, amount: 3), IngredientPortion(ingredient: IngredientsData.d3K2, amount: 1), IngredientPortion(ingredient: IngredientsData.standaloneK2, amount: 1), IngredientPortion(ingredient: IngredientsData.biotinKeratin, amount: 1)])),
      TimelineItem(time: '3:45-5:00 pm', title: 'Work', icon: '💻'),
      TimelineItem(time: '5:00-5:30 pm', title: 'Commute To Gym', icon: '🚗', details: ['micellar wipe -> WAIT to dry -> Wash hands -> Mineral Unseen SPF (1 squirt for face/ears -> 1 squirt for neck)', '1 banana (pre-workout)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.banana, amount: 1)])),
      TimelineItem(time: '5:30-7:00 pm', title: 'Gym Session (Upper A)', icon: '🏋️', details: ['Includes the 15 min travel time back home']),
      TimelineItem(time: '7:00-7:15 pm', title: 'Post-Workout', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.wheyIsolate, amount: 1), IngredientPortion(ingredient: IngredientsData.creatine, amount: 1)])),
      TimelineItem(time: '7:15-7:30 pm', title: 'Dinner', icon: '🥗', details: ['1/3 lb Wild Sockeye Salmon', '2 cups Unsweetened Almond Milk'], mealRecord: MealRecord(items: [const IngredientPortion(ingredient: IngredientsData.almondMilk, amount: 2)], recipeItems: [RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'salmon'), servings: 1)])),
      TimelineItem(time: '7:30-8:00 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop Casein + 1 tbsp Chia in 14-16oz water (drink immediately)', '2 cap Ashwagandha'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.casein, amount: 1), IngredientPortion(ingredient: IngredientsData.chiaSeeds, amount: 1), IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2)])),
      TimelineItem(time: '8:00-9:00 pm', title: 'Study Time', icon: '📚'),
      TimelineItem(time: '9:00-10:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['1. Turn OFF Dehumidifier -> Pre-Shower: Rub 2-3 pumps Cleansing Oil on DRY face (30s) to melt sunscreen', '2. In-Shower: Wet hands, rub face/neck/ears to emulsify (15-20s) -> Rinse', '3. Hair: 60s warm massage, Body: Bioderma Atoderm Wash (WITH Washcloth), Face: CeraVe Foaming (DO NOT DOUBLE WASH) -> Finish: 15s full-body cold shock', '4. PAT face & beard completely dry (Do Skincare immediately while bathroom is humid)' /* FUTURE PLAN: , '5. Minoxidil: Exactly 1mL liquid/half-cap foam rubbed deeply to skin of beard/mustache -> let dry 30-60m' */]),
      TimelineItem(time: '10:00-10:30 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['1. Take 3 Magnesium Glycinate + 1 tablet Finasteride (1mg)', '2. Retinol: 1 pea-sized pump ONLY for face -> 1/2 pea-sized pump for neck -> WAIT 1-2m', '3. CeraVe: 1 pea-size for face/ears -> 1 pea-size for neck -> WAIT to dry', '4. Read/Reflect'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.rMagnesium, amount: 3), IngredientPortion(ingredient: IngredientsData.finasteride, amount: 1)])),
      TimelineItem(time: '10:30-11:00 pm', title: 'Fall Asleep', icon: '😴', details: ['Lights out, try to fall asleep within 30 min']),
    ],
    'tue': [
      TimelineItem(time: '7:30-7:35 am', title: 'Wakeup', icon: '☀️', details: ['1. Use bathroom', '2. Weight (Step on scale)', '3. Take 600mg NAC + 25mcg Selenium (Combo Pill)', '4. Take 250mg Citicoline (w/ 25mg Tyrosine)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.nac, amount: 1), IngredientPortion(ingredient: IngredientsData.citicoline, amount: 1)])),
      TimelineItem(time: '7:35-8:15 am', title: 'Get Ready', icon: '🚿', details: ['1. Turn OFF Dehumidifier -> Brush teeth', '2. Shower: Hair (60s warm massage) -> Body (Lipikar AP+, NO WASHCLOTH) -> Face (CeraVe Foaming, LUKEWARM. DO NOT DOUBLE WASH) -> Finish: 15s full-body cold shock -> PAT DRY (Do Skincare immediately while bathroom is humid)' /* FUTURE PLAN: If itching returns from 2x showers, use Nivea In-Shower Lotion to seal barrier */, '3. Ascorbyl 12%: 3 tiny drops for face, 2 for neck -> WAIT 90s', '4. CeraVe: 1 dime-size for face/ears, 1 pea-size for neck -> WAIT 30s', '5. Apply deodorant', '6. Get dressed']),
      TimelineItem(time: '8:15-8:30 am', title: 'Morning Reading', icon: '📖', details: ['Turn on Verilux HappyLight (45-degree angle to face)', 'reading']),
      TimelineItem(time: '8:30-9:05 am', title: 'Cook', icon: '🧑‍🍳', details: ['1cup quinoa + 1lb ground beef (divide in 4, 4 fridge)']),
      TimelineItem(time: '9:05-11:30 am', title: 'Work', icon: '💻', details: ['Laundry Cycle 1: Face Towels & Pillowcases (${isDeloadWeek() ? "5/5" : "3/5"} warmness) -> 1-2 tbsp liquid detergent + OxiClean. NO Fabric Softener', 'Run Dishwasher']),
      TimelineItem(time: '11:30-12:00 pm', title: 'Pre-Lunch Fiber', icon: '🥤', details: ['2 tsp husk + 1/8 tsp Morton Lite Salt in 16oz water (Drink 30m before lunch)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.psylliumHusk, amount: 2), IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 0.125)])),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🍝', details: ['1 serving of my pasta (Spinach is cooked inside)'], mealRecord: MealRecord(recipeItems: [RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'pasta'), servings: 1)])),
      TimelineItem(time: '12:30-3:30 pm', title: 'Work', icon: '💻', details: ['Laundry Cycle 2: Bath Towels & Washcloths (5/5 warmness) -> 2 tbsp Arm&Hammer + 1/3 cup Bleach + EXTRA RINSE']),
      TimelineItem(time: '3:30-4:00 pm', title: 'Afternoon Snack', icon: '🥚', details: ['2 Boiled Eggs', '3 softgel omega-3', '1 D3-K2', '1 standalone K2 (100mcg)', '1 cap Biotin+Keratin (10mg/500mg)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.egg, amount: 2), IngredientPortion(ingredient: IngredientsData.omega3, amount: 3), IngredientPortion(ingredient: IngredientsData.d3K2, amount: 1), IngredientPortion(ingredient: IngredientsData.standaloneK2, amount: 1), IngredientPortion(ingredient: IngredientsData.biotinKeratin, amount: 1)])),
      TimelineItem(time: '4:00-4:15 pm', title: 'Pre-Cardio Snack', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.wheyIsolate, amount: 1), IngredientPortion(ingredient: IngredientsData.creatine, amount: 1)])),
      TimelineItem(time: '4:15-5:00 pm', title: 'Work/Study', icon: '💻', details: ['Depending on your workload, study or work']),
      TimelineItem(time: '5:00-6:30 pm', title: 'Cardio (LISS)', icon: '🏃', details: ['micellar wipe -> WAIT to dry -> Wash hands -> Mineral Unseen SPF (1 squirt index finger for face/ears -> Wash hands -> 1 squirt middle finger for neck) before leaving', '40 min walk (see Gym Plan → Cardio)', 'Every 2-3 weeks: swap for haircut']),
      TimelineItem(time: '6:30-7:30 pm', title: 'Dinner', icon: '🍛', details: ['1/4 cup quinoa + 1/4 pound ground beef', '1 cup Unsweetened Almond Milk'], mealRecord: MealRecord(items: [const IngredientPortion(ingredient: IngredientsData.almondMilk, amount: 1)], recipeItems: [RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'quinoa_beef'), servings: 1)])),
      TimelineItem(time: '7:30-8:15 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop Casein + 1 tbsp Chia in 14-16oz water (drink immediately)', '2 cap Ashwagandha'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.casein, amount: 1), IngredientPortion(ingredient: IngredientsData.chiaSeeds, amount: 1), IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2)])),
      TimelineItem(time: '8:15-9:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['1. Turn OFF Dehumidifier -> Pre-Shower: Rub 2-3 pumps Cleansing Oil on DRY face (30s) to melt sunscreen', '2. In-Shower: Wet hands, rub face/neck/ears to emulsify (15-20s) -> Rinse', '3. Hair: 60s warm massage, Body: Bioderma Atoderm Wash (WITH Washcloth), Face: CeraVe Foaming (DO NOT DOUBLE WASH) -> Finish: 15s full-body cold shock', '4. PAT face & beard completely dry (Do Skincare immediately while bathroom is humid)' /* FUTURE PLAN: , '5. Minoxidil: Exactly 1mL liquid/half-cap foam rubbed deeply to skin of beard/mustache -> let dry 30-60m' */]),
      TimelineItem(time: '9:00-10:30 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['1. Take 2 Magnesium Glycinate + 1 tablet Finasteride (1mg)', '2. Paula\'s Choice 2% BHA: Splash 3-4 drops in hands and pat into face (focus on bumps) -> Pat lightly on neck -> WAIT 1-2m', '3. CeraVe: 1 pea-size for face/ears -> 1 pea-size for neck -> WAIT to dry', '4. Read/Reflect'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.rMagnesium, amount: 2), IngredientPortion(ingredient: IngredientsData.finasteride, amount: 1)])),
      TimelineItem(time: '10:30-11:00 pm', title: 'Fall Asleep', icon: '😴', details: ['Lights out, try to fall asleep within 30 min']),
    ],
    'wed': [
      TimelineItem(time: '7:30-7:35 am', title: 'Wakeup', icon: '☀️', details: ['1. Use bathroom', '2. Weight (Step on scale)', '3. Take 250mg Citicoline (w/ 25mg Tyrosine)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.citicoline, amount: 1)])),
      TimelineItem(time: '7:35-8:15 am', title: 'Get Ready', icon: '🚿', details: ['1. Turn OFF Dehumidifier -> Brush teeth', '2. Shower: Hair (60s warm massage) -> Body (Lipikar AP+, NO WASHCLOTH) -> Face (CeraVe Foaming, LUKEWARM. DO NOT DOUBLE WASH) -> Finish: 15s full-body cold shock -> PAT DRY (Do Skincare immediately while bathroom is humid)' /* FUTURE PLAN: If itching returns from 2x showers, use Nivea In-Shower Lotion to seal barrier */, '3. Ascorbyl 12%: 3 tiny drops for face, 2 for neck -> WAIT 90s', '4. Supergoop Glow Screen: 1 squirt for face, 1 for neck', '5. Apply deodorant', '6. Get dressed (cloud x 4)']),
      TimelineItem(time: '8:15-8:30 am', title: 'Morning Reading', icon: '📖', details: ['Turn on Verilux HappyLight (45-degree angle to face)', 'reading']),
      TimelineItem(time: '8:30-8:35 am', title: 'Grab things to take to work', icon: '🗂️', details: ['kindle/laptop', '2 key/wallet/phone', 'airpods', 'gym outfit', 'micellar wipes', 'sunscreen', 'Pasta lunch', '3 Boiled Eggs', 'Supplements (D3/K2, Omega-3, Copper, Biotin)', 'Dry Mix: 2 tsp husk + 1/8 tsp Morton Lite Salt', '1 banana', 'water bottle']),
      TimelineItem(time: '8:35-9:00 am', title: 'Commute to Work', icon: '🚗'),
      TimelineItem(time: '9:00-11:30 am', title: 'Work', icon: '💻'),
      TimelineItem(time: '11:30-12:00 pm', title: 'Pre-Lunch Fiber', icon: '🥤', details: ['2 tsp husk + 1/8 tsp Morton Lite Salt in 16oz water (Drink 30m before lunch)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.psylliumHusk, amount: 2), IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 0.125)])),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🍝', details: ['1 serving of my pasta (Spinach is cooked inside)', '1 cap Copper Glycinate (3mg)'], mealRecord: MealRecord(items: [const IngredientPortion(ingredient: IngredientsData.copperGlycinate, amount: 1)], recipeItems: [RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'pasta'), servings: 1)])),
      TimelineItem(time: '12:30-3:30 pm', title: 'Work', icon: '💻'),
      TimelineItem(time: '3:30-3:45 pm', title: 'Afternoon Snack', icon: '🥚', details: ['3 Boiled Eggs', '3 softgel omega-3', '1 D3-K2', '1 standalone K2 (100mcg)', '1 cap Biotin+Keratin (10mg/500mg)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.egg, amount: 3), IngredientPortion(ingredient: IngredientsData.omega3, amount: 3), IngredientPortion(ingredient: IngredientsData.d3K2, amount: 1), IngredientPortion(ingredient: IngredientsData.standaloneK2, amount: 1), IngredientPortion(ingredient: IngredientsData.biotinKeratin, amount: 1)])),
      TimelineItem(time: '3:45-5:00 pm', title: 'Work', icon: '💻'),
      TimelineItem(time: '5:00-5:30 pm', title: 'Commute To Gym', icon: '🚗', details: ['micellar wipe -> WAIT to dry -> Wash hands -> Mineral Unseen SPF (1 squirt for face/ears -> 1 squirt for neck)', '1 banana (pre-workout)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.banana, amount: 1)])),
      TimelineItem(time: '5:30-7:30 pm', title: 'Gym Session (Lower A)', icon: '🏋️', details: ['Includes the 15 min travel time back home']),
      TimelineItem(time: '7:30-7:40 pm', title: 'Post-Workout', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.wheyIsolate, amount: 1), IngredientPortion(ingredient: IngredientsData.creatine, amount: 1)])),
      TimelineItem(time: '7:40-8:00 pm', title: 'Dinner', icon: '🥗', details: ['1/3 lb Wild Sockeye Salmon', '2 cups Unsweetened Almond Milk', '1 cap Zinc Picolinate (30mg)'], mealRecord: MealRecord(items: [const IngredientPortion(ingredient: IngredientsData.almondMilk, amount: 2), const IngredientPortion(ingredient: IngredientsData.zincPicolinate, amount: 1)], recipeItems: [RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'salmon'), servings: 1)])),
      TimelineItem(time: '8:00-8:30 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop Casein + 1 tbsp Chia in 14-16oz water (drink immediately)', '2 cap Ashwagandha'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.casein, amount: 1), IngredientPortion(ingredient: IngredientsData.chiaSeeds, amount: 1), IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2)])),
      TimelineItem(time: '8:30-9:30 pm', title: 'Study Time', icon: '📚'),
      TimelineItem(time: '9:30-10:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['1. Turn OFF Dehumidifier -> Pre-Shower: Rub 2-3 pumps Cleansing Oil on DRY face (30s) to melt sunscreen', '2. In-Shower: Wet hands, rub face/neck/ears to emulsify (15-20s) -> Rinse', '3. Hair: CeraVe Gentle Shampoo (45s lather), Body: Bioderma Atoderm Wash (WITH Washcloth), Face: CeraVe Foaming (DO NOT DOUBLE WASH) -> Finish: 15s full-body cold shock', '4. PAT face & beard completely dry (Do Skincare immediately while bathroom is humid)' /* FUTURE PLAN: , '5. Minoxidil: Exactly 1mL liquid/half-cap foam rubbed deeply to skin of beard/mustache -> let dry 30-60m' */]),
      TimelineItem(time: '10:00-10:30 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['1. Take 3 Magnesium Glycinate + 1 tablet Finasteride (1mg)', '2. Retinol: 1 pea-sized pump ONLY for face -> 1/2 pea-sized pump for neck -> WAIT 1-2m', '3. CeraVe: 1 pea-size for face/ears -> 1 pea-size for neck -> WAIT to dry', '4. Read/Reflect'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.rMagnesium, amount: 3), IngredientPortion(ingredient: IngredientsData.finasteride, amount: 1)])),
      TimelineItem(time: '10:30-11:00 pm', title: 'Fall Asleep', icon: '😴', details: ['Lights out, try to fall asleep within 30 min']),
    ],
    'thu': [
      TimelineItem(time: '7:30-7:35 am', title: 'Wakeup', icon: '☀️', details: ['1. Use bathroom', '2. Weight (Step on scale)', '3. Take 250mg Citicoline (w/ 25mg Tyrosine)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.citicoline, amount: 1)])),
      TimelineItem(time: '7:35-8:15 am', title: 'Get Ready', icon: '🚿', details: ['1. Turn OFF Dehumidifier -> Brush teeth', '2. Shower: Hair (60s warm massage) -> Body (Lipikar AP+, NO WASHCLOTH) -> Face (CeraVe Foaming, LUKEWARM. DO NOT DOUBLE WASH) -> Finish: 15s full-body cold shock -> PAT DRY (Do Skincare immediately while bathroom is humid)' /* FUTURE PLAN: If itching returns from 2x showers, use Nivea In-Shower Lotion to seal barrier */, '3. Ascorbyl 12%: 3 tiny drops for face, 2 for neck -> WAIT 90s', '4. CeraVe: 1 dime-size for face/ears, 1 pea-size for neck -> WAIT 30s', '5. Apply deodorant', '6. Get dressed']),
      TimelineItem(time: '8:15-8:30 am', title: 'Morning Reading', icon: '📖', details: ['Turn on Verilux HappyLight (45-degree angle to face)', 'reading']),
      TimelineItem(time: '8:30-11:30 am', title: 'Work', icon: '💻', details: ['Laundry: Regular Wash (All other clothes/gym gear, 3/5 warmness + OxiClean)', 'Run Dishwasher']),
      TimelineItem(time: '11:30-12:00 pm', title: 'Pre-Lunch Fiber', icon: '🥤', details: ['2 tsp husk + 1/8 tsp Morton Lite Salt in 16oz water (Drink 30m before lunch)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.psylliumHusk, amount: 2), IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 0.125)])),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🍝', details: ['1 serving of my pasta (Spinach is cooked inside)'], mealRecord: MealRecord(recipeItems: [RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'pasta'), servings: 1)])),
      TimelineItem(time: '12:30-3:30 pm', title: 'Work', icon: '💻', details: ['Fold & Put Away Laundry']),
      TimelineItem(time: '3:30-3:45 pm', title: 'Afternoon Snack', icon: '🥚', details: ['3 Boiled Eggs', '3 softgel omega-3', '1 D3-K2', '1 standalone K2 (100mcg)', '1 cap Biotin+Keratin (10mg/500mg)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.egg, amount: 3), IngredientPortion(ingredient: IngredientsData.omega3, amount: 3), IngredientPortion(ingredient: IngredientsData.d3K2, amount: 1), IngredientPortion(ingredient: IngredientsData.standaloneK2, amount: 1), IngredientPortion(ingredient: IngredientsData.biotinKeratin, amount: 1)])),
      TimelineItem(time: '3:45-4:00 pm', title: 'Pre-Workout Snack', icon: '🥤', details: ['1 banana (pre-workout)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.banana, amount: 1)])),
      TimelineItem(time: '4:00-5:30 pm', title: 'Work/Study', icon: '💻', details: ['Depending on your workload, work or study']),
      TimelineItem(time: '5:30-7:15 pm', title: 'Gym Session (Upper B)', icon: '🏋️', details: ['micellar wipe -> WAIT to dry -> Wash hands -> Mineral Unseen SPF (1 squirt index finger for face/ears -> Wash hands -> 1 squirt middle finger for neck) before leaving', 'Includes 20 min travel each way']),
      TimelineItem(time: '7:15-7:30 pm', title: 'Post-Workout', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.wheyIsolate, amount: 1), IngredientPortion(ingredient: IngredientsData.creatine, amount: 1)])),
      TimelineItem(time: '7:30-8:00 pm', title: 'Dinner', icon: '🍛', details: ['1/4 cup quinoa + 1/4 pound ground beef', '1 cup Unsweetened Almond Milk'], mealRecord: MealRecord(items: [const IngredientPortion(ingredient: IngredientsData.almondMilk, amount: 1)], recipeItems: [RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'quinoa_beef'), servings: 1)])),
      TimelineItem(time: '8:00-8:30 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop Casein + 1 tbsp Chia in 14-16oz water (drink immediately)', '2 cap Ashwagandha'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.casein, amount: 1), IngredientPortion(ingredient: IngredientsData.chiaSeeds, amount: 1), IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2)])),
      TimelineItem(time: '8:30-9:15 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['1. Turn OFF Dehumidifier -> Pre-Shower: Rub 2-3 pumps Cleansing Oil on DRY face (30s) to melt sunscreen', '2. In-Shower: Wet hands, rub face/neck/ears to emulsify (15-20s) -> Rinse', '3. Hair: 60s warm massage, Body: Bioderma Atoderm Wash (WITH Washcloth), Face: CeraVe Foaming (DO NOT DOUBLE WASH) -> Finish: 15s full-body cold shock', '4. PAT face & beard completely dry (Do Skincare immediately while bathroom is humid)' /* FUTURE PLAN: , '5. Minoxidil: Exactly 1mL liquid/half-cap foam rubbed deeply to skin of beard/mustache -> let dry 30-60m' */]),
      TimelineItem(time: '9:15-10:30 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['1. Take 2 Magnesium Glycinate + 1 tablet Finasteride (1mg)', '2. Paula\'s Choice 2% BHA: Splash 3-4 drops in hands and pat into face (focus on bumps) -> Pat lightly on neck -> WAIT 1-2m', '3. CeraVe: 1 pea-size for face/ears -> 1 pea-size for neck -> WAIT to dry', '4. Read/Reflect'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.rMagnesium, amount: 2), IngredientPortion(ingredient: IngredientsData.finasteride, amount: 1)])),
      TimelineItem(time: '10:30-11:00 pm', title: 'Fall Asleep', icon: '😴', details: ['Lights out, try to fall asleep within 30 min']),
    ],
    'fri': [
      TimelineItem(time: '7:30-7:35 am', title: 'Wakeup', icon: '☀️', details: ['1. Use bathroom', '2. Weight (Step on scale)', '3. Take 250mg Citicoline (w/ 25mg Tyrosine)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.citicoline, amount: 1)])),
      TimelineItem(time: '7:35-8:15 am', title: 'Get Ready', icon: '🚿', details: ['1. Turn OFF Dehumidifier -> Brush teeth', '2. Shower: Hair (60s warm massage) -> Body (Lipikar AP+, NO WASHCLOTH) -> Face (CeraVe Foaming, LUKEWARM. DO NOT DOUBLE WASH) -> Finish: 15s full-body cold shock -> PAT DRY (Do Skincare immediately while bathroom is humid)' /* FUTURE PLAN: If itching returns from 2x showers, use Nivea In-Shower Lotion to seal barrier */, '3. Ascorbyl 12%: 3 tiny drops for face, 2 for neck -> WAIT 90s', '4. Supergoop Glow Screen: 1 squirt for face, 1 for neck', '5. Apply deodorant', '6. Get dressed (cloud x 4)']),
      TimelineItem(time: '8:15-8:30 am', title: 'Morning Reading', icon: '📖', details: ['Turn on Verilux HappyLight (45-degree angle to face)', 'reading']),
      TimelineItem(time: '8:30-8:35 am', title: 'Grab things to take to work', icon: '🗂️', details: ['kindle/laptop', '2 key/wallet/phone', 'airpods', 'gym outfit', 'micellar wipes', 'sunscreen', 'Pasta lunch', '3 Boiled Eggs', 'Supplements (D3/K2, Omega-3, Copper, Biotin)', 'Dry Mix: 2 tsp husk + 1/8 tsp Morton Lite Salt', '1 banana', 'water bottle']),
      TimelineItem(time: '8:35-9:00 am', title: 'Commute to Work', icon: '🚗'),
      TimelineItem(time: '9:00-11:30 am', title: 'Work', icon: '💻'),
      TimelineItem(time: '11:30-12:00 pm', title: 'Pre-Lunch Fiber', icon: '🥤', details: ['2 tsp husk + 1/8 tsp Morton Lite Salt in 16oz water (Drink 30m before lunch)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.psylliumHusk, amount: 2), IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 0.125)])),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🍝', details: ['1 serving of my pasta (Spinach is cooked inside)'], mealRecord: MealRecord(recipeItems: [RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'pasta'), servings: 1)])),
      TimelineItem(time: '12:30-3:30 pm', title: 'Work', icon: '💻'),
      TimelineItem(time: '3:30-3:45 pm', title: 'Afternoon Snack', icon: '🥚', details: ['3 Boiled Eggs', '3 softgel omega-3', '1 D3-K2', '1 standalone K2 (100mcg)', '1 cap Biotin+Keratin (10mg/500mg)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.egg, amount: 3), IngredientPortion(ingredient: IngredientsData.omega3, amount: 3), IngredientPortion(ingredient: IngredientsData.d3K2, amount: 1), IngredientPortion(ingredient: IngredientsData.standaloneK2, amount: 1), IngredientPortion(ingredient: IngredientsData.biotinKeratin, amount: 1)])),
      TimelineItem(time: '3:45-5:00 pm', title: 'Work', icon: '💻'),
      TimelineItem(time: '5:00-5:30 pm', title: 'Commute to Gym', icon: '🚗', details: ['micellar wipe -> WAIT to dry -> Wash hands -> Mineral Unseen SPF (1 squirt for face/ears -> 1 squirt for neck)', '1 banana (pre-workout)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.banana, amount: 1)])),
      TimelineItem(time: '5:30-7:30 pm', title: 'Gym Session (Lower B)', icon: '🏋️', details: ['Includes the 15 min travel time back home']),
      TimelineItem(time: '7:30-7:40 pm', title: 'Post-Workout', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.wheyIsolate, amount: 1), IngredientPortion(ingredient: IngredientsData.creatine, amount: 1)])),
      TimelineItem(time: '7:40-8:00 pm', title: 'Dinner', icon: '🥗', details: ['1/3 lb Wild Sockeye Salmon', '2 cups Unsweetened Almond Milk'], mealRecord: MealRecord(items: [const IngredientPortion(ingredient: IngredientsData.almondMilk, amount: 2)], recipeItems: [RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'salmon'), servings: 1)])),
      TimelineItem(time: '8:00-8:30 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop Casein + 1 tbsp Chia in 14-16oz water (drink immediately)', '2 cap Ashwagandha'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.casein, amount: 1), IngredientPortion(ingredient: IngredientsData.chiaSeeds, amount: 1), IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2)])),
      TimelineItem(time: '8:30-9:30 pm', title: 'Study Time', icon: '📚'),
      TimelineItem(time: '9:30-10:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['1. Turn OFF Dehumidifier -> Pre-Shower: Rub 2-3 pumps Cleansing Oil on DRY face (30s) to melt sunscreen', '2. In-Shower: Wet hands, rub face/neck/ears to emulsify (15-20s) -> Rinse', '3. Hair: 60s warm massage, Body: Bioderma Atoderm Wash (WITH Washcloth), Face: CeraVe Foaming (DO NOT DOUBLE WASH) -> Finish: 15s full-body cold shock', '4. PAT face & beard completely dry (Do Skincare immediately while bathroom is humid)' /* FUTURE PLAN: , '5. Minoxidil: Exactly 1mL liquid/half-cap foam rubbed deeply to skin of beard/mustache -> let dry 30-60m' */]),
      TimelineItem(time: '10:00-10:30 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['1. Take 3 Magnesium Glycinate + 1 tablet Finasteride (1mg)', '2. Retinol: 1 pea-sized pump ONLY for face -> 1/2 pea-sized pump for neck -> WAIT 1-2m', '3. CeraVe: 1 pea-size for face/ears -> 1 pea-size for neck -> WAIT to dry', '4. Read/Reflect'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.rMagnesium, amount: 3), IngredientPortion(ingredient: IngredientsData.finasteride, amount: 1)])),
      TimelineItem(time: '10:30-11:00 pm', title: 'Fall Asleep', icon: '😴', details: ['Lights out, try to fall asleep within 30 min']),
    ],
    'sat': [
      TimelineItem(time: '7:30-7:40 am', title: 'Wakeup', icon: '☀️', details: ['1. Use bathroom', '2. Weight (Step on scale)', '3. Take 600mg NAC + 25mcg Selenium (Combo Pill)', '4. Take 250mg Citicoline (w/ 25mg Tyrosine)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.nac, amount: 1), IngredientPortion(ingredient: IngredientsData.citicoline, amount: 1)])),
      TimelineItem(time: '7:40-8:20 am', title: 'Get Ready', icon: '🚿', details: ['1. Turn OFF Dehumidifier -> Brush teeth', '2. Shower: Hair (60s warm massage) -> Body (Lipikar AP+, NO WASHCLOTH) -> Face (CeraVe Foaming, LUKEWARM. DO NOT DOUBLE WASH) -> Finish: 15s full-body cold shock -> PAT DRY (Do Skincare immediately while bathroom is humid)' /* FUTURE PLAN: If itching returns from 2x showers, use Nivea In-Shower Lotion to seal barrier */, '3. Ascorbyl 12%: 3 tiny drops for face, 2 for neck -> WAIT 90s', '4. CeraVe: 1 dime-size for face/ears, 1 pea-size for neck -> WAIT 30s', '5. Apply deodorant', '6. Get dressed for gym (Hoka Bondi 8)']),
      TimelineItem(time: '8:20-8:45 am', title: 'Relax', icon: '📖', details: ['Turn on Verilux HappyLight (45-degree angle to face)', '20mg adderall IR']),
      TimelineItem(time: '8:45-11:30 am', title: 'Study', icon: '📚'),
      TimelineItem(time: '11:30-12:00 pm', title: 'Pre-Lunch Fiber', icon: '🥤', details: ['2 tsp husk + 1/8 tsp Morton Lite Salt in 16oz water (Drink 30m before lunch)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.psylliumHusk, amount: 2), IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 0.125)])),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🍝', details: ['1 serving of my pasta (Spinach is cooked inside)', '1 cap Copper Glycinate (3mg)'], mealRecord: MealRecord(items: [const IngredientPortion(ingredient: IngredientsData.copperGlycinate, amount: 1)], recipeItems: [RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'pasta'), servings: 1)])),
      TimelineItem(time: '12:30-1:30 pm', title: 'Study', icon: '📚'),
      TimelineItem(time: '1:30-1:45 pm', title: 'Afternoon Snack', icon: '🥚', details: ['2 Boiled Eggs', '3 softgel omega-3', '1 D3-K2', '1 standalone K2 (100mcg)', '1 cap Biotin+Keratin (10mg/500mg)', '1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.egg, amount: 2), IngredientPortion(ingredient: IngredientsData.omega3, amount: 3), IngredientPortion(ingredient: IngredientsData.d3K2, amount: 1), IngredientPortion(ingredient: IngredientsData.standaloneK2, amount: 1), IngredientPortion(ingredient: IngredientsData.biotinKeratin, amount: 1), IngredientPortion(ingredient: IngredientsData.wheyIsolate, amount: 1), IngredientPortion(ingredient: IngredientsData.creatine, amount: 1)])),
      TimelineItem(time: '1:45-2:00 pm', title: 'Reflection/Revision', icon: '🔄', details: ['Has this plan been working?']),
      TimelineItem(time: '2:00-6:00 pm', title: 'Study', icon: '📚'),
      TimelineItem(time: '6:00-6:20 pm', title: 'Commute to Gym', icon: '🚗', details: ['micellar wipe -> WAIT to dry -> Wash hands -> Mineral Unseen SPF (1 squirt index finger for face/ears -> Wash hands -> 1 squirt middle finger for neck) before leaving']),
      TimelineItem(time: '6:20-7:20 pm', title: 'Cardio (LISS)', icon: '🏃', details: ['40 min walk (see Gym Plan → Cardio)']),
      TimelineItem(time: '7:20-7:30 pm', title: 'Commute Home', icon: '🚗'),
      TimelineItem(time: '7:30-8:00 pm', title: 'Dinner', icon: '🍛', details: ['1/4 cup quinoa + 1/4 pound ground beef', '1 cup Unsweetened Almond Milk', '1 cap Zinc Picolinate (30mg)'], mealRecord: MealRecord(items: [const IngredientPortion(ingredient: IngredientsData.almondMilk, amount: 1), const IngredientPortion(ingredient: IngredientsData.zincPicolinate, amount: 1)], recipeItems: [RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'quinoa_beef'), servings: 1)])),
      TimelineItem(time: '8:00-9:00 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop Casein + 1 tbsp Chia in 14-16oz water (drink immediately)', '2 cap Ashwagandha'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.casein, amount: 1), IngredientPortion(ingredient: IngredientsData.chiaSeeds, amount: 1), IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2)])),
      TimelineItem(time: '9:15-10:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['1. Turn OFF Dehumidifier -> Pre-Shower: Rub 2-3 pumps Cleansing Oil on DRY face (30s) to melt sunscreen', '2. In-Shower: Wet hands, rub face/neck/ears to emulsify (15-20s) -> Rinse', '3. Hair: Nizoral 1% (5m lather), Body: Bioderma Atoderm Wash (WITH Washcloth), Face: CeraVe Foaming (DO NOT DOUBLE WASH) -> Finish: 15s full-body cold shock', '4. PAT face & beard completely dry (Do Skincare immediately while bathroom is humid)' /* FUTURE PLAN: , '5. Minoxidil: Exactly 1mL liquid/half-cap foam rubbed deeply to skin of beard/mustache -> let dry 30-60m' */]),
      TimelineItem(time: '10:00-10:15 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['1. Take 2 Magnesium + 1 tablet Finasteride (1mg)', '2. Paula\'s Choice 2% BHA: Splash 3-4 drops in hands and pat into face (focus on bumps) -> Pat lightly on neck -> WAIT 1-2m', '3. CeraVe: 1 pea-size for face/ears -> 1 pea-size for neck -> WAIT to dry', '4. Read/Reflect'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.rMagnesium, amount: 2), IngredientPortion(ingredient: IngredientsData.finasteride, amount: 1)])),
      TimelineItem(time: '10:15-10:45 pm', title: 'Fall Asleep', icon: '😴', details: ['Lights out, try to fall asleep within 30 min']),
    ],
    'sun': [
      TimelineItem(time: '7:30-7:35 am', title: 'Wakeup', icon: '☀️', details: ['1. Use bathroom', '2. Weight (Step on scale)', '3. Take 600mg NAC + 25mcg Selenium (Combo Pill)', '4. Take 250mg Citicoline (w/ 25mg Tyrosine)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.nac, amount: 1), IngredientPortion(ingredient: IngredientsData.citicoline, amount: 1)])),
      TimelineItem(time: '7:35-8:20 am', title: 'Get Ready', icon: '🚿', details: ['1. Turn OFF Dehumidifier -> Brush teeth', '2. Shower: Hair (60s warm massage) -> Body (Lipikar AP+, NO WASHCLOTH) -> Face (CeraVe Foaming, LUKEWARM. DO NOT DOUBLE WASH) -> Finish: 15s full-body cold shock -> PAT DRY (Do Skincare immediately while bathroom is humid)' /* FUTURE PLAN: If itching returns from 2x showers, use Nivea In-Shower Lotion to seal barrier */, '3. Ascorbyl 12%: 3 tiny drops for face, 2 for neck -> WAIT 90s', '4. CeraVe: 1 dime-size for face/ears, 1 pea-size for neck -> WAIT 30s', '5. Apply deodorant', '6. Get dressed for shopping (NK 9060)']),
      TimelineItem(time: '8:20-9:30 am', title: 'Morning Reading', icon: '📖', details: ['Turn on Verilux HappyLight (45-degree angle to face)', 'reading']),
      TimelineItem(time: '9:30-12:30 pm', title: 'Study Time', icon: '📚', details: ['20mg adderall IR at 9:30am']),
      TimelineItem(time: '12:30-1:00 pm', title: 'Pre-Lunch Fiber', icon: '🥤', details: ['2 tsp husk + 1/8 tsp Morton Lite Salt in 16oz water (Drink 30m before lunch)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.psylliumHusk, amount: 2), IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 0.125)])),
      TimelineItem(time: '1:00-1:30 pm', title: 'Lunch', icon: '🍛', details: ['1/4 cup quinoa + 1/4 pound ground beef'], mealRecord: MealRecord(recipeItems: [RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'quinoa_beef'), servings: 1)])),
      TimelineItem(time: '1:30-1:45 pm', title: 'Afternoon Snack', icon: '🥚', details: ['2 Boiled Eggs', '3 softgel omega-3', '1 D3-K2', '1 standalone K2 (100mcg)', '1 cap Biotin+Keratin (10mg/500mg)'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.egg, amount: 2), IngredientPortion(ingredient: IngredientsData.omega3, amount: 3), IngredientPortion(ingredient: IngredientsData.d3K2, amount: 1), IngredientPortion(ingredient: IngredientsData.standaloneK2, amount: 1), IngredientPortion(ingredient: IngredientsData.biotinKeratin, amount: 1)])),
      TimelineItem(time: '1:45-3:30 pm', title: 'Grocery Shop', icon: '🛒', details: ['Wash hands -> Mineral Unseen SPF (quarter-sized dollop for face/ears -> quarter-sized dollop for neck)', 'check what I have before going', "Trader Joe's (all groceries are bought there)"]),
      TimelineItem(time: '3:30-6:00 pm', title: 'Cooking / Meal Prep', icon: '🧑‍🍳', details: ['Prep 7 Containers: 2 tsp Husk + 1/8 tsp Lite Salt each', 'Meal Prep: Pasta, Salmon, 18 Eggs']),
      TimelineItem(time: '6:00-6:15 pm', title: 'Snack', icon: '🥤', details: ['1 scoops whey isolate (37.5g protein)', '5g creatine'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.wheyIsolate, amount: 1), IngredientPortion(ingredient: IngredientsData.creatine, amount: 1)])),
      TimelineItem(time: '6:15-7:00 pm', title: 'Rest / Active Recovery', icon: '🛋️'),
      TimelineItem(time: '7:00-7:25 pm', title: 'Dinner', icon: '🌯', details: ['Chipotle Bowl: double chicken, normal brown rice/black beans, extra fajita veggies', '2 cups Unsweetened Almond Milk'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.chipotleBowl, amount: 1), IngredientPortion(ingredient: IngredientsData.almondMilk, amount: 2)])),
      TimelineItem(time: '7:25-8:00 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop Casein + 1 tbsp Chia in 14-16oz water (drink immediately)', '2 cap Ashwagandha'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.casein, amount: 1), IngredientPortion(ingredient: IngredientsData.chiaSeeds, amount: 1), IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2)])),
      TimelineItem(time: '8:00-9:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['1. Turn OFF Dehumidifier -> Pre-Shower: Rub 2-3 pumps Cleansing Oil on DRY face (30s) to melt sunscreen', '2. In-Shower: Wet hands, rub face/neck/ears to emulsify (15-20s) -> Rinse', '3. Hair: 60s warm massage, Body: Bioderma Atoderm Wash (WITH Washcloth), Face: CeraVe Foaming (DO NOT DOUBLE WASH) -> Finish: 15s full-body cold shock', '4. PAT face & beard completely dry (Do Skincare immediately while bathroom is humid)' /* FUTURE PLAN: , '5. Minoxidil: Exactly 1mL liquid/half-cap foam rubbed deeply to skin of beard/mustache -> let dry 30-60m' */]),
      TimelineItem(time: '9:00-9:15 pm', title: 'Night Supplement', icon: '🌙', details: ['1. Take 2 Magnesium + 1 tablet Finasteride (1mg)', '2. Joseon Alpha-Arbutin: 2 tiny drops ONLY for face -> 1 drop for neck -> WAIT 1-2m', '3. CeraVe: 1 pea-size for face/ears -> 1 pea-size for neck -> WAIT to dry'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.rMagnesium, amount: 2), IngredientPortion(ingredient: IngredientsData.finasteride, amount: 1)])),
      TimelineItem(time: '9:15-10:00 pm', title: 'Read/Reflect', icon: '📚'),
      TimelineItem(time: '10:00-10:30 pm', title: 'Fall Asleep', icon: '😴', details: ['Lights out, try to fall asleep within 30 min']),
    ],
  };
}
