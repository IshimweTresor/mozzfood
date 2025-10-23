// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    RegisterResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      verificationKey: json['verificationKey'] as String,
      sentVia: json['sentVia'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
    );

Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'verificationKey': instance.verificationKey,
      'sentVia': instance.sentVia,
      'expiresIn': instance.expiresIn,
    };

ResendCodeResponse _$ResendCodeResponseFromJson(Map<String, dynamic> json) =>
    ResendCodeResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      sentVia: json['sentVia'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
    );

Map<String, dynamic> _$ResendCodeResponseToJson(ResendCodeResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'sentVia': instance.sentVia,
      'expiresIn': instance.expiresIn,
    };

ForgotPasswordResponse _$ForgotPasswordResponseFromJson(
  Map<String, dynamic> json,
) => ForgotPasswordResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  resetKey: json['resetKey'] as String,
  sentVia: json['sentVia'] as String,
  expiresIn: (json['expiresIn'] as num).toInt(),
);

Map<String, dynamic> _$ForgotPasswordResponseToJson(
  ForgotPasswordResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'resetKey': instance.resetKey,
  'sentVia': instance.sentVia,
  'expiresIn': instance.expiresIn,
};

VerifyResetCodeResponse _$VerifyResetCodeResponseFromJson(
  Map<String, dynamic> json,
) => VerifyResetCodeResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  resetKey: json['resetKey'] as String,
  expiresIn: (json['expiresIn'] as num).toInt(),
);

Map<String, dynamic> _$VerifyResetCodeResponseToJson(
  VerifyResetCodeResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'resetKey': instance.resetKey,
  'expiresIn': instance.expiresIn,
};
