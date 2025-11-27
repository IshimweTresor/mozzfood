import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:vuba/models/order.model.dart';
import 'package:vuba/models/payment.model.dart';
import 'package:vuba/response/api_response.dart';

class OrderApi {
  static const String baseUrl = 'http://129.151.188.8:8085';

  static Map<String, String> _getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  /// Get all orders for a customer
  /// GET /api/orders/getOrdersByCustomerId/{customerId}
  static Future<ApiResponse<List<Order>>> getCustomerOrders({
    required String token,
    required int customerId,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/orders/getOrdersByCustomer/$customerId',
      );
      print('🔄 Fetching orders for customer: $customerId');

      final response = await http.get(uri, headers: _getHeaders(token: token));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final dynamic data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<Order> orders = [];
        String message = 'Orders fetched successfully';

        if (data is List) {
          orders = data.map((o) => Order.fromJson(o)).toList();
        } else if (data is Map<String, dynamic>) {
          if (data['success'] == true) {
            final ordersList = data['data'];
            if (ordersList is List) {
              orders = ordersList.map((o) => Order.fromJson(o)).toList();
            } else if (ordersList == null) {
              orders = [];
            } else {
              print('⚠️ Warning: data field is not a List: $ordersList');
              message = 'Failed to parse orders data';
            }
            message = data['message'] ?? message;
          } else {
            message = data['message'] ?? 'Failed to fetch orders';
            return ApiResponse<List<Order>>(
              success: false,
              message: message,
              error: data['error'],
            );
          }
        } else {
          print('⚠️ Warning: Unexpected response format: $data');
          message = 'Unexpected response format from server';
          return ApiResponse<List<Order>>(success: false, message: message);
        }

        print('✅ Found ${orders.length} orders');
        return ApiResponse<List<Order>>(
          success: true,
          message: message,
          data: orders,
        );
      }

      String errorMessage = 'Failed to fetch orders';
      dynamic errorDetails;
      if (data is Map<String, dynamic>) {
        errorMessage = data['message'] ?? errorMessage;
        errorDetails = data['error'];
      } else if (data is String) {
        errorMessage = data;
      }

