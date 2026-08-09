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
  static final pasta = RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'pasta'), servings: 1);
  static final salmon = RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'salmon'), servings: 1);
  static final salmonHalf = RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'salmon'), servings: 0.5);
  static final beef = RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'beef'), servings: 1);
  static final beefHalf = RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'beef'), servings: 0.5);
  static final quinoa = RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'quinoa'), servings: 1);
}

class DailyPlanData {
  static final DateTime planStartDate = DateTime(2026, 7, 27);

  static const String mon = 'mon';
  static const String tue = 'tue';
  static const String wed = 'wed';
  static const String thu = 'thu';
  static const String fri = 'fri';
  static const String sat = 'sat';
  static const String sun = 'sun';

  static DateTime? mockCurrentDate;


  static int get _currentWeekNumber {
    final now = mockCurrentDate ?? DateTime.now();
    final diff = now.difference(planStartDate).inDays;
    if (diff < 0) return 0;
    return (diff ~/ 7) + 1;
  }

  static int get currentWeekNumber => _currentWeekNumber;

  static bool isDeloadWeek() => isRefeedWeek();
  static bool shouldScaleUpCardio() => _currentWeekNumber >= 17;
  static bool isBloodDonationWeek() => _currentWeekNumber > 0 && _currentWeekNumber % 22 == 0;
  
  static bool isBloodTestPrepWeek() {
    final now = mockCurrentDate ?? DateTime.now();
    final start = DateTime(2026, 8, 24);
    final end = DateTime(2026, 8, 31, 23, 59, 59);
    return now.isAfter(start.subtract(const Duration(seconds: 1))) && now.isBefore(end);
  }
  static bool isAshwagandhaOff() {
    if (_currentWeekNumber == 0) return false;
    return ((_currentWeekNumber - 1) % 12) + 1 > 8;
  }

  static bool isRefeedWeek() {
    if (_currentWeekNumber == 0) return false;
    // Week 5 is early refeed (for blood draw & Labor Day); Weeks 12 and 18 are normal
    return _currentWeekNumber == 5 || _currentWeekNumber == 12 || _currentWeekNumber == 18;
  }

  static bool isNextWeekRefeedWeek() {
    if (_currentWeekNumber == 0) return false;
    return _currentWeekNumber == 4 || _currentWeekNumber == 11 || _currentWeekNumber == 17;
  }

  static const Map<String, int> waterBottles = {
    mon: 7, tue: 7, wed: 7, thu: 7, fri: 7, sat: 7, sun: 7,
  };

  static List<String> getReminders(String dayKey) {
    if (dayKey == wed) {
      return ['🥩 Take ground beef out of freezer to thaw in fridge'];
    } else if (dayKey == sun) {
      return ['❄️ Put fresh ground beef into the freezer'];
    }
    return [];
  }

  static TimelineItem _wakeup(String time, {bool nac = false}) {
    return TimelineItem(
      time: time,
      title: 'Wakeup',
      icon: '☀️',
      details: [
        'Use bathroom',
        'Weight (Step on scale)',
        'Drink cold water with a heavy pinch (0.5 tsp) of Lite Salt',
        if (isRefeedWeek()) '🍌 REFEED WEEK: Eat 1 Medium Banana',
        if (nac) 'Take 600mg NAC + 25mcg Selenium (Combo Pill)',
        'Take 250mg Citicoline (w/ 25mg Tyrosine)',
      ],
      mealRecord: MealRecord(items: [
        const IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 0.5),
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
        'Set Dehumidifier to 55%',
        'Brush teeth',
        'Wash face/neck with bare hands using 0.5 pump of Gentle Cleanser for 15s to remove overnight sweat -> Rinse -> Pat dry with new bamboo baby washcloth',
        'Ascorbyl 12% (Apply to slightly damp skin, AVOID orbital bone): 5 drops (1 forehead, 1 left cheek, 1 right cheek, 2 neck) -> WAIT 90s',
        skincare,
        clothes,
        'Set Dehumidifier to 45% (to prevent mold)',
      ],
    );
  }

