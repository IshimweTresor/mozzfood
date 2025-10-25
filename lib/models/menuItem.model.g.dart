// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menuItem.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
  id: (json['id'] as num).toInt(),
  name: json['menuItemName'] as String,
  description: json['description'] as String,
  price: (json['price'] as num).toDouble(),
  imageUrl: json['image'] as String,
  ingredients: json['ingredients'] as String,
  preparationTime: (json['preparationTime'] as num).toInt(),
  preparationScore: (json['preparationScore'] as num).toInt(),
  restaurantId: (json['restaurantId'] as num).toInt(),
  categoryId: (json['categoryId'] as num).toInt(),
  categoryName: json['categoryName'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  availability: json['available'] as bool,
);

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
  'id': instance.id,
  'menuItemName': instance.name,
  'description': instance.description,
  'price': instance.price,
  'image': instance.imageUrl,
  'ingredients': instance.ingredients,
  'preparationTime': instance.preparationTime,
  'preparationScore': instance.preparationScore,
  'restaurantId': instance.restaurantId,
  'categoryId': instance.categoryId,
  'categoryName': instance.categoryName,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'available': instance.availability,
};
