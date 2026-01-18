import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/menuItem.model.dart';
import '../api/order.api.dart';
import '../utils/logger.dart';

class CartProvider extends ChangeNotifier {
  static const String _cartKey = 'cart_items';
  List<CartItem> _items = [];
  int? _currentRestaurantId;
  String? _currentRestaurantName;
  double _deliveryFee = 0.0;
  bool _isLoadingDeliveryFee = false;

  CartProvider() {
    _loadCart();
  }

  List<CartItem> get items => List.unmodifiable(_items);
  int? get currentRestaurantId => _currentRestaurantId;
  String? get currentRestaurantName => _currentRestaurantName;
  double get deliveryFee => _deliveryFee;
  bool get isLoadingDeliveryFee => _isLoadingDeliveryFee;

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<String?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('customer_id');
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString(_cartKey);
    if (cartString != null) {
      try {
        final decoded = jsonDecode(cartString);
        _currentRestaurantId = decoded['restaurantId'] as int?;
        _currentRestaurantName = decoded['restaurantName'] as String?;
        _items = (decoded['items'] as List)
            .map((e) => CartItem.fromJson(e))
            .toList();
        notifyListeners();
      } catch (e) {
        print('Error loading cart: $e');
        _items = [];
      }
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode({
      'restaurantId': _currentRestaurantId,
      'restaurantName': _currentRestaurantName,
      'items': _items.map((e) => e.toJson()).toList(),
    });
    await prefs.setString(_cartKey, encoded);
  }

  void setRestaurantName(String name) {
    _currentRestaurantName = name;
    _saveCart();
    notifyListeners();
  }

  void addToCart(
    MenuItem item,
    int quantity, {
    String? specialInstructions,
    List<int>? variantIds,
  }) {
    // Allow multi-restaurant carts - no longer clear cart when adding from different restaurant
    // If this is the first item, set the restaurant info for backward compatibility
    if (_items.isEmpty) {
      _currentRestaurantId = item.restaurantId;
      _currentRestaurantName = null;
    }

    final index = _items.indexWhere(
      (e) =>
          e.item.id == item.id &&
          _listEquals(e.selectedVariantIds, variantIds ?? []),
    );

    if (index != -1) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + quantity,
      );
    } else {
      _items.add(
        CartItem(
          item: item,
          quantity: quantity,
          specialInstructions: specialInstructions,
          selectedVariantIds: variantIds ?? [],
        ),
      );
    }
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(int itemId, {List<int>? variantIds}) {
    _items.removeWhere(
      (e) =>
          e.item.id == itemId &&
          _listEquals(e.selectedVariantIds, variantIds ?? []),
    );
    if (_items.isEmpty) {
      _currentRestaurantId = null;
      _currentRestaurantName = null;
    }
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(int itemId, int quantity, {List<int>? variantIds}) {
    final index = _items.indexWhere(
      (e) =>
          e.item.id == itemId &&
          _listEquals(e.selectedVariantIds, variantIds ?? []),
    );
    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      _saveCart();
      notifyListeners();
    }
  }

  void updateSpecialInstructions(
    int itemId,
    String? instructions, {
    List<int>? variantIds,
  }) {
    final index = _items.indexWhere(
      (e) =>
          e.item.id == itemId &&
          _listEquals(e.selectedVariantIds, variantIds ?? []),
    );
    if (index != -1) {
      _items[index] = _items[index].copyWith(specialInstructions: instructions);
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _currentRestaurantId = null;
    _currentRestaurantName = null;
    _saveCart();
    notifyListeners();
  }

  int get totalItems => _items.fold(0, (sum, e) => sum + e.quantity);

  double get totalPrice {
    return _items.fold(0.0, (sum, e) => sum + ((e.item.price) * e.quantity));
  }

  double get subTotal => totalPrice;

  double get discountAmount => 0.0; // Calculate based on promotions

  // Delivery fee is handled by restaurant/backend, not added to customer's payment
  double get finalAmount => subTotal - discountAmount;

  /// Fetch delivery fee from API for the current restaurant
  Future<void> fetchDeliveryFee() async {
    if (_currentRestaurantId == null || _currentRestaurantId! <= 0) {
      Logger.warn('⚠️ Cannot fetch delivery fee: No valid restaurant ID');
      _deliveryFee = 0.0;
      notifyListeners();
      return;
    }

    _isLoadingDeliveryFee = true;
    notifyListeners();

    try {
      Logger.info(
        '🔄 Fetching delivery fee for restaurant: $_currentRestaurantId',
      );
      final response = await OrderApi.getDeliveryFee(
        restaurantId: _currentRestaurantId!,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        double fee = 0.0;

        // Handle different possible response formats
        if (data.containsKey('deliveryFee')) {
          fee = (data['deliveryFee'] as num).toDouble();
        } else if (data.containsKey('fee')) {
          fee = (data['fee'] as num).toDouble();
        } else if (data.containsKey('amount')) {
          fee = (data['amount'] as num).toDouble();
        }

        _deliveryFee = fee;
        Logger.info('✅ Delivery fee fetched: RWF $_deliveryFee');
      } else {
        Logger.warn(
          '⚠️ Failed to fetch delivery fee: ${response.message}. Using default.',
        );
        _deliveryFee = 0.0;
      }
    } catch (e) {
      Logger.error('❌ Error fetching delivery fee: $e');
      _deliveryFee = 0.0;
    }

    _isLoadingDeliveryFee = false;
    notifyListeners();
  }

  /// Manually set delivery fee (for testing or fallback)
  void setDeliveryFee(double fee) {
    _deliveryFee = fee;
    notifyListeners();
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Get all unique restaurant IDs in the cart
  List<int> get restaurantIds {
    final ids = <int>{};
    for (var item in _items) {
      ids.add(item.item.restaurantId);
    }
    return ids.toList();
  }

  /// Get items grouped by restaurant ID
  Map<int, List<CartItem>> get itemsByRestaurant {
    final Map<int, List<CartItem>> grouped = {};
    for (var item in _items) {
      final restaurantId = item.item.restaurantId;
      grouped.putIfAbsent(restaurantId, () => []).add(item);
    }
    return grouped;
  }

  /// Get restaurant name for a given restaurant ID
  /// Note: MenuItem doesn't store restaurant name, so this returns null
  /// Restaurant names should be fetched separately or stored in cart metadata
  String? getRestaurantName(int restaurantId) {
    return null;
  }
}

class CartItem {
  final MenuItem item;
  final int quantity;
  final String? specialInstructions;
  final List<int> selectedVariantIds;

  CartItem({
    required this.item,
    required this.quantity,
    this.specialInstructions,
    this.selectedVariantIds = const [],
  });

  CartItem copyWith({
    MenuItem? item,
    int? quantity,
    String? specialInstructions,
    List<int>? selectedVariantIds,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      selectedVariantIds: selectedVariantIds ?? this.selectedVariantIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'item': item.toJson(),
    'quantity': quantity,
    if (specialInstructions != null) 'specialInstructions': specialInstructions,
    'selectedVariantIds': selectedVariantIds,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    item: MenuItem.fromJson(json['item']),
    quantity: json['quantity'],
    specialInstructions: json['specialInstructions'] as String?,
    selectedVariantIds: json['selectedVariantIds'] != null
        ? List<int>.from(json['selectedVariantIds'])
        : [],
  );
}
