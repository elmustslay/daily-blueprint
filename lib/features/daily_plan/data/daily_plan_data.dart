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
    'tue': 6,
    'wed': 7,
    'thu': 7,
    'fri': 7,
    'sat': 7,
    'sun': 7,
  };

  static const Map<String, List<TimelineItem>> schedules = {
    'mon': [
      TimelineItem(time: '7:00-7:05 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '7:05-7:25 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'get dressed (NK 9060/Bondi)', 'put on sunscreen']),
      TimelineItem(time: '7:25-8:00 am', title: 'Morning Reading', icon: '📖', details: ['reading']),
      TimelineItem(time: '8:00-8:25 am', title: 'Breakfast', icon: '🍳', details: ['3 scrambled eggs w/ 1/5 bag spinach', '1 capsule citicoline', '2 cup 2% ultra-pasteurized milk w/ 2 tbsp peanut butter', '💧 1 bottle water']),
      TimelineItem(time: '8:25-8:35 am', title: 'Grab things to take to work', icon: '🗂️', details: ['Pasta lunch', '3tsp husk', 'kindle/laptop', 'the supplement capsule', 'gym outfit', '2 key/wallet/phone', 'airpods', 'water bottle']),
      TimelineItem(time: '8:35-9:00 am', title: 'Commute to Work', icon: '🚗'),
      TimelineItem(time: '9:00-12:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water']),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🥗', details: ['1 serving of my pasta', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '12:30-5:00 pm', title: 'Work', icon: '💻', details: ['💧 2 bottle water with 3 tsp husk at 2:30pm']),
      TimelineItem(time: '5:00-5:30 pm', title: 'Commute To Gym', icon: '🚗', details: ['Reapply Sunscreen', '1 banana (pre-workout)']),
      TimelineItem(time: '5:30-7:00 pm', title: 'Gym Session (Upper A)', icon: '🏋️', details: ['Includes the 15 min travel time back home', '💧 1 bottle water']),
      TimelineItem(time: '7:00-7:15 pm', title: 'Post-Workout', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)']),
      TimelineItem(time: '7:15-7:30 pm', title: 'Dinner', icon: '🍝', details: ['1/3 lb Wild Sockeye Salmon', '💧 1 bottle water']),
      TimelineItem(time: '7:30-8:00 pm', title: 'Chores & Clean Up', icon: '🧼'),
      TimelineItem(time: '8:00-9:00 pm', title: 'Study Time', icon: '📚', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwaganda']),
      TimelineItem(time: '9:00-10:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['minoxidil treatment brush on beard']),
      TimelineItem(time: '10:00-11:00 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['3 Magnesium Glycinate capsule', 'Cerave Moisturizer', 'Retinol Serum']),
    ],
    'tue': [
      TimelineItem(time: '7:00-7:05 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '7:05-7:15 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'get dressed', 'NO sunscreen']),
      TimelineItem(time: '7:15-7:45 am', title: 'Morning Reading', icon: '📖', details: ['reading']),
      TimelineItem(time: '7:45-8:10 am', title: 'Breakfast', icon: '🍳', details: ['2 scrambled eggs w/ 1/5 (2nd) bag spinach', '1 capsule citicoline', '1 cup 2% ultra-pasteurized milk w/ 1 tiny avocado', '3 softgel (not serving) omega-3', '💧 1 bottle water']),
      TimelineItem(time: '8:10-9:05 am', title: 'Cook', icon: '🧑‍🍳', details: ['1cup quinoa + 1lb prepped chicken (divide in 4, 4 fridge)']),
      TimelineItem(time: '9:05-12:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water', 'Laundry + Dishwasher']),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🍛', details: ['1 serving of my pasta', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '12:30-4:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water', 'Laundry + Dishwasher']),
      TimelineItem(time: '4:00-4:15 pm', title: 'Snack Break', icon: '🥤', details: ['1/3 container Raspberries', '1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)', '💧 1 bottle water']),
      TimelineItem(time: '4:15-5:00 pm', title: 'Work/Study', icon: '💻', details: ['Depending on your workload, study or work']),
      TimelineItem(time: '5:00-6:30 pm', title: 'Cardio (LISS)', icon: '🏃', details: ['Open Apple Watch → Workout → Outdoor Walk', '30 min incline walk (see Gym Plan → Cardio tab)', '15 min stretching/mobility', 'Every 2-3 weeks: swap for haircut']),
      TimelineItem(time: '6:30-7:30 pm', title: 'Dinner', icon: '🍗', details: ['1/4 cup quinoa + 1/4 pound chicken breast', '1/4 cup almonds', '💧 1 bottle water']),
      TimelineItem(time: '7:30-8:15 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwaganda']),
      TimelineItem(time: '8:15-9:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['minoxidil treatment brush on beard']),
      TimelineItem(time: '9:00-11:00 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['2 Magnesium Glycinate capsule', 'Cerave Moisturizer', 'Joseon alpha-arbutin']),
    ],
    'wed': [
      TimelineItem(time: '7:00-7:05 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '7:05-7:25 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'get dressed (cloud x 4)', 'put on sunscreen']),
      TimelineItem(time: '7:25-8:00 am', title: 'Morning Reading', icon: '📖', details: ['reading']),
      TimelineItem(time: '8:00-8:25 am', title: 'Breakfast', icon: '🍳', details: ['3 scrambled eggs w/ .5 mushroom', '1 capsule citicoline', '1 tiny avocado w/ 2 tbsp peanut butter', '💧 1 bottle water']),
      TimelineItem(time: '8:25-8:35 am', title: 'Grab things to take to work', icon: '🗂️', details: ['Pasta lunch', '2tsp husk', 'kindle/laptop', 'the supplement capsule', 'gym outfit', '2 key/wallet/phone', 'airpods', 'water bottle']),
      TimelineItem(time: '8:35-9:00 am', title: 'Commute to Work', icon: '🚗'),
      TimelineItem(time: '9:00-12:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water']),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🥗', details: ['1 serving of my pasta', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '12:30-5:00 pm', title: 'Work', icon: '💻', details: ['💧 2 bottle water with 2 tsp husk at 2:30pm']),
      TimelineItem(time: '5:00-5:30 pm', title: 'Commute To Gym', icon: '🚗', details: ['Reapply Sunscreen', '1 banana (pre-workout)']),
      TimelineItem(time: '5:30-7:30 pm', title: 'Gym Session (Lower A)', icon: '🏋️', details: ['Includes the 15 min travel time back home', '💧 1 bottle water']),
      TimelineItem(time: '7:30-7:40 pm', title: 'Post-Workout', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)']),
      TimelineItem(time: '7:40-8:00 pm', title: 'Dinner', icon: '🍝', details: ['1/3 lb Wild Sockeye Salmon', '💧 1 bottle water']),
      TimelineItem(time: '8:00-8:30 pm', title: 'Chores & Clean Up', icon: '🧼'),
      TimelineItem(time: '8:30-9:30 pm', title: 'Study Time', icon: '📚', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwaganda']),
      TimelineItem(time: '9:30-10:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['minoxidil treatment brush on beard']),
      TimelineItem(time: '10:00-11:00 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['3 Magnesium Glycinate capsule', 'Cerave Moisturizer', 'Retinol Serum']),
    ],
    'thu': [
      TimelineItem(time: '7:00-7:05 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '7:05-7:15 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'get dressed', 'NO sunscreen']),
      TimelineItem(time: '7:15-7:45 am', title: 'Morning Reading', icon: '📖', details: ['reading']),
      TimelineItem(time: '7:45-8:10 am', title: 'Breakfast', icon: '🍳', details: ['2 scrambled eggs w/ 1/5 (3rd) bag spinach', '1 capsule citicoline', '1 cup 2% ultra-pasteurized milk w/ 1 tiny avocado', '3 softgel (not serving) omega-3', '💧 1 bottle water']),
      TimelineItem(time: '8:10-12:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water', 'Laundry + Dishwasher']),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🍛', details: ['1 serving of my pasta', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '12:30-4:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water', 'Laundry + Dishwasher']),
      TimelineItem(time: '4:00-4:15 pm', title: 'Snack Break', icon: '🥤', details: ['1/3 (2nd) container Raspberries', '1 banana (pre-workout)', '💧 1 bottle water']),
      TimelineItem(time: '4:15-5:30 pm', title: 'Work/Study', icon: '💻', details: ['Depending on your workload, work or study']),
      TimelineItem(time: '5:30-7:15 pm', title: 'Gym Session (Upper B)', icon: '🏋️', details: ['Includes 20 min travel each way', '💧 1 bottle water']),
      TimelineItem(time: '7:15-7:30 pm', title: 'Post-Workout', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)']),
      TimelineItem(time: '7:30-8:00 pm', title: 'Dinner', icon: '🍗', details: ['1/4 cup quinoa + 1/4 pound chicken breast', '1/4 cup almonds', '💧 1 bottle water']),
      TimelineItem(time: '8:00-8:30 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwaganda']),
      TimelineItem(time: '8:30-9:15 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['minoxidil treatment brush on beard']),
      TimelineItem(time: '9:15-11:00 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['2 Magnesium Glycinate capsule', 'Cerave Moisturizer', 'Joseon alpha-arbutin']),
    ],
    'fri': [
      TimelineItem(time: '7:00-7:05 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '7:05-7:25 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'get dressed (NK 9060/Bondi)', 'put on sunscreen']),
      TimelineItem(time: '7:25-8:00 am', title: 'Morning Reading', icon: '📖', details: ['reading']),
      TimelineItem(time: '8:00-8:25 am', title: 'Breakfast', icon: '🍳', details: ['3 scrambled eggs w/ 1/5 (4th) bag spinach', '1 capsule citicoline', '1 tiny avocado', '2 cup 2% ultra-pasteurized milk w/ 2 tbsp peanut butter', '💧 1 bottle water']),
      TimelineItem(time: '8:25-8:35 am', title: 'Grab things to take to work', icon: '🗂️', details: ['Pasta Lunch', '3tsp husk', 'kindle/laptop', 'the supplement capsule', 'gym outfit', '2 key/wallet/phone', 'airpods', 'water bottle']),
      TimelineItem(time: '8:35-9:00 am', title: 'Commute to Work', icon: '🚗'),
      TimelineItem(time: '9:00-12:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water']),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🥗', details: ['1 serving of my pasta', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '12:30-5:00 pm', title: 'Work', icon: '💻', details: ['💧 2 bottle water with 3 tsp husk at 2:30pm']),
      TimelineItem(time: '5:00-5:30 pm', title: 'Commute to Gym', icon: '🚗', details: ['Reapply Sunscreen', '1 banana (pre-workout)']),
      TimelineItem(time: '5:30-7:30 pm', title: 'Gym Session (Lower B)', icon: '🏋️', details: ['Includes the 15 min travel time back home', '💧 1 bottle water']),
      TimelineItem(time: '7:30-7:40 pm', title: 'Post-Workout', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)']),
      TimelineItem(time: '7:40-8:00 pm', title: 'Dinner', icon: '🍝', details: ['1/3 lb Wild Sockeye Salmon', '💧 1 bottle water']),
      TimelineItem(time: '8:00-8:30 pm', title: 'Chores & Clean Up', icon: '🧼'),
      TimelineItem(time: '8:30-9:30 pm', title: 'Study Time', icon: '📚', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwaganda']),
      TimelineItem(time: '9:30-10:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['minoxidil treatment brush on beard']),
      TimelineItem(time: '10:00-11:00 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['3 Magnesium Glycinate capsule', 'Cerave Moisturizer', 'Retinol Serum']),
    ],
    'sat': [
      TimelineItem(time: '7:00-7:20 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '7:20-7:40 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'get dressed for gym (Hoka Bondi 8)']),
      TimelineItem(time: '7:40-8:10 am', title: 'Breakfast', icon: '🍳', details: ['3 scrambled eggs w/ .5 mushroom', '1 tiny avocado w/ 2 tbsp peanut butter', '3 softgel (not serving) omega-3', '💧 1 bottle water']),
      TimelineItem(time: '8:10-8:45 am', title: 'Relax', icon: '📖', details: ['20mg adderall IR']),
      TimelineItem(time: '8:45-12:00 pm', title: 'Study', icon: '📚', details: ['💧 1 bottle water']),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🍛', details: ['1/4 cup quinoa + 1/4 pound chicken breast', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '12:30-1:30 pm', title: 'Study', icon: '📚'),
      TimelineItem(time: '1:30-1:40 pm', title: 'Snack Break', icon: '🥤', details: ['1/4 cup almonds', '1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)', '💧 1 bottle water']),
      TimelineItem(time: '1:40-2:00 pm', title: 'Reflection/Revision', icon: '🔄', details: ['Has this plan been working?']),
      TimelineItem(time: '2:00-6:00 pm', title: 'Study', icon: '📚', details: ['💧 1 bottle water with 1tsp at 2:30pm']),
      TimelineItem(time: '6:00-6:20 pm', title: 'Commute to Gym', icon: '🚗'),
      TimelineItem(time: '6:20-7:20 pm', title: 'Cardio (HIIT)', icon: '🔥', details: ['Open Apple Watch → Workout → HIIT', '8x sprint intervals (see Gym Plan → Cardio tab)', '💧 1 bottle water']),
      TimelineItem(time: '7:20-7:30 pm', title: 'Commute Home', icon: '🚗'),
      TimelineItem(time: '7:30-8:00 pm', title: 'Dinner', icon: '🍗', details: ['1 serving of my pasta', '💧 1 bottle water']),
      TimelineItem(time: '8:00-9:00 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwaganda']),
      TimelineItem(time: '9:15-10:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['minoxidil treatment brush on beard']),
      TimelineItem(time: '10:00-10:45 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['2 Magnesium Glycinate capsule', 'Cerave Moisturizer', 'Joseon alpha-arbutin']),
    ],
    'sun': [
      TimelineItem(time: '7:00-7:30 am', title: 'Wakeup + get ready', icon: '☀️', details: ['get dressed for shopping (NK 9060)', 'brush teeth', '600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '7:30-9:00 am', title: 'Morning Reading', icon: '📖', details: ['reading']),
      TimelineItem(time: '9:00-9:30 am', title: 'Breakfast', icon: '🍳', details: ['3 scrambled eggs', '20mg adderall IR', '3 softgel (not serving) omega-3', '1 tbsp peanut butter w/ 1 tiny avocado', '💧 1 bottle water']),
      TimelineItem(time: '9:30-2:00 pm', title: 'Study Time', icon: '📚'),
      TimelineItem(time: '2:00-2:30 pm', title: 'Lunch', icon: '🍛', details: ['1/4 cup quinoa + 1/4 pound chicken breast', '1/4 cup almonds', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '2:30-3:30 pm', title: 'Grocery Shop', icon: '🛒', details: ['wash hand + put on sunscreen', 'check what I have before going', "Trader Joe's (all groceries are bought there)", '💧 1 bottle water + 1 scoop Greens Powder']),
      TimelineItem(time: '3:30-6:00 pm', title: 'Cooking', icon: '🧑‍🍳', details: ['💧 2 bottle water with 4tsp husk at 4:30pm', '12oz chickpea fusilli pasta + 3lb ground turkey + 48oz marinara sauce + 2 can lentils + 2/4 cup nutritional yeast + 6 full chopped bell peppers (divide in 6, for fridge)', '1lb Wild Sockeye Salmon (divide in 3, 3 fridge)', 'PREP FOR TUE: Dice 1lb chicken + mix w/ seasonings (store in airtight container)']),
      TimelineItem(time: '6:00-6:15 pm', title: 'Snack', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '5g creatine', '1/3 (3rd) container Raspberries', '💧 1 bottle water']),
      TimelineItem(time: '6:15-7:00 pm', title: 'LISS Cardio Walk', icon: '🚶', details: ['Open Apple Watch → Workout → Outdoor Walk', '30 min brisk walk around neighborhood', 'Stay in Heart Rate Zone 2 (120-140 bpm)', '10 min stretching/mobility']),
      TimelineItem(time: '7:00-7:25 pm', title: 'Dinner', icon: '🥩', details: ['0.5 lbs top sirloin steak w/ 1/5 (5th) bag spinach', '2 cup (rest) 2% ultra-pasteurized milk']),
      TimelineItem(time: '7:25-8:00 pm', title: 'Chores & Clean Up', icon: '🧼', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwaganda', '💧 1 bottle water']),
      TimelineItem(time: '8:00-9:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['Do Dermaroller (No minoxidil)']),
      TimelineItem(time: '9:00-9:15 pm', title: 'Night Supplement', icon: '🌙', details: ['2 Magnesium Glycinate capsule', 'Cerave Moisturizer']),
      TimelineItem(time: '9:15-10:30 pm', title: 'Read/Reflect & Sleep', icon: '😴'),
    ],
  };
}
