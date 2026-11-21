import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/auth_provider.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkAuthAndProceed(VoidCallback onAuthenticated) {
    final authRepo = ref.read(authRepositoryProvider);
    final user = authRepo.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in first to continue to cart & ordering.'),
          backgroundColor: AppTheme.primaryMaroon,
          action: SnackBarAction(
            label: 'Sign In',
            textColor: Colors.white,
            onPressed: () => context.push('/login'),
          ),
        ),
      );
      context.push('/login');
    } else {
      onAuthenticated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 950;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildWebHeader(context, isDesktop),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 36.0 : 16.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isDesktop ? _buildDesktopHero(context) : _buildMobileHero(context),
                    const SizedBox(height: 50),
                    _buildCategoryBar(context),
                    const SizedBox(height: 50),
                    _buildPopularSection(context),
                    const SizedBox(height: 60),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildWebHeader(BuildContext context, bool isDesktop) {
    return AppBar(
      backgroundColor: AppTheme.primaryMaroon,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      titleSpacing: isDesktop ? 24 : 12,
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            InkWell(
              onTap: () => context.go('/'),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppTheme.borderMaroon, width: 2),
                    ),
                    child: const Icon(Icons.outdoor_grill_rounded, size: 18, color: AppTheme.primaryMaroon),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'SMOKIN DANNYS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 30),
              _navLink('Menu', () => context.go('/customer/home')),
              const SizedBox(width: 18),
              _navLink('Offers', () => _showInfoDialog(context, 'Special Offers', 'Enjoy 20% off on all smoked ribs every weekend! Free delivery for orders over ₱1,000.')),
              const SizedBox(width: 18),
              _navLink('Locations', () => _showInfoDialog(context, 'Our Locations', '📍 Main Branch: 123 Smokelin St, Quezon City\n📍 South Branch: 45 Grill Ave, Makati City')),
              const SizedBox(width: 18),
              _navLink('Our Story', () => _showInfoDialog(context, 'Our Story', 'Smokin Dannys BBQ was founded with a passion for authentic slow-cooked smoked meats and rich family recipes.')),
              const SizedBox(width: 18),
              _navLink('Rewards', () => _showInfoDialog(context, 'Rewards Program', 'Earn 1 point for every ₱100 spent and redeem free burgers, steaks, and drinks!')),
            ],
          ],
        ),
      ),
      actions: [
        if (isDesktop) ...[
          SizedBox(
            width: 220,
            height: 40,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.darkText, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search ribs, burgers...',
                hintStyle: const TextStyle(color: AppTheme.mutedText, fontSize: 12),
                prefixIcon: const Icon(Icons.search, color: AppTheme.mutedText, size: 16),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppTheme.borderMaroon),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppTheme.borderMaroon),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 1.5),
                ),
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  context.go('/customer/home');
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
                onPressed: () {
                  _checkAuthAndProceed(() {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Your Cart is currently empty.')),
                    );
                  });
                },
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('0', style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 8, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => context.push('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryMaroon,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 24),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
            onPressed: () {
              _checkAuthAndProceed(() {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Your Cart is currently empty.')),
                );
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(color: AppTheme.darkText, height: 1.4)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryMaroon),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _navLink(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDesktopHero(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.softMaroon,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.champagneGold, width: 1.2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: AppTheme.champagneGold, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'PREMIUM MAROON & WHITE BBQ PORTAL',
                      style: TextStyle(
                        color: AppTheme.primaryMaroon,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'GOOD FOOD.\nDELIVERED\nFASTER.',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Real ingredients. Bold flavors. Delivered on your time in classic maroon and white styling.',
                style: TextStyle(
                  color: AppTheme.mutedText,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _checkAuthAndProceed(() => context.go('/customer/home'));
                    },
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Order now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryMaroon,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => context.go('/customer/home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryMaroon,
                      side: const BorderSide(color: AppTheme.primaryMaroon, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Explore menu'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  _heroFeatureItem(Icons.flash_on, 'Delivery or pickup', 'Choose what suits you'),
                  const SizedBox(width: 24),
                  _heroFeatureItem(Icons.eco, 'Fresh ingredients', 'Prepared with care'),
                  const SizedBox(width: 24),
                  _heroFeatureItem(Icons.local_fire_department, 'Cooked to order', 'Made for your meal'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          flex: 6,
          child: Container(
            height: 380,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.borderMaroon),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33800000),
                  blurRadius: 25,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'Menu_Food_Photos/01_The_Ultimate_Rib.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GOOD FOOD.\nDELIVERED\nFASTER.',
          style: TextStyle(
            color: AppTheme.darkText,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Real ingredients. Bold flavors. Delivered on your time.',
          style: TextStyle(color: AppTheme.mutedText, fontSize: 14),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            _checkAuthAndProceed(() => context.go('/customer/home'));
          },
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: const Text('Order now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryMaroon,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
      ],
    );
  }

  Widget _heroFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.softMaroon,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.champagneGold.withValues(alpha: 0.5)),
          ),
          child: Icon(icon, color: AppTheme.primaryMaroon, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppTheme.darkText, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: AppTheme.mutedText, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryBar(BuildContext context) {
    final categories = [
      {'icon': Icons.grid_view, 'name': 'All'},
      {'icon': Icons.local_fire_department, 'name': 'BBQ & Grills'},
      {'icon': Icons.kebab_dining, 'name': 'Chicken'},
      {'icon': Icons.local_pizza, 'name': 'Pizza'},
      {'icon': Icons.dinner_dining, 'name': 'Pasta'},
      {'icon': Icons.room_service, 'name': 'Sides'},
      {'icon': Icons.breakfast_dining, 'name': 'All-Day Breakfast'},
      {'icon': Icons.cake, 'name': 'Desserts'},
    ];

    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderMaroon),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 32),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = index == 0;
          return InkWell(
            onTap: () => context.go('/customer/home'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryMaroon : AppTheme.softMaroon,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat['icon'] as IconData, color: isSelected ? Colors.white : AppTheme.primaryMaroon, size: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  cat['name'] as String,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryMaroon : AppTheme.mutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'FEATURED MENU ITEMS (16 ITEMS)',
              style: TextStyle(
                color: AppTheme.darkText,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/customer/home'),
              child: const Text(
                'View All 16 Items →',
                style: TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _menuItemCard(context, 'The Ultimate Rib', '₱599.00', 'Menu_Food_Photos/01_The_Ultimate_Rib.jpg')),
            const SizedBox(width: 16),
            Expanded(child: _menuItemCard(context, 'Trio Baby Back Ribs', '₱899.00', 'Menu_Food_Photos/02_Trio_Baby_Back_Ribs.jpg')),
            const SizedBox(width: 16),
            Expanded(child: _menuItemCard(context, 'Ultimate BBQ Platter', '₱1,199.00', 'Menu_Food_Photos/03_Ultimate_BBQ_Platter.jpg')),
            const SizedBox(width: 16),
            Expanded(child: _menuItemCard(context, 'Pizza & Pasta Sisig', '₱399.00', 'Menu_Food_Photos/06_Pizza_and_Pasta_Sisig.jpg')),
          ],
        ),
      ],
    );
  }

  Widget _menuItemCard(BuildContext context, String name, String price, String imageUrl) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderMaroon),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.softMaroon,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(imageUrl, fit: BoxFit.cover, width: double.infinity),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.darkText, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price, style: const TextStyle(color: AppTheme.primaryMaroon, fontSize: 14, fontWeight: FontWeight.w900)),
              IconButton(
                icon: const Icon(Icons.add_shopping_cart, color: AppTheme.primaryMaroon, size: 16),
                onPressed: () {
                  _checkAuthAndProceed(() {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added $name to cart successfully!')),
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '© 2025 SMOKIN DANNYS BBQ & POS. All rights reserved.',
            style: TextStyle(color: AppTheme.mutedText, fontSize: 11),
          ),
          InkWell(
            onTap: () => context.push('/admin/login'),
            child: const Text(
              'Staff / Admin Portal →',
              style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
