import 'package:flutter/material.dart';
import '../api/vendor.api.dart';
import '../models/vendor.model.dart';

class TestRestaurantsPage extends StatefulWidget {
  const TestRestaurantsPage({super.key});

  @override
  State<TestRestaurantsPage> createState() => _TestRestaurantsPageState();
}

class _TestRestaurantsPageState extends State<TestRestaurantsPage> {
  bool _isLoading = false;
  String _error = '';
  List<Vendor> _restaurants = [];

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await VendorApi.getAllVendors();

      if (response.success && response.data != null) {
        setState(() {
          _restaurants = response.data!;
          _isLoading = false;
        });

        // Print debug information
        print('🌟 Successfully fetched ${_restaurants.length} restaurants');
        for (final restaurant in _restaurants) {
          print('📍 Restaurant Details:');
          print('   ID: ${restaurant.restaurantId}');
          print('   Name: ${restaurant.restaurantName}');
          print('   Cuisine: ${restaurant.cuisineType}');
          print('   Location: ${restaurant.location}');
          print('   Rating: ${restaurant.rating}');
          print('   Active: ${restaurant.active}');
          print('   Phone: ${restaurant.phoneNumber}');
          print('   Email: ${restaurant.email}');
          print('   🖼️ IMAGE: ${restaurant.image}');
          print('   🏷️ LOGO: ${restaurant.logo}');
          print('   Image is empty: ${restaurant.image?.isEmpty ?? true}');
          print('   Logo is empty: ${restaurant.logo?.isEmpty ?? true}');
          print('-------------------');
        }
      } else {
        setState(() {
          _error = response.message.toString();
          _isLoading = false;
        });
        print('❌ Error: $_error');
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
      print('❌ Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Restaurants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRestaurants,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchRestaurants,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _restaurants.isEmpty
          ? const Center(child: Text('No restaurants found'))
          : ListView.builder(
              itemCount: _restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _restaurants[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      restaurant.restaurantName ?? 'Unnamed Restaurant',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cuisine: ${restaurant.cuisineType ?? 'N/A'}'),
                        Text('Location: ${restaurant.location ?? 'N/A'}'),
                        Text(
                          'Rating: ${restaurant.rating?.toStringAsFixed(1) ?? 'N/A'}',
                        ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.circle,
                      color: restaurant.active == true
                          ? Colors.green
                          : Colors.red,
                      size: 12,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
