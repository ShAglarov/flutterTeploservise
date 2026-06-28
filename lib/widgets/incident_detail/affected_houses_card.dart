import 'package:flutter/material.dart';
import '../../models/incident_models.dart';
import '../base_card.dart';

class AffectedHousesCard extends StatelessWidget {
  final List<int>? houseIds;
  final List<AffectedHouseDetail>? houseDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onShowAll;

  const AffectedHousesCard({
    super.key,
    this.houseIds,
    this.houseDetails,
    this.onEdit,
    this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    final count = houseIds?.length ?? 0;

    return BaseCard(
      child: Stack(
        children: [
          // Left accent line
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 3,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Затронутые дома',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (onEdit != null)
                      TextButton(
                        onPressed: onEdit,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
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
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                      ),
                    ),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                if (count > 0) ...[
                  const SizedBox(height: 12),
                  Divider(color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
                  const SizedBox(height: 12),
                  Text(
                    'Дома:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (houseDetails != null && houseDetails!.isNotEmpty)
                    ...houseDetails!.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '• ${d.savedLocation?.name ?? "ID: ${d.savedLocationId}"}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ))
                  else
                    ...houseIds!.map((id) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '• Дом ID $id',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        )),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onShowAll,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withAlpha(50)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Показать все дома',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
