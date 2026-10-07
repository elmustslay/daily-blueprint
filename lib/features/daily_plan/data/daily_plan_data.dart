import '../../micro_macro_calorie_track/domain/nutrition.dart';
import '../../micro_macro_calorie_track/data/ingredients_data.dart';
import '../../recipe/data/recipe_data.dart';

class DetailItem {
  final String text;
  final bool isTrackable;
  const DetailItem(this.text, {this.isTrackable = false});
  const DetailItem.trackable(this.text) : isTrackable = true;

  @override
  String toString() => text;
}

class TimelineItem {
  final String time;
  final String title;
  final String icon;
  final List<DetailItem> details;
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
  static const babyCarrotsRegular = IngredientPortion(ingredient: IngredientsData.babyCarrots, amount: 12 / 7);
  static const babyCarrotsLarge = IngredientPortion(ingredient: IngredientsData.babyCarrots, amount: 54 / 7);
  
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
// ROUTINE CONSTANTS & ENUMS
// ==========================================

class _Routines {
  // Skincare Helpers (Reduces duplicate strings)
  static String morningRoutine(String sunscreen) => 
      'Eye Serum FIRST: Gently tap 1 drop of The Ordinary Caffeine Solution across orbital bone -> $sunscreen: Apply face in 2 layers (0.5 finger, wait 30s, 0.5 finger) -> Apply 1 finger for neck -> WAIT 3m';
  static String reapplySunscreen(String sunscreen) => 
      'Wash hands -> Blotting Sheet  -> Wash hands -> $sunscreen: Apply face in 2 layers (0.5 finger, wait 30s, 0.5 finger) -> Apply 1 finger for neck -> WAIT 3m';

  static final String morningSkin1004 = morningRoutine('Skin1004 Centella Sun Serum');
  static final String morningHaruharu = morningRoutine('Haruharu Wonder Sunscreen');
  static final String reapplyHur = reapplySunscreen('House of Hur Sun Fluid');
  static final String reapplyHaruharu = reapplySunscreen('Haruharu Wonder Sunscreen');
  
  static const String retinol = 'Retinol (CRUCIAL: Apply to BONE DRY skin to prevent irritation, STRICTLY AVOID orbital bone/eyelids): 1.5 pumps (0.5 forehead, 0.25 left cheek, 0.25 right cheek, 0.5 neck) -> WAIT 1-2m';
  static const String bha = 'Paula\'s Choice 2% BHA (CRUCIAL: Apply to BONE DRY skin to prevent irritation, AVOID orbital bone): 3 drops (1 forehead, 1 left cheek, 1 right cheek) -> WAIT 1-2m';
  static const String joseon = 'Joseon Alpha-Arbutin (Apply to slightly damp skin, AVOID orbital bone): 4 drops (1 forehead, 1 left cheek, 1 right cheek, 1 neck) -> WAIT 1-2m';

  // Laundry
  static const String laundryFaceTowels = 'Laundry Cycle 1: Bamboo Washcloths & Cotton Pillowcases (3/5 warmness) -> 1-2 tbsp All Free Clear (Liquid). NO Fabric Softener (Dry on LOW heat)';
  static const String laundryBathTowels = 'Laundry Cycle 2: Bath Towels & Body Washcloths (5/5 warmness) -> Wash 1: 2 tbsp All Free Clear (Liquid) + 1/3 cup Bleach -> Wash 2: Full Cycle (WATER ONLY - no detergent) to lift bleach residue (Dry on LOW heat)';
  static const String laundryRegular = 'Laundry: Regular Wash (All other clothes/gym gear, 3/5 warmness) -> All Free Clear (Liquid)';
}

enum ProteinSource { salmon, beef, none }
enum MorningSupplement { omega3, d3K2, vitaminE, zinc, copper }
enum NutritionAddOn { whey, creatine, calcium, copper, nac, banana, postWorkoutBanana, midMorningBanana, preWorkoutBanana }
enum RoutineModifier { caffeine, sparklingWater, standingDesk, cookSalmon, takeSunscreen, takeGymGloves, newBathTowel }

// ==========================================
// CONFIGURATION CLASSES
// ==========================================

class GymConfig {
  final String title;
  final String time;
  final String commuteTime;
  final String commuteHomeTime;
  final bool isCardio;
  final bool isResistance;
  final Set<RoutineModifier> modifiers;
  final Set<NutritionAddOn> commuteNutrition;
  final String? preGymStudyTime;
  final bool isWednesday;
  final Set<NutritionAddOn> preGymStudyNutrition;

  const GymConfig({
    required this.title,
    this.time = '6:30-8:00 pm',
    this.commuteTime = '5:55-6:30 pm',
    this.commuteHomeTime = '8:00-8:30 pm',
    this.isCardio = false,
    this.isResistance = true,
    this.modifiers = const {},
    this.commuteNutrition = const {NutritionAddOn.whey},
    this.isWednesday = false,
    this.preGymStudyTime,
    this.preGymStudyNutrition = const {NutritionAddOn.preWorkoutBanana},
  });
}

class ChoresConfig {
  final String time;
  final int sleepKiwiCount;
  final String blueberryText;
  final List<TimelineItem> extraPostChoresItems;

  const ChoresConfig({
    this.time = '9:20-9:50 pm',
    this.sleepKiwiCount = 0,
    this.blueberryText = '',
    this.extraPostChoresItems = const [],
  });
}

class BedPrepConfig {
  final String time;
  final String hair;
  final Set<RoutineModifier> modifiers;
  final bool isHarshActiveNight;
  final String nightSupplementTime;

  const BedPrepConfig({
    this.time = '9:50-10:20 pm',
    this.hair = '60s warm massage',
    this.modifiers = const {},
    this.isHarshActiveNight = false,
    this.nightSupplementTime = '10:20-10:50 pm',
  });
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

