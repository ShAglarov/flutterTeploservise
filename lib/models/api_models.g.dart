// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

APIUserResponse _$APIUserResponseFromJson(Map<String, dynamic> json) =>
    APIUserResponse(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      isActive: json['is_active'] as bool? ?? true,
      isBlocked: json['is_blocked'] as bool?,
      isDeleted: json['is_deleted'] as bool?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      lastLoginAt: json['last_login_at'] as String?,
      isOnline: json['is_online'] as bool?,
    );

Map<String, dynamic> _$APIUserResponseToJson(APIUserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'full_name': instance.fullName,
      'role': _$UserRoleEnumMap[instance.role]!,
      'is_active': instance.isActive,
      'is_blocked': instance.isBlocked,
      'is_deleted': instance.isDeleted,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'last_login_at': instance.lastLoginAt,
      'is_online': instance.isOnline,
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.manager: 'manager',
  UserRole.operatorUser: 'operator',
  UserRole.guest: 'guest',
  UserRole.viewer: 'viewer',
};

APILoginResponse _$APILoginResponseFromJson(Map<String, dynamic> json) =>
    APILoginResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String,
    );

Map<String, dynamic> _$APILoginResponseToJson(APILoginResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'token_type': instance.tokenType,
    };