  static TimelineItem _bedPrep(String time, {String hair = '60s warm massage', bool newBathTowel = false}) {
    return TimelineItem(
      time: time,
      title: 'Shower & Bed Prep',
      icon: '🚿',
      details: [
        if (newBathTowel) '🛑 Grab a FRESH Bath Towel for the new rotation; use instead of bamboo!',
        'Set Dehumidifier to 55%',
        'Brush teeth (safe since 30m since kiwi)',
        'Pre-Shower: Rub 2-3 pumps dedicated Cleansing Oil on DRY face (30s) to melt sunscreen/sweat',
        'In-Shower: Wet hands, rub face/neck/ears to emulsify oil (15-20s) -> Rinse thoroughly',
        'Hair: $hair',
        'Body: Hold Washcloth under water until SOAKING wet. Apply Dove Deep Moisture Body Wash into cloth and rub together to build a rich foam cushion. Gently sweep foamy cloth over upper and lower body (for frictionless gym maintenance)',
        'Face: Lather 1 pump of ${[11, 12, 1, 2, 3].contains(DateTime.now().month) ? "Lipikar AP+ (Winter Shield)" : "Vanicream Gentle Cleanser"} in wet hands for 3-4s to build foam. Gently glide foam onto face/neck/ears with LUKEWARM water for EXACTLY 30s (then rinse)',
        'Finish: Lukewarm rinse',
        newBathTowel
            ? 'Pat face & beard completely dry with the FRESH Bath Towel (Do Skincare immediately while bathroom is humid, before drying your body)'
            : 'Pat face & beard completely dry with a new bamboo baby washcloth (Do Skincare immediately while bathroom is humid)',
      ],
    );
  }


  static TimelineItem _morningDine(String time, {
    String additional = '', 
    int eggs = 3, 
    bool zinc = false, 
    bool vitamins = true, 
    bool vitaminE = false, 
    bool omega3 = true, 
    bool copper = false,
    bool eatSalmon = false,
    bool eatBeef = false,
    String blueberryText = '',
    bool useD3K2 = false,
  }) {
    return TimelineItem(
      time: time,
      title: 'Morning Dine',
      icon: '🍳',
      details: [
        'Eat in front of Verilux HappyLight (45-degree angle to face):',
        if (blueberryText.isNotEmpty) '🫐 $blueberryText',
        if (eatSalmon) 'Finish leftover 0.5 portion of Salmon (from fridge)',
        if (eatBeef) 'Finish leftover 0.5 portion of Ground Beef (from fridge)',
        if (eggs > 0) '$eggs Boiled Eggs',
        if (vitamins) ...[
          if (omega3) '3 softgel omega-3',
          if (useD3K2) '1 D3-K2',
          if (useD3K2) '1 standalone K2 (100mcg)' else '2 standalone K2 (100mcg each)',
          '1 cap Biotin+Keratin (10mg/500mg)',
          if (vitaminE) '1 softgel Vitamin E (267mg)',
        ],
        if (zinc) '1 cap Zinc Picolinate (30mg)',
        if (copper) '1 cap Copper Glycinate (3mg)',
        if (vitamins || zinc || copper) 'Swish/drink water after eating/drinking to clear mouth',
        if (additional.isNotEmpty) additional,
      ],
      mealRecord: MealRecord(items: [
        if (blueberryText.isNotEmpty) const IngredientPortion(ingredient: IngredientsData.blueberries, amount: 0.66),
        if (eggs > 0) IngredientPortion(ingredient: IngredientsData.egg, amount: eggs.toDouble()),
        if (vitamins && omega3) _Portions.omega3,
        if (vitamins && useD3K2) _Portions.d3K2,
        if (vitamins && useD3K2) _Portions.standaloneK2 else if (vitamins) const IngredientPortion(ingredient: IngredientsData.standaloneK2, amount: 2),
        if (vitamins) _Portions.biotin,
        if (vitamins && vitaminE) _Portions.vitaminE,
        if (zinc) _Portions.zinc,
        if (copper) const IngredientPortion(ingredient: IngredientsData.copperGlycinate, amount: 1),
      ], recipeItems: [
        if (eatSalmon) _Recipes.salmonHalf,
        if (eatBeef) _Recipes.beefHalf,
      ]),
    );
  }

  static TimelineItem _grabThings(String time, {
    int calciumCaps = 0,
  }) {
    return TimelineItem(
      time: time,
      title: 'Grab things to take to work',
      icon: '🗂️',
      details: [
        'kindle/laptop',
        '2 key/wallet/phone',
        'airpods',
        'apple watch',
        if (calciumCaps > 0) 'Calcium Citrate (${calciumCaps}x capsules)',
        if (isRefeedWeek()) '🍌 1 Medium Banana (Afternoon snack)',
        'Pasta lunch',
        'water bottle'
      ],
    );
  }

