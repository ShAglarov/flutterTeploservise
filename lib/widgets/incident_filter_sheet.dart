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
      decoration: const BoxDecoration(
        color: AppTheme.secondaryDarkBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                color: Colors.white24,
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
                const Text(
                  'Фильтры',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                const Text('Период', style: TextStyle(color: Colors.white70, fontSize: 14)),
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
                      return Colors.white70;
                    }),
                    side: WidgetStateProperty.all(const BorderSide(color: Colors.white24)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          
          // Resources Toggles
           const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('Остановленные ресурсы', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ),
          CheckboxListTile(
            title: const Text('Горячая вода (ГВС)', style: TextStyle(color: Colors.white)),
            value: filterState.stoppedHotWater ?? false,
            onChanged: (bool? value) {
              filterNotifier.setStoppedHotWater(value == true ? true : null);
            },
            activeColor: Colors.blue,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text('Отопление', style: TextStyle(color: Colors.white)),
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
