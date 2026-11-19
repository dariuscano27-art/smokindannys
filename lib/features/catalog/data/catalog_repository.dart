import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

class CatalogRepository {
  SupabaseClient get _client => SupabaseConfig.client;

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('display_order', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getProducts({
    String? categoryId,
    String? searchQuery,
    String sortBy = 'name', // 'name', 'price_asc', 'price_desc'
  }) async {
    var query = _client.from('products').select('*, categories(name)').eq('is_available', true);

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.eq('category_id', categoryId);
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      query = query.ilike('name', '%${searchQuery.trim()}%');
    }

    final response = await query;
    var products = List<Map<String, dynamic>>.from(response);

    // Sorting
    if (sortBy == 'price_asc') {
      products.sort((a, b) => (a['base_price'] as num).compareTo(b['base_price'] as num));
    } else if (sortBy == 'price_desc') {
      products.sort((a, b) => (b['base_price'] as num).compareTo(a['base_price'] as num));
    } else {
      products.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    }

    return products;
  }

  Future<Map<String, dynamic>> getProductDetails(String productId) async {
    final product = await _client
        .from('products')
        .select('*, categories(name), product_variants(*), product_addon_groups(*, product_addon_group_items(*))')
        .eq('id', productId)
        .single();
    return product;
  }

  Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    final response = await _client
        .from('favorites')
        .select('product_id, products(*)')
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> toggleFavorite({required String userId, required String productId, required bool isFavorite}) async {
    if (isFavorite) {
      await _client.from('favorites').delete().match({
        'user_id': userId,
        'product_id': productId,
      });
    } else {
      await _client.from('favorites').upsert({
        'user_id': userId,
        'product_id': productId,
      });
    }
  }
}
