import 'package:flutter_test/flutter_test.dart';
import 'package:vuba/api/vendor.api.dart';

void main() {
  test('getAllVendors returns restaurants successfully', () async {
    final response = await VendorApi.getAllVendors();

    // Print the raw response for debugging
    print('API Response:');
    print('Success: ${response.success}');
    print('Message: ${response.message}');
    print('Data count: ${response.data?.length ?? 0}');

    // Test the response structure
    expect(response.success, true);
    expect(response.data, isNotNull);
    expect(response.data, isList);

    // If we have any restaurants, verify their structure
    if (response.data != null && response.data!.isNotEmpty) {
      final firstRestaurant = response.data!.first;
      print('\nFirst Restaurant Details:');
      print('ID: ${firstRestaurant.restaurantId}');
      print('Name: ${firstRestaurant.restaurantName}');
      print('Cuisine: ${firstRestaurant.cuisineType}');
      print('Location: ${firstRestaurant.location}');
      print('Rating: ${firstRestaurant.rating}');
      print('Active: ${firstRestaurant.active}');

      // Verify required fields are present
      expect(firstRestaurant.restaurantId, isNotNull);
      expect(firstRestaurant.restaurantName, isNotNull);
      expect(firstRestaurant.location, isNotNull);
      expect(firstRestaurant.cuisineType, isNotNull);
    }
  });
}
