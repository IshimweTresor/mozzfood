// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsersListResponse _$UsersListResponseFromJson(Map<String, dynamic> json) =>
    UsersListResponse(
      users: (json['users'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationInfo.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
      statistics: UserStatistics.fromJson(
        json['statistics'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$UsersListResponseToJson(UsersListResponse instance) =>
    <String, dynamic>{
      'users': instance.users,
      'pagination': instance.pagination,
      'statistics': instance.statistics,
    };

PaginationInfo _$PaginationInfoFromJson(Map<String, dynamic> json) =>
    PaginationInfo(
      currentPage: (json['currentPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      totalUsers: (json['totalUsers'] as num).toInt(),
      hasNextPage: json['hasNextPage'] as bool,
      hasPrevPage: json['hasPrevPage'] as bool,
    );

Map<String, dynamic> _$PaginationInfoToJson(PaginationInfo instance) =>
    <String, dynamic>{
      'currentPage': instance.currentPage,
      'totalPages': instance.totalPages,
      'totalUsers': instance.totalUsers,
      'hasNextPage': instance.hasNextPage,
      'hasPrevPage': instance.hasPrevPage,
    };

UserStatistics _$UserStatisticsFromJson(Map<String, dynamic> json) =>
    UserStatistics(
      total: (json['total'] as num).toInt(),
      verified: (json['verified'] as num).toInt(),
      unverified: (json['unverified'] as num).toInt(),
      byRole: Map<String, int>.from(json['byRole'] as Map),
    );

Map<String, dynamic> _$UserStatisticsToJson(UserStatistics instance) =>
    <String, dynamic>{
      'total': instance.total,
      'verified': instance.verified,
      'unverified': instance.unverified,
      'byRole': instance.byRole,
    };

RoleHistoryResponse _$RoleHistoryResponseFromJson(Map<String, dynamic> json) =>
    RoleHistoryResponse(
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      roleHistory: (json['roleHistory'] as List<dynamic>)
          .map((e) => RoleHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoleHistoryResponseToJson(
  RoleHistoryResponse instance,
) => <String, dynamic>{
  'user': instance.user,
  'roleHistory': instance.roleHistory,
};

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  currentRole: json['currentRole'] as String,
);

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'currentRole': instance.currentRole,
};
