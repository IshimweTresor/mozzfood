// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  orderId: (json['orderId'] as num?)?.toInt(),
  orderNumber: json['orderNumber'] as String?,
  orderStatus: json['orderStatus'] as String?,
  deliveryAddress: json['deliveryAddress'] as String?,
  contactNumber: json['contactNumber'] as String?,
  specialInstructions: json['specialInstructions'] as String?,
  subTotal: (json['subTotal'] as num?)?.toDouble(),
  deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
  discountAmount: (json['discountAmount'] as num?)?.toDouble(),
  finalAmount: (json['finalAmount'] as num?)?.toDouble(),
  paymentMethod: json['paymentMethod'] as String?,
  paymentStatus: json['paymentStatus'] as String?,
  orderPlacedAt: json['orderPlacedAt'] as String?,
  orderConfirmedAt: json['orderConfirmedAt'] as String?,
  foodReadyAt: json['foodReadyAt'] as String?,
  pickedUpAt: json['pickedUpAt'] as String?,
  deliveredAt: json['deliveredAt'] as String?,
  cancelledAt: json['cancelledAt'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  estimatedDeliveryTime: json['estimatedDeliveryTime'] as String?,
  currentStatus: json['currentStatus'] as String?,
  statusHistory: (json['statusHistory'] as List<dynamic>?)
      ?.map((e) => OrderStatusHistory.fromJson(e as Map<String, dynamic>))
      .toList(),
  deliveryPersonName: json['deliveryPersonName'] as String?,
  deliveryPersonContact: json['deliveryPersonContact'] as String?,
  distanceRemaining: (json['distanceRemaining'] as num?)?.toDouble(),
  estimatedMinutesRemaining: (json['estimatedMinutesRemaining'] as num?)
      ?.toInt(),
  cancellationReason: json['cancellationReason'] as String?,
  customerId: (json['customerId'] as num?)?.toInt(),
  restaurantId: (json['restaurantId'] as num?)?.toInt(),
  bikerId: (json['bikerId'] as num?)?.toInt(),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'orderId': instance.orderId,
  'orderNumber': instance.orderNumber,
  'orderStatus': instance.orderStatus,
  'deliveryAddress': instance.deliveryAddress,
  'contactNumber': instance.contactNumber,
  'specialInstructions': instance.specialInstructions,
  'subTotal': instance.subTotal,
  'deliveryFee': instance.deliveryFee,
  'discountAmount': instance.discountAmount,
  'finalAmount': instance.finalAmount,
  'paymentMethod': instance.paymentMethod,
  'paymentStatus': instance.paymentStatus,
  'orderPlacedAt': instance.orderPlacedAt,
  'orderConfirmedAt': instance.orderConfirmedAt,
  'foodReadyAt': instance.foodReadyAt,
  'pickedUpAt': instance.pickedUpAt,
  'deliveredAt': instance.deliveredAt,
  'cancelledAt': instance.cancelledAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'estimatedDeliveryTime': instance.estimatedDeliveryTime,
  'currentStatus': instance.currentStatus,
  'statusHistory': instance.statusHistory?.map((e) => e.toJson()).toList(),
  'deliveryPersonName': instance.deliveryPersonName,
  'deliveryPersonContact': instance.deliveryPersonContact,
  'distanceRemaining': instance.distanceRemaining,
  'estimatedMinutesRemaining': instance.estimatedMinutesRemaining,
  'cancellationReason': instance.cancellationReason,
  'customerId': instance.customerId,
  'restaurantId': instance.restaurantId,
  'bikerId': instance.bikerId,
  'items': instance.items?.map((e) => e.toJson()).toList(),
};

OrderStatusHistory _$OrderStatusHistoryFromJson(Map<String, dynamic> json) =>
    OrderStatusHistory(
      status: json['status'] as String?,
      timestamp: json['timestamp'] as String?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$OrderStatusHistoryToJson(OrderStatusHistory instance) =>
    <String, dynamic>{
      'status': instance.status,
      'timestamp': instance.timestamp,
      'message': instance.message,
    };

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  itemId: (json['itemId'] as num).toInt(),
  menuItemId: (json['menuItemId'] as num).toInt(),
  itemName: json['itemName'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: (json['unitPrice'] as num).toDouble(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  specialInstructions: json['specialInstructions'] as String?,
  variantIds: (json['variantIds'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'itemId': instance.itemId,
  'menuItemId': instance.menuItemId,
  'itemName': instance.itemName,
  'quantity': instance.quantity,
  'unitPrice': instance.unitPrice,
  'totalPrice': instance.totalPrice,
  'specialInstructions': instance.specialInstructions,
  'variantIds': instance.variantIds,
};