  // DELOAD WINDOWS (7 days each, decoupled from refeed weeks which are disabled).
  // Starts Thursday so all 4 lifting sessions (Thu, Fri, Mon, Tue) get deloaded exactly once.
  //  - Oct 8:  ~10 weeks of hard training in a deficit -> performance dip (glycogen-limited, not CNS)
  //  - Dec 3:  8 weeks later; ~2 weeks pre-Addis so you arrive recovered, un-inflamed & full-looking
  static final List<DateTime> deloadStartDates = [
    DateTime(2026, 10, 8),
    DateTime(2026, 12, 3),
  ];

  static bool isDeloadWeek() {
    final now = mockCurrentDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return deloadStartDates.any((s) =>
        !today.isBefore(s) && today.isBefore(DateTime(s.year, s.month, s.day + 7)));
  }

  static String get deloadProtocolText =>
      '🔴 DELOAD WEEK — Intensity-Preservation\n'
      'Drop fatigue, not intensity. Heavy load keeps telling your body to hold onto muscle while the deficit continues; cutting volume lets the accumulated fatigue clear.\n\n'
      '━━━━━━━━━━━━━━━━━━━━\n'
      'LIFTING (Mon / Tue / Thu / Fri):\n'
      '━━━━━━━━━━━━━━━━━━━━\n'
      '• Keep your working weight the SAME (100%)\n'
      '• Cut your sets roughly in half (4 → 2, 3 → 2)\n'
      '• Keep the same rep ranges and rest periods\n'
      '• Stop 2-3 reps short of failure (RPE 7) on EVERY set (isolations too)\n'
      '• Zero forced reps, partials, or drop sets\n'
      '• Skip warm-up feeder sets beyond what you need to feel ready\n\n'
      'Example:\n'
      '  Normally Leg Press 200 lbs × 4 sets to failure\n'
      '  → This week: 200 lbs × 2 sets (stopping 2-3 reps early)\n\n'
      '━━━━━━━━━━━━━━━━━━━━\n'
      'ABS (Crunch Machine / Bicycle Crunches):\n'
      '━━━━━━━━━━━━━━━━━━━━\n'
      '• 2 sets each, stop a few reps short of failure\n\n'
      '━━━━━━━━━━━━━━━━━━━━\n'
      'CARDIO (Wed / Sat):\n'
      '━━━━━━━━━━━━━━━━━━━━\n'
      '• Keep your ${isRefeedWeek() ? "40-minute" : "1-hour"} LISS exactly the same and stay in your HR zone.\n'
      '• Zone 2 walking barely taxes recovery, so no deload needed here.\n\n'
      '━━━━━━━━━━━━━━━━━━━━\n'
      'NUTRITION & SUPPLEMENTS:\n'
      '━━━━━━━━━━━━━━━━━━━━\n'
      '• Same food plan, same protein — do NOT eat extra (the sim showed it costs fat, not muscle)\n'
      '• Keep creatine at 5g/day (never cycle it)\n'
      '• Feeling hungrier or restless is normal — hold the line\n\n'
      'AFTER THE DELOAD:\n'
      '• Compounds (Tier 1): stop 1-2 reps short of failure\n'
      '• Isolations: failure on the LAST set only\n\n'
      '⚡ Clear the fatigue. Keep the muscle. Trust the math.';

  static bool shouldScaleUpCardio() => currentWeekNumber >= 17;
  static bool isBloodDonationWeek() => currentWeekNumber > 0 && currentWeekNumber % 22 == 0;

  static bool isWinter() {
    final now = mockCurrentDate ?? DateTime.now();
    if (now.month == 11 && now.day >= 15) return true;
    if (now.month == 12 || now.month == 1 || now.month == 2) return true;
    if (now.month == 3 && now.day <= 15) return true;
    return false;
  }

  static bool isAshwagandhaOff() {
    if (currentWeekNumber == 0) return false;
    return ((currentWeekNumber - 1) % 12) + 1 > 8;
  }

  static bool isRefeedWeek() { // no more refeed weeks
    if (currentWeekNumber != -1) return false;
    return currentWeekNumber == 5 || currentWeekNumber == 12 || currentWeekNumber == 18;
  }

  static bool isNextWeekRefeedWeek() {
    if (currentWeekNumber != -1) return false;
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
    final bananaCount = isRefeedWeek() ? 1 : 0;
    return TimelineItem(
      time: time,
      title: 'Wakeup',
      icon: '☀️',
      details: [
        const DetailItem('Use bathroom'),
        const DetailItem.trackable('Weight (Step on scale)'),
        const DetailItem('Drink ~25oz water (Mix in 0.25 tsp Salt to restore blood volume)'),
        if (bananaCount > 0) DetailItem('🍌 REFEED WEEK: Eat $bananaCount Medium Banana'),
        if (nac) const DetailItem.trackable('Take 600mg NAC + 25mcg Selenium (Combo Pill)'),
        const DetailItem.trackable('Take 250mg Citicoline (w/ 25mg Tyrosine)'),
      ],
      mealRecord: MealRecord(items: [
        if (bananaCount > 0) IngredientPortion(ingredient: IngredientsData.banana, amount: bananaCount.toDouble()),
        if (nac) const IngredientPortion(ingredient: IngredientsData.nac, amount: 1),
        const IngredientPortion(ingredient: IngredientsData.citicoline, amount: 1),
        const IngredientPortion(ingredient: IngredientsData.iodizedTableSalt, amount: 0.25),
      ]),
    );
  }

  static TimelineItem _getReady(String time, {required String skincare, required String clothes}) {
    return TimelineItem(
      time: time,
      title: 'Get Ready',
      icon: '🧼',
      details: [
        const DetailItem('Brush teeth (Colgate Optic White) -> Spit, do not rinse. Wait 30m before drinking.'),
        const DetailItem('Blotting Sheet: Use 2-3 sheets to absorb heavy overnight sebum'),
        const DetailItem('Gently splash face/neck with water for 5-10s to rinse off overnight sweat'),
        const DetailItem('Pat dry with new bamboo baby washcloth'),
        const DetailItem('Ascorbyl 12% (Apply to slightly damp skin, AVOID orbital bone): 5 drops (1 forehead, 1 left cheek, 1 right cheek, 2 neck)'),
        const DetailItem('WAIT 90s'),
        DetailItem(skincare),
        DetailItem(clothes),
      ],
    );
  }

