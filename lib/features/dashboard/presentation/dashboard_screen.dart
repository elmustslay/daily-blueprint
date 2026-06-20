import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../daily_plan/presentation/daily_plan_screen.dart';
import '../../gym_plan/presentation/gym_plan_screen.dart';
import '../../recipe/presentation/recipe_screen.dart';
import '../../shopping_list/presentation/shopping_list_screen.dart';
import '../../book_plan/presentation/book_plan_screen.dart';
import '../../weight_track/presentation/weight_track_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome back, El!'),
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

  Widget _buildProgressBar(BuildContext context) {
    final startDate = DateTime(2026, 5, 1);
    final now = DateTime.now();
    
    int daysElapsed = now.difference(startDate).inDays + 1;
    if (daysElapsed < 1) daysElapsed = 1;
    if (daysElapsed > 200) daysElapsed = 200;
    
    double progress = daysElapsed / 200.0;
    
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
                  Text('Hitting these signals means your body has shifted from optimally burning fat to starvation-induced panic. However, you must differentiate between a false alarm and a true failure:', style: TextStyle(color: Colors.white70)),
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
                  Text('The Fix (Bump to ~1,900 Calories)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                  Text('Adding ~450 calories (primarily from carbohydrates) the second one of these lights turns red is the perfect biological intervention. It refills your glycogen, drops your cortisol, restores your sleep, and allows you to keep losing fat—just at a slightly slower, sustainable rate.', style: TextStyle(color: Colors.white70, height: 1.4)),
                  SizedBox(height: 24),
                  Divider(color: Colors.white24),
                  SizedBox(height: 24),
                  Text('Trigger 2: The Finish Line (15% Body Fat)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                  SizedBox(height: 8),
                  Text('At ~15% body fat, the upper two abdominals become clearly visible, and the linea alba (the vertical line down the stomach) pulls tight. Dropping below 15% usually requires extreme suffering and massive risk to your lean mass. 15% is the sweet spot where you look highly athletic but hormones function perfectly.', style: TextStyle(color: Colors.white70, height: 1.4)),
                  SizedBox(height: 12),
                  Text('The Fix (Bump to ~2,200+ Maintenance)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                  Text('Bumping up to a maintenance intake the second you see those top two abs in the mirror is the ultimate endgame. Your metabolism will roar back to life, your strength in the gym will skyrocket, and your body will be perfectly primed to "recomp"—building dense, new muscle while staying lean all year round.', style: TextStyle(color: Colors.white70, height: 1.4)),
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
              const Expanded(
                child: Text(
                  'The 200-Day Grind',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$daysElapsed / 200',
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
            '${200 - daysElapsed} days remaining to achieve 15% body fat.',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
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
