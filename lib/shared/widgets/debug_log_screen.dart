import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider для хранения логов
final debugLogsProvider = StateNotifierProvider<DebugLogsNotifier, List<String>>((ref) {
  return DebugLogsNotifier();
});

class DebugLogsNotifier extends StateNotifier<List<String>> {
  DebugLogsNotifier() : super([]);

  /// Проверка, включен ли debug режим
  bool get isDebugMode => true; // Всегда включен для отладки

  void addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    state = [...state, '[$timestamp] $message'];
    
    // Ограничиваем количество логов
    if (state.length > 50) {
      state = state.sublist(state.length - 50);
    }
  }

  void clear() {
    state = [];
  }
}

class DebugLogScreen extends ConsumerWidget {
  final Widget child;
  final bool showLogs;

  const DebugLogScreen({
    super.key,
    required this.child,
    this.showLogs = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!showLogs) {
      return child;
    }

    return Stack(
      children: [
        // Основной контент
        child,
        
        // Простая плавающая кнопка
        Positioned(
          top: 50,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: () => _showDebugDialog(context, ref),
            backgroundColor: Colors.blue.shade700,
            child: const Icon(Icons.bug_report, color: Colors.white),
          ),
        ),
      ],
    );
  }

  void _showDebugDialog(BuildContext context, WidgetRef ref) {
    final logs = ref.read(debugLogsProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.bug_report, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Debug Logs'),
            const Spacer(),
            Text('${logs.length}', style: const TextStyle(fontSize: 14)),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: logs.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Логи пусты', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[logs.length - 1 - index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(debugLogsProvider.notifier).clear();
              Navigator.of(context).pop();
            },
            child: const Text('Очистить'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
} 