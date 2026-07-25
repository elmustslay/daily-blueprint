import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../data/gym_data.dart';

final exerciseLogsProvider = FutureProvider.family<List<ExerciseLog>, String>((ref, exerciseId) async {
  final repo = ref.read(gymRepoProvider);
  return repo.getLogs(exerciseId);
});

class GymStatsScreen extends ConsumerWidget {
  final Exercise exercise;

  const GymStatsScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(exerciseLogsProvider(exercise.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('${exercise.name} Stats'),
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('No logs yet. Start lifting!'));
          }

          // Generate spots for the chart
          final spots = <FlSpot>[];
          for (int i = 0; i < logs.length; i++) {
            // x: index or timestamp. We use index for even spacing, 
            // but we can map bottom titles to dates.
            spots.add(FlSpot(i.toDouble(), logs[i].weight));
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Weight Progression',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (exercise.name.contains('Assisted')) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Note: Since this is an assisted machine, the line trending DOWN means you are getting stronger (using less assistance).',
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 13, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: Colors.blueAccent,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blueAccent.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value % 1 != 0 || value < 0 || value >= logs.length) return const SizedBox.shrink();
                              final date = logs[value.toInt()].date;
                              final formatted = DateFormat('MM/dd').format(date);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(formatted, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.2), strokeWidth: 1),
                        getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.2), strokeWidth: 1),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
