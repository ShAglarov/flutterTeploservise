/// Каталог всех ключей разрешений.
/// Зеркалирует backend: app/core/permission_registry.py
/// и iOS: Services/PermissionKey.swift
///
/// Использование:
/// ```dart
/// if (await permissionService.hasPermission(PermissionKey.incidentCreate)) { ... }
/// ```
class PermissionKey {
  PermissionKey._();

  // ─── Котельные ───
  static const boilerHouseRead = 'boiler_house.read';
  static const boilerHouseCreate = 'boiler_house.create';
  static const boilerHouseUpdate = 'boiler_house.update';
  static const boilerHouseDelete = 'boiler_house.delete';
  static const boilerHouseExport = 'boiler_house.export';
  static const boilerHouseImport = 'boiler_house.import';

  // ─── Адреса ───
  static const savedLocationRead = 'saved_location.read';
  static const savedLocationCreate = 'saved_location.create';
  static const savedLocationUpdate = 'saved_location.update';
  static const savedLocationDelete = 'saved_location.delete';

  // ─── Лицевые счета ───
  static const accountRead = 'account.read';
  static const accountCreate = 'account.create';
  static const accountUpdate = 'account.update';
  static const accountDelete = 'account.delete';
  static const accountImport = 'account.import';
  static const accountExport = 'account.export';
  static const accountAssign = 'account.assign';

  // ─── Инциденты ───
  static const incidentRead = 'incident.read';
  static const incidentCreate = 'incident.create';
  static const incidentUpdate = 'incident.update';
  static const incidentDelete = 'incident.delete';
  static const incidentApprove = 'incident.approve';

  // ─── Комментарии к инцидентам ───
  static const incidentCommentRead = 'incident_comment.read';
  static const incidentCommentCreate = 'incident_comment.create';
  static const incidentCommentDelete = 'incident_comment.delete';

  // ─── Фотографии ───
  static const photoCreate = 'photo.create';
  static const photoDelete = 'photo.delete';

  // ─── Управляющие компании ───
  static const managementCompanyRead = 'management_company.read';
  static const managementCompanyCreate = 'management_company.create';
  static const managementCompanyUpdate = 'management_company.update';
  static const managementCompanyDelete = 'management_company.delete';
  static const managementCompanyImport = 'management_company.import';
  static const managementCompanyExport = 'management_company.export';

  // ─── Отчёты ───
  static const reportRead = 'report.read';
  static const reportCreate = 'report.create';
  static const reportApprove = 'report.approve';

  // ─── Журнал работы ───
  static const operationLogRead = 'operation_log.read';
  static const operationLogCreate = 'operation_log.create';
  static const operationLogUpdate = 'operation_log.update';

  // ─── Пользователи ───
  static const userRead = 'user.read';
  static const userCreate = 'user.create';
  static const userUpdate = 'user.update';
  static const userDelete = 'user.delete';
  static const userManagePermissions = 'user.manage_permissions';
  static const userExport = 'user.export';

  // ─── Системные ───
  static const actionLogRead = 'action_log.read';
  static const analyticsRead = 'analytics.read';
  static const dataImport = 'data.import';
  static const dataExport = 'data.export';
  static const syncManage = 'sync.manage';

  // ─── Скоуп ───
  static const scopeAllObjects = 'scope.all_objects';
  static const scopeAllIncidents = 'scope.all_incidents';

  /// Все ключи.
  static const List<String> allKeys = [
    boilerHouseRead, boilerHouseCreate, boilerHouseUpdate, boilerHouseDelete,
    boilerHouseExport, boilerHouseImport,
    savedLocationRead, savedLocationCreate, savedLocationUpdate, savedLocationDelete,
    accountRead, accountCreate, accountUpdate, accountDelete,
    accountImport, accountExport, accountAssign,
    incidentRead, incidentCreate, incidentUpdate, incidentDelete, incidentApprove,
    incidentCommentRead, incidentCommentCreate, incidentCommentDelete,
    photoCreate, photoDelete,
    managementCompanyRead, managementCompanyCreate, managementCompanyUpdate,
    managementCompanyDelete, managementCompanyImport, managementCompanyExport,
    reportRead, reportCreate, reportApprove,
    operationLogRead, operationLogCreate, operationLogUpdate,
    userRead, userCreate, userUpdate, userDelete,
    userManagePermissions, userExport,
    actionLogRead, analyticsRead, dataImport, dataExport, syncManage,
    scopeAllObjects, scopeAllIncidents,
  ];
}
