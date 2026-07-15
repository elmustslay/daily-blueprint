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
  
  static const calciumCitrate = IngredientPortion(ingredient: IngredientsData.calciumCitrate, amount: 3);
  static const calciumCitrate2 = IngredientPortion(ingredient: IngredientsData.calciumCitrate, amount: 2);
  static const calciumCitrate1 = IngredientPortion(ingredient: IngredientsData.calciumCitrate, amount: 1);

  static const coreVitamins = [d3K2, standaloneK2, omega3, biotin];
}

class _Recipes {
  static final pasta = RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'pasta'), servings: 1);
  static final salmon = RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'salmon'), servings: 1);
  static final beef = RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'beef'), servings: 1);
  static final quinoa = RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'quinoa'), servings: 1);
}

class DailyPlanData {
  static final DateTime planStartDate = DateTime(2026, 4, 13);

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

  static bool isDeloadWeek() => _currentWeekNumber > 1 && (_currentWeekNumber - 1) % 6 == 0;
  static bool shouldScaleUpCardio() => _currentWeekNumber >= 17;
  static bool isBloodDonationWeek() => _currentWeekNumber > 0 && _currentWeekNumber % 22 == 0;
  
  static bool isAshwagandhaOff() {
    if (_currentWeekNumber == 0) return false;
    return ((_currentWeekNumber - 1) % 12) + 1 > 8;
  }

  static bool isRefeedWeek() {
    if (_currentWeekNumber == 0) return false;
    return (_currentWeekNumber - 1) % 6 == 5; // 5 weeks cut, 1 week refeed
  }

