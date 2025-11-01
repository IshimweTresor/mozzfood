import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import 'package:http/http.dart' as http;

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _cityIdController = TextEditingController();
  final TextEditingController _deliveryStreetController =
      TextEditingController();
  final TextEditingController _areaNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _usageOptionController = TextEditingController();
  int _addressTypeInt = 0;
  bool _isDefault = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _customerIdController.dispose();
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

  void _addLocationPicture() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _createAddress() async {
    if (_formKey.currentState!.validate()) {
      final customerId = int.tryParse(_customerIdController.text);
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
      final queryParams = {
        'customerId': customerId.toString(),
        'cityId': cityId.toString(),
        'street': street,
        'areaName': areaName,
        'houseNumber': houseNumber,
        'localContactNumber': localContact,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'addressType': _addressTypeInt.toString(),
        'usageOption': usageOption,
        'isDefault': _isDefault.toString(),
      };
      final uri = Uri.parse(
        'http://129.151.188.8:8085/api/locations/createAddresses',
      ).replace(queryParameters: queryParams);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({'Authorization': 'Bearer YOUR_AUTH_TOKEN'});
      if (_imageFile != null) {
        final imageMultipart = await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
        );
        request.files.add(imageMultipart);
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('🌐 Create Address Response:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Body: ${response.body}');
      Navigator.pop(context);
    }
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
                  controller: _customerIdController,
                  hintText: 'Customer ID',
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
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
                    DropdownMenuItem(value: 0, child: Text('HOME (0)')),
                    DropdownMenuItem(value: 1, child: Text('WORK (1)')),
                    DropdownMenuItem(value: 2, child: Text('OTHER (2)')),
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
                  onPressed: _addLocationPicture,
                ),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.file(_imageFile!, height: 80),
                  ),
                const SizedBox(height: 20),
                CustomButton(text: 'Create', onPressed: _createAddress),
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
