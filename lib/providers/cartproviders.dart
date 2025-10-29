import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menuItem.model.dart';

class CartProvider extends ChangeNotifier {
  static const String _cartKey = 'cart_items';
  List<_CartItem> _items = [];
  int? _currentRestaurantId;
  String? _currentRestaurantName;

  CartProvider() {
    _loadCart();
  }

  List<_CartItem> get items => List.unmodifiable(_items);
  int? get currentRestaurantId => _currentRestaurantId;
  String? get currentRestaurantName => _currentRestaurantName;

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
      final decoded = jsonDecode(cartString);
      _currentRestaurantId = decoded['restaurantId'] as int?;
      _currentRestaurantName = decoded['restaurantName'] as String?;
      _items = (decoded['items'] as List)
          .map((e) => _CartItem.fromJson(e))
          .toList();
      notifyListeners();
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

  void addToCart(MenuItem item, int quantity) {
    // If cart has items from a different restaurant, clear cart
    if (_items.isNotEmpty && _currentRestaurantId != item.restaurantId) {
      _items.clear();
      _currentRestaurantId = item.restaurantId;
      _currentRestaurantName =
          null; // This should be set when adding the first item
    }

    // If this is the first item, set the restaurant info
    if (_items.isEmpty) {
      _currentRestaurantId = item.restaurantId;
    }

    final index = _items.indexWhere((e) => e.item.id == item.id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + quantity,
      );
    } else {
      _items.add(_CartItem(item: item, quantity: quantity));
    }
    _saveCart();
    notifyListeners();
  }

  void removeFromCart(int itemId) {
    _items.removeWhere((e) => e.item.id == itemId);
    if (_items.isEmpty) {
      _currentRestaurantId = null;
      _currentRestaurantName = null;
    }
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(int itemId, int quantity) {
    final index = _items.indexWhere((e) => e.item.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: quantity);
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

  double get totalPrice =>
      _items.fold(0, (sum, e) => sum + e.item.price * e.quantity);
}

class _CartItem {
  final MenuItem item;
  final int quantity;

  _CartItem({required this.item, required this.quantity});

  _CartItem copyWith({MenuItem? item, int? quantity}) {
    return _CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
    'item': item.toJson(),
    'quantity': quantity,
  };

  factory _CartItem.fromJson(Map<String, dynamic> json) => _CartItem(
    item: MenuItem.fromJson(json['item']),
    quantity: json['quantity'],
  );
}
