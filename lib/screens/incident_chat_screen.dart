import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_providers.dart';
import '../models/incident_models.dart';
import '../models/permission_key.dart';
import '../services/permission_service.dart';
import '../services/user_service.dart';
import '../widgets/user_avatar_widget.dart';
import '../widgets/user_profile_sheet.dart';

/// Полноэкранный чат для инцидента — iMessage-style.
class IncidentChatScreen extends ConsumerStatefulWidget {
  final int incidentId;

  const IncidentChatScreen({super.key, required this.incidentId});

  @override
  ConsumerState<IncidentChatScreen> createState() => _IncidentChatScreenState();
}

class _IncidentChatScreenState extends ConsumerState<IncidentChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Свой id — из GET /users/me.
  ///
  /// Раньше читался `authProvider.user?.id` из второго провайдера с тем же
  /// именем (теперь удалён). Он инициализировался только как побочный
  /// эффект импорта, и при пустом состоянии `_currentUserId` == null — ВСЕ
  /// свои сообщения показывались как чужие: слева, серым пузырём, с
  /// аватаркой и именем другого человека.
  int? get _currentUserId => ref.watch(currentUserIdProvider);

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(incidentChatProvider(widget.incidentId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myId = _currentUserId;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('Чат'),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Theme.of(context).dividerColor.withAlpha(40)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.when(
              data: (comments) {
                _scrollToBottom();
                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(40),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Нет сообщений',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Напишите первое сообщение',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(60),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    // Пока свой id не загружен — считаем сообщения чужими:
                    // показать чужое своим (справа, синим) хуже, чем
                    // наоборот. Раньше сравнение null == null делало
                    // «своими» все сообщения жильцов.
                    final isMine = myId != null &&
                        comment.userId != null &&
                        comment.userId == myId;
                    // Show date separator
                    final showDate = index == 0 || _shouldShowDateSeparator(
                      comments[index - 1].createdAt,
                      comment.createdAt,
                    );
                    // Show avatar only for first message in group or different user
                    final showAvatar = !isMine && (
                      index == 0 ||
                      comments[index - 1].userId != comment.userId ||
                      showDate
                    );
                    return Column(
                      children: [
                        if (showDate) _buildDateSeparator(comment.createdAt),
                        _buildBubble(comment, isMine: isMine, showAvatar: showAvatar),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Ошибка: $err', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
          // Поле ввода — только при праве на добавление комментариев.
          // Сервер такой POST отклонит с 403, но раньше клиент этого не
          // знал: пользователь писал сообщение, отправлял и видел, что оно
          // исчезло без объяснения.
          if (ref.watch(permissionStateProvider)
              .hasPermission(PermissionKey.incidentCommentCreate))
            _buildInputBar(isDark)
          else
            _buildReadOnlyBar(isDark),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor.withAlpha(40)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Сообщение...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
          ),
          const SizedBox(width: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _send,
                icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Панель вместо поля ввода, когда права на комментарии нет.
  /// Объясняет причину: иначе исчезнувшее поле выглядит как поломка.
  Widget _buildReadOnlyBar(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor.withAlpha(40)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(110)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Нет права на добавление комментариев — только чтение',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(String dateStr) {
    String label;
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dt.year, dt.month, dt.day);

      if (messageDate == today) {
        label = 'Сегодня';
      } else if (messageDate == today.subtract(const Duration(days: 1))) {
        label = 'Вчера';
      } else {
        label = '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
      }
    } catch (_) {
      label = dateStr;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowDateSeparator(String prev, String current) {
    try {
      final prevDt = DateTime.parse(prev);
      final currDt = DateTime.parse(current);
      return prevDt.day != currDt.day || prevDt.month != currDt.month || prevDt.year != currDt.year;
    } catch (_) {
      return false;
    }
  }

  Widget _buildBubble(IncidentComment comment, {required bool isMine, required bool showAvatar}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isMine
        ? Colors.blue
        : isDark
            ? const Color(0xFF3A3A3C)
            : Colors.white;

    final textColor = isMine
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    final nameColor = isMine
        ? Colors.white.withAlpha(200)
        : Colors.blue;

    final timeColor = isMine
        ? Colors.white.withAlpha(150)
        : Theme.of(context).colorScheme.onSurface.withAlpha(100);

    return Padding(
      padding: EdgeInsets.only(
        top: showAvatar ? 8 : 2,
        bottom: 2,
        left: isMine ? 60 : 0,
        right: isMine ? 0 : 60,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            if (showAvatar)
              GestureDetector(
                onTap: () => _openUserProfile(comment),
                child: UserAvatarWidget(
                  avatarUrl: comment.author?.avatarUrl,
                  displayName: comment.displayName,
                  userId: comment.userId,
                  radius: 16,
                ),
              )
            else
              const SizedBox(width: 32), // Placeholder for avatar alignment
            const SizedBox(width: 6),
          ],
          Flexible(
            child: GestureDetector(
              // Удаление по долгому нажатию. Своё сообщение автор удаляет
              // всегда, чужое — только с правом incident_comment.delete;
              // те же правила проверяет сервер.
              onLongPress: _canDelete(comment, isMine)
                  ? () => _confirmDelete(comment)
                  : null,
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMine ? 18 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 18),
                ),
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMine && showAvatar)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            comment.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: nameColor,
                            ),
                          ),
                          // Жилец и сотрудник выглядели одинаково — отвечая,
                          // можно было не понять, кому пишешь.
                          if (comment.isResidentComment) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.teal.withAlpha(40),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'жилец',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  Text(
                    comment.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _formatTime(comment.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: timeColor,
                      ),
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Можно ли удалить это сообщение: своё — всегда, чужое — по праву.
  /// Системные сообщения не удаляются: это журнал, а не переписка.
  bool _canDelete(IncidentComment comment, bool isMine) {
    if (comment.isSystemMessage) return false;
    if (isMine) return true;
    return ref
        .read(permissionStateProvider)
        .hasPermission(PermissionKey.incidentCommentDelete);
  }

  Future<void> _confirmDelete(IncidentComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить сообщение?'),
        content: const Text('Сообщение будет удалено у всех участников.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(incidentChatProvider(widget.incidentId).notifier)
          .deleteComment(comment.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось удалить: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    ref.read(incidentChatProvider(widget.incidentId).notifier).sendComment(text);
    _focusNode.requestFocus();
  }

  void _openUserProfile(IncidentComment comment) {
    if (comment.userId == null || comment.userId == 0) return;
    final usersMap = ref.read(usersMapProvider).value ?? {};
    final user = usersMap[comment.userId];
    if (user != null) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => UserProfileSheet(user: user),
      );
    }
  }

  String _formatTime(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
