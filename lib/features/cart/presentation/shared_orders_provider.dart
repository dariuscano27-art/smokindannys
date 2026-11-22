import 'package:flutter_riverpod/flutter_riverpod.dart';

class SharedOrdersNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  SharedOrdersNotifier() : super([
    {
      'id': '#SD-1048',
      'customer': 'Table 4 (Dine-In)',
      'items': 'Signature Smoked Ribs x2, Iced Tea x2',
      'total': 898.00,
      'status': 'Completed',
      'type': 'Dine-In',
      'phone': '09123456789',
    },
    {
      'id': '#SD-1047',
      'customer': 'Maria Santos (Takeout)',
      'items': 'Classic Cheeseburger, Crispy Fries',
      'total': 389.00,
      'status': 'Preparing',
      'type': 'Takeout',
      'phone': '09187654321',
    },
  ]);

  void addOrder({
    required String orderId,
    required String customerName,
    required String itemsSummary,
    required double total,
    required String orderType,
    required String phone,
  }) {
    final newOrder = {
      'id': orderId,
      'customer': '$customerName ($orderType)',
      'items': itemsSummary,
      'total': total,
      'status': 'Preparing',
      'type': orderType,
      'phone': phone,
    };
    state = [newOrder, ...state];
  }

  void updateStatus(String orderId, String newStatus) {
    state = [
      for (final order in state)
        if (order['id'] == orderId)
          {...order, 'status': newStatus}
        else
          order
    ];
  }
}

final sharedOrdersProvider = StateNotifierProvider<SharedOrdersNotifier, List<Map<String, dynamic>>>((ref) {
  return SharedOrdersNotifier();
});
