import 'package:flutter/material.dart';
import '../../models/incident_models.dart';
import '../base_card.dart';

class BoilerHouseInfoCard extends StatelessWidget {
  final BoilerHouseSummary? boilerHouse;

  const BoilerHouseInfoCard({super.key, this.boilerHouse});

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              const Text(
                'ИНФОРМАЦИЯ О КОТЕЛЬНОЙ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Котельная', boilerHouse?.address ?? '—'),
          const Divider(color: Colors.white10),
          _buildInfoRow('Номер участка', boilerHouse?.siteNumber ?? '—'),
          const Divider(color: Colors.white10),
          _buildInfoRow('Начальник участка', boilerHouse?.siteManager ?? '—'),
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
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
