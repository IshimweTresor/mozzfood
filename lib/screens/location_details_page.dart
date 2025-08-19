import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/user.api.dart';
import '../models/user.model.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'home_page.dart';

class LocationDetailsPage extends StatefulWidget {
  final String? selectedProvince;
  final SavedLocation? editLocation;
  final VoidCallback? onLocationUpdated;

  const LocationDetailsPage({
    super.key,
    this.selectedProvince,
    this.editLocation,
    this.onLocationUpdated,
  });

  @override
  State<LocationDetailsPage> createState() => _LocationDetailsPageState();
}

class _LocationDetailsPageState extends State<LocationDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _deliveryStreetController = TextEditingController();
  final _areaNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _houseNumberController = TextEditingController();

  String _addressUsageOption = 'Permanent';
  String? _locationImagePath;
  bool _isDefault = false;
  bool _isLoading = false;
  String? _authToken;

  // Mock coordinates for provinces (in a real app, you'd get these from a map picker)
  final Map<String, Map<String, double>> _provinceCoordinates = {
    'KIGALI': {'lat': -1.9441, 'lng': 30.0619},
    'MUSANZE': {'lat': -1.4769, 'lng': 29.6333},
    'RUBAVU': {'lat': -1.6792, 'lng': 29.2598},
    'RUSIZI': {'lat': -2.4889, 'lng': 28.9203},
  };

  @override
  void initState() {
    super.initState();
    _loadUserToken();
    _initializeFields();
  }

  Future<void> _loadUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  void _initializeFields() {
    if (widget.editLocation != null) {
      final location = widget.editLocation!;
      _deliveryStreetController.text = location.address;
      _areaNameController.text = location.name;
      _contactNumberController.text = location.phone ?? '';
      _isDefault = location.isDefault ?? false;
    }

    if (widget.selectedProvince != null) {
      _areaNameController.text = widget.selectedProvince!;
      _deliveryStreetController.text = 'Street address in ${widget.selectedProvince}';
    }
  }

  @override
  void dispose() {
    _deliveryStreetController.dispose();
    _areaNameController.dispose();
    _contactNumberController.dispose();
    _houseNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Simulate image picker - in a real app, use image_picker package
    setState(() {
      _locationImagePath = 'selected_image.jpg';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image selected successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _handleCreateOrUpdateLocation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_authToken == null) {
      _showErrorMessage('Authentication required. Please login again.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get coordinates (in a real app, you'd get these from map picker)
      double lat, lng;
      
      if (widget.selectedProvince != null) {
        final coords = _provinceCoordinates[widget.selectedProvince];
        lat = coords?['lat'] ?? -1.9441;
        lng = coords?['lng'] ?? 30.0619;
      } else {
        // Default to Kigali coordinates
        lat = -1.9441;
        lng = 30.0619;
      }

      final name = _areaNameController.text.trim();
      final address = _deliveryStreetController.text.trim();
      final phone = _contactNumberController.text.trim();

      if (widget.editLocation != null) {
        // Update existing location
        final response = await UserApi.updateUserLocation(
          token: _authToken!,
          locationId: widget.editLocation!.name, // Using name as ID for now
          name: name,
          address: address,
          lat: lat,
          lng: lng,
          phone: phone.isEmpty ? null : phone,
          isDefault: _isDefault,
        );

        if (response.success) {
          _showSuccessMessage('Location updated successfully!');
          widget.onLocationUpdated?.call();
          Navigator.pop(context);
        } else {
          _showErrorMessage(response.message);
        }
      } else {
        // Create new location
        final response = await UserApi.addUserLocation(
          token: _authToken!,
          name: name,
          address: address,
          lat: lat,
          lng: lng,
          phone: phone.isEmpty ? null : phone,
          isDefault: _isDefault,
        );

        if (response.success) {
          _showSuccessMessage('Location created successfully!');
          widget.onLocationUpdated?.call();
          
          // Navigate based on context
          if (widget.onLocationUpdated != null) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  selectedLocation: name,
                ),
              ),
            );
          }
        } else {
          _showErrorMessage(response.message);
        }
      }
    } catch (e) {
      print('❌ Error creating/updating location: $e');
      _showErrorMessage('Failed to save location. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editLocation != null;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.selectedProvince ?? 'Search Location',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            Text(
              isEditing ? 'Edit Location' : 'Pick Delivery location',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),

            const SizedBox(height: 20),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Area name
                      CustomTextField(
                        label: 'Location Name',
                        hintText: 'Enter location name',
                        controller: _areaNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Location name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Delivery street
                      CustomTextField(
                        label: 'Delivery Address',
                        hintText: 'Enter complete address',
                        controller: _deliveryStreetController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Delivery address is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Local contact number
                      CustomTextField(
                        label: 'Contact Number (Optional)',
                        hintText: 'Enter contact number',
                        controller: _contactNumberController,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "If you don't have local number use: hotel, house keeper, guard etc.",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // House number
                      CustomTextField(
                        label: 'House/Building Number (Optional)',
                        hintText: 'Building or house number',
                        controller: _houseNumberController,
                      ),

                      const SizedBox(height: 24),

                      // Set as default location
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _isDefault,
                              onChanged: (value) {
                                setState(() {
                                  _isDefault = value ?? false;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Set as default location',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.onBackground,
                                ),
                              ),
                            ),
                          ],
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
                                    _addressUsageOption = 'Permanent';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _addressUsageOption == 'Permanent'
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    'Permanent',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _addressUsageOption == 'Permanent'
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
                                    _addressUsageOption = 'Temporary';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _addressUsageOption == 'Temporary'
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    'Temporary',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _addressUsageOption == 'Temporary'
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

                      // Location Picture
                      const Text(
                        'Location Picture (Optional):',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onBackground,
                        ),
                      ),

                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.inputBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _locationImagePath != null
                                      ? 'Image selected'
                                      : 'Add Location Picture',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _locationImagePath != null
                                        ? AppColors.onBackground
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Create/Update Button
                      CustomButton(
                        text: isEditing ? 'Update Location' : 'Create Location',
                        onPressed: _isLoading ? null : _handleCreateOrUpdateLocation,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}