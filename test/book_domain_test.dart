import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/book_plan/domain/book.dart';

void main() {
  group('Book Domain Logic', () {
    const defaultBook = Book(
      id: 'test_b1',
      title: 'Mindset',
      author: 'Carol S. Dweck',
      weeklyGoalPercent: 25,
      startWeek: 0,
      expectedDurationWeeks: 4,
    );

    test('expectedProgressForWeek correctly calculates weekly bounds', () {
      expect(defaultBook.expectedProgressForWeek(-1), 0); // Before start
      expect(defaultBook.expectedProgressForWeek(0), 25); // Week 0 EOW
      expect(defaultBook.expectedProgressForWeek(1), 50); // Week 1 EOW
      expect(defaultBook.expectedProgressForWeek(2), 75); // Week 2 EOW
      expect(defaultBook.expectedProgressForWeek(3), 100); // Week 3 EOW
      expect(defaultBook.expectedProgressForWeek(4), 100); // After expected duration
    });

    test('calculateProgressForDay calculates correct daily interpolation', () {
      // Prior to startWeek it should be 0 regardless of day
      expect(defaultBook.calculateProgressForDay(-1, 3), 0);

      // Week 0: Target EOW = 25%. Monday(1) = 25/7 ~ 4%.
      expect(defaultBook.calculateProgressForDay(0, 1), 4);
      // Tuesday(2) = 50/7 ~ 7%
      expect(defaultBook.calculateProgressForDay(0, 2), 7);
      // Wednesday(3) = 75/7 ~ 11%
      expect(defaultBook.calculateProgressForDay(0, 3), 11);
      // Sunday(7) = 25% (matches EOW)
      expect(defaultBook.calculateProgressForDay(0, 7), 25);
      
      // Zero or negative day clamp (yesterday on Monday becomes 0) -> gives last week's total
      expect(defaultBook.calculateProgressForDay(0, 0), 0);
      
      // Week 1: Starts at 25% and targets 50%. Diff is 25%
      // Monday(1): 25 + 4 = 29
      expect(defaultBook.calculateProgressForDay(1, 1), 29);
      // Sunday(7): 25 + 25 = 50
      expect(defaultBook.calculateProgressForDay(1, 7), 50);
      
      // Week 1 negative day: gives week 0 EOW
      expect(defaultBook.calculateProgressForDay(1, 0), 25);

      // Final Week (4): if expected duration hit early or at edge, clamp at 100
      expect(defaultBook.calculateProgressForDay(3, 7), 100);
      expect(defaultBook.calculateProgressForDay(4, 3), 100); 
    });

    test('Testing different weekly goal percents and clamping', () {
      const intensiveBook = Book(
        id: 'test_b2',
        title: 'Intensive Book',
        author: 'Unknown',
        weeklyGoalPercent: 40,
        startWeek: 2,
        expectedDurationWeeks: 3, // Week 2(40%), Week 3(80%), Week 4(100%)
      );

      // Week 2: diff is 40
      expect(intensiveBook.calculateProgressForDay(2, 7), 40);
      
      // Week 3: diff is 40. Start at 40
      expect(intensiveBook.calculateProgressForDay(3, 7), 80);
      
      // Week 4: diff is 20 (Target 100 - Last 80).
      // Monday(1): 80 + round(20/7*1 = 2.85) = 83
      expect(intensiveBook.calculateProgressForDay(4, 1), 83);
      // Friday(5): 80 + round(20/7*5 = 14.28) = 94
      expect(intensiveBook.calculateProgressForDay(4, 5), 94);
      // Sunday(7): 80 + 20 = 100
      expect(intensiveBook.calculateProgressForDay(4, 7), 100);
    });

    test('Black Skin (b25) progress calculations', () {
      const blackSkin = Book(
        id: 'b25',
        title: 'Black Skin: The Definitive Skincare Guide',
        author: 'Dija Ayodele',
        weeklyGoalPercent: 25,
        startWeek: 13,
        expectedDurationWeeks: 4,
      );

      // Prior to startWeek
      expect(blackSkin.expectedProgressForWeek(12), 0);
      expect(blackSkin.calculateProgressForDay(12, 5), 0);

      // Week 13 (First week of book)
      expect(blackSkin.expectedProgressForWeek(13), 25);
      // Tuesday of Week 13: 25/7 * 2 = 7.14 -> 7%
      expect(blackSkin.calculateProgressForDay(13, 2), 7);
      // Sunday of Week 13: 25%
      expect(blackSkin.calculateProgressForDay(13, 7), 25);

      // After expected duration (Week 17 and onwards)
      expect(blackSkin.expectedProgressForWeek(17), 100);
    });

    test('Bigger Leaner Stronger (b26) progress calculations', () {
      const bls = Book(
        id: 'b26',
        title: 'Bigger Leaner Stronger',
        author: 'Michael Matthews',
        weeklyGoalPercent: 17,
        startWeek: 18,
        expectedDurationWeeks: 6,
      );

      // Prior to startWeek
      expect(bls.expectedProgressForWeek(17), 0);

      // Week 18 (First week of book)
      expect(bls.expectedProgressForWeek(18), 17);
      // Saturday of Week 18: 17/7 * 6 = 14.57 -> 15%
      expect(bls.calculateProgressForDay(18, 6), 15);

      // Week 23 (Last week of expected duration)
      expect(bls.expectedProgressForWeek(23), 100);
    });
  });
}
