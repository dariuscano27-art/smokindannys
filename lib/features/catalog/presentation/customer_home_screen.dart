import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'catalog_provider.dart';
import 'product_details_screen.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(productsProvider);
    final filterState = ref.watch(catalogFilterProvider);
    final filterNotifier = ref.read(catalogFilterProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smokin Dannys BBQ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shopping Cart coming up in Phase 4')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Sort bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => filterNotifier.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search ribs, burgers, steaks...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  onSelected: (val) => filterNotifier.setSortBy(val),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
                    const PopupMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                    const PopupMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                  ],
                ),
              ],
            ),
          ),

          // Categories Horizontal List
          SizedBox(
            height: 50,
            child: categoriesAsync.when(
              data: (categories) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: filterState.categoryId == null,
                        selectedColor: AppTheme.primaryPink,
                        labelStyle: TextStyle(
                          color: filterState.categoryId == null ? Colors.white : AppTheme.darkText,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => filterNotifier.setCategory(null),
                      ),
                    ),
                    ...categories.map((cat) {
                      final isSelected = filterState.categoryId == cat['id'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(cat['name']),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryPink,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.darkText,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => filterNotifier.setCategory(cat['id']),
                        ),
                      );
                    }),
                  ],
                );
              },
              loading: () => const Center(child: CircularIndicatorSmall()),
              error: (err, st) => const SizedBox.shrink(),
            ),
          ),

          const SizedBox(height: 12),

          // Products Grid
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Text('No products found matching your search.'),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final pricePesos = (product['base_price'] as num) / 100;
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(productId: product['id']),
                          ),
                        );
                      },
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                color: AppTheme.softPink.withValues(alpha: 0.3),
                                width: double.infinity,
                                child: product['image_url'] != null
                                    ? Image.network(product['image_url'], fit: BoxFit.cover)
                                    : const Icon(Icons.fastfood, size: 48, color: AppTheme.primaryPink),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₱${pricePesos.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppTheme.primaryPink,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading products: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class CircularIndicatorSmall extends StatelessWidget {
  const CircularIndicatorSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
