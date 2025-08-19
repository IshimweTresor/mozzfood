import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _deliveryStreetController =
      TextEditingController();
  final TextEditingController _areaNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();

  String _selectedUsage = 'Permanent';

  @override
  void initState() {
    super.initState();
    // Set default values
    _deliveryStreetController.text =
        'KABC Building, 1st Floor, KN 5 Rd, Kigali, Rwanda';
    _areaNameController.text = 'KN 5 Rd';
    _contactNumberController.text = '250784107365';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _deliveryStreetController.dispose();
    _areaNameController.dispose();
    _contactNumberController.dispose();
    _houseNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with Search
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Back Button and Title Row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.inputBorder.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.onBackground,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Pick Delivery location',
                          style: TextStyle(
                            color: AppColors.onBackground,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 40), // Balance the back button
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: AppColors.inputBorder.withOpacity(0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: AppColors.onBackground),
                      decoration: const InputDecoration(
                        hintText: 'Search Address/Location',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: Icon(
                          Icons.more_horiz,
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Map Icons Row (decorative)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMapIcon(Icons.apartment, 'United Kingdom'),
                          _buildMapIcon(Icons.camera_alt, ''),
                          _buildMapIcon(Icons.qr_code_scanner, ''),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Delivery Street
                      const Text(
                        'Delivery street',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _deliveryStreetController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter delivery street';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Area Name
                      const Text(
                        'Area name',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _areaNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter area name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Local Contact Number
                      const Text(
                        'Local contact number',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _contactNumberController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contact number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'If you don\'t have local number use: hotel, house keeper, guard etc.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // House Number
                      const Text(
                        'House number',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _houseNumberController,
                        hintText: 'House number',
                      ),

                      const SizedBox(height: 20),

                      // Address Usage Option
                      const Text(
                        'Address Usage Option:',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedUsage = 'Permanent';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedUsage == 'Permanent'
                                          ? AppColors.primary
                                          : AppColors.surface,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color:
                                        _selectedUsage == 'Permanent'
                                            ? AppColors.primary
                                            : AppColors.inputBorder.withOpacity(
                                              0.3,
                                            ),
                                  ),
                                ),
                                child: Text(
                                  'Permanent',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        _selectedUsage == 'Permanent'
                                            ? Colors.white
                                            : AppColors.onBackground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedUsage = 'Temporary';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedUsage == 'Temporary'
                                          ? AppColors.primary
                                          : AppColors.surface,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color:
                                        _selectedUsage == 'Temporary'
                                            ? AppColors.primary
                                            : AppColors.inputBorder.withOpacity(
                                              0.3,
                                            ),
                                  ),
                                ),
                                child: Text(
                                  'Temporary',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        _selectedUsage == 'Temporary'
                                            ? Colors.white
                                            : AppColors.onBackground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Location Picture
                      const Text(
                        'Location Picture(Optional):',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _addLocationPicture,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.inputBorder.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Add Location Picture',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Create Button
                      CustomButton(text: 'Create', onPressed: _createAddress),

                      const SizedBox(height: 20),
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

  Widget _buildMapIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.inputBorder.withOpacity(0.3)),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.onBackground),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.inputBorder.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.inputBorder.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  void _addLocationPicture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera functionality would be implemented here'),
      ),
    );
  }

  void _createAddress() {
    if (_formKey.currentState!.validate()) {
      final newAddress = {
        'name': _areaNameController.text,
        'address': _deliveryStreetController.text,
        'phone': _contactNumberController.text,
        'houseNumber': _houseNumberController.text,
        'usage': _selectedUsage,
        'isDefault': false,
      };

      Navigator.pop(context, newAddress);
    }
  }
}
