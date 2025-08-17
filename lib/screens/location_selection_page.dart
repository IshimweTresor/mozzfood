import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';
import 'map_location_picker_page.dart';
import 'home_page.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  String _selectedAddressOption = 'Always Ask'; // 'Remember' or 'Always Ask'
  String _selectedCountry = 'RWANDA';
  List<Map<String, String>> _savedLocations = [
    {
      'name': 'Bwiza',
      'address': 'KG 115 Ave, Kabuga, Rwanda',
      'phone': '250784107365',
    },
  ];

  final List<String> _rwandaProvinces = [
    'KIGALI',
    'MUSANZE',
    'RUBAVU',
    'RUSIZI',
  ];

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

  void _handleLogout() {
    // Navigate back to login page
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _deleteLocation(int index) {
    setState(() {
      _savedLocations.removeAt(index);
    });
  }

  void _selectLocation(Map<String, String> location) {
    // Navigate to home page with selected location
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(selectedLocation: location['name']),
      ),
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
            icon: const Icon(
              Icons.logout,
              color: AppColors.textSecondary,
              size: 20,
            ),
            label: const Text(
              'Logout',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
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
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              _selectedAddressOption == 'Remember'
                                  ? AppColors.primary
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          'Remember',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                _selectedAddressOption == 'Remember'
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
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              _selectedAddressOption == 'Always Ask'
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          height: 9,
                          color: AppColors.ukraineBlue,
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 24,
                            height: 9,
                            color: AppColors.ukraineYellow,
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
                itemCount: _rwandaProvinces.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to location details for province selection
                      Navigator.pushNamed(context, '/location-details');
                    },
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _rwandaProvinces[index],
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
                },
              ),
            ),

            const SizedBox(height: 20),

            // Add New Location Button
            CustomButton(
              text: 'Add New Location',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapLocationPickerPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Saved Locations
            if (_savedLocations.isNotEmpty) ...[
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
                int index = entry.key;
                Map<String, String> location = entry.value;
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location['name']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onBackground,
                                    ),
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
                                    onTap: () {
                                      // Edit location functionality
                                    },
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
                                      _deleteLocation(index);
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
                                      location['address']!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                    location['phone']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
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
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
