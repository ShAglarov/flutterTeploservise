import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/management_company_models.dart';
import '../providers/management_company_providers.dart';
import '../services/management_company_service.dart';
import '../utils/app_theme.dart';
import 'management_company_form_screen.dart';

class ManagementCompanyDetailScreen extends ConsumerStatefulWidget {
  final ManagementCompanyResponse company;

  const ManagementCompanyDetailScreen({super.key, required this.company});

  @override
  ConsumerState<ManagementCompanyDetailScreen> createState() =>
      _ManagementCompanyDetailScreenState();
}

class _ManagementCompanyDetailScreenState
    extends ConsumerState<ManagementCompanyDetailScreen> {
  late ManagementCompanyResponse _company;

  @override
  void initState() {
    super.initState();
    _company = widget.company;
  }

  Future<void> _refresh() async {
    try {
      final service = ref.read(managementCompanyServiceProvider);
      final updated = await service.getManagementCompany(_company.id);
      if (mounted) {
        setState(() => _company = updated);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _openEditForm() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ManagementCompanyFormScreen(company: _company),
      ),
    );
    if (updated == true) {
      ref.invalidate(managementCompaniesProvider);
      await _refresh();
    }
  }

  Future<void> _deleteCompany() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.secondaryDarkBackground,
        title:
            const Text('Удалить УК', style: TextStyle(color: Colors.white)),
        content: Text(
          'Удалить управляющую компанию «${_company.name}»?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить',
                style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final service = ref.read(managementCompanyServiceProvider);
        await service.deleteManagementCompany(_company.id);
        ref.invalidate(managementCompaniesProvider);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('«${_company.name}» удалена'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка удаления: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label скопировано'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _company.name,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue),
            onPressed: _openEditForm,
            tooltip: 'Редактировать',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppTheme.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Header card with icon and name
              _buildHeaderCard(),

              const SizedBox(height: 20),

              // Contact info
              _buildSectionHeader('Контактная информация'),
              const SizedBox(height: 8),
              _buildInfoCard([
                if (_company.phone != null && _company.phone!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Телефон',
                    value: _company.phone!,
                    onTap: () =>
                        _copyToClipboard(_company.phone!, 'Телефон'),
                  ),
                if (_company.email != null && _company.email!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: _company.email!,
                    onTap: () => _copyToClipboard(_company.email!, 'Email'),
                  ),
                if (_company.address != null && _company.address!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Адрес',
                    value: _company.address!,
                    onTap: () =>
                        _copyToClipboard(_company.address!, 'Адрес'),
                  ),
                if (_company.director != null &&
                    _company.director!.isNotEmpty)
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    label: 'Директор',
                    value: _company.director!,
                  ),
              ]),

              const SizedBox(height: 20),

              // Statistics
              _buildSectionHeader('Статистика'),
              const SizedBox(height: 8),
              _buildStatsRow(),

              // Notes
              if (_company.notes != null && _company.notes!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildSectionHeader('Заметки'),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryDarkBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _company.notes!,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 15, height: 1.4),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Delete button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _deleteCompany,
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text('Удалить компанию',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: BorderSide(color: AppTheme.errorRed.withAlpha(80)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDarkBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.business,
                color: AppTheme.primaryBlue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _company.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${_company.id}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    // Filter out null widgets (empty conditions)
    final nonNullChildren = children.where((w) => true).toList();
    if (nonNullChildren.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDarkBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Нет контактной информации',
          style:
              TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryDarkBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (int i = 0; i < nonNullChildren.length; i++) ...[
            nonNullChildren[i],
            if (i < nonNullChildren.length - 1)
              Divider(
                height: 1,
                color: Colors.white.withAlpha(15),
                indent: 52,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryBlue, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (onTap != null)
              Icon(Icons.copy_outlined,
                  color: Colors.white.withOpacity(0.2), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final housesCount = _company.locationUUIDs.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.home_outlined,
            label: 'Домов',
            value: '$housesCount',
            color: AppTheme.successGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDarkBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
