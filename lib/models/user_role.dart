import 'package:json_annotation/json_annotation.dart';

enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('manager')
  manager,
  @JsonValue('dispatcher')
  dispatcher,
  @JsonValue('office_worker')
  officeWorker,
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
      UserRole.dispatcher => 'DISPATCHER',
      UserRole.officeWorker => 'OFFICE_WORKER',
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
      UserRole.dispatcher => 'Диспетчер',
      UserRole.officeWorker => 'Офисный сотрудник',
      UserRole.operatorUser => 'Оператор',
      UserRole.guest => 'Гость',
      UserRole.viewer => 'Наблюдатель',
    };
  }

  String get iconName {
    return switch (this) {
      UserRole.admin => 'crown_fill',
      UserRole.manager => 'person_2_fill',
      UserRole.dispatcher => 'antenna_radiowaves_left_and_right',
      UserRole.officeWorker => 'doc_text_fill',
      UserRole.operatorUser => 'person_crop_circle_badge_exclamationmark',
      UserRole.guest => 'person_crop_circle_badge_questionmark',
      UserRole.viewer => 'eye',
    };
  }

  bool get canEditData {
    return switch (this) {
      UserRole.admin || UserRole.manager || UserRole.operatorUser || UserRole.dispatcher => true,
      UserRole.guest || UserRole.viewer || UserRole.officeWorker => false,
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
      'manager' || 'lead' || 'supervisor' || 'site_manager' => UserRole.manager,
      'dispatcher' || 'dispatch' => UserRole.dispatcher,
      'office_worker' || 'officeworker' || 'office' => UserRole.officeWorker,
      'operator' || 'operator_user' || 'staff' => UserRole.operatorUser,
      'guest' || 'visitor' => UserRole.guest,
      'viewer' || 'observer' => UserRole.viewer,
      _ => UserRole.viewer,
    };
  }
}
