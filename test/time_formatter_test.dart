import 'package:flutter_test/flutter_test.dart';
import 'package:teploservice_flutter/utils/time_formatter.dart';

void main() {
  group('TimeFormatter.formatDuration', () {
    test('меньше минуты', () {
      expect(TimeFormatter.formatDuration(const Duration(seconds: 0)), '< 1м');
      expect(TimeFormatter.formatDuration(const Duration(seconds: 59)), '< 1м');
    });

    test('только минуты', () {
      expect(TimeFormatter.formatDuration(const Duration(minutes: 1)), '1м');
      expect(TimeFormatter.formatDuration(const Duration(minutes: 45)), '45м');
    });

    test('часы без остатка', () {
      expect(TimeFormatter.formatDuration(const Duration(hours: 3)), '3ч');
    });

    test('часы и минуты', () {
      expect(
        TimeFormatter.formatDuration(const Duration(hours: 3, minutes: 15)),
        '3ч 15м',
      );
    });
  });

  group('TimeFormatter.formatRelativeTime', () {
    test('только что', () {
      final now = DateTime.now();
      expect(TimeFormatter.formatRelativeTime(now), 'Был(а) только что');
    });

    test('минуты назад со склонением', () {
      final base = DateTime.now();
      expect(
        TimeFormatter.formatRelativeTime(base.subtract(const Duration(minutes: 1))),
        'Был(а) 1 минуту назад',
      );
      expect(
        TimeFormatter.formatRelativeTime(base.subtract(const Duration(minutes: 3))),
        'Был(а) 3 минуты назад',
      );
      expect(
        TimeFormatter.formatRelativeTime(base.subtract(const Duration(minutes: 5))),
        'Был(а) 5 минут назад',
      );
      // 11-19 всегда «минут», даже если последняя цифра 1..4
      expect(
        TimeFormatter.formatRelativeTime(base.subtract(const Duration(minutes: 12))),
        'Был(а) 12 минут назад',
      );
    });

    test('часы назад со склонением', () {
      final base = DateTime.now();
      expect(
        TimeFormatter.formatRelativeTime(base.subtract(const Duration(hours: 1))),
        'Был(а) 1 час назад',
      );
      expect(
        TimeFormatter.formatRelativeTime(base.subtract(const Duration(hours: 2))),
        'Был(а) 2 часа назад',
      );
      expect(
        TimeFormatter.formatRelativeTime(base.subtract(const Duration(hours: 7))),
        'Был(а) 7 часов назад',
      );
    });

    test('больше недели — абсолютная дата', () {
      final date = DateTime(2024, 6, 25, 10, 5);
      expect(TimeFormatter.formatRelativeTime(date), 'Был(а) 25.06 в 10:05');
    });
  });

  group('TimeFormatter.formatActivitySummary', () {
    test('онлайн без времени входа', () {
      expect(
        TimeFormatter.formatActivitySummary(isOnline: true, lastLoginAt: null),
        'Онлайн',
      );
    });

    test('онлайн с длительностью сессии', () {
      final since = DateTime.now().subtract(const Duration(hours: 2, minutes: 10));
      expect(
        TimeFormatter.formatActivitySummary(isOnline: true, lastLoginAt: since),
        startsWith('Онлайн ('),
      );
    });

    test('никогда не входил', () {
      expect(
        TimeFormatter.formatActivitySummary(isOnline: false, lastLoginAt: null),
        'Не входил(а)',
      );
    });

    test('оффлайн — относительное время', () {
      final seen = DateTime.now().subtract(const Duration(minutes: 5));
      expect(
        TimeFormatter.formatActivitySummary(isOnline: false, lastLoginAt: seen),
        'Был(а) 5 минут назад',
      );
    });
  });
}
