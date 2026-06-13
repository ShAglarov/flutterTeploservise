import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/server_manager.dart';
import '../utils/app_theme.dart';

class AddServerScreen extends ConsumerStatefulWidget {
  final ServerEntry? editingServer;

  const AddServerScreen({super.key, this.editingServer});

  @override
  ConsumerState<AddServerScreen> createState() => _AddServerScreenState();
}

class _AddServerScreenState extends ConsumerState<AddServerScreen> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  bool _isChecking = false;
  bool? _checkResult;
  String _checkMessage = '';

  bool get _isEditing => widget.editingServer != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.editingServer!.name;
      _urlController.text = widget.editingServer!.displayURL;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _urlController.text.trim().isNotEmpty;

  Future<void> _handleCheckConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _checkResult = false;
        _checkMessage = 'Введите адрес сервера';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isChecking = true;
      _checkResult = null;
      _checkMessage = 'Проверка соединения...';
    });

    final (success, message) =
        await ServerManagerNotifier.checkConnection(url);

    if (mounted) {
      setState(() {
        _isChecking = false;
        _checkResult = success;
        _checkMessage = message;
      });
    }
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();
    if (name.isEmpty || url.isEmpty) return;

    final notifier = ref.read(serverManagerProvider);

    if (_isEditing) {
      await notifier.updateServer(
        widget.editingServer!.id,
        name: name,
        url: url,
      );
    } else {
      final server = await notifier.addServer(name, url);
      // Автоматически выбираем добавленный сервер
      await notifier.selectServer(server.id);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Редактирование' : 'Новый сервер',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header
              Text(
                _isEditing ? 'Редактирование сервера' : 'Новый сервер',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Укажите данные сервера теплоснабжающей организации',
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ),
              const SizedBox(height: 32),

              // Name field
              const Text(
                'НАЗВАНИЕ ОРГАНИЗАЦИИ',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 17),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'МУП Теплосеть Казань',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                  filled: true,
                  fillColor: AppTheme.secondaryDarkBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                ),
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // URL field
              const Text(
                'АДРЕС СЕРВЕРА',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white, fontSize: 17),
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'https://api.company.ru',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                  filled: true,
                  fillColor: AppTheme.secondaryDarkBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                ),
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  setState(() {
                    _checkResult = null;
                    _checkMessage = '';
                  });
                },
              ),
              const SizedBox(height: 16),

              // Check connection button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isChecking ? null : _handleCheckConnection,
                  icon: _isChecking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTheme.primaryBlue),
                        )
                      : const Icon(Icons.cell_tower, size: 20),
                  label: Text(
                    _isChecking ? 'Проверка...' : 'Проверить соединение',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Connection status
              if (_checkMessage.isNotEmpty)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _checkResult == null
                          ? Colors.white.withOpacity(0.05)
                          : _checkResult!
                              ? AppTheme.successGreen.withOpacity(0.15)
                              : AppTheme.errorRed.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        if (_checkResult != null)
                          Icon(
                            _checkResult!
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: _checkResult!
                                ? AppTheme.successGreen
                                : AppTheme.errorRed,
                            size: 20,
                          ),
                        if (_checkResult != null) const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _checkMessage,
                            style: TextStyle(
                              color: _checkResult == null
                                  ? Colors.white54
                                  : _checkResult!
                                      ? AppTheme.successGreen
                                      : AppTheme.errorRed,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canSave ? _handleSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppTheme.primaryBlue.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Сохранить',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
}
