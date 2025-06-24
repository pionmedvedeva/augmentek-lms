import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider для хранения логов
final debugLogsProvider = StateNotifierProvider<DebugLogsNotifier, List<String>>((ref) {
  return DebugLogsNotifier();
});

// Provider для состояния debug панели
final debugPanelStateProvider = StateNotifierProvider<DebugPanelStateNotifier, DebugPanelState>((ref) {
  return DebugPanelStateNotifier();
});

enum DebugPanelState {
  hidden,     // Полностью скрыта
  icon,       // Показана только иконка
  expanded,   // Развернута панель логов
}

class DebugLogsNotifier extends StateNotifier<List<String>> {
  DebugLogsNotifier() : super([]);

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

class DebugPanelStateNotifier extends StateNotifier<DebugPanelState> {
  DebugPanelStateNotifier() : super(DebugPanelState.icon);

  void toggle() {
    switch (state) {
      case DebugPanelState.hidden:
        state = DebugPanelState.icon;
        break;
      case DebugPanelState.icon:
        state = DebugPanelState.expanded;
        break;
      case DebugPanelState.expanded:
        state = DebugPanelState.icon;
        break;
    }
  }

  void hide() {
    state = DebugPanelState.hidden;
  }

  void show() {
    state = DebugPanelState.icon;
  }

  void expand() {
    state = DebugPanelState.expanded;
  }

  void collapse() {
    state = DebugPanelState.icon;
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

    return Scaffold(
      body: Stack(
        children: [
          // Основной контент занимает весь экран
          child,
          
          // Плавающая debug иконка
          const FloatingDebugIcon(),
          
          // Overlay с логами (показывается при развороте)
          const DebugLogsOverlay(),
        ],
      ),
    );
  }
}

class FloatingDebugIcon extends ConsumerWidget {
  const FloatingDebugIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(debugLogsProvider);
    final panelState = ref.watch(debugPanelStateProvider);

    if (panelState == DebugPanelState.hidden || panelState == DebugPanelState.expanded) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 100, // Под AppBar
      right: 16,
      child: GestureDetector(
        onTap: () => ref.read(debugPanelStateProvider.notifier).expand(),
        onLongPress: () => ref.read(debugPanelStateProvider.notifier).hide(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.bug_report,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              if (logs.isNotEmpty)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      logs.length > 99 ? '99+' : '${logs.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
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

class DebugLogsOverlay extends ConsumerWidget {
  const DebugLogsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(debugLogsProvider);
    final panelState = ref.watch(debugPanelStateProvider);

    if (panelState != DebugPanelState.expanded) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: () => ref.read(debugPanelStateProvider.notifier).collapse(),
        child: Container(
          color: Colors.black54,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Предотвращаем закрытие при клике на панель
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Заголовок
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.bug_report,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Debug Logs',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (logs.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${logs.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          IconButton(
                            onPressed: () => ref.read(debugLogsProvider.notifier).clear(),
                            icon: const Icon(Icons.clear, color: Colors.white),
                            tooltip: 'Очистить логи',
                          ),
                          IconButton(
                            onPressed: () => ref.read(debugPanelStateProvider.notifier).collapse(),
                            icon: const Icon(Icons.close, color: Colors.white),
                            tooltip: 'Закрыть',
                          ),
                        ],
                      ),
                    ),
                    
                    // Список логов
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: logs.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Логи пусты',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: logs.length,
                                itemBuilder: (context, index) {
                                  final log = logs[logs.length - 1 - index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade900,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      log,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    
                    // Подсказка
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Нажмите вне панели или на ✕ чтобы закрыть\nДлинное нажатие на иконку скрывает её',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Виджет для быстрого доступа к debug панели (можно добавить в любое место)
class DebugToggleButton extends ConsumerWidget {
  const DebugToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panelState = ref.watch(debugPanelStateProvider);
    
    if (panelState != DebugPanelState.hidden) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.small(
      onPressed: () => ref.read(debugPanelStateProvider.notifier).show(),
      backgroundColor: Colors.blue.shade700,
      child: const Icon(Icons.bug_report, color: Colors.white, size: 20),
    );
  }
} 