import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/book.dart';
import '../data/book_data.dart';
import 'book_notifier.dart';

class BookPlanScreen extends ConsumerStatefulWidget {
  const BookPlanScreen({super.key});

  @override
  ConsumerState<BookPlanScreen> createState() => _BookPlanScreenState();
}

class _BookPlanScreenState extends ConsumerState<BookPlanScreen> {
  final int currentWeek = BookData.getCurrentWeek();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trifecta Reading Plan'),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderBanner(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: BookData.plan.length,
              itemBuilder: (context, index) {
                final quarter = BookData.plan[index];
                return _buildQuarterSection(quarter);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'We are currently in Week $currentWeek',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          const SizedBox(height: 4),
          const Text(
            'Keep grinding. Small daily pages compound massively.',
            style: TextStyle(color: Colors.white70),
          )
        ],
      ),
    );
  }

  Widget _buildQuarterSection(Quarter quarter) {
    // Determine if we are in this quarter purely for aesthetic highlighting
    // (A quarter is generally 13 weeks)
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quarter.title.toUpperCase(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          Text(
            '${quarter.weekRange} • ${quarter.goal}',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ...quarter.tracks.map((track) => _buildTrackSection(track)),
        ],
      ),
    );
  }

  Widget _buildTrackSection(ReadingTrack track) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              track.name,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
            ),
          ),
          ...track.books.map((b) => _buildBookTile(b)),
        ],
      ),
    );
  }

  Widget _buildBookTile(Book book) {
    final progressMap = ref.watch(bookProgressProvider);
    final currentProgress = progressMap[book.id] ?? 0;
    
    final expectedProgress = book.expectedProgressForWeek(currentWeek);
    
    bool isActive = currentWeek >= book.startWeek && currentWeek < (book.startWeek + book.expectedDurationWeeks);
    bool isPast = currentWeek >= (book.startWeek + book.expectedDurationWeeks);
    
    Color statusColor;
    String statusText;
    
    if (currentProgress == 100) {
      statusColor = Colors.greenAccent;
      statusText = 'Completed';
    } else if (currentWeek < book.startWeek) {
      statusColor = Colors.grey;
      statusText = 'Starts Week ${book.startWeek}';
    } else {
      if (currentProgress >= expectedProgress) {
        statusColor = Colors.blueAccent;
        statusText = 'On Track ($expectedProgress% expected)';
      } else {
        statusColor = Colors.redAccent;
        statusText = 'Behind ($expectedProgress% expected)';
      }
    }

    return InkWell(
      onTap: () => _showUpdateProgressDialog(book, currentProgress),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : (isPast && currentProgress < 100 ? Colors.red.withValues(alpha: 0.8) : Colors.white70),
                        ),
                      ),
                      Text('By ${book.author}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    '$currentProgress%',
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: currentProgress / 100.0,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(currentProgress == 100 ? Colors.greenAccent : Colors.blueAccent),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showUpdateProgressDialog(Book book, int currentProgress) {
    final txtController = TextEditingController(text: currentProgress.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update "${book.title}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your reading percentage (0-100):'),
            const SizedBox(height: 16),
            TextField(
              controller: txtController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(txtController.text);
              if (val != null) {
                ref.read(bookProgressProvider.notifier).updateProgress(book.id, val);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}
