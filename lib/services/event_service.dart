import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  return EventService();
});

enum AppEvent {
  logout,

  /// Сервер отказал по правам (403 permission_denied) — локальный снэпшот
  /// прав устарел и его надо перечитать. Слушается в auth_providers.
  permissionsStale,
}

class EventService {
  final _controller = StreamController<AppEvent>.broadcast();

  Stream<AppEvent> get events => _controller.stream;

  void fire(AppEvent event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}
