import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:vuba/models/order.model.dart';
import 'package:vuba/models/payment.model.dart';
import 'package:vuba/response/api_response.dart';

class OrderApi {
  static const String baseUrl = 'http://167.235.155.3:8085';

  static Map<String, String> _getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  /// Get all orders for a customer
  /// GET /api/orders/getOrdersByCustomerId/{customerId}
  static Future<ApiResponse<List<Order>>> getCustomerOrders({
    required String token,
    required String customerId,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/orders/getOrdersByCustomerId/$customerId',
      );
      print('🔄 Fetching orders for customer: $customerId');

      final response = await http.get(uri, headers: _getHeaders(token: token));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final ordersList = data['data'] as List;
          final orders = ordersList.map((o) => Order.fromJson(o)).toList();

          print('✅ Found ${orders.length} orders');

          return ApiResponse<List<Order>>(
            success: true,
            message: data['message'] ?? 'Orders fetched successfully',
            data: orders,
          );
        }
      }

      return ApiResponse<List<Order>>(
        success: false,
        message: data['message'] ?? 'Failed to fetch orders',
        error: data['error'],
      );
    } catch (e, stack) {
      print('❌ Error fetching orders: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<List<Order>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get order by ID
  /// GET /api/orders/getOrderById/{id}
  static Future<ApiResponse<Order>> getOrderById({
    required String token,
    required String orderId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/orders/$orderId');
      print('🔄 Fetching order details: $orderId');

      final response = await http.get(uri, headers: _getHeaders(token: token));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final order = Order.fromJson(data['data']);
          print('✅ Order fetched successfully');
          return ApiResponse<Order>(
            success: true,
            message: data['message'] ?? 'Order fetched successfully',
            data: order,
          );
        }
      }

      return ApiResponse<Order>(
        success: false,
        message: data['message'] ?? 'Failed to fetch order',
        error: data['error'],
      );
    } catch (e, stack) {
      print('❌ Error fetching order: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Create a new order
  /// POST /api/orders/createOrder
  static Future<ApiResponse<Order>> createOrder({
    required String token,
    required int customerId,
    required int restaurantId,
    required List<OrderItem> items,
    required String deliveryAddress,
    required double latitude,
    required double longitude,
    String? specialInstructions,
  }) async {
    try {
      print('🔄 Creating new order');
      print('👤 Customer ID: $customerId');
      print('🏪 Restaurant ID: $restaurantId');
      print('📍 Delivery Address: $deliveryAddress');
      print('🗺️ Location: $latitude, $longitude');
      print('📝 Special Instructions: $specialInstructions');
      print('🛒 Items: ${items.length}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/orders/createOrder'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'customerId': customerId,
          'restaurantId': restaurantId,
          'items': items
              .map(
                (i) => {
                  'menuItemId': i.itemId.id,
                  'quantity': i.quantity,
                  'specialInstructions': i.specialInstructions,
                },
              )
              .toList(),
          'deliveryAddress': deliveryAddress,
          'location': {'latitude': latitude, 'longitude': longitude},
          if (specialInstructions != null)
            'specialInstructions': specialInstructions,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (data['success'] == true) {
          final order = Order.fromJson(data['data']);
          print('✅ Order created successfully');
          return ApiResponse<Order>(
            success: true,
            message: data['message'] ?? 'Order created successfully',
            data: order,
          );
        }
      }

      return ApiResponse<Order>(
        success: false,
        message: data['message'] ?? 'Failed to create order',
        error: data['error'],
      );
    } catch (e, stack) {
      print('❌ Error creating order: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Initiate MoMo payment for an order
  /// POST /api/payments/momo/initiate
  static Future<ApiResponse<Order>> initiateMomoPayment({
    required String token,
    required int restaurantId,
    required List<OrderItem> items,
    required String address,
    required double latitude,
    required double longitude,
    required String phone,
  }) async {
    try {
      print('🔄 Initiating MoMo payment');
      print('📱 Phone: $phone');
      print('🏪 Restaurant ID: $restaurantId');
      print('📍 Address: $address');

      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/momo/initiate'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'restaurantId': restaurantId,
          'items': items
              .map(
                (i) => {
                  'menuItemId': i.itemId.id,
                  'quantity': i.quantity,
                  'specialInstructions': i.specialInstructions,
                },
              )
              .toList(),
          'deliveryAddress': address,
          'location': {'latitude': latitude, 'longitude': longitude},
          'phone': phone,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final order = Order.fromJson(data['data']);
          final referenceId = data['referenceId'] as String?;
          print('✅ MoMo payment initiated');
          print('📱 MoMo Reference ID: $referenceId');

          return ApiResponse<Order>(
            success: true,
            message: data['message'] ?? 'Payment initiated successfully',
            data: order,
            referenceId: referenceId,
          );
        }
      }

      return ApiResponse<Order>(
        success: false,
        message: data['message'] ?? 'Failed to initiate payment',
        error: data['error'],
      );
    } catch (e, stack) {
      print('❌ Error initiating MoMo payment: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Check MoMo payment status
  /// GET /api/payments/momo/status/{referenceId}
  static Future<ApiResponse<Order>> checkMomoPaymentStatus({
    required String referenceId,
  }) async {
    try {
      print('🔄 Checking MoMo payment status');
      print('📱 Reference ID: $referenceId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/momo/status/$referenceId'),
        headers: _getHeaders(),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final order = Order.fromJson(data['data']);
          print('✅ Payment status checked successfully');
          return ApiResponse<Order>(
            success: true,
            message: data['message'] ?? 'Payment status checked successfully',
            data: order,
          );
        }
      }

      return ApiResponse<Order>(
        success: false,
        message: data['message'] ?? 'Failed to check payment status',
        error: data['error'],
      );
    } catch (e, stack) {
      print('❌ Error checking MoMo payment status: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get payment by ID
  /// GET /api/payments/getPaymentById/{id}
  static Future<ApiResponse<Payment>> getPaymentById({
    required String token,
    required String paymentId,
  }) async {
    try {
      print('🔄 Fetching payment: $paymentId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/getPaymentById/$paymentId'),
        headers: _getHeaders(token: token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final payment = Payment.fromJson(data['data']);
          print('✅ Payment fetched successfully');
          return ApiResponse<Payment>(
            success: true,
            message: data['message'] ?? 'Payment fetched successfully',
            data: payment,
          );
        }
      }

      return ApiResponse<Payment>(
        success: false,
        message: data['message'] ?? 'Failed to fetch payment',
        error: data['error'],
      );
    } catch (e, stack) {
      print('❌ Error fetching payment: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<Payment>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get payment by order ID
  /// GET /api/payments/getPaymentByOrderId/{orderId}
  static Future<ApiResponse<Payment>> getPaymentByOrderId({
    required String token,
    required String orderId,
  }) async {
    try {
      print('🔄 Fetching payment for order: $orderId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/getPaymentByOrderId/$orderId'),
        headers: _getHeaders(token: token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final payment = Payment.fromJson(data['data']);
          print('✅ Payment fetched successfully');
          return ApiResponse<Payment>(
            success: true,
            message: data['message'] ?? 'Payment fetched successfully',
            data: payment,
          );
        }
      }

      return ApiResponse<Payment>(
        success: false,
        message: data['message'] ?? 'Failed to fetch payment',
        error: data['error'],
      );
    } catch (e, stack) {
      print('❌ Error fetching payment: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<Payment>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Process a payment
  /// POST /api/payments/process
  static Future<ApiResponse<Payment>> processPayment({
    required String token,
    required String orderId,
    required String paymentMethod,
    required double amount,
    String? phone,
  }) async {
    try {
      print('🔄 Processing payment');
      print('📦 Order ID: $orderId');
      print('💳 Method: $paymentMethod');
      print('💰 Amount: $amount');
      if (phone != null) print('📱 Phone: $phone');

      final body = {
        'orderId': orderId,
        'paymentMethod': paymentMethod,
        'amount': amount,
        if (phone != null) 'phone': phone,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/process'),
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (data['success'] == true) {
          final payment = Payment.fromJson(data['data']);
          print('✅ Payment processed successfully');
          return ApiResponse<Payment>(
            success: true,
            message: data['message'] ?? 'Payment processed successfully',
            data: payment,
            referenceId: data['referenceId'],
          );
        }
      }

      return ApiResponse<Payment>(
        success: false,
        message: data['message'] ?? 'Failed to process payment',
        error: data['error'],
      );
    } catch (e, stack) {
      print('❌ Error processing payment: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<Payment>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Create a new payment
  /// POST /api/payments/create
  static Future<ApiResponse<Payment>> createPayment({
    required String token,
    required String orderId,
    required String paymentMethod,
    required double amount,
    String? phone,
  }) async {
    try {
      print('🔄 Creating payment');
      print('📦 Order ID: $orderId');
      print('💳 Method: $paymentMethod');
      print('💰 Amount: $amount');
      if (phone != null) print('📱 Phone: $phone');

      final body = {
        'orderId': orderId,
        'paymentMethod': paymentMethod,
        'amount': amount,
        if (phone != null) 'phone': phone,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/process'),
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (data['success'] == true) {
          final payment = Payment.fromJson(data['data']);
          print('✅ Payment created successfully');
          return ApiResponse<Payment>(
            success: true,
            message: data['message'] ?? 'Payment created successfully',
            data: payment,
            referenceId: data['referenceId'],
          );
        }
      }

      return ApiResponse<Payment>(
        success: false,
        message: data['message'] ?? 'Failed to create payment',
        error: data['error'],
      );
    } catch (e, stack) {
      print('❌ Error creating payment: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<Payment>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update payment status
  /// PUT /api/payments/updateStatus/{paymentId}
  static Future<ApiResponse<Payment>> updatePaymentStatus({
    required String token,
    required String paymentId,
    required String status,
    String? transactionId,
  }) async {
    try {
      print('🔄 Updating payment status');
      print('💳 Payment ID: $paymentId');
      print('📊 New Status: $status');
      if (transactionId != null) print('🔢 Transaction ID: $transactionId');

      final body = {
        'status': status,
        if (transactionId != null) 'transactionId': transactionId,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/api/payments/updateStatus/$paymentId'),
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final payment = Payment.fromJson(data['data']);
          print('✅ Payment status updated successfully');
          return ApiResponse<Payment>(
            success: true,
            message: data['message'] ?? 'Payment status updated successfully',
            data: payment,
          );
        }
      }

      return ApiResponse<Payment>(
        success: false,
        message: data['message'] ?? 'Failed to update payment status',
        error: data['error'],
      );
    } catch (e, stack) {
      print('❌ Error updating payment status: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<Payment>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get all payments for a customer
  /// GET /api/payments/customer/{customerId}
  static Future<ApiResponse<List<Payment>>> getCustomerPayments({
    required String token,
    required String customerId,
  }) async {
    try {
      print('🔄 Fetching payments for customer: $customerId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/customer/$customerId'),
        headers: _getHeaders(token: token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final paymentsList = data['data'] as List;
          final payments = paymentsList
              .map((p) => Payment.fromJson(p))
              .toList();
          print('✅ Found ${payments.length} payments');
          return ApiResponse<List<Payment>>(
            success: true,
            message: data['message'] ?? 'Payments fetched successfully',
            data: payments,
          );
        }
      }

      return ApiResponse<List<Payment>>(
        success: false,
        message: data['message'] ?? 'Failed to fetch payments',
        error: data['error'],
      );
    } catch (e, stack) {
      print('❌ Error fetching payments: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<List<Payment>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update order status
  /// PUT /api/orders/updateOrderStatus/{orderId}
  static Future<ApiResponse<Order>> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
  }) async {
    try {
      print('🔄 Updating order status');
      print('📦 Order ID: $orderId');
      print('📊 New Status: $status');

      final response = await http.put(
        Uri.parse('$baseUrl/api/orders/$orderId/status'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'status': status}),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final order = Order.fromJson(data['data']);
          print('✅ Order status updated successfully');
          return ApiResponse<Order>(
            success: true,
            message: data['message'] ?? 'Order status updated successfully',
            data: order,
          );
        }
      }

      return ApiResponse<Order>(
        success: false,
        message: data['message'] ?? 'Failed to update order status',
        error: data['error'],
      );
    } catch (e, stack) {
      print('❌ Error updating order status: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
