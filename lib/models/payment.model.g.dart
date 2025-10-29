// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: json['_id'] as String?,
  order: Order.fromJson(json['order'] as Map<String, dynamic>),
  paymentMethod: json['paymentMethod'] as String,
  amount: (json['amount'] as num).toDouble(),
  status: json['status'] as String,
  phone: json['phone'] as String?,
  transactionId: json['transactionId'] as String?,
  referenceId: json['referenceId'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  '_id': instance.id,
  'order': instance.order.toJson(),
  'paymentMethod': instance.paymentMethod,
  'amount': instance.amount,
  'status': instance.status,
  'phone': instance.phone,
  'transactionId': instance.transactionId,
  'referenceId': instance.referenceId,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
