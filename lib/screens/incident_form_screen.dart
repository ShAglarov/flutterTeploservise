import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/incident_models.dart';
import '../providers/incident_form_controller.dart';
import '../providers/map_providers.dart';
import '../utils/app_theme.dart';
import '../widgets/base_card.dart';
import '../services/user_service.dart';
import '../models/api_models.dart';
import 'package:intl/intl.dart';

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
    final usersAsync = ref.watch(usersProvider);

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
                title: 'ОТВЕТСТВЕННЫЙ И СПЕРИОД',
                child: Column(
                  children: [
                    usersAsync.when(
                      data: (users) {
                        return DropdownButtonFormField<int>(
                          value: state.assignedTo,
                          dropdownColor: AppTheme.secondaryDarkBackground,
                          decoration: _inputDecoration('Ответственный'),
                          items: [
                            const DropdownMenuItem<int>(
                              value: null,
                              child: Text('Не назначен', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            ),
                            ...users.map((u) {
                              return DropdownMenuItem<int>(
                                value: u.id,
                                child: Text(u.fullName ?? u.username, style: const TextStyle(color: Colors.white, fontSize: 14)),
                              );
                            }),
                          ],
                          onChanged: controller.updateAssignedTo,
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => Text('Ошибка загрузки пользователей: $err', style: const TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      tileColor: Colors.white.withOpacity(0.05),
                      title: const Text('Время создания', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(state.createdAt), style: const TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: state.createdAt,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null && mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(state.createdAt),
                          );
                          if (time != null) {
                            controller.updateCreatedAt(DateTime(date.year, date.month, date.day, time.hour, time.minute));
                          }
                        }
                      },
                    ),
                    if (state.status == IncidentStatus.resolved || state.status == IncidentStatus.closed) ...[
                      const SizedBox(height: 16),
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        tileColor: Colors.white.withOpacity(0.05),
                        title: const Text('Время решения', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        subtitle: Text(
                          state.resolvedAt != null ? DateFormat('dd.MM.yyyy HH:mm').format(state.resolvedAt!) : 'Не указано',
                          style: const TextStyle(color: Colors.white)
                        ),
                        trailing: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                        onTap: () async {
                          final initialDate = state.resolvedAt ?? DateTime.now();
                          final date = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null && mounted) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(initialDate),
                            );
                            if (time != null) {
                              controller.updateResolvedAt(DateTime(date.year, date.month, date.day, time.hour, time.minute));
                            }
                          }
                        },
                      ),
                    ],
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
                title: 'УВЕДОМЛЕНИЯ ПРИ ПУБЛИКАЦИИ',
                child: Column(
                  children: [
                    DropdownButtonFormField<AudienceType>(
                      value: state.notificationConfig?.type ?? AudienceType.broadcast,
                      dropdownColor: AppTheme.secondaryDarkBackground,
                      decoration: _inputDecoration('Кому отправить уведомление'),
                      items: const [
                        DropdownMenuItem(
                          value: AudienceType.broadcast,
                          child: Text('Всем пользователям', style: TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                        DropdownMenuItem(
                          value: AudienceType.roleBased,
                          child: Text('По ролям (в разработке)', style: TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                        DropdownMenuItem(
                          value: AudienceType.userBased,
                          child: Text('Выбранным пользователям', style: TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          controller.updateNotificationConfig(
                            NotificationConfig(type: v, userIds: state.notificationConfig?.userIds),
                          );
                        }
                      },
                    ),
                    if (state.notificationConfig?.type == AudienceType.userBased) ...[
                      const SizedBox(height: 16),
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        tileColor: Colors.white.withOpacity(0.05),
                        title: const Text('Выбрать получателей', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          'Выбрано: ${state.notificationConfig?.userIds?.length ?? 0}',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                        onTap: () => _showUserSelector(context, ref, state, controller),
                      ),
                    ],
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
        return Consumer(
          builder: (context, modalRef, child) {
            final modalState = modalRef.watch(incidentFormControllerProvider(widget.initialIncident));
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ВЫБОР ДОМОВ',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              final allIds = relevantHouses.map((h) => h.id).toList();
                              controller.toggleAllHouses(allIds);
                            },
                            child: const Text('Выбрать все', style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: relevantHouses.length,
                        itemBuilder: (context, index) {
                          final house = relevantHouses[index];
                          final isSelected = modalState.affectedHouseIds.contains(house.id);
                          return CheckboxListTile(
                            title: Text(house.name, style: const TextStyle(color: Colors.white)),
                            value: isSelected,
                            onChanged: (v) {
                              controller.toggleHouse(house.id);
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

  void _showUserSelector(
    BuildContext context,
    WidgetRef ref,
    IncidentFormState state,
    IncidentFormController controller,
  ) {
    final usersAsync = ref.read(usersProvider);
    final users = usersAsync.value ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryDarkBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, modalRef, child) {
            final modalState = modalRef.watch(incidentFormControllerProvider(widget.initialIncident));
            final selectedUserIds = Set<int>.from(modalState.notificationConfig?.userIds ?? []);

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ВЫБОР ПОЛЬЗОВАТЕЛЕЙ',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              final allIds = users.map((u) => u.id).toList();
                              final allIncluded = allIds.every((id) => selectedUserIds.contains(id));
                              if (allIncluded) {
                                controller.updateNotificationConfig(NotificationConfig(type: AudienceType.userBased, userIds: []));
                              } else {
                                controller.updateNotificationConfig(NotificationConfig(type: AudienceType.userBased, userIds: allIds));
                              }
                            },
                            child: const Text('Выбрать всех', style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final isSelected = selectedUserIds.contains(user.id);
                          return CheckboxListTile(
                            title: Text(user.fullName ?? user.username, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(user.role.name, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            value: isSelected,
                            onChanged: (v) {
                              if (v == true) {
                                selectedUserIds.add(user.id);
                              } else {
                                selectedUserIds.remove(user.id);
                              }
                              controller.updateNotificationConfig(
                                NotificationConfig(type: AudienceType.userBased, userIds: selectedUserIds.toList()),
                              );
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
