import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'home_page.dart';

class LocationDetailsPage extends StatefulWidget {
  const LocationDetailsPage({super.key});

  @override
  State<LocationDetailsPage> createState() => _LocationDetailsPageState();
}

class _LocationDetailsPageState extends State<LocationDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _deliveryStreetController = TextEditingController(
    text: 'GJ24+CQ3, Ruhengeri, Rwanda',
  );
  final _areaNameController = TextEditingController(text: 'Ruhengeri');
  final _contactNumberController = TextEditingController(text: '250784107365');
  final _houseNumberController = TextEditingController();

  String _addressUsageOption = 'Permanent'; // 'Permanent' or 'Temporary'
  String? _locationImagePath;

  @override
  void dispose() {
    _deliveryStreetController.dispose();
    _areaNameController.dispose();
    _contactNumberController.dispose();
    _houseNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    // Simulate image picker
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

  Future<void> _handleCreateLocation() async {
    if (_formKey.currentState!.validate()) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate to home page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          Icon(Icons.search, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Search Location',
                              style: TextStyle(
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

            const Text(
              'Pick Delivery location',
              style: TextStyle(
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
                      // Delivery street
                      CustomTextField(
                        label: 'Delivery street',
                        hintText: 'Enter delivery street',
                        controller: _deliveryStreetController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Delivery street is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Area name
                      CustomTextField(
                        label: 'Area name',
                        hintText: 'Enter area name',
                        controller: _areaNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Area name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Local contact number
                      CustomTextField(
                        label: 'Local contact number',
                        hintText: 'Enter contact number',
                        controller: _contactNumberController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Contact number is required';
                          }
                          return null;
                        },
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
                        label: 'House number',
                        hintText: 'House number',
                        controller: _houseNumberController,
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
                                    color:
                                        _addressUsageOption == 'Permanent'
                                            ? AppColors.primary
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    'Permanent',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          _addressUsageOption == 'Permanent'
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
                                    color:
                                        _addressUsageOption == 'Temporary'
                                            ? AppColors.primary
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    'Temporary',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          _addressUsageOption == 'Temporary'
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
                        'Location Picture(Optional):',
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
                                    color:
                                        _locationImagePath != null
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

                      // Create Button
                      CustomButton(
                        text: 'Create',
                        onPressed: _handleCreateLocation,
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
