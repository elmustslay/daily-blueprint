import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../data/gym_data.dart';

final exerciseLogsProvider = FutureProvider.family<List<ExerciseLog>, String>((ref, exerciseId) async {
  final repo = ref.read(gymRepoProvider);
  return repo.getLogs(exerciseId);
});

class GymStatsScreen extends ConsumerStatefulWidget {
  final Exercise exercise;

  const GymStatsScreen({super.key, required this.exercise});

  @override
  ConsumerState<GymStatsScreen> createState() => _GymStatsScreenState();
}

class _GymStatsScreenState extends ConsumerState<GymStatsScreen> {
  String _selectedSeat = 'Seat 3';

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(exerciseLogsProvider(widget.exercise.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.exercise.name} Stats'),
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (allLogs) {
          List<ExerciseLog> logs = allLogs;
          final isLegPress = widget.exercise.id == 'legs_1a';

          if (isLegPress) {
            final cutoff = DateTime(2026, 9, 7);
            if (_selectedSeat == 'Seat 3') {
              logs = allLogs.where((l) => l.date.isAfter(cutoff)).toList();
            } else {
              logs = allLogs.where((l) => !l.date.isAfter(cutoff)).toList();
            }
          }

          if (logs.isEmpty) {
            return Column(
              children: [
                if (isLegPress) _buildSeatToggle(),
                const Expanded(child: Center(child: Text('No logs yet. Start lifting!'))),
              ],
            );
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
                if (isLegPress) _buildSeatToggle(),
                const SizedBox(height: 16),
                Text(
                  'Weight Progression',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (widget.exercise.name.contains('Assisted')) ...[
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

  Widget _buildSeatToggle() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'Seat 3', label: Text('Seat 3')),
          ButtonSegment(value: 'Seat 4', label: Text('Seat 4')),
        ],
        selected: {_selectedSeat},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _selectedSeat = newSelection.first;
          });
        },
      ),
    );
  }
}
