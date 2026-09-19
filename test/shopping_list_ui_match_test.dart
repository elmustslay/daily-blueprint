import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/shopping_list/presentation/shopping_list_screen.dart';

void main() {
  test('ShoppingListNotifier UI mathematically matches outputs/shopping_list.txt exactly', () async {
    final file = File('outputs/shopping_list.txt');
    if (!await file.exists()) {
      fail('outputs/shopping_list.txt does not exist. Run export_grocery_list_test.dart first.');
    }

    final content = await file.readAsString();
    final Map<String, String> groceryList = {};
    
    // Parse the text file
    final lines = content.split('\n');
    for (final line in lines) {
      if (line.startsWith('- ')) {
        final colonIndex = line.indexOf(':');
        if (colonIndex != -1) {
          final name = line.substring(2, colonIndex).trim();
          final quantities = line.substring(colonIndex + 1).trim();
          groceryList[name] = quantities.toLowerCase(); // Lowercase for easier regex matching
        }
      }
    }

    void verifyItemExact(List<ShoppingItem> items, String uiName, String fileKey, RegExp uiRegex, RegExp fileRegex, {double multiplier = 1.0}) {
      final item = items.firstWhere((i) => i.name.contains(uiName), orElse: () => throw Exception('Item $uiName not found in UI list'));
      final subtext = item.subtext.toLowerCase();
      
      final fileStr = groceryList[fileKey];
      if (fileStr == null) {
        fail('Key "$fileKey" not found in outputs/shopping_list.txt');
      }
      
      final uiMatch = uiRegex.firstMatch(subtext);
      if (uiMatch == null) {
        fail('Could not extract number from UI subtext: "$subtext" for $uiName using regex ${uiRegex.pattern}');
      }
      final uiNumber = double.parse(uiMatch.group(1)!);
      
      final fileMatch = fileRegex.firstMatch(fileStr);
      if (fileMatch == null) {
        fail('Could not extract number from file text: "$fileStr" for $fileKey using regex ${fileRegex.pattern}');
      }
      final fileNumber = double.parse(fileMatch.group(1)!);
      
      expect(
        uiNumber * multiplier,
        closeTo(fileNumber, 0.1),
        reason: 'Mismatch for $uiName: UI says $uiNumber, Simulation calculated $fileNumber'
      );
    }

    // Standard Week Check
    final standardItems = ShoppingListNotifier.getInitialItems(false);
    
    verifyItemExact(standardItems, 'Spinach', 'Spinach', RegExp(r'(\d+(?:\.\d+)?)\s*bag'), RegExp(r'(\d+(?:\.\d+)?)\s*bag\s*\(standard\)'));
    verifyItemExact(standardItems, 'Kiwis', 'Trader Joe\'s Kiwi (Skin-On)', RegExp(r'(\d+(?:\.\d+)?)\s*kiwis', caseSensitive: false), RegExp(r'(\d+(?:\.\d+)?)\s*kiwi'));
    verifyItemExact(standardItems, 'Baby Carrots', 'Baby Carrots', RegExp(r'(\d+(?:\.\d+)?)\s*oz'), RegExp(r'(\d+(?:\.\d+)?)\s*oz'));
    verifyItemExact(standardItems, 'Bananas', 'Banana', RegExp(r'(\d+(?:\.\d+)?)\s*bananas', caseSensitive: false), RegExp(r'(\d+(?:\.\d+)?)\s*medium\s*\(standard\)'));
    verifyItemExact(standardItems, 'Ground Turkey', 'Ground Turkey (93% Lean)', RegExp(r'(\d+(?:\.\d+)?)\s*lbs?'), RegExp(r'(\d+(?:\.\d+)?)\s*lb\s*\(standard\)'));
    verifyItemExact(standardItems, 'Ground Beef', 'Ground Beef (96% Lean)', RegExp(r'(\d+(?:\.\d+)?)\s*lb'), RegExp(r'(\d+(?:\.\d+)?)\s*lb'));
    verifyItemExact(standardItems, 'Salmon', 'Wild Sockeye Salmon', RegExp(r'(\d+(?:\.\d+)?)\s*lb\s*\('), RegExp(r'(\d+(?:\.\d+)?)\s*lb'));
    verifyItemExact(standardItems, 'Eggs', 'Egg', RegExp(r'need\s*(\d+(?:\.\d+)?)/week'), RegExp(r'(\d+(?:\.\d+)?)\s*large egg'));
    verifyItemExact(standardItems, 'Pasta', 'Barilla Protein+ Pasta', RegExp(r'\((\d+(?:\.\d+)?)\s*oz\)'), RegExp(r'(\d+(?:\.\d+)?)\s*oz'));
    verifyItemExact(standardItems, 'Marinara Sauce', 'Marinara Sauce', RegExp(r'(\d+(?:\.\d+)?)\s*jars?'), RegExp(r'(\d+(?:\.\d+)?)\s*jar\s*\(standard\)'));
    verifyItemExact(standardItems, 'Nutritional Yeast', 'Nutritional Yeast', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tbsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tbsp\s*\(standard\)'));
    verifyItemExact(standardItems, 'Avocado Oil', 'Avocado Oil', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tsp'));
    verifyItemExact(standardItems, 'Smoked Paprika', 'Smoked Paprika', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tsp'));
    verifyItemExact(standardItems, 'Garlic Powder', 'Garlic Powder', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tbsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tbsp\s*\(standard\)'));
    verifyItemExact(standardItems, 'Onion Powder', 'Onion Powder', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tsp'));
    verifyItemExact(standardItems, 'Dried Oregano', 'Dried Oregano', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tsp'));
    verifyItemExact(standardItems, 'Italian Seasoning', 'Italian Seasoning', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tbsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tsp'), multiplier: 3.0);
    verifyItemExact(standardItems, 'Morton Lite Salt', 'Morton Lite Salt', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tsp\s*\(standard\)'));
    verifyItemExact(standardItems, 'Black Pepper', 'Black Pepper', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tsp'));
    verifyItemExact(standardItems, 'Ground Cumin', 'Ground Cumin', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tsp'));
    verifyItemExact(standardItems, 'Iodized Table Salt (or Sea Salt)', 'Iodized Table Salt', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tsp\s*\(standard\)'));

    verifyItemExact(standardItems, 'D3-K2 Supplement', 'D3-K2', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*capsules?'), RegExp(r'(\d+(?:\.\d+)?)\s*capsule'));
    verifyItemExact(standardItems, 'Omega-3 Supplement', 'Omega-3', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*softgels?'), RegExp(r'(\d+(?:\.\d+)?)\s*softgel'));
    verifyItemExact(standardItems, 'Whey Isolate Protein', 'Whey Isolate', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*scoops?'), RegExp(r'(\d+(?:\.\d+)?)\s*scoop'));
    verifyItemExact(standardItems, 'Creatine Monohydrate', 'Creatine Monohydrate', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*scoops?'), RegExp(r'(\d+(?:\.\d+)?)\s*scoop'));
    verifyItemExact(standardItems, 'Casein Protein Powder', 'Casein', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*scoops?'), RegExp(r'(\d+(?:\.\d+)?)\s*scoop'));
    verifyItemExact(standardItems, 'Magnesium Glycinate', 'Magnesium Glycinate', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*capsules?'), RegExp(r'(\d+(?:\.\d+)?)\s*capsule'));
    verifyItemExact(standardItems, 'Citicoline', 'Citicoline', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*capsules?'), RegExp(r'(\d+(?:\.\d+)?)\s*capsule'));
    verifyItemExact(standardItems, 'NAC + Selenium', 'NAC + Selenium', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*capsules?'), RegExp(r'(\d+(?:\.\d+)?)\s*capsule'));
    verifyItemExact(standardItems, 'Ashwagandha', 'Ashwagandha', RegExp(r'(\d+(?:\.\d+)?)\s*capsules?\s*\(on\)'), RegExp(r'(\d+(?:\.\d+)?)\s*capsule\s*\(on\)'));


    // Refeed Week Check
    final refeedItems = ShoppingListNotifier.getInitialItems(true);
    verifyItemExact(refeedItems, 'Morton Lite Salt', 'Morton Lite Salt', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tsp\s*\(refeed\)'));
    verifyItemExact(refeedItems, 'Bananas', 'Banana', RegExp(r'(\d+(?:\.\d+)?)\s*bananas', caseSensitive: false), RegExp(r'(\d+(?:\.\d+)?)\s*medium\s*\(refeed\)'));
    verifyItemExact(refeedItems, 'Blueberries', 'Trader Joe\'s Blueberries', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*cups?'), RegExp(r'(\d+(?:\.\d+)?)\s*cup\s*\(refeed\)'));
    verifyItemExact(refeedItems, 'Quinoa', 'Quinoa', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*cups'), RegExp(r'(\d+(?:\.\d+)?)\s*cup\s*\(dry\)\s*\(refeed\)'));

    verifyItemExact(refeedItems, 'Spinach', 'Spinach', RegExp(r'(\d+(?:\.\d+)?)\s*bag'), RegExp(r'(\d+(?:\.\d+)?)\s*bag\s*\(refeed\)'));
    verifyItemExact(refeedItems, 'Ground Turkey', 'Ground Turkey (93% Lean)', RegExp(r'(\d+(?:\.\d+)?)\s*lbs?'), RegExp(r'(\d+(?:\.\d+)?)\s*lb\s*\(refeed\)'));
    verifyItemExact(refeedItems, 'Marinara Sauce', 'Marinara Sauce', RegExp(r'(\d+(?:\.\d+)?)\s*jars?'), RegExp(r'(\d+(?:\.\d+)?)\s*jar\s*\(refeed\)'));
    verifyItemExact(refeedItems, 'Garlic Powder', 'Garlic Powder', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tbsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tbsp\s*\(refeed\)'));
    verifyItemExact(refeedItems, 'Iodized Table Salt (or Sea Salt)', 'Iodized Table Salt', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tsp\s*\(refeed\)'));
    verifyItemExact(refeedItems, 'Nutritional Yeast', 'Nutritional Yeast', RegExp(r'need\s*(\d+(?:\.\d+)?)\s*tbsp'), RegExp(r'(\d+(?:\.\d+)?)\s*tbsp\s*\(refeed\)'));
  });
}
