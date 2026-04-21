import 'package:flutter/material.dart';
import '../data/recipe_data.dart';
import '../../micro_macro_calorie_track/domain/nutrition.dart';

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Prep'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: RecipeData.recipes.map((recipe) => Column(
          children: [
            _buildRecipeCard(context, recipe),
            const SizedBox(height: 16),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    final nutrition = recipe.nutritionPerServing;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          '${recipe.icon} ${recipe.name}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        childrenPadding: const EdgeInsets.all(16).copyWith(top: 0),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Yields: ${recipe.yields.isNotEmpty ? recipe.yields : '${recipe.servings} Portions'}',
            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          const Text('Macros Per Serving', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroItem('Calories', '${nutrition.calories.round()}'),
                _buildMacroItem('Protein', '${nutrition.protein.round()}g'),
                _buildMacroItem('Carbs', '${nutrition.carbs.round()}g'),
                _buildMacroItem('Fat', '${nutrition.fat.round()}g'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (nutrition.microNutrients.isNotEmpty) ...[
            const Text('Micronutrients Per Serving', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: nutrition.microNutrients.entries.map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.tealAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.4)),
                ),
                child: Text('${e.key}: ${_formatAmount(e.value)}', style: const TextStyle(fontSize: 12, color: Colors.tealAccent, fontWeight: FontWeight.w600)),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],

          if (recipe.textIngredients.isNotEmpty) ...[
            const Text('Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            ...recipe.textIngredients.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.grey)),
                      Expanded(child: Text(e, style: const TextStyle(color: Colors.white70))),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ] else if (recipe.ingredients.isNotEmpty) ...[
            const Text('Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.grey)),
                      Expanded(child: Text('${_formatAmount(e.amount)} ${e.ingredient.baseUnit} ${e.ingredient.name}', style: const TextStyle(color: Colors.white70))),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],
          if (recipe.equipment.isNotEmpty) ...[
            const Text('Equipment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            ...recipe.equipment.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.grey)),
                      Expanded(child: Text(e, style: const TextStyle(color: Colors.white70))),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],
          if (recipe.instructions.isNotEmpty) ...[
            const Text('Instructions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            ...recipe.instructions.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.key + 1}. ', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                      Expanded(child: Text(entry.value, style: const TextStyle(color: Colors.white70))),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.toInt()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(1);
  }

  Widget _buildMacroItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}
