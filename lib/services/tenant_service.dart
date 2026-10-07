import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';

/// Текущая организация (tenant) на устройстве.
///
/// Зачем клиенту знать организацию, если изоляция сделана на сервере:
///
///   * **локальный кэш.** Drift хранит данные в файле на устройстве. Если на
///     одном планшете работают сотрудники двух управляющих компаний,
///     единый `db.sqlite` смешает их данные: второй увидит дома и лицевые
///     счета первого, пока не пройдёт полная пересинхронизация. Имя файла
///     включает id организации — кэши физически разные.
///   * **push и realtime.** Уведомление может прийти на устройство после
///     выхода и входа под другой организацией (APNs доставляет с задержкой,
///     WebSocket переподключается). Клиент сверяет `organization_id` в
///     payload со своей организацией и молча отбрасывает чужое.
///
/// Значение читается синхронно (`currentOrganizationId`) — оно нужно в
/// момент открытия файла БД, до любых await.
class TenantService {
  static const _prefsKey = 'current_organization_id';
  static const _superadminKey = 'current_is_superadmin';

  /// Кэш в памяти: открытие БД не может ждать SharedPreferences.
  static int? _cached;
  static bool _superadmin = false;

  /// Организация текущей сессии. null — не определена (не вошли, или
  /// суперадмин без привязки).
  static int? get currentOrganizationId => _cached;

  /// Суперадмин — владелец сервиса, видит список организаций и создаёт новые.
  ///
  /// Флаг только для UI: показать или скрыть раздел. Доступ решает сервер,
  /// подделка значения на устройстве даёт 403 на каждом запросе.
  static bool get isSuperadmin => _superadmin;

  /// Поднимает сохранённое значение в память. Вызывается при старте
  /// приложения ДО инициализации базы.
  static Future<int?> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getInt(_prefsKey);
      _cached = value;
      _superadmin = prefs.getBool(_superadminKey) ?? false;
      logDebug('🏢 [Tenant] Восстановлена организация: $value (sa=$_superadmin)');
      return value;
    } catch (e) {
      logDebug('⚠️ [Tenant] Не удалось восстановить организацию: $e');
      return null;
    }
  }

  /// Запоминает организацию после входа.
  static Future<void> setOrganization(int? orgId, {bool isSuperadmin = false}) async {
    _cached = orgId;
    _superadmin = isSuperadmin;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (orgId == null) {
        await prefs.remove(_prefsKey);
      } else {
        await prefs.setInt(_prefsKey, orgId);
      }
      if (isSuperadmin) {
        await prefs.setBool(_superadminKey, true);
      } else {
        await prefs.remove(_superadminKey);
      }
      logDebug('🏢 [Tenant] Организация сессии: $orgId (sa=$isSuperadmin)');
    } catch (e) {
      logDebug('⚠️ [Tenant] Не удалось сохранить организацию: $e');
    }
  }

  /// Сбрасывает при выходе.
  static Future<void> clear() => setOrganization(null, isSuperadmin: false);

  /// Относится ли событие к текущей организации.
  ///
  /// Событие без `organization_id` считаем своим: так продолжают работать
  /// старые сборки сервера и системные сообщения, у которых тенанта нет.
  /// Отбрасываем только явное несовпадение — ситуацию, когда уведомление
  /// принадлежит другой компании.
  static bool belongsToCurrentOrg(dynamic eventOrgId) {
    if (eventOrgId == null) return true;
    final current = _cached;
    if (current == null) return true;
    final int? incoming = eventOrgId is int
        ? eventOrgId
        : int.tryParse(eventOrgId.toString());
    if (incoming == null) return true;
    final ok = incoming == current;
    if (!ok) {
      logDebug('🚫 [Tenant] Событие чужой организации ($incoming ≠ $current) — отброшено');
    }
    return ok;
  }
}

/// Организация текущей сессии — для UI и для провайдера локальной БД.
///
/// `NotifierProvider`, а не `StateProvider`: последний убран из публичного
/// API Riverpod 3, который используется в проекте.
class CurrentOrganization extends Notifier<int?> {
  @override
  int? build() => TenantService.currentOrganizationId;

  /// Вызывается после входа и выхода. Пересоздаёт зависимые провайдеры —
  /// в том числе базу данных, чей файл привязан к тенанту.
  void set(int? orgId) => state = orgId;
}

final currentOrganizationProvider =
    NotifierProvider<CurrentOrganization, int?>(CurrentOrganization.new);
