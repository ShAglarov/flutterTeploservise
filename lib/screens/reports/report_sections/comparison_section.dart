import 'package:flutter/material.dart';
import '../report_utils.dart';
import 'section_card.dart';

/// Секция 12: Сравнение домов.
class ComparisonSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ComparisonSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ReportSectionCard(
      icon: Icons.compare_arrows, title: 'Сравнение домов', color: Colors.blueGrey,
      subtitle: '${items.length} домов',
      child: items.isEmpty
          ? const Center(child: Text('Нет данных', style: TextStyle(fontSize: 13)))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 8,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 44,
                headingRowHeight: 36,
                columns: const [
                  DataColumn(label: Text('Дом', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('ЛС', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)), numeric: true),
                  DataColumn(label: Text('Сбор.%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)), numeric: true),
                  DataColumn(label: Text('Ср.долг', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)), numeric: true),
                  DataColumn(label: Text('Долж.%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)), numeric: true),
                ],
                rows: items.map((h) {
                  final coll = (h['collection'] as num?)?.toDouble() ?? 0;
                  final avgDebt = (h['avg_debt'] as num?)?.toDouble() ?? 0;
                  final debtorsPct = (h['debtors_pct'] as num?)?.toDouble() ?? 0;
                  return DataRow(cells: [
                    DataCell(SizedBox(width: 120, child: Text(h['name'] ?? '', style: const TextStyle(fontSize: 11),
                        maxLines: 2, overflow: TextOverflow.ellipsis))),
                    DataCell(Text('${h['count']}', style: const TextStyle(fontSize: 11))),
                    DataCell(Text('${coll.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                            color: coll >= 80 ? Colors.green : coll >= 50 ? Colors.orange : Colors.red))),
                    DataCell(Text('${fmtMoney(avgDebt)}₽', style: const TextStyle(fontSize: 11))),
                    DataCell(Text('${debtorsPct.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 11, color: debtorsPct > 50 ? Colors.red : Colors.green))),
                  ]);
                }).toList(),
              ),
            ),
    );
  }
}
