import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menuItem.model.dart';
import '../response/api_response.dart';

class MenuItemApi {
  static const String baseUrl = 'http://129.151.188.8:8085/api/menu-items';

  // Get menu items by restaurant ID
  static Future<ApiResponse<List<MenuItem>>> getMenuItemsByRestaurant(
    int restaurantId,
  ) async {
    final uri = Uri.parse('$baseUrl/getMenuItemsByRestaurant/$restaurantId');

    try {
      final response = await http.get(uri);
      final List<dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final items = data.map((item) => MenuItem.fromJson(item)).toList();
        return ApiResponse<List<MenuItem>>(
          success: true,
          message: 'Menu items fetched successfully',
          data: items,
        );
      } else {
        return ApiResponse<List<MenuItem>>(
          success: false,
          message: 'Failed to fetch menu items',
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
  static Future<ApiResponse<MenuItem>> getMenuItemById(int id) async {
    final uri = Uri.parse('$baseUrl/$id');
    try {
      final response = await http.get(uri);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Menu item fetched successfully',
          data: MenuItem.fromJson(data),
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to fetch menu item',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Network error: $e');
    }
  }
}
