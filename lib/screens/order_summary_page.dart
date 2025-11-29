import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/order.api.dart';
import '../api/location.api.dart';
import '../utils/logger.dart';
import '../models/order.model.dart';
import '../models/user.model.dart';
import '../providers/cartproviders.dart';
import 'address_book_page.dart';
import 'payment_method_page.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/safe_network_image.dart';
import 'waiting_for_payment_page.dart';
import 'mobile_wallet_numbers_page.dart';

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
  final TextEditingController _momoController = TextEditingController();
  bool _isPlacingOrder = false;

  CartProvider get cartProvider =>
      Provider.of<CartProvider>(context, listen: false);

  List get cartItems => cartProvider.items;

  @override
  void initState() {
    super.initState();
    // Pre-fill MOMO input with the selected number so user can edit it
    _momoController.text = widget.selectedNumber;
    // No special payment initialization required here.
  }

  Future<void> _placeOrder() async {
    setState(() => _isPlacingOrder = true);

    try {
      final token = await cartProvider.getAuthToken();
      final customerId = await cartProvider.getCustomerId();

      if (token == null) throw Exception('Authentication token missing.');
      if (customerId == null) throw Exception('Customer ID is missing.');
      if (cartProvider.currentRestaurantId == null) {
        throw Exception('Restaurant ID is missing.');
      }

      // Map payment method
      String paymentMethodCode = _mapPaymentMethod(widget.paymentMethod);

      // Map cart items to OrderItem
      List<OrderItem> orderItems = cartItems.map((cartItem) {
        final id = cartItem.item.id;
        int menuItemId = 0;
        if (id is int) {
          menuItemId = id;
        } else if (id is String) {
          menuItemId = int.tryParse(id) ?? 0;
        }

        // ✅ Ensure we have valid prices
        double unitPrice = (cartItem.item.price ?? 0.0).toDouble();
        double totalPrice = unitPrice * cartItem.quantity;

        return OrderItem(
          itemId: menuItemId,
          menuItemId: menuItemId,
          itemName: cartItem.item.name ?? 'Unknown Item',
          quantity: cartItem.quantity,
          unitPrice: unitPrice,
          totalPrice: totalPrice,
          specialInstructions: cartItem.specialInstructions?.isNotEmpty == true
              ? cartItem.specialInstructions
              : null,
          variantIds: cartItem.selectedVariantIds.isNotEmpty
              ? cartItem.selectedVariantIds
              : null,
        );
      }).toList();

      // ✅ Add validation before API call
      Logger.info('🔍 Validating order data...');
      Logger.info('📦 Restaurant ID: ${cartProvider.currentRestaurantId}');
      Logger.info('👤 Customer ID: $customerId');
      Logger.info(
        '📍 Delivery Address ID: ${widget.selectedLocation?.id ?? '1'}',
      );
      Logger.info('🛒 Order Items: ${orderItems.length}');
      for (var item in orderItems) {
        Logger.info(
          '  - Item ${item.menuItemId}: ${item.itemName} x${item.quantity} = ${item.totalPrice}',
        );
      }

      // Determine delivery address: prefer the selected location; if none
      // was provided, fetch saved customer addresses and use default (or first).
      SavedLocation? chosenLocation = widget.selectedLocation;
      if (chosenLocation == null) {
        try {
          final addrResp = await LocationApi.getCustomerAddresses(
            token: token,
            customerId: customerId,
          );
          if (addrResp.success && addrResp.data != null) {
            final list = addrResp.data!.addresses;
            if (list.isNotEmpty) {
              // pick default if present, otherwise first
              final defaultAddr = list.firstWhere(
                (a) => a.isDefault == true,
                orElse: () => list.first,
              );
              chosenLocation = defaultAddr;
              Logger.info('📍 Using saved address: ${chosenLocation.address}');
            }
          }
        } catch (e) {
          Logger.warn('⚠️ Could not fetch saved addresses: $e');
        }
      }

      // Convert deliveryAddressId properly
      String addressId =
          chosenLocation?.id ?? widget.selectedLocation?.id ?? '1';
      int deliveryAddressId;
      try {
        deliveryAddressId = int.parse(addressId);
      } catch (e) {
        Logger.warn(
          '⚠️ Warning: Could not parse address ID "$addressId", using 1',
        );
        deliveryAddressId = 1;
      }

      // Call API to create order
      final orderResponse = await OrderApi.createOrder(
        token: token,
        customerId: int.parse(customerId),
        restaurantId: cartProvider.currentRestaurantId!,
        deliveryAddressId: deliveryAddressId
            .toString(), // Backend expects String
        contactNumber: widget.selectedNumber.isNotEmpty
            ? widget.selectedNumber
            : '0000000000',
        orderItems: orderItems,
        deliveryAddress:
            chosenLocation?.address ??
            widget.selectedLocation?.address ??
            'Unknown Location',
        subTotal: cartProvider.subTotal,
        deliveryFee: cartProvider.deliveryFee,
        discountAmount: cartProvider.discountAmount,
        finalAmount: cartProvider.finalAmount,
        paymentMethod: paymentMethodCode,
        specialInstructions: _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
      );

      if (!orderResponse.success || orderResponse.data == null) {
        // Show detailed error dialog so developer / backend team can inspect
        if (mounted) {
          final details = orderResponse.error ?? orderResponse.message;
          await showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Order Failed'),
              content: SingleChildScrollView(child: Text(details.toString())),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // On success: handle payment flows (MoMo requires initiating request)
      if (mounted) {
        final createdOrder = orderResponse.data!;
        String? createdOrderId =
            (createdOrder.orderId?.toString() ?? createdOrder.orderNumber);

        // If MoMo selected, initiate MoMo request via backend and navigate to waiting page
        if (widget.paymentMethod == 'MOMO by MTN') {
          try {
            final externalId =
                createdOrderId ??
                DateTime.now().millisecondsSinceEpoch.toString();

            // Allow any entered MoMo number — normalize and validate it first.
            final rawNumber = _momoController.text.trim().isNotEmpty
                ? _momoController.text.trim()
                : widget.selectedNumber.trim();
            final normalizedNumber = OrderApi.normalizeMsisdn(rawNumber);
            if (rawNumber.isEmpty ||
                !OrderApi.isValidMsisdn(normalizedNumber)) {
              if (mounted) {
                await showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Invalid Number'),
                    content: const Text(
                      'Please select or enter a valid mobile money number to receive the payment request.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );

                // Redirect the user to the numbers page so they can add/select a valid number.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MobileWalletNumbersPage(
                      paymentMethod: 'MOMO by MTN',
                      selectedLocation:
                          widget.selectedLocation ??
                          SavedLocation(lat: 0, lng: 0, name: '', address: ''),
                    ),
                  ),
                );
              }
              return;
            }

            final momoResp = await OrderApi.momoRequest(
              token: token,
              externalId: externalId,
              msisdn: normalizedNumber,
              amount: cartProvider.finalAmount,
              payerMessageTitle: 'Payment for order $externalId',
              // callback will default to the shared webhook: /api/v1/momo/webhook/callback
            );

            if (momoResp.success && momoResp.data != null) {
              final mdata = momoResp.data!;
              String? requestId;
              if (mdata['requestId'] != null) {
                requestId = mdata['requestId'].toString();
              } else if (mdata['id'] != null) {
                requestId = mdata['id'].toString();
              } else if (mdata['data'] != null && mdata['data']['id'] != null) {
                requestId = mdata['data']['id'].toString();
              }

              if (requestId != null) {
                // Navigate to waiting screen which will poll status
                final displayNumber = OrderApi.normalizeMsisdn(
                  widget.selectedNumber,
                );

                if (!mounted) return;
                // Inform the user that the payment request was sent and prompt them to accept it on their phone
                await showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: const Text('Payment Request Sent'),
                    content: SingleChildScrollView(
                      child: Text(
                        'A payment request has been sent to $displayNumber. Please accept the request on your phone to complete payment.\n\nWhen you tap OK you will be taken to the payment status screen which will confirm when the payment completes.',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WaitingForPaymentPage(
                      token: token,
                      orderId: createdOrderId ?? externalId,
                      requestId: requestId!,
                      amount: cartProvider.finalAmount,
                    ),
                  ),
                );
                return;
              }
            }

            // If we reach here, momo initiation failed — show message and continue to orders
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('MoMo request failed: ${momoResp.message}'),
                ),
              );
            }
          } catch (e) {
            Logger.error('❌ MoMo initiation error: $e', e);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('MoMo initiation error: ${e.toString()}'),
                ),
              );
            }
          }
        }

        // Save a flag to SharedPreferences so OrdersPage shows success and refreshes
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('order_placed', true);
          if (createdOrderId != null) {
            await prefs.setString('order_placed_id', createdOrderId);
          }
        } catch (e) {
          Logger.warn('⚠️ Could not write order_placed flag: $e');
        }

        // Show immediate success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Navigate to Orders screen and clear back stack so user lands on orders
        Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
        return;
      }
    } catch (e, stackTrace) {
      print('❌ Error placing order: $e');
      print('📚 Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  String _mapPaymentMethod(String methodName) {
    switch (methodName) {
      case 'MOMO by MTN':
        return 'MOMO'; // use MOMO for mobile money
      case 'Vuba Wallet':
        return 'CARD'; // adjust if backend has separate code
      case 'Visa Card':
      case 'MasterCard':
        return 'CARD';
      case 'Airtel Money':
        return 'EMOLA';
      case 'SmartCash':
        return 'CASH';
      case 'SPENN':
        return 'CASH';
      default:
        return 'CASH';
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    _momoController.dispose();
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

                    // If MOMO is selected, allow entering/editing the recipient number here
                    if (widget.paymentMethod == 'MOMO by MTN')
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mobile Money Number',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _momoController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter mobile money number',
                                hintStyle: const TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: const Color(0xFF2A2A2A),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                      child: SafeNetworkImage(
                                        url: menuItem.imageUrl!,
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
                    onTap: !_isPlacingOrder ? _placeOrder : null,
                    child: Opacity(
                      opacity: !_isPlacingOrder ? 1.0 : 0.5,
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
                                'PLACE ORDER',
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

            // Bottom Navigation Bar (reusable)
            const SizedBox(height: 8),
            // Use the shared BottomNavBar widget. Orders is index 2.
            BottomNavBar(selectedIndex: 2),
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
