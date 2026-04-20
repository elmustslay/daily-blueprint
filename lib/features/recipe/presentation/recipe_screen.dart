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
              'Large Stainless Steel Sauté Pan',
              'Cutting board',
            ],
            instructions: [
              'Cook Pasta: In the stock pot, bring 3 quarts of water to a rolling boil. Add 1 tsp salt, then the 12 oz chickpea pasta. Cook 7 minutes, until al dente. Drain well and set aside.',
              'Start Sauce: Heat the large dry sauté pan over medium heat for 2 mins FIRST. ONLY THEN add 1 tbsp avocado oil, followed IMMEDIATELY by the 3 lb ground turkey (this prevents oil from sitting and burning). Season with 1/4tsp pepper, break apart and cook until browned (~8 minutes).',
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
              '2 tsp Avocado oil',
              '1 lb diced chicken',
              'Salt, pepper, paprika, and cumin to taste',
            ],
            equipment: [
              '2-3 qt saucepan',
              'Large Stainless Steel Sauté Pan',
              'Colander',
              'Cutting board',
            ],
            instructions: [
              'Prep Chicken (Sunday): Dry the chicken completely and dice it. In a ziplock, mix with 2tsp avocado oil, 1tsp salt, 1/2tsp black pepper, 1tsp smoked paprika, 1/2 tsp cumin. Store in fridge until Tuesday.',
              'Heat dry pan (NO OIL YET): Heat the dry sauté pan over medium heat for 2-3 minutes. Do the "Water Bead Test" (drop a droplet of water in; if it forms a solid ball and glides around like mercury, it\'s perfectly heated). Pour the water bead out.',
              'Cook Chicken: Since the chicken is already oiled from your ziploc prep, DO NOT add more oil to the pan! (Exposed oil on a bare pan burns). Add the pre-oiled chicken directly. Let sear 4 minutes without stirring so it releases naturally.',
              'Stir Chicken: After the 4 min (when it releases from the pan easily), stir occasionally until golden brown and fully cooked (~7-10 minutes total). Tip: If empty spots in the pan start smoking/blackening, spoon in a few drops of water to cool them and stop burning.',
              'Cook Quinoa: In the saucepan, bring 2 cups of water to a boil.',
              'Wash Quinoa: Wash (colander) 1 cup quinoa.',
              'Simmer Quinoa: Add quinoa to the boiling liquid. Reduce heat to low, cover, and simmer 15 minutes or until liquid is absorbed.',
              'Rest Quinoa: Remove from heat and let sit, covered, for 5 minutes, then fluff with a fork.',
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
            equipment: ['Non-Stick Skillet (Best for fish skin)'],
            instructions: [
              'Prep & Direct Oiling: 1. Pat salmon COMPLETELY dry. 2. Pour 1-2 tsp oil directly onto the fish. 3. Rub to coat both sides. 4. Do NOT pour oil into the pan (exposed oil in the empty edges of the pan produces heavy smoke). Season with salt and pepper.',
              'Heat dry pan (Water Bead Test): Heat the dry skillet over medium heat for 2-3 mins. Drop a droplet of water; when it forms a perfect ball that glides around the pan (Leidenfrost effect), the pan is ready. Pour out the water.',
              'Sear on the skin: Place the pre-oiled salmon skin side down into the hot dry pan. (This prevents empty oil spots on the pan from smoking/burning). Press lightly for 10-15 seconds so it stays flat.',
              'Cook gently: Keep heat at medium. Let it cook 5-7 minutes. It will release from the pan naturally when it\'s ready. Tip: If empty spots in the pan start smoking/blackening, spoon in a few drops of water to cool them.',
              'Flip briefly: Turn the fillet and cook another 1-2 minutes until opaque.',
              'Rest + Store: Remove from heat and let it sit for a minute. Then Divide into 3 portions.',
            ],
          ),
          const SizedBox(height: 16),
          _buildRecipeCard(
            context,
            icon: '🥩',
            title: 'Pan-Seared Ribeye & Spinach',
            yields: '1 Serving (Sunday Dinner)',
            ingredients: [
              '<0.7 lb Ribeye Steak',
              '1/5 bag of Spinach',
              '1-2 tsp Avocado Oil',
              'Salt (to taste)',
              'Black Pepper (to taste)',
            ],
            equipment: [
              'Stainless Steel Skillet/Sauté Pan (DO NOT use Non-Stick for high heat sears)',
              'Tongs',
              'Paper Towels',
            ],
            instructions: [
              'Prep & Direct Oiling (CRUCIAL FOR NO SMOKE): 1. Pat steak COMPLETELY dry. 2. Pour 1-2 tsp oil directly onto the steak. 3. Rub coat all sides. 4. Season generously. Do NOT pour any oil directly into the pan! Your pan is much larger than the steak. If you pour oil into the empty pan, all that exposed oil around the edges of the steak will hit its smoke point and burn instantly, filling your kitchen with smoke. By only oiling the actual steak, the oil is trapped perfectly under the meat and cannot smoke.',
              'Heat dry pan (Water Bead Test): Heat the dry stainless steel skillet over medium heat. Drop 1-2 drops of water; when they form a perfect mercury-like ball that slides around without evaporating, the pan is ready. Wipe out the water.',
              'Sear Steak: Place the oiled steak into the dry pan. (Because the steak doesn\'t cover the entire pan, putting oil in the pan directly causes the exposed oil to burn and smoke heavily). Sear 3-4 mins undisturbed. Tip: If empty spots in the pan start smoking/blackening, spoon in a few drops of water to cool those spots and stop the burning. Flip and sear another 3-4 mins.',
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
