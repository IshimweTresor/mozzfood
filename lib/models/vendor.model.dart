import 'package:json_annotation/json_annotation.dart';

part 'vendor.model.g.dart';

@JsonSerializable(explicitToJson: true)
class Vendor {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;
  final String? address;
  final String? description;
  final Location? location;
  final Owner? ownerId;
  final List<dynamic>? menuItems;
  final bool? isOpen;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  @JsonKey(name: '__v')
  final int? v;
  final String? imageUrl;

  Vendor({
    this.id,
    this.name,
    this.address,
    this.description,
    this.location,
    this.ownerId,
    this.menuItems,
    this.isOpen,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.imageUrl,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
  Map<String, dynamic> toJson() => _$VendorToJson(this);
}

@JsonSerializable()
class Owner {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;
  final String? phone;
  final String? email;
  final bool? isVerified;

  Owner({this.id, this.name, this.phone, this.email, this.isVerified});

  factory Owner.fromJson(Map<String, dynamic> json) => _$OwnerFromJson(json);
  Map<String, dynamic> toJson() => _$OwnerToJson(this);
}

@JsonSerializable()
class Location {
  final double? lat;
  final double? lng;

  Location({this.lat, this.lng});

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