  static TimelineItem _commuteToWork(String time) {
    return TimelineItem(time: time, title: 'Commute to Work', icon: '🚗');
  }

  static TimelineItem _work(String time, {
    List<String> details = const [], 
    String title = 'Work', 
    bool calcium = false, 
    bool standingDesk = false, 
    bool caffeine = false, 
    bool sparklingWater = false,
    bool banana = false,
  }) {
    return TimelineItem(
      time: time, 
      title: title, 
      icon: '💻', 
      details: [
        if (caffeine) '☕️ Drink Caffeine around 9:30 am',
        if (sparklingWater) 'Drink Sparkling Water',
        if (standingDesk && !isRefeedWeek()) '🧍‍♂️ Use Standing Desk for 3-4 hours',
        if (banana) '🍌 3:30-4:00 pm: Eat 1 Medium Banana (Afternoon Snack)',
        ...details
      ],
      mealRecord: banana ? const MealRecord(items: [
        IngredientPortion(ingredient: IngredientsData.banana, amount: 1),
      ]) : null,
    );
  }

  static TimelineItem _study(String time, {
    List<String> details = const [],
    bool calcium = false,
    int sleepKiwiCount = 0,
    bool banana = false,
    bool withWhey = false,
    bool withCreatine = false,
  }) {
    return TimelineItem(
      time: time,
      title: 'Study Time',
      icon: '📚',
      details: [
        if (withWhey || withCreatine) '🥤 Pre-Workout Shake: ${withWhey ? "1 scoop whey isolate (30g protein)" : ""}${withWhey && withCreatine ? " + " : ""}${withCreatine ? "1 scoop creatine monohydrate (5g)" : ""}',
        ...details,
        if (banana) '🍌 3:30-4:00 pm: Eat 1 Medium Banana (Afternoon Snack)',
        if (sleepKiwiCount > 0) 'Halfway through (30m before bed prep): Eat $sleepKiwiCount Kiwi${sleepKiwiCount > 1 ? "s" : ""} & Swish water (protect enamel)',
      ],
      mealRecord: (sleepKiwiCount > 0 || banana || withWhey || withCreatine) ? MealRecord(items: [
        if (withWhey) _Portions.whey,
        if (withCreatine) _Portions.creatine,
        if (banana) const IngredientPortion(ingredient: IngredientsData.banana, amount: 1),
        if (sleepKiwiCount > 0) IngredientPortion(ingredient: IngredientsData.kiwi, amount: sleepKiwiCount.toDouble()),
      ]) : null,
    );
  }

  static TimelineItem _relaxOrCatchUp(String time, {String title = 'Relax / Catch up on reading', String icon = '🛋️'}) {
    return TimelineItem(
      time: time,
      title: title,
      icon: icon,
    );
  }


  static TimelineItem _pastaLunch(String time, {int calciumCaps = 0}) {
    return TimelineItem(
      time: time,
      title: 'Lunch',
      icon: '🍝',
      details: [
        '1 serving of my pasta',
        if (calciumCaps > 0) 'Take $calciumCaps Calcium Citrate capsule${calciumCaps > 1 ? "s" : ""} (${(calciumCaps * 146).toStringAsFixed(0)}mg) with meal to bind to spinach oxalates',
      ],
      mealRecord: MealRecord(
        items: [
          if (calciumCaps == 3) _Portions.calciumCitrate,
          if (calciumCaps == 2) _Portions.calciumCitrate2,
          if (calciumCaps == 1) _Portions.calciumCitrate1,
        ],
        recipeItems: [_Recipes.pasta],
      ),
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
    return TimelineItem(
      time: time,
      title: title,
      icon: isCardio ? '🏃' : '🏋️',
      isCardio: isCardio,
    );
  }

  static TimelineItem _salmonDinner(String time, {bool withWhey = false, bool cook = false, bool copper = false, bool banana = false, bool withCreatine = true}) {
    final showAshwagandha = !isAshwagandhaOff();
    return TimelineItem(
      time: time,
      title: 'Dinner${withWhey ? ' & Post-Workout Shake' : ''}',
      icon: '🥗',
      details: [
        if (withWhey) '1 scoop whey isolate (30g protein)',
        if (withCreatine) '1 scoop creatine monohydrate (5g)',
        if (copper) 'Take 1 cap Copper Glycinate (3mg)',
        if (cook) 'Cook Salmon (3 portions): start 1st portion (eat 1/2, save 1/2 in fridge)' else 'Start a new portion of Salmon (eat 1/2, save other 1/2 in fridge)', 
        '🥕 Eat 1/7th of a bag (~14 baby carrots)',
        if (banana) '🍌 1 Medium Banana (REFEED WEEK)',
        if (showAshwagandha) '2 cap Ashwagandha',
        if (isRefeedWeek()) '🍚 REFEED WEEK: Include 0.5 cups (dry) cooked Quinoa',
      ],
      mealRecord: MealRecord(items: [
        if (withWhey) _Portions.whey,
        if (withCreatine) _Portions.creatine,
        if (copper) const IngredientPortion(ingredient: IngredientsData.copperGlycinate, amount: 1),
        _Portions.babyCarrots,
        if (banana) const IngredientPortion(ingredient: IngredientsData.banana, amount: 1),
        if (showAshwagandha) const IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2),
      ], recipeItems: [
        _Recipes.salmonHalf,
        if (isRefeedWeek()) _Recipes.quinoa,
      ]),
    );
  }

