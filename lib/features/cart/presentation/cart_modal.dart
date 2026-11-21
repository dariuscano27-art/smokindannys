import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import 'cart_provider.dart';

void showCartModal(BuildContext context, WidgetRef ref) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'CartModal',
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 460,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 20,
                  offset: Offset(-4, 0),
                ),
              ],
            ),
            child: const _MultiStepCheckoutSheet(),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
  );
}

class _MultiStepCheckoutSheet extends ConsumerStatefulWidget {
  const _MultiStepCheckoutSheet();

  @override
  ConsumerState<_MultiStepCheckoutSheet> createState() => _MultiStepCheckoutSheetState();
}

class _MultiStepCheckoutSheetState extends ConsumerState<_MultiStepCheckoutSheet> {
  int _currentStep = 0; // 0 = Cart, 1 = Review Order, 2 = Payment & Checkout, 3 = Receipt

  String _diningOption = 'Delivery'; // Default for Customer Online Ordering!
  String _selectedPayment = 'GCash'; // 'GCash', 'Cash', 'Card'
  final _tableOrAddressController = TextEditingController(text: '123 Main St, Quezon City');
  final _phoneController = TextEditingController(text: '09123456789');
  final _notesController = TextEditingController();
  String _confirmedOrderId = '#SD-1049';

  @override
  void dispose() {
    _tableOrAddressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final totalCount = ref.watch(cartTotalCountProvider);
    final totalPrice = ref.watch(cartTotalPriceProvider);

    return Column(
      children: [
        // Top Header
        _buildHeader(context, totalCount),

        // Step Progress Indicator
        if (cartItems.isNotEmpty && _currentStep < 3) _buildStepProgress(),

        // Dynamic Step Content
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildStepView(cartItems, totalPrice),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, int totalCount) {
    final stepTitles = ['YOUR SHOPPING CART', 'REVIEW ONLINE ORDER', 'CHECKOUT & PAYMENT', 'ORDER CONFIRMED'];
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryMaroon,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (_currentStep > 0 && _currentStep < 3)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => setState(() => _currentStep--),
                ),
              Icon(
                _currentStep == 0
                    ? Icons.shopping_bag_outlined
                    : _currentStep == 1
                        ? Icons.assignment_outlined
                        : _currentStep == 2
                            ? Icons.payment_outlined
                            : Icons.check_circle_outline,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                stepTitles[_currentStep],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              if (_currentStep == 0 && totalCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.champagneGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalCount',
                    style: const TextStyle(
                      color: AppTheme.primaryMaroon,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: AppTheme.softMaroon,
      child: Row(
        children: [
          _stepDot(0, 'Cart'),
          _stepLine(0),
          _stepDot(1, 'Review'),
          _stepLine(1),
          _stepDot(2, 'Payment'),
        ],
      ),
    );
  }

  Widget _stepDot(int stepIndex, String label) {
    final isActive = _currentStep >= stepIndex;
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppTheme.primaryMaroon : Colors.white,
            border: Border.all(color: isActive ? AppTheme.primaryMaroon : AppTheme.borderMaroon),
          ),
          alignment: Alignment.center,
          child: Text(
            '${stepIndex + 1}',
            style: TextStyle(
              color: isActive ? Colors.white : AppTheme.mutedText,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.primaryMaroon : AppTheme.mutedText,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(int fromStep) {
    final isActive = _currentStep > fromStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? AppTheme.primaryMaroon : AppTheme.borderMaroon,
      ),
    );
  }

  Widget _buildStepView(List<CartItem> cartItems, double totalPrice) {
    if (cartItems.isEmpty && _currentStep < 3) {
      return _buildEmptyCart();
    }

    switch (_currentStep) {
      case 0:
        return _buildStep0CartList(cartItems, totalPrice);
      case 1:
        return _buildStep1ReviewOrder(cartItems, totalPrice);
      case 2:
        return _buildStep2PaymentCheckout(cartItems, totalPrice);
      case 3:
        return _buildStep3Receipt();
      default:
        return _buildStep0CartList(cartItems, totalPrice);
    }
  }

  Widget _buildStep0CartList(List<CartItem> cartItems, double totalPrice) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: cartItems.length,
            separatorBuilder: (context, index) => const Divider(height: 24, color: AppTheme.borderMaroon),
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildCartItemTile(item);
            },
          ),
        ),

