import 'package:json_annotation/json_annotation.dart';

enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('operator')
  operatorUser,
  @JsonValue('guest')
  guest,
  @JsonValue('viewer')
  viewer;

  // Added custom fromJson hook to handle enum parsing safely
  static UserRole fromJson(String? value) {
    if (value == null) return UserRole.viewer;
    return UserRole.fromAnyString(value);
  }

  String get serverValue {
    return switch (this) {
      UserRole.admin => 'ADMIN',
      UserRole.manager => 'SITE_MANAGER',
      UserRole.operatorUser => 'OPERATOR',
      UserRole.guest => 'GUEST',
      UserRole.viewer => 'OBSERVER',
    };
  }

  String toJson() => serverValue;

  String get title {
    return switch (this) {
      UserRole.admin => 'Администратор',
      UserRole.manager => 'Начальник участка',
      UserRole.operatorUser => 'Оператор',
      UserRole.guest => 'Гость',
      UserRole.viewer => 'Наблюдатель',
    };
  }

  String get iconName {
    return switch (this) {
      UserRole.admin => 'crown_fill',
      UserRole.manager => 'person_2_fill',
      UserRole.operatorUser => 'person_crop_circle_badge_exclamationmark',
      UserRole.guest => 'person_crop_circle_badge_questionmark',
      UserRole.viewer => 'eye',
    };
  }

  bool get canEditData {
    return switch (this) {
      UserRole.admin || UserRole.manager || UserRole.operatorUser => true,
      UserRole.guest || UserRole.viewer => false,
    };
  }

  bool get canDeleteData {
    return switch (this) {
      UserRole.admin || UserRole.manager => true,
      _ => false,
    };
  }

  bool get canManageUsers {
    return this == UserRole.admin;
  }

  bool get canViewIncidents => true;
  
  static UserRole fromAnyString(String? value) {
    if (value == null || value.trim().isEmpty) {
      return UserRole.viewer;
    }

    final normalized = value.toLowerCase().trim();

    final match = UserRole.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized || 
             (e == UserRole.operatorUser && normalized == 'operator'),
      orElse: () => UserRole.viewer,
    );
    
    if (match != UserRole.viewer) return match;

    return switch (normalized) {
      'admin' || 'administrator' || 'superadmin' || 'root' => UserRole.admin,
      'manager' || 'lead' || 'supervisor' => UserRole.manager,
      'operator' || 'operator_user' || 'staff' => UserRole.operatorUser,
      'guest' || 'visitor' => UserRole.guest,
      'viewer' || 'observer' => UserRole.viewer,
      _ => UserRole.viewer,
    };
  }
}
