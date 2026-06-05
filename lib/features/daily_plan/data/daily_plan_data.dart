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
  static final beef = RecipePortion(recipe: RecipeData.recipes.firstWhere((r) => r.id == 'quinoa_beef'), servings: 1);
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

  static TimelineItem _wakeup(String time, {bool nac = false, bool copper = false}) {
    return TimelineItem(
      time: time,
      title: 'Wakeup',
      icon: '☀️',
      details: [
        'Use bathroom',
        'Weight (Step on scale)',
        if (nac) 'Take 600mg NAC + 25mcg Selenium (Combo Pill)',
        'Take 250mg Citicoline (w/ 25mg Tyrosine)',
        if (copper) 'Take 1 cap Copper Glycinate (3mg)',
      ],
      mealRecord: MealRecord(items: [
        if (nac) const IngredientPortion(ingredient: IngredientsData.nac, amount: 1),
        const IngredientPortion(ingredient: IngredientsData.citicoline, amount: 1),
        if (copper) const IngredientPortion(ingredient: IngredientsData.copperGlycinate, amount: 1),
      ]),
    );
  }

  static TimelineItem _getReady(String time, {required String skincare, required String clothes}) {
    return TimelineItem(
      time: time,
      title: 'Get Ready',
      icon: '🚿',
      details: [
        'Set Dehumidifier to 69% -> Brush teeth',
        'Shower: Hair (60s warm massage) -> Body (Bioderma Atoderm Cleansing Oil, 1.5 pumps upper / 1.5 pumps lower, BARE HANDS ONLY)',
        'Face & neck: Wet face with LUKEWARM water. Lather a half-pump of Lipikar AP+ in wet hands first, then glide over face with zero pressure for EXACTLY 20s -> Rinse',
        'Finish: 15s full-body cold shock',
        'Dab face & neck with clean Washcloth #1 so there is no dripping water (it does not have to be bone-dry, it is ok if ascorbyl gets foamy)',
        'Ascorbyl 12%: 3 tiny drops for face, 2 for neck -> WAIT 90s',
        skincare,
        'Apply deodorant',
        clothes,
      ],
    );
  }

  static TimelineItem _bedPrep(String time, {String hair = '60s warm massage', bool cetirizine = false}) {
    return TimelineItem(
      time: time,
      title: 'Shower & Bed Prep',
      icon: '🚿',
      details: [
        if (cetirizine) '8:30 PM: Take 10mg Cetirizine (Zyrtec)',
        'Set Dehumidifier to 69% -> Pre-Shower: Rub 2-3 pumps dedicated Cleansing Oil on DRY face (30s) to melt sunscreen/sweat',
        'In-Shower: Wet hands, rub face/neck/ears to emulsify oil (15-20s) -> Rinse thoroughly',
        'Hair: $hair',
        'Body: Hold Washcloth under water until SOAKING wet. Pump 1 pump of Lipikar AP+ into cloth and rub together to build a rich foam cushion. Gently sweep foamy cloth over upper and, once done/rinsed another 1 pump for lower body (for frictionless gym maintenance)',
        'Face: Lather 1 pump of Lipikar AP+ in wet hands for 3-4s to build foam. Gently glide foam onto face/neck/ears with LUKEWARM water for EXACTLY 30s (then rinse)',
        'Finish: 15s full-body cold shock',
        'Pat face & beard completely dry with fresh Washcloth #2 (Do Skincare immediately while bathroom is humid)'
      ],
    );
  }


  static TimelineItem _morningReading(String time, {String additional = ''}) {
    return TimelineItem(
      time: time,
      title: 'Morning Reading',
      icon: '📖',
      details: [
        'Turn on Verilux HappyLight (45-degree angle to face)',
        if (additional.isNotEmpty) additional,
        'Set Dehumidifier to 30%',
      ],
    );
  }

  static TimelineItem _grabThings(String time, {
    bool zinc = false,
    int eggs = 3,
    int bananas = 1,
    bool husk = false,
    int calciumCaps = 0,
  }) {
    final List<String> supplements = ['D3/K2', 'K2', 'Omega-3', 'Biotin+Keratin'];
    if (zinc) supplements.add('Zinc Picolinate');
    if (calciumCaps > 0) supplements.add('Calcium Citrate');

    return TimelineItem(
      time: time,
      title: 'Grab things to take to work',
      icon: '🗂️',
      details: [
        'kindle/laptop',
        '2 key/wallet/phone',
        'airpods',
        'apple watch',
        'gym outfit',
        'Pasta lunch',
        '$eggs Boiled Eggs',
        'Supplements (${supplements.join(", ")})',
        if (husk) 'Dry Mix: 2 tsp husk + 1/8 tsp Morton Lite Salt',
        if (bananas > 0) '${bananas == 1 ? "1 banana" : "$bananas bananas"}',
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
    bool cetirizine = false,
  }) {
    return TimelineItem(
      time: time,
      title: 'Study Time',
      icon: '📚',
      details: [
        if (cetirizine) '8:30 PM: Take 10mg Cetirizine (Zyrtec)',
        ...details
      ],
    );
  }

  static TimelineItem _relaxOrCatchUp(String time, {String title = 'Relax / Catch up on reading', String icon = '🛋️'}) {
    return TimelineItem(
      time: time,
      title: title,
      icon: icon,
    );
  }

  static TimelineItem _preLunchFiber(String time) {
    return TimelineItem(
      time: time,
      title: 'Pre-Lunch Fiber',
      icon: '🥤',
      details: ['2 tsp husk + 1/8 tsp Morton Lite Salt in 16oz water (Drink 30m before lunch)'],
      mealRecord: const MealRecord(items: [
        IngredientPortion(ingredient: IngredientsData.psylliumHusk, amount: 2),
        IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 0.125)
      ]),
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

  static TimelineItem _afternoonSnack(String time, {required int eggs, bool zinc = false, bool whey = false, bool vitamins = true, bool vitaminE = false}) {
    return TimelineItem(
      time: time,
      title: 'Afternoon Snack',
      icon: eggs > 0 ? '🥚' : '🥤',
      details: [
        if (eggs > 0) '$eggs Boiled Eggs',
        if (vitamins) ...[
          '3 softgel omega-3',
          '1 D3-K2',
          '1 standalone K2 (100mcg)',
          '1 cap Biotin+Keratin (10mg/500mg)',
          if (vitaminE) '1 softgel Vitamin E (267mg)',
        ],
        if (zinc) '1 cap Zinc Picolinate (30mg)',
        if (whey) '1.5 scoops whey isolate (45g protein)',
        if (whey) '1 scoop creatine monohydrate (5g)',
      ],
      mealRecord: MealRecord(items: [
        if (eggs > 0) IngredientPortion(ingredient: IngredientsData.egg, amount: eggs.toDouble()),
        if (vitamins) ..._Portions.coreVitamins,
        if (vitamins && vitaminE) _Portions.vitaminE,
        if (zinc) _Portions.zinc,
        if (whey) const IngredientPortion(ingredient: IngredientsData.wheyIsolate, amount: 1.5),
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
    );
  }

  static TimelineItem _salmonDinner(String time, {bool withWheyCreatine = false}) {
    final showAshwagandha = !isAshwagandhaOff();
    return TimelineItem(
      time: time,
      title: 'Dinner' + (withWheyCreatine ? ' & Post-Workout Shake' : ''),
      icon: '🥗',
      details: [
        if (withWheyCreatine) '1 scoop whey isolate (30g protein)',
        if (withWheyCreatine) '1 scoop creatine monohydrate (5g)',
        '1/3 lb Wild Sockeye Salmon', 
        if (showAshwagandha) '2 cap Ashwagandha',
      ],
      mealRecord: MealRecord(items: [
        if (withWheyCreatine) _Portions.whey,
        if (withWheyCreatine) _Portions.creatine,
        if (showAshwagandha) const IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2),
      ], recipeItems: [_Recipes.salmon]),
    );
  }

  static TimelineItem _beefDinner(String time, {bool withWheyCreatine = false}) {
    final showAshwagandha = !isAshwagandhaOff();
    return TimelineItem(
      time: time,
      title: 'Dinner' + (withWheyCreatine ? ' & Post-Workout Shake' : ''),
      icon: '🍛',
      details: [
        if (withWheyCreatine) '1 scoop whey isolate (30g protein)',
        if (withWheyCreatine) '1 scoop creatine monohydrate (5g)',
        '1/4 cup quinoa + 1/4 pound ground beef', 
        if (showAshwagandha) '2 cap Ashwagandha',
      ],
      mealRecord: MealRecord(items: [
        if (withWheyCreatine) _Portions.whey,
        if (withWheyCreatine) _Portions.creatine,
        if (showAshwagandha) const IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2),
      ], recipeItems: [_Recipes.beef]),
    );
  }

  static TimelineItem _chores(String time, {bool cetirizine = false}) {
    return TimelineItem(
      time: time,
      title: 'Chores & Clean Up',
      icon: '🧼',
      details: [
        if (cetirizine) '8:30 PM: Take 10mg Cetirizine (Zyrtec)',
        '1 scoop Casein + 1 tbsp Chia in 16oz water',
        'The 7 bottles water are separate from this. This is in addition to that. So 7 bottles + this.',
      ], 
      mealRecord: const MealRecord(items: [
        IngredientPortion(ingredient: IngredientsData.casein, amount: 1),
        IngredientPortion(ingredient: IngredientsData.chiaSeeds, amount: 1)
      ]),
    );
  }

  static TimelineItem _nightSupplement(String time, {
    required String skincare, 
    int magAmount = 2, 
    String magName = 'Magnesium Glycinate',
    String title = 'Night Supplement + Read/Reflect',
  }) {
    return TimelineItem(
      time: time,
      title: title,
      icon: '🌙',
      details: [
        'Take $magAmount $magName + 1 tablet Finasteride (1mg)',
        skincare,
        'Moisturizer (CeraVe PM): 1 pea-size for face/ears -> 1 pea-size for neck -> WAIT to dry',
        'Set Dehumidifier to 30%',
      ],
      mealRecord: MealRecord(items: [
        IngredientPortion(ingredient: IngredientsData.rMagnesium, amount: magAmount.toDouble()),
        const IngredientPortion(ingredient: IngredientsData.finasteride, amount: 1)
      ]),
    );
  }

  static TimelineItem _fallAsleep(String time) {
    return TimelineItem(time: time, title: 'Fall Asleep', icon: '😴', details: ['Lights out, try to fall asleep within 30 min']);
  }

  static const String _morningMoisturizer = 'Moisturizer (CeraVe PM): 1 dime-size for face/ears, 1 pea-size for neck -> WAIT 30s';
  static const String _moisturizerAndSunscreen = 'Apply morning moisturizer (CeraVe PM): 1 dime-size for face/ears, 1 pea-size for neck -> WAIT 3m -> Supergoop Matte Mineral (Layer 1: 1/8 tsp (pea-size) to face/ears, then 1/8 tsp to neck -> WAIT 30s -> Layer 2: Repeat 1/8 tsp to face/ears, then 1/8 tsp to neck)';
  static const String _retinol = 'Retinol: 1 pea-sized pump ONLY for face -> 1/2 pea-sized pump for neck -> WAIT 1-2m';
  static const String _bha = 'Paula\'s Choice 2% BHA: Splash 3-4 drops in hands and pat into face (focus on bumps) -> Pat lightly on neck -> WAIT 1-2m';
  static const String _joseon = 'Joseon Alpha-Arbutin: 2 tiny drops ONLY for face -> 1 drop for neck -> WAIT 1-2m';
  static const String _sunscreen = 'Wash hands -> Blotting Sheet (Place over oily area and press against skin for 3s, lift and press - no rubbing ever) -> Wash hands -> Supergoop Matte Mineral (Layer 1: 1/8 tsp (pea-size) to face/ears, then 1/8 tsp to neck -> WAIT 30s -> Layer 2: Repeat 1/8 tsp to face/ears, then 1/8 tsp to neck)';

  static String get _laundryFaceTowels => 'Laundry Cycle 1: Face Towels & Pillowcases (${isDeloadWeek() ? "5/5" : "3/5"} warmness) -> 1-2 tbsp Arm&Hammer w/ OxiClean. NO Fabric Softener (Dry on LOW heat)';
  static String get _laundryBathTowels {
    final bool isBleachWeek = _currentWeekNumber % 2 == 0;
    return 'Laundry Cycle 2: Bath Towels${isBleachWeek ? " & Washcloths" : ""} (5/5 warmness) -> 2 tbsp Arm&Hammer w/ OxiClean${isBleachWeek ? " + 1/3 cup Bleach" : ""} + EXTRA RINSE (Dry on LOW heat)';
  }
  static const String _laundryRegular = 'Laundry: Regular Wash (All other clothes/gym gear, 3/5 warmness) -> Arm&Hammer w/ OxiClean';

  static TimelineItem _preWorkoutBanana1(String time) {
    return TimelineItem(
      time: time,
      title: 'Pre-Workout Banana 1',
      icon: '🍌',
      details: [
        'Eat 1st banana (45m pre-workout)',
      ],
      mealRecord: const MealRecord(items: [
        IngredientPortion(ingredient: IngredientsData.banana, amount: 1)
      ]),
    );
  }

  static TimelineItem _commuteToGym(String time, {bool preWorkoutBanana = false, bool applySunscreen = true}) {
    return TimelineItem(
      time: time,
      title: 'Commute to Gym',
      icon: '🚗',
      details: [
        if (applySunscreen) _sunscreen,
        if (preWorkoutBanana) 'Eat 2nd banana (15m pre-workout)',
      ],
      mealRecord: preWorkoutBanana ? const MealRecord(items: [IngredientPortion(ingredient: IngredientsData.banana, amount: 1)]) : null,
    );
  }

  static Map<String, List<TimelineItem>> get schedules => {
    mon: [
      _wakeup('7:30-7:35 am'),
      _getReady('7:35-8:15 am', skincare: _morningMoisturizer, clothes: 'Get dressed'),
      _morningReading('8:15-8:30 am'),
      _work('8:30-12:00 pm', details: [_laundryFaceTowels, 'Run Dishwasher']),
      _pastaLunch('12:00-12:30 pm', calciumCaps: 3),
      _work('12:30-3:30 pm', details: [_laundryBathTowels]),
      _afternoonSnack('3:30-4:00 pm', eggs: 2, zinc: true, vitaminE: true),
      _work('4:00-4:45 pm'),
      _preWorkoutBanana1('4:45-4:50 pm'),
      _work('4:50-5:00 pm'),
      _commuteToGym('5:00-5:30 pm', preWorkoutBanana: true),
      _gym('5:30-7:00 pm', 'Gym Session (Upper A)'),
      _salmonDinner('7:00-7:30 pm', withWheyCreatine: true),
      _chores('7:30-8:00 pm'),
      _study('8:00-9:00 pm', cetirizine: true),
      _bedPrep('9:00-10:00 pm'),
      _nightSupplement('10:00-10:30 pm', magAmount: 3, skincare: _retinol),
      _fallAsleep('10:30-11:00 pm'),
    ],
    tue: [
      _wakeup('7:30-7:35 am', copper: true),
      _getReady('7:35-8:15 am', skincare: _moisturizerAndSunscreen, clothes: 'Get dressed (cloud x 4)'),
      _morningReading('8:15-8:30 am'),
      _grabThings('8:30-8:35 am', zinc: true, bananas: 2),
      _commuteToWork('8:35-9:00 am'),
      _work('9:00-12:00 pm'),
      _pastaLunch('12:00-12:30 pm'),
      _work('12:30-3:30 pm'),
      _afternoonSnack('3:30-3:45 pm', eggs: 3, zinc: true),
      _work('3:45-4:45 pm'),
      _preWorkoutBanana1('4:45-4:50 pm'),
      _work('4:50-5:00 pm'),
      _commuteToGym('5:00-5:30 pm', preWorkoutBanana: true, applySunscreen: false),
      _gym('5:30-7:30 pm', 'Gym Session (Lower A)'),
      _salmonDinner('7:30-8:00 pm', withWheyCreatine: true),
      _chores('8:00-8:30 pm'),
      _study('8:30-9:30 pm', cetirizine: true),
      _bedPrep('9:30-10:00 pm'),
      _nightSupplement('10:00-10:30 pm', magAmount: 3, skincare: _joseon),
      _fallAsleep('10:30-11:00 pm'),
    ],
    wed: [
      _wakeup('7:30-7:35 am', nac: true),
      _getReady('7:35-8:15 am', skincare: _moisturizerAndSunscreen, clothes: 'Get dressed (NK 9060/Bondi)'),
      _morningReading('8:15-8:30 am', additional: 'Take ground beef out of freezer to thaw in fridge'),
      _grabThings('8:30-8:35 am', zinc: false, eggs: 3, bananas: 0, calciumCaps: 3),
      _commuteToWork('8:35-9:00 am'),
      _work('9:00-12:00 pm'),
      _pastaLunch('12:00-12:30 pm', calciumCaps: 3),
      _work('12:30-3:30 pm'),
      _afternoonSnack('3:30-3:45 pm', eggs: 3, zinc: false, vitaminE: false),
      _work('3:45-5:00 pm'),
      _commuteToGym('5:00-5:30 pm', preWorkoutBanana: false, applySunscreen: false),
      _gym('5:30-6:30 pm', 'Cardio (LISS) / Haircut', isCardio: true),
      _salmonDinner('6:30-7:30 pm', withWheyCreatine: true),
      _chores('7:30-8:00 pm'),
      _study('8:00-9:30 pm', cetirizine: true),
      _bedPrep('9:30-10:00 pm', hair: 'CeraVe Gentle Shampoo (45s lather)'),
      _nightSupplement('10:00-10:30 pm', magAmount: 2, skincare: _retinol),
      _fallAsleep('10:30-11:00 pm'),
    ],
    thu: [
      _wakeup('7:30-7:35 am'),
      _getReady('7:35-8:15 am', skincare: _morningMoisturizer, clothes: 'Get dressed'),
      _morningReading('8:15-8:30 am'),
      TimelineItem(time: '8:30-9:05 am', title: 'Cook', icon: '🧑‍🍳', details: ['1cup quinoa + 1lb ground beef (divide in 4, 4 fridge)']),
      _work('9:05-12:00 pm', details: [_laundryRegular, 'Run Dishwasher']),
      _pastaLunch('12:00-12:30 pm', calciumCaps: 3),
      _work('12:30-3:30 pm', details: ['Fold & Put Away Laundry']),
      _afternoonSnack('3:30-3:45 pm', eggs: 3, vitaminE: true),
      _work('3:45-4:45 pm'),
      _preWorkoutBanana1('4:45-4:50 pm'),
      _work('4:50-5:15 pm'),
      _commuteToGym('5:15-5:30 pm', preWorkoutBanana: true),
      _gym('5:30-7:15 pm', 'Gym Session (Upper B)'),
      _beefDinner('7:15-8:00 pm', withWheyCreatine: true),
      _chores('8:00-8:30 pm'),
      _bedPrep('8:30-9:15 pm', cetirizine: true),
      _nightSupplement('9:15-10:30 pm', magAmount: 2, skincare: _bha),
      _fallAsleep('10:30-11:00 pm'),
    ],
    fri: [
      _wakeup('7:30-7:35 am', copper: true),
      _getReady('7:35-8:15 am', skincare: _moisturizerAndSunscreen, clothes: 'Get dressed (cloud x 4)'),
      _morningReading('8:15-8:30 am'),
      _grabThings('8:30-8:35 am', bananas: 2),
      _commuteToWork('8:35-9:00 am'),
      _work('9:00-12:00 pm'),
      _pastaLunch('12:00-12:30 pm'),
      _work('12:30-3:30 pm'),
      _afternoonSnack('3:30-3:45 pm', eggs: 3),
      _work('3:45-4:45 pm'),
      _preWorkoutBanana1('4:45-4:50 pm'),
      _work('4:50-5:00 pm'),
      _commuteToGym('5:00-5:30 pm', preWorkoutBanana: true, applySunscreen: false),
      _gym('5:30-7:30 pm', 'Gym Session (Lower B)'),
      _beefDinner('7:30-8:00 pm', withWheyCreatine: true),
      _chores('8:00-8:30 pm'),
      _study('8:30-9:30 pm', cetirizine: true),
      _bedPrep('9:30-10:00 pm'),
      _nightSupplement('10:00-10:30 pm', magAmount: 3, skincare: _joseon),
      _fallAsleep('10:30-11:00 pm'),
    ],
    sat: [
      _wakeup('7:30-7:40 am', nac: true),
      _getReady('7:40-8:15 am', skincare: _morningMoisturizer, clothes: 'Get dressed for gym (Hoka Bondi 8)'),
      _preMedicationBuffer('8:15-8:20 am'),
      _morningReading('8:20-8:45 am', additional: '20mg adderall IR'),
      _study('8:45-10:15 am'),
      TimelineItem(time: '10:15-10:35 am', title: 'Diffuse Brain Rest', icon: '🧠', details: ['NO PHONE. Relax or nap on bed/chair. Close eyes and allow memory consolidation.']),
      _study('10:35-12:00 pm'),
      _pastaLunch('12:00-12:30 pm', calciumCaps: 3),
      _study('12:30-1:45 pm'),
      TimelineItem(time: '1:45-2:00 pm', title: 'Diffuse Brain Rest', icon: '🧠', details: ['NO PHONE. Relax or nap on bed/chair. Close eyes and allow memory consolidation.']),
      _study('2:00-3:30 pm'),
      _afternoonSnack('3:30-4:00 pm', eggs: 0, whey: true, vitamins: false),
      _study('4:00-4:50 pm'),
      TimelineItem(time: '4:50-5:10 pm', title: 'Diffuse Brain Rest', icon: '🧠', details: ['NO PHONE. Relax or nap on bed/chair. Let mind wander completely.']),
      _study('5:10-6:00 pm'),
      _commuteToGym('6:00-6:20 pm', preWorkoutBanana: false),
      _gym('6:20-7:20 pm', 'Cardio (LISS)', isCardio: true),
      TimelineItem(time: '7:20-7:30 pm', title: 'Commute Home', icon: '🚗'),
      _beefDinner('7:30-8:00 pm', withWheyCreatine: false),
      _chores('8:00-9:00 pm', cetirizine: true),
      _bedPrep('9:15-10:00 pm', hair: 'Nizoral 1% (5m lather)'),
      _nightSupplement('10:00-10:15 pm', magAmount: 2, magName: 'Magnesium', skincare: _bha),
      _fallAsleep('10:15-10:45 pm'),
    ],
    sun: [
      _wakeup('7:30-7:35 am', nac: true),
      _getReady('7:35-8:20 am', skincare: _morningMoisturizer, clothes: 'Get dressed for shopping (NK 9060)'),
      _morningReading('8:20-9:15 am'),
      _preMedicationBuffer('9:15-9:30 am'),
      _study('9:30-11:00 am', details: ['20mg adderall IR at 9:30am']),
      TimelineItem(time: '11:00-11:30 am', title: 'Diffuse Brain Rest', icon: '🧠', details: ['NO PHONE. Relax or nap on bed/chair to hit "save" on encoded information.']),
      _study('11:30-12:30 pm'),
      _preLunchFiber('12:30-1:00 pm'),
      TimelineItem(time: '1:00-1:30 pm', title: 'Lunch', icon: '🍛', details: ['1/4 cup quinoa + 1/4 pound ground beef', 'Take 3 Calcium Citrate capsules (438mg) with meal'], mealRecord: MealRecord(items: [_Portions.calciumCitrate], recipeItems: [_Recipes.beef])),
      TimelineItem(time: '1:30-3:30 pm', title: 'Grocery Shop', icon: '🛒', details: [_sunscreen, 'check what I have before going', "Trader Joe's (all groceries are bought there)"]),
      TimelineItem(time: '3:30-6:00 pm', title: 'Cooking / Meal Prep', icon: '🧑‍🍳', details: ['Meal Prep: Pasta, Salmon, 18 Eggs', 'Put ground beef in freezer']),
      _relaxOrCatchUp('6:00-7:00 pm', title: 'Rest / Weekly Reflection'),
      TimelineItem(time: '7:00-7:25 pm', title: 'Dinner & Post-Workout Shake', icon: '🌯', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)', 'Chipotle Bowl: double chicken, normal brown rice/black beans, extra fajita veggies', if (!isAshwagandhaOff()) '2 cap Ashwagandha'], mealRecord: MealRecord(items: [_Portions.whey, _Portions.creatine, const IngredientPortion(ingredient: IngredientsData.chipotleBowl, amount: 1), if (!isAshwagandhaOff()) const IngredientPortion(ingredient: IngredientsData.ashwagandha, amount: 2)])),
      _chores('7:25-8:00 pm'),
      _bedPrep('8:00-9:00 pm', cetirizine: true),
      _nightSupplement('9:00-9:15 pm', magAmount: 2, magName: 'Magnesium', skincare: _joseon, title: 'Night Supplement'),
      _relaxOrCatchUp('9:15-10:00 pm'),
      _fallAsleep('10:00-10:30 pm'),
    ],
  };
}


