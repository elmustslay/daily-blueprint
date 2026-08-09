import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/shared_prefs.dart';
import '../data/daily_plan_data.dart';
import '../../micro_macro_calorie_track/domain/nutrition.dart';

// --- State ---
class SupplementTrackerNotifier extends Notifier<Map<String, List<bool>>> {
  @override
  Map<String, List<bool>> build() {
    final prefs = SharedPrefsLogic.instance;
    final Map<String, List<bool>> stateMap = {};

    final now = DateTime.now().subtract(const Duration(hours: 2));
    final currentWeekday = now.weekday;

    final List<String> dayKeys = [DailyPlanData.mon, DailyPlanData.tue, DailyPlanData.wed, DailyPlanData.thu, DailyPlanData.fri, DailyPlanData.sat, DailyPlanData.sun];

    for (int i = 0; i < 7; i++) {
      final dayKey = dayKeys[i];
      final tabWeekday = i + 1; // 1 to 7

      DateTime targetDate;
      final differenceInDays = tabWeekday <= currentWeekday
          ? (currentWeekday - tabWeekday)
          : (7 - (tabWeekday - currentWeekday));

      if (tabWeekday <= currentWeekday) {
        targetDate = now.subtract(Duration(days: currentWeekday - tabWeekday));
      } else {
        targetDate = now.subtract(Duration(days: 7 - (tabWeekday - currentWeekday)));
      }

      final targetDateStr = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
      
      final savedTargetDateStr = prefs.getString('supp_target_date_$dayKey');
      
      if (savedTargetDateStr != targetDateStr || differenceInDays > 4) {
        prefs.remove('supp_$dayKey');
        prefs.setString('supp_target_date_$dayKey', targetDateStr);
        stateMap[dayKey] = [false, false];
      } else {
        final keys = prefs.getStringList('supp_$dayKey');
        if (keys != null && keys.length == 2) {
          stateMap[dayKey] = keys.map((e) => e == 'true').toList();
        } else {
          stateMap[dayKey] = [false, false];
        }
      }
    }

    return stateMap;
  }

  void toggleSupplement(String dayKey, int index) {
    if (!state.containsKey(dayKey)) return;
    final newStateMap = Map<String, List<bool>>.from(state);
    final dayList = List<bool>.from(newStateMap[dayKey]!);
    dayList[index] = !dayList[index];
    newStateMap[dayKey] = dayList;
    state = newStateMap;
    
    SharedPrefsLogic.instance.setStringList('supp_$dayKey', dayList.map((e) => e.toString()).toList());
  }
}

final supplementTrackerProvider = NotifierProvider<SupplementTrackerNotifier, Map<String, List<bool>>>(SupplementTrackerNotifier.new);

