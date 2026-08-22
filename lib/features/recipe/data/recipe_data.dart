import '../../micro_macro_calorie_track/domain/nutrition.dart';
import '../../micro_macro_calorie_track/data/ingredients_data.dart';
import '../../daily_plan/data/daily_plan_data.dart';

class RecipeData {
  static List<Recipe> get recipes => [
    Recipe(
      id: 'pasta',
      name: 'Pasta Recipe',
      icon: '🍝',
      yields: '6 Portions (6 Fridge)',
      textIngredients: [
        '18 oz Carbe Diem Pasta (1.5 boxes)',
        '1 tbsp avocado oil',
        '2 lb ground turkey',
        '2.5 tsp Morton Lite Salt',
        '1 tbsp garlic powder, 1 tbsp Italian seasoning, 1 tsp Smoked Paprika',
        'Pepper to taste',
        '2 jars marinara sauce',
        '4 tbsp nutritional yeast',
        '1 bag of Spinach (Wilted at the end)',
      ],
      servings: 6,
      ingredients: [
        IngredientPortion(ingredient: IngredientsData.carbeDiemPasta, amount: 18),
        IngredientPortion(ingredient: IngredientsData.avocadoOil, amount: 3),
        IngredientPortion(ingredient: IngredientsData.groundTurkey, amount: 2),
        IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 2.5),
        IngredientPortion(ingredient: IngredientsData.marinaraSauce, amount: 2),
        IngredientPortion(ingredient: IngredientsData.nutritionalYeast, amount: 4),
        IngredientPortion(ingredient: IngredientsData.spinach, amount: 1),
        IngredientPortion(ingredient: IngredientsData.garlicPowder, amount: 1),
        IngredientPortion(ingredient: IngredientsData.smokedPaprika, amount: 1),
      ],
      equipment: [
        'Large 12 qt Stainless Steel Sauté Pan',
        'Wooden spoon or spatula',
        'Cutting board',
      ],
      instructions: [
        'Turkey Sear & Salt (Foundation Seasoning): Preheat the dry 12 qt stainless steel sauté pan over medium-high heat for 2-3 minutes (until a drop of water glides across the surface like mercury). Add 1 tbsp (3 tsp) of avocado oil, then immediately add the 3 lb ground turkey. Season evenly with the 2.5 tsp Morton Lite Salt, 1 tbsp garlic powder, 1 tbsp Italian seasoning, 1 tsp smoked paprika, and pepper to taste. Sauté and break apart until browned (~8 minutes).',
        'Liquid & Pasta Boil (One-Pot): Pour the 2 cups of water and the 48 oz of marinara sauce into the pan first. Stir well and bring to a boil. Slide the dry 24 oz Carbe Diem pasta directly into the liquid, ensuring it is submerged. Reduce heat to medium-low, cover with a lid, and simmer for 6 minutes, stirring occasionally.',
        'Add Yeast: Uncover the pan, stir in the 4 tbsp of nutritional yeast. Cook covered for another 3-5 minutes until the pasta is al dente and the liquid is beautifully absorbed.',
        'Wilt Spinach: Stir in the bag of spinach and cook uncovered for 2 minutes over low heat until fully wilted and incorporated.',
        'Store: Divide into 6 containers (for the fridge). Let cool uncovered on the counter for 20-30 minutes before snapping the lids on to prevent condensation/waterlogging and keep the pasta chewy al dente.',
      ],
    ),
    const Recipe(
      id: 'beef',
      name: 'Ground Beef Bowl',
      icon: '🍛',
      yields: '4 Portions (4 Fridge)',
      textIngredients: [
        '1 lb 96% Lean Ground Beef',
        '1 tsp avocado oil',
        '2 tsp Morton Lite Salt, 1 tsp black pepper',
        '2 tsp smoked paprika, 1 tsp cumin',
        '1 tsp garlic powder, 1 tsp onion powder, 1 tsp dried oregano',
        '1/4 cup water (for deglazing)',
        'Fresh Lemon or Lime wedges (crucial for moisture)',
      ],
      servings: 4,
      ingredients: [
        IngredientPortion(ingredient: IngredientsData.leanGroundBeef96, amount: 1),
        IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 2),
        IngredientPortion(ingredient: IngredientsData.avocadoOil, amount: 1),
        IngredientPortion(ingredient: IngredientsData.garlicPowder, amount: 0.333),
        IngredientPortion(ingredient: IngredientsData.smokedPaprika, amount: 2.0),
      ],
      equipment: [
        'Large Stainless Steel Sauté Pan',
        'Small bowl (for spice bloom)',
      ],
      instructions: [
        'Minute 0 (Prep the Bloom): Mix paprika, cumin, garlic, onion, and oregano in a small bowl. Keep salt/pepper separate. Have 1/4 cup of water ready.',
        'Minute 2 (Preheat Pan): Place the large stainless steel pan over medium-high heat. Let it preheat dry for 2 minutes.',
        'Minute 4 (Oiling & Maillard Sear): Add the 1 tsp avocado oil, swirling to coat. Immediately add the raw ground beef. Sprinkle 2 tsp Lite Salt & 1 tsp pepper evenly over the beef. Let sit untouched 60s for a brown crust, then break apart. Cook 3-4 mins until pink is gone.',
        'Minute 8 (The Bloom & Deglaze): Turn beef pan to Low. Push beef to perimeter. Dump the spice blend in the center, toasting them in the oil/fat for 15 seconds to release volatile flavor compounds. Pour in the 1/4 cup of water. Stir vigorously to deglaze pan, scraping up browned bits, and mix through beef. Turn heat off.',
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
        '0.75 tsp avocado oil, 0.5 tsp Morton Lite Salt, pepper',
      ],
      servings: 3,
      ingredients: [
        IngredientPortion(ingredient: IngredientsData.salmon, amount: 1),
        IngredientPortion(ingredient: IngredientsData.avocadoOil, amount: 0.75),
        IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 0.5),
      ],
      equipment: [
        'Non-Stick Skillet (Best for fish skin)',
      ],
      instructions: [
        'Prep & Direct Oiling: Pat salmon COMPLETELY bone-dry on both sides with paper towels (moisture creates steam, preventing crispy skin). Pour the 0.75 tsp avocado oil directly onto the skin side only of the fillets; rub to coat evenly. Season the skin side with a tiny pinch of the 0.5 tsp Lite Salt.',
        'Season Flesh: Turn fillets over. Season the flesh side evenly with the remaining Lite Salt and pepper. Do NOT pour oil into the pan or onto the flesh side (this prevents empty pan areas from smoking/burning).',
        'Pan Preheat (Coating Protection): Heat the dry non-stick skillet over medium heat for only 60-90 seconds. Do not let it get smoking hot, as excessive dry heat degrades the non-stick coating.',
        'Sear on the skin: Place the pre-oiled salmon skin side down into the warm skillet. Press down gently with a spatula for 10-15 seconds so the fillets stay flat and make uniform contact with the pan.',
        'Cook gently: Keep heat at medium. Let it cook undisturbed 5-7 minutes. The fat will render from the skin, turning it crispy. (If empty areas of the pan start smoking, spoon in a few drops of water to cool them). The fish is ready to flip when the skin releases naturally.',
        'Flip briefly: Turn the fillet and cook another 1-2 minutes until opaque on the sides and medium-rare in the center.',
        'Rest + Store: Remove from heat and let it rest on a plate for 2 minutes. Then divide into 3 portions.',
      ],
    ),
    const Recipe(
      id: 'hard_boiled_eggs',
      name: 'Perfect Hard Boiled Eggs',
      icon: '🥚',
      yields: '18 Eggs',
      textIngredients: [
        '18 large eggs',
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
        'The Setup: Do this in 3 batches to prep all 18 eggs for the entire week (Mon-Sun). First, let the eggs sit on the cabinet for 10 minutes (putting cold eggs in is explosive/causes cracking). Pierce the top (non-pointy end, which is also the top in the carton) of each egg with a pin, and keep that side up too.',
        'Cook: Add the exact water amount for "Hard Boiled" into your cooker. Run the cycle until it shuts off.',
        'The Ice Bath (CRITICAL): Immediately transfer the hot eggs into a bowl of heavy ice water. Let them sit for 5 minutes. The thermal shock shrinks the egg away from the shell, creating a microscopic gap that makes peeling effortless.',
        'Store: Keep the eggs IN THEIR SHELLS and place them into your dedicated clear egg storage bin in the fridge so they never mix with raw eggs. Unpeeled eggs last 7 days. Peeled eggs get slimy after 2 days.',
        'Peeling Hack: When you are at work and ready to eat, crack the egg all over by rolling it on your desk under your palm. The shell will slide off in one or two large pieces.',
      ],
    ),
    const Recipe(
      id: 'quinoa',
      name: 'Refeed Quinoa',
      icon: '🍚',
      yields: '6 Portions (3 Containers for Mon-Sat)',
      textIngredients: [
        '3.0 cups dry Quinoa',
        '6 cups water or bone broth',
        '1 tsp Morton Lite Salt (optional)',
      ],
      servings: 6,
      ingredients: [
        IngredientPortion(ingredient: IngredientsData.quinoa, amount: 3.0),
        IngredientPortion(ingredient: IngredientsData.liteSalt, amount: 1),
      ],
      equipment: [
        'Medium Saucepan or Rice Cooker',
        'Fine mesh strainer',
      ],
      instructions: [
        'Rinse: Rinse the 3.0 cups of dry quinoa thoroughly in a fine mesh strainer under cold water to remove saponins (which cause bitterness).',
        'Cook: Combine the rinsed quinoa, 6 cups of liquid (water or broth), and salt in the saucepan. Bring to a rolling boil.',
        'Simmer: Reduce heat to low, cover, and simmer for 15 minutes until the liquid is absorbed and the quinoa germs have popped out (little white tails).',
        'Rest: Remove from heat and let it sit covered for 5 minutes. Fluff with a fork.',
        'Store: Divide into 3 containers (each container holds 2 servings = 1.0 cup dry equivalent). During Refeed Weeks, eat half a container with your Salmon (Mon-Wed) and Beef (Thu-Sat) dinners. Sunday dinner gets extra rice & beans at Chipotle!',
      ],
    ),
  ];
}