  static TimelineItem _morningDine(String time, {
    String additional = '', 
    int eggs = 3, 
    Set<MorningSupplement> supplements = const { MorningSupplement.omega3 },
    ProteinSource protein = ProteinSource.none,
    int bananaCount = 0,
    bool isResistanceDay = true,
  }) {
    final omega3 = supplements.contains(MorningSupplement.omega3);
    final useD3K2 = supplements.contains(MorningSupplement.d3K2);
    final vitaminE = supplements.contains(MorningSupplement.vitaminE);
    final zinc = supplements.contains(MorningSupplement.zinc);
    final copper = supplements.contains(MorningSupplement.copper);
    final extraRefeedBanana = isResistanceDay && isRefeedWeek();
    final totalBananaCount = bananaCount + (extraRefeedBanana ? 1 : 0);

    return TimelineItem(
      time: time,
      title: 'Morning Dine',
      icon: '🍳',
      details: [
        const DetailItem('Eat in front of Verilux HappyLight (45-degree angle to face):'),
        if (totalBananaCount > 0) DetailItem('🍌 Eat $totalBananaCount Medium Banana${totalBananaCount > 1 ? "s" : ""}'),
        if (protein == ProteinSource.salmon) const DetailItem('Finish leftover 0.5 portion of Salmon (from fridge)'),
        if (protein == ProteinSource.beef) const DetailItem('Finish leftover 0.5 portion of Ground Beef (from fridge)'),
        if (eggs > 0) DetailItem('$eggs Boiled Eggs'),
        if (omega3) const DetailItem.trackable('3 softgel omega-3'),
        if (useD3K2) const DetailItem.trackable('1 D3-K2'),
        if (useD3K2) const DetailItem.trackable('1 standalone K2 (100mcg)') else const DetailItem.trackable('2 standalone K2 (100mcg each)'),
        const DetailItem.trackable('1 cap Biotin+Keratin (10mg/500mg)'),
        if (vitaminE) const DetailItem.trackable('1 softgel Vitamin E (267mg)'),
        if (zinc) const DetailItem.trackable('1 cap Zinc Picolinate (30mg)'),
        if (copper) const DetailItem.trackable('1 cap Copper Glycinate (3mg)'),
        const DetailItem('Swish/drink water after eating/drinking to clear mouth'),
        if (additional.isNotEmpty) DetailItem(additional),
      ],
      mealRecord: MealRecord(
        items: [
          if (totalBananaCount > 0) IngredientPortion(ingredient: IngredientsData.banana, amount: totalBananaCount.toDouble()),
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
          if (protein == ProteinSource.salmon) _Recipes.salmonHalf,
          if (protein == ProteinSource.beef) _Recipes.beefHalf,
        ]
      ),
    );
  }

  static TimelineItem _grabThings(String time, {String additional = '', Set<RoutineModifier> modifiers = const {RoutineModifier.takeSunscreen}}) {
    final takeSunscreen = modifiers.contains(RoutineModifier.takeSunscreen);
    return TimelineItem(
      time: time,
      title: 'Grab things to take to work',
      icon: '🗂️',
      details: [
        const DetailItem('kindle/laptop'),
        const DetailItem('2 key/wallet/phone'),
        const DetailItem('airpods'),
        const DetailItem('apple watch'),
        if (takeSunscreen) const DetailItem('Haruharu Wonder Sunscreen'),
        if (takeSunscreen) const DetailItem('Oil-Absorbing Blotting Sheets'),
        const DetailItem('Pasta lunch'),
        const DetailItem('water bottle'),
        if (additional.isNotEmpty) DetailItem(additional),
      ],
    );
  }

  static TimelineItem _commuteToWork(String time) => TimelineItem(time: time, title: 'Commute to Work', icon: '🚗');

