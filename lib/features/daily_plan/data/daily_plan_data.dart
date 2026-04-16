class TimelineItem {
  final String time;
  final String title;
  final String icon;
  final List<String> details;

  const TimelineItem({
    required this.time,
    required this.title,
    required this.icon,
    this.details = const [],
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
   * - Copper Glycinate: 3mg (Balances the zinc at lunch)
   * - Biotin/Keratin: 10mg / 500mg (Standard for hair/skin)
   * - Omega-3: 3 softgels containing 2160mg total (1300mg EPA / 860mg DHA) (Excellent therapeutic dose)
   * 
   * Mid-Day:
   * - Zinc Picolinate: 30mg (Well within the 40mg upper limit, safely balanced by morning Copper)
   * - D3-K2: 2 capsules providing 2000 IU D3 + 90mcg K2 (Optimal, moderate dose for daily use)
   * 
   * Evening/Night:
   * - Ashwagandha: 2 capsules = 500mg of 25:1 extract (equiv 12500mg root) + 5mg black pepper extract.
   *   [Safety Note: Research shows 500-600mg is the optimal clinical dose for maximizing testosterone, strength, and muscle hypertrophy. Because this is a high-potency dose, the 8-weeks on / 4-weeks off cycle is mandatory to prevent emotional blunting while keeping maximum gains.]
   * - Magnesium Glycinate: 2-3 capsules providing 180mg-270mg elemental magnesium (90mg elemental per capsule from 500mg mag glycinate). (Completely safe, well below the 350mg supplement upper limit).
   */

  // Plan start date — April 13, 2026 (Monday)
  static final DateTime planStartDate = DateTime(2026, 4, 13);

  /// Deload: every 6th week (weeks 6, 12, 18, ...)
  static bool isDeloadWeek() {
    final now = DateTime.now();
    final diff = now.difference(planStartDate).inDays;
    if (diff < 0) return false;
    final weekNumber = (diff ~/ 7) + 1;
    return weekNumber % 6 == 0;
  }

  /// Ashwagandha: 8 weeks on, 4 weeks off (12-week cycle)
  static bool isAshwagandhaOff() {
    final now = DateTime.now();
    final diff = now.difference(planStartDate).inDays;
    if (diff < 0) return false;
    final weekNumber = (diff ~/ 7) + 1;
    final posInCycle = ((weekNumber - 1) % 12) + 1;
    return posInCycle > 8;
  }

  static const Map<String, int> waterBottles = {
    'mon': 7,
    'tue': 7,
    'wed': 7,
    'thu': 7,
    'fri': 7,
    'sat': 7,
    'sun': 7,
  };

  static const Map<String, List<TimelineItem>> schedules = {
    'mon': [
      TimelineItem(time: '7:00-7:05 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '7:05-7:25 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'wash face + Ascorbyl Glucoside 12% (wait 60s)', 'CeraVe moisturizer', 'get dressed (NK 9060/Bondi)', 'put on sunscreen']),
      TimelineItem(time: '7:25-8:00 am', title: 'Morning Reading', icon: '📖', details: ['reading']),
      TimelineItem(time: '8:00-8:25 am', title: 'Breakfast', icon: '🍳', details: ['1tsp oil + 3 scrambled eggs w/ 1/5 bag spinach', '1 capsule citicoline', '1 cap Copper Glycinate (3mg)', '1 cap Biotin+Keratin (10mg/500mg)', '2 cup 2% ultra-pasteurized milk w/ 2 tbsp peanut butter', '💧 1 bottle water']),
      TimelineItem(time: '8:25-8:35 am', title: 'Grab things to take to work', icon: '🗂️', details: ['1 cap Zinc Picolinate', 'Pasta lunch', '2tsp husk', 'kindle/laptop', '2 D3-K2 capsules', 'gym outfit', 'micellar wipes', 'sunscreen', '1 banana', '2 key/wallet/phone', 'airpods', 'water bottle']),
      TimelineItem(time: '8:35-9:00 am', title: 'Commute to Work', icon: '🚗'),
      TimelineItem(time: '9:00-12:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water']),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🥗', details: ['1 cap Zinc Picolinate (30mg)', '1 serving of my pasta', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '12:30-5:00 pm', title: 'Work', icon: '💻', details: ['💧 2 bottle water with 2 tsp husk at 2:30pm']),
      TimelineItem(time: '5:00-5:30 pm', title: 'Commute To Gym', icon: '🚗', details: ['micellar wipe + reapply sunscreen', '1 banana (pre-workout)']),
      TimelineItem(time: '5:30-7:00 pm', title: 'Gym Session (Upper A)', icon: '🏋️', details: ['Includes the 15 min travel time back home', '💧 1 bottle water']),
      TimelineItem(time: '7:00-7:15 pm', title: 'Post-Workout', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)']),
      TimelineItem(time: '7:15-7:30 pm', title: 'Dinner', icon: '🍝', details: ['1/3 lb Wild Sockeye Salmon', '💧 1 bottle water']),
      TimelineItem(time: '7:30-8:00 pm', title: 'Chores & Clean Up', icon: '🧼'),
      TimelineItem(time: '8:00-9:00 pm', title: 'Study Time', icon: '📚', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwagandha']),
      TimelineItem(time: '9:00-10:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['minoxidil treatment brush on beard (wait until face is dry)']),
      TimelineItem(time: '10:00-11:00 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['3 Magnesium Glycinate capsule', 'Cerave Moisturizer', 'Retinol Serum']),
    ],
    'tue': [
      TimelineItem(time: '7:00-7:05 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '7:05-7:15 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'wash face + Ascorbyl Glucoside 12% (wait 60s)', 'CeraVe moisturizer', 'get dressed', 'NO sunscreen']),
      TimelineItem(time: '7:15-7:45 am', title: 'Morning Reading', icon: '📖', details: ['reading']),
      TimelineItem(time: '7:45-8:10 am', title: 'Breakfast', icon: '🍳', details: ['1tsp oil + 2 scrambled eggs w/ 1/5 (2nd) bag spinach', '1 capsule citicoline', '1 cap Copper Glycinate (3mg)', '1 cap Biotin+Keratin (10mg/500mg)', '1 cup 2% ultra-pasteurized milk w/ 1 tiny avocado', '3 softgel (not serving) omega-3', '💧 1 bottle water']),
      TimelineItem(time: '8:10-9:05 am', title: 'Cook', icon: '🧑‍🍳', details: ['1cup quinoa + 1lb prepped chicken (divide in 4, 4 fridge)']),
      TimelineItem(time: '9:05-12:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water', 'Laundry + Dishwasher']),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🍛', details: ['1 cap Zinc Picolinate (30mg)', '1 serving of my pasta', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '12:30-4:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water', 'Laundry + Dishwasher']),
      TimelineItem(time: '4:00-4:15 pm', title: 'Snack Break', icon: '🥤', details: ['1/3 container Raspberries', '1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)', '💧 1 bottle water']),
      TimelineItem(time: '4:15-5:00 pm', title: 'Work/Study', icon: '💻', details: ['Depending on your workload, study or work']),
      TimelineItem(time: '5:00-6:30 pm', title: 'Cardio (LISS)', icon: '🏃', details: ['micellar wipe + sunscreen before leaving', '30 min walk + 15 min stretch (see Gym Plan → Cardio)', 'Every 2-3 weeks: swap for haircut', '💧 1 bottle water']),
      TimelineItem(time: '6:30-7:30 pm', title: 'Dinner', icon: '🍗', details: ['1/4 cup quinoa + 1/4 pound chicken breast', '1/4 cup almonds', '💧 1 bottle water']),
      TimelineItem(time: '7:30-8:15 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwagandha']),
      TimelineItem(time: '8:15-9:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['minoxidil treatment brush on beard (wait until face is dry)']),
      TimelineItem(time: '9:00-11:00 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['2 Magnesium Glycinate capsule', 'Cerave Moisturizer', 'Joseon alpha-arbutin']),
    ],
    'wed': [
      TimelineItem(time: '7:00-7:05 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '7:05-7:25 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'wash face + Ascorbyl Glucoside 12% (wait 60s)', 'CeraVe moisturizer', 'get dressed (cloud x 4)', 'put on sunscreen']),
      TimelineItem(time: '7:25-8:00 am', title: 'Morning Reading', icon: '📖', details: ['reading']),
      TimelineItem(time: '8:00-8:25 am', title: 'Breakfast', icon: '🍳', details: ['1tsp oil + 3 scrambled eggs w/ .5 mushroom', '1 capsule citicoline', '1 cap Copper Glycinate (3mg)', '1 cap Biotin+Keratin (10mg/500mg)', '1 tiny avocado w/ 2 tbsp peanut butter', '💧 1 bottle water']),
      TimelineItem(time: '8:25-8:35 am', title: 'Grab things to take to work', icon: '🗂️', details: ['1 cap Zinc Picolinate', 'Pasta lunch', '1tsp husk', 'kindle/laptop', '2 D3-K2 capsules', 'gym outfit', 'micellar wipes', 'sunscreen', '1 banana', '2 key/wallet/phone', 'airpods', 'water bottle']),
      TimelineItem(time: '8:35-9:00 am', title: 'Commute to Work', icon: '🚗'),
      TimelineItem(time: '9:00-12:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water']),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🥗', details: ['1 cap Zinc Picolinate (30mg)', '1 serving of my pasta', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '12:30-5:00 pm', title: 'Work', icon: '💻', details: ['💧 2 bottle water with 1 tsp husk at 2:30pm']),
      TimelineItem(time: '5:00-5:30 pm', title: 'Commute To Gym', icon: '🚗', details: ['micellar wipe + reapply sunscreen', '1 banana (pre-workout)']),
      TimelineItem(time: '5:30-7:30 pm', title: 'Gym Session (Lower A)', icon: '🏋️', details: ['Includes the 15 min travel time back home', '💧 1 bottle water']),
      TimelineItem(time: '7:30-7:40 pm', title: 'Post-Workout', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)']),
      TimelineItem(time: '7:40-8:00 pm', title: 'Dinner', icon: '🍝', details: ['1/3 lb Wild Sockeye Salmon', '💧 1 bottle water']),
      TimelineItem(time: '8:00-8:30 pm', title: 'Chores & Clean Up', icon: '🧼'),
      TimelineItem(time: '8:30-9:30 pm', title: 'Study Time', icon: '📚', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwagandha']),
      TimelineItem(time: '9:30-10:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['minoxidil treatment brush on beard (wait until face is dry)']),
      TimelineItem(time: '10:00-11:00 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['3 Magnesium Glycinate capsule', 'Cerave Moisturizer', 'Retinol Serum']),
    ],
    'thu': [
      TimelineItem(time: '7:00-7:05 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '7:05-7:15 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'wash face + Ascorbyl Glucoside 12% (wait 60s)', 'CeraVe moisturizer', 'get dressed', 'NO sunscreen']),
      TimelineItem(time: '7:15-7:45 am', title: 'Morning Reading', icon: '📖', details: ['reading']),
      TimelineItem(time: '7:45-8:10 am', title: 'Breakfast', icon: '🍳', details: ['1tsp oil + 2 scrambled eggs w/ 1/5 (3rd) bag spinach', '1 capsule citicoline', '1 cap Copper Glycinate (3mg)', '1 cap Biotin+Keratin (10mg/500mg)', '1 cup 2% ultra-pasteurized milk w/ 1 tiny avocado', '3 softgel (not serving) omega-3', '💧 1 bottle water']),
      TimelineItem(time: '8:10-12:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water', 'Laundry + Dishwasher']),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🍛', details: ['1 cap Zinc Picolinate (30mg)', '1 serving of my pasta', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '12:30-4:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water', 'Laundry + Dishwasher']),
      TimelineItem(time: '4:00-4:15 pm', title: 'Snack Break', icon: '🥤', details: ['1/3 (2nd) container Raspberries', '1 banana (pre-workout)', '💧 1 bottle water']),
      TimelineItem(time: '4:15-5:30 pm', title: 'Work/Study', icon: '💻', details: ['Depending on your workload, work or study']),
      TimelineItem(time: '5:30-7:15 pm', title: 'Gym Session (Upper B)', icon: '🏋️', details: ['micellar wipe + sunscreen before leaving', 'Includes 20 min travel each way', '💧 1 bottle water']),
      TimelineItem(time: '7:15-7:30 pm', title: 'Post-Workout', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)']),
      TimelineItem(time: '7:30-8:00 pm', title: 'Dinner', icon: '🍗', details: ['1/4 cup quinoa + 1/4 pound chicken breast', '1/4 cup almonds', '💧 1 bottle water']),
      TimelineItem(time: '8:00-8:30 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwagandha']),
      TimelineItem(time: '8:30-9:15 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['minoxidil treatment brush on beard (wait until face is dry)']),
      TimelineItem(time: '9:15-11:00 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['2 Magnesium Glycinate capsule', 'Cerave Moisturizer', 'Joseon alpha-arbutin']),
    ],
    'fri': [
      TimelineItem(time: '7:00-7:05 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '7:05-7:25 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'wash face + Ascorbyl Glucoside 12% (wait 60s)', 'CeraVe moisturizer', 'get dressed (cloud x 4)', 'put on sunscreen']),
      TimelineItem(time: '7:25-8:00 am', title: 'Morning Reading', icon: '📖', details: ['reading']),
      TimelineItem(time: '8:00-8:25 am', title: 'Breakfast', icon: '🍳', details: ['1tsp oil + 3 scrambled eggs w/ 1/5 (4th) bag spinach', '1 capsule citicoline', '1 cap Copper Glycinate (3mg)', '1 cap Biotin+Keratin (10mg/500mg)', '1 tiny avocado', '2 cup 2% ultra-pasteurized milk w/ 2 tbsp peanut butter', '💧 1 bottle water']),
      TimelineItem(time: '8:25-8:35 am', title: 'Grab things to take to work', icon: '🗂️', details: ['1 cap Zinc Picolinate', 'Pasta lunch', '1tsp husk', 'kindle/laptop', '2 D3-K2 capsules', 'gym outfit', 'micellar wipes', 'sunscreen', '1 banana', '2 key/wallet/phone', 'airpods', 'water bottle']),
      TimelineItem(time: '8:35-9:00 am', title: 'Commute to Work', icon: '🚗'),
      TimelineItem(time: '9:00-12:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water']),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🥗', details: ['1 cap Zinc Picolinate (30mg)', '1 serving of my pasta', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '12:30-5:00 pm', title: 'Work', icon: '💻', details: ['💧 2 bottle water with 1 tsp husk at 2:30pm']),
      TimelineItem(time: '5:00-5:30 pm', title: 'Commute to Gym', icon: '🚗', details: ['micellar wipe + reapply sunscreen', '1 banana (pre-workout)']),
      TimelineItem(time: '5:30-7:30 pm', title: 'Gym Session (Lower B)', icon: '🏋️', details: ['Includes the 15 min travel time back home', '💧 1 bottle water']),
      TimelineItem(time: '7:30-7:40 pm', title: 'Post-Workout', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)']),
      TimelineItem(time: '7:40-8:00 pm', title: 'Dinner', icon: '🍝', details: ['1/3 lb Wild Sockeye Salmon', '💧 1 bottle water']),
      TimelineItem(time: '8:00-8:30 pm', title: 'Chores & Clean Up', icon: '🧼'),
      TimelineItem(time: '8:30-9:30 pm', title: 'Study Time', icon: '📚', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwagandha']),
      TimelineItem(time: '9:30-10:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['minoxidil treatment brush on beard (wait until face is dry)']),
      TimelineItem(time: '10:00-11:00 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['3 Magnesium Glycinate capsule', 'Cerave Moisturizer', 'Retinol Serum']),
    ],
    'sat': [
      TimelineItem(time: '7:00-7:20 am', title: 'Wakeup', icon: '☀️'),
      TimelineItem(time: '7:20-7:40 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'wash face + Ascorbyl Glucoside 12% (wait 60s)', 'CeraVe moisturizer', 'get dressed for gym (Hoka Bondi 8)']),
      TimelineItem(time: '7:40-8:10 am', title: 'Breakfast', icon: '🍳', details: ['1tsp oil + 3 scrambled eggs w/ .5 mushroom', '1 cap Copper Glycinate (3mg)', '1 cap Biotin+Keratin (10mg/500mg)', '1 tiny avocado w/ 2 tbsp peanut butter', '3 softgel (not serving) omega-3', '💧 1 bottle water']),
      TimelineItem(time: '8:10-8:45 am', title: 'Relax', icon: '📖', details: ['20mg adderall IR']),
      TimelineItem(time: '8:45-12:00 pm', title: 'Study', icon: '📚', details: ['💧 1 bottle water']),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🍛', details: ['1/4 cup quinoa + 1/4 pound chicken breast', '1 cap Zinc Picolinate (30mg)', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '12:30-1:30 pm', title: 'Study', icon: '📚'),
      TimelineItem(time: '1:30-1:40 pm', title: 'Snack Break', icon: '🥤', details: ['1/4 cup almonds', '1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)', '💧 1 bottle water']),
      TimelineItem(time: '1:40-2:00 pm', title: 'Reflection/Revision', icon: '🔄', details: ['Has this plan been working?']),
      TimelineItem(time: '2:00-6:00 pm', title: 'Study', icon: '📚', details: ['💧 1 bottle water']),
      TimelineItem(time: '6:00-6:20 pm', title: 'Commute to Gym', icon: '🚗', details: ['micellar wipe + sunscreen before leaving']),
      TimelineItem(time: '6:20-7:20 pm', title: 'Cardio (HIIT)', icon: '🔥', details: ['8x sprints + cooldown (see Gym Plan → Cardio)', '💧 1 bottle water']),
      TimelineItem(time: '7:20-7:30 pm', title: 'Commute Home', icon: '🚗'),
      TimelineItem(time: '7:30-8:00 pm', title: 'Dinner', icon: '🍗', details: ['1 serving of my pasta', '💧 1 bottle water']),
      TimelineItem(time: '8:00-9:00 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwagandha']),
      TimelineItem(time: '9:15-10:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['minoxidil treatment brush on beard (wait until face is dry)']),
      TimelineItem(time: '10:00-10:45 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['600mg NAC + 25mcg Selenium', '2 Magnesium Glycinate capsule', 'Cerave Moisturizer', 'Joseon alpha-arbutin']),
    ],
    'sun': [
      TimelineItem(time: '7:00-7:30 am', title: 'Wakeup + get ready', icon: '☀️', details: ['brush teeth', 'wash face + Ascorbyl Glucoside 12% (wait 60s)', 'CeraVe moisturizer', 'get dressed for shopping (NK 9060)']),
      TimelineItem(time: '7:30-9:00 am', title: 'Morning Reading', icon: '📖', details: ['reading']),
      TimelineItem(time: '9:00-9:30 am', title: 'Breakfast', icon: '🍳', details: ['1tsp oil + 3 scrambled eggs', '1 cap Copper Glycinate (3mg)', '1 cap Biotin+Keratin (10mg/500mg)', '20mg adderall IR', '3 softgel (not serving) omega-3', '1 tbsp peanut butter w/ 1 tiny avocado', '💧 1 bottle water']),
      TimelineItem(time: '9:30-2:00 pm', title: 'Study Time', icon: '📚'),
      TimelineItem(time: '2:00-2:30 pm', title: 'Lunch', icon: '🍛', details: ['1/4 cup quinoa + 1/4 pound chicken breast', '1/4 cup almonds', '1 cap Zinc Picolinate (30mg)', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '2:30-3:30 pm', title: 'Grocery Shop', icon: '🛒', details: ['wash hand + put on sunscreen', 'check what I have before going', "Trader Joe's (all groceries are bought there)", '💧 1 bottle water + 1 scoop Greens Powder']),
      TimelineItem(time: '3:30-6:00 pm', title: 'Cooking', icon: '🧑‍🍳', details: ['💧 2 bottle water with 4tsp husk at 4:30pm', '12oz chickpea fusilli pasta + 3lb ground turkey + 48oz marinara sauce + 2 can lentils + 2/4 cup nutritional yeast + 6 full chopped bell peppers (divide in 6, for fridge)', '1lb Wild Sockeye Salmon (divide in 3, 3 fridge)', 'PREP FOR TUE: Dice 1lb chicken + mix w/ seasonings (store in airtight container)']),
      TimelineItem(time: '6:00-6:15 pm', title: 'Snack', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '5g creatine', '1/3 (3rd) container Raspberries', '💧 1 bottle water']),
      TimelineItem(time: '6:15-7:00 pm', title: 'LISS Cardio Walk', icon: '🚶', details: ['micellar wipe + sunscreen before leaving', '30 min walk + 10 min stretch (see Gym Plan → Cardio)']),
      TimelineItem(time: '7:00-7:25 pm', title: 'Dinner', icon: '🥩', details: ['0.5 lbs top sirloin steak w/ 1/5 (5th) bag spinach', '2 cup (rest) 2% ultra-pasteurized milk']),
      TimelineItem(time: '7:25-8:00 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwagandha', '💧 1 bottle water']),
      TimelineItem(time: '8:00-9:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['Do Dermaroller (No minoxidil)']),
      TimelineItem(time: '9:00-9:15 pm', title: 'Night Supplement', icon: '🌙', details: ['600mg NAC + 25mcg Selenium', '2 Magnesium Glycinate capsule', 'Cerave Moisturizer']),
      TimelineItem(time: '9:15-10:30 pm', title: 'Read/Reflect & Sleep', icon: '😴'),
    ],
  };
}
