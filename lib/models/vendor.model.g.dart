// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vendor _$VendorFromJson(Map<String, dynamic> json) => Vendor(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  address: json['address'] as String?,
  description: json['description'] as String?,
  location:
      json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
  ownerId:
      json['ownerId'] == null
          ? null
          : Owner.fromJson(json['ownerId'] as Map<String, dynamic>),
  menuItems: json['menuItems'] as List<dynamic>?,
  isOpen: json['isOpen'] as bool?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  v: (json['__v'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$VendorToJson(Vendor instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'description': instance.description,
  'location': instance.location?.toJson(),
  'ownerId': instance.ownerId?.toJson(),
  'menuItems': instance.menuItems,
  'isOpen': instance.isOpen,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  '__v': instance.v,
  'imageUrl': instance.imageUrl,
};

Owner _$OwnerFromJson(Map<String, dynamic> json) => Owner(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  isVerified: json['isVerified'] as bool?,
);

Map<String, dynamic> _$OwnerToJson(Owner instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'phone': instance.phone,
  'email': instance.email,
  'isVerified': instance.isVerified,
};

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
};
