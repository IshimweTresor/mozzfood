import 'package:json_annotation/json_annotation.dart';
import '../utils/date_parser.dart';

part 'order.model.g.dart';

// Helper function to safely convert dynamic values to String
String? _safeStringFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) {
    // If it's a map, try to extract a meaningful string value
    // Common patterns: {address: "..."}, {street: "...", city: "..."}
    if (value.containsKey('address')) return value['address']?.toString();
    if (value.containsKey('street')) {
      final parts = [
        value['street'],
        value['city'],
        value['state'],
        value['country'],
      ].where((e) => e != null).join(', ');
      return parts.isNotEmpty ? parts : null;
    }
    // Fallback: return JSON string representation
    return value.toString();
  }
  return value.toString();
}

// Helper function to safely convert date arrays or strings to ISO8601 strings
String? _safeDateFromJson(dynamic value) {
  return DateParser.toIso8601(value);
}

@JsonSerializable(explicitToJson: true)
class Order {
  final int? orderId;
  final String? orderNumber;
  final String? orderStatus;

  @JsonKey(fromJson: _safeStringFromJson)
  final String? deliveryAddress;

  @JsonKey(name: 'phoneNumber')
  final String? contactNumber;
  final String? specialInstructions;
  final double? subTotal;
  final double? deliveryFee;
  final double? discountAmount;
  final double? finalAmount;
  final String? paymentMethod;
  final String? paymentStatus;

  @JsonKey(fromJson: _safeDateFromJson)
  final String? orderPlacedAt;

  @JsonKey(fromJson: _safeDateFromJson)
  final String? orderConfirmedAt;

  @JsonKey(fromJson: _safeDateFromJson)
  final String? foodReadyAt;

  @JsonKey(fromJson: _safeDateFromJson)
  final String? pickedUpAt;

  @JsonKey(fromJson: _safeDateFromJson)
  final String? deliveredAt;

  @JsonKey(fromJson: _safeDateFromJson)
  final String? cancelledAt;

  @JsonKey(fromJson: _safeDateFromJson)
  final String? createdAt;

  @JsonKey(fromJson: _safeDateFromJson)
  final String? updatedAt;

  @JsonKey(fromJson: _safeStringFromJson)
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

  @JsonKey(fromJson: _safeDateFromJson)
  final String? timestamp;

  final String? message;

  OrderStatusHistory({this.status, this.timestamp, this.message});

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatusHistoryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class OrderItem {
  @JsonKey(name: 'orderItemId')
  final int itemId;
  final int menuItemId;
  @JsonKey(name: 'menuItemName')
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  @JsonKey(name: 'specialRequests')
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
