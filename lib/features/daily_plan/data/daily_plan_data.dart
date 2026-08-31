import '../../micro_macro_calorie_track/domain/nutrition.dart';
import '../../micro_macro_calorie_track/data/ingredients_data.dart';
import '../../recipe/data/recipe_data.dart';

class TimelineItem {
  final String time;
  final String title;
  final String icon;
  final List<String> details;
  final MealRecord? mealRecord;
  final bool isCardio;

  const TimelineItem({
    required this.time,
    required this.title,
    required this.icon,
    this.details = const [],
    this.mealRecord,
    this.isCardio = false,
  });
}

// ==========================================
// PORTIONS & RECIPES
// ==========================================

class _Portions {
  static const d3K2 = IngredientPortion(ingredient: IngredientsData.d3K2, amount: 1);
  static const standaloneK2 = IngredientPortion(ingredient: IngredientsData.standaloneK2, amount: 1);
  static const vitaminE = IngredientPortion(ingredient: IngredientsData.vitaminE, amount: 1);
  static const omega3 = IngredientPortion(ingredient: IngredientsData.omega3, amount: 3);
  static const biotin = IngredientPortion(ingredient: IngredientsData.biotinKeratin, amount: 1);
  
  static const zinc = IngredientPortion(ingredient: IngredientsData.zincPicolinate, amount: 1);
  static const whey = IngredientPortion(ingredient: IngredientsData.wheyIsolate, amount: 1);
  static const creatine = IngredientPortion(ingredient: IngredientsData.creatine, amount: 1);
  static const babyCarrots = IngredientPortion(ingredient: IngredientsData.babyCarrots, amount: 24 / 7);
  
  static const calciumCitrate = IngredientPortion(ingredient: IngredientsData.calciumCitrate, amount: 3);
  static const calciumCitrate2 = IngredientPortion(ingredient: IngredientsData.calciumCitrate, amount: 2);
  static const calciumCitrate1 = IngredientPortion(ingredient: IngredientsData.calciumCitrate, amount: 1);

  static const coreVitamins = [d3K2, standaloneK2, omega3, biotin];
}

class _Recipes {
  static RecipePortion get pasta => RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'pasta'), servings: 1);
  static RecipePortion get pastaThird => RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'pasta'), servings: 1/3);
  static RecipePortion get pastaTwoThirds => RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'pasta'), servings: 2/3);
  static RecipePortion get salmon => RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'salmon'), servings: 1);
  static RecipePortion get salmonHalf => RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'salmon'), servings: 0.5);
  static RecipePortion get beef => RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'beef'), servings: 1);
  static RecipePortion get beefHalf => RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'beef'), servings: 0.5);
  static RecipePortion get quinoa => RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'quinoa'), servings: 1);
}

// ==========================================
// ROUTINE CONSTANTS (Skincare & Laundry)
// ==========================================

class _Routines {
  // Skincare
  static const String morningSkin1004 = 'Eye Serum FIRST: Gently tap 1 drop of The Ordinary Caffeine Solution across orbital bone -> Skin1004 Centella Sun Serum: Apply face in 2 layers (0.5 finger, wait 30s, 0.5 finger) -> Apply 1 finger for neck -> WAIT 3m';
  static const String morningHaruharu = 'Eye Serum FIRST: Gently tap 1 drop of The Ordinary Caffeine Solution across orbital bone -> Haruharu Wonder Sunscreen: Apply face in 2 layers (0.5 finger, wait 30s, 0.5 finger) -> Apply 1 finger for neck -> WAIT 3m';
  static const String reapplyHur = 'Wash hands -> Blotting Sheet  -> Wash hands -> House of Hur Sun Fluid: Apply face in 2 layers (0.5 finger, wait 30s, 0.5 finger) -> Apply 1 finger for neck -> WAIT 3m';
  static const String reapplyHaruharu = 'Wash hands -> Blotting Sheet  -> Wash hands -> Haruharu Wonder Sunscreen: Apply face in 2 layers (0.5 finger, wait 30s, 0.5 finger) -> Apply 1 finger for neck -> WAIT 3m';
  static const String retinol = 'Retinol (Apply to BONE DRY skin to prevent irritation, STRICTLY AVOID orbital bone/eyelids): 1.5 pumps (0.5 forehead, 0.25 left cheek, 0.25 right cheek, 0.5 neck) -> WAIT 1-2m';
  static const String bha = 'Paula\'s Choice 2% BHA (Apply to BONE DRY skin to prevent irritation, AVOID orbital bone): 3 drops (1 forehead, 1 left cheek, 1 right cheek) -> WAIT 1-2m';
  static const String joseon = 'Joseon Alpha-Arbutin (Apply to slightly damp skin, AVOID orbital bone): 4 drops (1 forehead, 1 left cheek, 1 right cheek, 1 neck) -> WAIT 1-2m';

  // Laundry
  static const String laundryFaceTowels = 'Laundry Cycle 1: Bamboo Washcloths & Cotton Pillowcases (3/5 warmness) -> 1-2 tbsp All Free Clear (Liquid). NO Fabric Softener (Dry on LOW heat)';
  static const String laundryBathTowels = 'Laundry Cycle 2: Bath Towels & Body Washcloths (5/5 warmness) -> Wash 1: 2 tbsp All Free Clear (Liquid) + 1/3 cup Bleach -> Wash 2: Full Cycle (WATER ONLY - no detergent) to lift bleach residue (Dry on LOW heat)';
  static const String laundryRegular = 'Laundry: Regular Wash (All other clothes/gym gear, 3/5 warmness) -> All Free Clear (Liquid)';
}

enum MorningSupplement {
  omega3,
  d3K2,
  vitaminE,
  zinc,
  copper,
}

