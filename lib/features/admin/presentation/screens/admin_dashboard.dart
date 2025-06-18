import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/providers/auth_provider.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель администратора'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Добро пожаловать, ${authState.username}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            const Text(
              'Управление курсами',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildAdminCard(
                    context,
                    'Создать курс',
                    Icons.add_circle,
                    () {
                      // TODO: Implement course creation
                    },
                  ),
                  _buildAdminCard(
                    context,
                    'Управление пользователями',
                    Icons.people,
                    () {
                      // TODO: Implement user management
                    },
                  ),
                  _buildAdminCard(
                    context,
                    'Статистика',
                    Icons.bar_chart,
                    () {
                      // TODO: Implement statistics
                    },
                  ),
                  _buildAdminCard(
                    context,
                    'Настройки',
                    Icons.settings,
                    () {
                      // TODO: Implement settings
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 