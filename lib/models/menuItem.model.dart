import 'package:json_annotation/json_annotation.dart';

part 'menuItem.model.g.dart';

@JsonSerializable(explicitToJson: true)
class MenuItem {
  @JsonKey(name: '_id')
  final String? id;
  final Vendor? vendorId;
  final String? name;
  final String? description;
  final int? price;
  final String? imageUrl;
  final String? category;
  final bool? availability;
  final String? type;
  final int? volumeMl;
  final bool? canBeOrderedAlone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  @JsonKey(name: '__v')
  final int? v;

  MenuItem({
    this.id,
    this.vendorId,
    this.name,
    this.description,
    this.price,
    this.imageUrl,
    this.category,
    this.availability,
    this.type,
    this.volumeMl,
    this.canBeOrderedAlone,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
}

@JsonSerializable()
class Vendor {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;
  final String? address;
  final Location? location;

  Vendor({this.id, this.name, this.address, this.location});

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
  Map<String, dynamic> toJson() => _$VendorToJson(this);
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
