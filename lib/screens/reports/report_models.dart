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
];

/// Группы секций для конфигуратора.
const sectionGroups = <String, List<String>>{
  '📊 Обзор': ['summary', 'monthly_dynamics', 'payment_trend'],
  '📋 Детализация': ['top_houses', 'top_debtors', 'best_payers', 'last_payments', 'location_comparison'],
  '🔍 Специальные': ['by_services', 'recalc_analysis', 'overpayments', 'debt_aging'],
};

/// Пресеты отчётов.
const reportPresets = <String, Map<String, List<String>>>{
  '📊 Руководителю': {'keys': ['summary', 'top_houses', 'monthly_dynamics', 'payment_trend', 'location_comparison']},
  '💰 Бухгалтеру': {'keys': ['summary', 'by_services', 'recalc_analysis', 'last_payments', 'overpayments']},
  '⚖️ Юристу': {'keys': ['top_debtors', 'debt_aging', 'overpayments']},
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
};
