import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/boiler_house_models.dart';
import '../models/user_role.dart';
import '../services/boiler_house_service.dart';
import '../services/user_service.dart';
import '../utils/app_theme.dart';

class BoilerHouseFormDialog extends ConsumerStatefulWidget {
  final LatLng position;

  const BoilerHouseFormDialog({super.key, required this.position});

  @override
  ConsumerState<BoilerHouseFormDialog> createState() => _BoilerHouseFormDialogState();
}

class _BoilerHouseFormDialogState extends ConsumerState<BoilerHouseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late final TextEditingController _siteNumberController;
  
  String? _selectedSiteManager;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _latController = TextEditingController(text: widget.position.latitude.toStringAsFixed(6));
    _lngController = TextEditingController(text: widget.position.longitude.toStringAsFixed(6));
    _siteNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _siteNumberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final boilerHouse = BoilerHouseCreate(
        address: _addressController.text,
        latitude: double.parse(_latController.text),
        longitude: double.parse(_lngController.text),
        siteNumber: _siteNumberController.text.isNotEmpty ? _siteNumberController.text : null,
        siteManager: _selectedSiteManager,
      );

      final result = await ref.read(boilerHouseServiceProvider).createBoilerHouse(boilerHouse);
      
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: 500,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Form(
                key: _formKey,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildRow('Название', controller: _addressController, hint: 'Напр.: Котельная №1'),
                      _buildDivider(),
                      _buildRow('Широта', controller: _latController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      _buildDivider(),
                      _buildRow('Долгота', controller: _lngController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                      _buildDivider(),
                      _buildRow('Номер участка', controller: _siteNumberController, hint: 'Напр.: 1'),
                      _buildDivider(),

                      _buildManagerDropdown(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleButton(
            icon: Icons.close,
            onTap: () => Navigator.pop(context),
          ),
          const Text(
            'Новая котельная',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          _isSaving 
            ? const SizedBox(width: 80, height: 36, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
            : ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Text('Сохранить', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, {
    TextEditingController? controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(String label, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: value == 'Не выбрано' ? Colors.white38 : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 20, color: Colors.white24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagerDropdown() {
    return Consumer(
      builder: (context, ref, child) {
        final usersAsync = ref.watch(usersProvider);
        return usersAsync.when(
          data: (users) {
            final managers = users.where((u) => u.role == UserRole.manager).toList();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Начальник участка',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSiteManager,
                        dropdownColor: const Color(0xFF2C2C2E),
                        icon: const SizedBox.shrink(),
                        alignment: Alignment.centerRight,
                        hint: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Выберите',
                            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 16),
                          ),
                        ),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                        items: managers.map((user) {
                          // Omit the • Role suffix for the picker to save space
                          final label = user.formattedDisplayName.split(' • ').first;
                          return DropdownMenuItem<String>(
                            value: label,
                            alignment: Alignment.centerRight,
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedSiteManager = value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (err, stack) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.1), height: 1, indent: 16);
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
