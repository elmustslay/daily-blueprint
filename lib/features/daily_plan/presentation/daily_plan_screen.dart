import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/shared_prefs.dart';
import '../data/daily_plan_data.dart';

// --- State ---
class WaterTrackerNotifier extends Notifier<Map<String, List<bool>>> {
  @override
  Map<String, List<bool>> build() {
    final prefs = SharedPrefsLogic.instance;
    final Map<String, List<bool>> stateMap = {};
    
    for (final dayKey in DailyPlanData.waterBottles.keys) {
      final bottlesCount = DailyPlanData.waterBottles[dayKey] ?? 0;
      final keys = prefs.getStringList('water_$dayKey');
      if (keys != null && keys.length == bottlesCount) {
        stateMap[dayKey] = keys.map((e) => e == 'true').toList();
      } else {
        stateMap[dayKey] = List.filled(bottlesCount, false);
      }
    }
    return stateMap;
  }

  void toggleBottle(String dayKey, int index) {
    if (!state.containsKey(dayKey)) return;
    final newStateMap = Map<String, List<bool>>.from(state);
    final dayList = List<bool>.from(newStateMap[dayKey]!);
    dayList[index] = !dayList[index];
    newStateMap[dayKey] = dayList;
    state = newStateMap;
    
    SharedPrefsLogic.instance.setStringList('water_$dayKey', dayList.map((e) => e.toString()).toList());
  }
}

final waterTrackerProvider = NotifierProvider<WaterTrackerNotifier, Map<String, List<bool>>>(WaterTrackerNotifier.new);

// --- UI ---
class DailyPlanScreen extends ConsumerStatefulWidget {
  const DailyPlanScreen({super.key});

  @override
  ConsumerState<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends ConsumerState<DailyPlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  final List<String> displayDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    // Set to current day (0 = monday in our tab layout, but DateTime.weekday is 1=Mon, 7=Sun)
    int currentDayIndex = DateTime.now().weekday - 1; 
    _tabController.index = currentDayIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Blueprint'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: displayDays.map((d) => Tab(text: d)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: days.map((day) => _buildDayContent(day)).toList(),
      ),
    );
  }

  Widget _buildDayContent(String dayKey) {
    final items = DailyPlanData.schedules[dayKey] ?? [];
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildWaterTracker(dayKey),
        const SizedBox(height: 24),
        ...items.map((item) => _buildTimelineItem(item)),
      ],
    );
  }

  Widget _buildWaterTracker(String dayKey) {
    final waterStateMap = ref.watch(waterTrackerProvider);
    final waterState = waterStateMap[dayKey] ?? [];
    final bottlesCount = DailyPlanData.waterBottles[dayKey] ?? 0;
    final totalOz = bottlesCount * 21;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Water Intake',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '1 bottle = 21oz. Total: ${totalOz}oz',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              bottlesCount,
              (index) {
                final isChecked = waterState[index];
                return GestureDetector(
                  onTap: () => ref.read(waterTrackerProvider.notifier).toggleBottle(dayKey, index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isChecked ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                      border: Border.all(
                        color: isChecked ? Colors.blueAccent : Colors.grey.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '💧',
                        style: TextStyle(
                          fontSize: 20,
                          color: isChecked ? null : Colors.grey,
                          // Grayscale effect in flutter for unsupported emojis is tricky natively,
                          // so we decrease opacity or just rely on the border to indicate state.
                        ).copyWith(color: isChecked ? Colors.white : Colors.white.withOpacity(0.3)),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimelineItem(TimelineItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Column
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).cardColor,
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Center(child: Text(item.icon, style: const TextStyle(fontSize: 20))),
              ),
              // We could add a little line here for a true timeline aesthetic if we aren't the last item
            ],
          ),
          const SizedBox(width: 16),
          // Content Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.time, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                const SizedBox(height: 4),
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                if (item.details.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: item.details.map((detail) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Colors.grey)),
                            Expanded(child: Text(detail, style: const TextStyle(color: Colors.white70))),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}
