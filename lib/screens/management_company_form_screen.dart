import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/management_company_models.dart';
import '../services/management_company_service.dart';
import '../utils/app_theme.dart';

class ManagementCompanyFormScreen extends ConsumerStatefulWidget {
  /// If null — create mode; otherwise — edit mode.
  final ManagementCompanyResponse? company;

  const ManagementCompanyFormScreen({super.key, this.company});

  @override
  ConsumerState<ManagementCompanyFormScreen> createState() =>
      _ManagementCompanyFormScreenState();
}

class _ManagementCompanyFormScreenState
    extends ConsumerState<ManagementCompanyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _directorController;
  late final TextEditingController _notesController;

  bool _isSaving = false;

  bool get _isEditing => widget.company != null;

  @override
  void initState() {
    super.initState();
    final c = widget.company;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _directorController = TextEditingController(text: c?.director ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _directorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final service = ref.read(managementCompanyServiceProvider);

      if (_isEditing) {
        final update = ManagementCompanyUpdate(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          director: _directorController.text.trim().isEmpty
              ? null
              : _directorController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
        await service.updateManagementCompany(widget.company!.id, update);
      } else {
        final create = ManagementCompanyCreate(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          director: _directorController.text.trim().isEmpty
              ? null
              : _directorController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
        await service.createManagementCompany(create);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'УК обновлена' : 'УК создана'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Редактировать УК' : 'Новая УК',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryBlue,
                    ),
                  )
                : const Text(
                    'Сохранить',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Основное'),
              const SizedBox(height: 8),
              _buildFieldCard([
                _buildTextField(
                  controller: _nameController,
                  label: 'Название *',
                  icon: Icons.business,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Введите название';
                    }
                    return null;
                  },
                ),
              ]),

              const SizedBox(height: 20),
              _buildSectionHeader('Контактная информация'),
              const SizedBox(height: 8),
              _buildFieldCard([
                _buildTextField(
                  controller: _phoneController,
                  label: 'Телефон',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                _buildDivider(),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildDivider(),
                _buildTextField(
                  controller: _addressController,
                  label: 'Адрес',
                  icon: Icons.location_on_outlined,
                ),
                _buildDivider(),
                _buildTextField(
                  controller: _directorController,
                  label: 'Директор',
                  icon: Icons.person_outline,
                ),
              ]),

              const SizedBox(height: 20),
              _buildSectionHeader('Дополнительно'),
              const SizedBox(height: 8),
              _buildFieldCard([
                _buildTextField(
                  controller: _notesController,
                  label: 'Заметки',
                  icon: Icons.notes_outlined,
                  maxLines: 4,
                ),
              ]),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFieldCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(15),
      indent: 52,
      endIndent: 16,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 16 : 0),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              validator: validator,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
