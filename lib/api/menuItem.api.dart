import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menuItem.model.dart';
import '../response/api_response.dart';
import '../utils/logger.dart';
import '../utils/date_parser.dart';

class MenuItemApi {
  static const String baseUrl = 'https://delivery.apis.ivas.rw/api/menu-items';

  // Get menu items by restaurant ID
  static Future<ApiResponse<List<MenuItem>>> getMenuItemsByRestaurant(
    int restaurantId,
  ) async {
    final uri = Uri.parse('$baseUrl/getMenuItemsByRestaurant/$restaurantId');

    try {
      Logger.info('🔄 Fetching menu items for restaurant: $restaurantId');
      final response = await http.get(uri);

      Logger.info('📡 Menu items response status: ${response.statusCode}');
      Logger.info('📡 Menu items response body: ${response.body}');

      final List<dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final items = data.map((item) {
          // Convert item to map
          final itemMap = Map<String, dynamic>.from(item as Map);

          // Convert date arrays to ISO8601 strings using DateParser
          itemMap['createdAt'] = DateParser.toIso8601(itemMap['createdAt']);
          itemMap['updatedAt'] = DateParser.toIso8601(itemMap['updatedAt']);

          return MenuItem.fromJson(itemMap);
        }).toList();

        // Debug: Log image URLs
        Logger.info('✅ Successfully fetched ${items.length} menu items');
        for (var item in items) {
          print('📦 Menu Item: ${item.name}');
          print('   Price: ${item.price}');
          print('   Image URL: ${item.imageUrl}');
        }

        return ApiResponse<List<MenuItem>>(
          success: true,
          message: 'Menu items fetched successfully',
          data: items,
        );
      } else {
        Logger.error('❌ Failed to fetch menu items: ${response.statusCode}');
        return ApiResponse<List<MenuItem>>(
          success: false,
          message: 'Failed to fetch menu items',
        );
      }
    } catch (e, stack) {
      Logger.error('❌ Error fetching menu items: $e', e, stack);
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
