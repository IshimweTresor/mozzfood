// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['_id'] as String?,
  name: json['name'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  isVerified: json['isVerified'] as bool?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  location:
      json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
  savedLocations:
      (json['savedLocations'] as List<dynamic>?)
          ?.map((e) => SavedLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
  locationPreferences:
      json['locationPreferences'] == null
          ? null
          : LocationPreferences.fromJson(
            json['locationPreferences'] as Map<String, dynamic>,
          ),
  roleHistory:
      (json['roleHistory'] as List<dynamic>?)
          ?.map((e) => RoleHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'phone': instance.phone,
  'email': instance.email,
  'role': instance.role,
  'isVerified': instance.isVerified,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'location': instance.location?.toJson(),
  'savedLocations': instance.savedLocations?.map((e) => e.toJson()).toList(),
  'locationPreferences': instance.locationPreferences?.toJson(),
  'roleHistory': instance.roleHistory?.map((e) => e.toJson()).toList(),
};

SavedLocation _$SavedLocationFromJson(Map<String, dynamic> json) =>
    SavedLocation(
      name: json['name'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      phone: json['phone'] as String?,
      isDefault: json['isDefault'] as bool?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SavedLocationToJson(SavedLocation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'lat': instance.lat,
      'lng': instance.lng,
      'phone': instance.phone,
      'isDefault': instance.isDefault,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

LocationPreferences _$LocationPreferencesFromJson(Map<String, dynamic> json) =>
    LocationPreferences(
      addressUsageOption: json['addressUsageOption'] as String?,
      country: json['country'] as String?,
      province: json['province'] as String?,
    );

Map<String, dynamic> _$LocationPreferencesToJson(
  LocationPreferences instance,
) => <String, dynamic>{
  'addressUsageOption': instance.addressUsageOption,
  'country': instance.country,
  'province': instance.province,
};

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
};

RoleHistory _$RoleHistoryFromJson(Map<String, dynamic> json) => RoleHistory(
  previousRole: json['previousRole'] as String?,
  newRole: json['newRole'] as String?,
  changedBy: json['changedBy'] as String?,
  changedAt:
      json['changedAt'] == null
          ? null
          : DateTime.parse(json['changedAt'] as String),
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$RoleHistoryToJson(RoleHistory instance) =>
    <String, dynamic>{
      'previousRole': instance.previousRole,
      'newRole': instance.newRole,
      'changedBy': instance.changedBy,
      'changedAt': instance.changedAt?.toIso8601String(),
      'reason': instance.reason,
    };