  static TimelineItem _work(String time, {
    List<DetailItem> details = const [], 
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
    final bananaCount = (banana ? 1 : 0) + (midMorningBanana ? 1 : 0);

    return TimelineItem(
      time: time, 
      title: title, 
      icon: '💻', 
      details: [
        if (caffeine) const DetailItem.trackable('☕️ Drink Caffeine around 9:30 am'),
        if (sparklingWater) const DetailItem('Drink Sparkling Water'),
        if (standingDesk && !isRefeedWeek()) const DetailItem('🧍‍♂️ Use Standing Desk for 3-4 hours'),
        if (midMorningBanana) const DetailItem('🍌 11:30 am: Eat 1 Medium Banana (Mid-Morning)'),
        if (banana) const DetailItem('🍌 4:30 pm: Eat 1 Medium Banana (Afternoon Snack)'),
        if (afternoonSunscreen != null) DetailItem('4:00 pm Touch-up: $afternoonSunscreen'),
        ...details
      ],
      mealRecord: (bananaCount > 0) ? MealRecord(items: [
        IngredientPortion(ingredient: IngredientsData.banana, amount: bananaCount.toDouble()),
      ]) : null,
    );
  }

  static TimelineItem _pastaLunch(String time, {int extraBananas = 0, bool isFullPastaDay = false, String bananaReason = 'Refeed Carb Load'}) {
    final isFullLunch = isRefeedWeek() || isFullPastaDay;
    return TimelineItem(
      time: time,
      title: 'Lunch',
      icon: '🍝',
      details: [
        if (isFullLunch) const DetailItem('1 full serving of my pasta') else const DetailItem('2/3 serving of my pasta'),
        if (extraBananas > 0) DetailItem('🍌 Eat $extraBananas Medium Banana${extraBananas > 1 ? "s" : ""} ($bananaReason)'),
      ],
      mealRecord: MealRecord(
        items: [
          if (extraBananas > 0) IngredientPortion(ingredient: IngredientsData.banana, amount: extraBananas.toDouble()),
        ],
        recipeItems: [if (isFullLunch) _Recipes.pasta else _Recipes.pastaTwoThirds],
      ),
    );
  }

  static TimelineItem _study(String time, {
    List<DetailItem> details = const [],
    int sleepKiwiCount = 0,
    Set<NutritionAddOn> nutrition = const {},
  }) {
    final banana = nutrition.contains(NutritionAddOn.banana);
    final midMorningBanana = nutrition.contains(NutritionAddOn.midMorningBanana);
    final preWorkoutBanana = nutrition.contains(NutritionAddOn.preWorkoutBanana);
    final bananaCount = (banana ? 1 : 0) + (midMorningBanana ? 1 : 0) + (preWorkoutBanana ? 1 : 0);
    final withCreatine = nutrition.contains(NutritionAddOn.creatine);

    return TimelineItem(
      time: time,
      title: 'Study Time',
      icon: '📚',
      details: [
        if (withCreatine) const DetailItem.trackable('🥤 Pre-Workout Shake: 1 scoop creatine monohydrate (5g)'),
        ...details,
        if (midMorningBanana) const DetailItem('🍌 11:30 am: Eat 1 Medium Banana (Mid-Morning)'),
        if (banana) const DetailItem('🍌 4:30 pm: Eat 1 Medium Banana (Afternoon Snack)'),
        if (preWorkoutBanana) const DetailItem('🍌 Eat 1 Medium Banana (Pre-Workout Phase 1)'),
        if (sleepKiwiCount > 0) DetailItem('Halfway through (~1hr before sleep): Eat $sleepKiwiCount Kiwi${sleepKiwiCount > 1 ? "s" : ""} & swish water (brush 20 min after)'),
      ],
      mealRecord: (sleepKiwiCount > 0 || bananaCount > 0 || withCreatine) ? MealRecord(items: [
        if (withCreatine) _Portions.creatine,
        if (bananaCount > 0) IngredientPortion(ingredient: IngredientsData.banana, amount: bananaCount.toDouble()),
        if (sleepKiwiCount > 0) IngredientPortion(ingredient: IngredientsData.kiwi, amount: sleepKiwiCount.toDouble()),
      ]) : null,
    );
  }

  static TimelineItem _relaxOrCatchUp(String time, {String title = 'Relax / Catch up on reading', String icon = '🛋️'}) {
    return TimelineItem(time: time, title: title, icon: icon);
  }

  static TimelineItem _commuteToGym(String time, {String? reapplySunscreen, Set<RoutineModifier> modifiers = const {}, Set<NutritionAddOn> nutrition = const {}, bool isResistanceDay = true}) {
    final takeGymGloves = modifiers.contains(RoutineModifier.takeGymGloves);
    final withWhey = nutrition.contains(NutritionAddOn.whey);
    final preWorkoutBananaCount = (isResistanceDay || isRefeedWeek()) ? (isRefeedWeek() ? 3 : 2) : 0;
    
    return TimelineItem(
      time: time,
      title: 'Get Dressed & Commute to Gym${isResistanceDay ? " (Resistance)" : " (LISS)"}',
      icon: '🚗',
      details: [
        const DetailItem('Get dressed for gym'),
        if (isResistanceDay) const DetailItem.trackable('🧂 Mix 0.33 tsp Table Salt (electrolytes) in 21oz water bottle and drink it (front load)')
        else const DetailItem('💧 Drink one 21oz water bottle'),
        if (preWorkoutBananaCount > 0) DetailItem('🍌 Eat $preWorkoutBananaCount Medium Bananas (Pre-Workout) literally right before walking out the door (digests during commute)'),
        if (withWhey) const DetailItem('🥤 Mix 1 scoop whey isolate (30g protein) in shaker bottle with water and ice (leave in car for later)'),
        if (reapplySunscreen != null) DetailItem(reapplySunscreen),
        if (takeGymGloves) const DetailItem('🧤 Grab Gym Gloves'),
      ],
      mealRecord: (preWorkoutBananaCount > 0 || isResistanceDay) ? MealRecord(items: [
        if (preWorkoutBananaCount > 0) IngredientPortion(ingredient: IngredientsData.banana, amount: preWorkoutBananaCount.toDouble()),
        if (isResistanceDay) const IngredientPortion(ingredient: IngredientsData.iodizedTableSalt, amount: 0.33),
      ]) : null,
    );
  }

  static TimelineItem _commuteHomeFromGym(String time, {Set<NutritionAddOn> nutrition = const {}}) {
    final withWhey = nutrition.contains(NutritionAddOn.whey);
    return TimelineItem(
      time: time,
      title: 'Commute Home',
      icon: '🚗',
      details: [
        if (withWhey) const DetailItem.trackable('🥤 Drink the whey isolate shake on commute home.'),
      ],
      mealRecord: withWhey ? MealRecord(items: [
        _Portions.whey,
      ]) : null,
    );
  }

  static TimelineItem _gym(String time, String title, {bool isCardio = false, bool isWednesday = false}) {
    if (isCardio && isRefeedWeek()) {
      return TimelineItem(
        time: time,
        title: 'Recovery Walk / Haircut (Refeed)',
        icon: '🚶‍♂️',
        details: [
          DetailItem(isWednesday 
            ? 'Check weekly steps: If you are UNDER 15k steps so far, do a Zone 1 Recovery Walk (< 120bpm). Otherwise, skip LISS and rest!'
            : 'Check weekly steps: If you are UNDER 26k steps for the week (assuming 1k tomorrow), do a Zone 1 Recovery Walk (< 120bpm) to hit your 27k target. Otherwise, rest!')
        ],
        isCardio: true,
      );
    }
    return TimelineItem(time: time, title: title, icon: isCardio ? '🏃' : '🏋️', isCardio: isCardio);
  }

  static TimelineItem _salmonDinner(String time, {Set<RoutineModifier> modifiers = const {}, Set<NutritionAddOn> nutrition = const {NutritionAddOn.creatine}, bool withCreatine = false, bool isFullPastaDay = false, bool largeCarrots = false}) {
    final effectiveWithCreatine = nutrition.contains(NutritionAddOn.creatine) || withCreatine;
    final copper = nutrition.contains(NutritionAddOn.copper);
    final cook = modifiers.contains(RoutineModifier.cookSalmon);
    final showAshwagandha = !isAshwagandhaOff();
    final eatPastaThird = !isRefeedWeek() && !isFullPastaDay;
    
    return TimelineItem(
      time: time,
      title: 'Dinner',
      icon: '🥗',
      details: [
        if (effectiveWithCreatine) const DetailItem.trackable('1 scoop creatine monohydrate (5g)'),
        if (copper) const DetailItem.trackable('Take 1 cap Copper Glycinate (3mg)'),
        if (cook) const DetailItem('Cook Salmon (3 portions): start 1st portion (eat 1/2, save 1/2 in fridge)') else const DetailItem('Start a new portion of Salmon (eat 1/2, save other 1/2 in fridge)'), 
        DetailItem(largeCarrots ? '🥕 Eat 32% of bag (54/7 oz, ~31 baby carrots)' : '🥕 Eat 7% of bag (12/7 oz, ~7 baby carrots)'),
        if (eatPastaThird) const DetailItem('1/3 serving of my pasta'),
        if (showAshwagandha) const DetailItem.trackable('2 cap Ashwagandha'),
        if (isRefeedWeek()) const DetailItem('🍚 REFEED WEEK: Include 0.5 cups (dry) cooked Quinoa'),
      ],
      mealRecord: MealRecord(
        items: [
          if (effectiveWithCreatine) _Portions.creatine,
          if (copper) const IngredientPortion(ingredient: IngredientsData.copperGlycinate, amount: 1),
          largeCarrots ? _Portions.babyCarrotsLarge : _Portions.babyCarrotsRegular,
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

  static TimelineItem _beefDinner(String time, {int extraBananas = 0, bool isFullPastaDay = false, bool largeCarrots = false}) {
    final showAshwagandha = !isAshwagandhaOff();
    final eatPastaThird = !isRefeedWeek() && !isFullPastaDay;
    return TimelineItem(
      time: time,
      title: 'Dinner',
      icon: '🍛',
      details: [
        const DetailItem.trackable('1 scoop creatine monohydrate (5g)'),
        const DetailItem('Start a new portion of Ground Beef (eat 1/2, save other 1/2 in fridge)'), 
        DetailItem(largeCarrots ? '🥕 Eat 32% of bag (54/7 oz, ~31 baby carrots)' : '🥕 Eat 7% of bag (12/7 oz, ~7 baby carrots)'),
        if (eatPastaThird) const DetailItem('1/3 serving of my pasta'),
        if (showAshwagandha) const DetailItem.trackable('2 cap Ashwagandha'),
        if (isRefeedWeek()) const DetailItem('🍚 REFEED WEEK: Include 0.5 cups (dry) cooked Quinoa'),
        if (extraBananas > 0) DetailItem('🍌 Eat $extraBananas Medium Bananas (Post-Workout Carb Load)'),
      ],
      mealRecord: MealRecord(
        items: [
          _Portions.creatine,
          largeCarrots ? _Portions.babyCarrotsLarge : _Portions.babyCarrotsRegular,
          if (showAshwagandha) const IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2),
          if (extraBananas > 0) IngredientPortion(ingredient: IngredientsData.banana, amount: extraBananas.toDouble()),
        ], 
        recipeItems: [
          _Recipes.beefHalf,
          if (eatPastaThird) _Recipes.pastaThird,
          if (isRefeedWeek()) _Recipes.quinoa,
        ]
      ),
    );
  }

  static TimelineItem _chores(String time, {int sleepKiwiCount = 0, String blueberryText = '', Set<NutritionAddOn> nutrition = const {}, List<DetailItem> extraDetails = const []}) {
    return TimelineItem(
      time: time,
      title: 'Chores & Clean Up',
      icon: '🧼',
      details: [
        const DetailItem('1 scoop Casein + 1 pill Colace (100mg Docusate Sodium) in 16oz water -> Swish/drink water after'),
        const DetailItem('The 7 bottles water are separate from this. This is in addition to that. So 7 bottles + this.'),
        if (sleepKiwiCount > 0) DetailItem('Eat $sleepKiwiCount Kiwi${sleepKiwiCount > 1 ? "s" : ""} now (~1hr before sleep) & swish water (brush 20 min after)'),
        if (blueberryText.isNotEmpty) DetailItem('🫐 $blueberryText'),
        ...extraDetails,
        const DetailItem('📱 Final check of phone/messages before Screen Curfew starts.'),
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
        const DetailItem('📱 SCREEN CURFEW: Dim bathroom and bedroom lights. Put phone on charger across the room (No more screens tonight).'),
        if (newBathTowel) const DetailItem('🛑 Grab a FRESH Bath Towel for the new rotation; skip the bamboo!'),
        const DetailItem('Brush teeth (Boka nHAp) -> Spit, DO NOT rinse. (Mental cue: Keep mouth CLOSED in shower!)'),
        const DetailItem('Pre-Shower: Gently massage 2-3 pumps Cleansing Oil on DRY face (MAX 45s CRUCIAL - do not over-rub) to melt sunscreen/sweat'),
        const DetailItem('In-Shower: Wet hands, rub face/neck/ears to emulsify oil (15-20s) -> Rinse thoroughly'),
        DetailItem('Hair: $hair'),
        const DetailItem('Body: Hold Washcloth under water until SOAKING wet. Apply Dove Deep Moisture Body Wash into cloth and rub together to build a rich foam cushion. Gently sweep foamy cloth over upper and lower body (for frictionless gym maintenance)'),
        DetailItem('Face: Lather 1 pump of ${isWinter() || isHarshActiveNight ? "Lipikar AP+ (Barrier Shield)" : "Vanicream Gentle Cleanser"} in wet hands for 3-4s to build foam. Gently glide foam onto face/neck/ears with LUKEWARM water (CRUCIAL: NO HOT WATER) for EXACTLY 30s (then rinse)'),
        const DetailItem('Finish: Hot rinse to raise skin temperature (helps drop core body temp afterward for sleep onset)'),
        newBathTowel
            ? const DetailItem('Pat face & beard completely dry with the FRESH Bath Towel (Do Skincare immediately while bathroom is humid, before drying your body)')
            : const DetailItem('Pat face & beard completely dry with a new bamboo baby washcloth (Do Skincare immediately while bathroom is humid)'),
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
        const DetailItem('📖 WIND DOWN: Read a physical book, use a Kindle (warm light/dark mode), or stretch. strictly NO phone scrolling or videos.'),
        DetailItem(skincare),
        const DetailItem('Underarms: Ensure pits are BONE DRY -> Moisturize with face moisturizer (Vanicream Daily Facial) -> WAIT to dry -> Apply 5% AHA Deodorant'),
        const DetailItem('Eye Serum FIRST: Gently tap 1 drop of The Ordinary Caffeine Solution across orbital bone'),
        const DetailItem('Moisturizer (Cetaphil Hydrating Lotion): Apply 1.5 pumps for face, 1.5 pumps for neck, and 0.5 pumps for ears, then rub in -> WAIT to dry'),
        DetailItem.trackable('Take $magAmount Magnesium Glycinate + 1 tablet Finasteride (1mg)'),
        if (nac) const DetailItem.trackable('Take 600mg NAC + 25mcg Selenium (Combo Pill)'),
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
        const DetailItem('📝 Brain dump: Write down your to-do list for tomorrow on paper so you aren\'t thinking about it in bed.'),
        const DetailItem('🌡️ Ensure room temperature drops to ~65°F (18°C) to facilitate sleep onset.'),
        const DetailItem('Lights completely out (pitch black). Close eyes and allow sleep to happen naturally.'),
      ],
    );
  }

  // ------------------------------------------
  // Study Cycle Helper (Weekend)
  // ------------------------------------------

  static List<TimelineItem> _buildStudyCycle(String studyTime, String restTime, {
    List<DetailItem> studyDetails = const [],
    Set<NutritionAddOn> studyNutrition = const {},
  }) => [
    _study(studyTime, details: studyDetails, nutrition: studyNutrition),
    TimelineItem(time: restTime, title: 'Diffuse Brain Rest', icon: '🧠', details: [const DetailItem('NO PHONE. Relax or nap on bed/chair. Close eyes and allow memory consolidation.')]),
  ];

  // ------------------------------------------
  // Standard Weekday Template
  // ------------------------------------------

  static List<TimelineItem> _buildStandardWeekday({
    required String clothes,
    required TimelineItem dinner,
    required GymConfig gym,
    required int magAmount,
    required String nightSkincare,
    bool isOfficeDay = false,
    ProteinSource morningProtein = ProteinSource.none,
    int eggs = 2,
    Set<MorningSupplement> morningSupplements = const {},
    int morningBanana = 0,
    String morningAdditional = '',
    String? morningSkincare,
    List<DetailItem> amWorkDetails = const [],
    List<DetailItem> pmWorkDetails = const [],
    Set<NutritionAddOn> pmWorkNutrition = const {},
    ChoresConfig chores = const ChoresConfig(),
    BedPrepConfig bedPrep = const BedPrepConfig(),
    Set<NutritionAddOn> wakeupNutrition = const {},
    int lunchExtraBananas = 0,
    String grabThingsAdditional = '',
    bool isFullPastaDay = false,
    bool prepTomorrowPasta = true,
  }) {
    final effectiveSkincare = morningSkincare ??
        (isOfficeDay ? _Routines.morningHaruharu : _Routines.morningSkin1004);
    final effectiveStudyTime = gym.preGymStudyTime ??
        (isOfficeDay ? '5:10-5:55 pm' : '5:00-5:55 pm');
    final effectiveSunscreen = isOfficeDay ? _Routines.reapplyHaruharu : _Routines.reapplyHur;

    return [
      _wakeup('8:00-8:10 am', nutrition: wakeupNutrition),
      _morningDine(
        '8:10-8:30 am', 
        eggs: eggs, 
        supplements: morningSupplements, 
        bananaCount: morningBanana, 
        protein: morningProtein, 
        additional: morningAdditional, 
        isResistanceDay: gym.isResistance
      ),
      _getReady('8:30-8:50 am', skincare: effectiveSkincare, clothes: clothes),
      if (isOfficeDay) _grabThings('8:50-8:55 am', additional: grabThingsAdditional),
      if (isOfficeDay) _commuteToWork('8:55-9:00 am'),
      _work(
        isOfficeDay ? '9:00-1:00 pm' : '8:50-1:00 pm', 
        details: amWorkDetails, 
        modifiers: isOfficeDay ? {RoutineModifier.caffeine, RoutineModifier.sparklingWater, RoutineModifier.standingDesk} : {}, 
        nutrition: {}
      ),
      _pastaLunch('1:00-1:30 pm', extraBananas: lunchExtraBananas, isFullPastaDay: isFullPastaDay),
      _work(
        '1:30-5:00 pm', 
        details: pmWorkDetails, 
        modifiers: isOfficeDay ? {RoutineModifier.sparklingWater, RoutineModifier.standingDesk} : {}, 
        nutrition: pmWorkNutrition, 
        afternoonSunscreen: effectiveSunscreen
      ),
      if (isOfficeDay) TimelineItem(time: '5:00-5:10 pm', title: 'Commute Home', icon: '🚗'),
      _study(effectiveStudyTime, details: [const DetailItem('Study (Beat traffic before gym)')], nutrition: gym.preGymStudyNutrition),
      _commuteToGym(
        gym.commuteTime, 
        nutrition: gym.commuteNutrition, 
        modifiers: gym.modifiers, 
        isResistanceDay: gym.isResistance
      ),
      _gym(gym.time, gym.title, isCardio: gym.isCardio, isWednesday: gym.isWednesday),
      _commuteHomeFromGym(gym.commuteHomeTime, nutrition: gym.commuteNutrition),
      dinner,
      _chores(
        chores.time, 
        sleepKiwiCount: chores.sleepKiwiCount, 
        blueberryText: chores.blueberryText, 
        nutrition: {}, 
        extraDetails: [
          if (!isRefeedWeek() && prepTomorrowPasta) const DetailItem('Scoop 1/3 of tomorrow\'s pasta into a separate container for dinner. The remaining 2/3 stays in the main container for lunch.'),
        ]
      ),
      ...chores.extraPostChoresItems,
      _bedPrep(bedPrep.time, hair: bedPrep.hair, modifiers: bedPrep.modifiers, isHarshActiveNight: bedPrep.isHarshActiveNight),
      _nightSupplement(bedPrep.nightSupplementTime, magAmount: magAmount, skincare: nightSkincare),
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
    amWorkDetails: [DetailItem(_Routines.laundryFaceTowels), const DetailItem('Run Dishwasher')],
    pmWorkDetails: [DetailItem(_Routines.laundryBathTowels)],
    gym: const GymConfig(title: 'Chest, Shoulders & Triceps'),
    dinner: _salmonDinner('8:50-9:20 pm', modifiers: {RoutineModifier.cookSalmon}),
    chores: const ChoresConfig(sleepKiwiCount: 2),
    bedPrep: const BedPrepConfig(modifiers: {RoutineModifier.newBathTowel}, isHarshActiveNight: true),
    magAmount: 3,
    nightSkincare: _Routines.bha,
  );

  static List<TimelineItem> _buildTuesday() => _buildStandardWeekday(
    clothes: 'Get dressed for work (cloud x 4)',
    morningSupplements: {MorningSupplement.zinc},
    morningBanana: 1,
    morningProtein: ProteinSource.salmon,
    isOfficeDay: true,
    gym: const GymConfig(title: 'Legs (Quads & Calves)'),
    dinner: _salmonDinner('8:50-9:20 pm', nutrition: {NutritionAddOn.creatine, NutritionAddOn.copper}),
    chores: const ChoresConfig(sleepKiwiCount: 2),
    magAmount: 3,
    nightSkincare: _Routines.joseon,
  );

  static List<TimelineItem> _buildWednesday() => _buildStandardWeekday(
    wakeupNutrition: {NutritionAddOn.nac},
    clothes: 'Get dressed for work (NK 9060/Bondi)',
    morningBanana: 1,
    morningProtein: ProteinSource.salmon,
    morningAdditional: '🥩 Take ground beef out of freezer to thaw in fridge',
    isOfficeDay: true,
    gym: const GymConfig(
      title: 'Cardio (LISS) / Haircut',
      time: '6:15-7:25 pm',
      commuteTime: '6:05-6:15 pm',
      commuteHomeTime: '7:25-7:35 pm',
      isCardio: true,
      isResistance: false,
      isWednesday: true,
      preGymStudyTime: '5:10-6:05 pm',
      preGymStudyNutrition: {NutritionAddOn.creatine},
    ),
    dinner: _salmonDinner('7:40-8:20 pm', nutrition: const {}),
    chores: ChoresConfig(
      time: '8:20-8:50 pm',
      extraPostChoresItems: [
        _study('8:50-9:20 pm'),
        _relaxOrCatchUp('9:20-9:50 pm'),
      ],
    ),
    bedPrep: const BedPrepConfig(
      hair: 'CeraVe Gentle Shampoo (45s lather)',
      isHarshActiveNight: true,
    ),
    magAmount: 2,
    nightSkincare: _Routines.retinol,
    prepTomorrowPasta: false, // Tomorrow (Thursday) is a full pasta day
  );

  static List<TimelineItem> _buildThursday() => _buildStandardWeekday(
    lunchExtraBananas: 1,
    clothes: 'Get dressed for the gym',
    morningProtein: ProteinSource.salmon,
    amWorkDetails: [DetailItem(_Routines.laundryRegular), const DetailItem('Run Dishwasher')],
    pmWorkDetails: [const DetailItem('Cook 1lb ground beef (divide in 4, 4 fridge) while working')],
    gym: const GymConfig(
      title: 'Back, Biceps & Forearms',
      time: '6:20-7:50 pm',
      commuteTime: '5:55-6:20 pm',
      commuteHomeTime: '7:50-8:20 pm',
      modifiers: {RoutineModifier.takeGymGloves},
    ),
    dinner: _beefDinner('8:30-9:00 pm', extraBananas: 3, isFullPastaDay: true, largeCarrots: true), // 4 -> 3: 4th banana moved to Sat lunch (refeed still > 200g net carbs)
    chores: const ChoresConfig(time: '9:00-9:30 pm', sleepKiwiCount: 2),
    bedPrep: const BedPrepConfig(
      time: '9:30-10:00 pm',
      modifiers: {RoutineModifier.newBathTowel},
      nightSupplementTime: '10:00-10:50 pm',
    ),
    magAmount: 2,
    nightSkincare: _Routines.joseon,
    isFullPastaDay: true, // Full pasta at lunch, 0 at dinner
    prepTomorrowPasta: false, // Tomorrow (Friday) is a full pasta day
  );

  static List<TimelineItem> _buildFriday() => _buildStandardWeekday(
    grabThingsAdditional: '🍌 Pack 1 Banana for lunch!',
    lunchExtraBananas: 1,
    clothes: 'Get dressed for work (cloud x 4)',
    morningSupplements: {MorningSupplement.copper},
    morningBanana: 1,
    morningProtein: ProteinSource.beef,
    isOfficeDay: true,
    gym: const GymConfig(title: 'Legs (Hamstrings / Glutes)'),
    dinner: _beefDinner('8:50-9:20 pm', extraBananas: 3, isFullPastaDay: true, largeCarrots: true), // 4 -> 3: refeed still > 200g net carbs
    chores: const ChoresConfig(),
    bedPrep: const BedPrepConfig(isHarshActiveNight: true),
    magAmount: 3,
    nightSkincare: _Routines.bha,
    isFullPastaDay: true, // Full pasta at lunch, 0 at dinner
  );

  static List<TimelineItem> _buildSaturday() => [
    _wakeup('8:00-8:10 am'),
    _morningDine('8:10-8:45 am', additional: '20mg adderall IR', eggs: 4, protein: ProteinSource.beef, supplements: {MorningSupplement.omega3, MorningSupplement.d3K2, MorningSupplement.vitaminE}, bananaCount: 0, isResistanceDay: false),
    _getReady('8:45-9:05 am', skincare: _Routines.morningSkin1004, clothes: 'Get dressed for gym (Hoka Bondi 8)'),
    ..._buildStudyCycle('9:05-10:35 am', '10:35-10:55 am'),
    ..._buildStudyCycle('10:55-12:20 pm', '12:20-12:35 pm', studyNutrition: {}),
    _study('12:35-1:50 pm'),
    // +1 banana: Saturday is the lowest-carb day (~64g net). Without it, the sim burns protein
    // for brain glucose (GNG). Moving 1 banana here from Thu/Fri cut catabolism ~1.3 -> ~0.4 lbs by Dec.
    _pastaLunch('1:50-2:20 pm', extraBananas: 1, bananaReason: 'Muscle Shield: covers brain glucose so protein goes to muscle'),
    ..._buildStudyCycle('2:20-5:10 pm', '5:10-5:30 pm', studyNutrition: {}),
    _study('5:30-6:20 pm'),
    _commuteToGym('6:20-6:25 pm', reapplySunscreen: _Routines.reapplyHur, nutrition: {}, isResistanceDay: false),
    _gym('6:25-7:35 pm', 'Cardio (LISS) / Haircut', isCardio: true),
    TimelineItem(time: '7:35-7:45 pm', title: 'Commute Home', icon: '🚗'),
    _beefDinner('7:45-8:00 pm'),
    _chores('8:00-8:50 pm', blueberryText: isRefeedWeek() ? 'Eat the rest of the box of Blueberries' : '', nutrition: {}, sleepKiwiCount: 0),
    _relaxOrCatchUp('8:50-9:35 pm'),
    _bedPrep('9:35-10:20 pm', hair: 'Nizoral 1% (5m lather) -> Post-shower: Massage a few drops of Argan Oil into damp scalp to prevent severe dryness'),
    _nightSupplement('10:20-10:35 pm', magAmount: 2, skincare: _Routines.joseon, nutrition: {NutritionAddOn.nac}),
    _fallAsleep('10:35-11:05 pm'),
  ];

  static List<TimelineItem> _buildSunday() => [
    _wakeup('8:00-8:10 am'),
    _morningDine('8:10-9:15 am', eggs: 3, protein: ProteinSource.beef, supplements: {MorningSupplement.d3K2}, bananaCount: 1, isResistanceDay: false),
    _getReady('9:15-9:35 am', skincare: _Routines.morningSkin1004, clothes: 'Get dressed for shopping (NK 9060)'),
    ..._buildStudyCycle('9:50-11:20 am', '11:20-11:50 am', studyDetails: [const DetailItem.trackable('20mg adderall IR at 9:50am')], studyNutrition: {}),
    _study('11:50-1:20 pm'),
    TimelineItem(
      time: '1:20-1:50 pm', 
      title: 'Lunch', 
      icon: '🍛', 
      details: [
        const DetailItem('Eat the last full Ground Beef from fridge'), 
        if (isRefeedWeek()) const DetailItem('🍌 2 Medium Bananas (Pre-Workout Boost)')
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
        DetailItem(_Routines.reapplyHaruharu), 
        const DetailItem('check what I have before going'), 
        const DetailItem("Take both your TJ's shopping bags"),
        if (isNextWeekRefeedWeek()) const DetailItem('🛒 UPCOMING REFEED WEEK: Buy 21 Bananas (3/day: morning, afternoon snack, dinner), and 1 bag of Quinoa (if out)'),
        isRefeedWeek()
            ? const DetailItem('Pick up Chipotle for dinner (REFEED: Double white rice, DOUBLE black beans, extra fajita veggies - NO SOUR CREAM)')
            : const DetailItem('Pick up Chipotle for dinner (MINI-REFEED: Double white rice, SINGLE black beans, extra fajita veggies - NO SOUR CREAM)')
      ]
    ),
    TimelineItem(
      time: '4:00-4:30 pm', 
      title: 'Dinner (Eat fresh Chipotle)', 
      icon: '🌯', 
      details: [
        const DetailItem.trackable('1 scoop creatine monohydrate (5g)'), 
        isRefeedWeek()
            ? const DetailItem('Chipotle Bowl (REFEED): single chicken, double white rice, DOUBLE black beans, extra fajita veggies (NO SOUR CREAM)')
            : const DetailItem('Chipotle Bowl (MINI-REFEED): single chicken, double white rice, SINGLE black beans, extra fajita veggies (NO SOUR CREAM)'),
        const DetailItem('🥕 Eat 7% of bag (12/7 oz, ~7 baby carrots)'),
        if (isRefeedWeek()) const DetailItem('🍌 1 Medium Banana (REFEED WEEK)'),
        if (!isAshwagandhaOff()) const DetailItem.trackable('2 cap Ashwagandha'),
      ], 
      mealRecord: MealRecord(
        items: [
          _Portions.creatine, 
          IngredientPortion(
            ingredient: isRefeedWeek() ? IngredientsData.chipotleBowlRefeed : IngredientsData.chipotleBowl, 
            amount: 1,
          ),
          if (isRefeedWeek()) const IngredientPortion(ingredient: IngredientsData.banana, amount: 1),
          const IngredientPortion(ingredient: IngredientsData.babyCarrots, amount: 12 / 7),
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
        const DetailItem('Meal Prep: Pasta (6 portions)'), 
        if (isNextWeekRefeedWeek()) const DetailItem('🧑‍🍳 UPCOMING REFEED WEEK: Cook a batch of Quinoa for Mon-Sat dinners (divide into 3 containers)'),
        const DetailItem('Put ground beef in freezer'),
        const DetailItem('Boil 18 eggs for the week (warm on counter 10m first)')
      ]
    ),
    _relaxOrCatchUp('7:30-8:15 pm'),
    _chores('8:15-8:50 pm', nutrition: {}, sleepKiwiCount: 0),
    _bedPrep('8:50-9:50 pm', isHarshActiveNight: true),
    _nightSupplement('9:50-10:05 pm', magAmount: 2, skincare: _Routines.retinol, nutrition: {NutritionAddOn.nac}),
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