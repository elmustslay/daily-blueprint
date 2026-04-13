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
        title: const Text('Fix-ur-life'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome back, El',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'What would you like to focus on today?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildDashboardCard(
                      context,
                      title: 'Daily Plan',
                      icon: Icons.calendar_today_rounded,
                      color: Colors.blueAccent,
                      destination: const DailyPlanScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Gym Plan',
                      icon: Icons.fitness_center_rounded,
                      color: Colors.redAccent,
                      destination: const GymPlanScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Recipes',
                      icon: Icons.restaurant_menu_rounded,
                      color: Colors.orangeAccent,
                      destination: const RecipeScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Shopping List',
                      icon: Icons.shopping_cart_rounded,
                      color: Colors.greenAccent,
                      destination: const ShoppingListScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Book Plan',
                      icon: Icons.book_rounded,
                      color: Colors.purpleAccent,
                      destination: const BookPlanScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      title: 'Weight',
                      icon: Icons.monitor_weight_rounded,
                      color: Colors.tealAccent,
                      destination: const WeightTrackScreen(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
