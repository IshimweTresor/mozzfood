import 'package:flutter/material.dart';
import '../utils/colors.dart';

class StoreDetailPage extends StatefulWidget {
  final Map<String, dynamic> store;
  const StoreDetailPage({required this.store, Key? key}) : super(key: key);

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  late String selectedCategory;

  // Example categories for each store type
  Map<String, List<String>> getCategoriesForStore(String name) {
    if (name.contains('Zenn Pharmacy')) {
      return {
        'Most Popular': ['Innotex Condom', 'Durex extra time 10 pieces'],
        'Condoms & Lubricant': [
          'Innotex Condom',
          'Durex extra time 10 pieces',
          'Armour Condom',
        ],
        'Oral Care': ['Listerine Cool Mint'],
      };
    } else if (name.contains('Honest') || name.contains('Supermarket')) {
      return {
        'Most Popular': ['Rice 5kg', 'Cooking Oil 1L'],
        'Groceries': ['Rice 5kg', 'Sugar 1kg', 'Milk 500ml'],
        'Canned Goods': ['Tomato Paste'],
        'Snacks': ['Milk 500ml'],
      };
    } else if (name.contains('Inyange')) {
      return {
        'Most Popular': ['Inyange Milk 1L', 'Inyange Yogurt'],
        'Drinks': ['Inyange Milk 1L', 'Inyange Water 1.5L', 'Inyange Juice'],
        'Dairy': ['Inyange Yogurt'],
      };
    } else if (name.contains('Liquor')) {
      return {
        'Most Popular': ['Hennessy', 'Smirnoff Vodka'],
        'Whiskey': ['Jameson', 'Hennessy'],
        'Vodka': ['Smirnoff Vodka'],
        'Rum': ['Bacardi'],
      };
    }
    return {
      'All': ['Sample Product'],
    };
  }

  // Map product name to details for each store type
  Map<String, Map<String, String>> getProductDetailsForStore(String name) {
    if (name.contains('Zenn Pharmacy')) {
      return {
        'Innotex Condom': {'price': 'RWF2,000', 'description': 'B/3'},
        'Durex extra time 10 pieces': {
          'price': 'RWF7,000',
          'description':
              'Looking for extended long lasting pleasure? Try this.',
        },
        'Armour Condom': {
          'price': 'RWF2,000',
          'description': 'strawberry flavour',
        },
        'Listerine Cool Mint': {'price': '', 'description': '250ml'},
      };
    } else if (name.contains('Honest') || name.contains('Supermarket')) {
      return {
        'Rice 5kg': {'price': 'RWF8,000', 'description': 'Premium long grain'},
        'Cooking Oil 1L': {'price': 'RWF2,500', 'description': 'Sunflower'},
        'Tomato Paste': {'price': 'RWF1,200', 'description': '400g can'},
        'Sugar 1kg': {'price': 'RWF1,800', 'description': ''},
        'Milk 500ml': {'price': 'RWF700', 'description': 'Fresh'},
      };
    } else if (name.contains('Inyange')) {
      return {
        'Inyange Milk 1L': {'price': 'RWF1,200', 'description': 'Fresh milk'},
        'Inyange Yogurt': {'price': 'RWF800', 'description': 'Strawberry'},
        'Inyange Water 1.5L': {
          'price': 'RWF600',
          'description': 'Mineral water',
        },
        'Inyange Juice': {'price': 'RWF1,000', 'description': 'Mango'},
      };
    } else if (name.contains('Liquor')) {
      return {
        'Smirnoff Vodka': {'price': 'RWF12,000', 'description': '750ml'},
        'Hennessy': {'price': 'RWF110,000', 'description': '700ml'},
        'Bacardi': {'price': 'RWF15,000', 'description': '750ml'},
        'Jameson': {'price': 'RWF18,000', 'description': '700ml'},
      };
    }
    return {
      'Sample Product': {'price': 'RWF1,000', 'description': 'Description'},
    };
  }

  @override
  void initState() {
    super.initState();
    final categories = getCategoriesForStore(widget.store['name'] ?? '');
    selectedCategory = categories.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final categories = getCategoriesForStore(widget.store['name'] ?? '');
    final productDetails = getProductDetailsForStore(
      widget.store['name'] ?? '',
    );
    final products = categories[selectedCategory] ?? [];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.store['name'],
          style: const TextStyle(
            color: AppColors.onBackground,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: AppColors.textSecondary,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green open banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.check, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'We are Open 24/7!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Great news, Kigali! Vuba Vuba is now open 24/7, from Thursday to Sunday. From Monday to Wednesday, we stay open late until 1:00 AM. Order anytime, day or night',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Store info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.store['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.onBackground,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 14),
                    Text(
                      '${widget.store['rating']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.store['distance'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DF: ${widget.store['deliveryFee']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DT: ${widget.store['deliveryTime']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Text(
                      '49 items',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Minimum Order: RWF3,000',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Dynamic Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final category in categories.keys)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:
                                selectedCategory == category
                                    ? Colors.white
                                    : AppColors.textSecondary,
                          ),
                        ),
                        selected: selectedCategory == category,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        onSelected: (_) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Product list (mocked)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Don't miss out on what everyone's raving about!!",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final productName = products[index];
                final details = productDetails[productName] ?? {};
                return _ProductListItem(
                  name: productName,
                  price: details['price'] ?? '',
                  description: details['description'] ?? '',
                  image: null,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return ProductDetailSheet(
                          name: productName,
                          price: details['price'] ?? '',
                          description: details['description'] ?? '',
                          image: null,
                          storeName: widget.store['name'] ?? '',
                        );
                      },
                    );
                  },
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
  final String name;
  final String price;
  final String description;
  final String? image;
  final VoidCallback? onTap;
  const _ProductListItem({
    required this.name,
    required this.price,
    required this.description,
    this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: AppColors.surface,
      child: ListTile(
        leading:
            image == null
                ? const Icon(Icons.shopping_bag, color: AppColors.primary)
                : Image.asset(image!),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.isNotEmpty)
              Text(
                description,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            if (price.isNotEmpty)
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                ),
              ),
          ],
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}

class ProductDetailSheet extends StatefulWidget {
  final String name;
  final String price;
  final String description;
  final String? image;
  final String storeName;
  const ProductDetailSheet({
    required this.name,
    required this.price,
    required this.description,
    this.image,
    required this.storeName,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final priceValue =
        int.tryParse(widget.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final total = priceValue * quantity;
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
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
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (widget.image == null)
                  Center(
                    child: Icon(
                      Icons.shopping_bag,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  )
                else
                  Center(child: Image.asset(widget.image!, height: 100)),
                const SizedBox(height: 16),
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  widget.storeName,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(widget.description.isNotEmpty ? widget.description : '-'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'RWF ${total.toString()}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed:
                          quantity > 1
                              ? () => setState(() => quantity--)
                              : null,
                    ),
                    Text('$quantity', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => quantity++),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              backgroundColor: Colors.grey[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'SUCCESS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Product added to cart\nSuccessfully !',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text(
                                    'Ok',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    child: const Text(
                      'Add to cart',
                      style: TextStyle(fontSize: 18),
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
