import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'catalog_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../cart/presentation/cart_modal.dart';
import '../../cart/presentation/cart_provider.dart';
import '../../profile/presentation/customer_profile_modal.dart';
import '../../../core/theme/app_theme.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';

  // Exact 16 menu items requested by client with corresponding photo paths
  final List<Map<String, dynamic>> _mockProducts = [
    {
      'name': 'The Ultimate Rib',
      'description': 'Tender, juicy, slow-smoked ultimate beef/pork rib glazed with rich BBQ sauce.',
      'price': 59900,
      'category': 'BBQ & Grills',
      'image_url': 'Menu_Food_Photos/01_The_Ultimate_Rib.jpg',
    },
    {
      'name': 'Trio Baby Back Ribs',
      'description': 'Three signature styles of slow-cooked baby back ribs served with sides.',
      'price': 89900,
      'category': 'BBQ & Grills',
      'image_url': 'Menu_Food_Photos/02_Trio_Baby_Back_Ribs.jpg',
    },
    {
      'name': 'Ultimate BBQ Platter',
      'description': 'Massive sharing platter with ribs, grilled chicken, wings, and sausages.',
      'price': 119900,
      'category': 'BBQ & Grills',
      'image_url': 'Menu_Food_Photos/03_Ultimate_BBQ_Platter.jpg',
    },
    {
      'name': 'Italian Grilled Chicken',
      'description': 'Herb-marinated grilled chicken breast served with roasted veggies.',
      'price': 34900,
      'category': 'Chicken',
      'image_url': 'Menu_Food_Photos/04_Italian_Grilled_Chicken.jpg',
    },
    {
      'name': 'Chicken Barbecue (with Java Rice & Atchara)',
      'description': 'Classic grilled chicken barbecue skewer served with flavorful java rice and atchara.',
      'price': 26900,
      'category': 'Chicken',
      'image_url': 'Menu_Food_Photos/05_Chicken_Barbecue_with_Java_Rice_and_Atchara.jpg',
    },
    {
      'name': 'Pizza & Pasta Sisig',
      'description': 'Fusion masterpiece combining crispy savory sisig on pizza and pasta.',
      'price': 39900,
      'category': 'Pizza',
      'image_url': 'Menu_Food_Photos/06_Pizza_and_Pasta_Sisig.jpg',
    },
    {
      'name': 'Pizza Canton',
      'description': 'Unique stir-fried canton noodles loaded with pizza toppings and cheese.',
      'price': 24900,
      'category': 'Pasta',
      'image_url': 'Menu_Food_Photos/07_Pizza_Canton.jpg',
    },
    {
      'name': 'Sisig Tuna Pasta',
      'description': 'Creamy pasta tossed with flavorful tuna sisig and calamansi zest.',
      'price': 28900,
      'category': 'Pasta',
      'image_url': 'Menu_Food_Photos/08_Sisig_Tuna_Pasta.jpg',
    },
    {
      'name': 'Buffalo Wings',
      'description': 'Crispy chicken wings tossed in fiery buffalo hot sauce with ranch dip.',
      'price': 25900,
      'category': 'Chicken',
      'image_url': 'Menu_Food_Photos/09_Buffalo_Wings.jpg',
    },
    {
      'name': 'Garlic Parmesan Wings',
      'description': 'Crispy chicken wings coated in rich garlic butter and parmesan cheese.',
      'price': 26900,
      'category': 'Chicken',
      'image_url': 'Menu_Food_Photos/10_Garlic_Parmesan_Wings.jpg',
    },
    {
      'name': 'Chili Con Nachos',
      'description': 'Crispy corn tortilla chips loaded with spicy chili con carne and melted cheese.',
      'price': 22900,
      'category': 'Sides',
      'image_url': 'Menu_Food_Photos/11_Chili_Con_Nachos.jpg',
    },
    {
      'name': 'Crispy Fries',
      'description': 'Golden brown crispy potato french fries served with special dipping sauce.',
      'price': 12900,
      'category': 'Sides',
      'image_url': 'Menu_Food_Photos/12_Crispy_Fries.jpg',
    },
    {
      'name': 'Tapa Silog',
      'description': 'Savory cured beef tapa served with garlic fried rice and fried egg.',
      'price': 19900,
      'category': 'All-Day Breakfast',
      'image_url': 'Menu_Food_Photos/13_Tapa_Silog.jpg',
    },
    {
      'name': 'Tocilog',
      'description': 'Sweet cured pork tocino served with garlic fried rice and fried egg.',
      'price': 18900,
      'category': 'All-Day Breakfast',
      'image_url': 'Menu_Food_Photos/14_Tocilog.jpg',
    },
    {
      'name': 'Spam & Eggs Skillet',
      'description': 'Sizzling skillet of thick-cut spam slices and sunny-side-up eggs with rice.',
      'price': 21900,
      'category': 'All-Day Breakfast',
      'image_url': 'Menu_Food_Photos/15_Spam_and_Eggs_Skillet.jpg',
    },
    {
      'name': 'Suman Sundae',
      'description': 'Traditional sweet sticky rice suman topped with rich vanilla ice cream and latik.',
      'price': 14900,
      'category': 'Desserts',
      'image_url': 'Menu_Food_Photos/16_Suman_Sundae.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

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
                  horizontal: isDesktop ? 48.0 : 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role Identification Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.softMaroon,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryMaroon),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_rounded, size: 14, color: AppTheme.primaryMaroon),
                          SizedBox(width: 6),
                          Text('ROLE: CUSTOMER PORTAL (Food Catalog & Ordering)', style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title & Search Section
                    _buildHeaderBanner(isDesktop),

                    const SizedBox(height: 32),

                    // Category Icon Bar
                    _buildCategoryBar(),

                    const SizedBox(height: 36),

                    // Products Grid (handles errors gracefully with mock fallback)
                    productsAsync.when(
                      data: (products) {
                        final displayList = products.isEmpty ? _mockProducts : products;
                        return _buildProductGrid(context, displayList, isDesktop);
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(60.0),
                          child: CircularProgressIndicator(color: AppTheme.primaryMaroon),
                        ),
                      ),
                      error: (err, st) => _buildProductGrid(context, _mockProducts, isDesktop),
                    ),

                    const SizedBox(height: 60),
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
      titleSpacing: isDesktop ? 48 : 16,
      title: InkWell(
        onTap: () => context.go('/'),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppTheme.borderMaroon, width: 2),
              ),
              child: const Icon(Icons.outdoor_grill_rounded, size: 20, color: AppTheme.primaryMaroon),
            ),
            const SizedBox(width: 12),
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
      ),
      actions: [
        if (isDesktop) ...[
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Home', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 20),
          TextButton(
            onPressed: () {},
            child: const Text('Menu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 20),
          TextButton(
            onPressed: () => _showInfoDialog(context, 'Special Offers', 'Enjoy 20% off on all smoked ribs every weekend! Free delivery for orders over ₱1,000.'),
            child: const Text('Offers', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 20),
          TextButton(
            onPressed: () => _showInfoDialog(context, 'Rewards Program', 'Earn 1 point for every ₱100 spent and redeem free burgers, steaks, and drinks!'),
            child: const Text('Rewards', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 28),

          // Reactive Cart Button with Dynamic Badge
          Consumer(
            builder: (context, ref, child) {
              final cartCount = ref.watch(cartTotalCountProvider);
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
                    onPressed: () => showCartModal(context, ref),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppTheme.champagneGold,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: AppTheme.primaryMaroon,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),

          Consumer(
            builder: (context, ref, child) {
              return Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => showCustomerProfileModal(context, ref),
                    icon: const Icon(Icons.person_pin_rounded, size: 16),
                    label: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.softMaroon,
                      foregroundColor: AppTheme.primaryMaroon,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(authControllerProvider.notifier).signOut();
                      if (!context.mounted) return;
                      context.go('/');
                    },
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryMaroon,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 24),
        ] else ...[
          Consumer(
            builder: (context, ref, child) {
              final cartCount = ref.watch(cartTotalCountProvider);
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                    onPressed: () => showCartModal(context, ref),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppTheme.champagneGold,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: AppTheme.primaryMaroon,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: Colors.white),
            onPressed: () => showCustomerProfileModal(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (!context.mounted) return;
              context.go('/');
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

  Widget _buildHeaderBanner(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FIND YOUR NEXT FAVORITE.',
          style: TextStyle(
            color: AppTheme.darkText,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Great food. More to love. Explore our menu and order your favorites.',
          style: TextStyle(color: AppTheme.mutedText, fontSize: 15),
        ),
        const SizedBox(height: 24),
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
          style: const TextStyle(color: AppTheme.darkText, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search menu items...',
            hintStyle: const TextStyle(color: AppTheme.mutedText, fontSize: 13),
            prefixIcon: const Icon(Icons.search, color: AppTheme.mutedText, size: 20),
            filled: true,
            fillColor: AppTheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppTheme.borderMaroon)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppTheme.borderMaroon)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 1.8)),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBar() {
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

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategoryIndex == index;
          return InkWell(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryMaroon : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppTheme.primaryMaroon : AppTheme.borderMaroon),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cat['icon'] as IconData,
                    color: isSelected ? Colors.white : AppTheme.primaryMaroon,
                    size: 22,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['name'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.mutedText,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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

  Widget _buildProductGrid(BuildContext context, List<dynamic> products, bool isDesktop) {
    // Filter by category and search query
    final categories = ['All', 'BBQ & Grills', 'Chicken', 'Pizza', 'Pasta', 'Sides', 'All-Day Breakfast', 'Desserts'];
    final selectedCat = categories[_selectedCategoryIndex];

    final filtered = products.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final desc = (p['description'] ?? '').toString().toLowerCase();
      final cat = (p['category'] ?? '').toString();

      final matchesSearch = name.contains(_searchQuery) || desc.contains(_searchQuery);
      final matchesCat = selectedCat == 'All' || cat == selectedCat;

      return matchesSearch && matchesCat;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(60.0),
          child: Text('No menu items found matching your search.', style: TextStyle(color: AppTheme.mutedText, fontSize: 14)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];
        return _productCard(context, product);
      },
    );
  }

  Widget _productCard(BuildContext context, dynamic product) {
    final name = product['name'] ?? 'Product';
    final desc = product['description'] ?? '';
    final rawPrice = (product['price'] ?? 0);
    final price = rawPrice > 1000 ? rawPrice / 100.0 : (rawPrice is int ? rawPrice.toDouble() : rawPrice);
    final imageUrl = product['image_url'] as String?;

    return Container(
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
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(imageUrl, fit: BoxFit.cover, width: double.infinity),
                    )
                  : const Icon(Icons.fastfood_rounded, size: 40, color: AppTheme.primaryMaroon),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.mutedText, fontSize: 11, height: 1.3),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₱${price.toStringAsFixed(2)}',
                style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 15),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(cartProvider.notifier).addItem({
                    'name': name,
                    'price': price,
                    'image_url': imageUrl,
                    'category': product['category'] ?? 'Main',
                  });
                  AppToast.show(context, message: 'Added $name to cart!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryMaroon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