      return ApiResponse<List<Order>>(
        success: false,
        message: errorMessage,
        error: errorDetails,
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
    required int orderId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/orders/getOrderById/$orderId');
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
    required String deliveryAddressId,
    required List<OrderItem> orderItems,
    required String deliveryAddress,
    required double subTotal,
    required double deliveryFee,
    required double discountAmount,
    required double finalAmount,
    required String paymentMethod,
    required String contactNumber,
    String? specialInstructions,
    int? promotionId,
    String? estimatedDeliveryTime,
  }) async {
    try {
      print('🔄 Creating new order');
      print('👤 Customer ID: $customerId');
      print('🏪 Restaurant ID: $restaurantId');
      print('📍 Delivery Address: $deliveryAddress');
      print('📞 Contact Number: $contactNumber');
      print('🛒 Items: ${orderItems.length}');
      print('💰 Final Amount: $finalAmount');

      // Get current date in yyyy-MM-dd format
      final now = DateTime.now();
      final orderPlacedAt =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Calculate estimated delivery (30 minutes from now)
      final estimatedDelivery = now.add(const Duration(minutes: 30));
      final estimatedDeliveryDate =
          '${estimatedDelivery.year}-${estimatedDelivery.month.toString().padLeft(2, '0')}-${estimatedDelivery.day.toString().padLeft(2, '0')}';

      final requestBody = {
        'restaurantId': restaurantId,
        'customerId': customerId,
        'deliveryAddressId': int.tryParse(deliveryAddressId) ?? 0,
        'orderStatus': 'PLACED',
        'deliveryAddress': deliveryAddress,
        'contactNumber': contactNumber,
        'paymentStatus': 'PENDING',
        'subTotal': subTotal,
        'deliveryFee': deliveryFee,
        'discountAmount': discountAmount,
        'finalAmount': finalAmount,
        'paymentMethod': paymentMethod,
        'orderPlacedAt': orderPlacedAt,
        'estimatedDelivery':
            estimatedDeliveryTime ?? estimatedDeliveryDate, // ✅ ADDED THIS
        'orderItems': orderItems
            .map(
              (item) => {
                'menuItemId': item.menuItemId,
                'quantity': item.quantity,
                if (item.specialInstructions != null &&
                    item.specialInstructions!.isNotEmpty)
                  'specialInstructions': item.specialInstructions,
                if (item.variantIds != null && item.variantIds!.isNotEmpty)
                  'variantIds': item.variantIds,
              },
            )
            .toList(),
        if (specialInstructions != null && specialInstructions.isNotEmpty)
          'specialInstructions': specialInstructions,
        if (promotionId != null && promotionId > 0) 'promotionId': promotionId,
      };

      print('📤 Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/orders/createOrder'),
        headers: _getHeaders(token: token),
        body: jsonEncode(requestBody),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final order = Order.fromJson(data);
        print('✅ Order created successfully: ${order.orderNumber}');
        return ApiResponse<Order>(
          success: true,
          message: 'Order created successfully',
          data: order,
        );
      }

      // Handle error responses
      try {
        final data = jsonDecode(response.body);
        String errorMessage = 'Failed to create order';

        if (data is Map<String, dynamic>) {
          errorMessage =
              data['message'] ??
              data['error'] ??
              'Failed to create order (${response.statusCode})';
        }

        return ApiResponse<Order>(
          success: false,
          message: errorMessage,
          error: data,
        );
      } catch (parseError) {
        return ApiResponse<Order>(
          success: false,
          message: 'Server error: ${response.statusCode}',
          error: response.body,
        );
      }
    } catch (e, stack) {
      print('❌ Error creating order: $e');
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

      if (response.statusCode == 201 || response.statusCode == 200) {
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

      if (response.statusCode == 201 || response.statusCode == 200) {
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

  /// Initiate a MoMo (mobile money) request via backend
  /// POST /api/v1/payments/momo/request
  static Future<ApiResponse<Map<String, dynamic>>> momoRequest({
    required String token,
    required String externalId,
    required String msisdn,
    required double amount,
    String? payerMessageTitle,
    String? payerMessageDescription,
  }) async {
    try {
      print('🔄 Initiating MoMo request');
      final body = {
        'externalId': externalId,
        'msisdn': msisdn,
        'amount': amount,
        if (payerMessageTitle != null) 'payerMessageTitle': payerMessageTitle,
        if (payerMessageDescription != null)
          'payerMessageDescription': payerMessageDescription,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/payments/momo/request'),
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      print('📡 MoMo request status: ${response.statusCode}');
      print('📡 MoMo request body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: data is Map && data['message'] != null
              ? data['message']
              : 'MoMo request created',
          data: data is Map<String, dynamic> ? data : {'data': data},
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: data is Map && data['message'] != null
            ? data['message']
            : 'Failed to initiate MoMo request',
        error: data is Map ? data['error'] ?? data : data,
      );
    } catch (e, stack) {
      print('❌ Error initiating MoMo request: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Check MoMo request status
  /// GET /api/v1/payments/momo/status/{id}
  static Future<ApiResponse<Map<String, dynamic>>> momoStatus({
    required String token,
    required String requestId,
  }) async {
    try {
      print('🔄 Checking MoMo status: $requestId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/payments/momo/status/$requestId'),
        headers: _getHeaders(token: token),
      );

      print('📡 MoMo status response: ${response.statusCode}');
      print('📡 MoMo status body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: data is Map && data['message'] != null
              ? data['message']
              : 'MoMo status fetched',
          data: data is Map<String, dynamic> ? data : {'data': data},
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: data is Map && data['message'] != null
            ? data['message']
            : 'Failed to fetch MoMo status',
        error: data is Map ? data['error'] ?? data : data,
      );
    } catch (e, stack) {
      print('❌ Error fetching MoMo status: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<Map<String, dynamic>>(
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
      if (transactionId != null) print('🔑 Transaction ID: $transactionId');

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
    required int orderId,
    required String status,
  }) async {
    try {
      print('🔄 Updating order status');
      print('📦 Order ID: $orderId');
      print('📊 New Status: $status');

      final response = await http.put(
        Uri.parse('$baseUrl/api/orders/updateOrderStatus/$orderId'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'orderStatus': status}),
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

  //track order
  static Future<ApiResponse<Order>> trackOrder({
    required String token,
    required int orderId,
  }) async {
    try {
      print('🔄 Tracking order: $orderId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$orderId/track'),
        headers: _getHeaders(token: token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Backend returns the order directly, not wrapped in success/data
        final order = Order.fromJson(data);
        print('✅ Order tracked successfully');
        return ApiResponse<Order>(
          success: true,
          message: 'Order tracked successfully',
          data: order,
        );
      }

      // Handle error responses
      try {
        final data = jsonDecode(response.body);
        return ApiResponse<Order>(
          success: false,
          message: data['message'] ?? 'Failed to track order',
          error: data['error'],
        );
      } catch (e) {
        return ApiResponse<Order>(
          success: false,
          message: 'Failed to track order: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      print('❌ Error tracking order: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  //cancel order
  static Future<ApiResponse<Order>> cancelOrder({
    required String token,
    required int orderId,
  }) async {
    try {
      print('🔄 Cancelling order: $orderId');

      final response = await http.post(
        Uri.parse('$baseUrl/api/orders/cancelOrder/$orderId'),
        headers: _getHeaders(token: token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Backend returns the order directly, not wrapped in success/data
        final order = Order.fromJson(data);
        print('✅ Order cancelled successfully');
        return ApiResponse<Order>(
          success: true,
          message: 'Order cancelled successfully',
          data: order,
        );
      }

      // Handle error responses
      try {
        final data = jsonDecode(response.body);
        return ApiResponse<Order>(
          success: false,
          message: data['message'] ?? 'Failed to cancel order',
          error: data['error'],
        );
      } catch (e) {
        return ApiResponse<Order>(
          success: false,
          message: 'Failed to cancel order: ${response.statusCode}',
        );
      }
    } catch (e, stack) {
      print('❌ Error cancelling order: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