enum NutritionAddOn {
  whey,
  creatine,
  calcium,
  copper,
  nac,
  banana,
  postWorkoutBanana,
  midMorningBanana,
  preWorkoutBanana,
  dextrin,
}

enum RoutineModifier {
  caffeine,
  sparklingWater,
  standingDesk,
  cookSalmon,
  takeSunscreen,
  takeGymGloves,
  newBathTowel,
}

// ==========================================
// DAILY PLAN DATA
// ==========================================

class DailyPlanData {
  static final DateTime planStartDate = DateTime(2026, 7, 27);
  static DateTime? mockCurrentDate;

  // Day Keys
  static const String mon = 'mon';
  static const String tue = 'tue';
  static const String wed = 'wed';
  static const String thu = 'thu';
  static const String fri = 'fri';
  static const String sat = 'sat';
  static const String sun = 'sun';

  static const Map<String, int> waterBottles = {
    mon: 7, tue: 7, wed: 7, thu: 7, fri: 7, sat: 7, sun: 7,
  };

  // ------------------------------------------
  // Schedule Conditions & Flags
  // ------------------------------------------

  static int get currentWeekNumber {
    final now = mockCurrentDate ?? DateTime.now();
    final diff = now.difference(planStartDate).inDays;
    if (diff < 0) return 0;
    return (diff ~/ 7) + 1;
  }

  static bool isDeloadWeek() => isRefeedWeek();
  static bool shouldScaleUpCardio() => currentWeekNumber >= 17;
  
  static bool isBloodDonationWeek() => currentWeekNumber > 0 && currentWeekNumber % 22 == 0;

  static bool isWinter() {
    final now = mockCurrentDate ?? DateTime.now();
    if (now.month == 11 && now.day >= 15) return true;
    if (now.month == 12 || now.month == 1 || now.month == 2) return true;
    if (now.month == 3 && now.day <= 15) return true;
    return false;
  }
  
  static bool isBloodTestPrepWeek() {
    final now = mockCurrentDate ?? DateTime.now();
    final start = DateTime(2026, 8, 24);
    final end = DateTime(2026, 8, 31, 23, 59, 59);
    return now.isAfter(start.subtract(const Duration(seconds: 1))) && now.isBefore(end);
  }

  static bool isAshwagandhaOff() {
    if (currentWeekNumber == 0) return false;
    return ((currentWeekNumber - 1) % 12) + 1 > 8;
  }

  static bool isRefeedWeek() {
    if (currentWeekNumber == 0) return false;
    return currentWeekNumber == 5 || currentWeekNumber == 12 || currentWeekNumber == 18;
  }

  static bool isNextWeekRefeedWeek() {
    if (currentWeekNumber == 0) return false;
    return currentWeekNumber == 4 || currentWeekNumber == 11 || currentWeekNumber == 17;
  }

  static List<String> getReminders(String dayKey) {
    if (dayKey == wed) return ['🥩 Take ground beef out of freezer to thaw in fridge'];
    if (dayKey == sun) return ['❄️ Put fresh ground beef into the freezer'];
    return [];
  }

  // ------------------------------------------
  // Timeline Item Builders
  // ------------------------------------------

  static TimelineItem _wakeup(String time, {Set<NutritionAddOn> nutrition = const {}}) {
    final nac = nutrition.contains(NutritionAddOn.nac);
    return TimelineItem(
      time: time,
      title: 'Wakeup',
      icon: '☀️',
      details: [
        'Use bathroom',
        'Weight (Step on scale)',
        'Drink cold water',
        if (isRefeedWeek()) '🍌 REFEED WEEK: Eat 1 Medium Banana',
        if (nac) 'Take 600mg NAC + 25mcg Selenium (Combo Pill)',
        'Take 250mg Citicoline (w/ 25mg Tyrosine)',
      ],
      mealRecord: MealRecord(items: [
        if (isRefeedWeek()) const IngredientPortion(ingredient: IngredientsData.banana, amount: 1),
        if (nac) const IngredientPortion(ingredient: IngredientsData.nac, amount: 1),
        const IngredientPortion(ingredient: IngredientsData.citicoline, amount: 1),
      ]),
    );
  }

  static TimelineItem _getReady(String time, {required String skincare, required String clothes}) {
    return TimelineItem(
      time: time,
      title: 'Get Ready',
      icon: '🧼',
      details: [
        'Brush teeth',
        'Blotting Sheet: Use 2-3 sheets to absorb heavy overnight sebum',
        'Gently splash face/neck with water for 5-10s to rinse off overnight sweat',
        'Pat dry with new bamboo baby washcloth',
        'Ascorbyl 12% (Apply to slightly damp skin, AVOID orbital bone): 5 drops (1 forehead, 1 left cheek, 1 right cheek, 2 neck)',
        'WAIT 90s',
        skincare,
        clothes,
      ],
    );
  }

