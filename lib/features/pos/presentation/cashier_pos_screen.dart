import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class CashierPosScreen extends ConsumerStatefulWidget {
  const CashierPosScreen({super.key});

  @override
  ConsumerState<CashierPosScreen> createState() => _CashierPosScreenState();
}

class _CashierPosScreenState extends ConsumerState<CashierPosScreen> {
  static const Color accentRed = Color(0xFFED101E);
  static const Color darkBg = Color(0xFF0B0B0B);
  static const Color cardColor = Color(0xFF171717);
  static const Color borderDark = Color(0xFF282828);

  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _menuItems = [
    {'id': '1', 'name': 'Signature Smoked BBQ Ribs', 'price': 449.00, 'category': 'Ribs', 'icon': Icons.local_fire_department},
    {'id': '2', 'name': 'Classic Cheeseburger', 'price': 289.00, 'category': 'Burgers', 'icon': Icons.lunch_dining},
    {'id': '3', 'name': 'Crispy Chicken Tenders', 'price': 259.00, 'category': 'Chicken', 'icon': Icons.kebab_dining},
    {'id': '4', 'name': 'Margherita Pizza', 'price': 349.00, 'category': 'Pizza', 'icon': Icons.local_pizza},
    {'id': '5', 'name': 'Creamy Alfredo Pasta', 'price': 299.00, 'category': 'Pasta', 'icon': Icons.ramen_dining},
    {'id': '6', 'name': 'BBQ Pulled Pork Sandwich', 'price': 319.00, 'category': 'Burgers', 'icon': Icons.fastfood},
    {'id': '7', 'name': 'Iced Tea Pitcher', 'price': 120.00, 'category': 'Drinks', 'icon': Icons.local_drink},
    {'id': '8', 'name': 'French Fries Large', 'price': 99.00, 'category': 'Sides', 'icon': Icons.restaurant},
  ];

  final List<Map<String, dynamic>> _orderCart = [];

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      final index = _orderCart.indexWhere((element) => element['id'] == item['id']);
      if (index >= 0) {
        _orderCart[index]['qty'] += 1;
      } else {
        _orderCart.add({
          'id': item['id'],
          'name': item['name'],
          'price': item['price'],
          'qty': 1,
        });
      }
    });
  }

  void _updateQty(int index, int change) {
    setState(() {
      _orderCart[index]['qty'] += change;
      if (_orderCart[index]['qty'] <= 0) {
        _orderCart.removeAt(index);
      }
    });
  }

  double get _subtotal => _orderCart.fold(0.0, (sum, item) => sum + (item['price'] * item['qty']));

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    final filteredItems = _selectedCategory == 'All'
        ? _menuItems
        : _menuItems.where((i) => i['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.point_of_sale, color: accentRed),
            const SizedBox(width: 10),
            const Text(
              'CASHIER POS TERMINAL',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Return to Admin Dashboard',
            icon: const Icon(Icons.dashboard_outlined, color: Colors.white70),
            onPressed: () => context.go('/owner/dashboard'),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout, color: accentRed),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).adminSignOut();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  Expanded(flex: 7, child: _buildMenuGrid(filteredItems)),
                  Container(width: 1, color: borderDark),
                  Expanded(flex: 4, child: _buildCartPanel()),
                ],
              )
            : Column(
                children: [
                  Expanded(flex: 6, child: _buildMenuGrid(filteredItems)),
                  Expanded(flex: 4, child: _buildCartPanel()),
                ],
              ),
      ),
    );
  }

  Widget _buildMenuGrid(List<Map<String, dynamic>> items) {
    final categories = ['All', 'Ribs', 'Burgers', 'Chicken', 'Pizza', 'Pasta', 'Sides', 'Drinks'];

    return Column(
      children: [
        // Category Pills Bar
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: cardColor,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: accentRed,
                  backgroundColor: const Color(0xFF222222),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                ),
              );
            },
          ),
        ),

        // Products Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () => _addToCart(item),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderDark),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'] as IconData, color: accentRed, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        item['name'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₱${(item['price'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(color: accentRed, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartPanel() {
    return Container(
      color: cardColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Order Cart',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_orderCart.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _orderCart.clear()),
                  child: const Text('Clear Order', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Expanded(
            child: _orderCart.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, color: Colors.white24, size: 48),
                        SizedBox(height: 8),
                        Text('No items in cart', style: TextStyle(color: Colors.white38)),
                        Text('Tap menu items on left to add', style: TextStyle(color: Colors.white24, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _orderCart.length,
                    separatorBuilder: (context, index) => const Divider(color: borderDark),
                    itemBuilder: (context, index) {
                      final item = _orderCart[index];
                      final itemTotal = item['price'] * item['qty'];

                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                Text(
                                  '₱${(item['price'] as double).toStringAsFixed(2)} each',
                                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.white54, size: 20),
                                onPressed: () => _updateQty(index, -1),
                              ),
                              Text(
                                '${item['qty']}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: accentRed, size: 20),
                                onPressed: () => _updateQty(index, 1),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              '₱${itemTotal.toStringAsFixed(2)}',
                              textAlign: TextAlign.end,
                              style: const TextStyle(color: accentRed, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          const Divider(color: borderDark, height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL AMOUNT:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('₱${_subtotal.toStringAsFixed(2)}', style: const TextStyle(color: accentRed, fontWeight: FontWeight.w900, fontSize: 22)),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _orderCart.isEmpty
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Payment processed successfully! Total: ₱${_subtotal.toStringAsFixed(2)}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      setState(() => _orderCart.clear());
                    },
              icon: const Icon(Icons.payment),
              label: const Text('PAY & PRINT RECEIPT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentRed,
                disabledBackgroundColor: Colors.grey.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
