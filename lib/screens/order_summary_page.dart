import 'dart:async';

import 'package:flutter/material.dart';
import 'address_book_page.dart';
import 'payment_method_page.dart';
import '../api/order.api.dart';
import '../providers/cartproviders.dart';
import '../models/user.model.dart';
import '../models/order.model.dart'; // Ensure you import the correct OrderItem
import 'orders_page.dart' hide OrderItem;
import 'package:provider/provider.dart';

class OrderSummaryPage extends StatefulWidget {
  final String paymentMethod;
  final String selectedNumber;
  final SavedLocation?
  selectedLocation; // Add this if you want to pass location

  const OrderSummaryPage({
    super.key,
    required this.paymentMethod,
    required this.selectedNumber,
    this.selectedLocation,
  });

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  final TextEditingController _instructionsController = TextEditingController();
  bool _isPaymentComplete = false;
  bool _isPlacingOrder = false;
  String? _momoReferenceId;
  String? _orderId;
  bool _isLoading = false;

  CartProvider get cartProvider => Provider.of<CartProvider>(context);
  List get cartItems => cartProvider.items;

  @override
  void initState() {
    super.initState();
    if (widget.paymentMethod == 'MOMO by MTN') {
      _initiateMomoPayment();
    }
  }

  Future<void> _initiateMomoPayment() async {
    setState(() => _isLoading = true);

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final token = await cartProvider.getAuthToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token missing.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final formattedPhone = widget.selectedNumber.startsWith('0')
        ? '250${widget.selectedNumber.substring(1)}'
        : widget.selectedNumber;

    final response = await OrderApi.initiateMomoPayment(
      token: token,
      restaurantId: cartProvider.currentRestaurantId!,
      items: cartProvider.items
          .map<OrderItem>(
            (cartItem) =>
                OrderItem(itemId: cartItem.item, quantity: cartItem.quantity),
          )
          .toList(),
      address: widget.selectedLocation?.address ?? "Unknown Location",
      latitude: widget.selectedLocation?.lat ?? 0,
      longitude: widget.selectedLocation?.lng ?? 0,
      phone: formattedPhone,
    );

    setState(() => _isLoading = false);

    if (!response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message != null ? response.message! : 'Error')),
      );
      return;
    }

    // Immediately navigate to Orders page after order is created (payment pending)
    if (response.success && response.data != null) {
      print("Order created: ${response.data!.id}");
      print("MoMo Ref: ${response.referenceId}"); // 👈 now works
      final order = response.data!;
      setState(() {
        _orderId = order.id; // save order id
        _momoReferenceId = response.referenceId; // save MoMo reference
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order created. Waiting for payment approval.'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OrdersPage()),
        (route) => false,
      );
    }

    // Optionally, show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order created. Waiting for payment approval.'),
      ),
    );

    // Optionally, you can still poll for payment in the background if you want
  }

  // Future<void> _pollMomoStatus() async {
  //   if (_momoReferenceId == null) return;

  //   int attempts = 0;
  //   const int maxAttempts = 10;

  //   setState(() => _isLoading = true);

  //   while (!_isPaymentComplete && attempts < maxAttempts) {
  //     attempts++;
  //     print('⏱ Checking MoMo payment status (Attempt $attempts)...');

  //     final response = await OrderApi.checkMomoPaymentAndCreateOrder(
  //       referenceId: _momoReferenceId!,
  //     );

  //     if (response.success && response.data != null) {
  //       setState(() {
  //         _isPaymentComplete = true;
  //         _orderId = response.data!.id;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Payment successful! You can place your order.'),
  //         ),
  //       );
  //       break;
  //     } else {
  //       print(
  //         '⏳ Payment not yet completed. Status: PENDING',
  //       );
  //     }

  //     await Future.delayed(const Duration(seconds: 3));
  //   }

  //   setState(() => _isLoading = false);

  //   if (!_isPaymentComplete) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Payment not completed. Please try again.'),
  //       ),
  //     );
  //   }
  // }

  Future<void> _placeOrder() async {
    setState(() => _isPlacingOrder = true);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OrdersPage()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery Location
                    _buildSection(
                      title: 'Delivery Location',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.selectedLocation?.name ?? 'Bwiza',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.selectedLocation?.address ??
                                'KG 115 Ave, Kabuga, Rwanda',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Contact Phone: ${widget.selectedNumber}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Contact Option:',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const Text(
                            'Call Me',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                      hasChangeButton: true,
                      onChangePressed: _changeDeliveryLocation,
                    ),

                    const SizedBox(height: 20),

                    // Instructions
                    const Text(
                      'Have any instruction for the rider?',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF3A3A3A)),
                      ),
                      child: TextField(
                        controller: _instructionsController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type here...',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '0/400',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Payment Details
                    _buildSection(
                      title: 'Payment Details',
                      content: Row(
                        children: [
                          _buildPaymentMethodIcon(widget.paymentMethod),
                          const SizedBox(width: 12),
                          Text(
                            widget.paymentMethod,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      hasChangeButton: true,
                      onChangePressed: _changePaymentMethod,
                    ),

                    const SizedBox(height: 20),

                    // Order Details
                    const Text(
                      'Your Order Details',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 12),

                    // Restaurant dropdown
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cartProvider.currentRestaurantName ?? 'Select Restaurant',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Order item
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartItems[index];
                        final menuItem = cartItem.item;
                        return Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2A2A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child:
                                  (menuItem.imageUrl == null ||
                                      menuItem.imageUrl!.isEmpty)
                                  ? const Center(
                                      child: Icon(
                                        Icons.fastfood,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        menuItem.imageUrl!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menuItem.name ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    menuItem.description ?? '',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'RWF ${menuItem.price ?? 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Quantity: ${cartItem.quantity}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Place Order Button
            Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isPaymentComplete && !_isPlacingOrder
                        ? _placeOrder
                        : null,
                    child: Opacity(
                      opacity: _isPaymentComplete && !_isPlacingOrder
                          ? 1.0
                          : 0.5,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isPlacingOrder)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                const Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              const SizedBox(width: 8),
                              Text(
                                _isPaymentComplete
                                    ? 'PLACE ORDER'
                                    : (_isLoading
                                          ? 'Requesting Payment...'
                                          : 'Waiting for Payment...'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF2A2A2A),
                border: Border(
                  top: BorderSide(color: Color(0xFF3A3A3A), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(Icons.store, 'Store Front', false),
                  _buildBottomNavItem(Icons.local_offer, 'Prime', false),
                  _buildBottomNavItem(Icons.receipt_long, 'Orders', false),
                  _buildBottomNavItem(
                    Icons.shopping_cart,
                    'Cart',
                    false,
                    hasNotification: true,
                  ),
                  _buildBottomNavItem(Icons.more_horiz, 'More', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget content,
    bool hasChangeButton = false,
    VoidCallback? onChangePressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            if (hasChangeButton)
              GestureDetector(
                onTap: onChangePressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Change',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label,
    bool isSelected, {
    bool hasNotification = false,
  }) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.green : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        if (hasNotification)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: const Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _changeDeliveryLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressBookPage()),
    );
  }

  void _changePaymentMethod() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentMethodPage(
          selectedLocation:
              widget.selectedLocation ??
              SavedLocation(lat: 0, lng: 0, name: '', address: ''),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodIcon(String methodName) {
    switch (methodName) {
      case 'Vuba Wallet':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'vuba',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        );
      case 'MOMO by MTN':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC00),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'MoMo',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        );
      case 'Visa Card':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F71),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'VISA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1.0,
              ),
            ),
          ),
        );
      case 'MasterCard':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 6, backgroundColor: Color(0xFFEB001B)),
                SizedBox(width: 1),
                CircleAvatar(radius: 6, backgroundColor: Color(0xFFFF5F00)),
              ],
            ),
          ),
        );
      case 'Airtel Money':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE60012),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'airtel',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 8,
              ),
            ),
          ),
        );
      case 'SmartCash':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 20,
            ),
          ),
        );
      case 'SPENN':
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF00A651),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'SPENN',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 8,
              ),
            ),
          ),
        );
      default:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.payment, color: Colors.white, size: 20),
          ),
        );
    }
  }
}