class WaterTrackerNotifier extends Notifier<Map<String, List<bool>>> {
  @override
  Map<String, List<bool>> build() {
    final prefs = SharedPrefsLogic.instance;
    final Map<String, List<bool>> stateMap = {};

    final now = DateTime.now().subtract(const Duration(hours: 2));
    final currentWeekday = now.weekday;

    final List<String> dayKeys = [DailyPlanData.mon, DailyPlanData.tue, DailyPlanData.wed, DailyPlanData.thu, DailyPlanData.fri, DailyPlanData.sat, DailyPlanData.sun];

    for (int i = 0; i < 7; i++) {
      final dayKey = dayKeys[i];
      final tabWeekday = i + 1; // 1 to 7

      DateTime targetDate;
      final differenceInDays = tabWeekday <= currentWeekday
          ? (currentWeekday - tabWeekday)
          : (7 - (tabWeekday - currentWeekday));

      if (tabWeekday <= currentWeekday) {
        targetDate = now.subtract(Duration(days: currentWeekday - tabWeekday));
      } else {
        targetDate = now.subtract(Duration(days: 7 - (tabWeekday - currentWeekday)));
      }

      final targetDateStr = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
      
      final savedTargetDateStr = prefs.getString('water_target_date_$dayKey');
      final bottlesCount = DailyPlanData.waterBottles[dayKey] ?? 0;
      
      if (savedTargetDateStr != targetDateStr || differenceInDays > 4) {
        // Target date changed (a week has passed for this specific day) or > 4 days ago, clear data
        prefs.remove('water_$dayKey');
        prefs.setString('water_target_date_$dayKey', targetDateStr);
        stateMap[dayKey] = List.filled(bottlesCount, false);
      } else {
        final keys = prefs.getStringList('water_$dayKey');
        if (keys != null && keys.length == bottlesCount) {
          stateMap[dayKey] = keys.map((e) => e == 'true').toList();
        } else {
          stateMap[dayKey] = List.filled(bottlesCount, false);
        }
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

class ReminderTrackerNotifier extends Notifier<Map<String, List<bool>>> {
  @override
  Map<String, List<bool>> build() {
    final prefs = SharedPrefsLogic.instance;
    final Map<String, List<bool>> stateMap = {};

    final now = DateTime.now().subtract(const Duration(hours: 2));
    final currentWeekday = now.weekday;

    final List<String> dayKeys = [DailyPlanData.mon, DailyPlanData.tue, DailyPlanData.wed, DailyPlanData.thu, DailyPlanData.fri, DailyPlanData.sat, DailyPlanData.sun];

    for (int i = 0; i < 7; i++) {
      final dayKey = dayKeys[i];
      final tabWeekday = i + 1; // 1 to 7

      DateTime targetDate;
      final differenceInDays = tabWeekday <= currentWeekday
          ? (currentWeekday - tabWeekday)
          : (7 - (tabWeekday - currentWeekday));

      if (tabWeekday <= currentWeekday) {
        targetDate = now.subtract(Duration(days: currentWeekday - tabWeekday));
      } else {
        targetDate = now.subtract(Duration(days: 7 - (tabWeekday - currentWeekday)));
      }

      final targetDateStr = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';
      
      final savedTargetDateStr = prefs.getString('reminders_target_date_$dayKey');
      final remindersCount = DailyPlanData.getReminders(dayKey).length;
      
      if (savedTargetDateStr != targetDateStr || differenceInDays > 4) {
        prefs.remove('reminders_$dayKey');
        prefs.setString('reminders_target_date_$dayKey', targetDateStr);
        stateMap[dayKey] = List.filled(remindersCount, false);
      } else {
        final keys = prefs.getStringList('reminders_$dayKey');
        if (keys != null && keys.length == remindersCount) {
          stateMap[dayKey] = keys.map((e) => e == 'true').toList();
        } else {
          stateMap[dayKey] = List.filled(remindersCount, false);
        }
      }
    }

    return stateMap;
  }

  void toggleReminder(String dayKey, int index) {
    if (!state.containsKey(dayKey)) return;
    final newStateMap = Map<String, List<bool>>.from(state);
    final dayList = List<bool>.from(newStateMap[dayKey]!);
    dayList[index] = !dayList[index];
    newStateMap[dayKey] = dayList;
    state = newStateMap;
    
    SharedPrefsLogic.instance.setStringList('reminders_$dayKey', dayList.map((e) => e.toString()).toList());
  }
}

final reminderTrackerProvider = NotifierProvider<ReminderTrackerNotifier, Map<String, List<bool>>>(ReminderTrackerNotifier.new);

// --- UI ---
class DailyPlanScreen extends ConsumerStatefulWidget {
  const DailyPlanScreen({super.key});

  @override
  ConsumerState<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends ConsumerState<DailyPlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> days = [DailyPlanData.mon, DailyPlanData.tue, DailyPlanData.wed, DailyPlanData.thu, DailyPlanData.fri, DailyPlanData.sat, DailyPlanData.sun, 'nutrition'];
  final List<String> displayDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Nutrition'];
  final Map<String, GlobalKey> _itemKeys = {};
  
  bool _showWater = false;
  bool _showSupp = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    // Set to current day (0 = monday in our tab layout, but DateTime.weekday is 1=Mon, 7=Sun)
    int currentDayIndex = DateTime.now().weekday - 1; 
    _tabController.index = currentDayIndex;

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentTime());
      }
    });
    
