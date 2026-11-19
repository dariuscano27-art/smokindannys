import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'catalog_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _quantity = 1;
  String? _selectedVariantId;
  final List<String> _selectedAddons = [];
  final _instructionsController = TextEditingController();

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productDetailsAsync = ref.watch(productDetailsProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: productDetailsAsync.when(
        data: (product) {
          final basePrice = (product['base_price'] as num) / 100;
          final variants = List<Map<String, dynamic>>.from(product['product_variants'] ?? []);
          final addonGroups = List<Map<String, dynamic>>.from(product['product_addon_groups'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.softPink.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: product['image_url'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(product['image_url'], fit: BoxFit.cover),
                        )
                      : const Icon(Icons.fastfood, size: 80, color: AppTheme.primaryPink),
                ),
                const SizedBox(height: 16),
                Text(
                  product['name'],
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '₱${basePrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPink,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product['description'] ?? 'No description available.',
                  style: const TextStyle(color: AppTheme.mutedText, height: 1.4),
                ),
                const Divider(height: 32),

                // Variants
                if (variants.isNotEmpty) ...[
                  const Text('Select Option / Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: variants.map((v) {
                      final isSelected = _selectedVariantId == v['id'];
                      final modifier = (v['price_modifier'] as num) / 100;
                      return ChoiceChip(
                        label: Text('${v['name']} (+₱${modifier.toStringAsFixed(2)})'),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryPink,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.darkText,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() => _selectedVariantId = v['id']),
                      );
                    }).toList(),
                  ),
                  const Divider(height: 24),
                ],

                // Add-ons
                if (addonGroups.isNotEmpty) ...[
                  ...addonGroups.map((group) {
                    final items = List<Map<String, dynamic>>.from(group['product_addon_group_items'] ?? []);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        ...items.map((item) {
                          final itemPrice = (item['price'] as num) / 100;
                          final isSelected = _selectedAddons.contains(item['id']);
                          return CheckboxListTile(
                            title: Text('${item['name']} (+₱${itemPrice.toStringAsFixed(2)})'),
                            value: isSelected,
                            activeColor: AppTheme.primaryPink,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  _selectedAddons.add(item['id']);
                                } else {
                                  _selectedAddons.remove(item['id']);
                                }
                              });
                            },
                          );
                        }),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),
                  const Divider(height: 24),
                ],

                // Special Instructions
                const Text('Special Order Instructions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: _instructionsController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Extra spicy, no onions please',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Quantity and Add to Cart
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.mutedText.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                          ),
                          Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to Cart successfully!')),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Add to Cart'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading product details: $err')),
      ),
    );
  }
}
