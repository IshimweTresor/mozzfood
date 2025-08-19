import 'package:flutter/material.dart';
import 'order_summary_page.dart';

class MobileWalletNumbersPage extends StatefulWidget {
  final String paymentMethod;

  const MobileWalletNumbersPage({super.key, required this.paymentMethod});

  @override
  State<MobileWalletNumbersPage> createState() =>
      _MobileWalletNumbersPageState();
}

class _MobileWalletNumbersPageState extends State<MobileWalletNumbersPage> {
  List<String> _walletNumbers = ['0784107365'];
  final TextEditingController _newNumberController = TextEditingController();

  @override
  void dispose() {
    _newNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
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
                    'Mobile Wallet Numbers',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            // Add New Number Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _showAddNumberDialog,
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'New Number',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Wallet Numbers List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _walletNumbers.length,
                itemBuilder: (context, index) {
                  final number = _walletNumbers[index];
                  return _buildWalletNumberCard(number, index);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          border: Border(top: BorderSide(color: Color(0xFF3A3A3A), width: 1)),
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
              false,
              hasNotification: true,
            ),
            _buildBottomNavItem(Icons.more_horiz, 'More', false),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletNumberCard(String number, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to order summary with selected number
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => OrderSummaryPage(
                  paymentMethod: widget.paymentMethod,
                  selectedNumber: number,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3A3A3A)),
        ),
        child: Row(
          children: [
            // Payment method icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    widget.paymentMethod.contains('MOMO')
                        ? const Color(0xFFFFCC00)
                        : const Color(0xFFE60012),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  widget.paymentMethod.contains('MOMO') ? 'MoMo' : 'airtel',
                  style: TextStyle(
                    color:
                        widget.paymentMethod.contains('MOMO')
                            ? Colors.black
                            : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Phone number
            Expanded(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Delete button
            GestureDetector(
              onTap: () => _deleteNumber(index),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
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

  void _showAddNumberDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: const Color(0xFF2A2A2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'New Mobile Wallet\nNumber',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Phone number input
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF3A3A3A)),
                    ),
                    child: TextField(
                      controller: _newNumberController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter phone number',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            _newNumberController.clear();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _confirmAddNumber,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
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
          ),
    );
  }

  void _confirmAddNumber() {
    final newNumber = _newNumberController.text.trim();
    if (newNumber.isNotEmpty) {
      setState(() {
        _walletNumbers.add(newNumber);
      });
      _newNumberController.clear();
      Navigator.pop(context);
    }
  }

  void _deleteNumber(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text(
              'Delete Number',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to delete this number?',
              style: TextStyle(color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _walletNumbers.removeAt(index);
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
