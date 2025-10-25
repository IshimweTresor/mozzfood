import 'package:json_annotation/json_annotation.dart';
import '../models/user.model.dart';

part 'user_location_responses.g.dart';

@JsonSerializable()
class UserLocationsResponse {
  final List<SavedLocation> savedLocations;
  final LocationPreferences preferences;

  UserLocationsResponse({
    required this.savedLocations,
    required this.preferences,
  });

  factory UserLocationsResponse.fromJson(Map<String, dynamic> json) =>
      _$UserLocationsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserLocationsResponseToJson(this);
}

@JsonSerializable()
class CustomerAddressesResponse {
  final List<SavedLocation> addresses;

  CustomerAddressesResponse({required this.addresses});

  factory CustomerAddressesResponse.fromJson(Map<String, dynamic> json) =>
      _$CustomerAddressesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerAddressesResponseToJson(this);
}

@JsonSerializable()
class SavedLocationResponse {
  final SavedLocation address;

  SavedLocationResponse({required this.address});

  factory SavedLocationResponse.fromJson(Map<String, dynamic> json) =>
      _$SavedLocationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SavedLocationResponseToJson(this);
}

@JsonSerializable()
class NearbyVendorsResponse {
  final List<VendorWithDistance> vendors;
  final SearchLocation searchLocation;
  final double radius;
  final int count;

  NearbyVendorsResponse({
    required this.vendors,
    required this.searchLocation,
    required this.radius,
    required this.count,
  });

  factory NearbyVendorsResponse.fromJson(Map<String, dynamic> json) =>
      _$NearbyVendorsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NearbyVendorsResponseToJson(this);
}

@JsonSerializable()
class VendorWithDistance {
  @JsonKey(name: '_id')
  final String? id;
  final String name;
  final String description;
  final String address;
  final Location location;
  final bool isOpen;
  final String? phone;
  final String? email;
  final double rating;
  final int totalRatings;
  final double distance; // Distance in kilometers
  final VendorOwner? ownerId;
  final List<MenuItem>? menuItems;

  VendorWithDistance({
    this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.location,
    required this.isOpen,
    this.phone,
    this.email,
    required this.rating,
    required this.totalRatings,
    required this.distance,
    this.ownerId,
    this.menuItems,
  });

  factory VendorWithDistance.fromJson(Map<String, dynamic> json) =>
      _$VendorWithDistanceFromJson(json);
  Map<String, dynamic> toJson() => _$VendorWithDistanceToJson(this);
}

@JsonSerializable()
class SearchLocation {
  final double lat;
  final double lng;

  SearchLocation({required this.lat, required this.lng});

  factory SearchLocation.fromJson(Map<String, dynamic> json) =>
      _$SearchLocationFromJson(json);
  Map<String, dynamic> toJson() => _$SearchLocationToJson(this);
}

@JsonSerializable()
class VendorOwner {
  final String name;
  final String email;
  final String phone;

  VendorOwner({required this.name, required this.email, required this.phone});

  factory VendorOwner.fromJson(Map<String, dynamic> json) =>
      _$VendorOwnerFromJson(json);
  Map<String, dynamic> toJson() => _$VendorOwnerToJson(this);
}

@JsonSerializable()
class MenuItem {
  final String name;
  final double price;
  final String category;
  final bool availability;

  MenuItem({
    required this.name,
    required this.price,
    required this.category,
    required this.availability,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
}
