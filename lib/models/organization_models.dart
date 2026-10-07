/// Организации (multi-tenancy). Доступно только суперадмину.
///
/// JSON пишется руками, без json_serializable: модель небольшая, а запуск
/// build_runner перегенерировал бы все *.g.dart проекта.
class OrganizationResponse {
  final int id;
  final String name;
  final String? inn;
  final String? ogrn;
  final String? requisites;
  final bool isActive;
  final int usersCount;

  const OrganizationResponse({
    required this.id,
    required this.name,
    this.inn,
    this.ogrn,
    this.requisites,
    required this.isActive,
    required this.usersCount,
  });

  factory OrganizationResponse.fromJson(Map<String, dynamic> json) {
    return OrganizationResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      inn: json['inn'] as String?,
      ogrn: json['ogrn'] as String?,
      requisites: json['requisites'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      usersCount: (json['users_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'inn': inn,
        'ogrn': ogrn,
        'requisites': requisites,
        'is_active': isActive,
        'users_count': usersCount,
      };
}

/// Организация вместе с её первым администратором — сервер создаёт их
/// одной транзакцией, поэтому и в форме это один шаг.
class OrganizationCreate {
  final String name;
  final String? inn;
  final String? ogrn;
  final String? requisites;

  final String adminUsername;
  final String adminPassword;
  final String adminEmail;
  final String? adminFullName;

  const OrganizationCreate({
    required this.name,
    this.inn,
    this.ogrn,
    this.requisites,
    required this.adminUsername,
    required this.adminPassword,
    required this.adminEmail,
    this.adminFullName,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'admin_username': adminUsername,
      'admin_password': adminPassword,
      'admin_email': adminEmail,
    };
    // Пустые необязательные поля не отправляем: сервер валидирует длину
    // ИНН/ОГРН, и пустая строка дала бы ошибку вместо «не указано».
    if (inn != null && inn!.isNotEmpty) map['inn'] = inn;
    if (ogrn != null && ogrn!.isNotEmpty) map['ogrn'] = ogrn;
    if (requisites != null && requisites!.isNotEmpty) map['requisites'] = requisites;
    if (adminFullName != null && adminFullName!.isNotEmpty) {
      map['admin_full_name'] = adminFullName;
    }
    return map;
  }
}

class OrganizationUpdate {
  final String? name;
  final String? inn;
  final String? ogrn;
  final String? requisites;
  final bool? isActive;

  const OrganizationUpdate({
    this.name,
    this.inn,
    this.ogrn,
    this.requisites,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (inn != null) map['inn'] = inn;
    if (ogrn != null) map['ogrn'] = ogrn;
    if (requisites != null) map['requisites'] = requisites;
    if (isActive != null) map['is_active'] = isActive;
    return map;
  }
}
