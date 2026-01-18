import 'dart:convert';
import 'dart:core';

import 'package:http/http.dart' as http;
import 'package:vuba/models/order.model.dart';
import 'package:vuba/models/payment.model.dart';
import 'package:vuba/response/api_response.dart';

import '../utils/logger.dart';

class OrderApi {
  static const String baseUrl = 'https://delivery.apis.ivas.rw';

  static Map<String, String> _getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  // Normalize mobile numbers for MoMo requests to the backend-expected format:
  // Expected formats: 250XXXXXXXXX (international), 07XXXXXXXXX (local), +250XXXXXXXXX
  // All will be normalized to: 250XXXXXXXXX
  static String normalizeMsisdn(String msisdn) {
    var s = msisdn.trim();
    if (s.isEmpty) return s;

    // Remove any non-digit characters (spaces, +, dashes, parentheses)
    s = s.replaceAll(RegExp(r'\D'), '');

    // Remove leading international prefix expressed as 00
    if (s.startsWith('00')) s = s.substring(2);

    // If number starts with 250 (country code), keep it as is - this is the target format
    if (s.startsWith('250')) return s;

    // If user entered a local number starting with 0 (e.g. 07xxxxxxx), drop the 0 and add 250
    if (s.startsWith('0') && s.length > 1) {
      s = s.substring(1); // Remove leading 0
      return '250$s'; // Add Rwanda country code
    }

    // If looks like a 9-digit number (e.g. 784107365), prefix Rwanda code
    if (s.length == 9) return '250$s';

    // If length is reasonable (9-15 digits) return as-is
    if (s.length >= 9 && s.length <= 15) return s;

    return s; // fallback: cleaned digits
  }

  /// Very small validator to ensure we send a reasonable MSISDN to backend.
  /// Accepts: 250XXXXXXXXX (international), 07XXXXXXXXX (local), +250XXXXXXXXX
  static bool isValidMsisdn(String msisdn) {
    final s = msisdn.trim().replaceAll(RegExp(r'\D'), '');
    if (s.isEmpty) return false;

    // Accept numbers 9-15 digits (local or international)
    // After normalization, should be 12 digits (250 + 9 digits)
    return s.length >= 9 && s.length <= 15;
  }

