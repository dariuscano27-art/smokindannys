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
  int _selectedTab = 0; // 0 = Overview, 1 = Orders, 2 = Inventory, 3 = Analytics

  static const Color accentRed = Color(0xFFED101E);
  static const Color darkBg = Color(0xFF0B0B0B);
  static const Color cardColor = Color(0xFF171717);
  static const Color borderDark = Color(0xFF282828);

  // Sample order data for demonstration & management
  final List<Map<String, dynamic>> _recentOrders = [
    {
      'id': '#SD-1048',
      'customer': 'Table 4 (Dine-In)',
      'items': 'Signature Smoked Ribs x2, Iced Tea x2',
      'total': 898.00,
      'time': '10 mins ago',
      'status': 'Completed',
      'statusColor': Colors.green,
    },
    {
      'id': '#SD-1047',
      'customer': 'Takeout - Maria Santos',
      'items': 'Classic Cheeseburger, Crispy Fries',
      'total': 389.00,
      'time': '18 mins ago',
      'status': 'Preparing',
      'statusColor': Colors.orange,
    },
    {
      'id': '#SD-1046',
      'customer': 'Table 2 (Dine-In)',
      'items': 'Margherita Pizza, Creamy Alfredo',
      'total': 648.00,
      'time': '25 mins ago',
      'status': 'Completed',
      'statusColor': Colors.green,
    },
    {
      'id': '#SD-1045',
      'customer': 'Delivery - GrabFood #883',
      'items': 'Crispy Chicken Tenders x3, BBQ Dip',
      'total': 777.00,
      'time': '32 mins ago',
      'status': 'Completed',
      'statusColor': Colors.green,
    },
    {
      'id': '#SD-1044',
      'customer': 'Table 8 (Dine-In)',
      'items': 'Smoked BBQ Pork Platter, Garlic Rice',
      'total': 1120.00,
      'time': '45 mins ago',
      'status': 'Completed',
      'statusColor': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Admin Navigation Header
            _buildAdminHeader(context, isDesktop),

            // Dashboard Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome & Quick Action Bar
                    _buildWelcomeBanner(context, isDesktop),

                    const SizedBox(height: 24),

                    // Metrics Grid (4 Key Metric Cards)
                    _buildMetricsGrid(isDesktop),

                    const SizedBox(height: 28),

                    // Navigation Tabs & Action Bar
                    _buildTabNavigation(),

                    const SizedBox(height: 20),

                    // Main Grid: Orders & Activity + Side Panel
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: _buildRecentOrdersCard(),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                _buildQuickActionsCard(context),
                                const SizedBox(height: 20),
                                _buildInventoryAlertsCard(),
                              ],
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _buildRecentOrdersCard(),
                      const SizedBox(height: 20),
                      _buildQuickActionsCard(context),
                      const SizedBox(height: 20),
                      _buildInventoryAlertsCard(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminHeader(BuildContext context, bool isDesktop) {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 16),
      decoration: const BoxDecoration(
        color: cardColor,
        border: Border(bottom: BorderSide(color: borderDark)),
      ),
      child: Row(
        children: [
          // Brand Logo & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accentRed.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: accentRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SMOKIN DANNYS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'ADMIN CONTROL CENTER',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // System Mode Badge
          if (isDesktop) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderDark),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'POS & Database Connected',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
          ],

          // Admin User Profile & Sign Out
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: accentRed,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 10),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Store Owner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'admin@smokindannys.com',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(width: 16),
              IconButton(
                tooltip: 'Sign Out Administrator',
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.logout, color: accentRed, size: 18),
                ),
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).adminSignOut();
                  if (context.mounted) {
                    context.go('/');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cardColor,
            const Color(0xFF221112),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDark),
      ),
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Welcome to Admin Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Monitor restaurant sales, manage POS orders, and track live inventory.',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
                _buildActionButtons(context),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Monitor sales, manage POS orders, and track live inventory.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(context),
              ],
            ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        ElevatedButton.icon(
          onPressed: () => context.go('/cashier/pos'),
          icon: const Icon(Icons.point_of_sale, size: 18),
          label: const Text('OPEN POS TERMINAL'),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go('/customer/home'),
          icon: const Icon(Icons.restaurant_menu, size: 18, color: Colors.white),
          label: const Text('VIEW CATALOG', style: TextStyle(color: Colors.white)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF444444)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(bool isDesktop) {
    final metrics = [
      {
        'title': 'TOTAL REVENUE (TODAY)',
        'value': '₱24,850.00',
        'subtitle': '+14.2% from yesterday',
        'icon': Icons.payments_outlined,
        'color': accentRed,
      },
      {
        'title': 'TOTAL ORDERS TODAY',
        'value': '42 Orders',
        'subtitle': '34 Dine-In • 8 Takeout',
        'icon': Icons.receipt_long_outlined,
        'color': Colors.amber,
      },
      {
        'title': 'ACTIVE POS STATIONS',
        'value': '2 Terminals',
        'subtitle': 'Terminal #1 & #2 Online',
        'icon': Icons.desktop_windows_outlined,
        'color': Colors.green,
      },
      {
        'title': 'TOP SELLING ITEM',
        'value': 'Smoked BBQ Ribs',
        'subtitle': '18 Portions Sold',
        'icon': Icons.local_fire_department_outlined,
        'color': Colors.orangeAccent,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : (MediaQuery.of(context).size.width >= 600 ? 2 : 1),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.5 : 2.2,
      ),
      itemBuilder: (context, index) {
        final item = metrics[index];
        final iconColor = item['color'] as Color;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item['icon'] as IconData, color: iconColor, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item['value'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item['subtitle'] as String,
                style: TextStyle(
                  color: iconColor == accentRed ? Colors.greenAccent : Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabNavigation() {
    final tabs = ['System Overview', 'Recent POS Orders', 'Stock Inventory', 'Sales Reports'];
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: borderDark)),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 24),
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? accentRed : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white38,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRecentOrdersCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt_long, color: accentRed, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Live POS Transactions & Orders',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exporting full transaction log...')),
                  );
                },
                child: const Text('View All Orders', style: TextStyle(color: accentRed)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('ORDER ID', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('CUSTOMER / TABLE', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 4, child: Text('ITEMS PURCHASED', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('AMOUNT', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('STATUS', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentOrders.length,
            separatorBuilder: (context, index) => const Divider(color: borderDark, height: 1),
            itemBuilder: (context, index) {
              final order = _recentOrders[index];
              final statusColor = order['statusColor'] as Color;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        order['id'],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        order['customer'],
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        order['items'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '₱${(order['total'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(color: accentRed, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withOpacity(0.4)),
                        ),
                        child: Text(
                          order['status'],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Management Actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _actionTile(
            icon: Icons.point_of_sale_rounded,
            title: 'Open Cashier POS',
            subtitle: 'Process customer sales & print receipts',
            onTap: () => context.go('/cashier/pos'),
          ),
          const SizedBox(height: 10),
          _actionTile(
            icon: Icons.menu_book_rounded,
            title: 'Catalog & Menu Items',
            subtitle: 'Browse & preview available menu items',
            onTap: () => context.go('/customer/home'),
          ),
          const SizedBox(height: 10),
          _actionTile(
            icon: Icons.analytics_outlined,
            title: 'Sales & Revenue Analytics',
            subtitle: 'Daily summary and report breakdown',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating daily sales report...')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accentRed, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryAlertsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'Inventory Stock Alerts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _stockRow('Smoked Pork Ribs', '12 portions remaining', Colors.amber),
          const Divider(color: borderDark, height: 16),
          _stockRow('Special BBQ Sauce', 'Low Stock (2 Bottles)', Colors.redAccent),
          const Divider(color: borderDark, height: 16),
          _stockRow('Chicken Wings', '45 portions available', Colors.green),
        ],
      ),
    );
  }

  Widget _stockRow(String item, String status, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          item,
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
