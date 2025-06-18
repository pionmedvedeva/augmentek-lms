import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:miniapp/core/di/di.dart';
import 'package:miniapp/shared/models/user.dart';

final logger = Logger();

final telegramProvider = Provider<TelegramProvider>((ref) {
  return TelegramProvider(ref.watch(loggerProvider), ref);
});

final telegramUserProvider = StateProvider<AppUser?>((ref) => null);

class TelegramProvider {
  final Logger _logger;
  final TelegramWebApp _webApp;
  final Ref _ref;

  TelegramProvider(this._logger, this._ref) : _webApp = TelegramWebApp.instance;

  Future<void> initialize() async {
    try {
      final initData = _webApp.initDataUnsafe;
      if (initData != null && initData.user != null) {
        final user = AppUser.fromTelegramData(initData.user!);
        _ref.read(telegramUserProvider.notifier).state = user;
        _logger.i('Telegram user initialized: ${user.firstName} (Admin: ${user.isAdmin})');
      } else {
        _ref.read(telegramUserProvider.notifier).state = null;
        _logger.w('No Telegram user data available');
      }
    } catch (e, stack) {
      _ref.read(telegramUserProvider.notifier).state = null;
      _logger.e('Error initializing Telegram user', error: e, stackTrace: stack);
    }
  }

  void showAlert(String message) {
    try {
      _webApp.showAlert(message);
    } catch (e, stack) {
      _logger.e('Error showing alert', error: e, stackTrace: stack);
    }
  }

  void showConfirm(String message) {
    try {
      _webApp.showConfirm(message);
    } catch (e, stack) {
      _logger.e('Error showing confirm', error: e, stackTrace: stack);
    }
  }
} 