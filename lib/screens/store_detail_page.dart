import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/menuItem.api.dart';
import '../models/menuItem.model.dart';
import '../models/vendor.model.dart';
import '../providers/cartproviders.dart';
import '../utils/colors.dart';
import '../widgets/safe_network_image.dart';

class StoreDetailPage extends StatefulWidget {
  final Vendor vendor;
  const StoreDetailPage({required this.vendor, super.key});

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  late Future<List<MenuItem>> _menuItemsFuture;

  @override
  void initState() {
    super.initState();
    _menuItemsFuture = _fetchMenuItems();
  }

  Future<List<MenuItem>> _fetchMenuItems() async {
    if (widget.vendor.restaurantId == null) {
      return [];
    }
    final response = await MenuItemApi.getMenuItemsByRestaurant(
      widget.vendor.restaurantId!,
    );
    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          FutureBuilder<List<MenuItem>>(
            future: _menuItemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Failed to load menu items'));
              }
              final allItems = snapshot.data ?? [];

              // Group items by category
              final Map<String, List<MenuItem>> groupedItems = {};
              for (var item in allItems) {
                final category = item.categoryName.isEmpty
                    ? 'Menu'
                    : item.categoryName;
                groupedItems.putIfAbsent(category, () => []).add(item);
              }

              return CustomScrollView(
                slivers: [
                  // Premium Header with Image
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: AppColors.background,
                    elevation: 0,
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.store,
                              size: 64,
                              color: AppColors.primary,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.black),
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Store Information Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.vendor.restaurantName ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: AppColors.onBackground,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '4.5', // Mock rating
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.vendor.location ?? "Kigali"} • 20-30 min',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Green open banner
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Open 24/7! Late night delivery available until 1:00 AM.',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Menu Categories and Items
                  ...groupedItems.entries.expand((entry) {
                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onBackground,
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = entry.value[index];
                          return _ProductListItem(
                            item: item,
                            storeName: widget.vendor.restaurantName ?? '',
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return ProductDetailSheet(
                                    menuItem: item,
                                    storeName:
                                        widget.vendor.restaurantName ?? '',
                                  );
                                },
                              );
                            },
                          );
                        }, childCount: entry.value.length),
                      ),
                    ];
                  }).toList(),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ), // Extra space for floating cart
                ],
              );
            },
          ),

          // Floating Cart Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Consumer<CartProvider>(
              builder: (context, cart, child) {
                if (cart.items.isEmpty) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/cart'),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${cart.totalItems}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'View Cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'RWF ${cart.totalPrice.toInt()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductListItem extends StatelessWidget {
  final MenuItem item;
  final String storeName;
  final VoidCallback onTap;

  const _ProductListItem({
    required this.item,
    required this.storeName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Details on the left
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.description.isNotEmpty)
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'RWF ${item.price.toInt()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Image on the right
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.imageUrl.isEmpty
                      ? Container(
                          width: 110,
                          height: 110,
                          color: AppColors.primary.withOpacity(0.05),
                          child: const Icon(
                            Icons.fastfood,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        )
                      : SafeNetworkImage(
                          url: item.imageUrl,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                ),
                // Quick Add Button
                Positioned(
                  bottom: -8,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: AppColors.primary,
                      ),
                      onPressed: onTap,
                      child: const Text(
                        'ADD',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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
  }
}

class ProductDetailSheet extends StatefulWidget {
  final MenuItem menuItem;
  final String storeName;
  const ProductDetailSheet({
    required this.menuItem,
    required this.storeName,
    super.key,
  });

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final total = widget.menuItem.price * quantity;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Center(
                  child: widget.menuItem.imageUrl.isEmpty
                      ? Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.shopping_bag,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SafeNetworkImage(
                            url: widget.menuItem.imageUrl,
                            height: 140,
                            width: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.menuItem.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.storeName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'RWF ${widget.menuItem.price}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.menuItem.description.isNotEmpty
                      ? widget.menuItem.description
                      : '-',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.onBackground,
                      ),
                    ),
                    Text(
                      'RWF $total',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.primary,
                          ),
                          onPressed: quantity > 1
                              ? () => setState(() => quantity--)
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.onBackground,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primary,
                          ),
                          onPressed: () => setState(() => quantity++),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.shopping_cart_checkout_rounded,
                      color: Colors.white,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Provider.of<CartProvider>(
                        context,
                        listen: false,
                      ).addToCart(widget.menuItem, quantity);
                      // Close the bottom sheet first
                      Navigator.of(context).pop();

                      // Show a brief success SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${widget.menuItem.name} added to cart',
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'VIEW CART',
                            onPressed: () =>
                                Navigator.pushNamed(context, '/cart'),
                          ),
                        ),
                      );
                    },
                    label: const Text(
                      'Add to cart',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
