import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/incident_providers.dart';
import '../models/incident_models.dart';
import '../services/incident_service.dart';
import '../widgets/incident_detail/incident_header_card.dart';
import '../widgets/incident_detail/boiler_house_info_card.dart';
import '../widgets/incident_detail/affected_houses_card.dart';
import '../widgets/incident_detail/incident_description_card.dart';
import '../widgets/incident_detail/incident_chat_card.dart';
import '../widgets/incident_detail/incident_activity_card.dart';
import '../widgets/incident_detail/incident_photos_card.dart';
import 'incident_form_screen.dart';

class IncidentDetailScreen extends ConsumerWidget {
  final int incidentId;

  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentAsync = ref.watch(singleIncidentProvider(incidentId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('ИНЦИДЕНТ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: incidentAsync.when(
        data: (incident) => RefreshIndicator(
          onRefresh: () async {
            // ref.refresh(singleIncidentProvider(incidentId).future) is not applicable to Stream anymore
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: incident == null ? const Center(child: Text('Инцидент не найден', style: TextStyle(color: Colors.white))) : Column(
              children: [
                IncidentHeaderCard(
                  incident: incident,
                  onStatusToggle: () async {
                    final service = ref.read(incidentServiceProvider);
                    final isClosed = incident.status == IncidentStatus.resolved || incident.status == IncidentStatus.closed;
                    final newStatus = isClosed ? IncidentStatus.open : IncidentStatus.resolved;

                    try {
                      await service.updateIncident(incidentId, IncidentUpdate(id: incidentId, status: newStatus));
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка обновления статуса: $e')));
                      }
                    }
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IncidentFormScreen(initialIncident: incident),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (incident.boilerHouse != null) ...[
                  BoilerHouseInfoCard(boilerHouse: incident.boilerHouse!),
                  const SizedBox(height: 16),
                ],
                if (incident.affectedHouseIds != null) ...[
                  AffectedHousesCard(
                    houseIds: incident.affectedHouseIds!,
                    houseDetails: incident.affectedHouseDetails,
                    onShowAll: () {
                      // TODO: Show list of affected houses
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                if (incident.description != null) ...[
                  IncidentDescriptionCard(description: incident.description!),
                  const SizedBox(height: 16),
                ],
                IncidentChatCard(incidentId: incidentId),
                const SizedBox(height: 16),
                IncidentPhotosCard(
                  incidentId: incidentId,
                  photos: incident.photos ?? [],
                ),
                const SizedBox(height: 16),
                IncidentActivityCard(incidentId: incidentId),
                const SizedBox(height: 32), // Bottom padding
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Ошибка загрузки: $err', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(singleIncidentProvider(incidentId)),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
