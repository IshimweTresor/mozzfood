import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:vuba/models/order.model.dart';
import 'package:vuba/response/api_response.dart';

class OrderApi {
  static const String baseUrl = 'http://167.235.155.3:8085/api/orders';
  static const String momoBaseUrl =
      'http://167.235.155.3:8085/api/orders/payments';

  static Map<String, String> _getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  /// Create a new order (POST /api/orders)
  static Future<ApiResponse<Order>> createOrder({
    required String token,
    required int restaurantId,
    required List<OrderItem> items,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'restaurantId': restaurantId,
          'items': items
              .map((i) => {'itemId': i.itemId.id, 'quantity': i.quantity})
              .toList(),
          'location': {
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
          },
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return ApiResponse<Order>(
          success: true,
          message: data['message'],
          data: Order.fromJson(data['data']),
        );
      } else {
        return ApiResponse<Order>(
          success: false,
          message: data['message'] ?? 'Failed to create order',
          error: data['error'],
        );
      }
    } catch (e) {
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Initiate MoMo payment (POST /api/payments/momo-request)
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
      final response = await http.post(
        Uri.parse('$momoBaseUrl/momo-request'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          "restaurantId": restaurantId,
          "items": items
              .map((i) => {'itemId': i.itemId.id, 'quantity': i.quantity})
              .toList(),
          "location": {
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
          },
          "phone": phone,
          "currency": "EUR",
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return ApiResponse<Order>(
          success: true,
          message: data['message'],
          data: Order.fromJson(data['data']),
          referenceId: data['referenceId'],
        );
      } else {
        return ApiResponse<Order>(
          success: false,
          message: data['message'] ?? 'Failed to initiate payment',
          error: data['error'],
        );
      }
    } catch (e) {
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Check MoMo payment status and create order (GET /api/payments/momo-status/:referenceId)
  static Future<ApiResponse<Order>> checkMomoPaymentAndCreateOrder({
    required String referenceId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$momoBaseUrl/momo-status/$referenceId'),
        headers: _getHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return ApiResponse<Order>(
          success: true,
          message: data['message'],
          data: Order.fromJson(data['data']),
        );
      } else {
        return ApiResponse<Order>(
          success: false,
          message: data['message'] ?? 'Payment not completed',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Get all orders (GET /api/orders)
  static Future<ApiResponse<List<Order>>> getOrders({
    required String token,
    int page = 1,
    int limit = 10,
    String? orderStatus,
    String? paymentStatus,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (orderStatus != null) 'orderStatus': orderStatus,
        if (paymentStatus != null) 'paymentStatus': paymentStatus,
      };
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _getHeaders(token: token));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final orders = (data['data'] as List)
            .map((o) => Order.fromJson(o))
            .toList();
        return ApiResponse<List<Order>>(
          success: true,
          message: data['message'],
          data: orders,
        );
      } else {
        return ApiResponse<List<Order>>(
          success: false,
          message: data['message'] ?? 'Failed to fetch orders',
        );
      }
    } catch (e) {
      return ApiResponse<List<Order>>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Get order by ID (GET /api/orders/:id)
  static Future<ApiResponse<Order>> getOrderById({
    required String token,
    required String orderId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$orderId'),
        headers: _getHeaders(token: token),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse<Order>(
          success: true,
          message: data['message'],
          data: Order.fromJson(data['data']),
        );
      } else {
        return ApiResponse<Order>(
          success: false,
          message: data['message'] ?? 'Failed to fetch order',
        );
      }
    } catch (e) {
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Update order status (PATCH /api/orders/:id/status)
  static Future<ApiResponse<Order>> updateOrderStatus({
    required String token,
    required String orderId,
    required String orderStatus,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$orderId/status'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'status': orderStatus}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse<Order>(
          success: true,
          message: data['message'],
          data: Order.fromJson(data['data']),
        );
      } else {
        return ApiResponse<Order>(
          success: false,
          message: data['message'] ?? 'Failed to update order status',
          error: data['error'],
        );
      }
    } catch (e) {
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Cancel order (PATCH /api/orders/:id/cancel)
  static Future<ApiResponse<Order>> cancelOrder({
    required String token,
    required String orderId,
    String? reason,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$orderId/cancel'),
        headers: _getHeaders(token: token),
        body: jsonEncode({'reason': reason}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse<Order>(
          success: true,
          message: data['message'],
          data: Order.fromJson(data['data']),
        );
      } else {
        return ApiResponse<Order>(
          success: false,
          message: data['message'] ?? 'Failed to cancel order',
          error: data['error'],
        );
      }
    } catch (e) {
      return ApiResponse<Order>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
