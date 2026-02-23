import 'package:json_annotation/json_annotation.dart';
import 'user_role.dart';

part 'auth_user.g.dart';

@JsonSerializable()
class AuthUser {
  final String id;
  final String username;
  final String displayName;
  final String? email;
  
  @JsonKey(
    fromJson: _roleFromJson,
    toJson: _roleToJson,
  )
  final UserRole role;
  
  final String? passwordHash;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  AuthUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.email,
    this.role = UserRole.viewer,
    this.passwordHash,
    this.createdAt,
    this.lastLoginAt,
  });

  bool get isAdmin => role == UserRole.admin;

  String get safeDisplayName => displayName.isEmpty ? username : displayName;

  String get initials {
    final components = safeDisplayName.split(' ');
    final first = components.isNotEmpty && components.first.isNotEmpty
        ? components.first[0]
        : (username.isNotEmpty ? username[0] : '');
    final last = components.length > 1 && components[1].isNotEmpty
        ? components[1][0]
        : '';
    return (first + last).toUpperCase();
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);
  Map<String, dynamic> toJson() => _$AuthUserToJson(this);

  static UserRole _roleFromJson(dynamic roleValue) {
    if (roleValue is String) {
      return UserRole.fromAnyString(roleValue);
    }
    return UserRole.viewer;
  }

  static String _roleToJson(UserRole role) => role.name;
}
