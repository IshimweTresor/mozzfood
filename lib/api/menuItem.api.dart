import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menuItem.model.dart';
import '../response/api_response.dart';

class MenuItemApi {
  static const String baseUrl =
      'https://food-delivery-backend-hazel.vercel.app/api/menu-items';

  // Get all menu items
  static Future<ApiResponse<List<MenuItem>>> getAllMenuItems({
    int page = 1,
    int limit = 12,
    String? category,
    String? vendorId,
    String? search,
    int? minPrice,
    int? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (category != null) 'category': category,
      if (vendorId != null) 'vendorId': vendorId,
      if (search != null) 'search': search,
      if (minPrice != null) 'minPrice': minPrice.toString(),
      if (maxPrice != null) 'maxPrice': maxPrice.toString(),
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
    };

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final items = (data['data']['menuItems'] as List)
            .map((e) => MenuItem.fromJson(e))
            .toList();
        return ApiResponse<List<MenuItem>>(
          success: true,
          message: data['message'],
          data: items,
        );
      } else {
        return ApiResponse<List<MenuItem>>(
          success: false,
          message: data['message'] ?? 'Failed to fetch menu items',
        );
      }
    } catch (e) {
      return ApiResponse<List<MenuItem>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // Get menu item by ID
  static Future<ApiResponse<MenuItem>> getMenuItemById(String id) async {
    final uri = Uri.parse('$baseUrl/$id');
    try {
      final response = await http.get(uri);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(
          success: true,
          message: data['message'],
          data: MenuItem.fromJson(data['menuItem']),
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed',
          error: data['error'],
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  // Create menu item (Vendor only, needs auth token)
  static Future<ApiResponse<MenuItem>> createMenuItem({
    required String token,
    required MenuItem menuItem,
  }) async {
    final uri = Uri.parse(baseUrl);
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(menuItem.toJson()),
      );
      final data = jsonDecode(response.body);

      if ((response.statusCode == 201 || response.statusCode == 200) &&
          data['success'] == true) {
        return ApiResponse(
          success: true,
          message: data['message'],
          data: MenuItem.fromJson(data['menuItem']),
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed',
          error: data['error'],
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  // Update menu item (Vendor/Admin, needs auth token)
  static Future<ApiResponse<MenuItem>> updateMenuItem({
    required String token,
    required String id,
    required Map<String, dynamic> updateData,
  }) async {
    final uri = Uri.parse('$baseUrl/$id');
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
        return ApiResponse(
          success: true,
          message: data['message'],
          data: MenuItem.fromJson(data['menuItem']),
        );
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed',
          error: data['error'],
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  // Delete menu item (Vendor/Admin, needs auth token)
  static Future<ApiResponse<void>> deleteMenuItem({
    required String token,
    required String id,
  }) async {
    final uri = Uri.parse('$baseUrl/$id');
    try {
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse(success: true, message: data['message']);
      } else {
        return ApiResponse(
          success: false,
          message: data['message'] ?? 'Failed',
          error: data['error'],
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }

  // Get other menu items from the same vendor
  static Future<ApiResponse<List<MenuItem>>> getOtherMenuItemsOfVendor(
    String menuItemId,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/$menuItemId/others');
      final response = await http.get(uri);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final items = (data['items'] as List)
            .map((e) => MenuItem.fromJson(e))
            .toList();
        return ApiResponse<List<MenuItem>>(
          success: true,
          message: data['message'],
          data: items,
        );
      } else {
        return ApiResponse<List<MenuItem>>(
          success: false,
          message: data['message'] ?? 'Failed to fetch other menu items',
        );
      }
    } catch (e) {
      return ApiResponse<List<MenuItem>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
}
