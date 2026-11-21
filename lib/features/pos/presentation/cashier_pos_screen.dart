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
  static const Color accentRed = AppTheme.primaryMaroon;
  static const Color darkBg = AppTheme.background;
  static const Color cardColor = AppTheme.surface;
  static const Color borderDark = AppTheme.borderMaroon;

  int _mobileTab = 0; // 0 = POS, 1 = Orders, 2 = Profile
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

  final List<Map<String, dynamic>> _staffOrders = [
    {'id': '#SD-1048', 'customer': 'Table 4 (Dine-In)', 'items': 'Signature Smoked Ribs x2', 'total': 898.00, 'status': 'Ready'},
    {'id': '#SD-1047', 'customer': 'Takeout - Maria Santos', 'items': 'Classic Cheeseburger', 'total': 389.00, 'status': 'Preparing'},
    {'id': '#SD-1046', 'customer': 'Table 2 (Dine-In)', 'items': 'Margherita Pizza', 'total': 648.00, 'status': 'Completed'},
  ];

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

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.point_of_sale, color: accentRed),
            const SizedBox(width: 10),
            Text(
              isDesktop ? 'STAFF POS & ORDER MANAGEMENT' : 'STAFF MOBILE POS',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout, color: accentRed),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).adminSignOut();
              if (!mounted) return;
              context.go('/');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  Expanded(flex: 7, child: _buildPosTab()),
                  Container(width: 1, color: borderDark),
                  Expanded(flex: 4, child: _buildCartPanel()),
                ],
              )
            : _buildMobileBody(),
      ),
      bottomNavigationBar: isDesktop ? null : _buildMobileBottomNav(),
    );
  }

  Widget _buildMobileBody() {
    switch (_mobileTab) {
      case 0:
        return Column(
          children: [
            Expanded(flex: 6, child: _buildPosTab()),
            Expanded(flex: 4, child: _buildCartPanel()),
          ],
        );
      case 1:
        return _buildOrdersTab();
      case 2:
        return _buildProfileTab();
      default:
        return _buildPosTab();
    }
  }

  Widget _buildMobileBottomNav() {
    return BottomNavigationBar(
      currentIndex: _mobileTab,
      onTap: (idx) => setState(() => _mobileTab = idx),
      backgroundColor: cardColor,
      selectedItemColor: accentRed,
      unselectedItemColor: Colors.white54,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'POS Terminal'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders Queue'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Staff Profile'),
      ],
    );
  }

  Widget _buildPosTab() {
    final filteredItems = _selectedCategory == 'All'
        ? _menuItems
        : _menuItems.where((i) => i['category'] == _selectedCategory).toList();
    final categories = ['All', 'Ribs', 'Burgers', 'Chicken', 'Pizza', 'Pasta', 'Sides', 'Drinks'];

    return Column(
      children: [
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.15,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return InkWell(
                onTap: () => _addToCart(item),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderDark),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'] as IconData, color: accentRed, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        item['name'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₱${(item['price'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(color: accentRed, fontWeight: FontWeight.bold, fontSize: 13),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transaction Cart',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (_orderCart.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _orderCart.clear()),
                  child: const Text('Clear', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _orderCart.isEmpty
                ? const Center(
                    child: Text('Cart is empty. Tap items above.', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  )
                : ListView.separated(
                    itemCount: _orderCart.length,
                    separatorBuilder: (context, index) => const Divider(color: borderDark, height: 1),
                    itemBuilder: (context, index) {
                      final item = _orderCart[index];
                      final itemTotal = item['price'] * item['qty'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['name'], style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                  Text('₱${(item['price'] as double).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => _updateQty(index, -1),
                                  child: const Icon(Icons.remove_circle_outline, color: Colors.white54, size: 18),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('${item['qty']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                InkWell(
                                  onTap: () => _updateQty(index, 1),
                                  child: const Icon(Icons.add_circle_outline, color: accentRed, size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text('₱${itemTotal.toStringAsFixed(2)}', style: const TextStyle(color: accentRed, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Divider(color: borderDark, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text('₱${_subtotal.toStringAsFixed(2)}', style: const TextStyle(color: accentRed, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _orderCart.isEmpty
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('POS Sale Recorded! Total: ₱${_subtotal.toStringAsFixed(2)}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      setState(() => _orderCart.clear());
                    },
              icon: const Icon(Icons.payment, size: 18),
              label: const Text('PROCESS PAYMENT & PRINT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentRed,
                disabledBackgroundColor: Colors.grey.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _staffOrders.length,
      itemBuilder: (context, index) {
        final order = _staffOrders[index];
        return Card(
          color: cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderDark)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order['id'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Chip(
                      label: Text(order['status']),
                      backgroundColor: order['status'] == 'Ready' ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                      labelStyle: TextStyle(color: order['status'] == 'Ready' ? Colors.greenAccent : Colors.orangeAccent, fontSize: 11),
                    ),
                  ],
                ),
                Text(order['customer'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text(order['items'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₱${(order['total'] as double).toStringAsFixed(2)}', style: const TextStyle(color: accentRed, fontWeight: FontWeight.bold, fontSize: 14)),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order status updated successfully!')));
                      },
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: accentRed)),
                      child: const Text('Update Status', style: TextStyle(color: accentRed, fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: accentRed,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text('Staff Cashier Member', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('cashier@smokindannys.com', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 24),
          Card(
            color: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderDark)),
            child: ListTile(
              leading: const Icon(Icons.access_time, color: accentRed),
              title: const Text('Shift Status', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Active Shift • Started at 8:00 AM', style: TextStyle(color: Colors.white54)),
              trailing: const Chip(label: Text('OPEN', style: TextStyle(color: Colors.greenAccent)), backgroundColor: Colors.green),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).adminSignOut();
              if (!mounted) return;
              context.go('/');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out Staff Session'),
            style: ElevatedButton.styleFrom(backgroundColor: accentRed, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
