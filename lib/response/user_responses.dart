import 'package:json_annotation/json_annotation.dart';
import '../models/user.model.dart';  // Fixed import path

part 'user_responses.g.dart';

@JsonSerializable()
class UsersListResponse {
  final List<User> users;
  final PaginationInfo pagination;
  final UserStatistics statistics;

  UsersListResponse({
    required this.users,
    required this.pagination,
    required this.statistics,
  });

  factory UsersListResponse.fromJson(Map<String, dynamic> json) => _$UsersListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UsersListResponseToJson(this);
}

@JsonSerializable()
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalUsers;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalUsers,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => _$PaginationInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationInfoToJson(this);
}

@JsonSerializable()
class UserStatistics {
  final int total;
  final int verified;
  final int unverified;
  final Map<String, int> byRole;

  UserStatistics({
    required this.total,
    required this.verified,
    required this.unverified,
    required this.byRole,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) => _$UserStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatisticsToJson(this);
}

@JsonSerializable()
class RoleHistoryResponse {
  final UserInfo user;
  final List<RoleHistory> roleHistory;

  RoleHistoryResponse({
    required this.user,
    required this.roleHistory,
  });

  factory RoleHistoryResponse.fromJson(Map<String, dynamic> json) => _$RoleHistoryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RoleHistoryResponseToJson(this);
}

@JsonSerializable()
class UserInfo {
  final String id;
  final String name;
  final String email;
  final String currentRole;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.currentRole,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}