  static TimelineItem _beefDinner(String time, {bool withWhey = false, bool banana = false}) {
    final showAshwagandha = !isAshwagandhaOff();
    return TimelineItem(
      time: time,
      title: 'Dinner${withWhey ? ' & Post-Workout Shake' : ''}',
      icon: '🍛',
      details: [
        if (withWhey) '1 scoop whey isolate (30g protein)',
        '1 scoop creatine monohydrate (5g)',
        'Start a new portion of Ground Beef (eat 1/2, save other 1/2 in fridge)', 
        '🥕 Eat 1/7th of a bag (~14 baby carrots)',
        if (banana) '🍌 1 Medium Banana (REFEED WEEK)',
        if (showAshwagandha) '2 cap Ashwagandha',
        if (isRefeedWeek()) '🍚 REFEED WEEK: Include 0.5 cups (dry) cooked Quinoa',
      ],
      mealRecord: MealRecord(items: [
        if (withWhey) _Portions.whey,
        _Portions.creatine,
        _Portions.babyCarrots,
        if (banana) const IngredientPortion(ingredient: IngredientsData.banana, amount: 1),
        if (showAshwagandha) const IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2),
      ], recipeItems: [
        _Recipes.beefHalf,
        if (isRefeedWeek()) _Recipes.quinoa,
      ]),
    );
  }

  static TimelineItem _chores(String time, {int sleepKiwiCount = 0, String blueberryText = '', bool banana = true}) {
    return TimelineItem(
      time: time,
      title: 'Chores & Clean Up',
      icon: '🧼',
      details: [
        '1 scoop Casein in 16oz water -> Swish/drink water after',
        'The 7 bottles water are separate from this. This is in addition to that. So 7 bottles + this.',
        if (sleepKiwiCount > 0) 'Eat $sleepKiwiCount Kiwi${sleepKiwiCount > 1 ? "s" : ""} now (30m before bed prep to protect enamel) & Swish water',
        if (blueberryText.isNotEmpty) '🫐 $blueberryText',
        if (banana) 'Eat 1 Banana 🍌',
      ], 
      mealRecord: MealRecord(items: [
        const IngredientPortion(ingredient: IngredientsData.casein, amount: 1),
        if (sleepKiwiCount > 0) IngredientPortion(ingredient: IngredientsData.kiwi, amount: sleepKiwiCount.toDouble()),
        if (blueberryText.isNotEmpty) const IngredientPortion(ingredient: IngredientsData.blueberries, amount: 1.0),
        if (banana) const IngredientPortion(ingredient: IngredientsData.banana, amount: 1),
      ]),
    );
  }

  static TimelineItem _nightSupplement(String time, {
    required String skincare, 
    int magAmount = 2, 
    String magName = 'Magnesium Glycinate',
    String title = 'Night Supplement + Read/Reflect',
    bool nac = false,
  }) {
    return TimelineItem(
      time: time,
      title: title,
      icon: '🌙',
      details: [
        'Take $magAmount $magName + 1 tablet Finasteride (1mg)',
        if (nac) 'Take 600mg NAC + 25mcg Selenium (Combo Pill)',
        skincare,
        'Underarms: Ensure pits are BONE DRY -> Moisturize with face moisturizer (Vanicream Daily Facial) -> WAIT to dry -> Apply 5% AHA Deodorant',
        'Eye Serum FIRST: Gently tap 1 drop of The Ordinary Caffeine Solution across orbital bone -> THEN Moisturizer (Vanicream Daily Facial): Squeeze exactly 1 DIME-SIZED amount (total) onto fingertip, dot it evenly across face/neck/orbital bone, then rub in -> WAIT to dry',
        'Set Dehumidifier to 45% (to prevent mold)',
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
        'Come up with todo list for tom',
        'Lights out, try to fall asleep within 30 min',
      ],
    );
  }

  static const String _morningMoisturizer = 'Eye Serum FIRST: Gently tap 1 drop of The Ordinary Caffeine Solution across orbital bone -> THEN Moisturizer (Vanicream Daily Facial): Squeeze exactly 1 PEA-SIZED amount (total) onto fingertip, dot it across face/orbital bone, then rub in -> WAIT 30s';
  static const String _moisturizerAndSunscreen = 'Eye Serum FIRST: Gently tap 1 drop of The Ordinary Caffeine Solution across orbital bone -> THEN Moisturizer (Vanicream): Squeeze exactly 1 PEA-SIZED amount (total) onto fingertip, dot it across face/orbital bone, then rub in -> WAIT 3m -> Supergoop Matte Mineral (Layer 1: 1/8 tsp total, then 1/8 tsp to neck -> WAIT 30s -> Layer 2: Repeat)';
  static const String _retinol = 'Retinol (Apply to BONE DRY skin to prevent irritation, STRICTLY AVOID orbital bone/eyelids): 1.5 pumps (0.5 forehead, 0.25 left cheek, 0.25 right cheek, 0.5 neck) -> WAIT 1-2m';
  static const String _bha = 'Paula\'s Choice 2% BHA (Apply to BONE DRY skin to prevent irritation, AVOID orbital bone): 3 drops (1 forehead, 1 left cheek, 1 right cheek) -> WAIT 1-2m';
  static const String _joseon = 'Joseon Alpha-Arbutin (Apply to slightly damp skin, AVOID orbital bone): 4 drops (1 forehead, 1 left cheek, 1 right cheek, 1 neck) -> WAIT 1-2m';
  static const String _sunscreen = 'Wash hands -> Blotting Sheet (Place over oily area and press against skin for 3s, lift and press - no rubbing ever) -> Wash hands -> Supergoop Matte Mineral (Layer 1: 1/8 tsp total (dots on forehead, left cheek, right cheek, ears), then 1/8 tsp to neck -> WAIT 30s -> Layer 2: Repeat)';

  static String get _laundryFaceTowels => 'Laundry Cycle 1: Bamboo Washcloths & Cotton Pillowcases (3/5 warmness) -> 1-2 tbsp All Free Clear (Liquid). NO Fabric Softener (Dry on LOW heat)';
  static String get _laundryBathTowels => 'Laundry Cycle 2: Bath Towels & Body Washcloths (5/5 warmness) -> Wash 1: 2 tbsp All Free Clear (Liquid) + 1/3 cup Bleach -> Wash 2: Full Cycle (WATER ONLY - no detergent) to lift bleach residue (Dry on LOW heat)';
  static const String _laundryRegular = 'Laundry: Regular Wash (All other clothes/gym gear, 3/5 warmness) -> All Free Clear (Liquid)';


  static TimelineItem _commuteToGym(String time, {bool applySunscreen = false, bool takeGymGloves = false, bool withDextrin = true}) {
    return TimelineItem(
      time: time,
      title: 'Get Dressed & Commute to Gym',
      icon: '🚗',
      details: [
        'Get dressed for gym',
        if (withDextrin) 'Mix 1 scoop Cluster Dextrin in water bottle (+ 1/3 tsp Lite Salt electrolytes). Drink 1/3 on commute, sip rest during workout',
        if (applySunscreen) _sunscreen,
        if (takeGymGloves) '🧤 Grab Gym Gloves',
      ],
      mealRecord: withDextrin ? const MealRecord(items: [
        IngredientPortion(ingredient: IngredientsData.clusterDextrin, amount: 1),
        IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 1 / 3),
      ]) : null,
    );
  }

  static Map<String, List<TimelineItem>> get schedules => {
    mon: [
      _wakeup('8:10-8:20 am'),
      _getReady('8:20-8:40 am', skincare: _morningMoisturizer, clothes: 'Get dressed'),
      _morningDine('8:40-8:50 am', eggs: 2, zinc: true, vitaminE: true, omega3: false),
      _work('8:50-1:00 pm', details: [_laundryFaceTowels, 'Run Dishwasher']),
      _pastaLunch('1:00-1:30 pm', calciumCaps: 3),
      _work('1:30-5:00 pm', details: [_laundryBathTowels], banana: isRefeedWeek()),
      _study('5:00-5:55 pm', details: ['Study (Beat traffic before gym)']),
      _commuteToGym('5:55-6:30 pm', applySunscreen: true),
      _gym('6:30-8:30 pm', 'Gym Session (Upper A)'),
      TimelineItem(time: '8:30-8:50 pm', title: 'Commute Home', icon: '🚗'),
      _salmonDinner('8:50-9:20 pm', withWhey: true, cook: true, banana: isRefeedWeek()),
      _chores('9:20-9:50 pm', sleepKiwiCount: 1),
      _bedPrep('9:50-10:20 pm', newBathTowel: true),
      _nightSupplement('10:20-10:50 pm', magAmount: 3, skincare: _retinol),
      _fallAsleep('10:50-11:20 pm'),
    ],
    tue: [
      _wakeup('8:10-8:20 am'),
      _getReady('8:20-8:40 am', skincare: _moisturizerAndSunscreen, clothes: 'Get dressed (cloud x 4)'),
      _morningDine('8:40-8:50 am', eggs: 2, zinc: true, omega3: false, eatSalmon: true),
      _grabThings('8:50-8:55 am'),
      _commuteToWork('8:55-9:00 am'),
      _work('9:00-1:00 pm', caffeine: true, sparklingWater: true, standingDesk: true),
      _pastaLunch('1:00-1:30 pm'),
      _work('1:30-5:00 pm', sparklingWater: true, standingDesk: true, banana: isRefeedWeek()),
      TimelineItem(time: '5:00-5:10 pm', title: 'Commute Home', icon: '🚗'),
      _study('5:10-5:55 pm', details: ['Study (Beat traffic before gym)']),
      _commuteToGym('5:55-6:30 pm'),
      _gym('6:30-8:30 pm', 'Gym Session (Lower A)'),
      TimelineItem(time: '8:30-8:50 pm', title: 'Commute Home', icon: '🚗'),
      _salmonDinner('8:50-9:20 pm', withWhey: true, copper: true, banana: isRefeedWeek()),
      _chores('9:20-9:50 pm', sleepKiwiCount: 1),
      _bedPrep('9:50-10:20 pm'),
      _nightSupplement('10:20-10:50 pm', magAmount: 3, skincare: _joseon),
      _fallAsleep('10:50-11:20 pm'),
    ],
    wed: [
      _wakeup('8:10-8:20 am', nac: true),
      _getReady('8:20-8:40 am', skincare: _moisturizerAndSunscreen, clothes: 'Get dressed (NK 9060/Bondi)'),
      _morningDine('8:40-8:50 am', additional: 'Take ground beef out of freezer to thaw in fridge', eggs: 2, zinc: false, vitaminE: false, omega3: false, eatSalmon: true),
      _grabThings('8:50-8:55 am', calciumCaps: 3),
      _commuteToWork('8:55-9:00 am'),
      _work('9:00-1:00 pm', caffeine: true, sparklingWater: true, standingDesk: true),
      _pastaLunch('1:00-1:30 pm', calciumCaps: 3),
      _work('1:30-5:00 pm', sparklingWater: true, standingDesk: true, banana: isRefeedWeek()),
      TimelineItem(time: '5:00-5:10 pm', title: 'Commute Home', icon: '🚗'),
      _study('5:10-6:05 pm', details: ['Study (Beat traffic before gym)'], withWhey: true, withCreatine: true),
      _commuteToGym('6:05-6:15 pm', withDextrin: false),
      _gym('6:15-7:25 pm', 'Cardio (LISS) / Haircut', isCardio: true),
      TimelineItem(time: '7:25-7:35 pm', title: 'Commute Home', icon: '🚗'),
      _salmonDinner('7:40-8:20 pm', withWhey: false, withCreatine: false, banana: isRefeedWeek()),
      _chores('8:20-8:50 pm'),
      _study('8:50-9:20 pm', sleepKiwiCount: 1),
      _relaxOrCatchUp('9:20-9:50 pm'),
      _bedPrep('9:50-10:20 pm', hair: 'CeraVe Gentle Shampoo (45s lather)'),
      _nightSupplement('10:20-10:50 pm', magAmount: 2, skincare: _retinol),
      _fallAsleep('10:50-11:20 pm'),
    ],
    thu: [
      _wakeup('8:10-8:20 am'),
      _getReady('8:20-8:40 am', skincare: _morningMoisturizer, clothes: 'Get dressed'),
      _morningDine('8:40-8:50 am', eggs: 2, vitaminE: true, omega3: false, eatSalmon: true),
      TimelineItem(time: '8:50-9:25 am', title: 'Cook', icon: '🧑‍🍳', details: ['1lb ground beef (divide in 4, 4 fridge)']),
      _work('9:25-1:00 pm', details: [_laundryRegular, 'Run Dishwasher']),
      _pastaLunch('1:00-1:30 pm', calciumCaps: 3),
      _work('1:30-5:00 pm', details: ['Work'], banana: isRefeedWeek()),
      _study('5:00-5:55 pm', details: ['Study (Beat traffic before gym)']),
      _commuteToGym('5:55-6:20 pm', applySunscreen: true, takeGymGloves: true),
      _gym('6:10-8:10 pm', 'Gym Session (Upper B)'),
      TimelineItem(time: '8:10-8:30 pm', title: 'Commute Home', icon: '🚗'),
      _beefDinner('8:30-9:00 pm', withWhey: true, banana: isRefeedWeek()),
      _chores('9:00-9:30 pm', sleepKiwiCount: 2),
      _bedPrep('9:30-10:00 pm', newBathTowel: true),
      _nightSupplement('10:00-10:50 pm', magAmount: 2, skincare: _bha),
      _fallAsleep('10:50-11:20 pm'),
    ],
    fri: [
      _wakeup('8:10-8:20 am'),
      _getReady('8:20-8:40 am', skincare: _moisturizerAndSunscreen, clothes: 'Get dressed (cloud x 4)'),
      _morningDine('8:40-8:50 am', eggs: 2, copper: true, omega3: false, eatBeef: true),
      _grabThings('8:50-8:55 am'),
      _commuteToWork('8:55-9:00 am'),
      _work('9:00-1:00 pm', caffeine: true, sparklingWater: true, standingDesk: true),
      _pastaLunch('1:00-1:30 pm'),
      _work('1:30-5:00 pm', sparklingWater: true, standingDesk: true, banana: isRefeedWeek()),
      TimelineItem(time: '5:00-5:10 pm', title: 'Commute Home', icon: '🚗'),
      _study('5:10-5:55 pm', details: ['Study (Beat traffic before gym)']),
      _commuteToGym('5:55-6:30 pm'),
      _gym('6:30-8:30 pm', 'Gym Session (Lower B)'),
      TimelineItem(time: '8:30-8:50 pm', title: 'Commute Home', icon: '🚗'),
      _beefDinner('8:50-9:20 pm', withWhey: true, banana: isRefeedWeek()),
      _chores('9:20-9:50 pm', blueberryText: 'Eat 1/2 of the box of Blueberries'),
      _bedPrep('9:50-10:20 pm'),
      _nightSupplement('10:20-10:50 pm', magAmount: 3, skincare: _joseon),
      _fallAsleep('10:50-11:20 pm'),
    ],
    sat: [
      _wakeup('8:10-8:20 am'),
      _getReady('8:20-8:40 am', skincare: _morningMoisturizer, clothes: 'Get dressed for gym (Hoka Bondi 8)'),
      _morningDine('8:40-9:05 am', additional: '20mg adderall IR', eggs: 4, vitamins: true, useD3K2: true, vitaminE: true, eatBeef: true),
      _study('9:05-10:35 am'),
      TimelineItem(time: '10:35-10:55 am', title: 'Diffuse Brain Rest', icon: '🧠', details: ['NO PHONE. Relax or nap on bed/chair. Close eyes and allow memory consolidation.']),
      _study('10:55-12:20 pm'),
      TimelineItem(time: '12:20-12:35 pm', title: 'Diffuse Brain Rest', icon: '🧠', details: ['NO PHONE. Relax or nap on bed/chair. Close eyes and allow memory consolidation.']),
      _study('12:35-1:50 pm'),
      _pastaLunch('1:50-2:20 pm', calciumCaps: 3),
      _study('2:20-5:10 pm', banana: isRefeedWeek()),
      TimelineItem(time: '5:10-5:30 pm', title: 'Diffuse Brain Rest', icon: '🧠', details: ['NO PHONE. Relax or nap on bed/chair. Let mind wander completely.']),
      _study('5:30-6:20 pm'),
      _commuteToGym('6:20-6:25 pm', applySunscreen: true, withDextrin: false),
      _gym('6:25-7:35 pm', 'Cardio (LISS) / Haircut', isCardio: true),
      TimelineItem(time: '7:35-7:45 pm', title: 'Commute Home', icon: '🚗'),
      _beefDinner('7:45-8:00 pm', withWhey: false, banana: isRefeedWeek()),
      _chores('8:00-8:50 pm', blueberryText: 'Eat the rest of the box of Blueberries'),
      _relaxOrCatchUp('8:50-9:35 pm'),
      _bedPrep('9:35-10:20 pm', hair: 'Nizoral 1% (5m lather)'),
      _nightSupplement('10:20-10:35 pm', magAmount: 2, magName: 'Magnesium', skincare: _bha, nac: true),
      _fallAsleep('10:35-11:05 pm'),
    ],
    sun: [
      _wakeup('8:10-8:20 am'),
      _getReady('8:20-8:40 am', skincare: _morningMoisturizer, clothes: 'Get dressed for shopping (NK 9060)'),
      _morningDine('8:40-9:35 am', eggs: 4, vitamins: true, useD3K2: true, vitaminE: true, omega3: false, eatBeef: true),
      _study('9:50-11:20 am', details: ['20mg adderall IR at 9:50am']),
      TimelineItem(time: '11:20-11:50 am', title: 'Diffuse Brain Rest', icon: '🧠', details: ['NO PHONE. Relax or nap on bed/chair to hit "save" on encoded information.']),
      _study('11:50-1:20 pm'),
      TimelineItem(
        time: '1:20-1:50 pm', 
        title: 'Lunch', 
        icon: '🍛', 
        details: [
          'Eat the remaining full portion of Ground Beef from fridge', 
          'Take 3 Calcium Citrate capsules (438mg) with meal', 
          if (isRefeedWeek()) '🍌 1 Medium Banana (REFEED WEEK)'
        ], 
        mealRecord: MealRecord(
          items: [
            _Portions.calciumCitrate, 
            if (isRefeedWeek()) const IngredientPortion(ingredient: IngredientsData.banana, amount: 1)
          ], 
          recipeItems: [_Recipes.beef]
        )
      ),
      TimelineItem(
        time: '1:50-4:00 pm', 
        title: 'Grocery Shop & Pick up Chipotle', 
        icon: '🛒', 
        details: [
          _sunscreen, 
          'check what I have before going', 
          "Trader Joe's (all groceries are bought there)", 
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
        mealRecord: MealRecord(items: [
          _Portions.creatine, 
          if (isRefeedWeek()) const IngredientPortion(ingredient: IngredientsData.banana, amount: 1), 
          IngredientPortion(
            ingredient: isRefeedWeek() ? IngredientsData.chipotleBowlRefeed : IngredientsData.chipotleBowl, 
            amount: 1,
          ), 
          const IngredientPortion(ingredient: IngredientsData.babyCarrots, amount: 3.4),
          if (!isAshwagandhaOff()) const IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2),
        ], recipeItems: const [])
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
      _relaxOrCatchUp('7:30-8:15 pm', title: 'Rest / Weekly Reflection'),
      _chores('8:15-8:50 pm'),
      _bedPrep('8:50-9:50 pm'),
      _nightSupplement('9:50-10:05 pm', magAmount: 2, magName: 'Magnesium', skincare: _joseon, title: 'Night Supplement', nac: true),
      _relaxOrCatchUp('10:05-10:50 pm'),
      _fallAsleep('10:50-11:20 pm'),
    ],
  };
}


