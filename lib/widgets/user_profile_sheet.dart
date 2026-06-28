import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../utils/app_theme.dart';

class UserProfileSheet extends StatelessWidget {
  final APIUserResponse user;

  const UserProfileSheet({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(bottom: 32, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blueAccent.withOpacity(0.2),
            child: Text(
              _getInitials(user.formattedDisplayName),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Name and Role
          Text(
            user.formattedDisplayName.split(' • ').first,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            user.position?.isNotEmpty == true ? user.position! : user.role.title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
            ),
            textAlign: TextAlign.center,
          ),
          
          // Status badge
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: user.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.isActive ? 'Активен' : 'Неактивен',
              style: TextStyle(
                color: user.isActive ? Colors.green : Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Divider(color: Theme.of(context).colorScheme.onSurface.withAlpha(25)),
          
          // Details
          if (user.phoneNumber?.isNotEmpty == true)
            _buildDetailRow(context, Icons.phone, user.phoneNumber!),
          
          _buildDetailRow(context, Icons.email, user.email),
          
          _buildDetailRow(context, Icons.admin_panel_settings, 'Роль: ${user.role.title}'),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurface.withAlpha(140), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }
}
