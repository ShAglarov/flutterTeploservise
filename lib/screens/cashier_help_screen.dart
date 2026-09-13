import 'package:flutter/material.dart';

/// Экран-инструкция для кассира
class CashierHelpScreen extends StatelessWidget {
  const CashierHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('📖 Инструкция кассира'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _intro(theme),
          const SizedBox(height: 16),
          _section(theme, '📅 Как начать работу с новым месяцем', Colors.indigo, _startMonth),
          _section(theme, '💰 Как внести оплату', Colors.green, _paymentInstructions),
          _section(theme, '🔄 Как сделать авто-оплату', Colors.teal, _autoPayInstructions),
          _section(theme, '📊 Как сделать перерасчёт', Colors.blue, _recalcInstructions),
          _section(theme, '📝 Как начислить вручную', Colors.orange, _chargeInstructions),
          _section(theme, '✏️ Как скорректировать значение', Colors.deepOrange, _correctionInstructions),
          _section(theme, '⏪ Как отменить действие', Colors.grey, _undoInstructions),
          _section(theme, '📋 Как посмотреть историю', Colors.purple, _historyInstructions),
          _section(theme, '⚠️ Важные правила', Colors.red, _rules),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _intro(ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Добро пожаловать!', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Это рабочее место кассира для работы с платёжными документами жильцов. '
            'Здесь вы можете вносить оплату, делать перерасчёты и начисления, '
            'а также закрывать отчётные периоды.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ]),
      ),
    );
  }

  Widget _section(ThemeData theme, String title, Color color, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withAlpha(60), width: 1),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: color.withAlpha(30),
          child: Text(title.substring(0, 2), style: const TextStyle(fontSize: 16)),
        ),
        title: Text(
          title.substring(3),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: children,
      ),
    );
  }

  // ═══ Контент секций ═══

  List<Widget> get _startMonth => [
    _step('1', 'Откройте раздел «Платёжные документы» в нижнем меню.'),
    _step('2', 'Убедитесь, что документы за прошлый месяц введены корректно (все оплаты разнесены).'),
    _step('3', 'Зайдите в «Настройки» → «Закрытие периода» (или попросите администратора).'),
    _step('4', 'Укажите прошедший месяц и нажмите «Закрыть период».'),
    _step('5', 'Система автоматически создаст документы на следующий месяц, перенеся долги.'),
    _note('Закрытие периода можно сделать только один раз. Если документы на новый месяц уже есть — они не будут дублироваться.'),
  ];

  List<Widget> get _paymentInstructions => [
    _step('1', 'Найдите жильца в списке по фамилии, адресу или номеру лицевого счёта.'),
    _step('2', 'Нажмите на строку — откроется карточка документа.'),
    _step('3', 'Нажмите кнопку 💰 «Оплата».'),
    _step('4', 'Введите суммы оплаты по каждой услуге отдельно:'),
    _indent('• Отопление\n• Горячая вода\n• Теплообслуживание\n• ТБО\n• ОДН Электричество\n• ОДН Вода'),
    _step('5', 'Необязательно заполнять все поля — введите только те услуги, за которые платит жилец.'),
    _step('6', 'Нажмите «Оплатить». Долг пересчитается автоматически.'),
    _note('Суммы оплаты ДОБАВЛЯЮТСЯ к уже введённым. Нельзя ввести отрицательную оплату — для этого используйте Корректировку.'),
  ];

  List<Widget> get _autoPayInstructions => [
    _step('1', 'Нажмите 🔄 «Авто-оплата» на карточке документа.'),
    _step('2', 'Введите ОБЩУЮ сумму, которую жилец принёс в кассу (например, 3000 ₽).'),
    _step('3', 'Нажмите «Оплатить».'),
    _step('4', 'Система сама распределит сумму пропорционально долгам по каждой услуге.'),
    _example(
      'Пример: долг 20 650 ₽\n'
      '  Отопление 11 420₽ (55%) → 1 650₽\n'
      '  ГВС 5 800₽ (28%)        → 840₽\n'
      '  ТО 2 500₽ (12%)         → 360₽\n'
      '  ... и т.д.',
    ),
    _note('Авто-оплата удобна, когда жилец платит одной суммой без разбивки по услугам.'),
  ];

  List<Widget> get _recalcInstructions => [
    _step('1', 'Нажмите 📊 «Перерасчёт» на карточке документа.'),
    _step('2', 'Выберите услугу, по которой нужен перерасчёт.'),
    _step('3', 'Введите сумму перерасчёта:'),
    _indent('• Если жильцу надо снизить долг (льгота, ошибка, переплата) — введите отрицательное число (например −500).'),
    _indent('• Если надо доначислить — введите положительное число.'),
    _step('4', 'Введите комментарий (причину).'),
    _step('5', 'Нажмите «Применить». Долг пересчитается.'),
    _example(
      'Пример: жилец переплатил за отопление.\n'
      '  Перерасчёт Отопление: −500₽\n'
      '  Долг был: 11 420₽ → стал: 10 920₽',
    ),
  ];

  List<Widget> get _chargeInstructions => [
    _step('1', 'Нажмите 📝 «Начисление» на карточке документа.'),
    _step('2', 'Выберите услугу.'),
    _step('3', 'Введите сумму начисления (всегда положительная).'),
    _step('4', 'Нажмите «Применить».'),
    _note('Начисление увеличивает сумму «Начислено» и пересчитывает долг.\n\nОбычно начисления делаются автоматически при массовом начислении по тарифам. Ручное начисление — для разовых случаев (перерасход, индивидуальный расчёт).'),
  ];

  List<Widget> get _correctionInstructions => [
    _step('1', 'Нажмите ✏️ «Корректировка» — это самая мощная функция.'),
    _step('2', 'Выберите услугу.'),
    _step('3', 'Выберите поле для изменения:'),
    _indent(
      '• Долг на начало — если нужно исправить сальдо\n'
      '• Начислено — если начислена неправильная сумма\n'
      '• Оплачено — если оплата введена неверно\n'
      '• Перерасчёт — если перерасчёт введён неверно\n'
      '• Долг на конец — прямая установка итогового долга',
    ),
    _step('4', 'Введите НОВОЕ точное значение (не дельту, а готовую цифру).'),
    _step('5', 'ОБЯЗАТЕЛЬНО укажите причину — без причины корректировка не сохранится.'),
    _step('6', 'Нажмите «Применить».'),
    _warning('Корректировка — это прямое изменение данных. Она записывается в историю операций с указанием вашего имени. Используйте только при реальных ошибках.'),
  ];

  List<Widget> get _undoInstructions => [
    _step('1', 'Нажмите ⏪ «Отменить последнее действие» внизу карточки документа.'),
    _step('2', 'Появится подтверждение — нажмите «Да, отменить».'),
    _step('3', 'Система найдёт последнюю выполненную операцию и откатит её:'),
    _indent(
      '• Если последняя операция была оплата 500₽ → оплата уменьшится на 500₽\n'
      '• Если перерасчёт −200₽ → перерасчёт вернётся на 200₽\n'
      '• Если начисление 1420₽ → начисление уменьшится на 1420₽',
    ),
    _step('4', 'Долг автоматически пересчитается.'),
    _step('5', 'В истории отменённая операция будет зачёркнута, а рядом появится запись «⏪ Отмена».'),
    _note('Можно нажать «Отмена» несколько раз — каждый раз отменяется предыдущая операция. Максимум 10 отмен подряд.'),
    _example(
      'Пример:\n'
      '  1-я отмена → отменяет последнюю оплату\n'
      '  2-я отмена → отменяет перерасчёт (который был до оплаты)\n'
      '  3-я отмена → отменяет начисление (которое было до перерасчёта)\n'
      '  ... и так до 10 раз',
    ),
    _note('Если вы отменили операцию по ошибке — нажмите ⏩ «Вернуть» чтобы восстановить её. Работает как Ctrl+Z / Ctrl+Y.'),
    _example(
      'Пример:\n'
      '  ⏪ Отменить → отменяет оплату 500₽ (долг вырос)\n'
      '  ⏩ Вернуть  → восстанавливает оплату 500₽ (долг снова уменьшился)\n'
      '  ⏪ Отменить → снова отменяет (если передумали)',
    ),
  ];

  List<Widget> get _historyInstructions => [
    _step('1', 'Нажмите 📋 «История» на карточке документа.'),
    _step('2', 'Откроется список всех операций по этому документу в обратном хронологическом порядке.'),
    _step('3', 'Каждая запись показывает:'),
    _indent(
      '• Тип операции (Оплата / Перерасчёт / Начисление / Корректировка)\n'
      '• Услугу\n'
      '• Сумму операции\n'
      '• Долг ДО и ПОСЛЕ операции\n'
      '• Кто и когда выполнил',
    ),
    _note('История — для контроля ошибок и разбора спорных ситуаций. Записи нельзя удалить.'),
  ];

  List<Widget> get _rules => [
    _warning('1. Нельзя вносить отрицательную оплату. Если жилец вернул переплату — используйте Корректировку поля «Оплачено».'),
    _warning('2. Закрытие периода необратимо — убедитесь, что все данные за месяц введены.'),
    _warning('3. Корректировка всегда требует причины — это обязательное поле.'),
    _info('4. При любых сомнениях используйте вкладку «История» — там видно, кто и что менял.'),
    _info('5. Долг на конец считается автоматически по формуле:\n    Долг_нач + Начислено − Оплачено + Перерасчёт = Долг_кон'),
    _info('6. Авто-оплата — самый быстрый способ при приёме наличных. Указывайте сумму квитанции целиком.'),
  ];

  // ═══ Вспомогательные виджеты ═══

  Widget _step(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 24, height: 24,
          margin: const EdgeInsets.only(right: 10, top: 2),
          decoration: BoxDecoration(color: Colors.grey.shade700, shape: BoxShape.circle),
          child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
        ),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, height: 1.5))),
      ]),
    );
  }

  Widget _indent(String text) {
    return Container(
      margin: const EdgeInsets.only(left: 34, bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontSize: 13, height: 1.6, fontFamily: 'monospace')),
    );
  }

  Widget _example(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('💡 ', style: TextStyle(fontSize: 16)),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, height: 1.6, color: Colors.blue.shade900))),
      ]),
    );
  }

  Widget _note(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('📌 ', style: TextStyle(fontSize: 16)),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, height: 1.5, color: Colors.amber.shade900))),
      ]),
    );
  }

  Widget _warning(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('⛔ ', style: TextStyle(fontSize: 16)),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, height: 1.5, color: Colors.red.shade900))),
      ]),
    );
  }

  Widget _info(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('✅ ', style: TextStyle(fontSize: 16)),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, height: 1.5, color: Colors.green.shade900))),
      ]),
    );
  }
}
