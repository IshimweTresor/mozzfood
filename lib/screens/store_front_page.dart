import 'package:flutter/material.dart';

import '../api/vendor.api.dart';
import '../models/vendor.model.dart';
import '../utils/colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/safe_network_image.dart';
import 'store_detail_page.dart';

class StoreFrontPage extends StatefulWidget {
  final String selectedLocationName;
  // Pass selectedLocationName from LocationSelectionPage or HomePage

  const StoreFrontPage({Key? key, required this.selectedLocationName})
    : super(key: key);

  @override
  State<StoreFrontPage> createState() => _StoreFrontPageState();
}

class _StoreFrontPageState extends State<StoreFrontPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Vendor> _allVendors = [];
  List<Vendor> _filteredVendors = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVendors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await VendorApi.getAllVendors();
      if (response.success && response.data != null) {
        setState(() {
          _allVendors = response.data!;
          _filteredVendors = _allVendors;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message.toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  void _filterVendors(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredVendors = _allVendors;
      } else {
        _filteredVendors = _allVendors.where((vendor) {
          final name = (vendor.restaurantName ?? '').toLowerCase();
          final cuisine = (vendor.cuisineType ?? '').toLowerCase();
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || cuisine.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Back button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 6.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.onBackground,
                      ),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                          return;
                        }
                        Navigator.pushReplacementNamed(
                          context,
                          '/location-selection',
                        );
                      },
                      tooltip: 'Back',
                    ),
                  ],
                ),
              ),
            ),
            // Top bar with selected location
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deliver to:',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.selectedLocationName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onBackground,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Rwanda flag icon (mocked)
                    Container(
                      width: 32,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: 32,
                            height: 12,
                            color: AppColors.ukraineBlue,
                          ),
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: 32,
                              height: 12,
                              color: AppColors.ukraineYellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Green open banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'We are Open 24/7!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Great news, Kigali! Vuba Vuba is now open 24/7, from Thursday to Sunday. From Monday to Wednesday, we stay open late until 1:00 AM. Order anytime, day or night',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterVendors,
                          decoration: InputDecoration(
                            hintText: 'Search for restaurants or cuisine',
                            border: InputBorder.none,
                            hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterVendors('');
                                    },
                                  )
                                : null,
                          ),
                          style: const TextStyle(color: AppColors.onBackground),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  _searchController.text.isEmpty
                      ? 'All Vuba Breakfast'
                      : 'Search Results',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
              ),
            ),

            // Store grid
            Builder(
              builder: (context) {
                if (_isLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                if (_errorMessage != null) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_errorMessage!),
                          TextButton(
                            onPressed: _fetchVendors,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (_filteredVendors.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No restaurants found for "${_searchController.text}"',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return StoreCard(vendor: _filteredVendors[index]);
                    }, childCount: _filteredVendors.length),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 0),
    );
  }
}

class StoreCard extends StatelessWidget {
  final Vendor vendor;
  const StoreCard({required this.vendor, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreDetailPage(vendor: vendor),
          ),
        );
      },
      child: Card(
        elevation: 4,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: (vendor.image != null && vendor.image!.isNotEmpty)
                      ? SafeNetworkImage(
                          url: vendor.image!,
                          height: 90,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : (vendor.logo != null && vendor.logo!.isNotEmpty)
                      ? SafeNetworkImage(
                          url: vendor.logo!,
                          height: 90,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 90,
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Center(
                            child: Icon(
                              Icons.store,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: vendor.active == true ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      vendor.active == true ? 'OPEN' : 'CLOSED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.restaurantName ?? 'Unnamed Restaurant',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.onBackground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        flex: 0,
                        fit: FlexFit.loose,
                        child: Text(
                          vendor.location ?? 'No location',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          vendor.cuisineType ?? 'Various Cuisine',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      if (vendor.rating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              vendor.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
