import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../services/base_api_service.dart';

/// Экран импорта XLS файла с лицевыми счетами и платежными документами
class ImportXlsScreen extends ConsumerStatefulWidget {
  const ImportXlsScreen({super.key});

  @override
  ConsumerState<ImportXlsScreen> createState() => _ImportXlsScreenState();
}

class _ImportXlsScreenState extends ConsumerState<ImportXlsScreen> {
  String? _selectedFilePath;
  String? _selectedFileName;
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _isImporting = false;
  Map<String, dynamic>? _importResult;
  String? _error;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
          _importResult = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() => _error = 'Ошибка выбора файла: $e');
    }
  }

  Future<void> _selectPeriod() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      helpText: 'Выберите период (месяц)',
      fieldLabelText: 'Дата периода',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  Future<void> _startImport() async {
    if (_selectedFilePath == null) {
      setState(() => _error = 'Выберите XLS файл');
      return;
    }

    setState(() {
      _isImporting = true;
      _error = null;
      _importResult = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final file = File(_selectedFilePath!);
      final periodStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-01';
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: _selectedFileName ?? 'import.xls',
        ),
        'period_date': periodStr,
      });

      final response = await dio.post(
        '/import/xls',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        
        if (data['status'] == 'success') {
          setState(() {
            _importResult = data;
            _isImporting = false;
          });
        } else {
          setState(() {
            _error = data['detail']?.toString() ?? 'Неизвестная ошибка импорта';
            _isImporting = false;
          });
        }
      } else {
        setState(() {
          _error = 'Ошибка сервера: ${response.statusCode}';
          _isImporting = false;
        });
      }
    } on DioException catch (e) {
      setState(() {
        _error = 'Ошибка: ${e.response?.data?['detail'] ?? e.message}';
        _isImporting = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка импорта: $e';
        _isImporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const months = [
      '', 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Импорт XLS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Шаг 1: Выбор файла
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.file_upload_outlined, color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 12),
                        const Text('1. Выберите XLS файл', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Формат: файл с данными лицевых счетов и платежных документов (например baosna0826.XLS)',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isImporting ? null : _pickFile,
                      icon: const Icon(Icons.folder_open),
                      label: Text(_selectedFileName ?? 'Выбрать файл'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    if (_selectedFileName != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFileName!,
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Шаг 2: Выбор периода
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 12),
                        const Text('2. Укажите период', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'За какой месяц/год данные в файле?',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _isImporting ? null : _selectPeriod,
                      icon: const Icon(Icons.edit_calendar),
                      label: Text(
                        '${months[_selectedDate.month]} ${_selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Кнопка импорта
            ElevatedButton.icon(
              onPressed: _isImporting || _selectedFilePath == null ? null : _startImport,
              icon: _isImporting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_upload),
              label: Text(
                _isImporting ? 'Импортирую...' : 'Начать импорт',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),

            // Ошибка
            if (_error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ),
            ],

            // Результат
            if (_importResult != null) ...[
              const SizedBox(height: 16),
              _buildResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final stats = _importResult!['statistics'] as Map<String, dynamic>?;
    if (stats == null) return const SizedBox.shrink();

    final errors = (stats['errors'] as List?)?.cast<String>() ?? [];

    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                const Text('Импорт завершён!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow('Всего строк', stats['total_rows']),
            const Divider(height: 12),
            _buildStatRow('Лицевых счетов создано', stats['accounts_created'], color: Colors.blue),
            _buildStatRow('Лицевых счетов обновлено', stats['accounts_updated'], color: Colors.orange),
            const Divider(height: 12),
            _buildStatRow('Платежных документов создано', stats['payment_docs_created'], color: Colors.blue),
            _buildStatRow('Платежных документов обновлено', stats['payment_docs_updated'], color: Colors.orange),

            if (errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: Text('Ошибки (${errors.length})', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                children: errors.take(20).map((e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Text(e, style: const TextStyle(fontSize: 12, color: Colors.red)),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, dynamic value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            '${value ?? 0}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
