import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/providers/auth_provider.dart';

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои курсы'),
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
              'Доступные курсы',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 0, // TODO: Replace with actual courses
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: const Icon(Icons.school),
                      title: const Text('Название курса'),
                      subtitle: const Text('Описание курса'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement course enrollment
                        },
                        child: const Text('Записаться'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 