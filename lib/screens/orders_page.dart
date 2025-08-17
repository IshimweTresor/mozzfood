import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/colors.dart';
import '../widgets/custom_button.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _selectedTab = 'Order History'; // 'Order History' or 'Pickup History'
  String _selectedStatus = 'Processing'; // 'Processing', 'Completed', 'Failed'

  // Mock order data - replace with actual state management
  List<OrderItem> _orders = [
    OrderItem(
      id: 'ORD001',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'Processing',
      items: [
        OrderProduct(
          name: 'Fresh Tomatoes',
          quantity: 2,
          price: 2500,
          image: '🍅',
        ),
        OrderProduct(name: 'Bread', quantity: 1, price: 1500, image: '🍞'),
      ],
      total: 6500,
      deliveryAddress: 'Kigali, Gasabo District',
    ),
    OrderItem(
      id: 'ORD002',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Completed',
      items: [
        OrderProduct(name: 'Milk', quantity: 3, price: 1800, image: '🥛'),
        OrderProduct(name: 'Rice', quantity: 1, price: 3500, image: '🍚'),
      ],
      total: 8900,
      deliveryAddress: 'Kigali, Nyarugenge District',
    ),
    OrderItem(
      id: 'ORD003',
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Failed',
      items: [
        OrderProduct(name: 'Bananas', quantity: 5, price: 500, image: '🍌'),
      ],
      total: 3500,
      deliveryAddress: 'Kigali, Kicukiro District',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.inputBorder.withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.onBackground,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Orders',
                    style: TextStyle(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Tab Selection (Order History / Pickup History)
            Container(
              margin: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 'Order History';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              _selectedTab == 'Order History'
                                  ? AppColors.primary
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color:
                                _selectedTab == 'Order History'
                                    ? AppColors.primary
                                    : AppColors.inputBorder,
                          ),
                        ),
                        child: Text(
                          'Order History',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                _selectedTab == 'Order History'
                                    ? Colors.white
                                    : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 'Pickup History';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              _selectedTab == 'Pickup History'
                                  ? AppColors.primary
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color:
                                _selectedTab == 'Pickup History'
                                    ? AppColors.primary
                                    : AppColors.inputBorder,
                          ),
                        ),
                        child: Text(
                          'Pickup History',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                _selectedTab == 'Pickup History'
                                    ? Colors.white
                                    : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Status Filter (Processing / Completed / Failed)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStatus = 'Processing';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              _selectedStatus == 'Processing'
                                  ? AppColors.primary
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          'Processing',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                _selectedStatus == 'Processing'
                                    ? Colors.white
                                    : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStatus = 'Completed';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              _selectedStatus == 'Completed'
                                  ? AppColors.primary
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          'Completed',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                _selectedStatus == 'Completed'
                                    ? Colors.white
                                    : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStatus = 'Failed';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              _selectedStatus == 'Failed'
                                  ? AppColors.primary
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          'Failed',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                _selectedStatus == 'Failed'
                                    ? Colors.white
                                    : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Content based on selected status and whether there are orders
            Expanded(
              child:
                  _getFilteredOrders().isEmpty
                      ? _buildEmptyState()
                      : _buildOrdersList(),
            ),
          ],
        ),
      ),
    );
  }

  List<OrderItem> _getFilteredOrders() {
    return _orders.where((order) => order.status == _selectedStatus).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state illustration
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
                    left: 60 + radius * _cos(angle) - 4,
                    top: 60 + radius * _sin(angle) - 4,
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
          Text(
            _getEmptyStateTitle(),
            style: const TextStyle(
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
                Navigator.pop(context); // Go back to store front
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    final filteredOrders = _getFilteredOrders();
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(OrderItem order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(order.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(order.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Order Items
          ...order.items.map((item) => _buildOrderItemRow(item)),

          const SizedBox(height: 12),
          const Divider(color: AppColors.inputBorder),
          const SizedBox(height: 8),

          // Order Total and Address
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Address:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      order.deliveryAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'RWF ${order.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Action Buttons
          if (order.status == 'Processing') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancelOrder(order),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel Order',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _trackOrder(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Track Order',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (order.status == 'Completed') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _reorderItems(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Reorder',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(OrderProduct item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(item.image, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${item.quantity}x ${item.name}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onBackground,
              ),
            ),
          ),
          Text(
            'RWF ${(item.price * item.quantity).toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Processing':
        return Colors.orange;
      case 'Completed':
        return AppColors.success;
      case 'Failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _cancelOrder(OrderItem order) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Cancel Order',
              style: TextStyle(color: AppColors.onBackground),
            ),
            content: Text(
              'Are you sure you want to cancel order #${order.id}?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Keep Order',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    order.status = 'Failed';
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order cancelled successfully'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                },
                child: const Text(
                  'Cancel Order',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }

  void _trackOrder(OrderItem order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tracking order #${order.id}...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _reorderItems(OrderItem order) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Items added to cart'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  String _getEmptyStateTitle() {
    if (_selectedStatus == 'Processing') {
      return 'Oops! There is no Pending Order. Start\nbrowsing and place your order.';
    } else if (_selectedStatus == 'Completed') {
      return 'Oops! There is no Completed Order\nAvailable. Start browsing and place\nyour order.';
    } else {
      return 'Oops! There is no Failed. Start browsing and place\nyour order.';
    }
  }

  // Helper functions for trigonometry
  double _cos(double angle) => math.cos(angle);
  double _sin(double angle) => math.sin(angle);
}

// Data classes
class OrderItem {
  final String id;
  final DateTime date;
  String status;
  final List<OrderProduct> items;
  final double total;
  final String deliveryAddress;

  OrderItem({
    required this.id,
    required this.date,
    required this.status,
    required this.items,
    required this.total,
    required this.deliveryAddress,
  });
}

class OrderProduct {
  final String name;
  final int quantity;
  final double price;
  final String image;

  OrderProduct({
    required this.name,
    required this.quantity,
    required this.price,
    required this.image,
  });
}
