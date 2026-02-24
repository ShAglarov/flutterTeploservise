import 'package:flutter/material.dart';
import '../../models/incident_models.dart';
import '../base_card.dart';

class BoilerHouseInfoCard extends StatelessWidget {
  final BoilerHouseSummary? boilerHouse;

  const BoilerHouseInfoCard({super.key, this.boilerHouse});

  @override
  Widget build(BuildContext context) {
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
                color: Colors.orange,
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
                const Text(
                  'Информация о котельной',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Котельная', boilerHouse?.address ?? '—'),
                Divider(color: Colors.white.withOpacity(0.1)),
                _buildInfoRow('Номер участка', boilerHouse?.siteNumber ?? '—'),
                Divider(color: Colors.white.withOpacity(0.1)),
                _buildInfoRow('Начальник участка', boilerHouse?.siteManager ?? '—'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
