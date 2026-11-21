import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final String id;
  final String name;
  final double price; // in Pesos
  final String? imageUrl;
  final String category;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.category,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(Map<String, dynamic> product) {
    final name = (product['name'] ?? 'Menu Item') as String;
    final rawPrice = (product['base_price'] ?? product['price'] ?? 299.0) as num;
    
    // Convert centavos (e.g. 119900) or keep exact Pesos (e.g. 1199.0)
    final double pricePesos;
    if (rawPrice >= 10000) {
      pricePesos = rawPrice / 100.0;
    } else {
      pricePesos = rawPrice.toDouble();
    }
    
    final imageUrl = product['image_url'] as String?;
    final category = (product['category'] ?? 'Main') as String;

    final existingIndex = state.indexWhere((item) => item.name == name);
    if (existingIndex >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex)
            CartItem(
              id: state[i].id,
              name: state[i].name,
              price: state[i].price,
              imageUrl: state[i].imageUrl,
              category: state[i].category,
              quantity: state[i].quantity + 1,
            )
          else
            state[i]
      ];
    } else {
      state = [
        ...state,
        CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          price: pricePesos,
          imageUrl: imageUrl,
          category: category,
          quantity: 1,
        )
      ];
    }
  }

  void updateQuantity(String id, int delta) {
    state = [
      for (final item in state)
        if (item.id == id)
          if (item.quantity + delta > 0)
            CartItem(
              id: item.id,
              name: item.name,
              price: item.price,
              imageUrl: item.imageUrl,
              category: item.category,
              quantity: item.quantity + delta,
            )
          else
            null
        else
          item
    ].whereType<CartItem>().toList();
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clear() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});

final cartTotalPriceProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider);
  return items.fold(0.0, (sum, item) => sum + item.total);
});
