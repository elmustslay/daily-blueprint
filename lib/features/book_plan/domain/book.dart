class Book {
  final String id;
  final String title;
  final String author;
  final int weeklyGoalPercent;
  final int startWeek;
  final int expectedDurationWeeks;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.weeklyGoalPercent,
    required this.startWeek,
    required this.expectedDurationWeeks,
  });

  int expectedProgressForWeek(int currentWeek) {
    if (currentWeek < startWeek) return 0;
    int weeksIn = currentWeek - startWeek + 1;
    if (weeksIn >= expectedDurationWeeks) return 100;
    return (weeksIn * weeklyGoalPercent).clamp(0, 100);
  }

  int expectedProgressForToday(int currentWeek) {
    return calculateProgressForDay(currentWeek, DateTime.now().weekday);
  }

  int expectedProgressForYesterday(int currentWeek) {
    return calculateProgressForDay(currentWeek, (DateTime.now().weekday - 1).clamp(0, 7));
  }

  int calculateProgressForDay(int currentWeek, int weekday) {
    if (currentWeek < startWeek) return 0;
    
    int lastWeekProgress = expectedProgressForWeek(currentWeek - 1);
    int thisWeekTarget = expectedProgressForWeek(currentWeek);
    
    int diff = thisWeekTarget - lastWeekProgress;
    if (diff <= 0) return thisWeekTarget;
    
    if (weekday <= 0) return lastWeekProgress;
    
    int expectedForDay = lastWeekProgress + ((diff / 7.0) * weekday).round();
    return expectedForDay.clamp(0, 100);
  }
}

class ReadingTrack {
  final String id;
  final String name;
  final List<Book> books;

  const ReadingTrack({required this.id, required this.name, required this.books});
}

class Quarter {
  final String id;
  final String title;
  final String goal;
  final String weekRange;
  final List<ReadingTrack> tracks;

  const Quarter({
    required this.id,
    required this.title,
    required this.goal,
    required this.weekRange,
    required this.tracks,
  });
}
