import 'package:flutter/material.dart';
import '../models/user.model.dart';
import '../api/user.api.dart';
import 'payment_method_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AddressBookPage extends StatefulWidget {
  final SavedLocation? selectedLocation;
  const AddressBookPage({super.key, this.selectedLocation});

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  bool _isAddressSelected = false;
  int? _selectedIndex;
  List<SavedLocation> _addresses = [];
  bool _isLoading = true;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

// ...existing imports...

Future<void> _loadAddresses() async {
  setState(() {
    _isLoading = true;
  });

  // Get auth token from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  _authToken = prefs.getString('auth_token'); // <-- Make sure this key matches your app

  if (_authToken == null) {
    setState(() {
      _isLoading = false;
    });
    return;
  }

  final response = await UserApi.getUserLocations(token: _authToken!);
  if (response.success && response.data != null) {
    final locations = response.data!.savedLocations;
    setState(() {
      _addresses = locations;
      _isLoading = false;
      if (widget.selectedLocation != null) {
        _selectedIndex = _addresses.indexWhere(
          (loc) => loc.id == widget.selectedLocation!.id,
        );
        _isAddressSelected = _selectedIndex != -1;
      }
    });
  } else {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    // App Bar
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'My Address Book',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    // Address List
                    Expanded(
                      child:
                          _addresses.isEmpty
                              ? const Center(
                                child: Text(
                                  'No addresses found.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: _addresses.length,
                                itemBuilder: (context, index) {
                                  final address = _addresses[index];
                                  return _buildAddressCard(address, index);
                                },
                              ),
                    ),
                  ],
                ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isAddressSelected)
            Container(
              margin: const EdgeInsets.all(20),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _proceedToCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Proceed To Checkout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(SavedLocation address, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _isAddressSelected = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.green.withOpacity(0.15)
                  : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : const Color(0xFF3A3A3A),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  address.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.home, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.address,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
            if (address.phone != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, color: Colors.grey, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    address.phone!,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

void _proceedToCheckout() {
    if (_selectedIndex != null) {
      final selectedAddress = _addresses[_selectedIndex!];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PaymentMethodPage(selectedLocation: selectedAddress),
        ),
      );
    }
  }
}
