/// Утилита для нечёткого поиска адресов с нормализацией.
/// Dart-аналог iOS AddressSearchHelper.
/// Используется для in-memory фильтрации локальной БД (Drift).
class AddressSearchHelper {
  AddressSearchHelper._();

  // Стоп-слова для нормализации адресов (от длинных к коротким)
  static const List<String> _stopWords = [
    'улица', 'ул.', 'ул',
    'проспект', 'просп.', 'пр-т', 'пр.',
    'переулок', 'пер.', 'пер',
    'бульвар', 'бул.', 'б-р',
    'площадь', 'пл.',
    'шоссе', 'ш.',
    'набережная', 'наб.',
    'проезд', 'пр-д',
    'тупик', 'туп.',
    'аллея', 'ал.',
    'дом', 'д.', 'д',
    'корпус', 'корп.', 'к.',
    'строение', 'стр.', 'с.',
    'квартира', 'кв.', 'кв',
    'город', 'г.', 'г',
    'село', 'с.',
    'посёлок', 'поселок', 'пос.', 'п.',
    'район', 'р-н',
    'республика', 'респ.',
  ];

  /// Нормализует адресную строку: lowercase, удаление стоп-слов, пунктуации и лишних пробелов.
  static String normalize(String address) {
    var result = address.toLowerCase();

    // Удаление стоп-слов (сортируем от длинных к коротким)
    final sorted = List<String>.from(_stopWords)
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final word in sorted) {
      result = result.replaceAll(word, ' ');
    }

    // Удаление пунктуации (оставляем только буквы, цифры, пробелы)
    result = result.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ');

    // Схлопывание пробелов
    result = result.split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .join(' ')
        .trim();

    return result;
  }

  /// Разбивает нормализованную строку на токены.
  static List<String> tokenize(String text) {
    return normalize(text)
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Проверяет, что **все** токены запроса содержатся в кандидате.
  /// Устойчиво к перестановке слов.
  static bool fuzzyMatch(String query, String candidate) {
    final queryTokens = tokenize(query);
    if (queryTokens.isEmpty) return true;

    final normalizedCandidate = normalize(candidate);

    for (final token in queryTokens) {
      if (!normalizedCandidate.contains(token)) {
        return false;
      }
    }
    return true;
  }

  /// Оценка совпадения (0.0 — нет, 1.0 — полное). Для сортировки по релевантности.
  static double matchScore(String query, String candidate) {
    final queryTokens = tokenize(query);
    if (queryTokens.isEmpty) return 1.0;

    final normalizedCandidate = normalize(candidate);
    int matched = 0;

    for (final token in queryTokens) {
      if (normalizedCandidate.contains(token)) {
        matched++;
      }
    }

    return matched / queryTokens.length;
  }
}
