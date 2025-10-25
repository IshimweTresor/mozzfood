import 'package:json_annotation/json_annotation.dart';

part 'user.model.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  @JsonKey(name: '_id')
  final String? id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Location? location; // Legacy location
  final List<SavedLocation>? savedLocations; // ✅ Added missing field
  final LocationPreferences? locationPreferences; // ✅ Added missing field
  final List<RoleHistory>? roleHistory;

  User({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.isVerified,
    this.createdAt,
    this.updatedAt,
    this.location,
    this.savedLocations, // ✅ Added
    this.locationPreferences, // ✅ Added
    this.roleHistory,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle both 'id' and '_id' field names
    final id = json['id'] ?? json['_id'];
    final modifiedJson = Map<String, dynamic>.from(json);
    modifiedJson['_id'] = id;

    return _$UserFromJson(modifiedJson);
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class SavedLocation {
  @JsonKey(name: '_id') // MongoDB uses _id
  final String? id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? phone;
  final String? imageUrl;
  final bool? isDefault;
  final DateTime? createdAt;

  SavedLocation({
    this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.phone,
    this.imageUrl,
    this.isDefault,
    this.createdAt,
  });

  factory SavedLocation.fromJson(Map<String, dynamic> json) =>
      _$SavedLocationFromJson(json);
  Map<String, dynamic> toJson() => _$SavedLocationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LocationPreferences {
  final String? addressUsageOption; // 'Remember' or 'Always Ask'
  final String? country;
  final String? province; // 'KIGALI', 'MUSANZE', 'RUBAVU', 'RUSIZI'

  LocationPreferences({this.addressUsageOption, this.country, this.province});

  factory LocationPreferences.fromJson(Map<String, dynamic> json) =>
      _$LocationPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$LocationPreferencesToJson(this);
}

// Legacy location for backward compatibility
@JsonSerializable()
class Location {
  final double? lat;
  final double? lng;

  Location({this.lat, this.lng});

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class RoleHistory {
  final String? previousRole;
  final String? newRole;
  final String? changedBy;
  final DateTime? changedAt;
  final String? reason;

  RoleHistory({
    this.previousRole,
    this.newRole,
    this.changedBy,
    this.changedAt,
    this.reason,
  });

  factory RoleHistory.fromJson(Map<String, dynamic> json) =>
      _$RoleHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$RoleHistoryToJson(this);
}

@JsonSerializable()
class LoginResponse {
  final String token;
  final String tokenType;
  final int id;
  final String email;
  final String role;
  final String fullName;
  final int? restaurantId;
  final String? restaurantName;

  LoginResponse({
    required this.token,
    required this.tokenType,
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    this.restaurantId,
    this.restaurantName,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
