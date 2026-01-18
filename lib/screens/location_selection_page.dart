import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/user.api.dart';
import '../api/location.api.dart';
import '../models/user.model.dart';
import '../utils/colors.dart';
import '../utils/logger.dart';
import '../widgets/safe_network_image.dart';
import 'store_front_page.dart';
import 'location_details_page.dart';
import 'auth/login_page.dart';
import 'map_location_picker_page.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  String _selectedAddressOption = 'Always Ask';
  String _selectedCountry = 'Rwanda';
  String _selectedProvince = 'Kigali';
  List<SavedLocation> _savedLocations = [];
  // Removed unused _preferences field
  bool _isLoading = true;
  String? _authToken;
  // No dynamic country list — only direct map options are shown

  // country/province mapping removed — selection handled by map picker

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
      final customerId = prefs.get('customer_id');

      Logger.info(
        '🔐 Auth Token: ${_authToken != null ? "Present" : "Missing"}',
      );
      Logger.info('👤 Customer ID: $customerId');

      // restore locally saved country preference if available
      final saved = prefs.getString('selected_country');
      if (saved != null && saved.isNotEmpty) {
        _selectedCountry = saved;
      }

      if (_authToken == null) {
        Logger.error('❌ No auth token, redirecting to login');
        _navigateToLogin();
        return;
      }

      Logger.info('🔄 Starting to fetch user locations...');
      await _fetchUserLocations();
    } catch (e, stack) {
      Logger.error('❌ Failed to load user data: $e', e, stack);
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
      Logger.info('🔄 Fetching locations for customer: $customerId');
      final response = await UserApi.getCustomerAddresses(
        token: _authToken!,
        customerId: customerId,
      );

      Logger.info('📍 Response success: ${response.success}');
      Logger.info('📍 Response data: ${response.data?.length ?? 0} locations');

      if (response.success) {
        setState(() {
          _savedLocations = response.data ?? [];
        });
        Logger.info('✅ Loaded ${_savedLocations.length} locations');
        if (_savedLocations.isEmpty) {
          Logger.info('ℹ️ No locations found for this customer');
        }
      } else {
        Logger.error('❌ Failed to load locations: ${response.message}');
        _showErrorMessage(response.message);
        // Set empty list so UI doesn't show stale data
        setState(() {
          _savedLocations = [];
        });
      }
    } catch (e, stack) {
      Logger.error('❌ Exception loading locations: $e', e, stack);
      _showErrorMessage('Failed to load locations: ${e.toString()}');
      setState(() {
        _savedLocations = [];
      });
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
      Logger.error('❌ Error updating preferences', e);
      _showErrorMessage('Failed to update preferences');
    }
  }

  Future<void> _deleteLocation(String locationId, int index) async {
    if (_authToken == null) return;

    // Show confirmation dialog
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    try {
      final response = await LocationApi.deleteAddress(
        token: _authToken!,
        addressId: int.tryParse(locationId) ?? 0,
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
    // Navigate to store front page with selected location
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StoreFrontPage(selectedLocationName: location.name),
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
      Logger.error('❌ Error during logout', e);
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

  // Country picker and selection removed: map is opened directly from the row above.

  Future<void> _openMapForCountry(String? country) async {
    Logger.info('🗺️ Opening map for country: $country');
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPickerPage(initialCountry: country),
      ),
    );

    Logger.info('🔙 Returned from map with result: $result');

    if (result != null) {
      Logger.info('✅ Location was created, refreshing list...');
      await _fetchUserLocations();
      _showSuccessMessage('Location created successfully');
    } else {
      Logger.info('ℹ️ No location created (user cancelled or error)');
    }
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
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
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

                    // Add / Pick Location trigger — label-only. Use the
                    // popup menu to open country maps.
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
                          const Icon(
                            Icons.add_location_alt_outlined,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Pick Location on Map',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onBackground,
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Open country map',
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.textSecondary,
                            ),
                            onSelected: (value) {
                              if (value == 'rwanda') {
                                _openMapForCountry('Rwanda');
                              } else if (value == 'mozambique') {
                                _openMapForCountry('Mozambique');
                              }
                            },
                            itemBuilder: (BuildContext ctx) => [
                              const PopupMenuItem<String>(
                                value: 'rwanda',
                                child: ListTile(
                                  leading: Icon(
                                    Icons.map,
                                    color: AppColors.primary,
                                  ),
                                  title: Text('Open Rwanda Map'),
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'mozambique',
                                child: ListTile(
                                  leading: Icon(
                                    Icons.map,
                                    color: AppColors.primary,
                                  ),
                                  title: Text('Open Mozambique Map'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Show saved locations under the button
                    if (_savedLocations.isNotEmpty) ...[
                      const Text(
                        'Saved Locations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        _savedLocations.length,
                        (i) => _buildSavedLocationCard(_savedLocations[i], i),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      const Text(
                        'No saved locations yet. Use the button above to add one.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
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
                  child: SafeNetworkImage(
                    url: imageUrl,
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: Container(),
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
