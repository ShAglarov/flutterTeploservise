/// Утилиты форматирования для конструктора отчётов.

/// Форматирует период: "2025-01-01" → "Янв 2025".
String formatPeriod(String? s) {
  if (s == null) return '—';
  final dt = DateTime.tryParse(s);
  if (dt == null) return s;
  const months = [
    '', 'Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн',
    'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек',
  ];
  return '${months[dt.month]} ${dt.year}';
}

/// Форматирует деньги: 1500000 → "1.5M", 25000 → "25K", 500 → "500".
String fmtMoney(double v) {
  if (v.abs() >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v.abs() >= 10000) return '${(v / 1000).toStringAsFixed(0)}K';
  return v.toStringAsFixed(0);
}

/// Фильтрует список документов по поисковому запросу.
/// Формат "33,4" → дом содержит "33" И адрес содержит "4".
/// Иначе — поиск по ФИО, адресу, ЛС.
List<T> filterItems<T>(List<T> items, String searchQuery, String Function(T) getFio,
    {String Function(T)? getLocationName, String Function(T)? getAddress,
    String Function(T)? getAccountNumber}) {
  if (searchQuery.isEmpty) return items;
  final q = searchQuery.toLowerCase();

  // Формат "дом,кв"
  if (q.contains(',')) {
    final parts = q.split(',');
    final housePart = parts[0].trim();
    final aptPart = parts.length > 1 ? parts[1].trim() : '';
    return items.where((item) {
      final loc = (getLocationName?.call(item) ?? '').toLowerCase();
      final addr = (getAddress?.call(item) ?? '').toLowerCase();
      final matchHouse = housePart.isEmpty || loc.contains(housePart) || addr.contains(housePart);
      final matchApt = aptPart.isEmpty || addr.contains(aptPart);
      return matchHouse && matchApt;
    }).toList();
  }

  // Обычный поиск
  return items.where((item) {
    final fio = getFio(item).toLowerCase();
    final loc = (getLocationName?.call(item) ?? '').toLowerCase();
    final addr = (getAddress?.call(item) ?? '').toLowerCase();
    final acc = (getAccountNumber?.call(item) ?? '').toLowerCase();
    return fio.contains(q) || loc.contains(q) || addr.contains(q) || acc.contains(q);
  }).toList();
}
