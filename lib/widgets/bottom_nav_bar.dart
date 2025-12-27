import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cartproviders.dart';
import '../utils/colors.dart';

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
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.grey,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          if (badgeCount > 0)
            Positioned(
              right: -6,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(
                context,
                Icons.store,
                'Store Front',
                selectedIndex == 0,
                onTap: () {
                  if (selectedIndex != 0) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ),
              _navItem(
                context,
                Icons.local_offer,
                'Prime',
                selectedIndex == 1,
                onTap: () {
                  if (selectedIndex != 1) {
                    Navigator.pushNamed(context, '/prime');
                  }
                },
              ),
              _navItem(
                context,
                Icons.receipt_long,
                'Orders',
                selectedIndex == 2,
                onTap: () {
                  if (selectedIndex != 2) {
                    Navigator.pushNamed(context, '/orders');
                  }
                },
              ),
              _navItem(
                context,
                Icons.shopping_cart,
                'Cart',
                selectedIndex == 3,
                badgeCount: cart.totalItems,
                onTap: () {
                  if (selectedIndex != 3) {
                    Navigator.pushNamed(context, '/cart');
                  }
                },
              ),
              _navItem(
                context,
                Icons.more_horiz,
                'More',
                selectedIndex == 4,
                onTap: () {
                  if (selectedIndex != 4) {
                    Navigator.pushNamed(context, '/more-options');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
