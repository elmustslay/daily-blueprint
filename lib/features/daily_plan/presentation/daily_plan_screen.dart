import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/shared_prefs.dart';
import '../data/daily_plan_data.dart';
import '../../micro_macro_calorie_track/domain/nutrition.dart';

// --- State ---
class WaterTrackerNotifier extends Notifier<Map<String, List<bool>>> {
  @override
  Map<String, List<bool>> build() {
    final prefs = SharedPrefsLogic.instance;
    final Map<String, List<bool>> stateMap = {};

    // Shift time by 2 hours so the reset happens at 2 AM Monday instead of midnight
    final now = DateTime.now();
    final adjustedTime = now.subtract(const Duration(hours: 2));
    final weekStart = adjustedTime.subtract(Duration(days: adjustedTime.weekday - 1));
    final weekStartStr =
        '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';

    final isNewWeek = prefs.getString('water_week_start') != weekStartStr;
    
    for (final dayKey in DailyPlanData.waterBottles.keys) {
      final bottlesCount = DailyPlanData.waterBottles[dayKey] ?? 0;
      final keys = prefs.getStringList('water_$dayKey');
      
      if (!isNewWeek && keys != null && keys.length == bottlesCount) {
        stateMap[dayKey] = keys.map((e) => e == 'true').toList();
      } else {
        stateMap[dayKey] = List.filled(bottlesCount, false);
        // Clear the stale data from storage if it's a new week
        if (isNewWeek) {
          prefs.remove('water_$dayKey');
        }
      }
    }

    if (isNewWeek) {
      prefs.setString('water_week_start', weekStartStr);
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
  final List<String> days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun', 'nutrition'];
  final List<String> displayDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Nutrition'];
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    // Set to current day (0 = monday in our tab layout, but DateTime.weekday is 1=Mon, 7=Sun)
    int currentDayIndex = DateTime.now().weekday - 1; 
    _tabController.index = currentDayIndex;

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToCurrentTime);
      }
    });
    
    // Give the layout engine a moment to render the slivers before scrolling
    Future.delayed(const Duration(milliseconds: 400), _scrollToCurrentTime);
  }

  void _scrollToCurrentTime() {
    if (!mounted) return;
    int dayIndex = _tabController.index;
    if (dayIndex >= 7) return; // nutrition
    
    String currentDayKey = days[dayIndex];
    if (DateTime.now().weekday - 1 != dayIndex) return; // Only scroll if viewing today
    
    final items = DailyPlanData.schedules[currentDayKey] ?? [];
    
    int targetIndex = -1;
    final now = DateTime.now();
    final currentMins = now.hour * 60 + now.minute;
    
    for (int i = 0; i < items.length; i++) {
       final startMins = _parseStartTimeMins(items[i].time);
       if (startMins != null && currentMins >= startMins) {
           targetIndex = i;
       }
    }
    
    if (targetIndex != -1) {
       final key = _itemKeys['${currentDayKey}_$targetIndex'];
       if (key != null && key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: Duration.zero,
            alignment: 0.1, // slightly below the sticky header
          );
       }
    }
  }

  int? _parseStartTimeMins(String timeString) {
    try {
      final parts = timeString.split('-');
      if (parts.length != 2) return null;
      
      final startStr = parts[0].trim();
      final endPart = parts[1].trim();
      
      final endTokens = endPart.split(' ');
      if (endTokens.length != 2) return null;
      
      final endStr = endTokens[0];
      final amPm = endTokens[1].toLowerCase();
      
      int parseTime(String timeStr, bool isPm) {
        final tParts = timeStr.split(':');
        int h = int.parse(tParts[0]);
        int m = int.parse(tParts[1]);
        if (isPm && h != 12) h += 12;
        if (!isPm && h == 12) h = 0;
        return h * 60 + m;
      }
      
      bool startIsPm = amPm == 'pm';
      int startH = int.parse(startStr.split(':')[0]);
      int endH = int.parse(endStr.split(':')[0]);
      
      if (amPm == 'pm') {
        if (startH == 12) {
           startIsPm = true;
        } else if (endH == 12 && startH >= 7 && startH < 12) {
           startIsPm = false; // e.g. "9:00-12:00 pm" -> 9 AM
        } else if (startH > endH && endH != 12) {
           startIsPm = false; // e.g. "10:00-1:00 pm" -> 10 AM
        } else {
           startIsPm = true; // e.g. "10:15-10:45 pm" -> 10 PM
        }
      }
      
      return parseTime(startStr, startIsPm);
    } catch (e) {
      return null;
    }
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
        children: days.map((day) => day == 'nutrition' ? _buildNutritionTab() : _buildDayContent(day)).toList(),
      ),
    );
  }

  Widget _buildDayContent(String dayKey) {
    final items = DailyPlanData.schedules[dayKey] ?? [];
    
    NutritionFact dailyTotals = const NutritionFact();
    for (var item in items) {
      if (item.mealRecord != null) {
        dailyTotals += item.mealRecord!.totalNutrition;
      }
    }
    
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyWaterHeaderDelegate(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: _buildWaterTracker(dayKey),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (DailyPlanData.isDeloadWeek()) ...[
                  _buildDeloadAlert(),
                  const SizedBox(height: 12),
                ],
                if (DailyPlanData.shouldScaleUpCardio()) ...[
                  _buildCardioScaleUpAlert(),
                  const SizedBox(height: 12),
                ],
                if (DailyPlanData.isAshwagandhaOff()) ...[
                  _buildAshwagandhaAlert(),
                  const SizedBox(height: 12),
                ],
                if (DailyPlanData.isBloodDonationWeek()) ...[
                  _buildBloodDonationAlert(),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 16),
                ...items.asMap().entries.map((entry) {
                  int idx = entry.key;
                  TimelineItem item = entry.value;
                  String keyStr = '${dayKey}_$idx';
                  _itemKeys[keyStr] ??= GlobalKey();
                  
                  return _buildTimelineItem(item, _itemKeys[keyStr]!);
                }),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionTab() {
    NutritionFact weeklyTotals = const NutritionFact();
    final Map<String, NutritionFact> dailyTotalsMap = {};
    
    for (int i = 0; i < 7; i++) {
      final dayKey = days[i];
      final dayItems = DailyPlanData.schedules[dayKey] ?? [];
      NutritionFact dayTotal = const NutritionFact();
      
      for (var item in dayItems) {
        if (item.mealRecord != null) {
          dayTotal += item.mealRecord!.totalNutrition;
          weeklyTotals += item.mealRecord!.totalNutrition;
        }
      }
      dailyTotalsMap[dayKey] = dayTotal;
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Daily Summaries', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.white),
              tooltip: 'Copy JSON for AI',
              onPressed: () {
                final exportData = {
                  'weeklyTotals': weeklyTotals.toJson(),
                  'dailyTotals': dailyTotalsMap.map((k, v) => MapEntry(k, v.toJson())),
                };
                Clipboard.setData(ClipboardData(text: jsonEncode(exportData)));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nutrition JSON copied to clipboard')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < 7; i++) 
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ExpansionTile(
              title: Text('${displayDays[i]} Nutrition', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              collapsedBackgroundColor: Theme.of(context).cardColor,
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              children: [
                _buildDailyNutritionSummary(dailyTotalsMap[days[i]]!, title: ''),
              ],
            ),
          ),
        const SizedBox(height: 16),
        const Text('Overall', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        ExpansionTile(
          title: const Text('Weekly Summary', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          initiallyExpanded: true,
          collapsedBackgroundColor: Theme.of(context).cardColor,
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          children: [
            _buildDailyNutritionSummary(weeklyTotals, title: ''),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyNutritionSummary(NutritionFact total, {String title = 'Daily Nutrition Goal'}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroCircle('Calories', '${total.calories.round()}', Colors.orangeAccent),
              _buildMacroCircle('Protein', '${total.protein.round()}g', Colors.blueAccent),
              _buildMacroCircle('Carbs', '${total.carbs.round()}g', Colors.greenAccent),
              _buildMacroCircle('Fat', '${total.fat.round()}g', Colors.purpleAccent),
            ],
          ),
          if (total.microNutrients.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Micronutrients & Supplements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: total.microNutrients.entries.map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.4)),
                ),
                child: Text('${e.key}: ${_formatMicronutrient(e.value)}', style: const TextStyle(fontSize: 12, color: Colors.tealAccent, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatMicronutrient(double value) {
    if (value == value.toInt()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  Widget _buildMacroCircle(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 3),
            color: color.withOpacity(0.1),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildWaterTracker(String dayKey) {
    final waterStateMap = ref.watch(waterTrackerProvider);
    final waterState = waterStateMap[dayKey] ?? [];
    final bottlesCount = DailyPlanData.waterBottles[dayKey] ?? 0;
    final totalOz = bottlesCount * 21;

    int? currentIndex;
    bool isRed = false;

    final now = DateTime.now();
    // Monday is 1, Sunday is 7 in DateTime.weekday
    final dayIndex = days.indexOf(dayKey) + 1;
    
    if (now.weekday == dayIndex && bottlesCount > 0) {
      final wakeMinutes = 7 * 60; // 7:00 AM
      final stopDrinkingMinutes = 20 * 60; // 8:00 PM
      final currentMinutes = now.hour * 60 + now.minute;

      if (currentMinutes < wakeMinutes) {
        currentIndex = 0;
      } else if (currentMinutes < stopDrinkingMinutes) {
        final windowLength = stopDrinkingMinutes - wakeMinutes; // 810 mins
        final minutesPerBottle = windowLength / bottlesCount;
        final elapsed = currentMinutes - wakeMinutes;
        currentIndex = (elapsed / minutesPerBottle).floor();
        if (currentIndex! >= bottlesCount) currentIndex = bottlesCount - 1;
      } else {
        currentIndex = bottlesCount - 1;
        isRed = true;
      }
    }

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
                
                Color borderColor;
                Color bgColor;
                Color iconColor;
                
                if (index == currentIndex) {
                  if (isRed) {
                    borderColor = Colors.redAccent;
                    bgColor = isChecked ? Colors.red.withValues(alpha: 0.2) : Colors.transparent;
                    iconColor = isChecked ? Colors.redAccent : Colors.redAccent.withValues(alpha: 0.5);
                  } else {
                    borderColor = Colors.amber;
                    bgColor = isChecked ? Colors.amber.withValues(alpha: 0.2) : Colors.transparent;
                    iconColor = isChecked ? Colors.amber : Colors.amber.withValues(alpha: 0.5);
                  }
                } else {
                  borderColor = isChecked ? Colors.blueAccent : Colors.grey.withValues(alpha: 0.5);
                  bgColor = isChecked ? Colors.blue.withValues(alpha: 0.2) : Colors.transparent;
                  iconColor = isChecked ? Colors.blueAccent : Colors.grey.withValues(alpha: 0.5);
                }

                return GestureDetector(
                  onTap: () => ref.read(waterTrackerProvider.notifier).toggleBottle(dayKey, index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bgColor,
                      border: Border.all(
                        color: borderColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.water_drop,
                        size: 20,
                        color: iconColor,
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

  Widget _buildTimelineItem(TimelineItem item, GlobalKey key) {
    return Padding(
      key: key,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white))),
                    if (item.mealRecord != null && item.mealRecord!.totalNutrition.calories > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orangeAccent.withOpacity(0.4)),
                        ),
                        child: Text(
                          '${item.mealRecord!.totalNutrition.calories.round()} kcal',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                        ),
                      ),
                  ],
                ),
                if (item.details.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withValues(alpha: 0.5),
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

  Widget _buildCardioScaleUpAlert() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent, width: 2),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_run, color: Colors.orangeAccent, size: 20),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'Beginning this week, add 10 min to each session of your cardio.',
              style: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeloadAlert() {
    return GestureDetector(
      onTap: () => _showDeloadDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent, width: 2),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_rounded, color: Colors.redAccent, size: 22),
            SizedBox(width: 8),
            Text(
              'DELOAD WEEK',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(width: 8),
            Text('Tap for details', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showDeloadDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fitness_center, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Deload Protocol', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            '🔴 DELOAD WEEK — Recovery Protocol\n'
            'Your body recovers and supercompensates this week. Still train, but lighter.\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'LIFTING (Mon / Wed / Thu / Fri):\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Use 50% of your normal working weight\n'
            '• Do 2 sets instead of 3-4 per exercise\n'
            '• Same rep ranges, same rest periods\n'
            '• Focus on perfect form & mind-muscle connection\n'
            '• Stop every set 4-5 reps short of failure\n\n'
            'Example:\n'
            '  If you normally Chest Press 120 lbs × 4 sets × 8 reps\n'
            '  → This week: 60 lbs × 2 sets × 8 reps\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'CARDIO:\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Tuesday LISS: Same 30 min walk, drop incline to 4-6%\n'
            '• Saturday HIIT → Replace with LISS (30 min easy walk, no sprints)\n'
            '• Sunday LISS: Keep as is\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'PLANK HOLD:\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Do 2 sets × 20-30 sec (instead of 3 × 30-60 sec)\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'NUTRITION & SUPPLEMENTS:\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Keep protein intake the same\n'
            '• Keep creatine at 5g/day (never cycle creatine)\n'
            '• Keep all other supplements unchanged\n'
            '• If hungrier than usual — that\'s normal, don\'t overeat\n\n'
            '⚡ You\'ll come back STRONGER next week. Trust the process.',
            style: TextStyle(height: 1.5, fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it — light week! 💪'),
          ),
        ],
      ),
    );
  }

  Widget _buildAshwagandhaAlert() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent, width: 2),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.do_not_disturb_alt_rounded, color: Colors.redAccent, size: 22),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              '⛔ NO ASHWAGANDHA THIS WEEK',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodDonationAlert() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('🩸 Phlebotomy Protocol', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
              'It has been ~5 months. To manage high ferritin buildup from your continuous high-iron red meat athletic diet, it is clinically recommended to donate blood.\n\nThis dumps excess ferritin and forces your body to generate fresh erythrocytes!',
              style: TextStyle(height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Got it! 🩸'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent, width: 2),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bloodtype, color: Colors.redAccent, size: 22),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                '🩸 DONATE BLOOD THIS WEEK',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyWaterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyWaterHeaderDelegate({required this.child});

  @override
  double get minExtent => 165;
  @override
  double get maxExtent => 165;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyWaterHeaderDelegate oldDelegate) {
    return true;
  }
}