  static TimelineItem _morningDine(String time, {
    String additional = '', 
    int eggs = 3, 
    Set<MorningSupplement> supplements = const { MorningSupplement.omega3 },
    bool eatSalmon = false,
    bool eatBeef = false,
    String blueberryText = '',
    bool banana = false,
  }) {
    final omega3 = supplements.contains(MorningSupplement.omega3);
    final useD3K2 = supplements.contains(MorningSupplement.d3K2);
    final vitaminE = supplements.contains(MorningSupplement.vitaminE);
    final zinc = supplements.contains(MorningSupplement.zinc);
    final copper = supplements.contains(MorningSupplement.copper);

    return TimelineItem(
      time: time,
      title: 'Morning Dine',
      icon: '🍳',
      details: [
        'Eat in front of Verilux HappyLight (45-degree angle to face):',
        if (banana) '🍌 Eat 1 Medium Banana',
        if (blueberryText.isNotEmpty) '🫐 $blueberryText',
        if (eatSalmon) 'Finish leftover 0.5 portion of Salmon (from fridge)',
        if (eatBeef) 'Finish leftover 0.5 portion of Ground Beef (from fridge)',
        if (eggs > 0) '$eggs Boiled Eggs',
        if (omega3) '3 softgel omega-3',
        if (useD3K2) '1 D3-K2',
        if (useD3K2) '1 standalone K2 (100mcg)' else '2 standalone K2 (100mcg each)',
        '1 cap Biotin+Keratin (10mg/500mg)',
        if (vitaminE) '1 softgel Vitamin E (267mg)',
        if (zinc) '1 cap Zinc Picolinate (30mg)',
        if (copper) '1 cap Copper Glycinate (3mg)',
        'Swish/drink water after eating/drinking to clear mouth',
        if (additional.isNotEmpty) additional,
      ],
      mealRecord: MealRecord(
        items: [
          if (banana) const IngredientPortion(ingredient: IngredientsData.banana, amount: 1),
          if (blueberryText.isNotEmpty) const IngredientPortion(ingredient: IngredientsData.blueberries, amount: 0.66),
          if (eggs > 0) IngredientPortion(ingredient: IngredientsData.egg, amount: eggs.toDouble()),
          if (omega3) _Portions.omega3,
          if (useD3K2) _Portions.d3K2,
          if (useD3K2) _Portions.standaloneK2 else const IngredientPortion(ingredient: IngredientsData.standaloneK2, amount: 2),
          _Portions.biotin,
          if (vitaminE) _Portions.vitaminE,
          if (zinc) _Portions.zinc,
          if (copper) const IngredientPortion(ingredient: IngredientsData.copperGlycinate, amount: 1),
        ], 
        recipeItems: [
          if (eatSalmon) _Recipes.salmonHalf,
          if (eatBeef) _Recipes.beefHalf,
        ]
      ),
    );
  }

  static TimelineItem _grabThings(String time, {Set<RoutineModifier> modifiers = const {RoutineModifier.takeSunscreen}}) {
    final takeSunscreen = modifiers.contains(RoutineModifier.takeSunscreen);
    return TimelineItem(
      time: time,
      title: 'Grab things to take to work',
      icon: '🗂️',
      details: [
        'kindle/laptop',
        '2 key/wallet/phone',
        'airpods',
        'apple watch',
        if (takeSunscreen) 'Haruharu Wonder Sunscreen',
        if (takeSunscreen) 'Oil-Absorbing Blotting Sheets',
        'Pasta lunch',
        'water bottle'
      ],
    );
  }

  static TimelineItem _commuteToWork(String time) => TimelineItem(time: time, title: 'Commute to Work', icon: '🚗');

  static TimelineItem _work(String time, {
    List<String> details = const [], 
    String title = 'Work', 
    Set<NutritionAddOn> nutrition = const {},
    Set<RoutineModifier> modifiers = const {},
    String? afternoonSunscreen,
  }) {
    final caffeine = modifiers.contains(RoutineModifier.caffeine);
    final sparklingWater = modifiers.contains(RoutineModifier.sparklingWater);
    final standingDesk = modifiers.contains(RoutineModifier.standingDesk);
    final banana = nutrition.contains(NutritionAddOn.banana);
    final midMorningBanana = nutrition.contains(NutritionAddOn.midMorningBanana);

    return TimelineItem(
      time: time, 
      title: title, 
      icon: '💻', 
      details: [
        if (caffeine) '☕️ Drink Caffeine around 9:30 am',
        if (sparklingWater) 'Drink Sparkling Water',
        if (standingDesk && !isRefeedWeek()) '🧍♂️ Use Standing Desk for 3-4 hours',
        if (midMorningBanana) '🍌 11:30 am: Eat 1 Medium Banana (Mid-Morning)',
        if (banana) '🍌 3:30-4:00 pm: Eat 1 Medium Banana (Afternoon Snack)',
        if (afternoonSunscreen != null) '4:00 pm Touch-up: $afternoonSunscreen',
        ...details
      ],
      mealRecord: (banana || midMorningBanana) ? MealRecord(items: [
        if (midMorningBanana) const IngredientPortion(ingredient: IngredientsData.banana, amount: 1),
        if (banana) const IngredientPortion(ingredient: IngredientsData.banana, amount: 1),
      ]) : null,
    );
  }

  static TimelineItem _pastaLunch(String time) {
    final isFullLunch = isRefeedWeek();
    return TimelineItem(
      time: time,
      title: 'Lunch',
      icon: '🍝',
      details: [
        if (isFullLunch) '1 full serving of my pasta' else '2/3 serving of my pasta',
      ],
      mealRecord: MealRecord(
        items: [],
        recipeItems: [if (isFullLunch) _Recipes.pasta else _Recipes.pastaTwoThirds],
      ),
    );
  }

