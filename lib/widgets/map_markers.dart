import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class BoilerHouseMarkerWidget extends StatelessWidget {
  final bool hasIncident;
  final bool isDisabled;

  const BoilerHouseMarkerWidget({
    super.key,
    required this.hasIncident,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color pinColor = isDisabled
        ? Colors.grey
        : hasIncident
            ? AppTheme.errorRed
            : const Color(0xFF33B2CC); // Turquoise from iOS

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Circle (Border)
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        // Main Circle
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: pinColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: const Center(
            child: Icon(
              Icons.local_fire_department, // flame.fill equivalent
              color: Colors.orange,
              size: 20,
            ),
          ),
        ),
        // Incident Badge
        if (hasIncident)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

class LocationMarkerWidget extends StatelessWidget {
  const LocationMarkerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Circle
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        // Inner Circle
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.successGreen,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: const Center(
            child: Icon(
              Icons.home_filled,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}
