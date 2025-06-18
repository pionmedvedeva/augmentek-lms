import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/providers/auth_provider.dart';
import 'package:miniapp/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:miniapp/features/student/presentation/screens/student_dashboard.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isAuthenticated) {
      return authState.isAdmin
          ? const AdminDashboard()
          : const StudentDashboard();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('LMS Mini App'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Добро пожаловать в LMS Mini App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ваш помощник в обучении',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Telegram WebApp will handle the authentication
              },
              child: const Text('Войти через Telegram'),
            ),
          ],
        ),
      ),
    );
  }
} 