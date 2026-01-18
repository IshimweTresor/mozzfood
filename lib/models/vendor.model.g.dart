// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vendor _$VendorFromJson(Map<String, dynamic> json) => Vendor(
  restaurantId: (json['restaurantId'] as num?)?.toInt(),
  restaurantName: json['restaurantName'] as String?,
  location: json['location'] as String?,
  cuisineType: json['cuisineType'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  description: json['description'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  totalOrders: (json['totalOrders'] as num?)?.toInt(),
  totalReviews: (json['totalReviews'] as num?)?.toInt(),
  averagePreparationTime: (json['averagePreparationTime'] as num?)?.toInt(),
  deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
  minimumOrderAmount: (json['minimumOrderAmount'] as num?)?.toDouble(),
  operatingHours: json['operatingHours'] as String?,
  image: json['image'] as String?,
  logo: json['logo'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  active: json['active'] as bool?,
);

Map<String, dynamic> _$VendorToJson(Vendor instance) => <String, dynamic>{
  'restaurantId': instance.restaurantId,
  'restaurantName': instance.restaurantName,
  'location': instance.location,
  'cuisineType': instance.cuisineType,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'description': instance.description,
  'rating': instance.rating,
  'totalOrders': instance.totalOrders,
  'totalReviews': instance.totalReviews,
  'averagePreparationTime': instance.averagePreparationTime,
  'deliveryFee': instance.deliveryFee,
  'minimumOrderAmount': instance.minimumOrderAmount,
  'operatingHours': instance.operatingHours,
  'image': instance.image,
  'logo': instance.logo,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'active': instance.active,
};
