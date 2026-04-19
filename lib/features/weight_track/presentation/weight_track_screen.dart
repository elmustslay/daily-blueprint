import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../data/weight_data.dart';

class WeightTrackScreen extends ConsumerStatefulWidget {
  const WeightTrackScreen({super.key});

  @override
  ConsumerState<WeightTrackScreen> createState() => _WeightTrackScreenState();
}

class _WeightTrackScreenState extends ConsumerState<WeightTrackScreen> {
  final _controller = TextEditingController();
  bool _isMorning = false;

  @override
  void initState() {
    super.initState();
    final hour = DateTime.now().hour;
    _isMorning = hour >= 6 && hour < 10;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(bodyWeightEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Weight Tracker')),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) => _buildBody(entries),
      ),
    );
  }

  Widget _buildBody(List<BodyWeightEntry> entries) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_isMorning)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.amber, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Good morning — time to weigh in!",
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        _buildLogCard(entries),
        const SizedBox(height: 24),
        if (entries.length >= 2) ...[
          _buildChart(entries),
          const SizedBox(height: 24),
        ],
        _buildHistory(entries),
      ],
    );
  }

  Widget _buildLogCard(List<BodyWeightEntry> entries) {
    final latest = entries.isNotEmpty ? entries.last : null;
    final diff = entries.length >= 2
        ? entries.last.weight - entries[entries.length - 2].weight
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.monitor_weight, color: Colors.blueAccent, size: 28),
                const SizedBox(width: 10),
                Text(
                  latest != null ? '${latest.weight} lbs' : 'No entries yet',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                if (diff != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (diff <= 0 ? Colors.greenAccent : Colors.redAccent).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} lbs',
                      style: TextStyle(
                        color: diff <= 0 ? Colors.greenAccent : Colors.redAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (latest != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Last logged: ${DateFormat.yMMMd().format(latest.date)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Weight (lbs)',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _logWeight,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: const Text('Log'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<BodyWeightEntry> entries) {
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    final weights = entries.map((e) => e.weight).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final padding = (maxW - minW) * 0.15;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.white.withValues(alpha: 0.06),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (v, _) => Text(
                          '${v.toInt()}',
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: entries.length > 8 ? (entries.length / 5).ceilToDouble() : 1,
                        getTitlesWidget: (v, _) {
                          final idx = v.toInt();
                          if (idx < 0 || idx >= entries.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              DateFormat('M/d').format(entries[idx].date),
                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: minW - padding - 1,
                  maxY: maxW + padding + 1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: Colors.blueAccent,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 3.5,
                          color: Colors.blueAccent,
                          strokeWidth: 1.5,
                          strokeColor: Colors.white24,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blueAccent.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory(List<BodyWeightEntry> entries) {
    if (entries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No weight entries yet.\nLog your first weigh-in above!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38)),
          ),
        ),
      );
    }

    final reversed = entries.reversed.toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...reversed.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat.yMMMd().format(e.date),
                      style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  Text('${e.weight} lbs',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _logWeight() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final weight = double.tryParse(text);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid weight')),
      );
      return;
    }

    await ref.read(bodyWeightRepoProvider).log(weight, DateTime.now());
    ref.invalidate(bodyWeightEntriesProvider);
    _controller.clear();
    if (mounted) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged ${weight.toStringAsFixed(1)} lbs')),
      );
    }
  }
}
