import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/incident_models.dart';
import '../models/location_models.dart';
import '../models/user_role.dart';
import '../providers/incident_form_controller.dart';
import '../services/user_service.dart';
import '../utils/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class HouseIncidentFormDialog extends ConsumerStatefulWidget {
  final SavedLocationResponse house;

  const HouseIncidentFormDialog({super.key, required this.house});

  @override
  ConsumerState<HouseIncidentFormDialog> createState() => _HouseIncidentFormDialogState();
}

class _HouseIncidentFormDialogState extends ConsumerState<HouseIncidentFormDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(incidentFormControllerProvider(null).notifier);
      if (widget.house.boilerHouseId != null) {
        controller.updateTitle('Инцидент по дому: ${widget.house.name}');
        controller.updateBoilerHouse(widget.house.boilerHouseId!);
        controller.toggleHouse(widget.house.id);
        controller.updateStopHeating(true);
        controller.updateStopHotWater(true);
      } else {
        // This will immediately fail validation if they try to save without selecting one
        controller.setError('Этот дом не привязан к котельной. Выберите котельную на основном экране инцидентов.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incidentFormControllerProvider(null));
    final controller = ref.read(incidentFormControllerProvider(null).notifier);
    final usersAsync = ref.watch(usersProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 500, // Matching other dialog widths
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Новый инцидент',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  state.isSaving
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : TextButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final success = await controller.save();
                              if (success && mounted) {
                                Navigator.pop(context, true);
                              }
                            }
                          },
                          child: const Text('Сохранить', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.errorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.errorRed.withOpacity(0.1),
                            border: Border.all(color: AppTheme.errorRed),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppTheme.errorRed),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage!, 
                                  style: const TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold)
                                ),
                              ),
                            ],
                          ),
                        ),
                      _buildSectionTitle('Основная информация'),
                      _buildContainer(
                        child: Column(
                          children: [
                            _buildRow(
                              'Тип',
                              state.title.isEmpty ? 'Инцидент' : state.title,
                              icon: Icons.list,
                              trailing: const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
                              onTap: () => _showTypeSelector(context, state, controller),
                            ),
                            _buildDivider(),
                            _buildDropdownRow<IncidentStatus>(
                              'Статус',
                              state.status,
                              IncidentStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name, style: const TextStyle(color: AppTheme.errorRed)))).toList(),
                              (v) { if (v != null) controller.updateStatus(v); },
                              icon: Icons.flag,
                            ),
                            _buildDivider(),
                            _buildDropdownRow<String>(
                              'Серьёзность',
                              state.severity,
                              ['1', '2', '3'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(color: Color(0xFFFFA726))))).toList(),
                              (v) { if (v != null) controller.updateSeverity(v); },
                              icon: Icons.warning_amber_rounded,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      _buildSectionTitle('Сроки'),
                      _buildContainer(
                        child: Column(
                          children: [
                            _buildRow(
                              'Начало', 
                              DateFormat('dd.MM.yyyy HH:mm').format(state.createdAt),
                              icon: Icons.calendar_today,
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
                            _buildDivider(),
                            _buildRow(
                              'Окончание', 
                              state.resolvedAt != null ? DateFormat('dd.MM.yyyy HH:mm').format(state.resolvedAt!) : '—',
                              icon: Icons.event_available,
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
                              }
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      _buildSectionTitle('Затронутые ресурсы и дома'),
                      _buildContainer(
                        child: Column(
                          children: [
                            _buildToggleRow('Остановить ГВС', Icons.water_drop, Colors.blue, state.stopHotWater, controller.updateStopHotWater),
                            _buildDivider(),
                            _buildToggleRow('Остановить отопление', Icons.local_fire_department, Colors.red, state.stopHeating, controller.updateStopHeating),
                            _buildDivider(),
                            _buildRow('Затронутые дома', 'выбрано: ${state.affectedHouseIds.length}', icon: Icons.business),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      _buildSectionTitle('Назначение и уведомления'),
                      _buildContainer(
                        child: Column(
                          children: [
                            usersAsync.when(
                              data: (users) {
                                final assignedUserName = users.where((u) => u.id == state.assignedTo).map((u) => u.formattedDisplayName.split(' • ').first).firstOrNull ?? 'Не назначен';
                                return _buildDropdownRow<int?>(
                                  'Исполнитель',
                                  state.assignedTo,
                                  [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('Не назначен', style: TextStyle(color: Colors.white70)),
                                    ),
                                    ...users.map((u) {
                                      final label = u.formattedDisplayName.split(' • ').first;
                                      return DropdownMenuItem<int?>(
                                        value: u.id,
                                        child: Text(label, style: const TextStyle(color: Colors.white)),
                                      );
                                    }),
                                  ],
                                  (v) => controller.updateAssignedTo(v),
                                  icon: Icons.person_outline,
                                );
                              },
                              loading: () => const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              error: (e, st) => Text('Ошибка: $e', style: const TextStyle(color: Colors.red)),
                            ),
                            _buildDivider(),
                            _buildDropdownRow<AudienceType>(
                              'Уведомить (Пуш)',
                              state.notificationConfig?.type ?? AudienceType.broadcast,
                              const [
                                DropdownMenuItem(value: AudienceType.broadcast, child: Text('Всем пользователям', style: TextStyle(color: Colors.white))),
                                DropdownMenuItem(value: AudienceType.roleBased, child: Text('По ролям', style: TextStyle(color: Colors.white))),
                                DropdownMenuItem(value: AudienceType.userBased, child: Text('По пользователям', style: TextStyle(color: Colors.white))),
                              ],
                              (v) {
                                if (v != null) {
                                  controller.updateNotificationConfig(NotificationConfig(type: v, userIds: state.notificationConfig?.userIds));
                                }
                              },
                              icon: Icons.notifications_none,
                            ),
                            if (state.notificationConfig?.type == AudienceType.userBased) ...[
                              _buildDivider(),
                              _buildRow(
                                'Выбрать получателей',
                                'выбрано: ${state.notificationConfig?.userIds?.length ?? 0}',
                                icon: Icons.group_add,
                                trailing: const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
                                onTap: () => _showUserSelector(context, ref, state, controller),
                              ),
                            ],
                            if (state.notificationConfig?.type == AudienceType.roleBased) ...[
                              _buildDivider(),
                              _buildRow(
                                'Выбрать роли',
                                'выбрано: ${state.notificationConfig?.roleIds?.length ?? 0}',
                                icon: Icons.admin_panel_settings,
                                trailing: const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
                                onTap: () => _showRoleSelector(context, ref, state, controller),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      _buildSectionTitle('Сведения'),
                      _buildContainer(
                        padding: EdgeInsets.zero,
                        child: TextFormField(
                          initialValue: state.description,
                          maxLines: 4,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Описание инцидента...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          onChanged: controller.updateDescription,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContainer({required Widget child, EdgeInsets padding = const EdgeInsets.all(0)}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 48, endIndent: 16);
  }

  Widget _buildRow(String title, String value, {required IconData icon, Widget? trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
            const Spacer(),
            Text(value, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15)),
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(String title, IconData icon, Color iconColor, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow<T>(
    String title, 
    T value, 
    List<DropdownMenuItem<T>> items, 
    ValueChanged<T?> onChanged, 
    {required IconData icon}
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              dropdownColor: const Color(0xFF2C2C2E),
              icon: const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  void _showTypeSelector(BuildContext context, IncidentFormState state, IncidentFormController controller) {
    final List<String> incidentTypes = [
      'Авария котла',
      'Ремонт труб',
      'Плановые работы',
      'Отключение электричества',
      'Отключение газоснабжения',
      'Иное',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Тип', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: incidentTypes.length,
                  itemBuilder: (context, index) {
                    final type = incidentTypes[index];
                    final isSelected = state.title == type || (state.title.isEmpty && type == 'Иное');
                    return ListTile(
                      title: Text(
                        type,
                        style: TextStyle(color: isSelected ? AppTheme.primaryBlue : Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        controller.updateTitle(type);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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
            final modalState = modalRef.watch(incidentFormControllerProvider(null));
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
                            title: Text(user.formattedDisplayName.split(' • ').first, style: const TextStyle(color: Colors.white)),
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

  void _showRoleSelector(
    BuildContext context,
    WidgetRef ref,
    IncidentFormState state,
    IncidentFormController controller,
  ) {
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
            final modalState = modalRef.watch(incidentFormControllerProvider(null));
            final selectedRoles = Set<String>.from(modalState.notificationConfig?.roleIds ?? []);

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
                            'ВЫБОР РОЛЕЙ',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              final allRoles = UserRole.values.map((r) => r.name).toList();
                              final allIncluded = allRoles.every((r) => selectedRoles.contains(r));
                              if (allIncluded) {
                                controller.updateNotificationRoles([]);
                              } else {
                                controller.updateNotificationRoles(allRoles);
                              }
                            },
                            child: const Text('Выбрать все', style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: UserRole.values.length,
                        itemBuilder: (context, index) {
                          final role = UserRole.values[index];
                          final isSelected = selectedRoles.contains(role.name);
                          return CheckboxListTile(
                            title: Text(role.title, style: const TextStyle(color: Colors.white)),
                            value: isSelected,
                            onChanged: (v) {
                              if (v == true) {
                                selectedRoles.add(role.name);
                              } else {
                                selectedRoles.remove(role.name);
                              }
                              controller.updateNotificationRoles(selectedRoles.toList());
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
