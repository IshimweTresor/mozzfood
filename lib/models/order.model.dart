import 'package:json_annotation/json_annotation.dart';
import 'package:vuba/models/menuItem.model.dart';
import 'package:vuba/models/menuItem.model.dart' as menuitem;

part 'order.model.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {
  @JsonKey(name: '_id')
  final String? id;
  final User userId; // <- nested
  final Vendor vendorId; // <- nested
  final String? riderId;
  final List<OrderItem> items;
  final double totalPrice;
  final String paymentStatus;
  final String orderStatus;
  final menuitem.Location location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    this.id,
    required this.userId,
    required this.vendorId,
    this.riderId,
    required this.items,
    required this.totalPrice,
    required this.paymentStatus,
    required this.orderStatus,
    required this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String phone;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Vendor {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String address;
  final menuitem.Location location;

  Vendor({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
  Map<String, dynamic> toJson() => _$VendorToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OrderItem {
  final MenuItem itemId; // <- nested object, not string
  final int quantity;

  OrderItem({required this.itemId, required this.quantity});

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}
