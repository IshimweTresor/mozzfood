// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    RegisterResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      requiresVerification: json['requiresVerification'] as bool,
      data:
          json['data'] == null
              ? null
              : RegisteredUserData.fromJson(
                json['data'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'requiresVerification': instance.requiresVerification,
      'data': instance.data,
    };

RegisteredUserData _$RegisteredUserDataFromJson(Map<String, dynamic> json) =>
    RegisteredUserData(
      customerId: (json['customerId'] as num).toInt(),
      fullNames: json['fullNames'] as String,
      location: json['location'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String,
      roles: json['roles'] as String,
      emailVerified: json['emailVerified'] as bool,
      phoneVerified: json['phoneVerified'] as bool,
      lastLogin: json['lastLogin'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      active: json['active'] as bool,
    );

Map<String, dynamic> _$RegisteredUserDataToJson(RegisteredUserData instance) =>
    <String, dynamic>{
      'customerId': instance.customerId,
      'fullNames': instance.fullNames,
      'location': instance.location,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'roles': instance.roles,
      'emailVerified': instance.emailVerified,
      'phoneVerified': instance.phoneVerified,
      'lastLogin': instance.lastLogin,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'active': instance.active,
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
