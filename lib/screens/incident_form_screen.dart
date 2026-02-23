import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incident_models.dart';
import '../providers/incident_form_controller.dart';
import '../providers/map_providers.dart';
import '../utils/app_theme.dart';
import '../widgets/base_card.dart';

class IncidentFormScreen extends ConsumerStatefulWidget {
  final IncidentResponse? initialIncident;

  const IncidentFormScreen({super.key, this.initialIncident});

  @override
  ConsumerState<IncidentFormScreen> createState() => _IncidentFormScreenState();
}

class _IncidentFormScreenState extends ConsumerState<IncidentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incidentFormControllerProvider(widget.initialIncident));
    final controller = ref.read(incidentFormControllerProvider(widget.initialIncident).notifier);
    final mapData = ref.watch(mapDataProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.initialIncident == null ? 'НОВЫЙ ИНЦИДЕНТ' : 'РЕДАКТИРОВАНИЕ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (state.isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final success = await controller.save();
                  if (success && mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('СОХРАНИТЬ', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              
              _buildSection(
                title: 'ОСНОВНАЯ ИНФОРМАЦИЯ',
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: state.title,
                      decoration: _inputDecoration('Название / Тип инцидента'),
                      style: const TextStyle(color: Colors.white),
                      onChanged: controller.updateTitle,
                      validator: (v) => v == null || v.isEmpty ? 'Обязательное поле' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: state.boilerHouseId,
                      dropdownColor: AppTheme.secondaryDarkBackground,
                      decoration: _inputDecoration('Котельная'),
                      items: mapData.boilerHouses.map((bh) {
                        return DropdownMenuItem(
                          value: bh.id,
                          child: Text(bh.address, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: controller.updateBoilerHouse,
                      validator: (v) => v == null ? 'Выберите котельную' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<IncidentStatus>(
                            value: state.status,
                            dropdownColor: AppTheme.secondaryDarkBackground,
                            decoration: _inputDecoration('Статус'),
                            items: IncidentStatus.values.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(s.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) controller.updateStatus(v);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: state.severity,
                            dropdownColor: AppTheme.secondaryDarkBackground,
                            decoration: _inputDecoration('Серьезность'),
                            items: ['1', '2', '3'].map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) controller.updateSeverity(v);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildSection(
                title: 'ЗАТРОНУТЫЕ РЕСУРСЫ И ДОМА',
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Остановить ГВС', style: TextStyle(color: Colors.white)),
                      value: state.stopHotWater,
                      onChanged: controller.updateStopHotWater,
                      activeColor: Colors.blue,
                    ),
                    SwitchListTile(
                      title: const Text('Остановить отопление', style: TextStyle(color: Colors.white)),
                      value: state.stopHeating,
                      onChanged: controller.updateStopHeating,
                      activeColor: Colors.red,
                    ),
                    const Divider(color: Colors.white10),
                    ListTile(
                      title: const Text('Выбрать дома', style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                        'Выбрано: ${state.affectedHouseIds.length}',
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                      onTap: () => _showHouseSelector(context, ref, state, controller),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildSection(
                title: 'ОПИСАНИЕ',
                child: TextFormField(
                  initialValue: state.description,
                  maxLines: 5,
                  decoration: _inputDecoration('Детали инцидента'),
                  style: const TextStyle(color: Colors.white),
                  onChanged: controller.updateDescription,
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        BaseCard(child: child),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  void _showHouseSelector(
    BuildContext context,
    WidgetRef ref,
    IncidentFormState state,
    IncidentFormController controller,
  ) {
    if (state.boilerHouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала выберите котельную')),
      );
      return;
    }

    final mapData = ref.read(mapDataProvider);
    // Filter locations by boiler house ID if available in data
    final relevantHouses = mapData.locations.where((loc) => loc.boilerHouseId == state.boilerHouseId).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryDarkBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'ВЫБОР ДОМОВ',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: relevantHouses.length,
                        itemBuilder: (context, index) {
                          final house = relevantHouses[index];
                          final isSelected = state.affectedHouseIds.contains(house.id);
                          return CheckboxListTile(
                            title: Text(house.name, style: const TextStyle(color: Colors.white)),
                            value: isSelected,
                            onChanged: (v) {
                              controller.toggleHouse(house.id);
                              setModalState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
