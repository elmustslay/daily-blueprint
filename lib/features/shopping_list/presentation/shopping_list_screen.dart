import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/shared_prefs.dart';

// --- Domain & State ---
class ShoppingItem {
  final String id;
  final String name;
  final String subtext;
  final bool isChecked;

  ShoppingItem({required this.id, required this.name, this.subtext = '', this.isChecked = false});

  ShoppingItem copyWith({bool? isChecked}) {
    return ShoppingItem(
      id: id,
      name: name,
      subtext: subtext,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}

class ShoppingListNotifier extends Notifier<List<ShoppingItem>> {
  @override
  List<ShoppingItem> build() {
    final initialItems = [
      // Produce
      ShoppingItem(id: 'prod-3', name: 'Bell Peppers', subtext: '2 pack (6)'),
      ShoppingItem(id: 'prod-4', name: 'Spinach', subtext: '1 bag (/5)'),
      ShoppingItem(id: 'prod-7', name: 'Bananas', subtext: '1 bunch (need 4/week)'),
      
      // Poultry & Meat
      ShoppingItem(id: 'meat-1', name: 'Ground Turkey', subtext: '3 lbs'),
      ShoppingItem(id: 'meat-2', name: '96% Lean Ground Beef', subtext: '1 lb'),
      ShoppingItem(id: 'meat-3', name: 'Sockeye Salmon Fillet', subtext: '1 lb (hard min 0.82 lb)'),
      // Dairy
      ShoppingItem(id: 'dairy-1', name: 'Eggs', subtext: '1.5 dozen (need 18/week)'),
      ShoppingItem(id: 'dairy-2', name: '2% Unsweetened Almond Milk', subtext: '.5 gallon'),

      // Others
      ShoppingItem(id: 'oth-1', name: 'Canned Lentils', subtext: '2 containers'),
      ShoppingItem(id: 'oth-2', name: 'Chickpea Fusilli Pasta', subtext: '1 box (need 12oz)'),
      ShoppingItem(id: 'oth-3', name: 'Quinoa', subtext: '1 bag (need 1 cup)'),
      ShoppingItem(id: 'oth-4', name: 'Marinara Sauce', subtext: '2 jar (48 oz)'),

      ShoppingItem(id: 'oth-7', name: 'Nutritional Yeast', subtext: '1 container (need 12tbsp)'),
      ShoppingItem(id: 'oth-8', name: 'Avocado Oil', subtext: '1 bottle'),
      
      // Spices
      ShoppingItem(id: 'spc-1', name: 'Smoked Paprika', subtext: 'need 2tsp'),
      ShoppingItem(id: 'spc-2', name: 'Garlic Powder', subtext: 'need 1.5tsp'),
      ShoppingItem(id: 'spc-3', name: 'Onion Powder', subtext: 'need 1tsp'),
      ShoppingItem(id: 'spc-4', name: 'Dried Oregano', subtext: 'need 1tsp'),



      // Amazon
      ShoppingItem(id: 'amz-2', name: 'Psyllium Husk'),
      ShoppingItem(id: 'amz-3', name: 'Multivitamins'),
      ShoppingItem(id: 'amz-4', name: 'D3-K2 Supplement'),
      ShoppingItem(id: 'amz-5', name: 'Omega-3 Supplement'),
      ShoppingItem(id: 'amz-6', name: 'Whey Isolate Protein'),
      ShoppingItem(id: 'amz-7', name: 'Creatine Monohydrate'),
      ShoppingItem(id: 'amz-8', name: 'Casein Protein Powder'),
      ShoppingItem(id: 'amz-9', name: 'Magnesium Glycinate'),
      ShoppingItem(id: 'amz-10', name: 'Citicoline'),
      ShoppingItem(id: 'amz-11', name: 'NAC + Selenium'),
      ShoppingItem(id: 'amz-13', name: 'Ashwagandha'),
      ShoppingItem(id: 'amz-14', name: 'Chia Seeds'),
      ShoppingItem(id: 'amz-15', name: 'Anua Heartleaf Pore Control Cleansing Oil', subtext: 'Sunscreen Remover'),
      ShoppingItem(id: 'amz-16', name: 'La Roche-Posay Lipikar Wash AP+', subtext: 'Moisturizing Body Wash (for 2x daily showers)'),
    ];

    final prefs = SharedPrefsLogic.instance;
    return initialItems.map((item) {
      final isChecked = prefs.getBool('shop_${item.id}') ?? false;
      return item.copyWith(isChecked: isChecked);
    }).toList();
  }

  void toggleItem(String id) {
    final prefs = SharedPrefsLogic.instance;
    state = state.map((item) {
      if (item.id == id) {
        final newValue = !item.isChecked;
        prefs.setBool('shop_$id', newValue);
        return item.copyWith(isChecked: newValue);
      }
      return item;
    }).toList();
  }

  void resetAll() {
    final prefs = SharedPrefsLogic.instance;
    state = state.map((item) {
      prefs.setBool('shop_${item.id}', false);
      return item.copyWith(isChecked: false);
    }).toList();
  }
}

final shoppingListProvider = NotifierProvider<ShoppingListNotifier, List<ShoppingItem>>(ShoppingListNotifier.new);

// --- UI ---
class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(shoppingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset list',
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Trader Joe's"),
            Tab(text: 'Amazon'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTraderJoesTab(items),
          _buildAmazonTab(items),
        ],
      ),
    );
  }

  Widget _buildTraderJoesTab(List<ShoppingItem> allItems) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Produce'),
        _buildSectionItems(allItems, (item) => item.id.startsWith('prod-')),
        const SizedBox(height: 16),
        _buildSectionHeader('Poultry & Meat'),
        _buildSectionItems(allItems, (item) => item.id.startsWith('meat-')),
        const SizedBox(height: 16),
        _buildSectionHeader('Dairy'),
        _buildSectionItems(allItems, (item) => item.id.startsWith('dairy-')),
        const SizedBox(height: 16),
        _buildSectionHeader('Others'),
        _buildSectionItems(allItems, (item) => item.id.startsWith('oth-')),
        const SizedBox(height: 16),
        _buildSectionHeader('Spices'),
        _buildSectionItems(allItems, (item) => item.id.startsWith('spc-')),
      ],

    );
  }

  Widget _buildAmazonTab(List<ShoppingItem> allItems) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Supplements (Restock?)'),
        _buildSectionItems(allItems, (item) => item.id.startsWith('amz-')),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildSectionItems(List<ShoppingItem> allItems, bool Function(ShoppingItem) filter) {
    final sectionItems = allItems.where(filter).toList();
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sectionItems.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Theme.of(context).dividerColor),
        itemBuilder: (context, index) {
          final item = sectionItems[index];
          return ListTile(
            onTap: () => ref.read(shoppingListProvider.notifier).toggleItem(item.id),
            leading: Checkbox(
              value: item.isChecked,
              onChanged: (val) {
                ref.read(shoppingListProvider.notifier).toggleItem(item.id);
              },
            ),
            title: Text(
              item.name,
              style: TextStyle(
                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                color: item.isChecked ? Colors.grey : Colors.white,
              ),
            ),
            trailing: item.subtext.isNotEmpty
                ? Text(item.subtext, style: const TextStyle(color: Colors.grey, fontSize: 13))
                : null,
          );
        },
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Shopping List?'),
        content: const Text('This will uncheck all items. Use this at the start of a new shopping trip.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(shoppingListProvider.notifier).resetAll();
              Navigator.of(ctx).pop();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
