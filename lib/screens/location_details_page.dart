import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user.model.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import 'package:http/http.dart' as http;

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
  final _cityIdController = TextEditingController();
  final _deliveryStreetController = TextEditingController();
  final _areaNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _usageOptionController = TextEditingController();
  int _addressTypeInt = 0;
  bool _isDefault = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _authToken;
  String? _customerId;

  @override
  void initState() {
    super.initState();
    _loadUserToken();
    _loadCustomerId();
    _initializeFields();
  }

  Future<void> _loadUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  Future<void> _loadCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customerId = prefs.getString('customer_id');
    });
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
      _deliveryStreetController.text =
          'Street address in ${widget.selectedProvince}';
    }
  }

  @override
  void dispose() {
    _cityIdController.dispose();
    _deliveryStreetController.dispose();
    _areaNameController.dispose();
    _contactNumberController.dispose();
    _houseNumberController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _usageOptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _handleCreateOrUpdateLocation() async {
    if (!_formKey.currentState!.validate()) return;

    final token = _authToken ?? 'YOUR_AUTH_TOKEN';
    final customerId = int.tryParse(_customerId ?? '');
    final cityId = int.tryParse(_cityIdController.text);
    final street = _deliveryStreetController.text;
    final areaName = _areaNameController.text;
    final houseNumber = _houseNumberController.text;
    final localContact = _contactNumberController.text;
    final latitude = double.tryParse(_latitudeController.text);
    final longitude = double.tryParse(_longitudeController.text);
    final usageOption = _usageOptionController.text;

    if (customerId == null ||
        cityId == null ||
        latitude == null ||
        longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields correctly.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare query parameters
      final queryParams = {
        'customerId': customerId.toString(),
        'cityId': cityId.toString(),
        'street': street,
        'areaName': areaName,
        'houseNumber': houseNumber,
        'localContactNumber': localContact,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'addressType':
            _addressTypeInt == 0
                ? 'HOME'
                : _addressTypeInt == 1
                ? 'WORK'
                : 'OTHER',
        'usageOption': usageOption,
        'isDefault': _isDefault.toString(),
      };

      // Create URI
      final uri = Uri.parse(
        'http://129.151.188.8:8085/api/locations/createAddresses',
      ).replace(queryParameters: queryParams);

      // Create request
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Add image file if available
      if (_imageFile != null) {
        final imageMultipart = await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
        );
        request.files.add(imageMultipart);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🌐 Create Address Response:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Body: ${response.body}');

      if (response.statusCode == 200) {
        _showSuccessMessage('Location created successfully!');
        widget.onLocationUpdated?.call();
        Navigator.pop(context);
      } else {
        _showErrorMessage('Failed to create location. Please try again.');
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _cityIdController,
                  hintText: 'City ID',
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _deliveryStreetController,
                  hintText: 'Street',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _areaNameController,
                  hintText: 'Area Name',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _houseNumberController,
                  hintText: 'House Number',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _contactNumberController,
                  hintText: 'Local Contact Number',
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _latitudeController,
                  hintText: 'Latitude',
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _longitudeController,
                  hintText: 'Longitude',
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Address Type'),
                  value: _addressTypeInt,
                  items: [
                    DropdownMenuItem(value: 0, child: Text('HOME')),
                    DropdownMenuItem(value: 1, child: Text('WORK')),
                    DropdownMenuItem(value: 2, child: Text('OTHER')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _addressTypeInt = val ?? 0;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _usageOptionController,
                  hintText: 'Usage Option',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _isDefault,
                      onChanged: (val) {
                        setState(() {
                          _isDefault = val ?? false;
                        });
                      },
                    ),
                    const Text('Is Default'),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: Text(
                    _imageFile == null ? 'Pick Image' : 'Image Selected',
                  ),
                  onPressed: _pickImage,
                ),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.file(_imageFile!, height: 80),
                  ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Create Location',
                  onPressed: _isLoading ? null : _handleCreateOrUpdateLocation,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
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
}
