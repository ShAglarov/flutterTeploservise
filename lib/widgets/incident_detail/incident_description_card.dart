import 'package:flutter/material.dart';
import '../base_card.dart';

class IncidentDescriptionCard extends StatelessWidget {
  final String? description;

  const IncidentDescriptionCard({super.key, this.description});

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
                color: Colors.purple,
              ),
              const SizedBox(width: 8),
              const Text(
                'ОПИСАНИЕ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description != null && description!.isNotEmpty ? description! : 'Нет описания',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
