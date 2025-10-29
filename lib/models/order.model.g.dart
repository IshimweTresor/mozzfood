// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: json['_id'] as String?,
  userId: User.fromJson(json['userId'] as Map<String, dynamic>),
  restaurantId: (json['restaurantId'] as num).toInt(),
  riderId: json['riderId'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  paymentStatus: json['paymentStatus'] as String,
  orderStatus: json['orderStatus'] as String,
  location: DeliveryLocation.fromJson(json['location'] as Map<String, dynamic>),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  '_id': instance.id,
  'userId': instance.userId.toJson(),
  'restaurantId': instance.restaurantId,
  'riderId': instance.riderId,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'totalPrice': instance.totalPrice,
  'paymentStatus': instance.paymentStatus,
  'orderStatus': instance.orderStatus,
  'location': instance.location.toJson(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['_id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'phone': instance.phone,
  'email': instance.email,
};

DeliveryLocation _$DeliveryLocationFromJson(Map<String, dynamic> json) =>
    DeliveryLocation(
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$DeliveryLocationToJson(DeliveryLocation instance) =>
    <String, dynamic>{
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  itemId: MenuItem.fromJson(json['itemId'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num).toInt(),
  specialInstructions: json['specialInstructions'] as String?,
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'itemId': instance.itemId.toJson(),
  'quantity': instance.quantity,
  'specialInstructions': instance.specialInstructions,
};
