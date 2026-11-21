import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'catalog_provider.dart';
import '../../auth/presentation/auth_provider.dart';
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
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shopping Cart coming up')),
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
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('0', style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Builder(
            builder: (context) {
              final user = ref.read(authRepositoryProvider).currentUser;
              if (user == null) {
                return TextButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                );
              } else {
                return TextButton(
                  onPressed: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    if (context.mounted) {
                      setState(() {});
                      context.go('/login');
                    }
                  },
                  child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                );
              }
            },
          ),
          const SizedBox(width: 48),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
            onPressed: () {},
          ),
          Builder(
            builder: (context) {
              final user = ref.read(authRepositoryProvider).currentUser;
              if (user == null) {
                return IconButton(
                  icon: const Icon(Icons.login, color: Colors.white),
                  onPressed: () => context.push('/login'),
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    if (context.mounted) {
                      setState(() {});
                      context.go('/login');
                    }
                  },
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ],
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
            fontSize: 32,
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
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: AppTheme.darkText, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search menu items...',
                    hintStyle: const TextStyle(color: AppTheme.mutedText, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.mutedText, size: 20),
                    filled: true,
                    fillColor: AppTheme.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppTheme.borderMaroon),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppTheme.borderMaroon),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppTheme.primaryMaroon, width: 1.8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryBar() {
    final categories = ['All', 'BBQ & Grills', 'Chicken', 'Pizza', 'Pasta', 'Sides', 'All-Day Breakfast', 'Desserts'];
    final icons = [
      Icons.grid_view,
      Icons.local_fire_department,
      Icons.kebab_dining,
      Icons.local_pizza,
      Icons.dinner_dining,
      Icons.room_service,
      Icons.breakfast_dining,
      Icons.cake,
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          final catName = categories[index];
          return InkWell(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryMaroon : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppTheme.primaryMaroon : AppTheme.borderMaroon),
              ),
              child: Row(
                children: [
                  Icon(icons[index], color: isSelected ? Colors.white : AppTheme.primaryMaroon, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    catName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.darkText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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
    final categoriesList = ['All', 'BBQ & Grills', 'Chicken', 'Pizza', 'Pasta', 'Sides', 'All-Day Breakfast', 'Desserts'];
    final selectedCategory = categoriesList[_selectedCategoryIndex];

    final filtered = products.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final cat = (p['category'] ?? '').toString();
      final matchesSearch = name.contains(_searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'All' || cat == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text('No menu items found.', style: TextStyle(color: AppTheme.mutedText, fontSize: 16)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final name = item['name'] ?? 'Item';
        final desc = item['description'] ?? 'Delicious meal from Smokin Dannys.';
        final rawPrice = (item['base_price'] ?? item['price'] ?? 29900) as num;
        final pricePesos = rawPrice > 1000 ? rawPrice / 100 : rawPrice.toDouble();
        final imageUrl = item['image_url'] as String?;

        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderMaroon),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A800000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
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
                      : const Icon(Icons.fastfood_rounded, size: 54, color: AppTheme.primaryMaroon),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.darkText, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.mutedText, fontSize: 11, height: 1.3),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₱${pricePesos.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppTheme.primaryMaroon, fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final authRepo = ref.read(authRepositoryProvider);
                      final user = authRepo.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please sign in first to add items to your cart.'),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added $name to cart successfully!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryMaroon,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Add to Cart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
