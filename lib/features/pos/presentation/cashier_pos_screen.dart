import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../cart/presentation/shared_orders_provider.dart';
import '../../../core/theme/app_theme.dart';

class CashierPosScreen extends ConsumerStatefulWidget {
  const CashierPosScreen({super.key});

  @override
  ConsumerState<CashierPosScreen> createState() => _CashierPosScreenState();
}

class _CashierPosScreenState extends ConsumerState<CashierPosScreen> {
  static const Color darkBg = AppTheme.background;
  static const Color cardColor = AppTheme.surface;
  static const Color borderDark = AppTheme.borderMaroon;

  int _selectedSidebarIndex = 0; // 0 = Menu, 1 = Receipt, 2 = History, 3 = Payment, 4 = Online Orders
  String _selectedCategory = 'All';

  // POS Cart State
  final List<Map<String, dynamic>> _orderCart = [];
  double _cashReceived = 0.0;

  // Exact 16 Menu Items with Photo Assets for Staff POS
  final List<Map<String, dynamic>> _menuItems = [
    {
      'id': '1',
      'name': 'The Ultimate Rib',
      'price': 599.00,
      'category': 'BBQ & Grills',
      'image_url': 'Menu_Food_Photos/01_The_Ultimate_Rib.jpg',
    },
    {
      'id': '2',
      'name': 'Trio Baby Back Ribs',
      'price': 899.00,
      'category': 'BBQ & Grills',
      'image_url': 'Menu_Food_Photos/02_Trio_Baby_Back_Ribs.jpg',
    },
    {
      'id': '3',
      'name': 'Ultimate BBQ Platter',
      'price': 1199.00,
      'category': 'BBQ & Grills',
      'image_url': 'Menu_Food_Photos/03_Ultimate_BBQ_Platter.jpg',
    },
    {
      'id': '4',
      'name': 'Italian Grilled Chicken',
      'price': 349.00,
      'category': 'Chicken',
      'image_url': 'Menu_Food_Photos/04_Italian_Grilled_Chicken.jpg',
    },
    {
      'id': '5',
      'name': 'Chicken Barbecue',
      'price': 269.00,
      'category': 'Chicken',
      'image_url': 'Menu_Food_Photos/05_Chicken_Barbecue_with_Java_Rice_and_Atchara.jpg',
    },
    {
      'id': '6',
      'name': 'Pizza & Pasta Sisig',
      'price': 399.00,
      'category': 'Pizza',
      'image_url': 'Menu_Food_Photos/06_Pizza_and_Pasta_Sisig.jpg',
    },
    {
      'id': '7',
      'name': 'Pizza Canton',
      'price': 249.00,
      'category': 'Pasta',
      'image_url': 'Menu_Food_Photos/07_Pizza_Canton.jpg',
    },
    {
      'id': '8',
      'name': 'Sisig Tuna Pasta',
      'price': 289.00,
      'category': 'Pasta',
      'image_url': 'Menu_Food_Photos/08_Sisig_Tuna_Pasta.jpg',
    },
    {
      'id': '9',
      'name': 'Buffalo Wings',
      'price': 259.00,
      'category': 'Chicken',
      'image_url': 'Menu_Food_Photos/09_Buffalo_Wings.jpg',
    },
    {
      'id': '10',
      'name': 'Garlic Parmesan Wings',
      'price': 269.00,
      'category': 'Chicken',
      'image_url': 'Menu_Food_Photos/10_Garlic_Parmesan_Wings.jpg',
    },
    {
      'id': '11',
      'name': 'Chili Con Nachos',
      'price': 229.00,
      'category': 'Sides',
      'image_url': 'Menu_Food_Photos/11_Chili_Con_Nachos.jpg',
    },
    {
      'id': '12',
      'name': 'Crispy Fries',
      'price': 129.00,
      'category': 'Sides',
      'image_url': 'Menu_Food_Photos/12_Crispy_Fries.jpg',
    },
    {
      'id': '13',
      'name': 'Tapa Silog',
      'price': 199.00,
      'category': 'All-Day Breakfast',
      'image_url': 'Menu_Food_Photos/13_Tapa_Silog.jpg',
    },
    {
      'id': '14',
      'name': 'Tocilog',
      'price': 189.00,
      'category': 'All-Day Breakfast',
      'image_url': 'Menu_Food_Photos/14_Tocilog.jpg',
    },
    {
      'id': '15',
      'name': 'Spam & Eggs Skillet',
      'price': 219.00,
      'category': 'All-Day Breakfast',
      'image_url': 'Menu_Food_Photos/15_Spam_and_Eggs_Skillet.jpg',
    },
    {
      'id': '16',
      'name': 'Suman Sundae',
      'price': 149.00,
      'category': 'Desserts',
      'image_url': 'Menu_Food_Photos/16_Suman_Sundae.jpg',
    },
  ];

