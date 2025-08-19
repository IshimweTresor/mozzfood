import 'package:flutter/material.dart';
import 'address_book_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _instructionsController = TextEditingController();
  String _selectedRestaurant = 'Delizia Italiana';

  // Sample cart item data matching your screenshot
  final Map<String, dynamic> _cartItem = {
    'id': '1',
    'name': 'Ice cream',
    'price': 15000.0,
    'quantity': 1,
    'image': '�',
    'description': 'Coffee break, Chocolate,',
  };

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark background
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
                  const Expanded(
                    child: Text(
                      'Cart',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _showClearAllDialog(),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Restaurant Selection Dropdown
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedRestaurant,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Cart Item
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    // Ice cream item
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          // Item Image
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Image.asset(
                                'assets/ice_cream.jpg', // You can replace with actual image
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.icecream,
                                      color: Colors.grey,
                                      size: 25,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Item Details
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ice cream',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Coffee break, Chocolate,',
                                  style: TextStyle(
                                    color: Color(0xFF9E9E9E),
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Price
                          Flexible(
                            child: Text(
                              'RWF 15,000',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quantity and Action Controls
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const SizedBox(width: 66), // Align with content above
                          // Quantity Controls
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => _decrementQuantity(),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF3A3A3A),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  '${_cartItem['quantity']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _incrementQuantity(),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2A2A),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF3A3A3A),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Edit/Delete Actions
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => _editItem(),
                                child: const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF9E9E9E),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              GestureDetector(
                                onTap: () => _removeItem(),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: 1,
                      color: const Color(0xFF2A2A2A),
                    ),

                    const SizedBox(height: 30),

                    // Continue Shopping Button
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.add, color: Colors.green),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Continue Shopping',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Instructions Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter Instruction to $_selectedRestaurant (Optional)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 80,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF3A3A3A),
                                width: 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _instructionsController,
                              maxLines: null,
                              expands: true,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText: '',
                                hintStyle: TextStyle(color: Color(0xFF6A6A6A)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '0/400',
                              style: TextStyle(
                                color: Color(0xFF6A6A6A),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Dietary Restrictions
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: CustomPaint(
                        painter: DottedBorderPainter(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFF6A6A6A),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Add dietary restrictions (0 selected)',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF6A6A6A),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Order Summary
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryRow('Sub Total :', 'RWF 15,000'),
                          _buildSummaryRow('Container charge:', 'RWF 0'),
                          _buildSummaryRow('Delivery Fee:', 'RWF 4,500'),
                          const SizedBox(height: 8),
                          const Divider(color: Color(0xFF3A3A3A), thickness: 1),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Total amount',
                            'RWF 19,500',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 30,
                    ), // Reduced space for bottom button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _proceedToCheckout,
                  child: const Text(
                    'Checkout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.white : const Color(0xFF9E9E9E),
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  void _decrementQuantity() {
    setState(() {
      if (_cartItem['quantity'] > 1) {
        _cartItem['quantity']--;
      }
    });
  }

  void _incrementQuantity() {
    setState(() {
      _cartItem['quantity']++;
    });
  }

  void _editItem() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Edit item functionality')));
  }

  void _removeItem() {
    setState(() {
      _cartItem['quantity'] = 0;
    });
    Navigator.pop(context);
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text(
              'Clear Cart',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to clear all items from cart?',
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
                    _cartItem['quantity'] = 0;
                  });
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _proceedToCheckout() {
    // Navigate directly to address book page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressBookPage()),
    );
  }
}

// Custom painter for dotted border
class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF6A6A6A)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;

    // Top border
    _drawDottedLine(
      canvas,
      const Offset(0, 0),
      Offset(size.width, 0),
      paint,
      dashWidth,
      dashSpace,
    );
    // Right border
    _drawDottedLine(
      canvas,
      Offset(size.width, 0),
      Offset(size.width, size.height),
      paint,
      dashWidth,
      dashSpace,
    );
    // Bottom border
    _drawDottedLine(
      canvas,
      Offset(size.width, size.height),
      Offset(0, size.height),
      paint,
      dashWidth,
      dashSpace,
    );
    // Left border
    _drawDottedLine(
      canvas,
      Offset(0, size.height),
      const Offset(0, 0),
      paint,
      dashWidth,
      dashSpace,
    );
  }

  void _drawDottedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    final direction = (end - start);
    final distance = direction.distance;
    final unitVector = direction / distance;

    double currentDistance = 0;
    bool isDash = true;

    while (currentDistance < distance) {
      final segmentLength = isDash ? dashWidth : dashSpace;
      final segmentEnd = currentDistance + segmentLength;

      if (isDash) {
        final segmentStart = start + unitVector * currentDistance;
        final segmentEndPoint =
            start +
            unitVector * (segmentEnd > distance ? distance : segmentEnd);
        canvas.drawLine(segmentStart, segmentEndPoint, paint);
      }

      currentDistance = segmentEnd;
      isDash = !isDash;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
