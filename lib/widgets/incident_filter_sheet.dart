import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/incident_providers.dart';
import '../utils/app_theme.dart';

class IncidentFilterSheet extends ConsumerWidget {
  const IncidentFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(incidentFilterProvider);
    final filterNotifier = ref.read(incidentFilterProvider.notifier);

    return Container(
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
                color: Theme.of(context).colorScheme.onSurface.withAlpha(60),
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
                Text(
                  'Фильтры',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    filterNotifier.setPeriod(IncidentPeriod.allTime);
                    filterNotifier.setStoppedHotWater(null);
                    filterNotifier.setStoppedHeating(null);
                    filterNotifier.setQuickFilter(IncidentQuickFilter.all);
                    filterNotifier.updateSearchQuery('');
                  },
                  child: const Text('Сбросить', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Period SegmentedControl
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Период', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(180), fontSize: 14)),
                const SizedBox(height: 12),
                SegmentedButton<IncidentPeriod>(
                  segments: const [
                    ButtonSegment(value: IncidentPeriod.allTime, label: Text('Всё время')),
                    ButtonSegment(value: IncidentPeriod.today, label: Text('Сегодня')),
                    ButtonSegment(value: IncidentPeriod.thisWeek, label: Text('Неделя')),
                  ],
                  selected: {filterState.period},
                  onSelectionChanged: (Set<IncidentPeriod> newSelection) {
                    filterNotifier.setPeriod(newSelection.first);
                  },
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) return AppTheme.primaryBlue;
                      return Colors.transparent;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) return Colors.white;
                      return Theme.of(context).colorScheme.onSurface.withAlpha(180);
                    }),
                    side: WidgetStateProperty.all(BorderSide(color: Theme.of(context).colorScheme.onSurface.withAlpha(60))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.black12),
          
          // Resources Toggles
           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('Остановленные ресурсы', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(180), fontSize: 14)),
          ),
          CheckboxListTile(
            title: Text('Горячая вода (ГВС)', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            value: filterState.stoppedHotWater ?? false,
            onChanged: (bool? value) {
              filterNotifier.setStoppedHotWater(value == true ? true : null);
            },
            activeColor: Colors.blue,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: Text('Отопление', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            value: filterState.stoppedHeating ?? false,
            onChanged: (bool? value) {
              filterNotifier.setStoppedHeating(value == true ? true : null);
            },
            activeColor: Colors.red,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Применить', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