  // Mock Transaction History
  final List<Map<String, dynamic>> _historyTransactions = [
    {'id': '#POS-1092', 'time': '10:45 AM', 'type': 'Walk-In POS', 'items': 'Ultimate BBQ Platter x1', 'total': 1199.00, 'payment': 'Cash (Change: ₱301.00)', 'status': 'Completed'},
    {'id': '#POS-1091', 'time': '09:30 AM', 'type': 'Walk-In POS', 'items': 'Buffalo Wings x2, Fries x1', 'total': 647.00, 'payment': 'GCash (Verified)', 'status': 'Completed'},
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${item['name']} to cart'), duration: const Duration(milliseconds: 600)),
    );
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
  double get _tax => _subtotal * 0.12;
  double get _total => _subtotal + _tax;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryMaroon,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.point_of_sale_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'STAFF POS & MANAGEMENT PORTAL',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.8),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out Staff',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).adminSignOut();
              if (!context.mounted) return;
              context.go('/');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  // Left Sidebar Navigation
                  _buildSidebar(isWide: true),
                  Container(width: 1, color: borderDark),
                  // Main Content Area
                  Expanded(child: _buildMainContent()),
                ],
              )
            : Column(
                children: [
                  _buildSidebar(isWide: false),
                  Expanded(child: _buildMainContent()),
                ],
              ),
      ),
    );
  }

  Widget _buildSidebar({required bool isWide}) {
    final buttons = [
      {'icon': Icons.restaurant_menu_rounded, 'title': 'Menu'},
      {'icon': Icons.receipt_long_rounded, 'title': 'Receipt'},
      {'icon': Icons.history_rounded, 'title': 'History'},
      {'icon': Icons.payment_rounded, 'title': 'Payment'},
      {'icon': Icons.task_alt_rounded, 'title': 'Online Orders'},
    ];

    if (isWide) {
      return Container(
        width: 240,
        color: cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('STAFF DASHBOARD', style: TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text('Cashier Active', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
            ),
            const Divider(height: 1, color: borderDark),
            Expanded(
              child: ListView.builder(
                itemCount: buttons.length,
                itemBuilder: (context, index) {
                  final btn = buttons[index];
                  final isSelected = _selectedSidebarIndex == index;
                  return InkWell(
                    onTap: () => setState(() => _selectedSidebarIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.softMaroon : Colors.transparent,
                        border: Border(left: BorderSide(color: isSelected ? AppTheme.primaryMaroon : Colors.transparent, width: 4)),
                      ),
                      child: Row(
                        children: [
                          Icon(btn['icon'] as IconData, color: isSelected ? AppTheme.primaryMaroon : AppTheme.mutedText, size: 20),
                          const SizedBox(width: 14),
                          Text(
                            btn['title'] as String,
                            style: TextStyle(
                              color: isSelected ? AppTheme.primaryMaroon : AppTheme.darkText,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 60,
        color: cardColor,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: buttons.length,
          itemBuilder: (context, index) {
            final btn = buttons[index];
            final isSelected = _selectedSidebarIndex == index;
            return InkWell(
              onTap: () => setState(() => _selectedSidebarIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.softMaroon : Colors.transparent,
                  border: Border(bottom: BorderSide(color: isSelected ? AppTheme.primaryMaroon : Colors.transparent, width: 3)),
                ),
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Icon(btn['icon'] as IconData, color: isSelected ? AppTheme.primaryMaroon : AppTheme.mutedText, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      btn['title'] as String,
                      style: TextStyle(
                        color: isSelected ? AppTheme.primaryMaroon : AppTheme.darkText,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildMainContent() {
    switch (_selectedSidebarIndex) {
      case 0:
        return _buildMenuModule();
      case 1:
        return _buildReceiptModule();
      case 2:
        return _buildHistoryModule();
      case 3:
        return _buildPaymentModule();
      case 4:
        return _buildOnlineOrdersModule();
      default:
        return _buildMenuModule();
    }
  }

  // 0. MENU MODULE WITH FOOD PHOTOS
  Widget _buildMenuModule() {
    final filtered = _selectedCategory == 'All'
        ? _menuItems
        : _menuItems.where((i) => i['category'] == _selectedCategory).toList();
    final categories = ['All', 'BBQ & Grills', 'Chicken', 'Pizza', 'Pasta', 'Sides', 'All-Day Breakfast', 'Desserts'];

    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 55,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppTheme.surface,
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
                        selectedColor: AppTheme.primaryMaroon,
                        backgroundColor: AppTheme.background,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.darkText,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final imageUrl = item['image_url'] as String?;
                    return InkWell(
                      onTap: () => _addToCart(item),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderMaroon),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.softMaroon,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: imageUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(imageUrl, fit: BoxFit.cover, width: double.infinity),
                                      )
                                    : const Icon(Icons.fastfood_rounded, size: 36, color: AppTheme.primaryMaroon),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['name'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₱${(item['price'] as double).toStringAsFixed(2)}',
                              style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Container(width: 1, color: AppTheme.borderMaroon),
        Expanded(
          flex: 4,
          child: Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current POS Cart', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 12),
                Expanded(
                  child: _orderCart.isEmpty
                      ? const Center(child: Text('Cart is empty. Tap menu items.', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)))
                      : ListView.separated(
                          itemCount: _orderCart.length,
                          separatorBuilder: (context, index) => const Divider(color: AppTheme.borderMaroon),
                          itemBuilder: (context, index) {
                            final item = _orderCart[index];
                            final itemTotal = item['price'] * item['qty'];
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['name'], style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text('₱${(item['price'] as double).toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.mutedText, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: AppTheme.mutedText, size: 18),
                                      onPressed: () => _updateQty(index, -1),
                                    ),
                                    Text('${item['qty']}', style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryMaroon, size: 18),
                                      onPressed: () => _updateQty(index, 1),
                                    ),
                                  ],
                                ),
                                Text('₱${itemTotal.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            );
                          },
                        ),
                ),
                const Divider(color: AppTheme.borderMaroon),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL:', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('₱${_total.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _orderCart.isEmpty
                        ? null
                        : () {
                            setState(() {
                              _historyTransactions.insert(0, {
                                'id': '#POS-${1093 + _historyTransactions.length}',
                                'time': 'Just now',
                                'type': 'Walk-In POS',
                                'items': _orderCart.map((e) => '${e['name']} x${e['qty']}').join(', '),
                                'total': _total,
                                'payment': 'Cash (Paid)',
                                'status': 'Completed',
                              });
                              _orderCart.clear();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('POS Transaction successfully completed & recorded!'), backgroundColor: Colors.green),
                            );
                            setState(() => _selectedSidebarIndex = 1); // Jump to Receipt
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryMaroon,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('CHECKOUT & PRINT RECEIPT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 1. RECEIPT MODULE
  Widget _buildReceiptModule() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(28),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderMaroon, width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x1A800000), blurRadius: 20, offset: Offset(0, 6))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.outdoor_grill_rounded, color: AppTheme.primaryMaroon, size: 40),
            const SizedBox(height: 8),
            const Text('SMOKIN DANNYS BBQ & GRILL', style: TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 16)),
            const Text('Metro Manila, Philippines • Tel: 917-1234', style: TextStyle(color: AppTheme.mutedText, fontSize: 11)),
            const Divider(height: 24, color: AppTheme.borderMaroon),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Receipt #: RCP-9021', style: TextStyle(color: AppTheme.darkText, fontSize: 12, fontWeight: FontWeight.bold)),
                Text('Date: Today', style: TextStyle(color: AppTheme.mutedText, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Item Description', style: TextStyle(color: AppTheme.darkText, fontSize: 12, fontWeight: FontWeight.bold)),
                Text('Amount', style: TextStyle(color: AppTheme.darkText, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 16, color: AppTheme.borderMaroon),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1x The Ultimate Rib', style: TextStyle(color: AppTheme.darkText, fontSize: 12)),
                Text('₱599.00', style: TextStyle(color: AppTheme.darkText, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1x Crispy Fries', style: TextStyle(color: AppTheme.darkText, fontSize: 12)),
                Text('₱129.00', style: TextStyle(color: AppTheme.darkText, fontSize: 12)),
              ],
            ),
            const Divider(height: 24, color: AppTheme.borderMaroon),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:', style: TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                Text('₱728.00', style: TextStyle(color: AppTheme.darkText, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('VAT (12%):', style: TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                Text('₱87.36', style: TextStyle(color: AppTheme.darkText, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL:', style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 15, fontWeight: FontWeight.w900)),
                Text('₱815.36', style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 16, fontWeight: FontWeight.w900)),
              ],
            ),
            const Divider(height: 24, color: AppTheme.borderMaroon),
            const Text('Thank you for dining at Smokin Dannys!', style: TextStyle(color: AppTheme.mutedText, fontSize: 11, fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thermal receipt sent to Bluetooth/USB Printer!')));
                },
                icon: const Icon(Icons.print, size: 16),
                label: const Text('PRINT THERMAL RECEIPT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryMaroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. HISTORY MODULE
  Widget _buildHistoryModule() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('POS Transaction History', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: _historyTransactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = _historyTransactions[index];
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderMaroon),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx['id'] as String, style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(tx['items'] as String, style: const TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('${tx['type']} • ${tx['time']} • ${tx['payment']}', style: const TextStyle(color: AppTheme.mutedText, fontSize: 11)),
                        ],
                      ),
                      Text(
                        '₱${(tx['total'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 3. PAYMENT MODULE
  Widget _buildPaymentModule() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderMaroon),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Cashier Payment Collection', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w900, fontSize: 18)),
              const SizedBox(height: 6),
              const Text('Enter cash received or verify GCash reference.', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
              const SizedBox(height: 20),
              const Text('Total Amount Due:', style: TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('₱815.36', style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              const Text('Cash Received (₱)', style: TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.darkText, fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '1000.00',
                  hintStyle: const TextStyle(color: AppTheme.mutedText),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.borderMaroon)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.borderMaroon)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 2)),
                ),
                onChanged: (val) {
                  setState(() {
                    _cashReceived = double.tryParse(val) ?? 0.0;
                  });
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.softMaroon, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Computed Change:', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      '₱${(_cashReceived >= 815.36 ? _cashReceived - 815.36 : 0.0).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _cashReceived < 815.36
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Payment verified & recorded successfully!'), backgroundColor: Colors.green),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('VALIDATE & FINISH PAYMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. ONLINE ORDERS MODULE (CONFIRMATION) WATCHING SHARED ORDERS
  Widget _buildOnlineOrdersModule() {
    final liveOrders = ref.watch(sharedOrdersProvider);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Confirmation of Online Orders (Synced from Customer Cart)', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 4),
          const Text('Accept or update customer orders placed via web portal in real-time.', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
          const SizedBox(height: 16),
          Expanded(
            child: liveOrders.isEmpty
                ? const Center(child: Text('No online customer orders yet.', style: TextStyle(color: AppTheme.mutedText)))
                : ListView.separated(
                    itemCount: liveOrders.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = liveOrders[index];
                      final orderId = order['id'] as String;
                      final status = order['status'] as String;
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderMaroon),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(orderId, style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 16)),
                                Chip(
                                  label: Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  backgroundColor: AppTheme.softMaroon,
                                  labelStyle: const TextStyle(color: AppTheme.primaryMaroon),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Customer / Ref: ${order['customer']}', style: const TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.bold)),
                            Text('Items: ${order['items']}', style: const TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('₱${(order['total'] as double).toStringAsFixed(2)} (${order['type']})', style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 14)),
                                Row(
                                  children: [
                                    OutlinedButton(
                                      onPressed: () {
                                        ref.read(sharedOrdersProvider.notifier).updateStatus(orderId, 'Cancelled');
                                      },
                                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                      child: const Text('Reject', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        ref.read(sharedOrdersProvider.notifier).updateStatus(orderId, 'Preparing');
                                      },
                                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryMaroon, foregroundColor: Colors.white),
                                      child: const Text('Accept & Prepare', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
