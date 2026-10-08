import 'package:dio/dio.dart';
import 'report_utils.dart';

/// Mixin для fetch-логики конструктора отчётов.
/// Требует от хоста предоставить доступ к state-переменным.
mixin ReportFetchers {
  // ── Абстрактные зависимости от хоста ──
  String? get periodFrom;
  String? get periodTo;
  int? get selectedLocationId;
  int get topN;
  double get debtThreshold;
  Map<String, dynamic> get reportResult;

  /// Общие query-параметры для диапазона периодов.
  Map<String, dynamic> get periodRangeParams => {
    if (periodFrom != null) 'period_from': periodFrom,
    if (periodTo != null) 'period_to': periodTo,
    if (selectedLocationId != null) 'location_id': selectedLocationId,
  };

  Future<void> fetchSummary(Dio dio) async {
    final resp = await dio.get('/payment-documents/reports/statistics-range', queryParameters: periodRangeParams);
    reportResult['summary'] = resp.data;
  }

  Future<void> fetchTopHouses(Dio dio) async {
    final resp = await dio.get('/payment-documents/reports/top-locations', queryParameters: {
      ...periodRangeParams,
      'limit': topN,
      if (debtThreshold > 0) 'min_debt': debtThreshold,
    });
    final data = resp.data;
    final List items = data is List ? data : [];
    reportResult['top_houses'] = items;
  }

  Future<void> fetchTopDebtors(Dio dio) async {
    final params = <String, dynamic>{
      'has_debt': true,
      'sort_by': 'debt_end',
      'sort_order': 'desc',
      'limit': topN,
      if (periodTo != null) 'period_date': periodTo,
      if (selectedLocationId != null) 'location_id': selectedLocationId,
      if (debtThreshold > 0) 'min_debt': debtThreshold,
    };
    final resp = await dio.get('/payment-documents/', queryParameters: params);
    final data = resp.data;
    final List items = data is List ? data : (data is Map ? (data['items'] ?? []) : []);
    reportResult['top_debtors'] = items;
  }

  Future<void> fetchLastPayments(Dio dio) async {
    final params = <String, dynamic>{
      'sort_by': 'total_paid',
      'sort_order': 'desc',
      'limit': topN * 3,
      if (periodTo != null) 'period_date': periodTo,
      if (selectedLocationId != null) 'location_id': selectedLocationId,
    };
    final resp = await dio.get('/payment-documents/', queryParameters: params);
    final data = resp.data;
    final List items = data is List ? data : (data is Map ? (data['items'] ?? []) : []);
    reportResult['last_payments'] = items.where((d) {
      final paid = (d['total_paid'] as num?)?.toDouble() ?? 0;
      return paid > 0;
    }).take(topN).toList();
  }

  Future<void> fetchMonthlyDynamics(Dio dio) async {
    final params = <String, dynamic>{
      if (selectedLocationId != null) 'location_id': selectedLocationId,
    };
    final resp = await dio.get('/archives/periods', queryParameters: params);
    final List<dynamic> periods = resp.data is List ? resp.data : [];

    final fromDt = DateTime.tryParse(periodFrom ?? '');
    final toDt = DateTime.tryParse(periodTo ?? '');

    final filtered = periods.where((p) {
      final pDate = DateTime.tryParse(p['period']?.toString() ?? '');
      if (pDate == null) return true;
      if (fromDt != null && pDate.isBefore(fromDt)) return false;
      if (toDt != null && pDate.isAfter(toDt.add(const Duration(days: 31)))) return false;
      return true;
    }).toList();

    reportResult['monthly_dynamics'] = filtered;
  }

  Future<void> fetchByServices(Dio dio) async {
    final resp = await dio.get('/payment-documents/reports/by-services', queryParameters: periodRangeParams);
    final data = resp.data;
    final List items = data is List ? data : [];
    reportResult['by_services'] = items;
  }

  Future<void> fetchOverpayments(Dio dio) async {
    final params = <String, dynamic>{
      'has_overpayment': true,
      'sort_by': 'debt_end',
      'sort_order': 'asc',
      'limit': topN,
      if (periodTo != null) 'period_date': periodTo,
      if (selectedLocationId != null) 'location_id': selectedLocationId,
    };
    final resp = await dio.get('/payment-documents/', queryParameters: params);
    final data = resp.data;
    final List items = data is List ? data : (data is Map ? (data['items'] ?? []) : []);
    reportResult['overpayments'] = items;
  }

  Future<void> fetchBestPayers(Dio dio) async {
    final fetchLimit = topN > 200 ? topN : 200;
    final params = <String, dynamic>{
      'sort_by': 'total_paid',
      'sort_order': 'desc',
      'limit': fetchLimit,
      if (periodTo != null) 'period_date': periodTo,
      if (selectedLocationId != null) 'location_id': selectedLocationId,
    };
    final resp = await dio.get('/payment-documents/', queryParameters: params);
    final data = resp.data;
    final List items = data is List ? data : (data is Map ? (data['items'] ?? []) : []);

    final scored = items.map((d) {
      final charged = (d['total_charged'] as num?)?.toDouble() ?? 0;
      final paid = (d['total_paid'] as num?)?.toDouble() ?? 0;
      final pct = charged > 0 ? (paid / charged * 100).clamp(0.0, 100.0) : 0.0;
      return {...(d as Map<String, dynamic>), '_pay_percent': pct};
    }).where((d) => (d['total_charged'] as num?)?.toDouble() != null && (d['total_charged'] as num).toDouble() > 0)
    .toList();

    scored.sort((a, b) => (b['_pay_percent'] as double).compareTo(a['_pay_percent'] as double));
    reportResult['best_payers'] = scored.take(topN).toList();
  }

  // ── Compute-методы (derived sections) ──

  void computePaymentTrend() {
    final periods = (reportResult['monthly_dynamics'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (periods.length < 2) {
      reportResult['payment_trend'] = <Map<String, dynamic>>[];
      return;
    }
    final trends = <Map<String, dynamic>>[];
    for (var i = 1; i < periods.length; i++) {
      final prev = periods[i];
      final curr = periods[i - 1];
      final prevCharged = (prev['total_charged'] as num?)?.toDouble() ?? 0;
      final currCharged = (curr['total_charged'] as num?)?.toDouble() ?? 0;
      final prevPaid = (prev['total_paid'] as num?)?.toDouble() ?? 0;
      final currPaid = (curr['total_paid'] as num?)?.toDouble() ?? 0;
      final prevColl = prevCharged > 0 ? prevPaid / prevCharged * 100 : 0.0;
      final currColl = currCharged > 0 ? currPaid / currCharged * 100 : 0.0;
      final delta = currColl - prevColl;
      trends.add({
        'period': curr['period'] ?? '',
        'period_label': curr['period_label'] ?? formatPeriod(curr['period']?.toString()),
        'collection': currColl,
        'prev_collection': prevColl,
        'delta': delta,
        'charged_change': prevCharged > 0 ? (currCharged - prevCharged) / prevCharged * 100 : 0.0,
        'paid_change': prevPaid > 0 ? (currPaid - prevPaid) / prevPaid * 100 : 0.0,
      });
    }
    reportResult['payment_trend'] = trends;
  }

  void computeRecalcAnalysis() {
    final services = (reportResult['by_services'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final analysis = services.where((s) {
      final recalc = (s['recalc'] as num?)?.toDouble() ?? 0;
      return recalc != 0;
    }).map((s) {
      final charged = (s['charged'] as num?)?.toDouble() ?? 0;
      final recalc = (s['recalc'] as num?)?.toDouble() ?? 0;
      final ratio = charged > 0 ? (recalc.abs() / charged * 100) : 0.0;
      return {
        ...s,
        'recalc_ratio': ratio,
        'is_anomaly': ratio > 10,
      };
    }).toList();
    analysis.sort((a, b) => ((b['recalc'] as num?)?.toDouble() ?? 0).abs().compareTo(((a['recalc'] as num?)?.toDouble() ?? 0).abs()));
    reportResult['recalc_analysis'] = analysis;
  }

  void computeDebtAging() {
    final items = (reportResult['top_debtors'] as List?) ?? [];
    final groups = <Map<String, dynamic>>[
      {'label': '0 — 1 000₽', 'min': 0.0, 'max': 1000.0, 'count': 0, 'total': 0.0},
      {'label': '1 000 — 5 000₽', 'min': 1000.0, 'max': 5000.0, 'count': 0, 'total': 0.0},
      {'label': '5 000 — 10 000₽', 'min': 5000.0, 'max': 10000.0, 'count': 0, 'total': 0.0},
      {'label': '10 000 — 50 000₽', 'min': 10000.0, 'max': 50000.0, 'count': 0, 'total': 0.0},
      {'label': '50 000+₽', 'min': 50000.0, 'max': double.infinity, 'count': 0, 'total': 0.0},
    ];
    for (final item in items) {
      final debt = ((item as Map<String, dynamic>)['total_debt_end'] as num?)?.toDouble() ?? 0;
      if (debt <= 0) continue;
      for (final g in groups) {
        if (debt > (g['min'] as double) && debt <= (g['max'] as double)) {
          g['count'] = (g['count'] as int) + 1;
          g['total'] = (g['total'] as double) + debt;
          break;
        }
      }
    }
    reportResult['debt_aging'] = groups;
  }

  void computeLocationComparison() {
    final houses = (reportResult['top_houses'] as List?) ?? [];
    final comparison = houses.map((h) {
      final m = h as Map<String, dynamic>;
      final count = (m['count'] as num?)?.toInt() ?? 1;
      final charged = (m['total_charged'] as num?)?.toDouble() ?? 0;
      final paid = (m['total_paid'] as num?)?.toDouble() ?? 0;
      final debt = (m['total_debt'] as num?)?.toDouble() ?? 0;
      final debtors = (m['debtors_count'] as num?)?.toInt() ?? 0;
      return {
        'name': m['name'] ?? '',
        'count': count,
        'collection': charged > 0 ? (paid / charged * 100).clamp(0.0, 100.0) : 0.0,
        'avg_debt': count > 0 ? debt / count : 0.0,
        'debtors_pct': count > 0 ? debtors / count * 100 : 0.0,
        'total_debt': debt,
      };
    }).toList();
    reportResult['location_comparison'] = comparison;
  }

  /// Dispatch: вызывает нужный fetch/compute по ключу секции.

  // ═══════════════════════════════════════════════════════════════════
  // Касса и платежи: серверная агрегация
  // ═══════════════════════════════════════════════════════════════════

  /// Даты для кассовых отчётов.
  ///
  /// Период конструктора задан периодами НАЧИСЛЕНИЙ (ММ.ГГГГ), а касса
  /// фильтруется по дате платежа. Берём первое число начального периода
  /// и последний день конечного — иначе платежи последнего месяца
  /// отсекались бы.
  Map<String, dynamic> get cashierDateParams {
    final from = periodFrom;
    final to = periodTo;
    return {
      'date_from': ?from,
      'date_to': ?(to == null ? null : _lastDayOf(to)),
    };
  }

  String _lastDayOf(String isoDate) {
    final d = DateTime.tryParse(isoDate);
    if (d == null) return isoDate;
    final last = DateTime(d.year, d.month + 1, 0);
    return '${last.year.toString().padLeft(4, '0')}-'
        '${last.month.toString().padLeft(2, '0')}-'
        '${last.day.toString().padLeft(2, '0')}';
  }

  Future<void> fetchCashierShift(Dio dio) async {
    // Смена — это один день. Берём конец периода: обычно отчёт смотрят
    // за последний день выбранного диапазона.
    final to = periodTo;
    final resp = await dio.get(
      '/payment-documents/reports/cashier-shift',
      queryParameters: {if (to != null) 'shift_date': _lastDayOf(to)},
    );
    reportResult['cashier_shift'] = resp.data;
  }

  Future<void> fetchPaymentsRegister(Dio dio) async {
    final resp = await dio.get(
      '/payment-documents/reports/payments-register',
      queryParameters: {
        ...cashierDateParams,
        'location_id': ?selectedLocationId,
        'limit': 1000,
      },
    );
    reportResult['payments_register'] = resp.data;
  }

  Future<void> fetchCashierPerformance(Dio dio) async {
    final resp = await dio.get(
      '/payment-documents/reports/cashier-performance',
      queryParameters: cashierDateParams,
    );
    reportResult['cashier_performance'] = resp.data;
  }

  Future<void> fetchPaymentStructure(Dio dio) async {
    final resp = await dio.get(
      '/payment-documents/reports/payment-structure',
      queryParameters: cashierDateParams,
    );
    reportResult['payment_structure'] = resp.data;
  }

  /// Распределение долгов ПО ВСЕЙ БАЗЕ.
  ///
  /// Раньше считалось на клиенте из топ-N должников, и в отчёте стояли
  /// суммы пятидесяти человек вместо итога по организации.
  Future<void> fetchDebtDistribution(Dio dio) async {
    final resp = await dio.get(
      '/payment-documents/reports/debt-distribution',
      queryParameters: {
        'period_date': ?periodTo,
        'location_id': ?selectedLocationId,
      },
    );
    reportResult['debt_distribution'] = resp.data;
  }

  Future<void> fetchCollectionSummary(Dio dio) async {
    final resp = await dio.get(
      '/payment-documents/reports/collection-summary',
      queryParameters: periodRangeParams,
    );
    reportResult['collection_summary'] = resp.data;
  }

  Future<void> fetchSection(Dio dio, String section) async {
    switch (section) {
      case 'summary':
        await fetchSummary(dio);
        break;
      case 'top_houses':
        await fetchTopHouses(dio);
        break;
      case 'top_debtors':
        await fetchTopDebtors(dio);
        break;
      case 'last_payments':
        await fetchLastPayments(dio);
        break;
      case 'monthly_dynamics':
        await fetchMonthlyDynamics(dio);
        break;
      case 'by_services':
        await fetchByServices(dio);
        break;
      case 'overpayments':
        await fetchOverpayments(dio);
        break;
      case 'best_payers':
        await fetchBestPayers(dio);
        break;
      case 'payment_trend':
        if (!reportResult.containsKey('monthly_dynamics')) {
          await fetchMonthlyDynamics(dio);
        }
        computePaymentTrend();
        break;
      case 'recalc_analysis':
        if (!reportResult.containsKey('by_services')) {
          await fetchByServices(dio);
        }
        computeRecalcAnalysis();
        break;
      case 'debt_aging':
        if (!reportResult.containsKey('top_debtors')) {
          await fetchTopDebtors(dio);
        }
        computeDebtAging();
        break;
      case 'location_comparison':
        if (!reportResult.containsKey('top_houses')) {
          await fetchTopHouses(dio);
        }
        computeLocationComparison();
        break;
      case 'cashier_shift':
        await fetchCashierShift(dio);
        break;
      case 'payments_register':
        await fetchPaymentsRegister(dio);
        break;
      case 'cashier_performance':
        await fetchCashierPerformance(dio);
        break;
      case 'payment_structure':
        await fetchPaymentStructure(dio);
        break;
      case 'debt_distribution':
        await fetchDebtDistribution(dio);
        break;
      case 'collection_summary':
        await fetchCollectionSummary(dio);
        break;
    }
  }
}
