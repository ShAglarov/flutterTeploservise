import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/organization_models.dart';
import '../providers/organization_providers.dart';
import '../services/tenant_service.dart';
import '../utils/app_theme.dart';
import 'organization_form_screen.dart';

/// Список организаций системы — экран владельца сервиса (суперадмина).
///
/// Удаления нет сознательно: организация — корень всех данных, и её удаление
/// означало бы каскад по 30 таблицам. Вместо этого переключатель «активна»,
/// который закрывает вход сотрудникам, оставляя данные на месте.
class OrganizationsScreen extends ConsumerWidget {
  const OrganizationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizations = ref.watch(organizationsProvider);
    final currentOrgId = TenantService.currentOrganizationId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Организации'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: () => ref.invalidate(organizationsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Организация'),
      ),
      body: organizations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          error: e,
          onRetry: () => ref.invalidate(organizationsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Организаций пока нет'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(organizationsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: list.length + 1,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == 0) return _Header(count: list.length);
                final org = list[index - 1];
                return _OrganizationTile(
                  org: org,
                  isCurrent: org.id == currentOrgId,
                  onTap: () => _openForm(context, ref, org: org),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    OrganizationResponse? org,
  }) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OrganizationFormScreen(organization: org),
      ),
    );
    if (changed == true) ref.invalidate(organizationsProvider);
  }
}

class _Header extends StatelessWidget {
  final int count;
  const _Header({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Text(
        'Всего организаций: $count. Данные каждой изолированы — сотрудники '
        'видят только свою компанию. Организация определяется по логину при входе.',
        style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(150)),
      ),
    );
  }
}

class _OrganizationTile extends StatelessWidget {
  final OrganizationResponse org;
  final bool isCurrent;
  final VoidCallback onTap;

  const _OrganizationTile({
    required this.org,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final details = <String>[
      if (org.inn != null && org.inn!.isNotEmpty) 'ИНН ${org.inn}',
      'сотрудников: ${org.usersCount}',
    ];

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: org.isActive
            ? AppTheme.primaryBlue.withAlpha(40)
            : cs.onSurface.withAlpha(20),
        child: Icon(
          org.isActive ? Icons.apartment : Icons.block,
          color: org.isActive ? AppTheme.primaryBlue : cs.onSurface.withAlpha(120),
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              org.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (isCurrent)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'ваша',
                style: TextStyle(fontSize: 11, color: AppTheme.successGreen),
              ),
            ),
        ],
      ),
      subtitle: Text(
        details.join(' · '),
        style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(150)),
      ),
      trailing: org.isActive
          ? const Icon(Icons.chevron_right)
          : Text(
              'отключена',
              style: TextStyle(fontSize: 11, color: AppTheme.warningOrange),
            ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 44, color: AppTheme.errorRed),
            const SizedBox(height: 12),
            Text(
              'Не удалось загрузить организации',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
