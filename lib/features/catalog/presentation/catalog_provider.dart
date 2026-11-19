import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository();
});

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await ref.watch(catalogRepositoryProvider).getCategories();
});

// Search and filter parameters state
class CatalogFilterState {
  final String? categoryId;
  final String searchQuery;
  final String sortBy;

  CatalogFilterState({
    this.categoryId,
    this.searchQuery = '',
    this.sortBy = 'name',
  });

  CatalogFilterState copyWith({
    String? categoryId,
    String? searchQuery,
    String? sortBy,
    bool clearCategory = false,
  }) {
    return CatalogFilterState(
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class CatalogFilterNotifier extends StateNotifier<CatalogFilterState> {
  CatalogFilterNotifier() : super(CatalogFilterState());

  void setCategory(String? categoryId) {
    state = state.copyWith(categoryId: categoryId, clearCategory: categoryId == null);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }
}

final catalogFilterProvider = StateNotifierProvider<CatalogFilterNotifier, CatalogFilterState>((ref) {
  return CatalogFilterNotifier();
});

final productsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final filter = ref.watch(catalogFilterProvider);
  return await ref.watch(catalogRepositoryProvider).getProducts(
        categoryId: filter.categoryId,
        searchQuery: filter.searchQuery,
        sortBy: filter.sortBy,
      );
});

final productDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, productId) async {
  return await ref.watch(catalogRepositoryProvider).getProductDetails(productId);
});
