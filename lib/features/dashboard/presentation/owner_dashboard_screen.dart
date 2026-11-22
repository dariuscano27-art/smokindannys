import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../cart/presentation/shared_orders_provider.dart';
import '../../../core/theme/app_theme.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  int _selectedNavIndex = 0;

  static const Color accentRed = AppTheme.primaryMaroon;
  static const Color darkBg = AppTheme.background;
  static const Color cardColor = AppTheme.surface;
  static const Color borderDark = AppTheme.borderMaroon;

  final List<Map<String, dynamic>> _adminNavItems = [
    {'title': 'Dashboard Overview', 'icon': Icons.dashboard_outlined},
    {'title': 'Order Management', 'icon': Icons.receipt_long_outlined},
    {'title': 'Menu Management', 'icon': Icons.restaurant_menu_outlined},
    {'title': 'Inventory Management', 'icon': Icons.inventory_2_outlined},
    {'title': 'Staff Management', 'icon': Icons.badge_outlined},
    {'title': 'Staff Attendance', 'icon': Icons.access_time_rounded},
    {'title': 'Payment Management', 'icon': Icons.payments_outlined},
    {'title': 'Customer Management', 'icon': Icons.people_outline_rounded},
    {'title': 'Reports and Analytics', 'icon': Icons.bar_chart_rounded},
  ];

  final List<Map<String, dynamic>> _inventoryStock = [
    {'item': 'Baby Back Ribs', 'stock': '45 kg', 'status': 'In Stock', 'color': Colors.green},
    {'item': 'Chicken Breast', 'stock': '30 kg', 'status': 'In Stock', 'color': Colors.green},
    {'item': 'Cheddar Cheese', 'stock': '12 kg', 'status': 'Low Stock', 'color': Colors.orange},
    {'item': 'Potato Fries', 'stock': '60 kg', 'status': 'In Stock', 'color': Colors.green},
    {'item': 'BBQ Sauce Gallons', 'stock': '8 units', 'status': 'In Stock', 'color': Colors.green},
  ];

  final List<Map<String, dynamic>> _staffList = [
    {'name': 'Chef Danny Smokes', 'role': 'Head Chef / Owner', 'status': 'Active On Duty'},
    {'name': 'Maria Santos', 'role': 'Cashier POS #1', 'status': 'Active On Duty'},
    {'name': 'Juan Dela Cruz', 'role': 'Kitchen Grill Master', 'status': 'Active On Duty'},
    {'name': 'Ana Reyes', 'role': 'Server / Floor Staff', 'status': 'Off Duty'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  _buildAdminSidebar(),
                  Container(width: 1, color: borderDark),
                  Expanded(
                    child: Column(
                      children: [
                        _buildAdminHeader(context, isDesktop: true),
                        Expanded(child: _buildSelectedModuleView()),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildAdminHeader(context, isDesktop: false),
                  _buildMobileNavDropdown(),
                  Expanded(child: _buildSelectedModuleView()),
                ],
              ),
      ),
    );
  }

  Widget _buildAdminSidebar() {
    return Container(
      width: 270,
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.softMaroon,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.champagneGold, width: 1.2),
                  ),
                  child: const Icon(Icons.local_fire_department_rounded, color: accentRed, size: 24),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SMOKIN DANNYS', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
                    Text('ENTERPRISE POS', style: TextStyle(color: AppTheme.champagneGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: borderDark),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              itemCount: _adminNavItems.length,
              itemBuilder: (context, index) {
                final item = _adminNavItems[index];
                final isSelected = _selectedNavIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedNavIndex = index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryMaroon : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(item['icon'] as IconData, color: isSelected ? Colors.white : AppTheme.mutedText, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.darkText,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavDropdown() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: cardColor,
      child: Row(
        children: [
          const Icon(Icons.menu, color: accentRed),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedNavIndex,
                dropdownColor: cardColor,
                style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 13),
                items: List.generate(_adminNavItems.length, (index) {
                  return DropdownMenuItem(
                    value: index,
                    child: Text(_adminNavItems[index]['title'] as String),
                  );
                }),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedNavIndex = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeader(BuildContext context, {required bool isDesktop}) {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
      decoration: const BoxDecoration(
        color: cardColor,
        border: Border(bottom: BorderSide(color: borderDark)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                _adminNavItems[_selectedNavIndex]['title'] as String,
                style: const TextStyle(color: AppTheme.darkText, fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.green),
                    SizedBox(width: 6),
                    Text('SYSTEM ONLINE', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => context.go('/cashier/pos'),
            icon: const Icon(Icons.point_of_sale, size: 16),
            label: const Text('OPEN POS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout, color: accentRed),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).adminSignOut();
              if (!context.mounted) return;
              context.go('/');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedModuleView() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildOverviewModule();
      case 1:
        return _buildOrderManagementModule();
      case 2:
        return _buildMenuManagementModule();
      case 3:
        return _buildInventoryModule();
      case 4:
        return _buildStaffModule();
      case 5:
        return _buildAttendanceModule();
      case 6:
        return _buildPaymentModule();
      case 7:
        return _buildCustomerModule();
      case 8:
        return _buildReportsModule();
      default:
        return _buildOverviewModule();
    }
  }

  // 0. Overview
  Widget _buildOverviewModule() {
    final liveOrders = ref.watch(sharedOrdersProvider);
    final totalRevenue = liveOrders.fold(0.0, (sum, o) => sum + (o['total'] as double));
    final totalOrdersCount = liveOrders.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dashboard Overview', style: TextStyle(color: AppTheme.darkText, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Welcome back, Admin. Real-time telemetry and customer online orders synced.', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
          const SizedBox(height: 24),
          _buildMetricsGrid(totalRevenue, totalOrdersCount),
          const SizedBox(height: 32),
          const Text('Recent Live Customer Orders', style: TextStyle(color: AppTheme.darkText, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderDark),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A800020),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: liveOrders.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No live orders yet.', style: TextStyle(color: AppTheme.mutedText)),
                  )
                : Column(
                    children: liveOrders.take(5).map((order) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(order['id'], style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(order['customer'], style: const TextStyle(color: AppTheme.darkText, fontSize: 12, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(order['items'], style: const TextStyle(color: AppTheme.mutedText, fontSize: 11)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₱${(order['total'] as double).toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 14)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (order['status'] == 'Completed' ? Colors.green : Colors.orange).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: (order['status'] == 'Completed' ? Colors.green : Colors.orange).withValues(alpha: 0.3)),
                                    ),
                                    child: Text(order['status'], style: TextStyle(color: order['status'] == 'Completed' ? Colors.green : Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(double totalRevenue, int totalOrdersCount) {
    final metrics = [
      {'title': 'TOTAL REVENUE', 'value': '₱${totalRevenue.toStringAsFixed(2)}', 'sub': 'Live real-time calculation', 'icon': Icons.payments_outlined, 'color': accentRed},
      {'title': 'TOTAL ORDERS', 'value': '$totalOrdersCount Orders', 'sub': 'Customer online orders synced', 'icon': Icons.receipt_long_outlined, 'color': Colors.amber.shade800},
      {'title': 'ACTIVE POS', 'value': '2 Terminals', 'sub': 'Terminal #1 & #2 Online', 'icon': Icons.desktop_windows_outlined, 'color': Colors.green.shade700},
      {'title': 'BEST SELLER', 'value': 'Smoked Ribs', 'sub': '18 Portions Sold', 'icon': Icons.local_fire_department_outlined, 'color': AppTheme.champagneGold},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.9,
      ),
      itemBuilder: (context, index) {
        final m = metrics[index];
        final col = m['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderDark),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A800020),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(m['title'] as String, style: const TextStyle(color: AppTheme.mutedText, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: col.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(m['icon'] as IconData, color: col, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(m['value'] as String, style: const TextStyle(color: AppTheme.darkText, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(m['sub'] as String, style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  // 1. Order Management
  Widget _buildOrderManagementModule() {
    final liveOrders = ref.watch(sharedOrdersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Active Orders & Kitchen Queue', style: TextStyle(color: AppTheme.darkText, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Manage, update status, and track active customer pickup and dine-in orders in real time.', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderDark)),
            child: liveOrders.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: Text('No active orders in queue.', style: TextStyle(color: AppTheme.mutedText))),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: liveOrders.length,
                    separatorBuilder: (context, index) => const Divider(color: borderDark, height: 1),
                    itemBuilder: (context, index) {
                      final order = liveOrders[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        title: Text('${order['id']} - ${order['customer']}', style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${order['items']}\nPhone: ${order['phone']}', style: const TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('₱${(order['total'] as double).toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 14)),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                final nextStatus = order['status'] == 'Preparing'
                                    ? 'Ready'
                                    : order['status'] == 'Ready'
                                        ? 'Completed'
                                        : 'Preparing';
                                ref.read(sharedOrdersProvider.notifier).updateStatus(order['id'], nextStatus);
                                AppToast.show(context, message: 'Updated ${order['id']} to $nextStatus!');
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryMaroon, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
                              child: Text(order['status'], style: const TextStyle(fontSize: 11)),
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

  // 2. Menu Management
  Widget _buildMenuManagementModule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Menu Items & Pricing', style: TextStyle(color: AppTheme.darkText, fontSize: 18, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text('Active restaurant menu catalog (16 items synced).', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => AppToast.show(context, message: 'Add Menu Item feature active.'),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Menu Item'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryMaroon),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderDark)),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.restaurant, color: AppTheme.primaryMaroon),
                  title: Text('The Ultimate Rib', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold)),
                  subtitle: Text('Category: BBQ & Grills • Status: Available'),
                  trailing: Text('₱599.00', style: TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900)),
                ),
                Divider(color: borderDark),
                ListTile(
                  leading: Icon(Icons.restaurant, color: AppTheme.primaryMaroon),
                  title: Text('Trio Baby Back Ribs', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold)),
                  subtitle: Text('Category: BBQ & Grills • Status: Available'),
                  trailing: Text('₱899.00', style: TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900)),
                ),
                Divider(color: borderDark),
                ListTile(
                  leading: Icon(Icons.restaurant, color: AppTheme.primaryMaroon),
                  title: Text('Ultimate BBQ Platter', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold)),
                  subtitle: Text('Category: BBQ & Grills • Status: Available'),
                  trailing: Text('₱1,199.00', style: TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Inventory Management
  Widget _buildInventoryModule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Inventory Stock Levels', style: TextStyle(color: AppTheme.darkText, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Monitor meat supplies, ingredients, and kitchen stock status.', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderDark)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _inventoryStock.length,
              separatorBuilder: (context, index) => const Divider(color: borderDark, height: 1),
              itemBuilder: (context, index) {
                final inv = _inventoryStock[index];
                final col = inv['color'] as Color;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  title: Text(inv['item'], style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('Stock Level: ${inv['stock']}', style: const TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: col.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text(inv['status'], style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => AppToast.show(context, message: 'Restocked ${inv['item']} successfully!'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primaryMaroon, side: const BorderSide(color: AppTheme.primaryMaroon)),
                        child: const Text('Restock', style: TextStyle(fontSize: 11)),
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

  // 4. Staff Management
  Widget _buildStaffModule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Staff Accounts & Roles', style: TextStyle(color: AppTheme.darkText, fontSize: 18, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text('Manage cashier POS accounts and kitchen staff.', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => AppToast.show(context, message: 'Add Staff Member active.'),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Add Staff'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryMaroon),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderDark)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _staffList.length,
              separatorBuilder: (context, index) => const Divider(color: borderDark, height: 1),
              itemBuilder: (context, index) {
                final s = _staffList[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  leading: const CircleAvatar(backgroundColor: AppTheme.softMaroon, child: Icon(Icons.person, color: AppTheme.primaryMaroon)),
                  title: Text(s['name'], style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(s['role'], style: const TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                  trailing: Text(s['status'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 5. Attendance
  Widget _buildAttendanceModule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Staff Attendance & Time Logs', style: TextStyle(color: AppTheme.darkText, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Track daily clock-in and shift hours for payroll.', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderDark)),
            child: const Column(
              children: [
                ListTile(title: Text('Chef Danny Smokes', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkText)), subtitle: Text('Clocked in at 08:00 AM'), trailing: Text('8 hrs logged', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                Divider(color: borderDark),
                ListTile(title: Text('Maria Santos (Cashier)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkText)), subtitle: Text('Clocked in at 09:30 AM'), trailing: Text('6.5 hrs logged', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. Payment Management
  Widget _buildPaymentModule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Management & Cash Drawer', style: TextStyle(color: AppTheme.darkText, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Verify GCash transactions and daily cash register reconciliation.', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderDark)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Cash Drawer: ₱14,250.00', style: TextStyle(color: AppTheme.darkText, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text('Total GCash Verified: ₱10,600.00', style: TextStyle(color: AppTheme.darkText, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                Divider(color: borderDark),
                SizedBox(height: 16),
                Text('Status: Cash Drawer Balanced 🟢', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 7. Customer Management
  Widget _buildCustomerModule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Registered Customers & VIPs', style: TextStyle(color: AppTheme.darkText, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Customer accounts database and order history.', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderDark)),
            child: const Column(
              children: [
                ListTile(leading: CircleAvatar(child: Text('DJ')), title: Text('David Cruz Johnson', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('customer@smokindannys.com • 12 Orders'), trailing: Text('VIP Member 🌟', style: TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.bold))),
                Divider(color: borderDark),
                ListTile(leading: CircleAvatar(child: Text('MS')), title: Text('Maria Santos', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('maria@example.com • 5 Orders'), trailing: Text('Regular', style: TextStyle(color: AppTheme.mutedText))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 8. Reports and Analytics
  Widget _buildReportsModule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sales Reports & Analytics', style: TextStyle(color: AppTheme.darkText, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Download financial reports, tax summaries, and daily analytics.', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton.icon(onPressed: () => AppToast.show(context, message: 'Exported PDF Sales Report!'), icon: const Icon(Icons.picture_as_pdf), label: const Text('Export PDF Report'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryMaroon)),
              const SizedBox(width: 16),
              OutlinedButton.icon(onPressed: () => AppToast.show(context, message: 'Exported CSV Data!'), icon: const Icon(Icons.table_chart), label: const Text('Export CSV Data'), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primaryMaroon, side: const BorderSide(color: AppTheme.primaryMaroon))),
            ],
          ),
        ],
      ),
    );
  }
}
