import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/user.api.dart';
import '../models/user.model.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import 'home_page.dart';
import 'location_details_page.dart';
import 'auth/login_page.dart';
// import '../response/user_location_responses.dart';
// import 'map_location_picker_page.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  String _selectedAddressOption = 'Always Ask';
  final String _selectedCountry = 'RWANDA';
  final String _selectedProvince = 'KIGALI';
  List<SavedLocation> _savedLocations = [];
  // Removed unused _preferences field
  bool _isLoading = true;
  String? _authToken;

  final List<String> _rwandaProvinces = [
    'KIGALI',
    'MUSANZE',
    'RUBAVU',
    'RUSIZI',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');

      if (_authToken == null) {
        _navigateToLogin();
        return;
      }

      await _fetchUserLocations();
    } catch (e) {
      print('❌ Error loading user data: $e');
      _showErrorMessage('Failed to load user data');
    }
  }

  Future<void> _fetchUserLocations() async {
    if (_authToken == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      dynamic customerIdRaw = prefs.get('customer_id');
      int? customerId;
      if (customerIdRaw is int) {
        customerId = customerIdRaw;
      } else if (customerIdRaw is String) {
        customerId = int.tryParse(customerIdRaw);
      }
      if (customerId == null) {
        _showErrorMessage('Customer ID not found.');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      print('🔍 Fetching customer addresses for customerId: $customerId');
      final response = await UserApi.getCustomerAddresses(
        token: _authToken!,
        customerId: customerId,
      );

      print('📍 API Response:');
      print('   - Success: ${response.success}');
      print('   - Message: ${response.message}');
      print('   - Data: ${response.data}');

      if (response.success && response.data != null) {
        print('📍 Locations found: ${response.data!.length}');
        setState(() {
          _savedLocations = response.data!;
        });
      } else {
        print('❌ Failed to fetch locations: ${response.message}');
        _showErrorMessage(response.message);
      }
    } catch (e) {
      print('❌ Error fetching locations: $e');
      _showErrorMessage('Failed to load locations');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePreferences() async {
    if (_authToken == null) return;

    try {
      final response = await UserApi.updateLocationPreferences(
        token: _authToken!,
        addressUsageOption: _selectedAddressOption,
        country: _selectedCountry,
        province: _selectedProvince,
      );

      if (response.success && response.data != null) {
        _showSuccessMessage('Preferences updated successfully');
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      print('❌ Error updating preferences: $e');
      _showErrorMessage('Failed to update preferences');
    }
  }

  Future<void> _deleteLocation(String locationId, int index) async {
    if (_authToken == null) return;

    // Show confirmation dialog
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    try {
      final response = await UserApi.deleteUserLocation(
        token: _authToken!,
        locationId: locationId,
      );

      if (response.success) {
        setState(() {
          _savedLocations.removeAt(index);
        });
        _showSuccessMessage('Location deleted successfully');
      } else {
        _showErrorMessage(response.message);
      }
    } catch (e) {
      print('❌ Error deleting location: $e');
      _showErrorMessage('Failed to delete location');
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Location'),
              content: const Text(
                'Are you sure you want to delete this location?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _selectLocation(SavedLocation location) {
    // Navigate to home page with selected location
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(
          selectedLocation: location.name,
          selectedLocationData: location,
        ),
      ),
    );
  }

  void _editLocation(SavedLocation location) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationDetailsPage(
          editLocation: location,
          onLocationUpdated: _fetchUserLocations,
        ),
      ),
    );
  }

  void _navigateToProvinceSelection(String province) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationDetailsPage(
          selectedProvince: province,
          onLocationUpdated: _fetchUserLocations,
        ),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _handleLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _navigateToLogin();
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you sure you want to sign out?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.buttonSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'No',
                          style: TextStyle(
                            color: AppColors.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _handleLogout();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Select Delivery location',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
            label: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error, fontSize: 16),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _fetchUserLocations,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'We ask for location upfront for clarity on delivery fees before selecting a merchant.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Address Usage Option
                    const Text(
                      'Address Usage Option:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedAddressOption = 'Remember';
                                });
                                _updatePreferences();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedAddressOption == 'Remember'
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  'Remember',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _selectedAddressOption == 'Remember'
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedAddressOption = 'Always Ask';
                                });
                                _updatePreferences();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedAddressOption == 'Always Ask'
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  'Always Ask',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        _selectedAddressOption == 'Always Ask'
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Country Selection
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.inputBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 18,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  width: 24,
                                  height: 6,
                                  color: AppColors.rwandaBlue,
                                ),
                                Positioned(
                                  top: 6,
                                  child: Container(
                                    width: 24,
                                    height: 6,
                                    color: AppColors.rwandaYellow,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    width: 24,
                                    height: 6,
                                    color: AppColors.rwandaGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedCountry,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onBackground,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Province List
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            _rwandaProvinces.length +
                            (_savedLocations.isNotEmpty ? 1 : 0) +
                            1,
                        itemBuilder: (context, index) {
                          // Add New Location Button
                          if (index == 0) {
                            return Column(
                              children: [
                                CustomButton(
                                  text: 'Add New Location',
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LocationDetailsPage(
                                              onLocationUpdated:
                                                  _fetchUserLocations,
                                            ),
                                      ),
                                    );
                                    // Refresh the list when returning from location details
                                    if (result == true) {
                                      await _fetchUserLocations();
                                    }
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          }

                          // Saved Locations Section
                          if (_savedLocations.isNotEmpty && index == 1) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Saved Locations:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onBackground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Tap on a location to access the main page',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ..._savedLocations.asMap().entries.map((entry) {
                                  int locationIndex = entry.key;
                                  SavedLocation location = entry.value;
                                  return _buildSavedLocationCard(
                                    location,
                                    locationIndex,
                                  );
                                }),
                                const SizedBox(height: 20),
                                const Text(
                                  'Or select a province:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onBackground,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          }

                          // Province List
                          final provinceIndex = _savedLocations.isNotEmpty
                              ? index - 2
                              : index - 1;
                          if (provinceIndex >= 0 &&
                              provinceIndex < _rwandaProvinces.length) {
                            return GestureDetector(
                              onTap: () => _navigateToProvinceSelection(
                                _rwandaProvinces[provinceIndex],
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.buttonSecondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _rwandaProvinces[provinceIndex],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onBackground,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSavedLocationCard(SavedLocation location, int index) {
    // Always check for null before using imageUrl
    final imageUrl = location.imageUrl ?? '';
    // ...existing code...
    return InkWell(
      onTap: () => _selectLocation(location),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.inputBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example usage: display image if available
            if (imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(),
                  ),
                ),
              ),
            // ...existing code for card...
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: location.isDefault == true
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    location.isDefault == true ? Icons.home : Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            location.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onBackground,
                            ),
                          ),
                          if (location.isDefault == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Default',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Text(
                        'Tap to access main page',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _editLocation(location),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (location.id != null && location.id!.isNotEmpty) {
                            _deleteLocation(location.id!, index);
                          } else {
                            _showErrorMessage(
                              'Cannot delete location: Invalid ID',
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.delete_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.home_outlined,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location.address,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (location.phone != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          location.phone!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
