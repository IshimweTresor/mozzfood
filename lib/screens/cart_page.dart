import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.model.dart';
import '../providers/cartproviders.dart';
import '../widgets/safe_network_image.dart';
import 'address_book_page.dart';

class CartPage extends StatelessWidget {
  final SavedLocation? selectedLocation;
  const CartPage({super.key, this.selectedLocation});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;
    final restaurantId = cartProvider.currentRestaurantId;
    final restaurantName = cartProvider.currentRestaurantName;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
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
                        onTap: () => _showClearAllDialog(context, cartProvider),
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
            // Restaurant Name
            if (restaurantName != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurantName,
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
            const SizedBox(height: 20),
            // Cart Items List - Grouped by Restaurant
            Expanded(
              child: cartItems.isEmpty
                  ? const Center(
                      child: Text(
                        'Your cart is empty.',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    )
                  : Builder(
                      builder: (context) {
                        // Group items by restaurant
                        final itemsByRestaurant =
                            cartProvider.itemsByRestaurant;

                        return ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: itemsByRestaurant.length,
                          itemBuilder: (context, restaurantIndex) {
                            final entry = itemsByRestaurant.entries.elementAt(
                              restaurantIndex,
                            );
                            final restaurantId = entry.key;
                            final restaurantItems = entry.value;

                            // Get restaurant name (we'll use a placeholder since MenuItem doesn't have it)
                            final restaurantDisplayName =
                                'Restaurant $restaurantId';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Restaurant Header
                                if (itemsByRestaurant.length > 1)
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.restaurant,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            restaurantDisplayName,
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
                                // Restaurant Items
                                ...restaurantItems.map((cartItem) {
                                  final menuItem = cartItem.item;
                                  return Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            // Item Image
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                child: menuItem.imageUrl.isEmpty
                                                    ? const Icon(
                                                        Icons.fastfood,
                                                        color: Colors.grey,
                                                        size: 25,
                                                      )
                                                    : SafeNetworkImage(
                                                        url: menuItem.imageUrl,
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                        placeholder: Container(
                                                          width: 50,
                                                          height: 50,
                                                          color:
                                                              Colors.grey[300],
                                                          child: const Icon(
                                                            Icons.fastfood,
                                                            color: Colors.grey,
                                                            size: 25,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Item Details
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    menuItem.name,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    menuItem.description,
                                                    style: const TextStyle(
                                                      color: Color(0xFF9E9E9E),
                                                      fontSize: 14,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Price
                                            Flexible(
                                              child: Text(
                                                'RWF ${menuItem.price}',
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
                                      // Quantity and Action Controls
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 66),
                                            // Quantity Controls
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    if (cartItem.quantity > 1) {
                                                      cartProvider
                                                          .updateQuantity(
                                                            menuItem.id,
                                                            cartItem.quantity -
                                                                1,
                                                          );
                                                    }
                                                  },
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF2A2A2A,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      border: Border.all(
                                                        color: const Color(
                                                          0xFF3A3A3A,
                                                        ),
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
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                      ),
                                                  child: Text(
                                                    '${cartItem.quantity}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    cartProvider.updateQuantity(
                                                      menuItem.id,
                                                      cartItem.quantity + 1,
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF2A2A2A,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      border: Border.all(
                                                        color: const Color(
                                                          0xFF3A3A3A,
                                                        ),
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
                                            // Delete Action
                                            GestureDetector(
                                              onTap: () {
                                                cartProvider.removeFromCart(
                                                  menuItem.id,
                                                );
                                              },
                                              child: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 22,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Divider
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        height: 1,
                                        color: const Color(0xFF2A2A2A),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        );
                      },
                    ),
            ),
            // Order Summary and Checkout
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                  _buildSummaryRow(
                    'Sub Total :',
                    'RWF ${cartProvider.totalPrice}',
                  ),
                  _buildSummaryRow('Container charge:', 'RWF 0'),
                  _buildSummaryRow('Delivery Fee:', 'RWF 0'),
                  const SizedBox(height: 8),
                  const Divider(color: Color(0xFF3A3A3A), thickness: 1),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Total amount',
                    'RWF ${cartProvider.totalPrice + 1}',
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : SafeArea(
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddressBookPage(
                                selectedLocation:
                                    selectedLocation, // Pass the SavedLocation object
                              ),
                            ),
                          );
                        },
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

  void _showClearAllDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Clear Cart', style: TextStyle(color: Colors.white)),
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
              cartProvider.clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
