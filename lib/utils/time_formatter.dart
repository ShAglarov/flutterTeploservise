/// Утилита форматирования времени для отображения статуса пользователей.
///
/// Аналог статических методов из iOS `UserListViewModel`:
/// - [formatDuration] — длительность сессии (Онлайн (3ч 15м))
/// - [formatRelativeTime] — относительное время последнего входа
class TimeFormatter {
  TimeFormatter._();

  /// Форматирует длительность в читаемый вид: "3ч 15м", "45м", "< 1м"
  static String formatDuration(Duration duration) {
    final totalMinutes = duration.inMinutes;
    if (totalMinutes < 1) return '< 1м';

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}ч ${minutes}м';
    } else if (hours > 0) {
      return '${hours}ч';
    } else {
      return '${minutes}м';
    }
  }

  /// Форматирует дату последней активности в относительное время.
  ///
  /// Примеры:
  /// - "Был(а) только что"
  /// - "Был(а) 5 минут назад"
  /// - "Был(а) 2 часа назад"
  /// - "Был(а) вчера в 15:30"
  /// - "Был(а) 3 дня назад"
  /// - "Был(а) 25.06 в 10:00"
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    final minutes = diff.inMinutes;
    final hours = diff.inHours;

    // Менее 1 минуты
    if (minutes < 1) {
      return 'Был(а) только что';
    }

    // Менее 60 минут
    if (minutes < 60) {
      final word = _pluralize(minutes, 'минуту', 'минуты', 'минут');
      return 'Был(а) $minutes $word назад';
    }

    // Менее 24 часов
    if (hours < 24) {
      final word = _pluralize(hours, 'час', 'часа', 'часов');
      return 'Был(а) $hours $word назад';
    }

    // Вчера
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      final hh = date.hour.toString().padLeft(2, '0');
      final mm = date.minute.toString().padLeft(2, '0');
      return 'Был(а) вчера в $hh:$mm';
    }

    // В течение последней недели
    final days = hours ~/ 24;
    if (days < 7) {
      final word = _pluralize(days, 'день', 'дня', 'дней');
      return 'Был(а) $days $word назад';
    }

    // Более недели — показываем дату и время
    final dd = date.day.toString().padLeft(2, '0');
    final mo = date.month.toString().padLeft(2, '0');
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return 'Был(а) $dd.$mo в $hh:$mm';
  }

  /// Форматирует статус для строки списка пользователей.
  ///
  /// Для онлайн: "Онлайн (3ч 15м)" или "Онлайн"
  /// Для оффлайн: "Был(а) 5 минут назад" или "Не входил(а)"
  static String formatActivitySummary({
    required bool isOnline,
    DateTime? lastLoginAt,
  }) {
    if (isOnline) {
      if (lastLoginAt != null) {
        final duration = DateTime.now().difference(lastLoginAt);
        return 'Онлайн (${formatDuration(duration)})';
      }
      return 'Онлайн';
    }

    if (lastLoginAt != null) {
      return formatRelativeTime(lastLoginAt);
    }

    return 'Не входил(а)';
  }

  /// Склонение слов для числительных (1 час, 2 часа, 5 часов).
  static String _pluralize(int count, String one, String few, String many) {
    final mod10 = count % 10;
    final mod100 = count % 100;

    if (mod100 >= 11 && mod100 <= 19) {
      return many;
    }
    switch (mod10) {
      case 1:
        return one;
      case 2:
      case 3:
      case 4:
        return few;
      default:
        return many;
    }
  }
}
