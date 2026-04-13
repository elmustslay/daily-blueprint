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
  static const Map<String, int> waterBottles = {
    'mon': 7,
    'tue': 6,
    'wed': 7,
    'thu': 6,
    'fri': 7,
    'sat': 7,
    'sun': 7,
  };

  static const Map<String, List<TimelineItem>> schedules = {
    'mon': [
      TimelineItem(time: '6:30-6:50 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '6:50-7:10 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'get dressed (NK 9060/Bondi)', 'put on sunscreen']),
      TimelineItem(time: '7:10-7:40 am', title: 'Morning Prayer', icon: '🙏', details: ['prayer and reading']),
      TimelineItem(time: '7:40-8:10 am', title: 'Breakfast', icon: '🍳', details: ['3 scrambled eggs w/ 1/5 bag spinach', '1 capsule citicoline', '2 cup whole milk w/ 2 tbsp peanut butter', '💧 1 bottle water']),
      TimelineItem(time: '8:10-8:30 am', title: 'Grab things to take to work', icon: '🗂️', details: ['Pasta lunch', '3tsp husk', 'kindle/laptop', 'the supplement capsule', 'gym outfit', 'keys/wallet/phone', 'airpods', 'water bottle']),
      TimelineItem(time: '8:30-9:00 am', title: 'Commute to Work', icon: '🚗'),
      TimelineItem(time: '9:00-12:00 pm', title: 'Work', icon: '💻', details: ['💧 1 bottle water']),
      TimelineItem(time: '12:00-12:30 pm', title: 'Lunch', icon: '🥗', details: ['1 serving of my pasta', '2 D3-K2 supplement capsule', '💧 1 bottle water']),
      TimelineItem(time: '12:30-5:00 pm', title: 'Work', icon: '💻', details: ['💧 2 bottle water with 3 tsp husk at 2:30pm']),
      TimelineItem(time: '5:00-5:30 pm', title: 'Commute To Gym', icon: '🚗', details: ['black coffee', 'Reapply Sunscreen']),
      TimelineItem(time: '5:30-7:00 pm', title: 'Gym Session (Push)', icon: '🏋️', details: ['Includes the 15 min travel time back home', '💧 1 bottle water']),
      TimelineItem(time: '7:00-7:15 pm', title: 'Post-Workout', icon: '🥤', details: ['1 scoop whey isolate (30g protein)', '1 scoop creatine monohydrate (5g)']),
      TimelineItem(time: '7:15-7:30 pm', title: 'Dinner', icon: '🍝', details: ['1/3 lb Wild Sockeye Salmon', '💧 1 bottle water']),
      TimelineItem(time: '7:30-8:00 pm', title: 'Chores & Clean Up', icon: '🧼'),
      TimelineItem(time: '8:00-9:00 pm', title: 'Study Time', icon: '📚', details: ['1 scoop casein protein', '1 tbsp Chia Seeds', '2 cap Ashwaganda']),
      TimelineItem(time: '9:00-10:00 pm', title: 'Shower & Bed Prep', icon: '🚿', details: ['minoxidil treatment brush on beard']),
      TimelineItem(time: '10:00-11:00 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙', details: ['3 Magnesium Glycinate capsule', 'Cerave Moisturizer', 'Retinol Serum']),
    ],
    'tue': [
      TimelineItem(time: '6:30-6:50 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '6:50-7:10 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'get dressed', 'NO sunscreen']),
      TimelineItem(time: '7:10-7:40 am', title: 'Morning Prayer', icon: '🙏', details: ['prayer and reading']),
      TimelineItem(time: '7:40-8:10 am', title: 'Breakfast', icon: '🍳', details: ['2 scrambled eggs w/ 1/5 bag spinach', '1 capsule citicoline', '1 cup whole milk w/ 1 tiny avocado', '3 softgel omega-3']),
      TimelineItem(time: '8:10-9:05 am', title: 'Cook', icon: '🧑‍🍳', details: ["quinoa + chicken prep"]),
      TimelineItem(time: '9:05-4:00 pm', title: 'Work', icon: '💻', details: ['💧 2 bottle water total']),
      TimelineItem(time: '4:00-6:30 pm', title: 'Study/Haircut', icon: '📚'),
      TimelineItem(time: '6:30-7:30 pm', title: 'Dinner', icon: '🍗', details: ["Chicken and Quinoa"]),
      TimelineItem(time: '7:30-9:00 pm', title: 'Chores & Shower', icon: '🚿'),
      TimelineItem(time: '9:00-10:30 pm', title: 'Night Supplement + Read/Reflect', icon: '🌙'),
    ],
    'wed': [
      TimelineItem(time: '6:30-6:50 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '6:50-7:10 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'put on sunscreen']),
      TimelineItem(time: '7:10-7:40 am', title: 'Morning Prayer', icon: '🙏', details: ['prayer and reading']),
      TimelineItem(time: '7:40-8:10 am', title: 'Breakfast', icon: '🍳'),
      TimelineItem(time: '8:10-8:30 am', title: 'Grab things', icon: '🗂️'),
      TimelineItem(time: '8:30-5:00 pm', title: 'Work & Lunch', icon: '💻', details: ['💧 3 bottle water total from work/lunch']),
      TimelineItem(time: '5:30-7:30 pm', title: 'Gym Session (Legs)', icon: '🏋️', details: ['Includes the 15 min travel time back home', '💧 1 bottle water']),
      TimelineItem(time: '7:30-8:00 pm', title: 'Post-Workout & Dinner', icon: '🍝'),
      TimelineItem(time: '8:00-11:00 pm', title: 'Study & Sleep Prep', icon: '🌙'),
    ],
    'thu': [
      TimelineItem(time: '6:30-6:50 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '6:50-7:10 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'NO sunscreen']),
      TimelineItem(time: '7:10-7:40 am', title: 'Morning Prayer', icon: '🙏', details: ['prayer and reading']),
      TimelineItem(time: '7:40-8:10 am', title: 'Breakfast', icon: '🍳'),
      TimelineItem(time: '8:45-4:00 pm', title: 'Work', icon: '💻', details: ['💧 2 water bottles']),
      TimelineItem(time: '4:00-6:30 pm', title: 'Work/Study', icon: '💻'),
      TimelineItem(time: '6:30-7:30 pm', title: 'Cardio', icon: '🏋️'),
      TimelineItem(time: '7:30-8:00 pm', title: 'Dinner', icon: '🍗'),
      TimelineItem(time: '8:00-10:45 pm', title: 'Chores & Sleep Prep', icon: '🌙'),
    ],
    'fri': [
      TimelineItem(time: '6:30-6:50 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '6:50-7:10 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'put on sunscreen']),
      TimelineItem(time: '7:10-7:40 am', title: 'Morning Prayer', icon: '🙏', details: ['prayer and reading']),
      TimelineItem(time: '7:40-8:10 am', title: 'Breakfast', icon: '🍳'),
      TimelineItem(time: '8:30-5:00 pm', title: 'Work & Lunch', icon: '💻'),
      TimelineItem(time: '5:30-7:30 pm', title: 'Gym Session (Pull)', icon: '🏋️', details: ['Includes the 15 min travel time back home', '💧 1 bottle water']),
      TimelineItem(time: '7:30-8:00 pm', title: 'Post-Workout & Dinner', icon: '🍝'),
      TimelineItem(time: '8:00-11:00 pm', title: 'Study & Sleep Prep', icon: '🌙'),
    ],
    'sat': [
      TimelineItem(time: '6:30-6:50 am', title: 'Wakeup', icon: '☀️', details: ['600mg NAC + 25mcg Selenium']),
      TimelineItem(time: '6:50-7:10 am', title: 'Get Ready', icon: '🚿', details: ['brush teeth', 'Hoka Bondi 8']),
      TimelineItem(time: '7:10-7:40 am', title: 'Morning Prayer', icon: '🙏', details: ['prayer and reading']),
      TimelineItem(time: '7:40-8:10 am', title: 'Breakfast', icon: '🍳'),
      TimelineItem(time: '8:45-6:00 pm', title: 'Study', icon: '📚', details: ['💧 2 water bottles total during study']),
      TimelineItem(time: '6:20-7:20 pm', title: 'Gym Session (Cardio)', icon: '🏋️', details: ['💧 1 bottle water']),
      TimelineItem(time: '7:30-8:00 pm', title: 'Dinner', icon: '🍗'),
      TimelineItem(time: '8:00-11:29 pm', title: 'Chores & Sleep Prep', icon: '🌙'),
    ],
    'sun': [
      TimelineItem(time: '8:00-8:30 am', title: 'Wakeup', icon: '☀️', details: ['get dressed for shopping (NK 9060)']),
      TimelineItem(time: '8:30-9:00 am', title: 'Morning prayer', icon: '🙏', details: ['Prayer and reading']),
      TimelineItem(time: '9:00-9:30 am', title: 'Breakfast', icon: '🍳', details: ['3 scrambled eggs', '20mg adderall IR', '💧 1 bottle water']),
      TimelineItem(time: '9:30-2:00 pm', title: 'Study Time', icon: '📚'),
      TimelineItem(time: '2:00-2:30 pm', title: 'Lunch', icon: '🍛'),
      TimelineItem(time: '2:30-3:30 pm', title: 'Grocery Shop', icon: '🛒', details: ["Trader Joe's", '💧 1 bottle water + 1 scoop Greens Powder']),
      TimelineItem(time: '3:30-6:00 pm', title: 'Cooking', icon: '🧑‍🍳', details: ['💧 2 bottle water', 'Prep for week']),
      TimelineItem(time: '6:00-6:45 pm', title: 'Read', icon: '📚'),
      TimelineItem(time: '6:45-7:25 pm', title: 'Dinner', icon: '🥩'),
      TimelineItem(time: '7:25-10:45 pm', title: 'Chores & Sleep Prep', icon: '🌙'),
    ],
  };
}
