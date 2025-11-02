import 'package:json_annotation/json_annotation.dart';

part 'order.model.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {
  final int? orderId;
  final String? orderNumber;
  final String? orderStatus;
  final String? deliveryAddress;
  final String? contactNumber;
  final String? specialInstructions;
  final double? subTotal;
  final double? deliveryFee;
  final double? discountAmount;
  final double? finalAmount;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? orderPlacedAt;
  final String? orderConfirmedAt;
  final String? foodReadyAt;
  final String? pickedUpAt;
  final String? deliveredAt;
  final String? cancelledAt;
  final String? createdAt;
  final String? updatedAt;
  final String? estimatedDeliveryTime;

  // Tracking-specific fields
  final String? currentStatus;
  final List<OrderStatusHistory>? statusHistory;
  final String? deliveryPersonName;
  final String? deliveryPersonContact;
  final double? distanceRemaining;
  final int? estimatedMinutesRemaining;

  final String? cancellationReason;
  final int? customerId;
  final int? restaurantId;
  final int? bikerId;
  final List<OrderItem>? items;

  Order({
    this.orderId,
    this.orderNumber,
    this.orderStatus,
    this.deliveryAddress,
    this.contactNumber,
    this.specialInstructions,
    this.subTotal,
    this.deliveryFee,
    this.discountAmount,
    this.finalAmount,
    this.paymentMethod,
    this.paymentStatus,
    this.orderPlacedAt,
    this.orderConfirmedAt,
    this.foodReadyAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
    this.estimatedDeliveryTime,
    this.currentStatus,
    this.statusHistory,
    this.deliveryPersonName,
    this.deliveryPersonContact,
    this.distanceRemaining,
    this.estimatedMinutesRemaining,
    this.cancellationReason,
    this.customerId,
    this.restaurantId,
    this.bikerId,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable()
class OrderStatusHistory {
  final String? status;
  final String? timestamp;
  final String? message;

  OrderStatusHistory({this.status, this.timestamp, this.message});

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatusHistoryToJson(this);
}



@JsonSerializable(explicitToJson: true)
class OrderItem {
  final int itemId;
  final int menuItemId;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? specialInstructions;
  final List<int>? variantIds;

  OrderItem({
    required this.itemId,
    required this.menuItemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.specialInstructions,
    this.variantIds,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}
