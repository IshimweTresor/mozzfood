import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vendor.model.dart';
import '../response/api_response.dart';
import '../utils/logger.dart';

class VendorApi {
  static const String baseUrl = 'http://129.151.188.8:8085/api/restaurants';

  // Get all vendors (with optional filters)
  static Future<ApiResponse<List<Vendor>>> getAllVendors({
    int page = 1,
    int limit = 12,
    String? search,
    double? lat,
    double? lng,
    double? radius,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/getAllActiveRestaurants');
      Logger.info('🌐 Fetching restaurants from: $uri');

      // Add headers for standard JSON content type
      final headers = {'Content-Type': 'application/json'};
      final response = await http.get(uri, headers: headers);
      final data = jsonDecode(response.body);
      Logger.info('📡 Response data: $data');

      if (response.statusCode == 200) {
        // The API returns restaurants directly as an array
        final List<dynamic> vendorsJson = data; // data is already the array
        Logger.info('📊 Processing ${vendorsJson.length} restaurants');

        final vendors = vendorsJson
            .map(
              (v) => Vendor.fromJson({
                'restaurantId': v['restaurantId'] is String
                    ? int.parse(v['restaurantId'])
                    : v['restaurantId'],
                'restaurantName': v['restaurantName'],
                'location': v['location'],
                'cuisineType': v['cuisineType'],
                'email': v['email'],
                'phoneNumber': v['phoneNumber'],
                'description': v['description'],
                'rating': (v['rating'] ?? 0.0).toDouble(),
                'totalOrders': v['totalOrders'],
                'totalReviews': v['totalReviews'],
                'averagePreparationTime': v['averagePreparationTime'],
                'deliveryFee': v['deliveryFee']?.toDouble(),
                'minimumOrderAmount': v['minimumOrderAmount']?.toDouble(),
                'operatingHours': v['operatingHours'],
                'createdAt': v['createdAt'],
                'updatedAt': v['updatedAt'],
                'active': v['active'] ?? true,
              }),
            )
            .toList();

        return ApiResponse<List<Vendor>>(
          success: true,
          message: 'Fetched restaurants successfully',
          data: vendors,
        );
      } else {
        Logger.error('❌ Failed to fetch restaurants: ${response.statusCode}');
        return ApiResponse<List<Vendor>>(
          success: false,
          message: data['message'] ?? 'Failed to fetch restaurants',
          data: [],
        );
      }
    } catch (e) {
      Logger.error('❌ Error fetching restaurants: $e');
      return ApiResponse<List<Vendor>>(
        success: false,
        message: 'Network error: ${e.toString()}',
        data: [],
      );
    }
  }

  // Get vendor by ID
  static Future<ApiResponse<Vendor>> getVendorById(String id) async {
    final uri = Uri.parse('$baseUrl/$id');
    try {
      final response = await http.get(uri);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final vendor = Vendor.fromJson(data['vendor']);
        return ApiResponse<Vendor>(
          success: true,
          message: data['message'],
          data: vendor,
        );
      } else {
        return ApiResponse<Vendor>(
          success: false,
          message: data['message'] ?? 'Failed to fetch vendor',
        );
      }
    } catch (e) {
      return ApiResponse<Vendor>(success: false, message: 'Network error: $e');
    }
  }

  // Create vendor profile (requires auth token)
  static Future<ApiResponse<Vendor>> createVendorProfile({
    required Vendor vendor,
    required String token,
  }) async {
    final uri = Uri.parse(baseUrl);
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(vendor.toJson()),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        final createdVendor = Vendor.fromJson(data['vendor']);
        return ApiResponse<Vendor>(
          success: true,
          message: data['message'],
          data: createdVendor,
        );
      } else {
        return ApiResponse<Vendor>(
          success: false,
          message: data['message'] ?? 'Failed to create vendor',
        );
      }
    } catch (e) {
      return ApiResponse<Vendor>(success: false, message: 'Network error: $e');
    }
  }

  // Update vendor profile (requires auth token)
  static Future<ApiResponse<Vendor>> updateVendorProfile({
    required Map<String, dynamic> updateData,
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/my-profile');
    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updateData),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final updatedVendor = Vendor.fromJson(data['vendor']);
        return ApiResponse<Vendor>(
          success: true,
          message: data['message'],
          data: updatedVendor,
        );
      } else {
        return ApiResponse<Vendor>(
          success: false,
          message: data['message'] ?? 'Failed to update vendor',
        );
      }
    } catch (e) {
      return ApiResponse<Vendor>(success: false, message: 'Network error: $e');
    }
  }

  // Delete vendor profile (requires auth token)
  static Future<ApiResponse<void>> deleteVendorProfile({
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/my-profile');
    try {
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse<void>(success: true, message: data['message']);
      } else {
        return ApiResponse<void>(
          success: false,
          message: data['message'] ?? 'Failed to delete vendor',
        );
      }
    } catch (e) {
      return ApiResponse<void>(success: false, message: 'Network error: $e');
    }
  }

  // Toggle vendor open/closed status (requires auth token)
  static Future<ApiResponse<Vendor>> toggleVendorStatus({
    required String token,
  }) async {
    final uri = Uri.parse('$baseUrl/toggle-status');
    try {
      final response = await http.patch(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final vendor = Vendor.fromJson(data['vendor']);
        return ApiResponse<Vendor>(
          success: true,
          message: data['message'],
          data: vendor,
        );
      } else {
        return ApiResponse<Vendor>(
          success: false,
          message: data['message'] ?? 'Failed to toggle vendor status',
        );
      }
    } catch (e) {
      return ApiResponse<Vendor>(success: false, message: 'Network error: $e');
    }
  }

  // Get nearby vendors
  static Future<ApiResponse<List<Vendor>>> getNearbyVendors({
    required double lat,
    required double lng,
    double radius = 10,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$baseUrl/nearby').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radius': radius.toString(),
        'limit': limit.toString(),
      },
    );

    try {
      final response = await http.get(uri);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final vendors = (data['data']['vendors'] as List)
            .map((e) => Vendor.fromJson(e))
            .toList();
        return ApiResponse<List<Vendor>>(
          success: true,
          message: data['message'],
          data: vendors,
        );
      } else {
        return ApiResponse<List<Vendor>>(
          success: false,
          message: data['message'] ?? 'Failed to fetch nearby vendors',
        );
      }
    } catch (e) {
      return ApiResponse<List<Vendor>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
}
