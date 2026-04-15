import 'package:flutter/material.dart';

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
        children: [
          _buildRecipeCard(
            context,
            icon: '🍝',
            title: 'Pasta Recipe',
            yields: '6 Portions (6 Fridge)',
            ingredients: [
              '12 oz chickpea fusilli pasta',
              '2 tbsp avocado oil',
              '3 lb ground turkey',
              '2 container canned lentils',
              'Salt & pepper to taste',
              '6 bell peppers',
              '48 oz marinara sauce',
              '12 tbsp nutritional yeast',
            ],
            equipment: [
              '6-8 qt stock pot (with strainer)',
              'Large sauté pan (12-inch or 3-4 qt)',
              'Cutting board',
            ],
            instructions: [
              'Cook Pasta: In the stock pot, bring 3 quarts of water to a rolling boil. Add 1 tsp salt, then the 12 oz chickpea pasta. Cook 7 minutes, until al dente. Drain well and set aside.',
              'Start Sauce: In the large sauté pan, heat 1 tbsp avocado oil over medium heat. Add 3 lb ground turkey, season with 1/4tsp pepper, and break apart and cook until browned (~8 minutes).',
              'Add Veggies: While turkey is browning, wash and chop the 6 bell peppers. Once turkey is browned, add the chopped peppers and cook until softened (~5-6 minutes).',
              'Simmer: Slowly pour in 48 oz marinara sauce (rinse jar with a little water and add that too). Stir as it heats (~3 minutes). Lower heat to medium-low.',
              'Finish Sauce: drain & rinse lentil. Simmer uncovered for 10 minutes, stirring occasionally. Stir in 12 tbsp nutritional yeast to finish.',
              'Combine: Add the drained chickpea pasta to the sauté pan with the sauce. Toss everything together for 2 minutes over low heat until evenly coated and hot.',
              'Store: Divide into 6 containers (for the fridge).',
            ],
          ),
          const SizedBox(height: 16),
          _buildRecipeCard(
            context,
            icon: '🍛',
            title: 'Quinoa & Chicken Recipe',
            yields: '4 Portions (4 Fridge)',
            ingredients: [
              '2 cups water',
              '1 cup quinoa, rinsed',
              'Avocado oil (2tsp + 1tbsp)',
              '1 lb diced chicken',
              '2 tbsp butter',
              'Salt, pepper, paprika, and cumin to taste',
            ],
            equipment: [
              '2-3 qt saucepan',
              'Large sauté pan (12-inch or 3-4 qt)',
              'Colander',
              'Cutting board',
            ],
            instructions: [
              'Prep Chicken (Sunday): Dry the chicken completely and dice it. In a ziplock, mix with 2tsp avocado oil, 1tsp salt, 1/2tsp black pepper, 1tsp smoked paprika, 1/2 tsp cumin. Store in fridge until Tuesday.',
              'Heat Pan: Heat a bit of avocado oil (1 tbsp) in the sauté pan over medium-high heat.',
              'Cook Chicken: Once oil dances, add the chicken. Let sear 4 minutes without stirring.',
              'Stir Chicken: After the 4 min, stir occasionally and cook until golden brown and fully cooked (~7-10 minutes total). Once done, add 1 tbsp butter to it.',
              'Cook Quinoa: In the saucepan, bring 2 cups of water to a boil.',
              'Wash Quinoa: Wash (colander) 1 cup quinoa.',
              'Simmer Quinoa: Add quinoa to the boiling liquid. Reduce heat to low, cover, and simmer 15 minutes or until liquid is absorbed.',
              'Rest Quinoa: Remove from heat and let sit, covered, for 5 minutes, then fluff with a fork and add 1 tbsp butter.',
              'Combine: Add cooked quinoa to the chicken in the skillet and mix thoroughly.',
              'Store: Divide into 4 containers.',
            ],
          ),
          const SizedBox(height: 16),
          _buildRecipeCard(
            context,
            icon: '🐟',
            title: 'Salmon',
            yields: '3 Portions (3 Fridge)',
            ingredients: [
              '1 lb salmon',
              '1-2 tsp avocado oil, salt, pepper (as needed)',
            ],
            equipment: [],
            instructions: [
              'Dry: Pat salmon dry. Season with salt and pepper.',
              'Heat the pan: Add avocado oil to a skillet and heat over medium-high until it moves freely in the pan.',
              'Sear on the skin: Place the salmon skin side down. Press lightly for 10-15 seconds so it stays flat.',
              'Cook gently: Reduce heat to medium. Let it cook 5-7 minutes. The skin protects it from drying out.',
              'Flip briefly: Turn the fillet and cook another 1-2 minutes, just until the top side becomes opaque.',
              'Rest + Store: Remove from heat and let it sit for a minute. Then Divide into 3 portions.',
            ],
          ),
          const SizedBox(height: 16),
          _buildRecipeCard(
            context,
            icon: '🥩',
            title: 'Pan-Seared Sirloin & Spinach',
            yields: '1 Serving (Sunday Dinner)',
            ingredients: [
              '0.5 lb (8 oz) Top Sirloin Steak',
              '1/5 bag of Spinach',
              '1-2 tsp Avocado Oil',
              'Salt (to taste)',
              'Black Pepper (to taste)',
            ],
            equipment: [
              'Cast Iron Skillet (or heavy-bottomed sauté pan)',
              'Tongs',
              'Paper Towels',
            ],
            instructions: [
              'Prep Steak: Remove steak from the fridge 30 minutes before cooking. Pat dry with paper towels. Season all sides generously with salt and pepper.',
              'Heat Pan: Place skillet over medium-high heat and let it get very hot. Add the avocado oil and heat until it shimmers.',
              'Sear Steak: Carefully place the steak in the hot pan. Let it sear undisturbed for 3-4 minutes. Flip and sear the other side for 3-4 minutes (for medium-rare).',
              'Rest Steak: Transfer the steak to a cutting board and let rest for 5-10 minutes.',
              'Cook Spinach: While steak rests, reduce pan heat to medium-low. Add the spinach to the hot pan and stir for 1-2 minutes until just wilted.',
              'Serve: Slice the steak against the grain and serve immediately with the wilted spinach.',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String yields,
    required List<String> ingredients,
    required List<String> equipment,
    required List<String> instructions,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          '$icon $title',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        childrenPadding: const EdgeInsets.all(16).copyWith(top: 0),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Yields: $yields',
            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (ingredients.isNotEmpty) ...[
            const Text('Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            ...ingredients.map((e) => Padding(
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
          if (equipment.isNotEmpty) ...[
            const Text('Equipment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            ...equipment.map((e) => Padding(
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
          if (instructions.isNotEmpty) ...[
            const Text('Instructions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            ...instructions.asMap().entries.map((entry) => Padding(
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
}
