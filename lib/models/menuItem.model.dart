import 'package:json_annotation/json_annotation.dart';

part 'menuItem.model.g.dart';

@JsonSerializable(explicitToJson: true)
class MenuItem {
  final int id;
  @JsonKey(name: 'menuItemName')
  final String name;
  final String description;
  final double price;
  @JsonKey(name: 'image')
  final String imageUrl;
  final String ingredients;
  final int preparationTime;
  final int preparationScore;
  final int restaurantId;
  final int categoryId;
  final String categoryName;
  final DateTime createdAt;
  final DateTime updatedAt;
  @JsonKey(name: 'available')
  final bool availability;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.ingredients,
    required this.preparationTime,
    required this.preparationScore,
    required this.restaurantId,
    required this.categoryId,
    required this.categoryName,
    required this.createdAt,
    required this.updatedAt,
    required this.availability,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
}
