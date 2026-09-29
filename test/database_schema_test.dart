import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teploservice_flutter/database/database.dart';

/// Проверяет схему локальной БД на in-memory sqlite.
///
/// Главное здесь — индексы. Раньше они объявлялись как
/// `@override List<Index> get indexes => [...]`, но у drift `Table` такого
/// геттера нет: код компилировался как обычный неиспользуемый метод, а индексы
/// в схему не попадали. Тест ловит повторение этой ошибки.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<Set<String>> indexNames() async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .get();
    return rows.map((r) => r.read<String>('name')).toSet();
  }

  test('индекс по affected_houses.incident_id создан', () async {
    expect(await indexNames(), contains('affected_houses_incident_id'));
  });

  test('индекс по incident_photos.incident_id создан', () async {
    expect(await indexNames(), contains('incident_photos_incident_id'));
  });

  test('индексы зарегистрированы в схеме drift', () {
    final declared = db.allSchemaEntities.whereType<Index>().map((i) => i.entityName);
    expect(
      declared,
      containsAll(<String>[
        'affected_houses_incident_id',
        'incident_photos_incident_id',
      ]),
    );
  });

  test('индекс действительно используется планировщиком', () async {
    final plan = await db
        .customSelect(
          'EXPLAIN QUERY PLAN '
          'SELECT * FROM incident_photos WHERE incident_id = 1',
        )
        .get();
    final text = plan.map((r) => r.data.values.join(' ')).join('\n');
    expect(
      text,
      contains('incident_photos_incident_id'),
      reason: 'план запроса должен использовать индекс, а не сканировать таблицу:\n$text',
    );
  });

  test('схема применяется целиком и все таблицы создаются', () async {
    final rows = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final tables = rows.map((r) => r.read<String>('name')).toSet();
    // Ключевые таблицы, на которых держится офлайн-кеш.
    expect(
      tables,
      containsAll(<String>[
        'incidents',
        'incident_photos',
        'affected_houses',
        'saved_locations',
        'pending_changes',
      ]),
    );
  });
}