        // Cart Summary Footer
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppTheme.softMaroon,
            border: Border(top: BorderSide(color: AppTheme.borderMaroon)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
                  Text('₱${totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Estimated Delivery / Tax', style: TextStyle(color: AppTheme.mutedText, fontSize: 13)),
                  Text('FREE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: AppTheme.borderMaroon),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Grand Total', style: TextStyle(color: AppTheme.darkText, fontSize: 16, fontWeight: FontWeight.w900)),
                  Text(
                    '₱${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppTheme.primaryMaroon, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => setState(() => _currentStep = 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('PROCEED TO REVIEW ORDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep1ReviewOrder(List<CartItem> cartItems, double totalPrice) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Type Selection (Delivery default for Online Ordering)
          const Text('1. SELECT ONLINE ORDER TYPE', style: TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Row(
            children: ['Delivery', 'Takeout', 'Dine-In'].map((type) {
              final isSelected = _diningOption == type;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => setState(() {
                      _diningOption = type;
                      if (type == 'Delivery') _tableOrAddressController.text = '123 Main St, Quezon City';
                      if (type == 'Takeout') _tableOrAddressController.text = 'Takeout Pickup Counter';
                      if (type == 'Dine-In') _tableOrAddressController.text = 'Table 4';
                    }),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryMaroon : AppTheme.softMaroon,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppTheme.primaryMaroon : AppTheme.borderMaroon),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.darkText,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Address / Table / Ref Input
          Text(
            _diningOption == 'Delivery'
                ? 'Delivery Address & Landmark *'
                : _diningOption == 'Takeout'
                    ? 'Pickup Reference Name *'
                    : 'Table Number *',
            style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _tableOrAddressController,
            style: const TextStyle(color: AppTheme.darkText, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Enter address or details',
              prefixIcon: Icon(
                _diningOption == 'Delivery'
                    ? Icons.location_on_outlined
                    : _diningOption == 'Takeout'
                        ? Icons.shopping_bag_outlined
                        : Icons.table_restaurant,
                color: AppTheme.primaryMaroon,
                size: 18,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Recipient Phone Number
          const Text('Contact Phone Number *', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
            style: const TextStyle(color: AppTheme.darkText, fontSize: 13),
            decoration: const InputDecoration(
              hintText: '09123456789',
              prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.primaryMaroon, size: 18),
            ),
          ),

          const SizedBox(height: 14),

          // Special Kitchen Notes
          const Text('Special Instructions (Optional)', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 2,
            style: const TextStyle(color: AppTheme.darkText, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'e.g. Extra barbecue sauce, no onions please',
              prefixIcon: Icon(Icons.note_alt_outlined, color: AppTheme.primaryMaroon, size: 18),
            ),
          ),

          const SizedBox(height: 24),

          // Order Items Summary List
          const Text('2. ORDER SUMMARY BREAKDOWN', style: TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.softMaroon,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderMaroon),
            ),
            child: Column(
              children: [
                ...cartItems.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.quantity}x ${item.name}', style: const TextStyle(color: AppTheme.darkText, fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('₱${item.total.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    )),
                const Divider(height: 20, color: AppTheme.borderMaroon),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount Due', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w900, fontSize: 14)),
                    Text('₱${totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Action Button to Payment
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => setState(() => _currentStep = 2),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryMaroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('PROCEED TO PAYMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2PaymentCheckout(List<CartItem> cartItems, double totalPrice) {
    final paymentMethods = [
      {'id': 'GCash', 'title': 'GCash / e-Wallet', 'icon': Icons.account_balance_wallet_outlined},
      {'id': 'Cash', 'title': 'Cash on Delivery / Counter', 'icon': Icons.payments_outlined},
      {'id': 'Card', 'title': 'Credit / Debit Card', 'icon': Icons.credit_card_outlined},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SELECT PAYMENT METHOD', style: TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
          const SizedBox(height: 12),

          ...paymentMethods.map((method) {
            final isSelected = _selectedPayment == method['id'];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.softMaroon : AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppTheme.primaryMaroon : AppTheme.borderMaroon, width: isSelected ? 1.8 : 1),
              ),
              child: RadioListTile<String>(
                value: method['id'] as String,
                groupValue: _selectedPayment,
                activeColor: AppTheme.primaryMaroon,
                title: Row(
                  children: [
                    Icon(method['icon'] as IconData, color: AppTheme.primaryMaroon, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      method['title'] as String,
                      style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                onChanged: (val) => setState(() => _selectedPayment = val!),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Payment Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.softMaroon,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.champagneGold, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Order Type', style: TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                    Text(_diningOption, style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reference / Address', style: TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                    Text(_tableOrAddressController.text, style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Contact Phone', style: TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                    Text(_phoneController.text, style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: AppTheme.borderMaroon),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount Due', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('₱${totalPrice.toStringAsFixed(2)}', style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Place Order Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final orderId = '#SD-${1045 + DateTime.now().second}';
                setState(() {
                  _confirmedOrderId = orderId;
                  _currentStep = 3;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryMaroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 3,
              ),
              child: const Text('PLACE ONLINE ORDER NOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Receipt() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'ONLINE ORDER PLACED!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.primaryMaroon, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          Text(
            'Order Reference: $_confirmedOrderId',
            style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.softMaroon,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderMaroon),
            ),
            child: Column(
              children: [
                _receiptRow('Status', 'Sent to Kitchen Queue 👨‍🍳', isGreen: true),
                _receiptRow('Order Type', _diningOption),
                _receiptRow('Address / Ref', _tableOrAddressController.text),
                _receiptRow('Contact Phone', _phoneController.text),
                _receiptRow('Payment Method', _selectedPayment),
              ],
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ref.read(cartProvider.notifier).clear();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryMaroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: const Text('BACK TO MENU', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.mutedText, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              color: isGreen ? Colors.green : AppTheme.darkText,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppTheme.softMaroon,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove_shopping_cart_outlined, size: 40, color: AppTheme.primaryMaroon),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Cart is Currently Empty',
              style: TextStyle(color: AppTheme.darkText, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore our menu and add your favorite smoked BBQ meals to your cart.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.mutedText, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryMaroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('EXPLORE MENU'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemTile(CartItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Food Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 64,
            height: 64,
            color: AppTheme.softMaroon,
            child: item.imageUrl != null
                ? Image.asset(item.imageUrl!, fit: BoxFit.cover)
                : const Icon(Icons.fastfood, color: AppTheme.primaryMaroon, size: 30),
          ),
        ),
        const SizedBox(width: 14),

        // Item details & quantity
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '₱${item.price.toStringAsFixed(2)} each',
                style: const TextStyle(color: AppTheme.mutedText, fontSize: 12),
              ),
              const SizedBox(height: 8),

              // Quantity Controls
              Row(
                children: [
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.softMaroon,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderMaroon),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          icon: const Icon(Icons.remove, size: 14, color: AppTheme.primaryMaroon),
                          onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.id, -1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkText),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          icon: const Icon(Icons.add, size: 14, color: AppTheme.primaryMaroon),
                          onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.id, 1),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₱${item.total.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppTheme.primaryMaroon, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Delete button
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
          onPressed: () => ref.read(cartProvider.notifier).removeItem(item.id),
        ),
      ],
    );
  }
}
