import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'base_card.dart';

class IncidentCard extends StatefulWidget {
  final String title;
  final String location;
  final String timestamp;
  final String statusText;
  final bool isStatusActive;
  final Color? statusColor;  // Optional override for badge/accent color
  final String? assigneeName;
  final String? stoppedServicesText;
  final int affectedPopulationCount;
  final String? boilerHouseDetail;
  final String? broadcastText;
  final bool isUnsynced;
  final bool isOverdue; // finishedAt прошла, но инцидент ещё активен
  final VoidCallback? onTap;

  const IncidentCard({
    super.key,
    required this.title,
    required this.location,
    required this.timestamp,
    required this.statusText,
    required this.isStatusActive,
    this.statusColor,
    this.assigneeName,
    this.stoppedServicesText,
    required this.affectedPopulationCount,
    this.boilerHouseDetail,
    this.broadcastText,
    this.isUnsynced = false,
    this.isOverdue = false,
    this.onTap,
  });

  @override
  State<IncidentCard> createState() => _IncidentCardState();
}

class _IncidentCardState extends State<IncidentCard> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Shake animation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  Timer? _shakeTimer;

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
    
    if (widget.isOverdue) {
      _pulseController.repeat(reverse: true);
      _startShakeLoop();
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
  }

  @override
  void dispose() {
    _shakeTimer?.cancel();
    _shakeController.dispose();
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
                color: widget.statusColor ?? (widget.isStatusActive ? AppTheme.errorRed : AppTheme.successGreen),
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
                          Flexible(
                            child: Text(
                              widget.timestamp,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(180), fontSize: 12, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.boilerHouseDetail ?? widget.location,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                                            Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
                      _buildActionRow(
                        context,
                        icon: Icons.account_circle,
                        text: widget.assigneeName ?? 'Не назначен',
                        rightText: 'Assigned',
                      ),
                      if (widget.broadcastText != null) ...[
                                              Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
                        _buildActionRow(
                          context,
                          icon: Icons.campaign,
                          text: widget.broadcastText!,
                        ),
                      ],
                      if (widget.stoppedServicesText != null) ...[
                                              Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
                        _buildActionRow(
                          context,
                          icon: Icons.warning_rounded,
                          iconColor: AppTheme.warningOrange,
                          text: 'Остановлено: ${widget.stoppedServicesText}',
                        ),
                      ],
                      if (widget.affectedPopulationCount > 0) ...[
                                              Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
                        _buildActionRow(
                          context,
                          icon: Icons.people,
                          text: 'Без услуг: ${widget.affectedPopulationCount} чел.',
                        ),
                      ],
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

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: widget.statusColor ?? (widget.isStatusActive ? AppTheme.errorRed : AppTheme.successGreen),
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
