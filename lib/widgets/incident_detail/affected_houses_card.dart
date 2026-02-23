import 'package:flutter/material.dart';
import '../base_card.dart';

class AffectedHousesCard extends StatelessWidget {
  final List<int>? houseIds;
  final VoidCallback? onEdit;
  final VoidCallback? onShowAll;

  const AffectedHousesCard({
    super.key,
    this.houseIds,
    this.onEdit,
    this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    final count = houseIds?.length ?? 0;

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ЗАТРОНУТЫЕ ДОМА',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (onEdit != null)
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Изменить', style: TextStyle(color: Colors.blue)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Затронутых домов',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (count > 0) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onShowAll,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ПОКАЗАТЬ ВСЕ ДОМА',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