  static TimelineItem _study(String time, {
    List<String> details = const [],
    int sleepKiwiCount = 0,
    Set<NutritionAddOn> nutrition = const {},
  }) {
    final banana = nutrition.contains(NutritionAddOn.banana);
    final midMorningBanana = nutrition.contains(NutritionAddOn.midMorningBanana);
    final withCreatine = nutrition.contains(NutritionAddOn.creatine);

    return TimelineItem(
      time: time,
      title: 'Study Time',
      icon: '📚',
      details: [
        if (withCreatine) '🥤 Pre-Workout Shake: 1 scoop creatine monohydrate (5g)',
        ...details,
        if (midMorningBanana) '🍌 11:30 am: Eat 1 Medium Banana (Mid-Morning)',
        if (banana) '🍌 3:30-4:00 pm: Eat 1 Medium Banana (Afternoon Snack)',
        if (sleepKiwiCount > 0) 'Halfway through (30m before bed prep): Eat $sleepKiwiCount Kiwi${sleepKiwiCount > 1 ? "s" : ""} & Swish water (protect enamel)',
      ],
      mealRecord: (sleepKiwiCount > 0 || banana || midMorningBanana || withCreatine) ? MealRecord(items: [
        if (withCreatine) _Portions.creatine,
        if (midMorningBanana) const IngredientPortion(ingredient: IngredientsData.banana, amount: 1),
        if (banana) const IngredientPortion(ingredient: IngredientsData.banana, amount: 1),
        if (sleepKiwiCount > 0) IngredientPortion(ingredient: IngredientsData.kiwi, amount: sleepKiwiCount.toDouble()),
      ]) : null,
    );
  }

  static TimelineItem _relaxOrCatchUp(String time, {String title = 'Relax / Catch up on reading', String icon = '🛋️'}) {
    return TimelineItem(time: time, title: title, icon: icon);
  }

