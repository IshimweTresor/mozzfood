import 'package:flutter/material.dart';

/// Reusable bottom navigation bar used across screens.
/// Callers should place a bottom spacer (height: kBottomNavigationBarHeight)
/// in their scrollable content to avoid overlap.
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({Key? key, this.selectedIndex = 0}) : super(key: key);

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isSelected, {
    bool hasNotification = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
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
            const Positioned(
              right: 0,
              top: 0,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.red,
                child: Text(
                  '1',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(top: BorderSide(color: Color(0xFF3A3A3A), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context,
            Icons.store,
            'Store Front',
            selectedIndex == 0,
            onTap: () => Navigator.popAndPushNamed(context, '/home'),
          ),
          _navItem(
            context,
            Icons.local_offer,
            'Prime',
            selectedIndex == 1,
            onTap: () => Navigator.pushNamed(context, '/prime'),
          ),
          _navItem(
            context,
            Icons.receipt_long,
            'Orders',
            selectedIndex == 2,
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),
          _navItem(
            context,
            Icons.shopping_cart,
            'Cart',
            selectedIndex == 3,
            hasNotification: true,
            onTap: () => Navigator.pushNamed(context, '/cart'),
          ),
          _navItem(
            context,
            Icons.more_horiz,
            'More',
            selectedIndex == 4,
            onTap: () => Navigator.pushNamed(context, '/more'),
          ),
        ],
      ),
    );
  }
}
