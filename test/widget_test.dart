import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teploservice_flutter/utils/app_theme.dart';

/// Ранее здесь лежал нетронутый шаблон `flutter create` («Counter increments
/// smoke test»), который искал счётчик, отсутствующий в этом приложении, и
/// поэтому всегда падал — единственный тест проекта был красным.
///
/// Полноценный тест `MyApp` требует инициализации Riverpod, secure storage и
/// sqlite, поэтому здесь остаются проверки, не требующие рантайма приложения.
/// Схема БД проверяется в database_schema_test.dart, форматирование времени —
/// в time_formatter_test.dart.
void main() {
  group('AppTheme', () {
    test('тема собирается и является тёмной', () {
      expect(AppTheme.darkTheme.brightness, Brightness.dark);
    });

    test('цвета статусов различимы между собой', () {
      final colors = <Color>{
        AppTheme.successGreen,
        AppTheme.errorRed,
      };
      expect(colors.length, 2, reason: 'цвета статусов не должны совпадать');
    });
  });

  testWidgets('MaterialApp с темой приложения рендерится', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(body: Text('Теплосервис')),
      ),
    );

    expect(find.text('Теплосервис'), findsOneWidget);
  });
}