  static TimelineItem _commuteToGym(String time, {String? reapplySunscreen, Set<RoutineModifier> modifiers = const {}, Set<NutritionAddOn> nutrition = const {NutritionAddOn.dextrin}}) {
    final takeGymGloves = modifiers.contains(RoutineModifier.takeGymGloves);
    final withDextrin = nutrition.contains(NutritionAddOn.dextrin);
    final withWhey = nutrition.contains(NutritionAddOn.whey);
    // Internalized: resistance days (with dextrin) always get banana, LISS days only on refeed
    final preWorkoutBanana = withDextrin || isRefeedWeek();
    return TimelineItem(
      time: time,
      title: 'Get Dressed & Commute to Gym${withDextrin ? " (Resistance)" : " (LISS)"}',
      icon: '🚗',
      details: [
        'Get dressed for gym',
        if (preWorkoutBanana) '🍌 Eat ${isRefeedWeek() ? "3" : "1"} Medium Banana${isRefeedWeek() ? "s" : ""} (Pre-Workout)',
        if (withDextrin || withWhey) 'Mix ${[if (withDextrin) '1 scoop Cluster Dextrin', if (withWhey) '1 scoop whey isolate (30g protein)'].join(' + ')} in water bottle${withDextrin && !isRefeedWeek() ? ' (+ 0.5 tsp Lite Salt electrolytes)' : ''}. Drink 1/3 on commute, sip rest during workout',
        if (reapplySunscreen != null) reapplySunscreen,
        if (takeGymGloves) '🧤 Grab Gym Gloves',
      ],
      mealRecord: (withDextrin || preWorkoutBanana || withWhey) ? MealRecord(items: [
        if (preWorkoutBanana) IngredientPortion(ingredient: IngredientsData.banana, amount: isRefeedWeek() ? 3 : 1),
        if (withDextrin) const IngredientPortion(ingredient: IngredientsData.clusterDextrin, amount: 1),
        if (withWhey) _Portions.whey,
        if (withDextrin && !isRefeedWeek()) const IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 0.5),
      ]) : null,
    );
  }

  static TimelineItem _gym(String time, String title, {bool isCardio = false}) {
    if (isCardio && isRefeedWeek()) {
      return TimelineItem(
        time: time,
        title: 'Haircut / Rest (Refeed Week)',
        icon: '🛋️',
        details: ['Skip LISS cardio to allow CNS to recover and muscles to fully replenish glycogen.'],
        isCardio: false,
      );
    }
    return TimelineItem(time: time, title: title, icon: isCardio ? '🏃' : '🏋️', isCardio: isCardio);
  }

  static TimelineItem _salmonDinner(String time, {Set<NutritionAddOn> nutrition = const {NutritionAddOn.creatine}, Set<RoutineModifier> modifiers = const {}}) {
    final withCreatine = nutrition.contains(NutritionAddOn.creatine);
    final copper = nutrition.contains(NutritionAddOn.copper);
    final cook = modifiers.contains(RoutineModifier.cookSalmon);
    final showAshwagandha = !isAshwagandhaOff();
    final eatPastaThird = !isRefeedWeek();
    return TimelineItem(
      time: time,
      title: 'Dinner',
      icon: '🥗',
      details: [
        if (withCreatine) '1 scoop creatine monohydrate (5g)',
        if (copper) 'Take 1 cap Copper Glycinate (3mg)',
        if (cook) 'Cook Salmon (3 portions): start 1st portion (eat 1/2, save 1/2 in fridge)' else 'Start a new portion of Salmon (eat 1/2, save other 1/2 in fridge)', 
        '🥕 Eat 1/7th of a bag (~14 baby carrots)',
        if (eatPastaThird) '1/3 serving of my pasta',
        if (showAshwagandha) '2 cap Ashwagandha',
        if (isRefeedWeek()) '🍚 REFEED WEEK: Include 0.5 cups (dry) cooked Quinoa',
      ],
      mealRecord: MealRecord(
        items: [
          if (withCreatine) _Portions.creatine,
          if (copper) const IngredientPortion(ingredient: IngredientsData.copperGlycinate, amount: 1),
          _Portions.babyCarrots,
          if (showAshwagandha) const IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2),
        ], 
        recipeItems: [
          _Recipes.salmonHalf,
          if (eatPastaThird) _Recipes.pastaThird,
          if (isRefeedWeek()) _Recipes.quinoa,
        ]
      ),
    );
  }

  static TimelineItem _beefDinner(String time) {
    final showAshwagandha = !isAshwagandhaOff();
    final eatPastaThird = !isRefeedWeek();
    return TimelineItem(
      time: time,
      title: 'Dinner',
      icon: '🍛',
      details: [
        '1 scoop creatine monohydrate (5g)',
        'Start a new portion of Ground Beef (eat 1/2, save other 1/2 in fridge)', 
        '🥕 Eat 1/7th of a bag (~14 baby carrots)',
        if (eatPastaThird) '1/3 serving of my pasta',
        if (showAshwagandha) '2 cap Ashwagandha',
        if (isRefeedWeek()) '🍚 REFEED WEEK: Include 0.5 cups (dry) cooked Quinoa',
      ],
      mealRecord: MealRecord(
        items: [
          _Portions.creatine,
          _Portions.babyCarrots,
          if (showAshwagandha) const IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2),
        ], 
        recipeItems: [
          _Recipes.beefHalf,
          if (eatPastaThird) _Recipes.pastaThird,
          if (isRefeedWeek()) _Recipes.quinoa,
        ]
      ),
    );
  }

  static TimelineItem _chores(String time, {int sleepKiwiCount = 0, String blueberryText = '', Set<NutritionAddOn> nutrition = const {}, List<String> extraDetails = const []}) {
    return TimelineItem(
      time: time,
      title: 'Chores & Clean Up',
      icon: '🧼',
      details: [
        '1 scoop Casein in 16oz water -> Swish/drink water after',
        'The 7 bottles water are separate from this. This is in addition to that. So 7 bottles + this.',
        if (sleepKiwiCount > 0) 'Eat $sleepKiwiCount Kiwi${sleepKiwiCount > 1 ? "s" : ""} now (30m before bed prep to protect enamel) & Swish water',
        if (blueberryText.isNotEmpty) '🫐 $blueberryText',
        ...extraDetails,
        '📱 Final check of phone/messages before Screen Curfew starts.',
      ], 
      mealRecord: MealRecord(items: [
        const IngredientPortion(ingredient: IngredientsData.casein, amount: 1),
        if (sleepKiwiCount > 0) IngredientPortion(ingredient: IngredientsData.kiwi, amount: sleepKiwiCount.toDouble()),
        if (blueberryText.isNotEmpty) const IngredientPortion(ingredient: IngredientsData.blueberries, amount: 1.0),
      ]),
    );
  }

  static TimelineItem _bedPrep(String time, {String hair = '60s warm massage', Set<RoutineModifier> modifiers = const {}, bool isHarshActiveNight = false}) {
    final newBathTowel = modifiers.contains(RoutineModifier.newBathTowel);
    return TimelineItem(
      time: time,
      title: 'Shower & Bed Prep (Wind Down Starts)',
      icon: '🚿',
      details: [
        '📱 SCREEN CURFEW: Dim bathroom and bedroom lights. Put phone on charger across the room (No more screens tonight).',
        if (newBathTowel) '🛑 Grab a FRESH Bath Towel for the new rotation; skip the bamboo!',
        'Brush teeth',
        'Pre-Shower: Rub 2-3 pumps dedicated Cleansing Oil on DRY face (30s) to melt sunscreen/sweat',
        'In-Shower: Wet hands, rub face/neck/ears to emulsify oil (15-20s) -> Rinse thoroughly',
        'Hair: $hair',
        'Body: Hold Washcloth under water until SOAKING wet. Apply Dove Deep Moisture Body Wash into cloth and rub together to build a rich foam cushion. Gently sweep foamy cloth over upper and lower body (for frictionless gym maintenance)',
        'Face: Lather 1 pump of ${isWinter() || isHarshActiveNight ? "Lipikar AP+ (Barrier Shield)" : "Vanicream Gentle Cleanser"} in wet hands for 3-4s to build foam. Gently glide foam onto face/neck/ears with LUKEWARM water for EXACTLY 30s (then rinse)',
        'Finish: Hot rinse to raise skin temperature (helps drop core body temp afterward for sleep onset)',
        newBathTowel
            ? 'Pat face & beard completely dry with the FRESH Bath Towel (Do Skincare immediately while bathroom is humid, before drying your body)'
            : 'Pat face & beard completely dry with a new bamboo baby washcloth (Do Skincare immediately while bathroom is humid)',
      ],
    );
  }

  static TimelineItem _nightSupplement(String time, {
    required String skincare, 
    int magAmount = 2, 
    String title = 'Night Supplement & Wind Down',
    Set<NutritionAddOn> nutrition = const {},
  }) {
    final nac = nutrition.contains(NutritionAddOn.nac);
    return TimelineItem(
      time: time,
      title: title,
      icon: '🌙',
      details: [
        '📖 WIND DOWN: Read a physical book, use a Kindle (warm light/dark mode), or stretch. strictly NO phone scrolling or videos.',
        skincare,
        'Underarms: Ensure pits are BONE DRY -> Moisturize with face moisturizer (Vanicream Daily Facial) -> WAIT to dry -> Apply 5% AHA Deodorant',
        'Eye Serum FIRST: Gently tap 1 drop of The Ordinary Caffeine Solution across orbital bone',
        'Moisturizer (Cetaphil Hydrating Lotion): Apply 1.5 pumps for face, 1.5 pumps for neck, and 0.5 pumps for ears, then rub in -> WAIT to dry',
        'Take $magAmount Magnesium Glycinate + 1 tablet Finasteride (1mg)',
        if (nac) 'Take 600mg NAC + 25mcg Selenium (Combo Pill)',
      ],
      mealRecord: MealRecord(items: [
        IngredientPortion(ingredient: IngredientsData.rMagnesium, amount: magAmount.toDouble()),
        const IngredientPortion(ingredient: IngredientsData.finasteride, amount: 1),
        if (nac) const IngredientPortion(ingredient: IngredientsData.nac, amount: 1),
      ]),
    );
  }

  static TimelineItem _fallAsleep(String time) {
    return TimelineItem(
      time: time,
      title: 'Fall Asleep',
      icon: '😴',
      details: [
        '📝 Brain dump: Write down your to-do list for tomorrow on paper so you aren\'t thinking about it in bed.',
        '🌡️ Ensure room temperature drops to ~65°F (18°C) to facilitate sleep onset.',
        'Lights completely out (pitch black). Close eyes and allow sleep to happen naturally.',
      ],
    );
  }


  // ------------------------------------------
  // Study Cycle Helper (Weekend)
  // ------------------------------------------

  static List<TimelineItem> _buildStudyCycle(String studyTime, String restTime, {
    List<String> studyDetails = const [],
    Set<NutritionAddOn> studyNutrition = const {},
  }) => [
    _study(studyTime, details: studyDetails, nutrition: studyNutrition),
    TimelineItem(time: restTime, title: 'Diffuse Brain Rest', icon: '🧠', details: ['NO PHONE. Relax or nap on bed/chair. Close eyes and allow memory consolidation.']),
  ];

  // ------------------------------------------
  // Standard Weekday Template
  // ------------------------------------------

  static List<TimelineItem> _buildStandardWeekday({
    Set<NutritionAddOn> wakeupNutrition = const {},
    String? morningSkincare,
    required String clothes,
    int eggs = 2,
    Set<MorningSupplement> morningSupplements = const {},
    bool morningBanana = false,
    bool eatSalmon = false,
    bool eatBeef = false,
    String morningAdditional = '',
    bool isOfficeDay = false,

    List<String> amWorkDetails = const [],

    List<String> pmWorkDetails = const [],
    String? preGymStudyTime,
    Set<NutritionAddOn> preGymStudyNutrition = const {},
    String commuteToGymTime = '5:55-6:30 pm',
    Set<NutritionAddOn> commuteToGymNutrition = const {NutritionAddOn.dextrin, NutritionAddOn.whey},
    Set<RoutineModifier> commuteToGymModifiers = const {},
    String gymTime = '6:30-8:00 pm',
    required String gymTitle,
    bool gymIsCardio = false,
    String commuteHomeFromGymTime = '8:00-8:30 pm',
    required TimelineItem dinner,
    String choresTime = '9:20-9:50 pm',
    int choresSleepKiwiCount = 0,
    String choresBlueberryText = '',
    List<TimelineItem> extraPostChoresItems = const [],
    String bedPrepTime = '9:50-10:20 pm',
    String bedPrepHair = '60s warm massage',
    Set<RoutineModifier> bedPrepModifiers = const {},
    bool isHarshActiveNight = false,
    String nightSupplementTime = '10:20-10:50 pm',
    required int magAmount,
    required String nightSkincare,
  }) {
    final effectiveSkincare = morningSkincare ??
        (isOfficeDay ? _Routines.morningHaruharu : _Routines.morningSkin1004);
    final effectiveStudyTime = preGymStudyTime ??
        (isOfficeDay ? '5:10-5:55 pm' : '5:00-5:55 pm');
    final effectiveSunscreen = isOfficeDay ? _Routines.reapplyHaruharu : _Routines.reapplyHur;

    return [
      _wakeup('8:00-8:10 am', nutrition: wakeupNutrition),
      _getReady('8:10-8:30 am', skincare: effectiveSkincare, clothes: clothes),
      _morningDine('8:30-8:50 am', eggs: eggs, supplements: morningSupplements, banana: morningBanana, eatSalmon: eatSalmon, eatBeef: eatBeef, additional: morningAdditional),
      if (isOfficeDay) _grabThings('8:50-8:55 am'),
      if (isOfficeDay) _commuteToWork('8:55-9:00 am'),
      _work(isOfficeDay ? '9:00-1:00 pm' : '8:50-1:00 pm', details: amWorkDetails, modifiers: isOfficeDay ? {RoutineModifier.caffeine, RoutineModifier.sparklingWater, RoutineModifier.standingDesk} : {}, nutrition: {}),
      _pastaLunch('1:00-1:30 pm'),
      _work('1:30-5:00 pm', details: pmWorkDetails, modifiers: isOfficeDay ? {RoutineModifier.sparklingWater, RoutineModifier.standingDesk} : {}, nutrition: {}, afternoonSunscreen: effectiveSunscreen),
      if (isOfficeDay) TimelineItem(time: '5:00-5:10 pm', title: 'Commute Home', icon: '🚗'),
      _study(effectiveStudyTime, details: ['Study (Beat traffic before gym)'], nutrition: preGymStudyNutrition),
      _commuteToGym(commuteToGymTime, nutrition: commuteToGymNutrition, modifiers: commuteToGymModifiers),
      _gym(gymTime, gymTitle, isCardio: gymIsCardio),
      TimelineItem(time: commuteHomeFromGymTime, title: 'Commute Home', icon: '🚗'),
      dinner,
      _chores(choresTime, sleepKiwiCount: choresSleepKiwiCount, blueberryText: choresBlueberryText, nutrition: {}, extraDetails: [
        if (!isRefeedWeek()) 'Scoop 1/3 of tomorrow\'s pasta into a separate container for dinner. The remaining 2/3 stays in the main container for lunch.',
      ]),
      ...extraPostChoresItems,
      _bedPrep(bedPrepTime, hair: bedPrepHair, modifiers: bedPrepModifiers, isHarshActiveNight: isHarshActiveNight),
      _nightSupplement(nightSupplementTime, magAmount: magAmount, skincare: nightSkincare),
      _fallAsleep('10:50-11:20 pm'),
    ];
  }

  // ------------------------------------------
  // Daily Builders
  // ------------------------------------------

  static List<TimelineItem> _buildMonday() => _buildStandardWeekday(
    clothes: 'Get dressed for the gym',
    eggs: 3,
    morningSupplements: {MorningSupplement.zinc},
    amWorkDetails: [_Routines.laundryFaceTowels, 'Run Dishwasher'],
    pmWorkDetails: [_Routines.laundryBathTowels],
    gymTitle: 'Chest, Shoulders & Triceps',
    dinner: _salmonDinner('8:50-9:20 pm', modifiers: {RoutineModifier.cookSalmon}),
    choresSleepKiwiCount: 1,
    bedPrepModifiers: {RoutineModifier.newBathTowel},
    isHarshActiveNight: true,
    magAmount: 3,
    nightSkincare: isWinter() ? _Routines.retinol : _Routines.bha,
  );

  static List<TimelineItem> _buildTuesday() => _buildStandardWeekday(
    clothes: 'Get dressed for work (cloud x 4)',
    morningSupplements: {MorningSupplement.zinc},
    morningBanana: true,
    eatSalmon: true,
    isOfficeDay: true,
    gymTitle: 'Legs (Quads & Calves)',
    dinner: _salmonDinner('8:50-9:20 pm', nutrition: {NutritionAddOn.creatine, NutritionAddOn.copper}),
    choresSleepKiwiCount: 1,
    magAmount: 3,
    nightSkincare: _Routines.joseon,
  );

  static List<TimelineItem> _buildWednesday() => _buildStandardWeekday(
    wakeupNutrition: {NutritionAddOn.nac},
    clothes: 'Get dressed for work (NK 9060/Bondi)',
    morningSupplements: {},
    morningBanana: true,
    eatSalmon: true,
    morningAdditional: '🥩 Take ground beef out of freezer to thaw in fridge',
    isOfficeDay: true,
    preGymStudyTime: '5:10-6:05 pm',
    preGymStudyNutrition: {NutritionAddOn.creatine},
    commuteToGymTime: '6:05-6:15 pm',
    commuteToGymNutrition: {NutritionAddOn.whey},
    gymTime: '6:15-7:25 pm',
    gymTitle: 'Cardio (LISS) / Haircut',
    gymIsCardio: true,
    commuteHomeFromGymTime: '7:25-7:35 pm',
    dinner: _salmonDinner('7:40-8:20 pm', nutrition: const {}),
    choresTime: '8:20-8:50 pm',
    extraPostChoresItems: [
      _study('8:50-9:20 pm', sleepKiwiCount: 1),
      _relaxOrCatchUp('9:20-9:50 pm'),
    ],
    bedPrepHair: 'CeraVe Gentle Shampoo (45s lather)',
    isHarshActiveNight: true,
    magAmount: 2,
    nightSkincare: isWinter() ? _Routines.retinol : _Routines.bha,
  );

  static List<TimelineItem> _buildThursday() => _buildStandardWeekday(
    clothes: 'Get dressed for the gym',
    morningSupplements: {},
    eatSalmon: true,
    amWorkDetails: [_Routines.laundryRegular, 'Run Dishwasher'],
    pmWorkDetails: ['Cook 1lb ground beef (divide in 4, 4 fridge) while working'],
    commuteToGymTime: '5:55-6:20 pm',
    commuteToGymModifiers: {RoutineModifier.takeGymGloves},
    gymTime: '6:20-7:50 pm',
    gymTitle: 'Back, Biceps & Forearms',
    commuteHomeFromGymTime: '7:50-8:20 pm',
    dinner: _beefDinner('8:30-9:00 pm'),
    choresTime: '9:00-9:30 pm',
    choresSleepKiwiCount: 2,
    bedPrepTime: '9:30-10:00 pm',
    bedPrepModifiers: {RoutineModifier.newBathTowel},
    isHarshActiveNight: true,
    nightSupplementTime: '10:00-10:50 pm',
    magAmount: 2,
    nightSkincare: _Routines.bha,
  );

  static List<TimelineItem> _buildFriday() => _buildStandardWeekday(
    clothes: 'Get dressed for work (cloud x 4)',
    morningSupplements: {MorningSupplement.copper},
    morningBanana: true,
    eatBeef: true,
    isOfficeDay: true,
    gymTitle: 'Legs (Hamstrings / Glutes)',
    dinner: _beefDinner('8:50-9:20 pm'),
    choresBlueberryText: 'Eat 1/2 of the box of Blueberries',
    isHarshActiveNight: true,
    magAmount: 3,
    nightSkincare: _Routines.retinol,
  );

  static List<TimelineItem> _buildSaturday() => [
    _wakeup('8:00-8:10 am'),
    _getReady('8:10-8:30 am', skincare: _Routines.morningSkin1004, clothes: 'Get dressed for gym (Hoka Bondi 8)'),
    _morningDine('8:30-9:05 am', additional: '20mg adderall IR', eggs: 4, eatBeef: true, supplements: {MorningSupplement.omega3, MorningSupplement.d3K2, MorningSupplement.vitaminE}, banana: true),
    ..._buildStudyCycle('9:05-10:35 am', '10:35-10:55 am'),
    ..._buildStudyCycle('10:55-12:20 pm', '12:20-12:35 pm', studyNutrition: {}),
    _study('12:35-1:50 pm'),
    _pastaLunch('1:50-2:20 pm'),
    ..._buildStudyCycle('2:20-5:10 pm', '5:10-5:30 pm', studyNutrition: {}),
    _study('5:30-6:20 pm'),
    _commuteToGym('6:20-6:25 pm', reapplySunscreen: _Routines.reapplyHur, nutrition: {}),
    _gym('6:25-7:35 pm', 'Cardio (LISS) / Haircut', isCardio: true),
    TimelineItem(time: '7:35-7:45 pm', title: 'Commute Home', icon: '🚗'),
    _beefDinner('7:45-8:00 pm'),
    _chores('8:00-8:50 pm', blueberryText: 'Eat the rest of the box of Blueberries', nutrition: {}),
    _relaxOrCatchUp('8:50-9:35 pm'),
    _bedPrep('9:35-10:20 pm', hair: 'Nizoral 1% (5m lather)', isHarshActiveNight: true),
    _nightSupplement('10:20-10:35 pm', magAmount: 2, skincare: _Routines.bha, nutrition: {NutritionAddOn.nac}),
    _fallAsleep('10:35-11:05 pm'),
  ];

  static List<TimelineItem> _buildSunday() => [
    _wakeup('8:00-8:10 am'),
    _getReady('8:10-8:30 am', skincare: _Routines.morningSkin1004, clothes: 'Get dressed for shopping (NK 9060)'),
    _morningDine('8:30-9:35 am', eggs: 3, eatBeef: true, supplements: {MorningSupplement.d3K2}, banana: true),
    ..._buildStudyCycle('9:50-11:20 am', '11:20-11:50 am', studyDetails: ['20mg adderall IR at 9:50am'], studyNutrition: {}),
    _study('11:50-1:20 pm'),
    TimelineItem(
      time: '1:20-1:50 pm', 
      title: 'Lunch', 
      icon: '🍛', 
      details: [
        'Eat the last full Ground Beef from fridge', 
        if (isRefeedWeek()) '🍌 2 Medium Bananas (Pre-Workout Boost)'
      ], 
      mealRecord: MealRecord(
        items: [
          if (isRefeedWeek()) const IngredientPortion(ingredient: IngredientsData.banana, amount: 2)
        ], 
        recipeItems: [_Recipes.beef]
      )
    ),
    TimelineItem(
      time: '1:50-4:00 pm', 
      title: 'Grocery Shop & Pick up Chipotle', 
      icon: '🛒', 
      details: [
        _Routines.reapplyHaruharu, 
        'check what I have before going', 
        "Take both your TJ's shopping bags",
        if (isNextWeekRefeedWeek()) '🛒 UPCOMING REFEED WEEK: Buy 21 Bananas (3/day: morning, afternoon snack, dinner), and 1 bag of Quinoa (if out)',
        isRefeedWeek()
            ? 'Pick up Chipotle for dinner (REFEED: Double white rice, DOUBLE black beans, extra fajita veggies - NO SOUR CREAM)'
            : 'Pick up Chipotle for dinner (MINI-REFEED: Double white rice, SINGLE black beans, extra fajita veggies - NO SOUR CREAM)'
      ]
    ),
    TimelineItem(
      time: '4:00-4:30 pm', 
      title: 'Dinner (Eat fresh Chipotle)', 
      icon: '🌯', 
      details: [
        '1 scoop creatine monohydrate (5g)', 
        isRefeedWeek()
            ? 'Chipotle Bowl (REFEED): single chicken, double white rice, DOUBLE black beans, extra fajita veggies (NO SOUR CREAM)'
            : 'Chipotle Bowl (MINI-REFEED): single chicken, double white rice, SINGLE black beans, extra fajita veggies (NO SOUR CREAM)',
        '🥕 Eat 1/7th of a bag (~10 baby carrots)',
        if (isRefeedWeek()) '🍌 1 Medium Banana (REFEED WEEK)',
        if (!isAshwagandhaOff()) '2 cap Ashwagandha',
      ], 
      mealRecord: MealRecord(
        items: [
          _Portions.creatine, 
          IngredientPortion(
            ingredient: isRefeedWeek() ? IngredientsData.chipotleBowlRefeed : IngredientsData.chipotleBowl, 
            amount: 1,
          ),
          if (isRefeedWeek()) const IngredientPortion(ingredient: IngredientsData.banana, amount: 1),
          const IngredientPortion(ingredient: IngredientsData.babyCarrots, amount: 3.4),
          if (!isAshwagandhaOff()) const IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2),
        ], 
        recipeItems: const []
      )
    ),
    TimelineItem(
      time: '4:30-7:30 pm', 
      title: 'Cooking / Meal Prep', 
      icon: '🧑‍🍳', 
      details: [
        'Meal Prep: Pasta (6 portions)', 
        if (isNextWeekRefeedWeek()) '🧑‍🍳 UPCOMING REFEED WEEK: Cook a batch of Quinoa for Mon-Sat dinners (divide into 3 containers)',
        'Put ground beef in freezer',
        'Boil 18 eggs for the week (warm on counter 10m first)'
      ]
    ),
    _relaxOrCatchUp('7:30-8:15 pm'),
    _chores('8:15-8:50 pm', nutrition: {}, extraDetails: ['kiwi @ 8:15-8:20 if box u bought has 6']),
    _bedPrep('8:50-9:50 pm'),
    _nightSupplement('9:50-10:05 pm', magAmount: 2, skincare: _Routines.joseon, nutrition: {NutritionAddOn.nac}),
    _relaxOrCatchUp('10:05-10:50 pm'),
    _fallAsleep('10:50-11:20 pm'),
  ];

  // ------------------------------------------
  // Main Schedules Map
  // ------------------------------------------

  static Map<String, List<TimelineItem>> get schedules => {
    mon: _buildMonday(),
    tue: _buildTuesday(),
    wed: _buildWednesday(),
    thu: _buildThursday(),
    fri: _buildFriday(),
    sat: _buildSaturday(),
    sun: _buildSunday(),
  };
}