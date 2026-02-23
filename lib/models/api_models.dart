import 'package:json_annotation/json_annotation.dart';
import 'user_role.dart';

part 'api_models.g.dart';

@JsonSerializable()
class APIUserResponse {
  final int id;
  final String username;
  final String email;
  @JsonKey(name: 'full_name')
  final String? fullName;
  final UserRole role;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_blocked')
  final bool? isBlocked;
  @JsonKey(name: 'is_deleted')
  final bool? isDeleted;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'last_login_at')
  final String? lastLoginAt;
  @JsonKey(name: 'is_online')
  final bool? isOnline;

  APIUserResponse({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    required this.role,
    this.isActive = true,
    this.isBlocked,
    this.isDeleted,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.isOnline,
  });

  factory APIUserResponse.fromJson(Map<String, dynamic> json) => _$APIUserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$APIUserResponseToJson(this);
}

@JsonSerializable()
class APILoginResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  @JsonKey(name: 'token_type')
  final String tokenType;

  APILoginResponse({
    required this.accessToken,
    this.refreshToken,
    required this.tokenType,
  });

  factory APILoginResponse.fromJson(Map<String, dynamic> json) => _$APILoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$APILoginResponseToJson(this);
}
