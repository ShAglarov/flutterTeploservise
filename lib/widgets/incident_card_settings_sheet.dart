import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/incident_card_settings.dart';
import '../utils/app_theme.dart';

/// Тумблеры «какие поля показывать в карточке инцидента».
///
/// Стиль повторяет [IncidentFilterSheet]: та же ручка, тот же заголовок со
/// «Сбросить», та же кнопка внизу — чтобы два листа с соседних кнопок в
/// AppBar не выглядели из разных приложений.
class IncidentCardSettingsSheet extends ConsumerWidget {
  const IncidentCardSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibility = ref.watch(incidentCardSettingsProvider);
    final notifier = ref.read(incidentCardSettingsProvider.notifier);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(bottom: 32, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: onSurface.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Поля карточки',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: notifier.resetToDefaults,
                  child: const Text('Сбросить',
                      style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Выключенные поля скрываются из карточек в списке. '
              'Заголовок и статус показываются всегда.',
              style: TextStyle(color: onSurface.withAlpha(160), fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: onSurface.withAlpha(30)),

          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                for (final field in kIncidentCardFields)
                  SwitchListTile(
                    value: visibility[field.key] ?? true,
                    onChanged: (value) => notifier.toggle(field.key, value),
                    activeThumbColor: AppTheme.primaryBlue,
                    title: Text(
                      field.label,
                      style: TextStyle(color: onSurface, fontSize: 15),
                    ),
                    subtitle: Text(
                      field.description,
                      style: TextStyle(
                        color: onSurface.withAlpha(140),
                        fontSize: 12,
                      ),
                    ),
                    secondary: Icon(
                      field.icon,
                      size: 22,
                      color: onSurface.withAlpha(160),
                    ),
                  ),
              ],
            ),
          ),

          Divider(color: onSurface.withAlpha(30)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Готово',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
