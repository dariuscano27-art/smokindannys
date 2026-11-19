import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: _buildWebHeader(context, isDesktop),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48.0 : 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section matching reference image
                    isDesktop ? _buildDesktopHero(context) : _buildMobileHero(context),

                    const SizedBox(height: 50),

                    // Category Bar
                    _buildCategoryBar(),

                    const SizedBox(height: 50),

                    // Popular Right Now Section preview
                    _buildPopularSection(context),

                    const SizedBox(height: 60),

                    // Footer
                    _buildFooter(),
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
      backgroundColor: AppTheme.darkBg,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      titleSpacing: isDesktop ? 48 : 16,
      title: Row(
        children: [
          // Brand Logo
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryRed,
                ),
                child: const Icon(Icons.location_on, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Text(
                'SMOKIN DANNYS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          if (isDesktop) ...[
            const SizedBox(width: 50),
            _navLink('Menu', () => context.go('/customer/home')),
            const SizedBox(width: 24),
            _navLink('Offers', () {}),
            const SizedBox(width: 24),
            _navLink('Locations', () {}),
            const SizedBox(width: 24),
            _navLink('Our Story', () {}),
            const SizedBox(width: 24),
            _navLink('Rewards', () {}),
          ],
        ],
      ),
      actions: [
        if (isDesktop) ...[
          // Search bar
          Container(
            width: 260,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: AppTheme.borderDark),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: const [
                Icon(Icons.search, color: AppTheme.textMuted, size: 18),
                SizedBox(width: 10),
                Text(
                  'Search for ribs, burgers...',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Cart Icon with badge
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cart coming up')),
                  );
                },
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('0', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Sign In Button
          ElevatedButton(
            onPressed: () => context.push('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 48),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _navLink(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDesktopHero(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Bold Text & CTA matching reference image
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GOOD FOOD.\nDELIVERED\nFASTER.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Real ingredients. Bold flavors. Delivered on your time.',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 36),

              // CTA Buttons
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.push('/login'),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Order now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => context.go('/customer/home'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppTheme.borderDark, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Explore menu'),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Feature badges row
              Row(
                children: [
                  _heroFeatureItem(Icons.flash_on, 'Delivery or pickup', 'Choose what suits you'),
                  const SizedBox(width: 32),
                  _heroFeatureItem(Icons.eco, 'Fresh ingredients', 'Prepared with care'),
                  const SizedBox(width: 32),
                  _heroFeatureItem(Icons.local_fire_department, 'Cooked to order', 'Made for your meal'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 40),

        // Right Column: Gorgeous Burger Image Card matching image 1/2
        Expanded(
          flex: 6,
          child: Container(
            height: 420,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [AppTheme.cardBg, AppTheme.surfaceBg],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppTheme.borderDark),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 30,
                  offset: Offset(0, 15),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      child: const Center(
                        child: Icon(Icons.fastfood_rounded, size: 140, color: AppTheme.primaryRed),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 24,
                  left: 24,
                  child: Text(
                    '🔥 Signature Smoked BBQ Burger',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Real ingredients. Bold flavors. Delivered on your time.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => context.push('/login'),
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: const Text('Order now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
        ),
      ],
    );
  }

  Widget _heroFeatureItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryRed, size: 22),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryBar() {
    final categories = [
      {'icon': Icons.grid_view, 'name': 'All'},
      {'icon': Icons.local_pizza, 'name': 'Pizza'},
      {'icon': Icons.lunch_dining, 'name': 'Burgers'},
      {'icon': Icons.kebab_dining, 'name': 'Chicken'},
      {'icon': Icons.dinner_dining, 'name': 'Pasta'},
      {'icon': Icons.eco, 'name': 'Salads'},
      {'icon': Icons.room_service, 'name': 'Sides'},
      {'icon': Icons.local_drink, 'name': 'Drinks'},
    ];

    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderDark),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryRed : AppTheme.surfaceBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat['icon'] as IconData, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  cat['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                    fontSize: 12,
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
              'POPULAR RIGHT NOW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/customer/home'),
              child: const Text(
                'View All →',
                style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Grid preview
        Row(
          children: [
            Expanded(child: _menuItemCard(context, 'Margherita Pizza', '₱349.00')),
            const SizedBox(width: 20),
            Expanded(child: _menuItemCard(context, 'Classic Cheeseburger', '₱289.00')),
            const SizedBox(width: 20),
            Expanded(child: _menuItemCard(context, 'Crispy Chicken Tenders', '₱259.00')),
            const SizedBox(width: 20),
            Expanded(child: _menuItemCard(context, 'Creamy Alfredo Pasta', '₱299.00')),
          ],
        ),
      ],
    );
  }

  Widget _menuItemCard(BuildContext context, String name, String price) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderDark),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceBg,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.fastfood, size: 50, color: AppTheme.primaryRed),
            ),
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price, style: const TextStyle(color: AppTheme.primaryRed, fontSize: 15, fontWeight: FontWeight.w900)),
              IconButton(
                icon: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 18),
                onPressed: () => context.go('/customer/home'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            '© 2025 SMOKIN DANNYS FOOD STUDIO. All rights reserved.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
          Text(
            'Privacy · Terms · Support',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
