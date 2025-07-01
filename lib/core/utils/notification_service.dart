import 'package:flutter/material.dart';

/// Сервис для показа неблокирующих уведомлений
class NotificationService {
  static OverlayEntry? _currentOverlay;
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  
  /// Показать уведомление об успехе
  static void showSuccess(String message, {Duration? duration}) {
    _showNotification(
      message: message,
      type: NotificationType.success,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
  
  /// Показать уведомление об ошибке
  static void showError(String message, {Duration? duration}) {
    _showNotification(
      message: message,
      type: NotificationType.error,
      duration: duration ?? const Duration(seconds: 5),
    );
  }
  
  /// Показать информационное уведомление
  static void showInfo(String message, {Duration? duration}) {
    _showNotification(
      message: message,
      type: NotificationType.info,
      duration: duration ?? const Duration(seconds: 4),
    );
  }
  
  /// Показать предупреждение
  static void showWarning(String message, {Duration? duration}) {
    _showNotification(
      message: message,
      type: NotificationType.warning,
      duration: duration ?? const Duration(seconds: 4),
    );
  }
  
  /// Показать loading уведомление
  static OverlayEntry showLoading(String message) {
    final context = _navigatorKey.currentContext;
    if (context == null) throw Exception('Navigator context not found');
    
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _LoadingNotification(
        message: message,
        onDismiss: () => overlayEntry.remove(),
      ),
    );
    
    overlay.insert(overlayEntry);
    return overlayEntry;
  }
  
  static void _showNotification({
    required String message,
    required NotificationType type,
    required Duration duration,
  }) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    
    // Убираем предыдущее уведомление если есть
    _currentOverlay?.remove();
    
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _NotificationWidget(
        message: message,
        type: type,
        onDismiss: () {
          overlayEntry.remove();
          if (_currentOverlay == overlayEntry) {
            _currentOverlay = null;
          }
        },
      ),
    );
    
    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);
    
    // Автоматически убираем через заданное время
    Future.delayed(duration, () {
      if (_currentOverlay == overlayEntry) {
        overlayEntry.remove();
        _currentOverlay = null;
      }
    });
  }
}

enum NotificationType { success, error, info, warning }

class _NotificationWidget extends StatefulWidget {
  final String message;
  final NotificationType type;
  final VoidCallback onDismiss;
  
  const _NotificationWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });
  
  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Color _getBackgroundColor() {
    switch (widget.type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.blue;
    }
  }
  
  IconData _getIcon() {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _getIcon(),
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _controller.reverse().then((_) => widget.onDismiss());
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingNotification extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  
  const _LoadingNotification({
    required this.message,
    required this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Более удобные диалоги с меньшим блокированием
class ImprovedDialogs {
  /// Показать подтверждение действия
  static Future<bool> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Подтвердить',
    String cancelText = 'Отмена',
    Color? confirmColor,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true, // Позволяем закрыть касанием вне диалога
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: confirmColor ?? Colors.red),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  /// Показать диалог с формой
  static Future<Map<String, String>?> showFormDialog(
    BuildContext context, {
    required String title,
    required List<CustomFormField> fields,
    String submitText = 'Сохранить',
    String cancelText = 'Отмена',
  }) async {
    final controllers = <String, TextEditingController>{};
    
    // Создаем контроллеры для всех полей
    for (final field in fields) {
      controllers[field.key] = TextEditingController(text: field.initialValue);
    }
    
    try {
      final result = await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fields.map((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: controllers[field.key]!,
                    decoration: InputDecoration(
                      labelText: field.label,
                      hintText: field.hint,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: field.maxLines,
                    keyboardType: field.keyboardType,
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () {
                final result = <String, String>{};
                for (final field in fields) {
                  result[field.key] = controllers[field.key]!.text.trim();
                }
                Navigator.of(context).pop(result);
              },
              child: Text(submitText),
            ),
          ],
        ),
      );
      
      return result;
    } finally {
      // Освобождаем контроллеры
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
  }
}

class CustomFormField {
  final String key;
  final String label;
  final String? hint;
  final String? initialValue;
  final int maxLines;
  final TextInputType keyboardType;
  
  const CustomFormField({
    required this.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });
} 