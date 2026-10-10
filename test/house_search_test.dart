// Поиск домов внутри котельной.
//
// Раньше список домов выбранной котельной строился без учёта запроса:
// `filteredMapData` оставляет в `locations` ВСЕ дома найденной
// котельной (на карте так и нужно), и в списке это выглядело как
// неработающий поиск — что бы оператор ни набрал, список не менялся.
import 'package:flutter_test/flutter_test.dart';
import 'package:teploservice_flutter/utils/address_search_helper.dart';

void main() {
  group('AddressSearchHelper.matchesHouse', () {
    test('пустой запрос подходит всем — показываем полный список', () {
      expect(
        AddressSearchHelper.matchesHouse('', name: 'ул. Айвазовского, д. 2А'),
        isTrue,
      );
      expect(
        AddressSearchHelper.matchesHouse('   ', name: 'ул. Перова, 29б'),
        isTrue,
      );
    });

    test('находит по части названия улицы', () {
      expect(
        AddressSearchHelper.matchesHouse(
          'айваз',
          name: 'ул. Айвазовского, д. 2А',
        ),
        isTrue,
      );
    });

    test('сокращения адреса не мешают: «Айвазовского 2» = «ул. …, д. 2А»', () {
      expect(
        AddressSearchHelper.matchesHouse(
          'Айвазовского 2',
          name: 'ул. Айвазовского, д. 2А',
        ),
        isTrue,
      );
    });

    test('порядок слов не важен', () {
      expect(
        AddressSearchHelper.matchesHouse(
          '29б Перова',
          name: 'ул. Перова, д. 29б',
        ),
        isTrue,
      );
    });

    test('чужой дом не находится', () {
      expect(
        AddressSearchHelper.matchesHouse(
          'Юсупова',
          name: 'ул. Айвазовского, д. 2А',
        ),
        isFalse,
      );
    });

    test('номер дома различает соседние адреса', () {
      // Именно на этом ломался старый поиск: в списке котельной
      // оставались оба дома.
      expect(
        AddressSearchHelper.matchesHouse(
          'Перова 297',
          name: 'пр-кт Али-Гаджи Акушинского, д. 299',
        ),
        isFalse,
      );
    });

    test('находит по управляющей компании', () {
      expect(
        AddressSearchHelper.matchesHouse(
          'теплосерв',
          name: 'ул. Айвазовского, д. 2А',
          managementCompany: 'УК Теплосервис',
        ),
        isTrue,
      );
    });

    test('находит по кадастровому номеру с двоеточиями', () {
      // Нормализация выбросила бы двоеточия, поэтому кадастровый
      // сверяется простой подстрокой.
      expect(
        AddressSearchHelper.matchesHouse(
          '05:40:000041:1718',
          name: 'ул. Айвазовского, д. 2А',
          cadastralNumber: '05:40:000041:1718',
        ),
        isTrue,
      );
      expect(
        AddressSearchHelper.matchesHouse(
          '000041:1718',
          name: 'ул. Айвазовского, д. 2А',
          cadastralNumber: '05:40:000041:1718',
        ),
        isTrue,
      );
    });

    test('регистр не важен', () {
      expect(
        AddressSearchHelper.matchesHouse(
          'АЙВАЗОВСКОГО',
          name: 'ул. айвазовского, д. 2А',
        ),
        isTrue,
      );
    });

    test('пустые УК и кадастровый не ломают поиск', () {
      expect(
        AddressSearchHelper.matchesHouse(
          'что-то',
          name: 'ул. Айвазовского, д. 2А',
          managementCompany: null,
          cadastralNumber: null,
        ),
        isFalse,
      );
    });
  });
}
