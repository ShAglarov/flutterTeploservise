import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/management_company_models.dart';
import '../providers/management_company_providers.dart';
import '../services/management_company_service.dart';
import '../utils/app_theme.dart';
import 'management_company_detail_screen.dart';
import 'management_company_form_screen.dart';

class ManagementCompanyListScreen extends ConsumerStatefulWidget {
  const ManagementCompanyListScreen({super.key});

  @override
  ConsumerState<ManagementCompanyListScreen> createState() =>
      _ManagementCompanyListScreenState();
}

class _ManagementCompanyListScreenState
    extends ConsumerState<ManagementCompanyListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteCompany(ManagementCompanyResponse company) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.secondaryDarkBackground,
        title:
            const Text('Удалить УК', style: TextStyle(color: Colors.white)),
        content: Text(
          'Удалить управляющую компанию «${company.name}»?',
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
        await service.deleteManagementCompany(company.id);
        ref.invalidate(managementCompaniesProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('«${company.name}» удалена'),
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

  void _openDetail(ManagementCompanyResponse company) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManagementCompanyDetailScreen(company: company),
      ),
    );
  }

  void _openCreateForm() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const ManagementCompanyFormScreen(),
      ),
    );
    if (created == true) {
      ref.invalidate(managementCompaniesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(managementCompaniesProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Управляющие компании',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryBlue),
            onPressed: _openCreateForm,
            tooltip: 'Добавить УК',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search,
                      color: Colors.white.withOpacity(0.5), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Поиск УК…',
                        hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear,
                          color: Colors.white30, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                ],
              ),
            ),
          ),

          // List
          Expanded(
            child: companiesAsync.when(
              loading: () => const Center(
                child:
                    CircularProgressIndicator(color: AppTheme.primaryBlue),
              ),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.errorRed, size: 48),
                    const SizedBox(height: 16),
                    Text('Ошибка загрузки: $err',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(managementCompaniesProvider),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
              data: (companies) {
                // Apply search filter
                final filtered = _searchQuery.isEmpty
                    ? companies
                    : companies
                        .where((c) => c.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(managementCompaniesProvider);
                  },
                  color: AppTheme.primaryBlue,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final company = filtered[index];
                      return _buildCompanyCard(company);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(ManagementCompanyResponse company) {
    final housesCount = company.locationUUIDs.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(company),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.secondaryDarkBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withOpacity(0.06), width: 1),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.business,
                      color: AppTheme.primaryBlue, size: 22),
                ),
                const SizedBox(width: 14),

                // Name + houses count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.home_outlined,
                              color: Colors.white.withOpacity(0.4),
                              size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Домов: $housesCount',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                          if (company.phone != null &&
                              company.phone!.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.phone_outlined,
                                color: Colors.white.withOpacity(0.4),
                                size: 14),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                company.phone!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      color: Colors.white.withOpacity(0.4), size: 20),
                  color: AppTheme.tertiaryDarkBackground,
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ManagementCompanyFormScreen(company: company),
                        ),
                      ).then((updated) {
                        if (updated == true) {
                          ref.invalidate(managementCompaniesProvider);
                        }
                      });
                    } else if (value == 'delete') {
                      _deleteCompany(company);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              color: AppTheme.warningOrange, size: 18),
                          SizedBox(width: 10),
                          Text('Редактировать',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              color: AppTheme.errorRed, size: 18),
                          SizedBox(width: 10),
                          Text('Удалить',
                              style: TextStyle(color: AppTheme.errorRed)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_outlined,
              color: Colors.white.withOpacity(0.2), size: 64),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'Ничего не найдено'
                : 'Нет управляющих компаний',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Попробуйте изменить запрос'
                : 'Добавьте новую УК нажав +',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
