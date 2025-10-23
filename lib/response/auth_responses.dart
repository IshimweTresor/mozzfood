import 'package:json_annotation/json_annotation.dart';
import '../models/user.model.dart';

part 'auth_responses.g.dart';

@JsonSerializable()
class RegisterResponse {
  final bool success;
  final String message;
  final String verificationKey;
  final String sentVia;
  final int expiresIn;

  RegisterResponse({
    required this.success,
    required this.message,
    required this.verificationKey,
    required this.sentVia,
    required this.expiresIn,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}

// LoginResponse moved to user.model.dart to match new backend structure

@JsonSerializable()
class ResendCodeResponse {
  final bool success;
  final String message;
  final String sentVia;
  final int expiresIn;

  ResendCodeResponse({
    required this.success,
    required this.message,
    required this.sentVia,
    required this.expiresIn,
  });

  factory ResendCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$ResendCodeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ResendCodeResponseToJson(this);
}

@JsonSerializable()
class ForgotPasswordResponse {
  final bool success;
  final String message;
  final String resetKey;
  final String sentVia;
  final int expiresIn;

  ForgotPasswordResponse({
    required this.success,
    required this.message,
    required this.resetKey,
    required this.sentVia,
    required this.expiresIn,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ForgotPasswordResponseToJson(this);
}

@JsonSerializable()
class VerifyResetCodeResponse {
  final bool success;
  final String message;
  final String resetKey;
  final int expiresIn;

  VerifyResetCodeResponse({
    required this.success,
    required this.message,
    required this.resetKey,
    required this.expiresIn,
  });

  factory VerifyResetCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$VerifyResetCodeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyResetCodeResponseToJson(this);
}
