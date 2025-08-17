import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AddressBookPage extends StatefulWidget {
  const AddressBookPage({super.key});

  @override
  State<AddressBookPage> createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Address Book',
          style: TextStyle(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _addAddress,
            icon: const Icon(Icons.add, color: AppColors.primary),
            label: const Text(
              'Address',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final address = _addresses[index];
          return _buildAddressCard(address, index);
        },
      ),
    );
  }

  Widget _buildAddressCard(AddressItem address, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    address.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.home_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address.address,
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
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    address.phone,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (address.isDefault)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addAddress() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Add New Address',
              style: TextStyle(color: AppColors.onBackground),
            ),
            content: const Text(
              'This feature will allow you to add a new delivery address.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
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
