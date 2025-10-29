import 'package:json_annotation/json_annotation.dart';
import 'package:vuba/models/menuItem.model.dart';

part 'order.model.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {
  @JsonKey(name: '_id')
  final String? id;
  final User userId;
  final int restaurantId;
  final String? riderId;
  final List<OrderItem> items;
  final double totalPrice;
  final String paymentStatus;
  final String orderStatus;
  final DeliveryLocation location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    this.id,
    required this.userId,
    required this.restaurantId,
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
class DeliveryLocation {
  final String address;
  final double latitude;
  final double longitude;

  DeliveryLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory DeliveryLocation.fromJson(Map<String, dynamic> json) =>
      _$DeliveryLocationFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryLocationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OrderItem {
  final MenuItem itemId; // <- nested object, not string
  final int quantity;
  final String? specialInstructions;

  OrderItem({
    required this.itemId,
    required this.quantity,
    this.specialInstructions,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}
