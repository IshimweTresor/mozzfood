import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vuba/response/api_response.dart';

import '../api/location.api.dart';
import '../api/order.api.dart';
import '../models/order.model.dart'; // Use your real Order model
import '../utils/colors.dart';
import '../widgets/custom_button.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _selectedTab = 'Order History';
  String _selectedStatus = 'Processing';

  List<Order> _orders = [];
  bool _isLoading = true;
  String? _defaultAddressText;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    // After build, check whether we should show an "order placed" message.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOrderPlacedFlag();
    });
  }

  // Check for a flag (either route args or SharedPreferences) indicating an order was just placed
  Future<void> _checkOrderPlacedFlag() async {
    // 1) Check route arguments (useful when navigating here with arguments)
    try {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs is Map && routeArgs['orderPlaced'] == true) {
        final id = routeArgs['orderId'];
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order ${id ?? ''} placed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _fetchOrders();
        return;
      }
    } catch (_) {}

    // 2) Check SharedPreferences flag (some flows may set this before navigation)
    try {
      final prefs = await SharedPreferences.getInstance();
      final placed = prefs.getBool('order_placed') ?? false;
      final placedId = prefs.getString('order_placed_id');
      if (placed) {
        // Clear the flag so we don't show it repeatedly
        await prefs.remove('order_placed');
        await prefs.remove('order_placed_id');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order ${placedId ?? ''} placed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _fetchOrders();
      }
    } catch (_) {}
  }

  Future<void> _fetchOrders() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final customerId = prefs.getString('customer_id');

      if (token == null || customerId == null) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to view orders')),
          );
        }
        return;
      }

      print('🔄 Fetching orders...');
      print('👤 Customer ID: $customerId');
      print('🎫 Token: ${token.substring(0, 10)}...');

      // Convert string customerId to integer
      final customerIdInt = int.tryParse(customerId);
      if (customerIdInt == null) {
        throw Exception('Invalid customer ID format');
      }

      final response = await OrderApi.getCustomerOrders(
        token: token,
        customerId: customerIdInt,
      );

      // Fetch saved addresses once and keep a default address for display
      try {
        final addrResp = await LocationApi.getCustomerAddresses(
          token: token,
          customerId: customerId,
        );
        if (addrResp.success && addrResp.data != null) {
          final list = addrResp.data!.addresses;
          if (list.isNotEmpty) {
            final defaultAddr = list.firstWhere(
              (a) => a.isDefault == true,
              orElse: () => list.first,
            );
            _defaultAddressText = defaultAddr.address;
          }
        }
      } catch (e) {
        print('⚠️ Could not fetch saved addresses: $e');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response.success && response.data != null) {
            // DEBUG: Log order statuses and ALL timestamps to help diagnose issues
            try {
              for (final o in response.data!) {
                try {
                  print(
                    '📦 Order ${o.orderId}: orderStatus="${o.orderStatus}" paymentStatus="${o.paymentStatus}"',
                  );
                  print('🕒 Order ${o.orderId} raw orderPlacedAt: ${o.orderPlacedAt}');
                  print('🕒 Order ${o.orderId} raw createdAt: ${o.createdAt}');
                  print('🕒 Order ${o.orderId} raw updatedAt: ${o.updatedAt}');
                  print('🕒 Order ${o.orderId} raw orderConfirmedAt: ${o.orderConfirmedAt}');
                  print('🕒 Order ${o.orderId} raw cancelledAt: ${o.cancelledAt}');
                  
                  // Parse and show what we're actually getting
                  if (o.updatedAt != null && o.updatedAt!.isNotEmpty) {
                    try {
                      final parsed = DateTime.parse(o.updatedAt!);
                      print('🕒 Order ${o.orderId} parsed updatedAt: $parsed (isUtc: ${parsed.isUtc})');
                      print('🕒 Current device time: ${DateTime.now()}');
                      final diff = DateTime.now().difference(parsed.toLocal());
                      print('🕒 Time difference from updatedAt: ${diff.inMinutes} minutes');
                    } catch (e) {
                      print('⚠️ Failed parsing updatedAt: $e');
                    }
                  }
                } catch (e) {
                  print(
                    '⚠️ Failed parsing timestamp for order ${o.orderId}: $e',
                  );
                }
              }
            } catch (_) {}

            // Store ALL orders without filtering - filtering happens in _getFilteredOrders()
            _orders = response.data!;

            print(
              '📦 Fetched ${_orders.length} total orders',
            );
          } else {
            print('❌ Error: ${response.message}');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(response.message)));
          }
        });
      }
    } catch (e, stack) {
      print('❌ Error loading orders: $e');
      print('📚 Stack trace: $stack');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading orders: $e')));
      }
    }
  }

  List<Order> _getFilteredOrders() {
    if (_selectedStatus == 'Processing') {
      // Show orders that are pending payment or in progress (not yet paid/delivered or cancelled)
      return _orders.where((order) {
        final status = order.orderStatus?.toUpperCase() ?? '';
        final paymentStatus = order.paymentStatus?.toUpperCase() ?? '';

        // Exclude cancelled/delivered orders first (they belong in other tabs)
        if (status == 'CANCELLED' || status == 'DELIVERED') {
          return false;
        }

        // Exclude orders with PAID payment status (they go to Completed)
        if (paymentStatus == 'PAID' || paymentStatus == 'COMPLETED' || paymentStatus == 'SUCCEEDED' || paymentStatus == 'SUCCESS') {
          return false;
        }

        // Include orders that are actively being processed with pending payment
        // This includes: PLACED, CONFIRMED, ACCEPTED, PROCESSING, PREPARING, READY, PICKED_UP, ON_THE_WAY
        return ['PENDING', 'PLACED', 'CONFIRMED', 'ACCEPTED', 'PROCESSING', 'PREPARING', 'READY', 'PICKED_UP', 'ON_THE_WAY'].contains(status) ||
            ['PENDING', 'PROCESSING'].contains(paymentStatus);
      }).toList();
    } else if (_selectedStatus == 'Completed') {
      // Show orders that are delivered OR have successful payment
      return _orders.where((order) {
        final status = order.orderStatus?.toUpperCase() ?? '';
        final paymentStatus = order.paymentStatus?.toUpperCase() ?? '';
        
        // Exclude cancelled orders
        if (status == 'CANCELLED') {
          return false;
        }
        
        // Show delivered orders OR orders with successful payment
        return status == 'DELIVERED' ||
            paymentStatus == 'PAID' ||
            paymentStatus == 'COMPLETED' ||
            paymentStatus == 'SUCCEEDED' ||
            paymentStatus == 'SUCCESS';
      }).toList();
    } else if (_selectedStatus == 'Failed') {
      // Show orders that are cancelled OR have failed payment (but not delivered/paid)
      return _orders.where((order) {
        final status = order.orderStatus?.toUpperCase() ?? '';
        final paymentStatus = order.paymentStatus?.toUpperCase() ?? '';
        
        // Show cancelled orders or failed payments (but not if delivered or paid)
        return status == 'CANCELLED' ||
            (status != 'DELIVERED' && 
             !['PAID', 'COMPLETED', 'SUCCEEDED', 'SUCCESS'].contains(paymentStatus) && (
              paymentStatus == 'FAILED' ||
              paymentStatus == 'REJECTED' ||
              paymentStatus == 'DECLINED'
            ));
      }).toList();
    }
    return _orders;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredOrders();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.popAndPushNamed(context, '/store-front');
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
                    Row(
                      children: [
                        const Text(
                          'Orders',
                          style: TextStyle(
                            color: AppColors.onBackground,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Show quick count badge for the currently filtered orders
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.inputBorder.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '${filtered.length}',
                            style: const TextStyle(
                              color: AppColors.onBackground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tab Selection (Order History / Pickup History)
            SliverToBoxAdapter(
              child: Container(
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
                            color: _selectedTab == 'Order History'
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: _selectedTab == 'Order History'
                                  ? AppColors.primary
                                  : AppColors.inputBorder,
                            ),
                          ),
                          child: Text(
                            'Order History',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedTab == 'Order History'
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
                            color: _selectedTab == 'Pickup History'
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: _selectedTab == 'Pickup History'
                                  ? AppColors.primary
                                  : AppColors.inputBorder,
                            ),
                          ),
                          child: Text(
                            'Pickup History',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedTab == 'Pickup History'
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
            ),

            // Status Filter (Processing / Completed / Failed)
            SliverToBoxAdapter(
              child: Container(
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
                            color: _selectedStatus == 'Processing'
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Processing',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedStatus == 'Processing'
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
                            color: _selectedStatus == 'Completed'
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Completed',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedStatus == 'Completed'
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
                            color: _selectedStatus == 'Failed'
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Failed',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedStatus == 'Failed'
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
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Content based on selected status and whether there are orders
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final order = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: _buildOrderCard(order),
                  );
                }, childCount: filtered.length),
              ),
            // Add bottom spacer so page content doesn't overlap footer/navigation
            SliverToBoxAdapter(
              child: SizedBox(height: kBottomNavigationBarHeight + 16),
            ),
          ],
        ),
      ),
    );
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
                        color: index % 2 == 0
                            ? AppColors.primary
                            : Colors.white,
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

  Widget _buildOrderCard(Order order) {
    double total =
        (order.subTotal ?? 0) +
        (order.deliveryFee ?? 0) -
        (order.discountAmount ?? 0);

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
                    'Order #${order.orderId ?? ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatOrderDisplay(order),
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
                  color: _getStatusColor(order).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(order),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(order),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Order Items
          ...(order.items ?? []).map((item) => _buildOrderItemRow(item)),

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
                      order.deliveryAddress ??
                          _defaultAddressText ??
                          'No address provided',
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
                    'RWF ${total.toStringAsFixed(2)}',
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
          if (order.paymentStatus?.toUpperCase() == 'PENDING' ||
              order.orderStatus?.toUpperCase() == 'PENDING' ||
              order.orderStatus?.toUpperCase() == 'PLACED') ...[
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

          if (order.orderStatus == 'delivered') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _reorder(order),
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

  Widget _buildOrderItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.fastfood, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'x${item.quantity} - ${item.menuItemId}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final nowLocal = DateTime.now();
    final diff = nowLocal.difference(date);

    final nowDateOnly = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diffDays = nowDateOnly.difference(dateOnly).inDays;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    if (diffDays == 0) {
      // Today
      if (diff.inMinutes < 1) {
        return 'Just now';
      } else if (diff.inMinutes == 1) {
        return '1 minute ago';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes} minutes ago';
      } else if (diff.inHours == 1) {
        return '1 hour ago';
      } else {
        return '${diff.inHours} hours ago';
      }
    } else if (diffDays == 1) {
      // Yesterday
      final timeStr = '${_twoDigit(date.hour)}:${_twoDigit(date.minute)}';
      return 'Yesterday, $timeStr';
    } else {
      // Older dates
      final monthStr = months[date.month - 1];
      final timeStr = '${_twoDigit(date.hour)}:${_twoDigit(date.minute)}';
      
      if (date.year == nowLocal.year) {
        return '${_twoDigit(date.day)} $monthStr, $timeStr';
      } else {
        return '${_twoDigit(date.day)} $monthStr ${date.year}, $timeStr';
      }
    }
  }

  String _formatOrderDisplay(Order order) {
    // If server sent date-only (no time) for orderPlacedAt or createdAt,
    // show only the date. Otherwise show the full formatted date/time.
    final raw = order.orderPlacedAt ?? order.createdAt ?? '';
    final hasTime = raw.contains('T') || raw.contains(':');

    final dt = _parseOrderDate(order);

    if (!hasTime) {
      // Show date-only
      final localDate = DateTime(dt.year, dt.month, dt.day);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final monthStr = months[localDate.month - 1];
      final nowLocal = DateTime.now();
      if (localDate.year == nowLocal.year) {
        return '${_twoDigit(localDate.day)} $monthStr';
      }
      return '${_twoDigit(localDate.day)} $monthStr ${localDate.year}';
    }

    // Otherwise show the usual detailed format
    return _formatDate(dt);
  }

  DateTime _parseOrderDate(Order order) {
    // Parse timestamps from backend
    // Priority: updatedAt > createdAt > orderPlacedAt
    
    DateTime? tryParse(String raw) {
      try {
        final parsed = DateTime.parse(raw);
        // Convert to local time for display
        return parsed.toLocal();
      } catch (_) {
        return null;
      }
    }

    // Try updatedAt first (most recent timestamp)
    if (order.updatedAt != null && order.updatedAt!.isNotEmpty) {
      final dt = tryParse(order.updatedAt!);
      if (dt != null) return dt;
    }

    // Then try createdAt
    if (order.createdAt != null && order.createdAt!.isNotEmpty) {
      final dt = tryParse(order.createdAt!);
      if (dt != null) return dt;
    }

    // Finally try orderPlacedAt
    if (order.orderPlacedAt != null && order.orderPlacedAt!.isNotEmpty) {
      final dt = tryParse(order.orderPlacedAt!);
      if (dt != null) return dt;
    }

    // Fallback to current time if no valid timestamp
    return DateTime.now();
  }

  Color _getStatusColor(Order order) {
    final status = order.orderStatus?.toUpperCase() ?? '';
    final paymentStatus = order.paymentStatus?.toUpperCase() ?? '';

    // Cancelled orders - red
    if (status == 'CANCELLED') {
      return AppColors.error;
    }
    
    // Delivered orders or paid orders - green
    if (status == 'DELIVERED' || ['PAID', 'COMPLETED', 'SUCCEEDED', 'SUCCESS'].contains(paymentStatus)) {
      return AppColors.success;
    }
    
    // Active processing states - orange/yellow
    if (['PENDING', 'PLACED', 'CONFIRMED', 'PREPARING', 'READY', 'PICKED_UP', 'ON_THE_WAY'].contains(status)) {
      return Colors.orange;
    }
    
    // Failed payment - red
    if (['FAILED', 'REJECTED', 'DECLINED'].contains(paymentStatus)) {
      return AppColors.error;
    }
    
    return AppColors.textSecondary;
  }

  String _getStatusText(Order order) {
    final status = order.orderStatus?.toUpperCase() ?? '';
    final paymentStatus = order.paymentStatus?.toUpperCase() ?? '';

    // Show cancelled status
    if (status == 'CANCELLED') {
      return 'Cancelled';
    }
    
    // Show delivered status
    if (status == 'DELIVERED') {
      return 'Delivered';
    }
    
    // Show completed for paid orders
    if (['PAID', 'COMPLETED', 'SUCCEEDED', 'SUCCESS'].contains(paymentStatus)) {
      return 'Completed';
    }
    
    // Show specific processing statuses
    if (status == 'CONFIRMED') {
      return 'Confirmed';
    }
    if (status == 'PREPARING') {
      return 'Preparing';
    }
    if (status == 'READY') {
      return 'Ready';
    }
    if (status == 'PICKED_UP') {
      return 'Picked Up';
    }
    if (status == 'ON_THE_WAY') {
      return 'On The Way';
    }
    
    // For placed/pending orders, show payment status if relevant
    if (status == 'PLACED' || status == 'PENDING') {
      return 'Pending';
    }
    
    // Default fallback
    return order.orderStatus ?? 'Unknown';
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

  Future<void> _trackOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to track orders')),
        );
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FutureBuilder<ApiResponse<Order>>(
        future: OrderApi.trackOrder(token: token, orderId: order.orderId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          } else if (snapshot.hasError) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Failed to track order: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.success != true) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  snapshot.data?.message ?? 'Failed to track order',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            );
          } else {
            final trackedOrder = snapshot.data!.data!;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Track Order #${trackedOrder.orderNumber ?? trackedOrder.orderId}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Current Status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Status',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                trackedOrder.currentStatus ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Estimated Time
                  if (trackedOrder.estimatedMinutesRemaining != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Estimated delivery: ${trackedOrder.estimatedMinutesRemaining} minutes',
                            style: const TextStyle(
                              color: AppColors.onBackground,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Status History
                  if (trackedOrder.statusHistory != null &&
                      trackedOrder.statusHistory!.isNotEmpty) ...[
                    const Text(
                      'Order Timeline',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...trackedOrder.statusHistory!.map(
                      (status) => _buildTrackStep(
                        status,
                        trackedOrder.currentStatus?.toUpperCase() ==
                            status.status?.toUpperCase(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTrackStep(OrderStatusHistory step, bool isCurrent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isCurrent
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: isCurrent ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.status ?? '',
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: AppColors.onBackground,
                  ),
                ),
                if (step.message != null)
                  Text(
                    step.message!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (step.timestamp != null)
                  Builder(
                    builder: (context) {
                      var ts = step.timestamp!;
                      try {
                        final raw = step.timestamp!;
                        final hasTime = raw.contains('T') || raw.contains(':');
                        final parsed = DateTime.parse(raw).toLocal();
                        if (!hasTime) {
                          const months = [
                            'Jan',
                            'Feb',
                            'Mar',
                            'Apr',
                            'May',
                            'Jun',
                            'Jul',
                            'Aug',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dec',
                          ];
                          final monthStr = months[parsed.month - 1];
                          final now = DateTime.now();
                          if (parsed.year == now.year) {
                            ts = '${_twoDigit(parsed.day)} $monthStr';
                          } else {
                            ts =
                                '${_twoDigit(parsed.day)} $monthStr ${parsed.year}';
                          }
                        } else {
                          ts =
                              '${parsed.year}-${_twoDigit(parsed.month)}-${_twoDigit(parsed.day)} ${_twoDigit(parsed.hour)}:${_twoDigit(parsed.minute)} SAST';
                        }
                      } catch (_) {}
                      return Text(
                        ts,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _twoDigit(int n) => n.toString().padLeft(2, '0');

  Future<void> _reorder(Order order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to reorder')),
          );
        }
        return;
      }

      // Create a new order with the same items
      final customerId = int.tryParse(order.customerId.toString());
      if (customerId == null) {
        throw Exception('Invalid customer ID format');
      }

      final response = await OrderApi.createOrder(
        token: token,
        customerId: customerId,
        restaurantId: order.restaurantId!,
        deliveryAddressId: order.deliveryAddress!,
        orderItems: order.items!,
        deliveryAddress: order.deliveryAddress!,
        subTotal: order.subTotal!,
        deliveryFee: order.deliveryFee!,
        discountAmount: order.discountAmount!,
        finalAmount: order.finalAmount!,
        paymentMethod: order.paymentMethod!,
        specialInstructions: order.specialInstructions!,
        promotionId: order.discountAmount! > 0 ? 1 : null,
        contactNumber: order.contactNumber!,
      );

      if (mounted) {
        if (response.success && response.data != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the orders list
          _fetchOrders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to cancel orders')),
        );
      }
      return;
    }

    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Cancel Order',
          style: TextStyle(color: AppColors.onBackground),
        ),
        content: const Text(
          'Are you sure you want to cancel this order?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'No',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    // Show loading snackbar
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cancelling order...')));
    }

    final response = await OrderApi.cancelOrder(
      token: token,
      orderId: order.orderId!,
    );

    if (mounted) {
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchOrders(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
