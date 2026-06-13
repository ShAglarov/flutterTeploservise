import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/server_manager.dart';
import '../utils/app_theme.dart';
import 'add_server_screen.dart';

import 'package:flutter_slidable/flutter_slidable.dart';

class ServerListScreen extends ConsumerWidget {
  const ServerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverState = ref.watch(serverStateProvider).value ?? ref.read(serverManagerProvider).state;
    final servers = serverState.servers;
    final activeId = serverState.activeServer?.id;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Выбор сервера',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Server list or empty state
            Expanded(
              child: servers.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: servers.length,
                      itemBuilder: (context, index) {
                        final server = servers[index];
                        final isActive = server.id == activeId;
                        return _ServerTile(
                          server: server,
                          isActive: isActive,
                          onTap: () {
                            ref
                                .read(serverManagerProvider)
                                .selectServer(server.id);
                            Navigator.pop(context);
                          },
                          onDelete: () =>
                              _confirmDelete(context, ref, server),
                          onEdit: () => _openEditServer(context, server),
                        );
                      },
                    ),
            ),

            // Add button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _openAddServer(context),
                  icon: const Icon(Icons.add_circle, size: 22),
                  label: const Text(
                    'Добавить сервер',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dns_outlined, size: 48, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'Нет сохранённых серверов',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте сервер теплоснабжающей\nорганизации для начала работы',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _openAddServer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddServerScreen()),
    );
  }

  void _openEditServer(BuildContext context, ServerEntry server) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddServerScreen(editingServer: server),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, ServerEntry server) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.secondaryDarkBackground,
        title: const Text('Удалить сервер?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          '«${server.name}» будет удалён из списка.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(serverManagerProvider)
                  .deleteServer(server.id);
              Navigator.pop(ctx);
            },
            child: const Text('Удалить',
                style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Server Tile (with Slidable swipe actions)
// ============================================================

class _ServerTile extends StatelessWidget {
  final ServerEntry server;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ServerTile({
    required this.server,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Slidable(
          key: ValueKey(server.id),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.5,
            children: [
              // Изменить (оранжевый)
              CustomSlidableAction(
                onPressed: (_) => onEdit(),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 22),
                    SizedBox(height: 4),
                    Text('Изменить',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              // Удалить (красный)
              CustomSlidableAction(
                onPressed: (_) => onDelete(),
                backgroundColor: AppTheme.errorRed,
                foregroundColor: Colors.white,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, size: 22),
                    SizedBox(height: 4),
                    Text('Удалить',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          child: Material(
            color: isActive
                ? AppTheme.primaryBlue.withOpacity(0.12)
                : AppTheme.secondaryDarkBackground,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.successGreen.withOpacity(0.15)
                            : AppTheme.primaryBlue.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.dns_outlined,
                        size: 20,
                        color: isActive
                            ? AppTheme.successGreen
                            : AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name + URL
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            server.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            server.displayURL,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Checkmark for active server
                    if (isActive)
                      const Icon(Icons.check_circle,
                          color: AppTheme.successGreen, size: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

