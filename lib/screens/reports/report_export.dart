import 'dart:io';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../../services/file_export_helper.dart';
import 'report_utils.dart';

/// Экспорт отчёта в PDF и CSV.
class ReportExporter {
  ReportExporter._();

  // ═══════════════════════════════════════════════════════════════════════
  // PDF
  // ═══════════════════════════════════════════════════════════════════════

  /// Генерирует PDF-файл и возвращает путь к нему.
  static Future<File> exportPdf({
    required Map<String, dynamic> reportResult,
    required String periodLabel,
    required String locationName,
  }) async {
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
    );

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
      header: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Аналитический отчёт', style: pw.TextStyle(font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Период: $periodLabel • Дом: $locationName',
              style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey700)),
          pw.Divider(),
        ],
      ),
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('TeploService', style: pw.TextStyle(font: ttf, fontSize: 8, color: PdfColors.grey500)),
          pw.Text('Стр. ${ctx.pageNumber}/${ctx.pagesCount}',
              style: pw.TextStyle(font: ttf, fontSize: 8, color: PdfColors.grey500)),
        ],
      ),
      build: (ctx) => [
        if (reportResult.containsKey('summary')) ...[
          _sectionTitle(ttf, 'Общая сводка'), _summaryTable(reportResult), pw.SizedBox(height: 12),
        ],
        if (reportResult.containsKey('top_houses')) ...[
          _sectionTitle(ttf, 'Топ домов по долгу'), _topHousesTable(reportResult), pw.SizedBox(height: 12),
        ],
        if (reportResult.containsKey('top_debtors')) ...[
          _sectionTitle(ttf, 'Топ должников'), _debtorsTable(reportResult), pw.SizedBox(height: 12),
        ],
        if (reportResult.containsKey('last_payments')) ...[
          _sectionTitle(ttf, 'Последние оплаты'), _paymentsTable(reportResult), pw.SizedBox(height: 12),
        ],
        if (reportResult.containsKey('monthly_dynamics')) ...[
          _sectionTitle(ttf, 'Динамика по периодам'), _monthlyTable(reportResult), pw.SizedBox(height: 12),
        ],
        if (reportResult.containsKey('by_services')) ...[
          _sectionTitle(ttf, 'Разбивка по услугам'), _servicesTable(reportResult), pw.SizedBox(height: 12),
        ],
        if (reportResult.containsKey('overpayments')) ...[
          _sectionTitle(ttf, 'Переплаты'), _overpaymentsTable(reportResult), pw.SizedBox(height: 12),
        ],
        if (reportResult.containsKey('best_payers')) ...[
          _sectionTitle(ttf, 'Лучшие плательщики'), _bestPayersTable(reportResult), pw.SizedBox(height: 12),
        ],
        if (reportResult.containsKey('payment_trend')) ...[
          _sectionTitle(ttf, 'Тренд собираемости'), _trendTable(reportResult), pw.SizedBox(height: 12),
        ],
        if (reportResult.containsKey('recalc_analysis')) ...[
          _sectionTitle(ttf, 'Анализ перерасчётов'), _recalcTable(reportResult), pw.SizedBox(height: 12),
        ],
        if (reportResult.containsKey('debt_aging')) ...[
          _sectionTitle(ttf, 'Группировка долгов'), _debtAgingTable(reportResult), pw.SizedBox(height: 12),
        ],
        if (reportResult.containsKey('location_comparison')) ...[
          _sectionTitle(ttf, 'Сравнение домов'), _locationComparisonTable(reportResult),
        ],
      ],
    ));

    final dir = await getTemporaryDirectory();
    final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ── PDF table helpers ──

  static pw.Widget _sectionTitle(pw.Font font, String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(title, style: pw.TextStyle(font: font, fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
    );
  }

  static pw.Widget _summaryTable(Map<String, dynamic> r) {
    final data = r['summary'] as Map<String, dynamic>? ?? {};
    final totalCharged = (data['total_charged'] as num?)?.toDouble() ?? 0;
    final totalPaid = (data['total_paid'] as num?)?.toDouble() ?? 0;
    final totalDebt = (data['total_debt'] as num?)?.toDouble() ?? 0;
    final count = data['count'] as int? ?? 0;
    final debtorsCount = data['debtors_count'] as int? ?? 0;
    final collection = totalCharged > 0 ? (totalPaid / totalCharged * 100).clamp(0.0, 100.0) : 0.0;
    return pw.TableHelper.fromTextArray(
      headers: ['Показатель', 'Значение'],
      data: [
        ['Лицевых счетов', '$count'],
        ['Начислено', '${totalCharged.toStringAsFixed(2)} ₽'],
        ['Оплачено', '${totalPaid.toStringAsFixed(2)} ₽'],
        ['Долг', '${totalDebt.toStringAsFixed(2)} ₽'],
        ['Должников', '$debtorsCount'],
        ['Собираемость', '${collection.toStringAsFixed(1)}%'],
      ],
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellAlignments: {0: pw.Alignment.centerLeft, 1: pw.Alignment.centerRight},
    );
  }

  static pw.Widget _topHousesTable(Map<String, dynamic> r) {
    final houses = (r['top_houses'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['#', 'Дом', 'ЛС', 'Начислено', 'Оплачено', 'Долг'],
      data: houses.asMap().entries.map((e) {
        final h = e.value;
        return ['${e.key + 1}', h['name'] ?? '', '${h['count'] ?? 0}',
          (((h['total_charged'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)),
          (((h['total_paid'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)),
          (((h['total_debt'] as num?)?.toDouble() ?? 0).toStringAsFixed(2))];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.orange50),
      cellAlignments: {0: pw.Alignment.center, 3: pw.Alignment.centerRight, 4: pw.Alignment.centerRight, 5: pw.Alignment.centerRight},
    );
  }

  static pw.Widget _debtorsTable(Map<String, dynamic> r) {
    final items = (r['top_debtors'] as List?) ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['#', 'ФИО', 'Адрес', 'ЛС', 'Начислено', 'Долг'],
      data: items.asMap().entries.map((e) {
        final d = e.value as Map<String, dynamic>;
        return ['${e.key + 1}', d['fio'] ?? '', d['address'] ?? '', d['account_number'] ?? '',
          (((d['total_charged'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)),
          (((d['total_debt_end'] as num?)?.toDouble() ?? 0).toStringAsFixed(2))];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.red50),
      cellAlignments: {0: pw.Alignment.center, 4: pw.Alignment.centerRight, 5: pw.Alignment.centerRight},
    );
  }

  static pw.Widget _paymentsTable(Map<String, dynamic> r) {
    final items = (r['last_payments'] as List?) ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['#', 'ФИО', 'Дом', 'Адрес', 'ЛС', 'Оплачено', 'Долг', 'Мес.'],
      data: items.asMap().entries.map((e) {
        final d = e.value as Map<String, dynamic>;
        final paid = (d['total_paid'] as num?)?.toDouble() ?? 0;
        final debt = (d['total_debt_end'] as num?)?.toDouble() ?? 0;
        final charged = (d['total_charged'] as num?)?.toDouble() ?? 0;
        final isOverpaid = debt < -0.01;
        final debtStr = isOverpaid ? '+${debt.abs().toStringAsFixed(2)}' : debt.toStringAsFixed(2);
        final months = charged > 0 ? (paid / charged).floor() : 0;
        return ['${e.key + 1}', d['fio'] ?? '', d['location_name'] ?? '', d['address'] ?? '',
          d['account_number'] ?? '', paid.toStringAsFixed(2), debtStr, months >= 1 ? '$months' : '-'];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 7),
      headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green50),
      cellAlignments: {0: pw.Alignment.center, 5: pw.Alignment.centerRight, 6: pw.Alignment.centerRight, 7: pw.Alignment.center},
    );
  }

  static pw.Widget _monthlyTable(Map<String, dynamic> r) {
    final periods = (r['monthly_dynamics'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['Период', 'ЛС', 'Начислено', 'Оплачено', 'Долг', '%'],
      data: periods.map((p) {
        final charged = (p['total_charged'] as num?)?.toDouble() ?? 0;
        final paid = (p['total_paid'] as num?)?.toDouble() ?? 0;
        final debt = (p['total_debt'] as num?)?.toDouble() ?? 0;
        final coll = charged > 0 ? (paid / charged * 100).clamp(0.0, 100.0) : 0.0;
        return [p['period_label'] ?? p['period'] ?? '', '${p['count'] ?? 0}',
          charged.toStringAsFixed(2), paid.toStringAsFixed(2), debt.toStringAsFixed(2), '${coll.toStringAsFixed(1)}%'];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.cyan50),
      cellAlignments: {1: pw.Alignment.center, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight, 4: pw.Alignment.centerRight, 5: pw.Alignment.centerRight},
    );
  }

  static pw.Widget _servicesTable(Map<String, dynamic> r) {
    final services = (r['by_services'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['Услуга', 'Начислено', 'Оплачено', 'Долг'],
      data: services.map((s) => [s['label'] ?? '',
        (((s['charged'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)),
        (((s['paid'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)),
        (((s['debt'] as num?)?.toDouble() ?? 0).toStringAsFixed(2))]).toList(),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.amber50),
      cellAlignments: {1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight},
    );
  }

  static pw.Widget _overpaymentsTable(Map<String, dynamic> r) {
    final items = (r['overpayments'] as List?) ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['#', 'ФИО', 'Дом', 'Адрес', 'ЛС', 'Переплата'],
      data: items.asMap().entries.map((e) {
        final d = e.value as Map<String, dynamic>;
        final debt = (d['total_debt_end'] as num?)?.toDouble() ?? 0;
        return ['${e.key + 1}', d['fio'] ?? '', d['location_name'] ?? '', d['address'] ?? '',
          d['account_number'] ?? '', debt.abs().toStringAsFixed(2)];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal50),
      cellAlignments: {0: pw.Alignment.center, 5: pw.Alignment.centerRight},
    );
  }

  static pw.Widget _bestPayersTable(Map<String, dynamic> r) {
    final items = (r['best_payers'] as List?) ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['#', 'ФИО', 'Дом', 'Адрес', 'ЛС', 'Оплачено', '% оплаты'],
      data: items.asMap().entries.map((e) {
        final d = e.value as Map<String, dynamic>;
        final paid = (d['total_paid'] as num?)?.toDouble() ?? 0;
        final pct = (d['_pay_percent'] as num?)?.toDouble() ?? 0;
        return ['${e.key + 1}', d['fio'] ?? '', d['location_name'] ?? '', d['address'] ?? '',
          d['account_number'] ?? '', paid.toStringAsFixed(2), '${pct.toStringAsFixed(1)}%'];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 7),
      headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.purple50),
      cellAlignments: {0: pw.Alignment.center, 5: pw.Alignment.centerRight, 6: pw.Alignment.centerRight},
    );
  }

  static pw.Widget _trendTable(Map<String, dynamic> r) {
    final items = (r['payment_trend'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['Период', 'Собираемость %', 'Изменение'],
      data: items.map((t) {
        final coll = (t['collection'] as num?)?.toDouble() ?? 0;
        final delta = (t['delta'] as num?)?.toDouble() ?? 0;
        return [t['period_label'] ?? '', '${coll.toStringAsFixed(1)}%',
          '${delta >= 0 ? "+" : ""}${delta.toStringAsFixed(1)}%'];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo50),
    );
  }

  static pw.Widget _recalcTable(Map<String, dynamic> r) {
    final items = (r['recalc_analysis'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['Услуга', 'Начислено', 'Перерасчёт', '% от начисл.', 'Аномалия'],
      data: items.map((s) {
        final charged = (s['charged'] as num?)?.toDouble() ?? 0;
        final recalc = (s['recalc'] as num?)?.toDouble() ?? 0;
        final ratio = (s['recalc_ratio'] as num?)?.toDouble() ?? 0;
        return [s['label'] ?? '', charged.toStringAsFixed(2), recalc.toStringAsFixed(2),
          '${ratio.toStringAsFixed(1)}%', s['is_anomaly'] == true ? '⚠️ ДА' : 'нет'];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.deepOrange50),
    );
  }

  static pw.Widget _debtAgingTable(Map<String, dynamic> r) {
    final groups = (r['debt_aging'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['Диапазон', 'Кол-во', 'Сумма долга'],
      data: groups.map((g) => [g['label'] ?? '', '${g['count']}', (g['total'] as double).toStringAsFixed(2)]).toList(),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.brown50),
    );
  }

  static pw.Widget _locationComparisonTable(Map<String, dynamic> r) {
    final items = (r['location_comparison'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return pw.TableHelper.fromTextArray(
      headers: ['Дом', 'ЛС', 'Сбор.%', 'Ср. долг', 'Долж.%'],
      data: items.map((h) {
        final coll = (h['collection'] as num?)?.toDouble() ?? 0;
        final avgDebt = (h['avg_debt'] as num?)?.toDouble() ?? 0;
        final debtorsPct = (h['debtors_pct'] as num?)?.toDouble() ?? 0;
        return [h['name'] ?? '', '${h['count']}', '${coll.toStringAsFixed(0)}%',
          avgDebt.toStringAsFixed(2), '${debtorsPct.toStringAsFixed(0)}%'];
      }).toList(),
      cellStyle: const pw.TextStyle(fontSize: 8),
      headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CSV
  // ═══════════════════════════════════════════════════════════════════════

  /// Генерирует CSV-файл и возвращает путь к нему.
  static Future<File> exportCsv({
    required Map<String, dynamic> reportResult,
    required String periodLabel,
    required String locationName,
  }) async {
    final buf = StringBuffer();
    buf.writeln('Аналитический отчёт TeploService');
    buf.writeln('Период: $periodLabel');
    buf.writeln('Дом: $locationName');
    buf.writeln();

    final r = reportResult;

    if (r.containsKey('summary')) {
      final data = r['summary'] as Map<String, dynamic>? ?? {};
      buf.writeln('=== ОБЩАЯ СВОДКА ===');
      buf.writeln('Показатель;Значение');
      buf.writeln('Лицевых счетов;${data['count'] ?? 0}');
      buf.writeln('Начислено;${(data['total_charged'] as num?)?.toDouble() ?? 0}');
      buf.writeln('Оплачено;${(data['total_paid'] as num?)?.toDouble() ?? 0}');
      buf.writeln('Долг;${(data['total_debt'] as num?)?.toDouble() ?? 0}');
      buf.writeln('Должников;${data['debtors_count'] ?? 0}');
      buf.writeln();
    }

    if (r.containsKey('top_houses')) {
      final houses = (r['top_houses'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      buf.writeln('=== ТОП ДОМОВ ===');
      buf.writeln('#;Дом;ЛС;Начислено;Оплачено;Долг');
      for (var i = 0; i < houses.length; i++) {
        final h = houses[i];
        buf.writeln('${i + 1};${h['name']};${h['count']};${h['total_charged']};${h['total_paid']};${h['total_debt']}');
      }
      buf.writeln();
    }

    if (r.containsKey('top_debtors')) {
      final items = (r['top_debtors'] as List?) ?? [];
      buf.writeln('=== ТОП ДОЛЖНИКОВ ===');
      buf.writeln('#;ФИО;Адрес;ЛС;Начислено;Долг');
      for (var i = 0; i < items.length; i++) {
        final d = items[i] as Map<String, dynamic>;
        buf.writeln('${i + 1};${d['fio']};${d['address']};${d['account_number']};${d['total_charged']};${d['total_debt_end']}');
      }
      buf.writeln();
    }

    if (r.containsKey('last_payments')) {
      final items = (r['last_payments'] as List?) ?? [];
      buf.writeln('=== ПОСЛЕДНИЕ ОПЛАТЫ ===');
      buf.writeln('#;ФИО;Дом;Адрес;ЛС;Оплачено;Долг/Переплата;Мес.');
      for (var i = 0; i < items.length; i++) {
        final d = items[i] as Map<String, dynamic>;
        final paid = (d['total_paid'] as num?)?.toDouble() ?? 0;
        final debt = (d['total_debt_end'] as num?)?.toDouble() ?? 0;
        final charged = (d['total_charged'] as num?)?.toDouble() ?? 0;
        final isOverpaid = debt < -0.01;
        final debtStr = isOverpaid ? '+${debt.abs().toStringAsFixed(2)} (переплата)' : debt.toStringAsFixed(2);
        final months = charged > 0 ? (paid / charged).floor() : 0;
        buf.writeln('${i + 1};${d['fio']};${d['location_name'] ?? ''};${d['address'] ?? ''};${d['account_number']};${paid.toStringAsFixed(2)};$debtStr;${months >= 1 ? '$months' : '-'}');
      }
      buf.writeln();
    }

    if (r.containsKey('monthly_dynamics')) {
      final periods = (r['monthly_dynamics'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      buf.writeln('=== ДИНАМИКА ===');
      buf.writeln('Период;ЛС;Начислено;Оплачено;Долг');
      for (final p in periods) {
        buf.writeln('${p['period_label'] ?? p['period']};${p['count']};${p['total_charged']};${p['total_paid']};${p['total_debt']}');
      }
      buf.writeln();
    }

    if (r.containsKey('by_services')) {
      final svcs = (r['by_services'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      buf.writeln('=== ПО УСЛУГАМ ===');
      buf.writeln('Услуга;Начислено;Оплачено;Долг');
      for (final s in svcs) {
        buf.writeln('${s['label']};${s['charged']};${s['paid']};${s['debt']}');
      }
      buf.writeln();
    }

    if (r.containsKey('overpayments')) {
      final items = (r['overpayments'] as List?) ?? [];
      buf.writeln('=== ПЕРЕПЛАТЫ ===');
      buf.writeln('#;ФИО;Дом;Адрес;ЛС;Переплата');
      for (var i = 0; i < items.length; i++) {
        final d = items[i] as Map<String, dynamic>;
        final debt = (d['total_debt_end'] as num?)?.toDouble() ?? 0;
        buf.writeln('${i + 1};${d['fio']};${d['location_name'] ?? ''};${d['address'] ?? ''};${d['account_number']};${debt.abs()}');
      }
      buf.writeln();
    }

    if (r.containsKey('best_payers')) {
      final items = (r['best_payers'] as List?) ?? [];
      buf.writeln('=== ЛУЧШИЕ ПЛАТЕЛЬЩИКИ ===');
      buf.writeln('#;ФИО;Дом;Адрес;ЛС;Оплачено;% оплаты');
      for (var i = 0; i < items.length; i++) {
        final d = items[i] as Map<String, dynamic>;
        buf.writeln('${i + 1};${d['fio']};${d['location_name'] ?? ''};${d['address'] ?? ''};${d['account_number']};${d['total_paid']};${(d['_pay_percent'] as num?)?.toDouble().toStringAsFixed(1) ?? '0'}%');
      }
      buf.writeln();
    }

    if (r.containsKey('payment_trend')) {
      final items = (r['payment_trend'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      buf.writeln('=== ТРЕНД СОБИРАЕМОСТИ ===');
      buf.writeln('Период;Собираемость %;Изменение %');
      for (final t in items) {
        buf.writeln('${t['period_label']};${(t['collection'] as num?)?.toDouble().toStringAsFixed(1)};${(t['delta'] as num?)?.toDouble().toStringAsFixed(1)}');
      }
      buf.writeln();
    }

    if (r.containsKey('recalc_analysis')) {
      final items = (r['recalc_analysis'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      buf.writeln('=== ПЕРЕРАСЧЁТЫ ===');
      buf.writeln('Услуга;Начислено;Перерасчёт;% от начисл;Аномалия');
      for (final s in items) {
        buf.writeln('${s['label']};${s['charged']};${s['recalc']};${(s['recalc_ratio'] as num?)?.toDouble().toStringAsFixed(1)};${s['is_anomaly'] == true ? 'ДА' : 'нет'}');
      }
      buf.writeln();
    }

    if (r.containsKey('debt_aging')) {
      final groups = (r['debt_aging'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      buf.writeln('=== ГРУППИРОВКА ДОЛГОВ ===');
      buf.writeln('Диапазон;Кол-во;Сумма долга');
      for (final g in groups) {
        buf.writeln('${g['label']};${g['count']};${(g['total'] as double).toStringAsFixed(2)}');
      }
      buf.writeln();
    }

    if (r.containsKey('location_comparison')) {
      final items = (r['location_comparison'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      buf.writeln('=== СРАВНЕНИЕ ДОМОВ ===');
      buf.writeln('Дом;ЛС;Собираемость %;Ср. долг;Должников %');
      for (final h in items) {
        buf.writeln('${h['name']};${h['count']};${(h['collection'] as num?)?.toDouble().toStringAsFixed(1)};${(h['avg_debt'] as num?)?.toDouble().toStringAsFixed(2)};${(h['debtors_pct'] as num?)?.toDouble().toStringAsFixed(1)}');
      }
    }

    final dir = await getTemporaryDirectory();
    final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(utf8.encode(buf.toString()), flush: true);
    return file;
  }
}
