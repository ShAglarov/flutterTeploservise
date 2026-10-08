import 'package:flutter/material.dart';

/// Определение секции отчёта — метаданные для конфигуратора.
class SectionDef {
  final String key;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const SectionDef(this.key, this.icon, this.color, this.title, this.subtitle);
}

/// Все секции отчёта.
final sectionDefinitions = <SectionDef>[
  SectionDef('summary', Icons.pie_chart, Colors.blue, 'Общая сводка', 'Начислено, оплачено, долг, % собираемости'),
  SectionDef('top_houses', Icons.apartment, Colors.orange, 'Топ домов по долгу', 'Рейтинг домов с наибольшей задолженностью'),
  SectionDef('top_debtors', Icons.person_off, Colors.red, 'Топ должников', 'Абоненты с максимальным долгом'),
  SectionDef('last_payments', Icons.payment, Colors.green, 'Последние оплаты', 'Абоненты с ненулевой оплатой за период'),
  SectionDef('monthly_dynamics', Icons.show_chart, Colors.cyan, 'Динамика по периодам', 'Тренды начислений и оплат по месяцам'),
  SectionDef('by_services', Icons.category, Colors.amber, 'Разбивка по услугам', 'Детализация: отопление, ГВС, ТБО, ОДН и др.'),
  SectionDef('overpayments', Icons.trending_down, Colors.teal, 'Переплаты', 'Абоненты с отрицательным долгом'),
  SectionDef('best_payers', Icons.star, Colors.purple, 'Лучшие плательщики', 'Топ по проценту оплаты'),
  SectionDef('payment_trend', Icons.trending_up, Colors.indigo, 'Тренд собираемости', 'Рост/падение оплат между периодами'),
  SectionDef('recalc_analysis', Icons.sync_alt, Colors.deepOrange, 'Анализ перерасчётов', 'Перерасчёты по услугам, аномалии'),
  SectionDef('debt_aging', Icons.hourglass_bottom, Colors.brown, 'Группировка долгов', 'Распределение должников по суммам'),
  SectionDef('location_comparison', Icons.compare_arrows, Colors.blueGrey, 'Сравнение домов', 'Таблица ключевых метрик по домам'),

  // ── Касса и платежи ──
  // Раньше по кассе в конструкторе не было ни одной секции, хотя журнал
  // операций хранит кассира, сумму, услугу и заявленный период.
  SectionDef('cashier_shift', Icons.point_of_sale, Colors.green, 'Кассовая смена',
      'Принято за день: по услугам и кассирам'),
  SectionDef('payments_register', Icons.receipt_long, Colors.teal, 'Реестр платежей',
      'Построчно: ЛС, плательщик, сумма, кассир'),
  SectionDef('cashier_performance', Icons.badge, Colors.indigo, 'Работа кассиров',
      'Принято, средний платёж, отмены по каждому'),
  SectionDef('payment_structure', Icons.call_split, Colors.deepPurple, 'Структура поступлений',
      'Текущие начисления, погашение долга, аванс'),

  // ── Честные итоги по всей базе ──
  SectionDef('collection_summary', Icons.account_balance_wallet, Colors.blue,
      'Собираемость (расширенная)',
      'Текущая и общая собираемость, куда пошли деньги'),
  SectionDef('debt_distribution', Icons.bar_chart, Colors.red, 'Распределение долгов',
      'Группы долга по ВСЕЙ базе, а не по топ-N'),
];

/// Группы секций для конфигуратора.
const sectionGroups = <String, List<String>>{
  '📊 Обзор': ['summary', 'collection_summary', 'monthly_dynamics', 'payment_trend'],
  '💰 Касса и платежи': [
    'cashier_shift', 'payments_register', 'cashier_performance', 'payment_structure',
  ],
  '📋 Детализация': ['top_houses', 'top_debtors', 'best_payers', 'last_payments', 'location_comparison'],
  '🔍 Долги и услуги': ['debt_distribution', 'by_services', 'recalc_analysis', 'overpayments', 'debt_aging'],
};

/// Пресеты по роли: что человеку реально нужно показать руководству.
///
/// Кассир закрывает день, бухгалтер сводит поступления и перерасчёты,
/// директор смотрит динамику и собираемость, юрист — долги для взыскания.
const reportPresets = <String, Map<String, List<String>>>{
  '💰 Кассиру': {'keys': [
    'cashier_shift', 'payments_register', 'payment_structure',
  ]},
  '📒 Бухгалтеру': {'keys': [
    'collection_summary', 'by_services', 'recalc_analysis',
    'payments_register', 'overpayments',
  ]},
  '📊 Директору': {'keys': [
    'collection_summary', 'monthly_dynamics', 'payment_trend',
    'debt_distribution', 'location_comparison', 'cashier_performance',
  ]},
  '⚖️ Юристу': {'keys': [
    'top_debtors', 'debt_distribution', 'overpayments',
  ]},
  '🔍 Контроль кассы': {'keys': [
    'cashier_performance', 'payment_structure', 'recalc_analysis', 'overpayments',
  ]},
};

/// Секции-потомки — не делают сетевых запросов, вычисляются из данных других секций.
const derivedSections = {'payment_trend', 'recalc_analysis', 'debt_aging', 'location_comparison'};

/// Дефолтные значения секций.
Map<String, bool> defaultSections() => {
  'summary': true,
  'top_houses': false,
  'top_debtors': true,
  'last_payments': false,
  'monthly_dynamics': false,
  'by_services': false,
  'overpayments': false,
  'best_payers': false,
  'payment_trend': false,
  'recalc_analysis': false,
  'debt_aging': false,
  'location_comparison': false,
  'cashier_shift': false,
  'payments_register': false,
  'cashier_performance': false,
  'payment_structure': false,
  // По умолчанию включаем расширенную сводку и честное распределение
  // долгов: это то, что чаще всего нужно и бухгалтеру, и директору.
  'collection_summary': true,
  'debt_distribution': false,
};
