import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorFallbackRedirect extends StatefulWidget {
  final String message;
  final String redirectRoute;
  final Duration delay;

  const ErrorFallbackRedirect({
    super.key,
    this.message = 'Ошибка загрузки данных',
    this.redirectRoute = '/courses',
    this.delay = const Duration(seconds: 2),
  });

  @override
  State<ErrorFallbackRedirect> createState() => _ErrorFallbackRedirectState();
}

class _ErrorFallbackRedirectState extends State<ErrorFallbackRedirect> {
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        context.go(widget.redirectRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(widget.message, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          const CircularProgressIndicator(),
          const SizedBox(height: 8),
          const Text('Сейчас вы будете перенаправлены...'),
        ],
      ),
    );
  }
} 