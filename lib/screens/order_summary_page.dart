import 'dart:async';

import 'package:flutter/material.dart';
import 'address_book_page.dart';
import 'payment_method_page.dart';
import '../api/order.api.dart';
import '../providers/cartproviders.dart';
import '../models/user.model.dart';
import '../models/order.model.dart';
import '../models/payment.model.dart';
import 'orders_page.dart';
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
  String? _orderId;
  String? _paymentId;
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

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final token = await cartProvider.getAuthToken();
      final customerId = await cartProvider.getCustomerId();

      if (token == null) {
        throw Exception('Authentication token missing.');
      }

      if (customerId == null) {
        throw Exception('Customer ID is missing.');
      }

      if (cartProvider.currentRestaurantId == null) {
        throw Exception('Restaurant ID is missing.');
      }

      // Create the order first
      final orderResponse = await OrderApi.createOrder(
        token: token,
        customerId: int.parse(customerId),
        restaurantId: cartProvider.currentRestaurantId!,
        items: cartProvider.items
            .map(
              (cartItem) => OrderItem(
                itemId: cartItem.item,
                quantity: cartItem.quantity,
                specialInstructions: _instructionsController.text,
              ),
            )
            .toList(),
        deliveryAddress: widget.selectedLocation?.address ?? "Unknown Location",
        latitude: widget.selectedLocation?.lat ?? 0,
        longitude: widget.selectedLocation?.lng ?? 0,
        specialInstructions: _instructionsController.text,
      );

      if (!orderResponse.success || orderResponse.data == null) {
        throw Exception(orderResponse.message);
      }

      final order = orderResponse.data!;
      setState(() => _orderId = order.id);

      // Format phone number for MTN MoMo (ensure it starts with 250)
      final formattedPhone = widget.selectedNumber.startsWith('0')
          ? '250${widget.selectedNumber.substring(1)}'
          : widget.selectedNumber;

      // Create payment record
      final paymentResponse = await OrderApi.createPayment(
        token: token,
        orderId: _orderId!,
        paymentMethod: 'momo',
        amount: order.totalPrice,
        phone: formattedPhone,
      );

      if (!paymentResponse.success || paymentResponse.data == null) {
        throw Exception(paymentResponse.message);
      }

      setState(() {
        _paymentId = paymentResponse.data!.id;
        _isLoading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment request sent. Please check your phone for the MTN MOMO prompt.',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Start polling for payment status
      await _pollPaymentStatus();
    } catch (e) {
      print('❌ Error during MoMo payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pollPaymentStatus() async {
    if (_paymentId == null) return;

    int attempts = 0;
    const maxAttempts = 20; // Poll for about 1 minute
    const pollInterval = Duration(seconds: 3);

    while (attempts < maxAttempts && mounted) {
      try {
        attempts++;
        print('⏱ Checking payment status (Attempt $attempts/$maxAttempts)');

        final token = await cartProvider.getAuthToken();
        if (token == null) {
          throw Exception('Authentication token missing.');
        }

        final response = await OrderApi.getPaymentById(
          token: token,
          paymentId: _paymentId!,
        );

        if (response.success && response.data != null) {
          final payment = response.data!;
          if (payment.status.toLowerCase() == 'paid') {
            setState(() => _isPaymentComplete = true);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Payment successful! You can now place your order.',
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 5),
                ),
              );
            }
            return;
          }
        }

        await Future.delayed(pollInterval);
      } catch (e) {
        print('❌ Error checking payment status: $e');
      }
    }

    if (mounted && !_isPaymentComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment status check timed out. Please check your MTN MoMo messages or try again.',
          ),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Polling logic moved to _pollPaymentStatus() method

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
                            cartProvider.currentRestaurantName ??
                                'Select Restaurant',
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
