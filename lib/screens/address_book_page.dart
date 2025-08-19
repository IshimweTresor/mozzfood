import 'package:flutter/material.dart';
import 'add_address_page.dart';
import 'payment_method_page.dart';

class AddressBookPage extends StatefulWidget {
  const AddressBookPage({super.key});

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  bool _isAddressSelected = false; // Track if address is selected

  List<AddressItem> _addresses = [
    AddressItem(
      name: 'Bwiza',
      address: 'KG 115 Ave, Kabuga, Rwanda',
      phone: '250784107365',
      isDefault: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF1A1A1A,
      ), // Dark background like screenshot
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
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
                  GestureDetector(
                    onTap: _addAddress,
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Address',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Address List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
          // Proceed to Checkout Button - Only show when address is selected
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
          // Bottom Navigation Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              border: Border(
                top: BorderSide(color: Color(0xFF3A3A3A), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.store, 'Store Front', false),
                _buildBottomNavItem(Icons.local_offer, 'Prime', false),
                _buildBottomNavItem(Icons.receipt_long, 'Orders', false),
                _buildBottomNavItem(
                  Icons.shopping_cart,
                  'Cart',
                  true,
                  hasNotification: true,
                ),
                _buildBottomNavItem(Icons.more_horiz, 'More', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressItem address, int index) {
    return GestureDetector(
      onTap: () {
        // Select this address and show checkout button
        setState(() {
          _isAddressSelected = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3A3A)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20,
                    ),
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
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      address.phone,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const Spacer(),
                    // Green call icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Edit icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (address.isDefault)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAddressPage()),
    );

    if (result != null) {
      setState(() {
        _addresses.add(
          AddressItem(
            name: result['name'],
            address: result['address'],
            phone: result['phone'],
            isDefault: result['isDefault'] ?? false,
          ),
        );
      });
    }
  }

  void _proceedToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentMethodPage()),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label,
    bool isSelected, {
    bool hasNotification = false,
  }) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.green : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        if (hasNotification)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: const Text(
                '1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class AddressItem {
  final String name;
  final String address;
  final String phone;
  final bool isDefault;

  AddressItem({
    required this.name,
    required this.address,
    required this.phone,
    required this.isDefault,
  });
}
