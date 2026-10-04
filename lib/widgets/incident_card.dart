import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class IncidentCard extends StatefulWidget {
  final String title;
  final String location;
  final String timestamp;
  final String statusText;
  final bool isStatusActive;
  final Color? statusColor;  // Optional override for badge/accent color
  /// colorStatus от сервера: "normal" | "partial" | "full"
  /// Используется для цвета левой полоски и бейджа: partial=оранжевый, full=красный
  final String? colorStatus;
  final String? assigneeName;
  final String? stoppedServicesText;
  final int affectedPopulationCount;
  final String? boilerHouseDetail;
  final String? broadcastText;
  final String? boilersInfoText; // fallback текст
  final List<int> inactiveBoilerNumbers;
  final int totalBoilersCount;
  final bool supplyFullyStopped;
  final bool isUnsynced;
  final bool isOverdue;
  final int unreadChatCount;
  final int incidentId;
  final String? affectedHousesText;
  /// Какие поля показывать — ключи из `kIncidentCardFields`.
  /// Отсутствующий ключ = показывать: скрыто только то, что пользователь
  /// скрыл осознанно.
  final Map<String, bool> fieldVisibility;
  final VoidCallback? onTap;

  const IncidentCard({
    super.key,
    required this.title,
    required this.location,
    required this.timestamp,
    required this.statusText,
    required this.isStatusActive,
    this.statusColor,
    this.colorStatus,
    this.assigneeName,
    this.stoppedServicesText,
    required this.affectedPopulationCount,
    this.boilerHouseDetail,
    this.broadcastText,
    this.boilersInfoText,
    this.inactiveBoilerNumbers = const [],
    this.totalBoilersCount = 0,
    this.supplyFullyStopped = false,
    this.isUnsynced = false,
    this.isOverdue = false,
    this.unreadChatCount = 0,
    this.incidentId = 0,
    this.affectedHousesText,
    this.fieldVisibility = const {},
    this.onTap,
  });

  @override
  State<IncidentCard> createState() => _IncidentCardState();
}

