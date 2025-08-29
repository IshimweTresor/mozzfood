// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: json['_id'] as String?,
  userId: User.fromJson(json['userId'] as Map<String, dynamic>),
  vendorId: Vendor.fromJson(json['vendorId'] as Map<String, dynamic>),
  riderId: json['riderId'] as String?,
  items:
      (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  paymentStatus: json['paymentStatus'] as String,
  orderStatus: json['orderStatus'] as String,
  location: Location.fromJson(json['location'] as Map<String, dynamic>),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  '_id': instance.id,
  'userId': instance.userId.toJson(),
  'vendorId': instance.vendorId.toJson(),
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

Vendor _$VendorFromJson(Map<String, dynamic> json) => Vendor(
  id: json['_id'] as String,
  name: json['name'] as String,
  address: json['address'] as String,
  location: Location.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VendorToJson(Vendor instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'location': instance.location.toJson(),
};

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  itemId: MenuItem.fromJson(json['itemId'] as Map<String, dynamic>),
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'itemId': instance.itemId.toJson(),
  'quantity': instance.quantity,
};
