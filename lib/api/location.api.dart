import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vuba/response/api_response.dart';
import 'package:vuba/response/user_location_responses.dart';
import 'package:vuba/models/user.model.dart';

class LocationApi {
  static const String baseUrl = 'http://167.235.155.3:8085/api/locations';

  static Map<String, String> _getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  /// Get customer addresses (GET /api/locations/getCustomerAddresses)
  static Future<ApiResponse<CustomerAddressesResponse>> getCustomerAddresses({
    required String token,
    required String customerId,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/getCustomerAddresses',
      ).replace(queryParameters: {'customerId': customerId});

      print('🌍 Fetching addresses from: $uri');
      print('🔑 Token: ${token.substring(0, 10)}...');

      final response = await http.get(uri, headers: _getHeaders(token: token));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Handle case where data might be directly an array
        final List<dynamic> addressList = data is List
            ? data
            : (data['data'] ?? []);

        final addresses = addressList
            .map(
              (addr) => SavedLocation(
                id: addr['customerAddressId']?.toString(),
                name: addr['addressType'] ?? 'Unnamed Location',
                address:
                    '${addr['areaName']}, ${addr['street']} ${addr['houseNumber']}, ${addr['cityName']}',
                lat: (addr['latitude'])?.toDouble() ?? 0.0,
                lng: (addr['longitude'])?.toDouble() ?? 0.0,
                phone: addr['localContactNumber'],
                isDefault: addr['isDefault'] ?? false,
              ),
            )
            .toList();

        print('📍 Found ${addresses.length} addresses');

        return ApiResponse<CustomerAddressesResponse>(
          success: true,
          message: 'Addresses fetched successfully',
          data: CustomerAddressesResponse(addresses: addresses),
        );
      } else {
        print('❌ Error response: $data');
        return ApiResponse<CustomerAddressesResponse>(
          success: false,
          message: data['message'] ?? 'Failed to fetch addresses',
          error: data['error'],
        );
      }
    } catch (e, stack) {
      print('❌ Exception: $e');
      print('📚 Stack trace: $stack');
      return ApiResponse<CustomerAddressesResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Save customer address (POST /api/locations)
  static Future<ApiResponse<SavedLocationResponse>> saveCustomerAddress({
    required String token,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          if (phone != null) 'phone': phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse<SavedLocationResponse>(
          success: true,
          message: data['message'],
          data: SavedLocationResponse.fromJson(data['data']),
        );
      } else {
        return ApiResponse<SavedLocationResponse>(
          success: false,
          message: data['message'] ?? 'Failed to save address',
          error: data['error'],
        );
      }
    } catch (e) {
      return ApiResponse<SavedLocationResponse>(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
