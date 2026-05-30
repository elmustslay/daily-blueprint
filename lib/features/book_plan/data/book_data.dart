import '../domain/book.dart';

class BookData {
  static final DateTime startDate = DateTime(2026, 3, 2); // Monday, March 2, 2026 (Week 0)

  static int getCurrentWeek() {
    final now = DateTime.now();
    final diff = now.difference(startDate).inDays;
    if (diff < 0) return 0;
    return diff ~/ 7;
  }

  static const List<Quarter> plan = [
    Quarter(
      id: 'q1',
      title: 'Quarter 1: The Foundation',
      goal: 'Install your core operating system: a belief in growth and the tools for learning.',
      weekRange: 'Weeks 0-12',
      tracks: [
        ReadingTrack(
          id: 'q1_t1',
          name: 'The Psychological Bedrock & Learning (Track 1)',
          books: [
            Book(id: 'b1', title: 'Mindset', author: 'Carol S. Dweck', weeklyGoalPercent: 25, startWeek: 0, expectedDurationWeeks: 4),
            Book(id: 'b2', title: 'Man\'s Search for Meaning', author: 'Viktor E. Frankl', weeklyGoalPercent: 50, startWeek: 4, expectedDurationWeeks: 2),
            Book(id: 'b3', title: 'The Sleep Solution', author: 'W. Chris Winter', weeklyGoalPercent: 20, startWeek: 6, expectedDurationWeeks: 5),
          ],
        ),
        ReadingTrack(
          id: 'q1_t2',
          name: 'The Learning Stack (Track 2)',
          books: [
            Book(id: 'b4', title: 'Learning How to Learn (Coursera)', author: 'Barbara Oakley', weeklyGoalPercent: 25, startWeek: 6, expectedDurationWeeks: 4),
          ],
        )
      ],
    ),
    Quarter(
      id: 'q2',
      title: 'Quarter 2: The Execution Engine',
      goal: 'Build your daily habits of discipline and establish a healthy wealth mindset.',
      weekRange: 'Weeks 13-23',
      tracks: [
        ReadingTrack(
          id: 'q2_t1',
          name: 'Discipline Track',
          books: [
            Book(id: 'b5', title: 'Dopamine Detox', author: 'Thibaut Meurisse', weeklyGoalPercent: 50, startWeek: 13, expectedDurationWeeks: 2),
            Book(id: 'b6', title: 'Atomic Habits', author: 'James Clear', weeklyGoalPercent: 33, startWeek: 15, expectedDurationWeeks: 3),
            Book(id: 'b7', title: 'Deep Work', author: 'Cal Newport', weeklyGoalPercent: 33, startWeek: 18, expectedDurationWeeks: 3),
            Book(id: 'b8', title: 'Essentialism: The Disciplined Pursuit of Less', author: 'Greg McKeown', weeklyGoalPercent: 33, startWeek: 21, expectedDurationWeeks: 3),
          ],
        ),
        ReadingTrack(
          id: 'q2_t2',
          name: 'Wealth Mindset Track',
          books: [
            Book(id: 'b9', title: 'The Psychology of Money', author: 'Morgan Housel', weeklyGoalPercent: 33, startWeek: 13, expectedDurationWeeks: 3),
            Book(id: 'b10', title: 'The Almanack of Naval Ravikant', author: 'Eric Jorgenson', weeklyGoalPercent: 33, startWeek: 16, expectedDurationWeeks: 3),
            Book(id: 'b24', title: 'Quit Porn and Get Rich: The Unspoken Rule of Successful People', author: 'Martin Prescott', weeklyGoalPercent: 33, startWeek: 19, expectedDurationWeeks: 3),
          ],
        ),
        ReadingTrack(
          id: 'q2_t3',
          name: 'Physical & Health Optimization Track',
          books: [
            Book(id: 'b25', title: 'Black Skin: The Definitive Skincare Guide', author: 'Dija Ayodele', weeklyGoalPercent: 25, startWeek: 13, expectedDurationWeeks: 4),
            Book(id: 'b26', title: 'Bigger Leaner Stronger', author: 'Michael Matthews', weeklyGoalPercent: 17, startWeek: 18, expectedDurationWeeks: 6),
          ],
        ),
      ],
    ),
    Quarter(
      id: 'q3',
      title: 'Quarter 3: The Applied Frameworks',
      goal: 'Build the real-world systems for wealth and social success. This is the most demanding quarter.',
      weekRange: 'Weeks 24-33',
      tracks: [
        ReadingTrack(
          id: 'q3_t1',
          name: 'Wealth Systems Track',
          books: [
            Book(id: 'b11', title: 'I Will Teach You to Be Rich', author: 'Ramit Sethi', weeklyGoalPercent: 20, startWeek: 24, expectedDurationWeeks: 5),
            Book(id: 'b12', title: 'So Good They Can\'t Ignore You', author: 'Cal Newport', weeklyGoalPercent: 20, startWeek: 29, expectedDurationWeeks: 5),
          ],
        ),
        ReadingTrack(
          id: 'q3_t2',
          name: 'Social Matrix Track',
          books: [
            Book(id: 'b13', title: 'How to Win Friends and Influence People', author: 'Dale Carnegie', weeklyGoalPercent: 33, startWeek: 24, expectedDurationWeeks: 3),
            Book(id: 'b14', title: 'Influence: The Psychology of Persuasion', author: 'Robert Cialdini', weeklyGoalPercent: 20, startWeek: 27, expectedDurationWeeks: 5),
            Book(id: 'b15', title: 'Never Split the Difference', author: 'Chris Voss', weeklyGoalPercent: 50, startWeek: 32, expectedDurationWeeks: 2),
          ],
        ),
      ],
    ),
    Quarter(
      id: 'q4',
      title: 'Quarter 4: The Integration Core',
      goal: 'Integrate your ambition with contentment, ensuring you achieve the full trifecta.',
      weekRange: 'Weeks 34-43',
      tracks: [
        ReadingTrack(
          id: 'q4_t1',
          name: 'Contentment Track',
          books: [
            Book(id: 'b16', title: 'The Power of Now', author: 'Eckhart Tolle', weeklyGoalPercent: 33, startWeek: 34, expectedDurationWeeks: 3),
            Book(id: 'b17', title: 'The Obstacle Is the Way', author: 'Ryan Holiday', weeklyGoalPercent: 33, startWeek: 37, expectedDurationWeeks: 3),
            Book(id: 'b18', title: 'Meditations', author: 'Marcus Aurelius', weeklyGoalPercent: 25, startWeek: 40, expectedDurationWeeks: 4),
          ],
        ),
        ReadingTrack(
          id: 'q4_t2',
          name: 'Integration Track',
          books: [
            Book(id: 'b19', title: 'Start with Why', author: 'Simon Sinek', weeklyGoalPercent: 50, startWeek: 34, expectedDurationWeeks: 2),
            Book(id: 'b20', title: 'The Courage to Be Disliked', author: 'Ichiro Kishimi & Fumitake Koga', weeklyGoalPercent: 50, startWeek: 36, expectedDurationWeeks: 2),
            Book(id: 'b23', title: 'The Game of Life and How to Play It', author: 'Florence Scovel Shinn', weeklyGoalPercent: 50, startWeek: 38, expectedDurationWeeks: 2),
            Book(id: 'b21', title: 'The Law and The Promise', author: 'Neville Goddard', weeklyGoalPercent: 50, startWeek: 40, expectedDurationWeeks: 2),
            Book(id: 'b22', title: 'Conversations with God, Book 1', author: 'Neale Donald Walsch', weeklyGoalPercent: 50, startWeek: 42, expectedDurationWeeks: 2),
          ],
        ),
      ],
    ),
  ];
}