class _IncidentCardState extends State<IncidentCard> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Shake animation for overdue
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  Timer? _shakeTimer;
  
  // Shake animation for unread chat badge
  late AnimationController _unreadShakeController;
  late Animation<double> _unreadShakeAnimation;
  Timer? _unreadShakeTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Shake: быстрое подёргивание (~360ms)
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 4, end: -3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3, end: 3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 3, end: -1.5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -1.5, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
    
    // Unread shake controller
    _unreadShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _unreadShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -3, end: 3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 3, end: -2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -2, end: 2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 2, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _unreadShakeController, curve: Curves.easeInOut));
    
    if (widget.isOverdue) {
      _pulseController.repeat(reverse: true);
      _startShakeLoop();
    }
    
    if (widget.unreadChatCount > 0) {
      _startUnreadShakeLoop();
    }
  }

  void _startShakeLoop() {
    _shakeController.forward(from: 0);
    _shakeTimer?.cancel();
    _shakeTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted && widget.isOverdue) {
        _shakeController.forward(from: 0);
      }
    });
  }

  void _stopShakeLoop() {
    _shakeTimer?.cancel();
    _shakeTimer = null;
    _shakeController.reset();
  }
  
  void _startUnreadShakeLoop() {
    _unreadShakeController.forward(from: 0);
    _unreadShakeTimer?.cancel();
    _unreadShakeTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && widget.unreadChatCount > 0) {
        _unreadShakeController.forward(from: 0);
      }
    });
  }
  
  void _stopUnreadShakeLoop() {
    _unreadShakeTimer?.cancel();
    _unreadShakeTimer = null;
    _unreadShakeController.reset();
  }

  @override
  void didUpdateWidget(covariant IncidentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOverdue && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
      _startShakeLoop();
    } else if (!widget.isOverdue && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
      _stopShakeLoop();
    }
    
    // Unread shake
    if (widget.unreadChatCount > 0 && oldWidget.unreadChatCount == 0) {
      _startUnreadShakeLoop();
    } else if (widget.unreadChatCount == 0 && oldWidget.unreadChatCount > 0) {
      _stopUnreadShakeLoop();
    }
  }

  @override
  void dispose() {
    _shakeTimer?.cancel();
    _shakeController.dispose();
    _unreadShakeTimer?.cancel();
    _unreadShakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget cardWidget = Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: isDark ? 0 : 2,
      shadowColor: isDark ? Colors.transparent : Colors.black.withAlpha(40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark 
            ? Theme.of(context).colorScheme.onSurface.withAlpha(25) 
            : const Color(0xFFD1D1D6), // iOS separator color
          width: 1,
        ),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: widget.onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: _resolvedAccentColor(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildStatusBadge(),
                                if (widget.isOverdue) ...[
                                  const SizedBox(width: 6),
                                  _buildOverdueBadge(),
                                ],
                                if (widget.isUnsynced) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.cloud_upload_outlined, size: 16, color: AppTheme.warningOrange),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Бейдж непрочитанных сообщений с shake-анимацией
                          if (widget.unreadChatCount > 0) ...[
                            AnimatedBuilder(
                              animation: _unreadShakeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(_unreadShakeAnimation.value, 0),
                                  child: child,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withAlpha(80),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.chat_bubble, size: 10, color: Colors.white),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${widget.unreadChatCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          if (_shows('timestamp'))
                            Flexible(
                              child: Text(
                                widget.timestamp,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(180), fontSize: 12, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.right,
                                maxLines: 2,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (widget.incidentId > 0) ...[
                            Text(
                              '№${widget.incidentId}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_shows('location')) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.boilerHouseDetail ?? widget.location,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (_shows('affectedHouses') && widget.affectedHousesText != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.home_outlined, size: 14, color: Theme.of(context).colorScheme.onSurface.withAlpha(120)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.affectedHousesText!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Нижние секции собираются списком: разделители
                      // вставляются МЕЖДУ видимыми блоками. Раньше каждый
                      // Divider стоял безусловно перед своим блоком, и при
                      // скрытии блока осталась бы двойная линия (а при
                      // скрытии всех — линия в пустоту).
                      ..._buildSections(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Пульсирующий оранжевый glow + подёргивание для просроченных инцидентов
    if (widget.isOverdue) {
      return AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: child,
          );
        },
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withAlpha((80 * _pulseAnimation.value).toInt()),
                    blurRadius: 8 + (4 * _pulseAnimation.value),
                    spreadRadius: 1 * _pulseAnimation.value,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }

  /// Показывать ли поле. Отсутствующий ключ = показывать: карточка с
  /// настройками по умолчанию (и любой вызов без `fieldVisibility`) выглядит
  /// как до появления настроек.
  bool _shows(String key) => widget.fieldVisibility[key] ?? true;

  bool get _hasBoilerInfo =>
      widget.totalBoilersCount > 0 ||
      widget.supplyFullyStopped ||
      widget.inactiveBoilerNumbers.isNotEmpty;

  /// Видимые нижние секции карточки, разделённые линиями.
  List<Widget> _buildSections(BuildContext context) {
    final sections = <Widget>[];

    if (_shows('assignee')) {
      sections.add(_buildActionRow(
        context,
        icon: Icons.account_circle,
        text: widget.assigneeName ?? 'Не назначен',
        rightText: 'Assigned',
      ));
    }
    if (_shows('broadcast') && widget.broadcastText != null) {
      sections.add(_buildActionRow(
        context,
        icon: Icons.campaign,
        text: widget.broadcastText!,
      ));
    }
    if (_shows('stoppedServices') && widget.stoppedServicesText != null) {
      sections.add(_buildActionRow(
        context,
        icon: Icons.warning_rounded,
        iconColor: AppTheme.warningOrange,
        text: 'Остановлено: ${widget.stoppedServicesText}',
      ));
    }
    if (_shows('boilerChips') && _hasBoilerInfo) {
      sections.add(_buildBoilerChipsRow(context));
    }
    if (_shows('population') && widget.affectedPopulationCount > 0) {
      sections.add(_buildActionRow(
        context,
        icon: Icons.people,
        text: 'Без услуг: ${widget.affectedPopulationCount} чел.',
      ));
    }

    if (sections.isEmpty) return const [];

    final divider = Divider(
      height: 1,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(25),
    );

    // Отступ перед первой линией был частью верхнего блока — оставляем его
    // только когда внизу реально что-то есть.
    final out = <Widget>[const SizedBox(height: 16)];
    for (final section in sections) {
      out..add(divider)..add(section);
    }
    return out;
  }

  /// Разрешаем цвет полоски/бейджа — идентично iOS логике окрашивания карточек:
  ///   full    → красный (errorRed)
  ///   partial → оранжевый (warningOrange)
  ///   normal  → зелёный (successGreen) / цвет по статусу
  Color _resolvedAccentColor() {
    if (widget.statusColor != null) return widget.statusColor!;
    if (widget.isStatusActive) {
      return switch (widget.colorStatus) {
        'full'    => AppTheme.errorRed,
        'partial' => AppTheme.warningOrange,
        _         => AppTheme.errorRed, // нет данных → красный (прежнее поведение)
      };
    }
    return AppTheme.successGreen;
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _resolvedAccentColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        widget.statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOverdueBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 10, color: Colors.white),
          SizedBox(width: 3),
          Text(
            'ПРОСРОЧЕН',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Блок состояния котлов. Разделитель сверху НЕ рисует: его вставляет
  /// `_buildSections`, иначе при скрытии соседних блоков линии сдваивались.
  Widget _buildBoilerChipsRow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = widget.totalBoilersCount;
    final inactive = widget.inactiveBoilerNumbers;
    final servicesOk = !widget.supplyFullyStopped;

    String? bannerTitle;
    String? bannerSubtitle;
    Color bannerColor = AppTheme.warningOrange;

    if (widget.supplyFullyStopped) {
      bannerTitle = 'Полная остановка';
      bannerSubtitle = 'Подача полностью прекращена';
      bannerColor = AppTheme.errorRed;
    } else if (inactive.isNotEmpty) {
      bannerTitle = 'Частичная остановка';
      // Было: 'С${inactive.length} из $total котл${_boilerWord(...)} не работает'
      // — лишняя «С» в начале и неверные склонения: «С1 из 3 котла не
      // работает», «С2 из 3 котла не работает». Склонение считалось по
      // числу неработающих, а слово стоит после «из $total», плюс для
      // count==1 суффикс был пустым и получалось «котл».
      bannerSubtitle = _inactiveBoilersPhrase(inactive.length, total);
      bannerColor = AppTheme.warningOrange;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Состояние котлов',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: total > 0
              ? List.generate(total, (i) => _boilerChip(context, i + 1, inactive: widget.supplyFullyStopped || inactive.contains(i + 1)))
              : inactive.map((n) => _boilerChip(context, n, inactive: true)).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              servicesOk ? Icons.check_circle : Icons.cancel,
              size: 20,
              color: servicesOk ? Colors.green.shade400 : AppTheme.errorRed,
            ),
            const SizedBox(width: 10),
            Text(
              servicesOk ? 'Услуги поступают' : 'Услуги прекращены',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: servicesOk ? Theme.of(context).colorScheme.onSurface : AppTheme.errorRed,
              ),
            ),
          ],
        ),
        if (bannerTitle != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? bannerColor.withAlpha(40) : bannerColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.circle, size: 10, color: bannerColor),
                  const SizedBox(width: 8),
                  Text(bannerTitle, style: TextStyle(color: bannerColor, fontSize: 14, fontWeight: FontWeight.w700)),
                ]),
                if (bannerSubtitle != null) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 18),
                    child: Text(bannerSubtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(180), fontSize: 12)),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  /// «1 котёл не работает» / «2 из 3 котлов не работают».
  ///
  /// Слово и глагол согласуются с ЧИСЛОМ НЕРАБОТАЮЩИХ, а после «из N» всегда
  /// идёт родительный падеж множественного числа («из 3 котлов»).
  static String _inactiveBoilersPhrase(int inactive, int total) {
    final verb = _boilerVerb(inactive);
    if (total > 0) {
      return '$inactive из $total котлов $verb';
    }
    return '$inactive ${_boilerNoun(inactive)} $verb';
  }

  /// «котёл» / «котла» / «котлов» — с чередованием ё→о в основе.
  static String _boilerNoun(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod100 >= 11 && mod100 <= 14) return 'котлов';
    if (mod10 == 1) return 'котёл';
    if (mod10 >= 2 && mod10 <= 4) return 'котла';
    return 'котлов';
  }

  /// «не работает» для 1, 21, 101…; «не работают» для остальных.
  static String _boilerVerb(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod100 >= 11 && mod100 <= 14) return 'не работают';
    return mod10 == 1 ? 'не работает' : 'не работают';
  }

  Widget _boilerChip(BuildContext context, int number, {required bool inactive}) {
    final bgColor = inactive ? AppTheme.errorRed.withAlpha(30) : Colors.green.shade900.withAlpha(50);
    final borderColor = inactive ? AppTheme.errorRed.withAlpha(200) : Colors.green.shade700;
    final textColor = inactive ? AppTheme.errorRed : Colors.green.shade400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Text(
        'Котёл $number',
        style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }


  Widget _buildActionRow(
    BuildContext context, {
    required IconData icon,
    required String text,
    String? rightText,
    Color? iconColor,
  }) {
    final defaultIconColor = Theme.of(context).colorScheme.onSurface.withAlpha(140);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor ?? defaultIconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (rightText != null)
            Text(
              rightText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
