import '../../micro_macro_calorie_track/domain/nutrition.dart';
import '../../micro_macro_calorie_track/data/ingredients_data.dart';

class RecipeData {
  static final List<Recipe> recipes = [
    const Recipe(
      id: 'pasta',
      name: 'Pasta Recipe',
      icon: '🍝',
      yields: '6 Portions (6 Fridge)',
      textIngredients: [
        '12 oz chickpea fusilli pasta',
        '2 tbsp avocado oil',
        '3 lb ground turkey',
        '2 container canned lentils',
        'Pepper to taste',
        '6 bell peppers',
        '48 oz marinara sauce',
        '12 tbsp nutritional yeast',
        '4/5 bag of Spinach (Wilted at the end)',
      ],
      servings: 6,
      ingredients: [
        IngredientPortion(ingredient: IngredientsData.chickpeaPasta, amount: 12),
        IngredientPortion(ingredient: IngredientsData.avocadoOil, amount: 6), // 2 tbsp = 6 tsp
        IngredientPortion(ingredient: IngredientsData.groundTurkey, amount: 3),
        IngredientPortion(ingredient: IngredientsData.cannedLentils, amount: 2),
        IngredientPortion(ingredient: IngredientsData.bellPeppers, amount: 6),
        IngredientPortion(ingredient: IngredientsData.marinaraSauce, amount: 48),
        IngredientPortion(ingredient: IngredientsData.nutritionalYeast, amount: 12),
        IngredientPortion(ingredient: IngredientsData.spinach, amount: 0.8), // 4/5 bag
      ],
      equipment: [
        '6-8 qt stock pot (with strainer)',
        'Large Stainless Steel Sauté Pan',
        'Cutting board',
      ],
      instructions: [
        'Cook Pasta: In the stock pot, bring 3 quarts of water to a rolling boil. Add the 12 oz chickpea pasta. Cook 7 minutes, until al dente. Drain well and set aside.',
        'Start Sauce: Heat the large dry sauté pan over medium heat for 2 mins FIRST. ONLY THEN add 1 tbsp avocado oil, followed IMMEDIATELY by the 3 lb ground turkey (this prevents oil from sitting and burning). Season with 1/4tsp pepper, break apart and cook until browned (~8 minutes).',
        'Add Veggies: While turkey is browning, wash and chop the 6 bell peppers. Once turkey is browned, add the chopped peppers and cook until softened (~5-6 minutes).',
        'Simmer: Slowly pour in 48 oz marinara sauce (rinse jar with a little water and add that too). Stir as it heats (~3 minutes). Lower heat to medium-low.',
        'Finish Sauce: drain & rinse lentil. Simmer uncovered for 10 minutes, stirring occasionally. Stir in 12 tbsp nutritional yeast to finish.',
        'Combine & Wilt: Add the drained chickpea pasta and 4/5 bag of spinach to the sauté pan with the sauce. Toss everything together for 2 minutes over low heat until the spinach is fully wilted and pasta is coated.',
        'Store: Divide into 6 containers (for the fridge).',
      ],
    ),
    const Recipe(
      id: 'quinoa_beef',
      name: 'Quinoa & Ground Beef Bowl',
      icon: '🍛',
      yields: '4 Portions (4 Fridge)',
      textIngredients: [
        '1 cup quinoa, rinsed',
        '2 cups water',
        '1 lb 96% Lean Ground Beef',
        '2 tsp Morton Lite Salt, 1 tsp black pepper',
        '2 tsp smoked paprika, 1.5 tsp cumin',
        '1.5 tsp garlic powder, 1 tsp onion powder, 1 tsp dried oregano',
        '1/4 cup water (for deglazing)',
        'Fresh Lemon or Lime wedges (crucial for moisture)',
      ],
      servings: 4,
      ingredients: [
        IngredientPortion(ingredient: IngredientsData.quinoa, amount: 1),
        IngredientPortion(ingredient: IngredientsData.leanGroundBeef96, amount: 1),
        IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 2),
      ],
      equipment: [
        '2-3 qt saucepan with tight lid',
        'Large Stainless Steel Sauté Pan',
        'Small bowl (for spice bloom)',
      ],
      instructions: [
        'Minute 0 (The Quinoa Simmer): Bring 2 cups water to a boil. Add 1 cup washed quinoa. Reduce heat to lowest possible setting, cover with tight lid, and set timer for 15 minutes.',
        'Minute 5 (Prep the Bloom): While simmering, mix paprika, cumin, garlic, onion, and oregano in a small bowl. Keep salt/pepper separate. Have 1/4 cup of water ready.',
        'Minute 10 (Preheat Pan): Place large dry skillet over medium-high heat. Let it get hot for 2 minutes.',
        'Minute 12 (The Maillard Sear): Add raw beef to dry pan. Instantly sprinkle 2 tsp Lite Salt & 1 tsp pepper. Let sit untouched 60s for a brown crust, then break apart. Cook 3-4 mins until pink is gone.',
        'Minute 15 (The Quinoa Rest): Quinoa timer ends. Do NOT lift lid. Move off heat and rest 5 mins (trapped steam makes it fluffy).',
        'Minute 16 (The Bloom & Deglaze): Turn beef pan to Low. Push beef to perimeter. Dump spice blend in center, toast 15 seconds. Pour in the 1/4 cup of water. Stir vigorously to deglaze pan, mix through beef. Turn heat off.',
        'Minute 20 (The Sponge Effect): Fluff quinoa, dump into beef pan. Toss thoroughly so thirsty quinoa absorbs the spiced liquid.',
        'The Acid Finish: Store in 4 containers. Right before eating, aggressively squeeze fresh lemon/lime juice over the top (the acid triggers salivation, masking any dryness).',
      ],
    ),
    const Recipe(
      id: 'salmon',
      name: 'Salmon',
      icon: '🐟',
      yields: '3 Portions (3 Fridge)',
      textIngredients: [
        '1 lb salmon',
        '1.5 tsp avocado oil, 1.5 tsp Morton Lite Salt, pepper',
      ],
      servings: 3,
      ingredients: [
        IngredientPortion(ingredient: IngredientsData.salmon, amount: 1),
        IngredientPortion(ingredient: IngredientsData.avocadoOil, amount: 1.5),
        IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 1.5),
      ],
      equipment: [
        'Non-Stick Skillet (Best for fish skin)',
      ],
      instructions: [
        'Prep & Direct Oiling: 1. Pat salmon COMPLETELY dry. 2. Pour 1-2 tsp oil directly onto the fish. 3. Rub to coat both sides. 4. Do NOT pour oil into the pan (exposed oil in the empty edges of the pan produces heavy smoke). Season with 1.5 tsp Morton Lite Salt and pepper.',
        'Heat dry pan (Water Bead Test): Heat the dry skillet over medium heat for 2-3 mins. Drop a droplet of water; when it forms a perfect ball that glides around the pan (Leidenfrost effect), the pan is ready. Pour out the water.',
        'Sear on the skin: Place the pre-oiled salmon skin side down into the hot dry pan. (This prevents empty oil spots on the pan from smoking/burning). Press lightly for 10-15 seconds so it stays flat.',
        'Cook gently: Keep heat at medium. Let it cook 5-7 minutes. It will release from the pan naturally when it\'s ready. Tip: If empty spots in the pan start smoking/blackening, spoon in a few drops of water to cool them.',
        'Flip briefly: Turn the fillet and cook another 1-2 minutes until opaque.',
        'Rest + Store: Remove from heat and let it sit for a minute. Then Divide into 3 portions.',
      ],
    ),
    const Recipe(
      id: 'ribeye',
      name: 'Pan-Seared Ribeye & Spinach',
      icon: '🥩',
      yields: '1 Serving (Sunday Dinner)',
      textIngredients: [
        '0.7 lb Ribeye Steak',
        '1/5 bag of Spinach',
        '1.5 tsp Avocado Oil',
        '0.5 tsp Morton Lite Salt',
        'Black Pepper (to taste)',
      ],
      servings: 1,
      ingredients: [
        IngredientPortion(ingredient: IngredientsData.ribeye, amount: 0.7),
        IngredientPortion(ingredient: IngredientsData.spinach, amount: 0.2), // 1/5 bag
        IngredientPortion(ingredient: IngredientsData.avocadoOil, amount: 1.5),
        IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 0.5),
      ],
      equipment: [
        'Stainless Steel Skillet/Sauté Pan (DO NOT use Non-Stick for high heat sears)',
        'Tongs',
        'Paper Towels',
      ],
      instructions: [
        'Prep & Direct Oiling (CRUCIAL FOR NO SMOKE): 1. Pat steak COMPLETELY dry. 2. Pour 1-2 tsp oil directly onto the steak. 3. Rub coat all sides. 4. Season with 0.5 tsp Morton Lite Salt. Do NOT pour any oil directly into the pan! Your pan is much larger than the steak. If you pour oil into the empty pan, all that exposed oil around the edges of the steak will hit its smoke point and burn instantly, filling your kitchen with smoke. By only oiling the actual steak, the oil is trapped perfectly under the meat and cannot smoke.',
        'Heat dry pan (Water Bead Test): Heat the dry stainless steel skillet over medium heat. Drop 1-2 drops of water; when they form a perfect mercury-like ball that slides around without evaporating, the pan is ready. Wipe out the water.',
        'Sear Steak: Place the oiled steak into the dry pan. (Because the steak doesn\'t cover the entire pan, putting oil in the pan directly causes the exposed oil to burn and smoke heavily). Sear 3-4 mins undisturbed. Tip: If empty spots in the pan start smoking/blackening, spoon in a few drops of water to cool those spots and stop the burning. Flip and sear another 3-4 mins.',
        'Rest Steak: Transfer the steak to a cutting board and let rest for 5-10 minutes.',
        'Cook Spinach: While steak rests, reduce pan heat to medium-low. Add the spinach to the hot pan and stir for 1-2 minutes until just wilted.',
        'Serve: Slice the steak against the grain and serve immediately with the wilted spinach.',
      ],
    ),
    const Recipe(
      id: 'hard_boiled_eggs',
      name: 'Perfect Hard Boiled Eggs',
      icon: '🥚',
      yields: '18 Eggs (All on Sunday)',
      textIngredients: [
        '18 large eggs (All on Sunday)',
        'Ice cubes and cold water (Crucial for peeling)',
      ],
      servings: 18,
      ingredients: [
        IngredientPortion(ingredient: IngredientsData.egg, amount: 18),
      ],
      equipment: [
        '7-Egg Cooker',
        'Large bowl for ice bath',
      ],
      instructions: [
        'The Setup: Do this in 3 batches on Sunday to prep all 18 eggs for the entire week (Mon-Sun). Pierce the bottom of each egg if your cooker has a pin (prevents cracking).',
        'Cook: Add the exact water amount for "Hard Boiled" into your cooker. Run the cycle until it shuts off.',
        'The Ice Bath (CRITICAL): Immediately transfer the hot eggs into a bowl of heavy ice water. Let them sit for 5 minutes. The thermal shock shrinks the egg away from the shell, creating a microscopic gap that makes peeling effortless.',
        'Store: Keep the eggs IN THEIR SHELLS and place them into your dedicated clear egg storage bin in the fridge so they never mix with raw eggs. Unpeeled eggs last 7 days. Peeled eggs get slimy after 2 days.',
        'Peeling Hack: When you are at work and ready to eat, crack the egg all over by rolling it on your desk under your palm. The shell will slide off in one or two large pieces.',
      ],
    ),
  ];
}
