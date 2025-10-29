import 'package:json_annotation/json_annotation.dart';
import 'order.model.dart';

part 'payment.model.g.dart';

@JsonSerializable(explicitToJson: true)
class Payment {
  @JsonKey(name: '_id')
  final String? id;
  final Order order;
  final String paymentMethod;
  final double amount;
  final String status;
  final String? phone;
  final String? transactionId;
  final String? referenceId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Payment({
    this.id,
    required this.order,
    required this.paymentMethod,
    required this.amount,
    required this.status,
    this.phone,
    this.transactionId,
    this.referenceId,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