  /// Get delivery fee for a restaurant
  /// GET /api/restaurants/{restaurantId}/delivery-fee
  static Future<ApiResponse<Map<String, dynamic>>> getDeliveryFee({
    required int restaurantId,
  }) async {
    try {
      Logger.info('🔄 Fetching delivery fee for restaurant: $restaurantId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/restaurants/$restaurantId/delivery-fee'),
      );

      Logger.info('📡 Response status: ${response.statusCode}');
      Logger.info('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: 'Delivery fee fetched successfully',
          data: data is Map<String, dynamic> ? data : {'fee': data},
        );
      }

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: data is Map<String, dynamic>
            ? (data['message'] ?? 'Failed to fetch delivery fee')
            : 'Failed to fetch delivery fee',
        error: data,
      );
    } catch (e, stack) {
      Logger.error('❌ Error fetching delivery fee: $e', e, stack);
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
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
      Logger.info('🔄 Fetching orders for customer: $customerId');

      final response = await http.get(uri, headers: _getHeaders(token: token));

      Logger.info('📡 Response status: ${response.statusCode}');
      Logger.info('📡 Response body: ${response.body}');

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
              Logger.warn('⚠️ Warning: data field is not a List: $ordersList');
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
          Logger.warn('⚠️ Warning: Unexpected response format: $data');
          message = 'Unexpected response format from server';
          return ApiResponse<List<Order>>(success: false, message: message);
        }

        Logger.info('✅ Found ${orders.length} orders');
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
      Logger.error('❌ Error fetching orders: $e', e, stack);
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
      Logger.info('🔄 Fetching order details: $orderId');

      final response = await http.get(uri, headers: _getHeaders(token: token));

      Logger.info('📡 Response status: ${response.statusCode}');
      Logger.info('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final order = Order.fromJson(data['data']);
          Logger.info('✅ Order fetched successfully');
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
      Logger.error('❌ Error fetching order: $e', e, stack);
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Create a new order (supports multi-restaurant orders)
  /// POST /api/orders/createOrder
  static Future<ApiResponse<Order>> createOrder({
    required String token,
    required int customerId,
    required int
    restaurantId, // Kept for backward compatibility, but will be ignored if restaurantOrders is provided
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
    Map<int, List<OrderItem>>?
    restaurantOrders, // NEW: Multi-restaurant support
  }) async {
    try {
      Logger.info('🔄 Creating new order');
      Logger.info('👤 Customer ID: $customerId');
      Logger.info('📍 Delivery Address: $deliveryAddress');
      Logger.info('📞 Contact Number: $contactNumber');
      Logger.info('💰 Final Amount: $finalAmount');

      // Get current datetime in ISO8601 (includes date and time)
      final now = DateTime.now();
      final orderPlacedAt = now.toIso8601String();

      // Calculate estimated delivery (30 minutes from now) and include time
      final estimatedDelivery = now.add(const Duration(minutes: 30));
      final estimatedDeliveryDate = estimatedDelivery.toIso8601String();

      final int? deliveryAddressIdNum = int.tryParse(
        deliveryAddressId,
      ); // may be null if not numeric

      // Build the request body based on whether we have multi-restaurant orders
      Map<String, dynamic> requestBody;

      if (restaurantOrders != null && restaurantOrders.isNotEmpty) {
        // Multi-restaurant order format
        Logger.info(
          '🏪 Multi-restaurant order with ${restaurantOrders.length} restaurants',
        );

        final restaurantOrdersPayload = restaurantOrders.entries.map((entry) {
          final restaurantId = entry.key;
          final items = entry.value;

          Logger.info('  - Restaurant $restaurantId: ${items.length} items');

          final orderItemsPayload = items.map((item) {
            final Map<String, dynamic> map = {
              'menuItemId': item.menuItemId,
              'quantity': item.quantity,
              'unitPrice': item.unitPrice,
              'totalPrice': item.totalPrice,
            };
            if (item.specialInstructions != null &&
                item.specialInstructions!.isNotEmpty) {
              map['specialInstructions'] = item.specialInstructions;
            }
            if (item.variantIds != null && item.variantIds!.isNotEmpty) {
              map['variantIds'] = item.variantIds;
            }
            return map;
          }).toList();

          return {
            'restaurantId': restaurantId,
            'orderItems': orderItemsPayload,
          };
        }).toList();

        requestBody = <String, dynamic>{
          'customerId': customerId,
          'deliveryAddress': deliveryAddress,
          'contactNumber': contactNumber,
          'paymentMethod': paymentMethod,
          'subTotal': subTotal,
          'deliveryFee': deliveryFee,
          'discountAmount': discountAmount,
          'finalAmount': finalAmount,
          'restaurantOrders': restaurantOrdersPayload,
        };
      } else {
        // Single restaurant order format (backward compatibility)
        Logger.info('🏪 Single restaurant order: $restaurantId');
        Logger.info('🛒 Items: ${orderItems.length}');

        final orderItemsPayload = orderItems.map((item) {
          final Map<String, dynamic> map = {
            'itemId': item.itemId,
            'menuItemId': item.menuItemId,
            'itemName': item.itemName,
            'quantity': item.quantity,
            'unitPrice': item.unitPrice,
            'totalPrice': item.totalPrice,
          };
          if (item.specialInstructions != null &&
              item.specialInstructions!.isNotEmpty) {
            map['specialInstructions'] = item.specialInstructions;
          }
          if (item.variantIds != null && item.variantIds!.isNotEmpty) {
            map['variantIds'] = item.variantIds;
          }
          return map;
        }).toList();

        requestBody = <String, dynamic>{
          'restaurantId': restaurantId,
          'customerId': customerId,
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
          'estimatedDelivery': estimatedDeliveryTime ?? estimatedDeliveryDate,
          'orderItems': orderItemsPayload,
        };
      }

      // Add optional fields
      if (deliveryAddressIdNum != null && deliveryAddressIdNum > 0) {
        requestBody['deliveryAddressId'] = deliveryAddressIdNum;
        requestBody['customerAddressId'] = deliveryAddressIdNum;
      }
      if (specialInstructions != null && specialInstructions.isNotEmpty) {
        requestBody['specialInstructions'] = specialInstructions;
      }
      if (promotionId != null && promotionId > 0) {
        requestBody['promotionId'] = promotionId;
      }

      Logger.info('📤 Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/orders/createOrder'),
        headers: _getHeaders(token: token),
        body: jsonEncode(requestBody),
      );

      Logger.info('📡 Response status: ${response.statusCode}');
      Logger.info('📡 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('🔍 DEBUG - Order response data type: ${data.runtimeType}');
        print('🔍 DEBUG - Order response data: $data');

        // Backend may return different shapes:
        // 1) The order directly as a JSON object
        // 2) { success: true, data: { ...order... }, message: '...'}
        // 3) { data: { ...order... } }
        // 4) An array of orders (for multi-restaurant)

        if (data is List && data.isNotEmpty) {
          // Multi-restaurant response - return the first order
          print('🔍 DEBUG - Response is List with ${data.length} items');
          print('🔍 DEBUG - First item: ${data[0]}');

          try {
            final order = Order.fromJson(data[0]);
            Logger.info('✅ Multi-restaurant order created successfully');
            return ApiResponse<Order>(
              success: true,
              message: 'Order created successfully',
              data: order,
            );
          } catch (e, stack) {
            Logger.error('❌ Error parsing order from list: $e', e, stack);
            return ApiResponse<Order>(
              success: false,
              message: 'Order parsing failed: ${e.toString()}',
              error: data,
            );
          }
        }

        Map<String, dynamic> orderMap;

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final d = data['data'];
          print('🔍 DEBUG - data["data"] type: ${d.runtimeType}');
          print('🔍 DEBUG - data["data"] value: $d');

          if (d is Map<String, dynamic>) {
            orderMap = d;
          } else if (d is List && d.isNotEmpty) {
            orderMap = d[0];
          } else {
            orderMap = Map<String, dynamic>.from(d ?? {});
          }
        } else if (data is Map<String, dynamic>) {
          orderMap = data;
        } else {
          orderMap = Map<String, dynamic>.from({});
        }

        print('🔍 DEBUG - Final orderMap keys: ${orderMap.keys.toList()}');
        print('🔍 DEBUG - Final orderMap: $orderMap');

        try {
          final order = Order.fromJson(orderMap);
          Logger.info('✅ Order created successfully: ${order.orderNumber}');
          return ApiResponse<Order>(
            success: true,
            message: data is Map<String, dynamic>
                ? (data['message'] ?? 'Order created successfully')
                : 'Order created successfully',
            data: order,
          );
        } catch (e, stack) {
          Logger.error('❌ Error parsing order: $e', e, stack);
          print('📚 Stack trace: $stack');
          return ApiResponse<Order>(
            success: false,
            message:
                'Order created but response parsing failed: ${e.toString()}',
            error: data,
          );
        }
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
          error: data ?? response.body,
        );
      } catch (parseError) {
        return ApiResponse<Order>(
          success: false,
          message: 'Server error: ${response.statusCode}',
          error: response.body,
        );
      }
    } catch (e, stack) {
      Logger.error('❌ Error creating order: $e', e, stack);
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
      Logger.info('🔄 Fetching payment: $paymentId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/getPaymentById/$paymentId'),
        headers: _getHeaders(token: token),
      );

      Logger.info('📡 Response status: ${response.statusCode}');
      Logger.info('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final payment = Payment.fromJson(data['data']);
          Logger.info('✅ Payment fetched successfully');
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
      Logger.error('❌ Error fetching payment: $e', e, stack);
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
      Logger.info('🔄 Fetching payment for order: $orderId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/getPaymentByOrderId/$orderId'),
        headers: _getHeaders(token: token),
      );

      Logger.info('📡 Response status: ${response.statusCode}');
      Logger.info('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final payment = Payment.fromJson(data['data']);
          Logger.info('✅ Payment fetched successfully');
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
      Logger.error('❌ Error fetching payment: $e', e, stack);
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
      Logger.info('🔄 Processing payment');
      Logger.info('📦 Order ID: $orderId');
      Logger.info('💳 Method: $paymentMethod');
      Logger.info('💰 Amount: $amount');
      if (phone != null) Logger.info('📱 Phone: $phone');

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

      Logger.info('📡 Response status: ${response.statusCode}');
      Logger.info('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (data['success'] == true) {
          final payment = Payment.fromJson(data['data']);
          Logger.info('✅ Payment processed successfully');
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
      Logger.error('❌ Error processing payment: $e', e, stack);
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
      Logger.info('🔄 Creating payment');
      Logger.info('📦 Order ID: $orderId');
      Logger.info('💳 Method: $paymentMethod');
      Logger.info('💰 Amount: $amount');
      if (phone != null) Logger.info('📱 Phone: $phone');

      final body = {
        'orderId': orderId,
        'paymentMethod': paymentMethod,
        'amount': amount,
        if (phone != null) 'phone': phone,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/payments/momo/request'),
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      Logger.info('📡 Response status: ${response.statusCode}');
      Logger.info('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (data['success'] == true) {
          final payment = Payment.fromJson(data['data']);
          Logger.info('✅ Payment created successfully');
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
      Logger.error('❌ Error creating payment: $e', e, stack);
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
    String? callback,
  }) async {
    try {
      Logger.info('🔄 Initiating MoMo request');

      final normalizedMsisdn = normalizeMsisdn(msisdn);
      if (normalizedMsisdn != msisdn) {
        Logger.info('🔁 Normalized msisdn: $msisdn -> $normalizedMsisdn');
      }

      if (!isValidMsisdn(normalizedMsisdn)) {
        Logger.warn(
          '⚠️ Warning: Unusual MSISDN format after normalization: $normalizedMsisdn',
        );
      }

      if (normalizedMsisdn.isEmpty) {
        final msg = 'Empty mobile money number provided';
        Logger.warn('⚠️ $msg');
        return ApiResponse<Map<String, dynamic>>(
          success: false,
          message: msg,
          error: null,
        );
      }

      final resolvedCallback =
          callback ?? '$baseUrl/api/v1/momo/webhook/callback';

      final resolvedPayerMessageDescription =
          payerMessageDescription ??
          payerMessageTitle ??
          'Payment for order $externalId';

      // ✅ FIXED REQUEST BODY
      // Backend expects `orderId` for MoMo initiation; we include it when available.
      final maybeOrderId = int.tryParse(externalId);

      // Send full amount with decimals, not just integer
      final amountString = amount.toStringAsFixed(2); // e.g., "101.54"

      final body = {
        'externalId': externalId,
        if (maybeOrderId != null)
          'orderId': maybeOrderId, // Send as integer, not string
        'msisdn': normalizedMsisdn,
        'amount': amountString, // Send full amount with decimals
        'currency': 'RWF',
        if (payerMessageTitle != null) 'payerMessageTitle': payerMessageTitle,
        'payerMessageDescription': resolvedPayerMessageDescription,
        'callback': resolvedCallback,
      };

      Logger.info('📤 MoMo request body: ${jsonEncode(body)}');
      print('🔍 DEBUG: ========== MOMO REQUEST DETAILS ==========');
      print('🔍 DEBUG: URL: $baseUrl/api/v1/payments/momo/request');
      print('🔍 DEBUG: msisdn: $normalizedMsisdn');
      print('🔍 DEBUG: amount: $amountString RWF (full amount with decimals)');
      print('🔍 DEBUG: currency: RWF');
      print('🔍 DEBUG: orderId included: ${maybeOrderId != null}');
      print('🔍 DEBUG: Full body: ${jsonEncode(body)}');
      print('🔍 DEBUG: ==========================================');

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/payments/momo/request'),
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      Logger.info('📡 MoMo request status: ${response.statusCode}');
      Logger.info('📡 MoMo request body: ${response.body}');

      print('🔍 DEBUG: ========== MOMO RESPONSE DETAILS ==========');
      print('🔍 DEBUG: Status Code: ${response.statusCode}');
      print('🔍 DEBUG: Response Body: ${response.body}');
      print('🔍 DEBUG: ==========================================');

      final rawBody = response.body;
      dynamic data;
      try {
        data = jsonDecode(rawBody);
      } catch (_) {
        data = rawBody;
      }

      String extractMessage(dynamic maybe) {
        if (maybe == null) return '';
        if (maybe is String) return maybe;
        try {
          return jsonEncode(maybe);
        } catch (_) {
          return maybe.toString();
        }
      }

      final respMessage = (data is Map && data.containsKey('message'))
          ? extractMessage(data['message'])
          : extractMessage(data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ DEBUG: MoMo backend returned SUCCESS');
        print('✅ DEBUG: Response data: $data');
        if (data is Map) {
          print('✅ DEBUG: Data keys: ${data.keys.toList()}');
          print('✅ DEBUG: Full data dump:');
          data.forEach((key, value) {
            print('  - $key: $value (type: ${value.runtimeType})');
          });
        }
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: respMessage.isNotEmpty
              ? respMessage
              : 'MoMo request created',
          data: data is Map<String, dynamic> ? data : {'data': data},
        );
      }

      final errMsg =
          'Failed to initiate MoMo request (status: ${response.statusCode}) - ${respMessage}';
      Logger.warn('⚠️ MoMo initiation failed: $errMsg - body: $rawBody');
      Logger.warn('⚠️ MoMo initiation failed: $errMsg');
      Logger.info('Response body: $rawBody');

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: errMsg,
        error: data,
      );
    } catch (e, stack) {
      Logger.error('❌ Error initiating MoMo request: $e', e, stack);
      Logger.error('❌ Error initiating MoMo request: $e', e, stack);
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
      Logger.info('🔄 Checking MoMo status: $requestId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/payments/momo/status/$requestId'),
        headers: _getHeaders(token: token),
      );

      Logger.info('📡 MoMo status response: ${response.statusCode}');
      Logger.info('📡 MoMo status body: ${response.body}');

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
      Logger.error('❌ Error fetching MoMo status: $e', e, stack);
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
      Logger.info('🔄 Updating payment status');
      Logger.info('💳 Payment ID: $paymentId');
      Logger.info('📊 New Status: $status');
      if (transactionId != null)
        Logger.info('🔑 Transaction ID: $transactionId');

      final body = {
        'status': status,
        if (transactionId != null) 'transactionId': transactionId,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/api/payments/updateStatus/$paymentId'),
        headers: _getHeaders(token: token),
        body: jsonEncode(body),
      );

      Logger.info('📡 Response status: ${response.statusCode}');
      Logger.info('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final payment = Payment.fromJson(data['data']);
          Logger.info('✅ Payment status updated successfully');
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
      Logger.error('❌ Error updating payment status: $e', e, stack);
      return ApiResponse<Payment>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update order payment status
  /// PUT /api/orders/{orderId}/updatePaymentStatus
  static Future<ApiResponse<Order>> updateOrderPaymentStatus({
    required String token,
    required int orderId,
    required String paymentStatus,
  }) async {
    try {
      Logger.info('🔄 Updating order payment status');
      Logger.info('📦 Order ID: $orderId');
      Logger.info('💳 Payment Status: $paymentStatus');

      final response = await http.put(
        Uri.parse('$baseUrl/api/orders/$orderId/updatePaymentStatus'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'paymentStatus': paymentStatus}),
      );

      Logger.info('📡 Response status: ${response.statusCode}');
      Logger.info('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true || data['data'] != null) {
          final order = Order.fromJson(data['data'] ?? data);
          Logger.info('✅ Order payment status updated successfully');
          return ApiResponse<Order>(
            success: true,
            message: data['message'] ?? 'Order payment status updated',
            data: order,
          );
        }
      }

      return ApiResponse<Order>(
        success: false,
        message: data['message'] ?? 'Failed to update order payment status',
        error: data['error'],
      );
    } catch (e, stack) {
      Logger.error('❌ Error updating order payment status: $e', e, stack);
      return ApiResponse<Order>(
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
      Logger.info('🔄 Fetching payments for customer: $customerId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/payments/customer/$customerId'),
        headers: _getHeaders(token: token),
      );

      Logger.info('📡 Response status: ${response.statusCode}');
      Logger.info('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final paymentsList = data['data'] as List;
          final payments = paymentsList
              .map((p) => Payment.fromJson(p))
              .toList();
          Logger.info('✅ Found ${payments.length} payments');
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
      Logger.error('❌ Error fetching payments: $e', e, stack);
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
      Logger.info('🔄 Updating order status');
      Logger.info('📦 Order ID: $orderId');
      Logger.info('📊 New Status: $status');

      final response = await http.put(
        Uri.parse('$baseUrl/api/orders/updateOrderStatus/$orderId'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'orderStatus': status}),
      );

      Logger.info('📡 Response status: ${response.statusCode}');
      Logger.info('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final order = Order.fromJson(data['data']);
          Logger.info('✅ Order status updated successfully');
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
      Logger.error('❌ Error updating order status: $e', e, stack);
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
      Logger.info('🔄 Tracking order: $orderId');

      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$orderId/track'),
        headers: _getHeaders(token: token),
      );

      Logger.info('📡 Response status: ${response.statusCode}');
      Logger.info('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Backend returns the order directly, not wrapped in success/data
        final order = Order.fromJson(data);
        Logger.info('✅ Order tracked successfully');
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
      Logger.error('❌ Error tracking order: $e', e, stack);
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
      Logger.info('🔄 Cancelling order: $orderId');

      final response = await http.post(
        Uri.parse('$baseUrl/api/orders/cancelOrder/$orderId'),
        headers: _getHeaders(token: token),
      );

      Logger.info('📡 Response status: ${response.statusCode}');
      Logger.info('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ Backend returns the order directly, not wrapped in success/data
        final order = Order.fromJson(data);
        Logger.info('✅ Order cancelled successfully');
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
      Logger.error('❌ Error cancelling order: $e', e, stack);
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
