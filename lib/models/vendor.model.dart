import 'package:json_annotation/json_annotation.dart';

part 'vendor.model.g.dart';

@JsonSerializable(explicitToJson: true)
class Vendor {
  final int? restaurantId;
  final String? restaurantName;
  final String? location;
  final String? cuisineType;
  final String? email;
  final String? phoneNumber;
  final String? description;
  final double? rating;
  final int? totalOrders;
  final int? totalReviews;
  final int? averagePreparationTime;
  final double? deliveryFee;
  final double? minimumOrderAmount;
  final String? operatingHours;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? active;

  Vendor({
    this.restaurantId,
    this.restaurantName,
    this.location,
    this.cuisineType,
    this.email,
    this.phoneNumber,
    this.description,
    this.rating,
    this.totalOrders,
    this.totalReviews,
    this.averagePreparationTime,
    this.deliveryFee,
    this.minimumOrderAmount,
    this.operatingHours,
    this.createdAt,
    this.updatedAt,
    this.active,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);
  Map<String, dynamic> toJson() => _$VendorToJson(this);
}
