// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_location_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLocationsResponse _$UserLocationsResponseFromJson(
  Map<String, dynamic> json,
) => UserLocationsResponse(
  savedLocations:
      (json['savedLocations'] as List<dynamic>)
          .map((e) => SavedLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
  preferences: LocationPreferences.fromJson(
    json['preferences'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$UserLocationsResponseToJson(
  UserLocationsResponse instance,
) => <String, dynamic>{
  'savedLocations': instance.savedLocations,
  'preferences': instance.preferences,
};

NearbyVendorsResponse _$NearbyVendorsResponseFromJson(
  Map<String, dynamic> json,
) => NearbyVendorsResponse(
  vendors:
      (json['vendors'] as List<dynamic>)
          .map((e) => VendorWithDistance.fromJson(e as Map<String, dynamic>))
          .toList(),
  searchLocation: SearchLocation.fromJson(
    json['searchLocation'] as Map<String, dynamic>,
  ),
  radius: (json['radius'] as num).toDouble(),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$NearbyVendorsResponseToJson(
  NearbyVendorsResponse instance,
) => <String, dynamic>{
  'vendors': instance.vendors,
  'searchLocation': instance.searchLocation,
  'radius': instance.radius,
  'count': instance.count,
};

VendorWithDistance _$VendorWithDistanceFromJson(Map<String, dynamic> json) =>
    VendorWithDistance(
      id: json['_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      address: json['address'] as String,
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      isOpen: json['isOpen'] as bool,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      rating: (json['rating'] as num).toDouble(),
      totalRatings: (json['totalRatings'] as num).toInt(),
      distance: (json['distance'] as num).toDouble(),
      ownerId:
          json['ownerId'] == null
              ? null
              : VendorOwner.fromJson(json['ownerId'] as Map<String, dynamic>),
      menuItems:
          (json['menuItems'] as List<dynamic>?)
              ?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$VendorWithDistanceToJson(VendorWithDistance instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'location': instance.location,
      'isOpen': instance.isOpen,
      'phone': instance.phone,
      'email': instance.email,
      'rating': instance.rating,
      'totalRatings': instance.totalRatings,
      'distance': instance.distance,
      'ownerId': instance.ownerId,
      'menuItems': instance.menuItems,
    };

SearchLocation _$SearchLocationFromJson(Map<String, dynamic> json) =>
    SearchLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

Map<String, dynamic> _$SearchLocationToJson(SearchLocation instance) =>
    <String, dynamic>{'lat': instance.lat, 'lng': instance.lng};

VendorOwner _$VendorOwnerFromJson(Map<String, dynamic> json) => VendorOwner(
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
);

Map<String, dynamic> _$VendorOwnerToJson(VendorOwner instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
    };

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  category: json['category'] as String,
  availability: json['availability'] as bool,
);

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
  'name': instance.name,
  'price': instance.price,
  'category': instance.category,
  'availability': instance.availability,
};
