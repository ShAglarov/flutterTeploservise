import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';

/// Описание переключаемого поля карточки инцидента.
///
/// Ключ, подпись и иконка лежат в ОДНОМ месте: и провайдер, и лист настроек,
/// и сама карточка читают этот список. Иначе подписи в настройках и реально
/// скрываемые блоки разъезжаются при любой правке.
class IncidentCardField {
  final String key;
  final String label;
  final String description;
  final IconData icon;

  const IncidentCardField({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
  });
}

/// Поля в том порядке, в котором они идут в карточке сверху вниз —
/// лист настроек повторяет этот порядок, чтобы настройку было легко
/// сопоставить с тем, что видно на карточке.
///
/// Заголовок, номер инцидента, статус-бейдж и цветная полоска не
/// переключаются: без них карточка перестаёт быть читаемой.
const List<IncidentCardField> kIncidentCardFields = [
  IncidentCardField(
    key: 'timestamp',
    label: 'Время',
    description: 'Период инцидента в правом верхнем углу',
    icon: Icons.schedule,
  ),
  IncidentCardField(
    key: 'location',
    label: 'Адрес котельной',
    description: 'Адрес под заголовком',
    icon: Icons.location_on_outlined,
  ),
  IncidentCardField(
    key: 'affectedHouses',
    label: 'Дома',
    description: 'Список затронутых домов',
    icon: Icons.home_outlined,
  ),
  IncidentCardField(
    key: 'assignee',
    label: 'Ответственный',
    description: 'Кто назначен на инцидент',
    icon: Icons.account_circle,
  ),
  IncidentCardField(
    key: 'broadcast',
    label: 'Оповещение',
    description: 'Кому отправлено уведомление',
    icon: Icons.campaign,
  ),
  IncidentCardField(
    key: 'stoppedServices',
    label: 'Остановленные услуги',
    description: 'ГВС и отопление',
    icon: Icons.warning_rounded,
  ),
  IncidentCardField(
    key: 'boilerChips',
    label: 'Котлы',
    description: 'Состояние котлов и чипы неработающих',
    icon: Icons.local_fire_department_outlined,
  ),
  IncidentCardField(
    key: 'population',
    label: 'Население',
    description: 'Сколько людей без услуг',
    icon: Icons.people,
  ),
];

/// Значения по умолчанию — показываем всё.
final Map<String, bool> kIncidentCardFieldDefaults = {
  for (final f in kIncidentCardFields) f.key: true,
};

/// Какие поля карточки инцидента показывать. Персистентно между сессиями.
///
/// keepAlive по умолчанию (в Riverpod 3.x `isAutoDispose = false`): настройки
/// не должны сбрасываться при уходе с экрана списка.
final incidentCardSettingsProvider =
    NotifierProvider<IncidentCardSettings, Map<String, bool>>(
  IncidentCardSettings.new,
);

class IncidentCardSettings extends Notifier<Map<String, bool>> {
  static const _prefsKey = 'incident_card_fields';

  @override
  Map<String, bool> build() {
    // SharedPreferences асинхронен, а build — нет: отдаём дефолты сразу и
    // подменяем состояние, когда сохранённое прочитается.
    _restore();
    return Map.unmodifiable(kIncidentCardFieldDefaults);
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;

      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      // Берём дефолты за основу и накладываем сохранённое: поле, добавленное
      // в новой версии приложения, останется видимым, а не пропадёт молча из
      // карточки у тех, кто уже сохранял настройки.
      final restored = <String, bool>{...kIncidentCardFieldDefaults};
      for (final f in kIncidentCardFields) {
        final value = decoded[f.key];
        if (value is bool) restored[f.key] = value;
      }
      state = Map.unmodifiable(restored);
    } catch (e) {
      // Настройки отображения — не те данные, из-за которых стоит ломать
      // экран: остаёмся на дефолтах.
      logDebug('⚠️ [IncidentCardSettings] restore failed: $e');
    }
  }

  Future<void> _persist(Map<String, bool> value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(value));
    } catch (e) {
      logDebug('⚠️ [IncidentCardSettings] persist failed: $e');
    }
  }

  /// Показывать ли поле. Неизвестный ключ считается видимым — скрывать
  /// можно только то, что пользователь скрыл осознанно.
  bool isVisible(String key) => state[key] ?? true;

  void toggle(String key, bool visible) {
    if (!kIncidentCardFieldDefaults.containsKey(key)) return;
    final next = {...state, key: visible};
    state = Map.unmodifiable(next);
    _persist(next);
  }

  void resetToDefaults() {
    state = Map.unmodifiable(kIncidentCardFieldDefaults);
    _persist(kIncidentCardFieldDefaults);
  }

  /// Сколько полей скрыто — для подписи в AppBar/листе настроек.
  int get hiddenCount => state.values.where((v) => v == false).length;
}