    // Scroll immediately after first frame render
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentTime());
  }

  void _showReasoningDialog() async {
    try {
      final content = await rootBundle.loadString('docs/reasoning.txt');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text('Supplement Info & Conflicts', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: SelectableText(
                content,
                style: const TextStyle(fontSize: 13, fontFamily: 'monospace', color: Colors.white70),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading reasoning file: $e')),
      );
    }
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
            alignment: 0.0, // exactly at the top edge
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
        automaticallyImplyLeading: false,
        centerTitle: true,
        leadingWidth: 90,
        leading: Center(
          child: _buildToggleButton('Water', _showWater, Colors.blueAccent, () {
            setState(() { _showWater = !_showWater; });
          }),
        ),
        title: const Text('Daily Plan'),
        actions: [
          _buildToggleButton('Supps', _showSupp, Colors.greenAccent, () {
            setState(() { _showSupp = !_showSupp; });
          }),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          labelPadding: EdgeInsets.zero,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: displayDays.map((d) {
            if (d == 'Nutrition') {
              return Tab(
                child: GestureDetector(
                  onLongPress: _showReasoningDialog,
                  child: Text(d),
                ),
              );
            }
            return Tab(text: d);
          }).toList(),
        ),
      ),
      body: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: child,
          );
        },
        child: TabBarView(
          controller: _tabController,
          children: days.map((day) => day == 'nutrition' ? _buildNutritionTab() : _buildDayContent(day)).toList(),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive, Color activeColor, VoidCallback onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? activeColor : Colors.grey.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderItem(String dayKey, int index, String text, bool isChecked) {
    return GestureDetector(
      onTap: () => ref.read(reminderTrackerProvider.notifier).toggleReminder(dayKey, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isChecked ? Colors.green.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked ? Colors.green.withValues(alpha: 0.5) : Colors.amberAccent, 
            width: 1.5
          ),
          boxShadow: isChecked ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? Colors.green.withValues(alpha: 0.2) : Colors.transparent,
                border: Border.all(color: isChecked ? Colors.greenAccent : Colors.amberAccent.withValues(alpha: 0.5), width: 2),
              ),
              child: Center(
                child: isChecked ? const Icon(Icons.check, size: 14, color: Colors.greenAccent) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isChecked ? Colors.grey : Colors.amberAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyReminders(String dayKey) {
    final reminders = DailyPlanData.getReminders(dayKey);
    if (reminders.isEmpty) return const SizedBox.shrink();

    final reminderStateMap = ref.watch(reminderTrackerProvider);
    final reminderState = reminderStateMap[dayKey] ?? [];

    final completedReminders = <MapEntry<int, String>>[];
    for (int i = 0; i < reminders.length; i++) {
      final isChecked = i < reminderState.length ? reminderState[i] : false;
      if (isChecked) {
        completedReminders.add(MapEntry(i, reminders[i]));
      }
    }

    if (completedReminders.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: completedReminders.map((entry) {
          return _buildReminderItem(dayKey, entry.key, entry.value, true);
        }).toList(),
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

    final reminders = DailyPlanData.getReminders(dayKey);
    final reminderStateMap = ref.watch(reminderTrackerProvider);
    final reminderState = reminderStateMap[dayKey] ?? [];

    final incompleteReminders = <MapEntry<int, String>>[];
    for (int i = 0; i < reminders.length; i++) {
      final isChecked = i < reminderState.length ? reminderState[i] : false;
      if (!isChecked) {
        incompleteReminders.add(MapEntry(i, reminders[i]));
      }
    }

    double stickyHeight = 0;

    if (_showWater) stickyHeight += 165.0;
    if (_showSupp) stickyHeight += 165.0;
    if (incompleteReminders.isNotEmpty) {
      stickyHeight += 16.0 + (incompleteReminders.length * 68.0);
    }
    
    return CustomScrollView(
      slivers: [
        if (stickyHeight > 0)
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              extent: stickyHeight,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    if (_showWater)
                      Container(
                        height: 165.0,
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                        child: _buildWaterTracker(dayKey),
                      ),
                    if (_showSupp)
                      Container(
                        height: 165.0,
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                        child: _buildSupplementTracker(dayKey),
                      ),
                    if (incompleteReminders.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: incompleteReminders.map((entry) {
                            return SizedBox(
                              height: 68.0,
                              child: _buildReminderItem(dayKey, entry.key, entry.value, false),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildDailyReminders(dayKey),
                if (DailyPlanData.isDeloadWeek()) ...[
                  _buildDeloadAlert(),
                  const SizedBox(height: 12),
                ],
                if (DailyPlanData.shouldScaleUpCardio()) ...[
                  _buildCardioScaleUpAlert(),
                  const SizedBox(height: 12),
                ],
                if (DailyPlanData.isBloodDonationWeek()) ...[
                  _buildBloodDonationAlert(),
                  const SizedBox(height: 12),
                ],
                if (DailyPlanData.isBloodTestPrepWeek()) ...[
                  _buildBloodTestAlert(),
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
            Row(
              children: [
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
                IconButton(
                  icon: const Icon(Icons.receipt_long, color: Colors.white),
                  tooltip: 'Copy Detailed JSON',
                  onPressed: () {
                    final Map<String, dynamic> detailedExport = {};
                    for (int i = 0; i < 7; i++) {
                      final dayKey = days[i];
                      final dayItems = DailyPlanData.schedules[dayKey] ?? [];
                      final Map<String, dynamic> timePeriods = {};
                      
                      for (var item in dayItems) {
                        if (item.mealRecord != null) {
                          final nutrition = item.mealRecord!.totalNutrition;
                          if (nutrition.calories > 0 || nutrition.protein > 0 || nutrition.carbs > 0 || nutrition.fat > 0 || nutrition.microNutrients.isNotEmpty) {
                            timePeriods[item.time] = {
                              'title': item.title,
                              'nutrition': nutrition.toJson(),
                            };
                          }
                        }
                      }
                      detailedExport[dayKey] = timePeriods;
                    }
                    Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('    ').convert(detailedExport)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Detailed Nutrition JSON copied to clipboard')),
                    );
                  },
                ),
              ],
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

  Widget _buildSupplementTracker(String dayKey) {
    final suppState = ref.watch(supplementTrackerProvider);
    final dayChecks = suppState[dayKey] ?? [false, false];

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
          const Text('Daily Supplements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          const SizedBox(height: 12),
          _buildSuppCheckboxRow('Creatine (5g)', dayKey, 0, dayChecks[0]),
          const SizedBox(height: 12),
          _buildSuppCheckboxRow('Finasteride (1mg)', dayKey, 1, dayChecks[1]),
        ],
      ),
    );
  }

  Widget _buildSuppCheckboxRow(String title, String dayKey, int index, bool isChecked) {
    return GestureDetector(
      onTap: () => ref.read(supplementTrackerProvider.notifier).toggleSupplement(dayKey, index),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isChecked ? Colors.green.withValues(alpha: 0.2) : Colors.transparent,
              border: Border.all(color: isChecked ? Colors.greenAccent : Colors.grey.withValues(alpha: 0.5), width: 2),
            ),
            child: Center(
              child: isChecked ? const Icon(Icons.check, size: 16, color: Colors.greenAccent) : null,
            ),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
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
      padding: const EdgeInsets.only(top: 16, bottom: 8),
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
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                            ),
                          ),
                          if (item.isCardio && DailyPlanData.shouldScaleUpCardio()) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.orangeAccent, width: 1),
                              ),
                              child: const Text(
                                'SCALE-UP (+10 min)',
                                style: TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
                            Text('• ', style: TextStyle(color: Colors.grey, fontSize: (item.title == 'Get Ready' || item.title == 'Shower & Bed Prep') ? 18 : null)),
                            Expanded(
                              child: Text(
                                detail, 
                                style: TextStyle(
                                  color: Colors.white70, 
                                  fontSize: (item.title == 'Get Ready' || item.title == 'Shower & Bed Prep') ? 18 : null,
                                  height: (item.title == 'Get Ready' || item.title == 'Shower & Bed Prep') ? 1.4 : null,
                                ),
                              ),
                            ),
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
        content: SingleChildScrollView(
          child: Text(
            '🔴 DELOAD WEEK — Intensity-Preservation\n'
            'Because you are on a caloric deficit, dropping weight will signal your body to shed muscle. Drop fatigue, not intensity.\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'LIFTING (Mon / Wed / Thu / Fri):\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Keep your working weight the SAME (100%)\n'
            '• Cut your volume in half (e.g., 2 sets instead of 4)\n'
            '• Keep the same rep ranges and rest periods\n'
            '• Stop 2-3 reps short of failure (RPE 7) on every set\n'
            '• Do absolutely zero forced reps or drop sets\n\n'
            'Example:\n'
            '  If you normally Leg Press 200 lbs × 4 sets to failure\n'
            '  → This week: 200 lbs × 2 sets (stopping 2 reps early)\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'CARDIO (Tue / Sat):\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Keep your ${DailyPlanData.isRefeedWeek() ? "40-minute" : "1-hour"} LISS schedule exactly same.\n'
            '• Since you track HR, just stay strictly in your target zone.\n'
            '• LISS does not tax the CNS, so no deload is needed here. Keep burning the fat.\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'PLANK HOLD:\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Do 2 sets × 20-30 sec (instead of 3-4 sets)\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'NUTRITION & SUPPLEMENTS:\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Keep protein intake the exact same\n'
            '• Keep creatine at 5g/day (never cycle it)\n'
            '• Expect sleep quality to drastically improve this week\n'
            '• If hungrier than usual — that\'s normal, hold the cut line\n\n'
            '⚡ Clear the CNS fatigue. Keep the muscle. Trust the math.',
            style: TextStyle(height: 1.5, fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it — heavy weight, low volume! 🧠'),
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
            title: const Text('🩸 Therapeutic Phlebotomy Protocol', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text(
              'Therapeutic Phlebotomy Check: It has been ~5 months. To manage high ferritin buildup from a continuous, high-heme red meat diet, therapeutic phlebotomy may be required to clear oxidative stress and generate fresh erythrocytes.\n\nACTION REQUIRED: Order a full iron panel. Only execute donation if Serum Ferritin is > 250 ng/mL. Do not rely only on the hemoglobin screening being over 13.3g/dL.',
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

  Widget _buildBloodTestAlert() {
    return GestureDetector(
      onTap: () => _showBloodTestDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purpleAccent, width: 2),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.biotech_rounded, color: Colors.purpleAccent, size: 22),
            SizedBox(width: 8),
            Text(
              '🩸 BLOOD TEST MONDAY',
              style: TextStyle(
                color: Colors.purpleAccent,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(width: 8),
            Text('Tap for details', style: TextStyle(color: Colors.purpleAccent, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showBloodTestDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.biotech_rounded, color: Colors.purpleAccent),
            SizedBox(width: 8),
            Text('Blood Draw Protocol (Aug 31)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            '🩸 BLOOD DRAW PREP PROTOCOL (Quest @ 8:30 AM)\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'WEDNESDAY (AUG 26) – SUNDAY (AUG 30):\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Skip Biotin starting Wednesday morning (gives 5 full days / >72h washout to protect Thyroid, Testosterone & Estradiol immunoassay accuracy).\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'SUNDAY (AUG 30):\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• Fasting Cutoff: Finish all food/protein intake by 7:30 PM (after that, WATER ONLY).\n'
            '• Finasteride: Take earlier during the day.\n'
            '• Magnesium: Skip Sunday night magnesium to keep baseline electrolytes clean.\n'
            '• Sleep: Get a full 7.5–8 hrs of sleep (do not stay up late).\n\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'MONDAY MORNING (AUG 31 - TEST DAY):\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '• 7:45 AM: Wake up & drink 21 oz plain water (NO salt, electrolytes, or lemon).\n'
            '• Hold Supplements & Coffee: NO morning vitamins, NAC, Citicoline, or caffeine before draw.\n'
            '• 8:05 AM: Drive over for your 8:30 AM appointment at Quest.\n'
            '• Post-Draw: Eat breakfast, take all morning vitamins/supplements, and enjoy your coffee!',
            style: TextStyle(height: 1.5, fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it! 🩸'),
          ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double extent;

  _StickyHeaderDelegate({required this.child, required this.extent});

  @override
  double get minExtent => extent;
  @override
  double get maxExtent => extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return true;
  }
}
