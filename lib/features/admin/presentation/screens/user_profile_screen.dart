import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniapp/features/admin/providers/user_list_provider.dart';
import 'package:miniapp/shared/widgets/error_widget.dart';
import 'package:miniapp/core/di/di.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIdInt = int.tryParse(userId);
    if (userIdInt == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ошибка'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/admin'),
          ),
        ),
        body: const Center(
          child: Text('Invalid User ID'),
        ),
      );
    }

    final userAsync = ref.watch(userProfileProvider(userIdInt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль пользователя'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('Пользователь не найден.'),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${user.id}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Имя: ${user.firstName} ${user.lastName ?? ''}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Ник: ${user.username ?? 'N/A'}', style: Theme.of(context).textTheme.titleMedium),
                 const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Права администратора'),
                  value: user.isAdmin,
                  onChanged: (bool value) async {
                    final updatedUser = user.copyWith(isAdmin: value);
                    await ref.read(userRepositoryProvider).updateUser(updatedUser);
                    ref.invalidate(userProfileProvider(userIdInt));
                    ref.invalidate(userListProvider);
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => AppErrorWidget(
          error: error.toString(),
          onRetry: () => ref.refresh(userProfileProvider(userIdInt)),
        ),
      ),
    );
  }
} 