  static bool isNextWeekRefeedWeek() {
    if (_currentWeekNumber == 0) return false;
    return (_currentWeekNumber) % 6 == 5; 
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
        if (nac) 'Take 600mg NAC + 25mcg Selenium (Combo Pill)',
        'Take 250mg Citicoline (w/ 25mg Tyrosine)',
      ],
      mealRecord: MealRecord(items: [
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
        'Face & neck: Use 1 Blotting Sheet to press against oily areas (forehead/nose) for 3s each to absorb overnight oil ->' , 
        'Wet new microfiber cloth with lukewarm water (leave SOAKING wet to prevent friction) and gently wipe',
        'Ascorbyl 12% (Apply to slightly damp skin): 5 drops (1 forehead, 1 left cheek, 1 right cheek, 2 neck) -> WAIT 90s',
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
        if (newBathTowel) '🛑 Grab a FRESH Bath Towel for the new rotation!',
        'Set Dehumidifier to 55%',
        'Brush teeth (safe since 30m since kiwi)',
        'Pre-Shower: Rub 2-3 pumps dedicated Cleansing Oil on DRY face (30s) to melt sunscreen/sweat',
        'In-Shower: Wet hands, rub face/neck/ears to emulsify oil (15-20s) -> Rinse thoroughly',
        'Hair: $hair',
        'Body: Hold Washcloth under water until SOAKING wet. Pump 1 pump of Lipikar AP+ into cloth and rub together to build a rich foam cushion. Gently sweep foamy cloth over upper and, once done/rinsed another 1 pump for lower body (for frictionless gym maintenance)',
        'Face: Lather 1 pump of Lipikar AP+ in wet hands for 3-4s to build foam. Gently glide foam onto face/neck/ears with LUKEWARM water for EXACTLY 30s (then rinse)',
        'Finish: Lukewarm rinse',
        'Pat face & beard completely dry with a new microfiber cloth (Do Skincare immediately while bathroom is humid)'
      ],
    );
  }


  static TimelineItem _morningReading(String time, {String additional = '', bool includeBagel = true}) {
    final bool showBagel = includeBagel && isRefeedWeek();
    return TimelineItem(
      time: time,
      title: 'Morning Reading' + (showBagel ? ' & Bagel' : ''),
      icon: '📖',
      details: [
        'Turn on Verilux HappyLight (45-degree angle to face)',
        if (showBagel) '🥯 REFEED WEEK: Eat 1 Plain Bagel',
        if (additional.isNotEmpty) additional,
      ],
      mealRecord: showBagel ? const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.bagel, amount: 1)]) : null,
    );
  }

  static TimelineItem _grabThings(String time, {
    bool zinc = false,
    int eggs = 3,
    int bananas = 0,
    int calciumCaps = 0,
    bool omega3 = true,
    bool copper = false,
  }) {
    final effectiveBananas = bananas + (isRefeedWeek() ? 2 : 0);
    final List<String> supplements = [
      'K2 (x2)',
      if (omega3) 'Omega-3',
      'Biotin+Keratin',
      if (zinc) 'Zinc Picolinate',
      if (calciumCaps > 0) 'Calcium Citrate',
      if (copper) 'Copper Glycinate',
    ];

    return TimelineItem(
      time: time,
      title: 'Grab things to take to work',
      icon: '🗂️',
      details: [
        'kindle/laptop',
        '2 key/wallet/phone',
        'airpods',
        'apple watch',
        'Supplements (${supplements.join(", ")})',
        'Pasta lunch',
        '$eggs Boiled Eggs',
        if (effectiveBananas > 0) '${effectiveBananas == 1 ? "1 banana" : "$effectiveBananas bananas"}',
        'water bottle'
      ],
    );
  }

  static TimelineItem _commuteToWork(String time) {
    return TimelineItem(time: time, title: 'Commute to Work', icon: '🚗');
  }

  static TimelineItem _work(String time, {List<String> details = const [], String title = 'Work', bool calcium = false}) {
    return TimelineItem(
      time: time, 
      title: title, 
      icon: '💻', 
      details: details,
    );
  }

  static TimelineItem _study(String time, {
    List<String> details = const [],
    bool calcium = false,
    int sleepKiwiCount = 0,
  }) {
    return TimelineItem(
      time: time,
      title: 'Study Time',
      icon: '📚',
      details: [
        ...details,
        if (sleepKiwiCount > 0) 'Halfway through (30m before bed prep): Eat $sleepKiwiCount Kiwi${sleepKiwiCount > 1 ? "s" : ""} & Swish water (protect enamel)',
      ],
      mealRecord: sleepKiwiCount > 0 ? MealRecord(items: [IngredientPortion(ingredient: IngredientsData.kiwi, amount: sleepKiwiCount.toDouble())]) : null,
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

  static TimelineItem _afternoonSnack(String time, {required int eggs, bool zinc = false, bool whey = false, bool vitamins = true, bool vitaminE = false, bool omega3 = true, bool copper = false, int bananaCount = 0}) {
    final effectiveBananaCount = bananaCount + (isRefeedWeek() ? 2 : 0);
    return TimelineItem(
      time: time,
      title: 'Afternoon Snack',
      icon: eggs > 0 ? '🥚' : '🥤',
      details: [
        if (eggs > 0) '$eggs Boiled Eggs',
        if (effectiveBananaCount > 0) '$effectiveBananaCount Banana${effectiveBananaCount > 1 ? 's' : ''}',
        if (vitamins) ...[
          if (omega3) '3 softgel omega-3',
          '2 standalone K2 (100mcg each)',
          '1 cap Biotin+Keratin (10mg/500mg)',
          if (vitaminE) '1 softgel Vitamin E (267mg)',
        ],
        if (zinc) '1 cap Zinc Picolinate (30mg)',
        if (copper) '1 cap Copper Glycinate (3mg)',
        if (whey) '1 scoop whey isolate (30g protein)',
        if (whey) '1 scoop creatine monohydrate (5g)',
        'Swish/drink water after eating/drinking to clear mouth',
      ],
      mealRecord: MealRecord(items: [
        if (eggs > 0) IngredientPortion(ingredient: IngredientsData.egg, amount: eggs.toDouble()),
        if (effectiveBananaCount > 0) IngredientPortion(ingredient: IngredientsData.banana, amount: effectiveBananaCount.toDouble()),
        if (vitamins && omega3) _Portions.omega3,
        if (vitamins) const IngredientPortion(ingredient: IngredientsData.standaloneK2, amount: 2),
        if (vitamins) _Portions.biotin,
        if (vitamins && vitaminE) _Portions.vitaminE,
        if (zinc) _Portions.zinc,
        if (copper) const IngredientPortion(ingredient: IngredientsData.copperGlycinate, amount: 1),
        if (whey) const IngredientPortion(ingredient: IngredientsData.wheyIsolate, amount: 1),
        if (whey) _Portions.creatine,
      ]),
    );
  }

  static TimelineItem _preMedicationBuffer(String time, {bool zinc = false, bool vitaminE = true}) {
    return TimelineItem(
      time: time,
      title: 'Pre-Medication Buffer',
      icon: '🥚',
      details: [
        '2 Boiled Eggs',
        '3 softgel omega-3',
        '1 D3-K2',
        '1 standalone K2 (100mcg)',
        '1 cap Biotin+Keratin (10mg/500mg)',
        if (vitaminE) '1 softgel Vitamin E (267mg)',
        if (zinc) '1 cap Zinc Picolinate (30mg)',
      ],
      mealRecord: MealRecord(items: [
        const IngredientPortion(ingredient: IngredientsData.egg, amount: 2),
        ..._Portions.coreVitamins,
        if (vitaminE) _Portions.vitaminE,
        if (zinc) _Portions.zinc,
      ]),
    );
  }



  static TimelineItem _gym(String time, String title, {bool isCardio = false}) {
    return TimelineItem(
      time: time,
      title: title,
      icon: isCardio ? '🏃' : '🏋️',
      isCardio: isCardio,
    );
  }

  static TimelineItem _salmonDinner(String time, {bool withWheyCreatine = false, bool cook = false, bool copper = false, int bananaCount = 0}) {
    final showAshwagandha = !isAshwagandhaOff();
    return TimelineItem(
      time: time,
      title: 'Dinner' + (withWheyCreatine ? ' & Post-Workout Shake' : ''),
      icon: '🥗',
      details: [
        if (withWheyCreatine) '1 scoop whey isolate (30g protein)',
        if (withWheyCreatine) '1 scoop creatine monohydrate (5g)',
        if (bananaCount > 0) '$bananaCount Banana${bananaCount > 1 ? 's' : ''}',
        if (copper) 'Take 1 cap Copper Glycinate (3mg)',
        if (cook) 'Cook Salmon (3 portions)' else '1/3 lb Wild Sockeye Salmon', 
        if (showAshwagandha) '2 cap Ashwagandha',
        if (isRefeedWeek()) '🍚 REFEED WEEK: Include 0.5 cups (dry) cooked Quinoa',
      ],
      mealRecord: MealRecord(items: [
        if (withWheyCreatine) _Portions.whey,
        if (withWheyCreatine) _Portions.creatine,
        if (bananaCount > 0) IngredientPortion(ingredient: IngredientsData.banana, amount: bananaCount.toDouble()),
        if (copper) const IngredientPortion(ingredient: IngredientsData.copperGlycinate, amount: 1),
        if (showAshwagandha) const IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2),
      ], recipeItems: [
        _Recipes.salmon,
        if (isRefeedWeek()) _Recipes.quinoa,
      ]),
    );
  }

  static TimelineItem _beefDinner(String time, {bool withWheyCreatine = false, int bananaCount = 0}) {
    final showAshwagandha = !isAshwagandhaOff();
    return TimelineItem(
      time: time,
      title: 'Dinner' + (withWheyCreatine ? ' & Post-Workout Shake' : ''),
      icon: '🍛',
      details: [
        if (withWheyCreatine) '1 scoop whey isolate (30g protein)',
        if (withWheyCreatine) '1 scoop creatine monohydrate (5g)',
        if (bananaCount > 0) '$bananaCount Banana${bananaCount > 1 ? 's' : ''}',
        '1/4 pound ground beef', 
        if (showAshwagandha) '2 cap Ashwagandha',
        if (isRefeedWeek()) '🍚 REFEED WEEK: Include 0.5 cups (dry) cooked Quinoa',
      ],
      mealRecord: MealRecord(items: [
        if (withWheyCreatine) _Portions.whey,
        if (withWheyCreatine) _Portions.creatine,
        if (bananaCount > 0) IngredientPortion(ingredient: IngredientsData.banana, amount: bananaCount.toDouble()),
        if (showAshwagandha) const IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2),
      ], recipeItems: [
        _Recipes.beef,
        if (isRefeedWeek()) _Recipes.quinoa,
      ]),
    );
  }

  static TimelineItem _chores(String time, {int sleepKiwiCount = 0}) {
    return TimelineItem(
      time: time,
      title: 'Chores & Clean Up',
      icon: '🧼',
      details: [
        '1 scoop Casein + 1 tbsp Chia in 16oz water -> Swish/drink water after',
        'The 7 bottles water are separate from this. This is in addition to that. So 7 bottles + this.',
        if (sleepKiwiCount > 0) 'Eat $sleepKiwiCount Kiwi${sleepKiwiCount > 1 ? "s" : ""} now (30m before bed prep to protect enamel)',
      ], 
      mealRecord: MealRecord(items: [
        const IngredientPortion(ingredient: IngredientsData.casein, amount: 1),
        const IngredientPortion(ingredient: IngredientsData.chiaSeeds, amount: 1),
        if (sleepKiwiCount > 0) IngredientPortion(ingredient: IngredientsData.kiwi, amount: sleepKiwiCount.toDouble()),
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
        'Apply 5% AHA to underarms (Deodorant - Apply to BONE DRY skin)',
        'Moisturizer (CeraVe PM): 3.5 pumps (1 forehead, 0.5 left cheek, 0.5 right cheek, 0.5 ears, 1 neck) + Cetaphil Hydrating Eye Gel-Cream -> WAIT to dry',
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

  static const String _morningMoisturizer = 'Moisturizer (CeraVe PM): 2 pumps (0.5 forehead, 0.5 left cheek, 0.5 right cheek, 0.5 neck & ears) + Cetaphil Hydrating Eye Gel-Cream -> WAIT 30s';
  static const String _moisturizerAndSunscreen = 'Apply morning moisturizer (CeraVe PM) + Cetaphil Hydrating Eye Gel-Cream: 2 pumps (0.5 forehead, 0.5 left cheek, 0.5 right cheek, 0.5 neck & ears) -> WAIT 3m -> Supergoop Matte Mineral (Layer 1: 1/8 tsp total (dots on forehead, left cheek, right cheek, ears), then 1/8 tsp to neck -> WAIT 30s -> Layer 2: Repeat)';
  static const String _retinol = 'Retinol (Apply to BONE DRY skin to prevent irritation): 1.5 pumps (0.5 forehead, 0.25 left cheek, 0.25 right cheek, 0.5 neck) -> WAIT 1-2m';
  static const String _bha = 'Paula\'s Choice 2% BHA (Apply to BONE DRY skin to prevent irritation): 3 drops (1 forehead, 1 left cheek, 1 right cheek) -> WAIT 1-2m';
  static const String _joseon = 'Joseon Alpha-Arbutin (Apply to slightly damp skin): 4 drops (1 forehead, 1 left cheek, 1 right cheek, 1 neck) -> WAIT 1-2m';
  static const String _sunscreen = 'Wash hands -> Blotting Sheet (Place over oily area and press against skin for 3s, lift and press - no rubbing ever) -> Wash hands -> Supergoop Matte Mineral (Layer 1: 1/8 tsp total (dots on forehead, left cheek, right cheek, ears), then 1/8 tsp to neck -> WAIT 30s -> Layer 2: Repeat)';

  static String get _laundryFaceTowels => 'Laundry Cycle 1: Face Towels & Pillowcases (${isDeloadWeek() ? "5/5" : "3/5"} warmness) -> 1-2 tbsp Arm&Hammer w/ OxiClean. NO Fabric Softener (Dry on LOW heat)';
  static String get _laundryBathTowels => 'Laundry Cycle 2: Bath Towels & Washcloths (5/5 warmness) -> 2 tbsp Arm&Hammer w/ OxiClean + 1/3 cup Bleach + EXTRA RINSE (Dry on LOW heat)';
  static const String _laundryRegular = 'Laundry: Regular Wash (All other clothes/gym gear, 3/5 warmness) -> Arm&Hammer w/ OxiClean';

  static TimelineItem _preWorkoutBanana(String time) {
    return TimelineItem(
      time: time,
      title: 'Pre-Workout Banana',
      icon: '🍌',
      details: [
        'Eat banana (30-45m pre-workout) -> Swish/drink water after',
      ],
      mealRecord: const MealRecord(items: [
        IngredientPortion(ingredient: IngredientsData.banana, amount: 1)
      ]),
    );
  }

  static TimelineItem _commuteToGym(String time, {bool applySunscreen = false}) {
    return TimelineItem(
      time: time,
      title: 'Commute to Gym',
      icon: '🚗',
      details: [
        if (applySunscreen) _sunscreen,
      ],
    );
  }

  static Map<String, List<TimelineItem>> get schedules => {
    mon: [
      _wakeup('8:10-8:20 am'),
      _getReady('8:20-8:40 am', skincare: _morningMoisturizer, clothes: 'Get dressed'),
      _morningReading('8:40-8:50 am'),
      _work('8:50-12:00 pm', details: ['Boil 24 eggs (warm on counter 10m first)', _laundryFaceTowels, 'Run Dishwasher']),
      _pastaLunch('12:00-12:30 pm', calciumCaps: 3),
      _work('12:30-3:30 pm', details: [_laundryBathTowels]),
      _afternoonSnack('3:30-4:00 pm', eggs: 3, zinc: true, vitaminE: true, omega3: false),
      _work('4:00-5:00 pm'),
      TimelineItem(time: '5:00-5:10 pm', title: 'Commute Home', icon: '🚗'),
      _study('5:10-5:55 pm', details: ['Study (Beat traffic before gym)']),
      TimelineItem(time: '5:55-6:10 pm', title: 'Pre-Workout Banana & Get Dressed', icon: '🍌', details: ['Eat banana (30-45m pre-workout) -> Swish/drink water after', 'Get dressed for gym'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.banana, amount: 1)])),
      _commuteToGym('6:10-6:30 pm', applySunscreen: true),
      _gym('6:30-8:30 pm', 'Gym Session (Upper A)'),
      TimelineItem(time: '8:30-8:50 pm', title: 'Commute Home', icon: '🚗'),
      _salmonDinner('8:50-9:20 pm', withWheyCreatine: true, cook: true, bananaCount: 1),
      _chores('9:20-9:50 pm', sleepKiwiCount: 1),
      _bedPrep('9:50-10:20 pm', newBathTowel: true),
      _nightSupplement('10:20-10:50 pm', magAmount: 3, skincare: _retinol),
      _fallAsleep('10:50-11:20 pm'),
    ],
    tue: [
      _wakeup('8:10-8:20 am'),
      _getReady('8:20-8:40 am', skincare: _moisturizerAndSunscreen, clothes: 'Get dressed (cloud x 4)'),
      _morningReading('8:40-8:50 am'),
      _grabThings('8:50-8:55 am', zinc: true, omega3: false),
      _commuteToWork('8:55-9:00 am'),
      _work('9:00-12:00 pm'),
      _pastaLunch('12:00-12:30 pm'),
      _work('12:30-3:30 pm'),
      _afternoonSnack('3:30-3:45 pm', eggs: 3, zinc: true, omega3: false),
      _work('3:45-5:00 pm'),
      TimelineItem(time: '5:00-5:10 pm', title: 'Commute Home', icon: '🚗'),
      _study('5:10-5:55 pm', details: ['Study (Beat traffic before gym)']),
      TimelineItem(time: '5:55-6:10 pm', title: 'Pre-Workout Banana & Get Dressed', icon: '🍌', details: ['Eat banana (30-45m pre-workout) -> Swish/drink water after', 'Get dressed for gym'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.banana, amount: 1)])),
      _commuteToGym('6:10-6:30 pm'),
      _gym('6:30-8:30 pm', 'Gym Session (Lower A)'),
      TimelineItem(time: '8:30-8:50 pm', title: 'Commute Home', icon: '🚗'),
      _salmonDinner('8:50-9:20 pm', withWheyCreatine: true, copper: true, bananaCount: 1),
      _chores('9:20-9:50 pm', sleepKiwiCount: 2),
      _bedPrep('9:50-10:20 pm'),
      _nightSupplement('10:20-10:50 pm', magAmount: 3, skincare: _joseon),
      _fallAsleep('10:50-11:20 pm'),
    ],
    wed: [
      _wakeup('8:10-8:20 am', nac: true),
      _getReady('8:20-8:40 am', skincare: _moisturizerAndSunscreen, clothes: 'Get dressed (NK 9060/Bondi)'),
      _morningReading('8:40-8:50 am', additional: 'Take ground beef out of freezer to thaw in fridge'),
      _grabThings('8:50-8:55 am', zinc: false, eggs: 3, bananas: 1, calciumCaps: 3, omega3: false),
      _commuteToWork('8:55-9:00 am'),
      _work('9:00-12:00 pm'),
      _pastaLunch('12:00-12:30 pm', calciumCaps: 3),
      _work('12:30-3:30 pm'),
      _afternoonSnack('3:30-3:45 pm', eggs: 3, zinc: false, vitaminE: false, omega3: false, bananaCount: 1),
      _work('3:45-5:00 pm'),
      TimelineItem(time: '5:00-5:10 pm', title: 'Commute Home', icon: '🚗'),
      _study('5:10-6:05 pm', details: ['Study (Beat traffic before gym)']),
      TimelineItem(time: '6:05-6:20 pm', title: 'Get Dressed', icon: '👕', details: ['Get dressed for gym']),
      _commuteToGym('6:20-6:25 pm'),
      _gym('6:25-7:15 pm', 'Cardio (LISS) / Haircut', isCardio: true),
      TimelineItem(time: '7:15-7:20 pm', title: 'Commute Home', icon: '🚗'),
      _salmonDinner('7:20-8:20 pm', withWheyCreatine: true, bananaCount: 1),
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
      _morningReading('8:40-8:50 am'),
      TimelineItem(time: '8:50-9:25 am', title: 'Cook', icon: '🧑‍🍳', details: ['1lb ground beef (divide in 4, 4 fridge)']),
      _work('9:25-12:20 pm', details: [_laundryRegular, 'Run Dishwasher']),
      _pastaLunch('12:20-12:50 pm', calciumCaps: 3),
      _work('12:50-3:50 pm', details: ['Fold & Put Away Laundry']),
      _afternoonSnack('3:50-4:05 pm', eggs: 3, vitaminE: true),
      _work('4:05-5:35 pm'),
      TimelineItem(time: '5:35-5:50 pm', title: 'Pre-Workout Banana & Get Dressed', icon: '🍌', details: ['Eat banana (30-45m pre-workout) -> Swish/drink water after', 'Get dressed for gym'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.banana, amount: 1)])),
      _commuteToGym('5:50-6:10 pm', applySunscreen: true),
      _gym('6:10-8:10 pm', 'Gym Session (Upper B)'),
      TimelineItem(time: '8:10-8:30 pm', title: 'Commute Home', icon: '🚗'),
      _beefDinner('8:30-9:00 pm', withWheyCreatine: true, bananaCount: 1),
      _chores('9:00-9:30 pm', sleepKiwiCount: 1),
      _bedPrep('9:30-10:00 pm', newBathTowel: true),
      _nightSupplement('10:00-10:50 pm', magAmount: 2, skincare: _bha),
      _fallAsleep('10:50-11:20 pm'),
    ],
    fri: [
      _wakeup('8:10-8:20 am'),
      _getReady('8:20-8:40 am', skincare: _moisturizerAndSunscreen, clothes: 'Get dressed (cloud x 4)'),
      _morningReading('8:40-8:50 am'),
      _grabThings('8:50-8:55 am', copper: true),
      _commuteToWork('8:55-9:00 am'),
      _work('9:00-12:00 pm'),
      _pastaLunch('12:00-12:30 pm'),
      _work('12:30-3:30 pm'),
      _afternoonSnack('3:30-3:45 pm', eggs: 3, copper: true),
      _work('3:45-5:00 pm'),
      TimelineItem(time: '5:00-5:10 pm', title: 'Commute Home', icon: '🚗'),
      _study('5:10-5:55 pm', details: ['Study (Beat traffic before gym)']),
      TimelineItem(time: '5:55-6:10 pm', title: 'Pre-Workout Banana & Get Dressed', icon: '🍌', details: ['Eat banana (30-45m pre-workout) -> Swish/drink water after', 'Get dressed for gym'], mealRecord: const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.banana, amount: 1)])),
      _commuteToGym('6:10-6:30 pm'),
      _gym('6:30-8:30 pm', 'Gym Session (Lower B)'),
      TimelineItem(time: '8:30-8:50 pm', title: 'Commute Home', icon: '🚗'),
      _beefDinner('8:50-9:20 pm', withWheyCreatine: true, bananaCount: 1),
      _chores('9:20-9:50 pm', sleepKiwiCount: 2),
      _bedPrep('9:50-10:20 pm'),
      _nightSupplement('10:20-10:50 pm', magAmount: 3, skincare: _joseon),
      _fallAsleep('10:50-11:20 pm'),
    ],
    sat: [
      _wakeup('8:10-8:20 am'),
      _getReady('8:20-8:40 am', skincare: _morningMoisturizer, clothes: 'Get dressed for gym (Hoka Bondi 8)'),
      _preMedicationBuffer('8:40-8:45 am'),
      _morningReading('8:45-9:05 am', additional: '20mg adderall IR'),
      _study('9:05-10:35 am'),
      TimelineItem(time: '10:35-10:55 am', title: 'Diffuse Brain Rest', icon: '🧠', details: ['NO PHONE. Relax or nap on bed/chair. Close eyes and allow memory consolidation.']),
      _study('10:55-12:20 pm'),
      _pastaLunch('12:20-12:50 pm', calciumCaps: 3),
      _study('12:50-2:05 pm'),
      TimelineItem(time: '2:05-2:20 pm', title: 'Diffuse Brain Rest', icon: '🧠', details: ['NO PHONE. Relax or nap on bed/chair. Close eyes and allow memory consolidation.']),
      _study('2:20-3:50 pm'),
      _afternoonSnack('3:50-4:20 pm', eggs: 2, whey: true, vitamins: false, bananaCount: 1),
      _study('4:20-5:10 pm'),
      TimelineItem(time: '5:10-5:30 pm', title: 'Diffuse Brain Rest', icon: '🧠', details: ['NO PHONE. Relax or nap on bed/chair. Let mind wander completely.']),
      _study('5:30-6:20 pm'),
      _commuteToGym('6:20-6:25 pm', applySunscreen: true),
      _gym('6:25-7:15 pm', 'Cardio (LISS)', isCardio: true),
      TimelineItem(time: '7:15-7:20 pm', title: 'Commute Home', icon: '🚗'),
      _beefDinner('7:20-7:50 pm', withWheyCreatine: false, bananaCount: 1),
      _chores('7:50-8:50 pm', sleepKiwiCount: 1),
      _relaxOrCatchUp('8:50-9:35 pm'),
      _bedPrep('9:35-10:20 pm', hair: 'Nizoral 1% (5m lather)'),
      _nightSupplement('10:20-10:35 pm', magAmount: 2, magName: 'Magnesium', skincare: _bha, nac: true),
      _fallAsleep('10:35-11:05 pm'),
    ],
    sun: [
      _wakeup('8:10-8:20 am'),
      _getReady('8:20-8:40 am', skincare: _morningMoisturizer, clothes: 'Get dressed for shopping (NK 9060)'),
      _morningReading('8:40-9:35 am', includeBagel: false),
      _preMedicationBuffer('9:35-9:50 am'),
      _study('9:50-11:20 am', details: ['20mg adderall IR at 9:50am']),
      TimelineItem(time: '11:20-11:50 am', title: 'Diffuse Brain Rest', icon: '🧠', details: ['NO PHONE. Relax or nap on bed/chair to hit "save" on encoded information.']),
      _study('11:50-1:20 pm'),
      TimelineItem(
        time: '1:20-1:50 pm', 
        title: 'Lunch', 
        icon: '🍛', 
        details: [
          '1/4 pound ground beef', 
          '3 Boiled Eggs', 
          'Take 3 Calcium Citrate capsules (438mg) with meal', 
          '1 banana' + (isRefeedWeek() ? ' (+ 2 EXTRA Bananas for Refeed)' : '')
        ], 
        mealRecord: MealRecord(
          items: [
            _Portions.calciumCitrate, 
            const IngredientPortion(ingredient: IngredientsData.egg, amount: 3), 
            IngredientPortion(ingredient: IngredientsData.banana, amount: isRefeedWeek() ? 3 : 1)
          ], 
          recipeItems: [_Recipes.beef]
        )
      ),
      TimelineItem(
        time: '1:50-4:15 pm', 
        title: 'Grocery Shop & Pick up Chipotle', 
        icon: '🛒', 
        details: [
          _sunscreen, 
          'check what I have before going', 
          "Trader Joe's (all groceries are bought there)", 
          if (isNextWeekRefeedWeek()) '🛒 UPCOMING REFEED WEEK: Buy 1 pack of Plain Bagels, 14 extra Bananas (2/day), and 1 bag of Quinoa (if out)',
          'Pick up Chipotle for dinner so it\'s one trip'
        ]
      ),
      TimelineItem(
        time: '4:15-6:45 pm', 
        title: 'Cooking / Meal Prep', 
        icon: '🧑‍🍳', 
        details: [
          'Meal Prep: Pasta (6 portions)', 
          if (isNextWeekRefeedWeek()) '🧑‍🍳 UPCOMING REFEED WEEK: Cook a batch of Quinoa for the week\'s dinners',
          'Put ground beef in freezer'
        ]
      ),
      _relaxOrCatchUp('6:45-7:45 pm', title: 'Rest / Weekly Reflection'),
      TimelineItem(
        time: '7:45-8:15 pm', 
        title: 'Dinner (Heat up Chipotle)', 
        icon: '🌯', 
        details: [
          '1 scoop creatine monohydrate (5g)', 
          'Chipotle Bowl: double chicken, DOUBLE white rice, extra black beans, extra fajita veggies', 
          '1 banana', 
          if (!isAshwagandhaOff()) '2 cap Ashwagandha',
          if (isRefeedWeek()) '🍚 REFEED WEEK: Include 0.5 cups (dry) cooked Quinoa',
        ], 
        mealRecord: MealRecord(items: [
          _Portions.creatine, 
          const IngredientPortion(ingredient: IngredientsData.banana, amount: 1), 
          const IngredientPortion(ingredient: IngredientsData.chipotleBowl, amount: 1), 
          if (!isAshwagandhaOff()) const IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2),
        ], recipeItems: [
          if (isRefeedWeek()) _Recipes.quinoa,
        ])
      ),
      _chores('8:15-8:50 pm'),
      _bedPrep('8:50-9:50 pm'),
      _nightSupplement('9:50-10:05 pm', magAmount: 2, magName: 'Magnesium', skincare: _joseon, title: 'Night Supplement', nac: true),
      _relaxOrCatchUp('10:05-10:50 pm'),
      _fallAsleep('10:50-11:20 pm'),
    ],
  };
}


