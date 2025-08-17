import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _cartItems = [
    // Mock data - replace with actual cart state management
    CartItem(
      id: '1',
      name: 'Fresh Tomatoes',
      price: 2500,
      quantity: 2,
      image: '🍅',
      description: 'Fresh organic tomatoes',
    ),
    CartItem(
      id: '2',
      name: 'Bread',
      price: 1500,
      quantity: 1,
      image: '🍞',
      description: 'Whole wheat bread',
    ),
    CartItem(
      id: '3',
      name: 'Milk',
      price: 1800,
      quantity: 3,
      image: '🥛',
      description: 'Fresh cow milk 1L',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final subtotal = _calculateSubtotal();
    const deliveryFee = 1000;
    final total = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Cart',
                    style: TextStyle(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  if (_cartItems.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: _showClearCartDialog,
                    ),
                ],
              ),
            ),
            Expanded(
              child:
                  _cartItems.isEmpty
                      ? _buildEmptyCart()
                      : _buildCartWithItems(),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _cartItems.isNotEmpty
              ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Order Summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal:',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'RWF ${subtotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.onBackground,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery:',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'RWF ${deliveryFee.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.onBackground,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.inputBorder),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            color: AppColors.onBackground,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'RWF ${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Proceed to Checkout',
                      onPressed: _proceedToCheckout,
                    ),
                  ],
                ),
              )
              : null,
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty cart illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main circle (sad face)
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('😞', style: TextStyle(fontSize: 40)),
                  ),
                ),
                // Small decorative elements
                ...List.generate(6, (index) {
                  final angle = (index * 60) * (3.14159 / 180);
                  final radius = 50.0;
                  return Positioned(
                    left: 60 + radius * math.cos(angle) - 4,
                    top: 60 + radius * math.sin(angle) - 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            index % 2 == 0 ? AppColors.primary : Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Oops! No orders yet. Start browsing and\nplace your order.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse our menu, place an order, and your favorites\nwill show up here!',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: CustomButton(
              text: 'Start Shopping',
              onPressed: () {
                Navigator.pushNamed(context, '/store-front');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartWithItems() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return _buildCartItem(item, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(item.image, style: const TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(width: 12),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'RWF ${item.price}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // Quantity Controls
          Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _decreaseQuantity(index),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: const Icon(
                        Icons.remove,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackground,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _increaseQuantity(index),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _removeItem(index),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _increaseQuantity(int index) {
    setState(() {
      _cartItems[index].quantity++;
    });
  }

  void _decreaseQuantity(int index) {
    if (_cartItems[index].quantity > 1) {
      setState(() {
        _cartItems[index].quantity--;
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from cart'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Clear Cart',
              style: TextStyle(color: AppColors.onBackground),
            ),
            content: const Text(
              'Are you sure you want to remove all items from your cart?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _cartItems.clear();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cart cleared'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }

  void _proceedToCheckout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Order Placed!',
              style: TextStyle(color: AppColors.onBackground),
            ),
            content: const Text(
              'Your order has been placed successfully and will be delivered soon.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/orders');
                },
                child: const Text('View Orders'),
              ),
            ],
          ),
    );
  }

  double _calculateSubtotal() {
    return _cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
  }
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final String description;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.quantity,
  });
}
