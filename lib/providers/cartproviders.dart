import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menuItem.model.dart';

class CartProvider extends ChangeNotifier {
  static const String _cartKey = 'cart_items';
  List<_CartItem> _items = [];
  Vendor? _vendor; // The vendor for the current cart

  CartProvider() {
    _loadCart();
  }

  List<_CartItem> get items => List.unmodifiable(_items);
  Vendor? get vendor => _vendor;

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString(_cartKey);
    if (cartString != null) {
      final decoded = jsonDecode(cartString);
      _vendor =
          decoded['vendor'] != null ? Vendor.fromJson(decoded['vendor']) : null;
      _items =
          (decoded['items'] as List).map((e) => _CartItem.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode({
      'vendor': _vendor?.toJson(),
      'items': _items.map((e) => e.toJson()).toList(),
    });
    await prefs.setString(_cartKey, encoded);
  }

  void addToCart(MenuItem item, int quantity) {
    // If cart is empty, set vendor
    if (_vendor == null && item.vendorId != null) {
      _vendor = item.vendorId;
    }
    // If cart has items from a different vendor, clear cart and set new vendor
    if (_vendor != null &&
        item.vendorId != null &&
        _vendor!.id != item.vendorId!.id) {
      _items.clear();
      _vendor = item.vendorId;
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

  void removeFromCart(String itemId) {
    _items.removeWhere((e) => e.item.id == itemId);
    if (_items.isEmpty) _vendor = null;
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    final index = _items.indexWhere((e) => e.item.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _saveCart();
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _vendor = null;
    _saveCart();
    notifyListeners();
  }

  int get totalItems => _items.fold(0, (sum, e) => sum + e.quantity);

  int get totalPrice =>
      _items.fold(0, (sum, e) => sum + (e.item.price ?? 0) * e.quantity);
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
