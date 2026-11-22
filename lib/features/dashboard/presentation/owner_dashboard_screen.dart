import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class OwnerDashboardScreen extends ConsumerStatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  ConsumerState<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends ConsumerState<OwnerDashboardScreen> {
  int _selectedNavIndex = 0; // 0 to 10 for the 11 Admin Navigation items

  static const Color accentRed = AppTheme.primaryMaroon;
  static const Color darkBg = AppTheme.background;
  static const Color cardColor = AppTheme.surface;
  static const Color borderDark = AppTheme.borderMaroon;

  // Final 11 Admin Navigation Items
  final List<Map<String, dynamic>> _adminNavItems = [
    {'title': 'Dashboard Overview', 'icon': Icons.dashboard_rounded},
    {'title': 'Order Management', 'icon': Icons.receipt_long_rounded},
    {'title': 'Menu Management', 'icon': Icons.restaurant_menu_rounded},
    {'title': 'Inventory Management', 'icon': Icons.inventory_2_rounded},
    {'title': 'Staff Management', 'icon': Icons.badge_rounded},
    {'title': 'Staff Attendance', 'icon': Icons.access_time_filled_rounded},
    {'title': 'Payment Management', 'icon': Icons.payments_rounded},
    {'title': 'Customer Management', 'icon': Icons.people_rounded},
    {'title': 'Reports and Analytics', 'icon': Icons.bar_chart_rounded},
    {'title': 'Activity Logs', 'icon': Icons.history_rounded},
    {'title': 'System Settings', 'icon': Icons.settings_rounded},
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
                  // Left Sidebar Navigation with 11 Items
                  _buildAdminSidebar(),
                  Container(width: 1, color: borderDark),
                  // Main Content View
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
      width: 260,
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_fire_department_rounded, color: accentRed, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SMOKIN DANNYS', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w900, fontSize: 15)),
                    Text('ADMIN CONTROL', style: TextStyle(color: AppTheme.mutedText, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: borderDark),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _adminNavItems.length,
              itemBuilder: (context, index) {
                final item = _adminNavItems[index];
                final isSelected = _selectedNavIndex == index;
                return InkWell(
                  onTap: () => setState(() => _selectedNavIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.softMaroon : Colors.transparent,
                      border: Border(left: BorderSide(color: isSelected ? accentRed : Colors.transparent, width: 4)),
                    ),
                    child: Row(
                      children: [
                        Icon(item['icon'] as IconData, color: isSelected ? accentRed : AppTheme.mutedText, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item['title'] as String,
                            style: TextStyle(
                              color: isSelected ? accentRed : AppTheme.darkText,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              fontSize: 13,
                            ),
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
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 16),
      decoration: const BoxDecoration(
        color: cardColor,
        border: Border(bottom: BorderSide(color: borderDark)),
      ),
      child: Row(
        children: [
          Text(
            _adminNavItems[_selectedNavIndex]['title'] as String,
            style: const TextStyle(color: AppTheme.darkText, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => context.go('/cashier/pos'),
            icon: const Icon(Icons.point_of_sale, size: 16),
            label: const Text('OPEN POS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        return _buildGenericModule('Order Management', 'Manage active dining and takeout orders.');
      case 2:
        return _buildGenericModule('Menu Management', 'Add, edit, or disable restaurant food products and prices.');
      case 3:
        return _buildGenericModule('Inventory Management', 'Monitor ingredients, stock levels, and low-stock alerts.');
      case 4:
        return _buildGenericModule('Staff Management', 'Manage staff accounts, roles, and pins.');
      case 5:
        return _buildGenericModule('Staff Attendance', 'Track clock-in, clock-out, and shift hours.');
      case 6:
        return _buildGenericModule('Payment Management', 'Verify GCash transactions and cash drawer sessions.');
      case 7:
        return _buildGenericModule('Customer Management', 'View registered customers and saved addresses.');
      case 8:
        return _buildGenericModule('Reports and Analytics', 'Export sales reports to PDF and CSV.');
      case 9:
        return _buildGenericModule('Activity Logs', 'Audit trail of secure administrative operations.');
      case 10:
        return _buildGenericModule('System Settings', 'Configure tax percentage, service charge, and operating hours.');
      default:
        return _buildOverviewModule();
    }
  }

  // 0. Overview Module
  Widget _buildOverviewModule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dashboard Overview', style: TextStyle(color: AppTheme.darkText, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Welcome back, Admin. Here is the restaurant performance summary today.', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
          const SizedBox(height: 24),
          _buildMetricsGrid(),
          const SizedBox(height: 28),
          const Text('Recent Live Orders', style: TextStyle(color: AppTheme.darkText, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderDark),
            ),
            child: Column(
              children: [
                _orderRow('#SD-1048', 'Table 4 (Dine-In)', 'Signature Smoked Ribs x2', '₱898.00', Colors.green, 'Completed'),
                const Divider(color: borderDark, height: 20),
                _orderRow('#SD-1047', 'Takeout - Maria', 'Classic Cheeseburger', '₱389.00', Colors.orange, 'Preparing'),
                const Divider(color: borderDark, height: 20),
                _orderRow('#SD-1046', 'Table 2 (Dine-In)', 'Margherita Pizza', '₱648.00', Colors.green, 'Completed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = [
      {'title': 'TOTAL REVENUE', 'value': '₱24,850.00', 'sub': '+14.2% today', 'icon': Icons.payments_outlined, 'color': accentRed},
      {'title': 'TOTAL ORDERS', 'value': '42 Orders', 'sub': '34 Dine-In • 8 Takeout', 'icon': Icons.receipt_long_outlined, 'color': Colors.amber.shade800},
      {'title': 'ACTIVE POS', 'value': '2 Terminals', 'sub': 'Terminal #1 & #2 Online', 'icon': Icons.desktop_windows_outlined, 'color': Colors.green.shade700},
      {'title': 'BEST SELLER', 'value': 'Smoked Ribs', 'sub': '18 Portions Sold', 'icon': Icons.local_fire_department_outlined, 'color': Colors.orange},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      itemBuilder: (context, index) {
        final m = metrics[index];
        final col = m['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(m['title'] as String, style: const TextStyle(color: AppTheme.mutedText, fontSize: 11, fontWeight: FontWeight.bold)),
                  Icon(m['icon'] as IconData, color: col, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(m['value'] as String, style: const TextStyle(color: AppTheme.darkText, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(m['sub'] as String, style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  Widget _orderRow(String id, String customer, String items, String amount, Color statusColor, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(id, style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(customer, style: const TextStyle(color: AppTheme.darkText, fontSize: 12, fontWeight: FontWeight.w600)),
            Text(items, style: const TextStyle(color: AppTheme.mutedText, fontSize: 11)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 13)),
            const SizedBox(height: 4),
            Chip(
              label: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              backgroundColor: statusColor.withValues(alpha: 0.15),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenericModule(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.darkText, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: AppTheme.mutedText, fontSize: 14)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderDark),
            ),
            child: Row(
              children: [
                const Icon(Icons.construction_rounded, color: AppTheme.primaryMaroon, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$title Module Active', style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      const Text('Manage records, view logs, and configure operational rules securely via Supabase backend.', style: TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
