import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/organization_models.dart';
import '../services/organization_service.dart';
import '../utils/app_theme.dart';

/// Создание организации (с первым администратором) или правка существующей.
///
/// Офлайн-очереди здесь нет намеренно: организацию заводит суперадмин,
/// сервер создаёт её вместе с админом и его правами одной транзакцией.
/// Локально такое не воспроизвести, поэтому форма требует сети.
class OrganizationFormScreen extends ConsumerStatefulWidget {
  /// null — создание; иначе правка.
  final OrganizationResponse? organization;

  const OrganizationFormScreen({super.key, this.organization});

  @override
  ConsumerState<OrganizationFormScreen> createState() =>
      _OrganizationFormScreenState();
}

class _OrganizationFormScreenState
    extends ConsumerState<OrganizationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _innController;
  late final TextEditingController _ogrnController;
  late final TextEditingController _requisitesController;

  final _adminUsernameController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminFullNameController = TextEditingController();

  bool _isSaving = false;
  bool _isActive = true;
  bool _obscurePassword = true;

  bool get _isEditing => widget.organization != null;

  @override
  void initState() {
    super.initState();
    final o = widget.organization;
    _nameController = TextEditingController(text: o?.name ?? '');
    _innController = TextEditingController(text: o?.inn ?? '');
    _ogrnController = TextEditingController(text: o?.ogrn ?? '');
    _requisitesController = TextEditingController(text: o?.requisites ?? '');
    _isActive = o?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _innController.dispose();
    _ogrnController.dispose();
    _requisitesController.dispose();
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    _adminEmailController.dispose();
    _adminFullNameController.dispose();
    super.dispose();
  }

  /// Сервер отдаёт в `detail` машинные коды (`username_already_taken`).
  /// Показывать их пользователю нельзя — переводим в понятный текст,
  /// особенно для 409: занятый логин самая частая причина отказа, и надо
  /// объяснить, что логин уникален на всю систему, а не только внутри УК.
  static const _messages = <String, String>{
    'username_already_taken':
        'Логин уже занят. Он уникален для всей системы — выберите другой.',
    'email_already_taken': 'Этот email уже используется.',
    'superadmin_required': 'Нужны права суперадмина.',
    'organization_not_found': 'Организация не найдена.',
    'organization_inactive': 'Организация отключена.',
  };

  String _errorText(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      final detail = data is Map ? data['detail'] : null;
      final code = detail?.toString();

      if (code != null && _messages.containsKey(code)) return _messages[code]!;

      switch (e.response?.statusCode) {
        case 409:
          return 'Логин или email уже заняты.';
        case 403:
          return 'Нужны права суперадмина.';
        case 422:
          return 'Проверьте заполнение полей.';
      }
      if (code != null && code.isNotEmpty) return code;
      return e.message ?? 'Ошибка сети';
    }
    return e.toString();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final service = ref.read(organizationServiceProvider);
      final String message;

      if (_isEditing) {
        await service.update(
          widget.organization!.id,
          OrganizationUpdate(
            name: _nameController.text.trim(),
            inn: _innController.text.trim(),
            ogrn: _ogrnController.text.trim(),
            requisites: _requisitesController.text.trim(),
            isActive: _isActive,
          ),
        );
        message = 'Организация обновлена';
      } else {
        await service.create(
          OrganizationCreate(
            name: _nameController.text.trim(),
            inn: _innController.text.trim(),
            ogrn: _ogrnController.text.trim(),
            requisites: _requisitesController.text.trim(),
            adminUsername: _adminUsernameController.text.trim(),
            adminPassword: _adminPasswordController.text,
            adminEmail: _adminEmailController.text.trim(),
            adminFullName: _adminFullNameController.text.trim(),
          ),
        );
        message = 'Организация создана. Админ может войти со своим логином.';
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppTheme.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorText(e)),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать организацию' : 'Новая организация'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(onPressed: _save, child: const Text('Сохранить')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Организация', cs),
            _field(
              controller: _nameController,
              label: 'Название *',
              hint: 'ООО «Теплосервис»',
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Минимум 2 символа'
                  : null,
            ),
            _field(
              controller: _innController,
              label: 'ИНН',
              keyboardType: TextInputType.number,
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return null;
                if (s.length > 12) return 'Не больше 12 цифр';
                if (int.tryParse(s) == null) return 'Только цифры';
                return null;
              },
            ),
            _field(
              controller: _ogrnController,
              label: 'ОГРН',
              keyboardType: TextInputType.number,
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return null;
                if (s.length > 15) return 'Не больше 15 цифр';
                if (int.tryParse(s) == null) return 'Только цифры';
                return null;
              },
            ),
            _field(
              controller: _requisitesController,
              label: 'Реквизиты',
              hint: 'Банк, р/с, адрес — для квитанций',
              maxLines: 4,
            ),

            if (_isEditing) ...[
              const SizedBox(height: 8),
              Card(
                color: cs.surfaceContainerHighest,
                child: SwitchListTile(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: const Text('Организация активна'),
                  subtitle: Text(
                    _isActive
                        ? 'Сотрудники могут входить в систему'
                        : 'Вход заблокирован для всех сотрудников этой организации',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isActive ? null : AppTheme.warningOrange,
                    ),
                  ),
                ),
              ),
            ],

            if (!_isEditing) ...[
              const SizedBox(height: 24),
              _sectionTitle('Администратор организации', cs),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Он получит полный набор прав и дальше сам создаст '
                  'остальных сотрудников. Логин уникален для всей системы — '
                  'по нему определяется организация при входе.',
                  style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(150)),
                ),
              ),
              _field(
                controller: _adminUsernameController,
                label: 'Логин *',
                hint: 'admin_teplo',
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Минимум 3 символа'
                    : null,
              ),
              _field(
                controller: _adminPasswordController,
                label: 'Пароль *',
                obscure: _obscurePassword,
                suffix: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) =>
                    (v == null || v.length < 8) ? 'Минимум 8 символов' : null,
              ),
              _field(
                controller: _adminEmailController,
                label: 'Email *',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return 'Укажите email';
                  if (!s.contains('@') || !s.contains('.')) {
                    return 'Некорректный email';
                  }
                  return null;
                },
              ),
              _field(
                controller: _adminFullNameController,
                label: 'ФИО',
                hint: 'Иванов Иван Иванович',
              ),
            ],

            const SizedBox(height: 28),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: Text(_isEditing ? 'Сохранить' : 'Создать организацию'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, ColorScheme cs) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: cs.onSurface.withAlpha(140),
          ),
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          maxLines: obscure ? 1 : maxLines,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            suffixIcon: suffix,
            border: const OutlineInputBorder(),
          ),
        ),
      );
}
