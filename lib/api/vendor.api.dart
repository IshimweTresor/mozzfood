import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vendor.model.dart';
import '../response/api_response.dart';

class VendorApi {
  static const String baseUrl =
      'https://food-delivery-backend-hazel.vercel.app/api/vendors';

  // Get all vendors (with optional filters)
static Future<ApiResponse<List<Vendor>>> getAllVendors({
    int page = 1,
    int limit = 12,
    String? search,
    bool? isOpen,
    double? lat,
    double? lng,
    double? radius,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null) 'search': search,
      if (isOpen != null) 'isOpen': isOpen.toString(),
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
      if (radius != null) 'radius': radius.toString(),
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
    };
    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);
      final data = jsonDecode(response.body);
      print('Response data: $data');
      if (response.statusCode == 200 && data['success'] == true) {
        // FIX: extract vendors from data['data']['vendors']
        final vendorsJson = data['data']?['vendors'] as List<dynamic>? ?? [];
        final vendors = vendorsJson.map((v) => Vendor.fromJson(v)).toList();
        return ApiResponse<List<Vendor>>(
          success: true,
          message: data['message'],
          data: vendors,
        );
      } else {
        return ApiResponse<List<Vendor>>(
          success: false,
          message: data['message'] ?? 'Failed to fetch vendors',
          data: [],
        );
      }
    } catch (e) {
      return ApiResponse<List<Vendor>>(
        success: false,
        message: e.toString(),
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
