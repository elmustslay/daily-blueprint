import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../daily_plan/presentation/daily_plan_screen.dart';
import '../../gym_plan/presentation/gym_plan_screen.dart';
import '../../recipe/presentation/recipe_screen.dart';
import '../../shopping_list/presentation/shopping_list_screen.dart';
import '../../book_plan/presentation/book_plan_screen.dart';
import '../../weight_track/presentation/weight_track_screen.dart';
import '../../micro_macro_calorie_track/presentation/ingredients_screen.dart';
import '../../learn_tigrinya/presentation/learn_tigrinya_screen.dart';
import '../data/steps_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back, El!'),
            Consumer(builder: (context, ref, child) {
              final stepsAsync = ref.watch(stepsProvider);
              return stepsAsync.when(
                data: (data) {
                  if (data.errorMessage != null) {
                    return Text('Health Error: ${data.errorMessage}', style: const TextStyle(fontSize: 12, color: Colors.redAccent));
                  }
                  
                  final now = DateTime.now();
                  final bool isLowActivityDay = (now.weekday == DateTime.thursday || now.weekday == DateTime.friday);
                  
                  Widget textWidget;
                  if (isLowActivityDay) {
                    int dailyLeft = 4000 - data.currentDailySteps;
                    if (dailyLeft > 0) {
                      textWidget = Text('You only have $dailyLeft left for the day to walk', style: const TextStyle(fontSize: 12, color: Colors.orangeAccent, fontWeight: FontWeight.bold));
                    } else {
                      textWidget = const Text('Daily step limit reached! Rest up.', style: TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold));
                    }
                  } else {
                    if (data.stepsRemainingWeekly > 0) {
                      textWidget = Text('${data.stepsRemainingWeekly} steps left this week!', style: const TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.bold));
                    } else {
                      textWidget = const Text('Weekly step goal reached!', style: TextStyle(fontSize: 12, color: Colors.greenAccent, fontWeight: FontWeight.bold));
                    }
                  }
                  
                  return GestureDetector(
                    onTap: () {
                      _showBalanceSheet(context, data);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          textWidget,
                          const SizedBox(width: 6),
                          const Icon(Icons.info_outline, size: 14, color: Colors.blueAccent),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Text('Loading steps...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                error: (err, stack) => const Text('Error loading steps', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
              );
            }),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDashboardCard(
                              context,
                              title: 'Daily Plan',
                              icon: Icons.calendar_today_rounded,
                              color: Colors.blueAccent,
                              destination: const DailyPlanScreen(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDashboardCard(
                              context,
                              title: 'Gym Plan',
                              icon: Icons.fitness_center_rounded,
                              color: Colors.redAccent,
                              destination: const GymPlanScreen(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDashboardCard(
                              context,
                              title: 'Recipes',
                              icon: Icons.restaurant_menu_rounded,
                              color: Colors.orangeAccent,
                              destination: const RecipeScreen(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDashboardCard(
                              context,
                              title: 'Shopping List',
                              icon: Icons.shopping_cart_rounded,
                              color: Colors.greenAccent,
                              destination: const ShoppingListScreen(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDashboardCard(
                              context,
                              title: 'Book Plan',
                              icon: Icons.book_rounded,
                              color: Colors.purpleAccent,
                              destination: const BookPlanScreen(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDashboardCard(
                              context,
                              title: 'Weight',
                              icon: Icons.monitor_weight_rounded,
                              color: Colors.tealAccent,
                              destination: const WeightTrackScreen(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDashboardCard(
                              context,
                              title: 'Ingredients',
                              icon: Icons.kitchen_rounded,
                              color: Colors.amberAccent,
                              destination: const IngredientsScreen(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDashboardCard(
                              context,
                              title: 'Learn Tigranya',
                              icon: Icons.language_rounded,
                              color: Colors.lightBlueAccent,
                              destination: const LearnTigranyaScreen(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildProgressBar(context),
            ],
          ),
        ),
      ),
    );
  }

  
  void _showBalanceSheet(BuildContext context, StepsData data) {
    
    String formatLog(WorkoutLog log) {
      final dayStr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][log.date.weekday - 1];
      final timeStr = "${log.date.hour > 12 ? log.date.hour - 12 : log.date.hour == 0 ? 12 : log.date.hour}:${log.date.minute.toString().padLeft(2, '0')}${log.date.hour >= 12 ? 'pm' : 'am'}";
      return '${log.stepsEquivalent} on $dayStr';
    }
    
    String formatLastRecorded(List<WorkoutLog> logs) {
      if (logs.isEmpty) return 'None recorded yet';
      final log = logs.first;
      final dayStr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][log.date.weekday - 1];
      final timeStr = "${log.date.hour > 12 ? log.date.hour - 12 : log.date.hour == 0 ? 12 : log.date.hour}:${log.date.minute.toString().padLeft(2, '0')}${log.date.hour >= 12 ? 'pm' : 'am'}";
      return 'Last recorded $dayStr at $timeStr';
    }

    String danceHistory = data.danceWorkouts.isEmpty ? '' : data.danceWorkouts.map((l) => formatLog(l)).join(' + ');
    String lissHistory = data.lissWorkouts.isEmpty ? '' : data.lissWorkouts.map((l) => formatLog(l)).join(' + ');

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Aerobic Balance Sheet 📊', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Weekly Goal:', style: TextStyle(color: Colors.white70)),
                Text('${data.targetWeeklySteps}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ]),
              const Divider(color: Colors.white24, height: 24),
              
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Natural Steps:', style: TextStyle(color: Colors.white70)),
                Text('${data.naturalSteps}', style: const TextStyle(color: Colors.greenAccent)),
              ]),
              const SizedBox(height: 16),
              
              const Text('Dance Equivalent:', style: TextStyle(color: Colors.white70)),
              Text('${data.totalDanceSteps} steps', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
              if (data.danceWorkouts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('($danceHistory)\n${formatLastRecorded(data.danceWorkouts)}', style: const TextStyle(fontSize: 12, color: Colors.white38)),
                ),
              const SizedBox(height: 16),

              const Text('LISS Equivalent:', style: TextStyle(color: Colors.white70)),
              Text('${data.totalLissSteps} steps', style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
              if (data.lissWorkouts.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('($lissHistory)\n${formatLastRecorded(data.lissWorkouts)}', style: const TextStyle(fontSize: 12, color: Colors.white38)),
                ),
              const Divider(color: Colors.white24, height: 24),
              
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Remaining:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('${data.stepsRemainingWeekly}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              ]),
              
              const SizedBox(height: 24),
              const Text('Note: 1 Active Calorie = 20 Steps (Conservative multiplier to guarantee fat loss). Resistance training is purposefully excluded to protect muscle repair calculations (EPOC).', style: TextStyle(fontSize: 11, color: Colors.white38, fontStyle: FontStyle.italic)),
              const SizedBox(height: 24),
            ],
          ),
        );
      }
    );
  }
Widget _buildProgressBar(BuildContext context) {
    final startDate = DateTime(2026, 7, 27);
    final targetDate = DateTime(2026, 12, 17); // Target Dec 17th for maintenance
    final now = DateTime.now();
    
    final totalDays = targetDate.difference(startDate).inDays;
    
    int daysElapsed = now.difference(startDate).inDays + 1;
    if (daysElapsed < 1) daysElapsed = 1;
    if (daysElapsed > totalDays) daysElapsed = totalDays;
    
    double progress = daysElapsed / totalDays.toDouble();
    
    int daysTillMaintenance = targetDate.difference(now).inDays;
    if (daysTillMaintenance < 0) daysTillMaintenance = 0;
    
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Phase Change Triggers', style: TextStyle(color: Colors.white)),
            backgroundColor: Theme.of(context).cardColor,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Trigger 1: The Biofeedback Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  SizedBox(height: 8),
                  Text('Even with cyclic refeeds, a 136-day deep deficit carries risks. Hitting these signals means your body has shifted from optimally burning fat to starvation-induced panic. However, you must differentiate between a false alarm and a true failure:', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.1), border: Border.all(color: Colors.amber), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('🟡 YELLOW LIGHTS (Hold The Line)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                        SizedBox(height: 4),
                        Text('An isolated 3 AM wake-up, a single bad gym session, or one day of achy joints means NOTHING. It could just be stress or a bad night of sleep. Do not change the plan.', style: TextStyle(color: Colors.white70, height: 1.4)),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), border: Border.all(color: Colors.redAccent), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('🔴 RED LIGHTS (Execute The Fix)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                        SizedBox(height: 4),
                        Text('1. The Cascading Failure: 2+ symptoms happen at the same time (e.g., your lifts crash AND you wake up at 3 AM).\n2. The Persistent Failure: 1 symptom lasts for 2+ weeks straight.', style: TextStyle(color: Colors.white70, height: 1.4)),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('1. The Gym Crash (Systemic Failure, not Local Fatigue)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  Text('Stalling on a lift is standard in a deep deficit. However, actively losing strength on the bar means your CNS is fried. IMPORTANT: This must be a SYSTEMIC failure. If just your Bench drops, that is local fatigue. If your Upper AND Lower splits BOTH drop in the same week, your body has started catabolizing your 104 lbs of lean mass for fuel.', style: TextStyle(color: Colors.white70, height: 1.4)),
                  SizedBox(height: 12),
                  Text('2. The 3 AM Cortisol Wake-Up', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  Text('This is textbook nocturnal hypoglycemia. When in a deep deficit, your liver glycogen depletes by the middle of the night. To keep your brain functioning, your adrenal glands pump out a massive surge of cortisol and adrenaline to force your body to make new glucose. You wake up hot, heart racing, and wide awake.', style: TextStyle(color: Colors.white70, height: 1.4)),
                  SizedBox(height: 12),
                  Text('3. The Joint/Libido Crash', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  Text('This is the endocrine system waving a white flag. When energy availability drops too low for too long, your body downregulates testosterone production and decreases the synovial fluid that lubricates your joints to conserve energy.', style: TextStyle(color: Colors.white70, height: 1.4)),
                  SizedBox(height: 16),
                  Text('The Fix (Bump to ~1,900 Calories or Maintenance)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                  Text('Adding ~450 calories (primarily from carbohydrates) or dropping entirely into maintenance for a week the second one of these lights turns red is the perfect biological intervention. It refills your glycogen, drops your cortisol, restores your sleep, and allows you to keep losing fat—just at a slightly slower, sustainable rate.', style: TextStyle(color: Colors.white70, height: 1.4)),
                  SizedBox(height: 24),
                  Divider(color: Colors.white24),
                  SizedBox(height: 24),
                  Text('Trigger 2: The Finish Line (21.2% Body Fat)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                  SizedBox(height: 8),
                  Text('At 21.2% body fat, you will be significantly leaner, your clothes will fit much better, and you will have lost over 20 lbs of pure fat. This is the perfect springboard for the next phase.', style: TextStyle(color: Colors.white70, height: 1.4)),
                  SizedBox(height: 12),
                  Text('The Fix (Bump to ~2,200+ Maintenance)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                  Text('Bumping up to a maintenance intake once you hit this target on December 17th is the ultimate endgame for this cycle. Your metabolism will roar back to life, your strength in the gym will skyrocket, and your body will be perfectly primed to "recomp" during your maintenance phase.', style: TextStyle(color: Colors.white70, height: 1.4)),
                ]
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Got it', style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Dec 17th Target ($daysTillMaintenance Days till Maintenance)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$daysElapsed / $totalDays',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${totalDays - daysElapsed} days remaining to achieve ~13-15% body fat and switch to maintenance.',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          if (totalDays - daysElapsed <= 7)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.1), border: Border.all(color: Colors.greenAccent), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('🌟 FINISH LINE: ETHIOPIA PREP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                  SizedBox(height: 8),
                  Text('Good job making it this far. Now for maintenance:\n\n1. Take 1/4 tsp Potassium Chloride (like "No Salt") in water morning and night to flush restaurant sodium. Do NOT chug it all at once.\n2. Drink over 4 liters a day.\n3. Aim for ~2,120 calories (this is true maintenance, fixing your metabolism).\n4. Macros: 140g Protein, 75g Fat, 220g Carb (fuels brain + resistance training).\n5. Keep up the resistance training (no LISS needed)!\n6. Stick to tequila and vodka and count a shot as 25g carb, 100 calories.', style: TextStyle(color: Colors.white, height: 1.5, fontSize: 13)),
                ],
              ),
            ),
        ],
      ),
    ));
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
