// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menuItem.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
  id: json['_id'] as String?,
  vendorId:
      json['vendorId'] == null
          ? null
          : Vendor.fromJson(json['vendorId'] as Map<String, dynamic>),
  name: json['name'] as String?,
  description: json['description'] as String?,
  price: (json['price'] as num?)?.toInt(),
  imageUrl: json['imageUrl'] as String?,
  category: json['category'] as String?,
  availability: json['availability'] as bool?,
  type: json['type'] as String?,
  volumeMl: (json['volumeMl'] as num?)?.toInt(),
  canBeOrderedAlone: json['canBeOrderedAlone'] as bool?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  v: (json['__v'] as num?)?.toInt(),
);

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
  '_id': instance.id,
  'vendorId': instance.vendorId?.toJson(),
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'imageUrl': instance.imageUrl,
  'category': instance.category,
  'availability': instance.availability,
  'type': instance.type,
  'volumeMl': instance.volumeMl,
  'canBeOrderedAlone': instance.canBeOrderedAlone,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  '__v': instance.v,
};

Vendor _$VendorFromJson(Map<String, dynamic> json) => Vendor(
  id: json['_id'] as String?,
  name: json['name'] as String?,
  address: json['address'] as String?,
  location:
      json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VendorToJson(Vendor instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'location': instance.location,
};

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
};
