import 'package:flutter/material.dart';
import '../data/ingredients_data.dart';
import '../domain/nutrition.dart';

class IngredientsScreen extends StatelessWidget {
  const IngredientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show ingredients that are bought at Trader Joe's (or on the regular grocery shopping list)
    final ingredients = [
      IngredientsData.spinach,
      IngredientsData.kiwi,
      IngredientsData.blueberries,
      IngredientsData.babyCarrots,
      IngredientsData.banana,
      
      IngredientsData.groundTurkey,
      IngredientsData.leanGroundBeef96,
      IngredientsData.salmon,
      
      IngredientsData.egg,
      
      IngredientsData.barillaProteinPlus,
      IngredientsData.quinoa,
      IngredientsData.marinaraSauce,
      IngredientsData.nutritionalYeast,
      IngredientsData.avocadoOil,
      
      IngredientsData.liteSalt,
      IngredientsData.smokedPaprika,
      IngredientsData.garlicPowder,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
      ),
      body: ListView.builder(
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          final ingredient = ingredients[index];
          return ListTile(
            title: Text(ingredient.name),
            subtitle: Text('${ingredient.nutritionPerBaseUnit.calories} kcal per ${ingredient.baseUnit}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  double multiplier = 1.0;
                  return StatefulBuilder(
                    builder: (context, setState) {
                      final scaledNutrition = ingredient.nutritionPerBaseUnit * multiplier;
                      return AlertDialog(
                        title: Text(ingredient.name),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Compare at store:',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value: multiplier,
                                      min: 0.1,
                                      max: 5.0,
                                      divisions: 49,
                                      label: '${multiplier.toStringAsFixed(2)}x',
                                      onChanged: (val) => setState(() => multiplier = val),
                                    ),
                                  ),
                                  Text('${multiplier.toStringAsFixed(2)}x', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(onPressed: () => setState(() => multiplier = 0.25), child: const Text('1/4')),
                                  TextButton(onPressed: () => setState(() => multiplier = 0.5), child: const Text('1/2')),
                                  TextButton(onPressed: () => setState(() => multiplier = 1.0), child: const Text('1x')),
                                ],
                              ),
                              const Divider(),
                              Text('Showing macros for: ${(multiplier).toStringAsFixed(2)} ${ingredient.baseUnit}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              Text('Calories: ${scaledNutrition.calories.toStringAsFixed(0)} kcal'),
                              Text('Protein: ${scaledNutrition.protein.toStringAsFixed(1)}g'),
                              Text('Carbs: ${scaledNutrition.carbs.toStringAsFixed(1)}g'),
                              Text('Fat: ${scaledNutrition.fat.toStringAsFixed(1)}g'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
