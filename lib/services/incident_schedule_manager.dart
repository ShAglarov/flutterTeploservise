import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incident_models.dart';
import '../providers/incident_providers.dart';
import '../services/incident_service.dart';
import '../repositories/sync_repository.dart';

/// Менеджер расписания инцидентов — автоматически обновляет UI
/// в момент наступления startedAt (запланированный → активный)
/// и finishedAt (активный → завершённый/просроченный).
class IncidentScheduleManager {
  Timer? _startTimer;
  Timer? _finishTimer;
  DateTime? _nextStartDate;
  DateTime? _nextFinishDate;
  final Ref _ref;
  List<IncidentResponse> _lastIncidents = [];

  IncidentScheduleManager(this._ref);

  /// Обновляет таймеры на основе текущего списка инцидентов
  void updateSchedule(List<IncidentResponse> incidents) {
    _lastIncidents = incidents;
    _updateStartSchedule(incidents);
    _updateFinishSchedule(incidents);
  }

  /// Находит ближайший startedAt в будущем и ставит таймер
  void _updateStartSchedule(List<IncidentResponse> incidents) {
    final now = DateTime.now();
    DateTime? nextStart;

    for (final inc in incidents) {
      if (inc.startedAt == null) continue;
      if (inc.status == IncidentStatus.resolved || inc.status == IncidentStatus.closed) continue;
      final parsed = DateTime.tryParse(inc.startedAt!);
      if (parsed == null) continue;
      final localDt = parsed.toLocal();
      if (localDt.isAfter(now)) {
        if (nextStart == null || localDt.isBefore(nextStart)) {
          nextStart = localDt;
        }
      }
    }

    if (nextStart == null) {
      _cancelStartTimer();
      return;
    }

    // Если уже есть таймер на эту дату — не пересоздаём
    if (_nextStartDate == nextStart) return;

    _cancelStartTimer();
    _nextStartDate = nextStart;

    final delay = nextStart.difference(now) + const Duration(milliseconds: 200);
    if (delay.isNegative) return;

    debugPrint('⏱ [ScheduleManager] Запланирован старт через ${delay.inSeconds} сек (${nextStart.toIso8601String()})');

    _startTimer = Timer(delay, () {
      debugPrint('🚨 [ScheduleManager] Таймер старта сработал! Инцидент стал АКТИВНЫМ.');
      _nextStartDate = null;
      // Трогаем БД чтобы Drift stream re-emit (аналог iOS tableView.reloadData())
      _touchIncidentsInDb();
      // Инвалидируем провайдер для перерисовки UI
      _ref.invalidate(allIncidentsProvider);
    });
  }

  /// Находит ближайший finishedAt в будущем и ставит таймер
  void _updateFinishSchedule(List<IncidentResponse> incidents) {
    final now = DateTime.now();
    DateTime? nextFinish;

    for (final inc in incidents) {
      if (inc.finishedAt == null) continue;
      if (inc.status == IncidentStatus.resolved || inc.status == IncidentStatus.closed) continue;
      if (inc.isScheduledLocal) continue; // Ещё не стартовал
      final parsed = DateTime.tryParse(inc.finishedAt!);
      if (parsed == null) continue;
      final localDt = parsed.toLocal();
      if (localDt.isAfter(now)) {
        if (nextFinish == null || localDt.isBefore(nextFinish)) {
          nextFinish = localDt;
        }
      }
    }

    if (nextFinish == null) {
      _cancelFinishTimer();
      // Проверяем уже просроченные с autoResolve — возможно нужно закрыть
      _performAutoResolveIfNeeded(incidents);
      return;
    }

    if (_nextFinishDate == nextFinish) return;

    _cancelFinishTimer();
    _nextFinishDate = nextFinish;

    final delay = nextFinish.difference(now) + const Duration(milliseconds: 200);
    if (delay.isNegative) return;

    debugPrint('⏱ [ScheduleManager] Запланировано завершение через ${delay.inSeconds} сек (${nextFinish.toIso8601String()})');

    _finishTimer = Timer(delay, () {
      debugPrint('🏁 [ScheduleManager] Таймер завершения сработал!');
      _nextFinishDate = null;
      // Авто-завершение для инцидентов с autoResolveOnFinish=true
      _performAutoResolveIfNeeded(_lastIncidents);
      // Трогаем БД чтобы Drift stream re-emit
      _touchIncidentsInDb();
      _ref.invalidate(allIncidentsProvider);
    });
  }

  /// Авто-завершает просроченные инциденты с autoResolveOnFinish=true
  void _performAutoResolveIfNeeded(List<IncidentResponse> incidents) {
    for (final inc in incidents) {
      if (!inc.isOverdue) continue;
      if (!inc.autoResolveOnFinish) continue;
      
      debugPrint('✅ [ScheduleManager] Авто-завершение инцидента "${inc.title}" (id=${inc.id})');
      
      // Отправляем PATCH на сервер для закрытия
      try {
        final service = _ref.read(incidentServiceProvider);
        final update = IncidentUpdate(
          id: inc.id,
          status: IncidentStatus.closed,
          resolvedAt: DateTime.now().toUtc().toIso8601String(),
        );
        service.updateIncident(inc.id, update).then((_) {
          debugPrint('✅ [ScheduleManager] Инцидент ${inc.id} закрыт на сервере');
          _ref.invalidate(allIncidentsProvider);
        }).catchError((e) {
          debugPrint('❌ [ScheduleManager] Ошибка закрытия инцидента ${inc.id}: $e');
        });
      } catch (e) {
        debugPrint('❌ [ScheduleManager] Ошибка при авто-завершении: $e');
      }
    }
  }

  void _cancelStartTimer() {
    _startTimer?.cancel();
    _startTimer = null;
    _nextStartDate = null;
  }

  void _cancelFinishTimer() {
    _finishTimer?.cancel();
    _finishTimer = null;
    _nextFinishDate = null;
  }

  void dispose() {
    _cancelStartTimer();
    _cancelFinishTimer();
  }

  /// Трогает записи в БД чтобы Drift стрим re-emit и карта перерисовала пины.
  /// Аналог iOS: tableView.reloadData() / NotificationCenter.post
  void _touchIncidentsInDb() {
    try {
      final syncRepo = _ref.read(syncRepositoryProvider);
      for (final inc in _lastIncidents) {
        if (inc.status == IncidentStatus.resolved || inc.status == IncidentStatus.closed) continue;
        syncRepo.touchIncidentForRefresh(inc.id);
      }
    } catch (e) {
      debugPrint('⚠️ [ScheduleManager] Failed to touch DB: $e');
    }
  }
}

/// Riverpod-провайдер для IncidentScheduleManager (keepAlive)
final incidentScheduleManagerProvider = Provider<IncidentScheduleManager>((ref) {
  final manager = IncidentScheduleManager(ref);

  // Подписываемся на поток инцидентов и обновляем таймеры
  ref.listen(allIncidentsProvider, (previous, next) {
    next.whenData((incidents) {
      manager.updateSchedule(incidents);
    });
  });

  ref.onDispose(() => manager.dispose());
  return manager;
});
