import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vuba/models/user.model.dart';
import '../utils/colors.dart';
import 'store_front_page.dart';
import 'prime_page.dart';
import 'orders_page.dart';
import 'cart_page.dart';
import 'more_options_page.dart';
import '../providers/cartproviders.dart';

class HomePage extends StatefulWidget {
  final String? selectedLocation;
  final SavedLocation? selectedLocationData;
  

  const HomePage({super.key, this.selectedLocation, this.selectedLocationData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  List<Widget> get _pages => [
    StoreFrontPage(
      selectedLocationName: widget.selectedLocation ?? "Select location",
    ),
    const PrimePage(),
    const OrdersPage(),
    const CartPage(),
    const MoreOptionsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.inputBorder, width: 0.5),
          ),
        ),
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            int cartCount = cartProvider.totalItems;
            return BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              selectedFontSize: 12,
              unselectedFontSize: 10,
              iconSize: 24,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.storefront),
                  label: 'Store Front',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.local_offer),
                  label: 'Prime',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart),
                      if (cartCount > 0)
                        Positioned(
                          right: -6,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$cartCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Cart',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'More',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
