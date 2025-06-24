import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/features/auth/repositories/user_repository.dart';
import 'package:miniapp/shared/models/user.dart';
import 'package:miniapp/core/di/di.dart';
import 'package:miniapp/shared/widgets/debug_log_screen.dart';

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<AppUser?>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserNotifier(userRepository, ref);
});

class UserNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final IUserRepository _userRepository;
  final Ref _ref;

  UserNotifier(this._userRepository, this._ref) : super(const AsyncValue.data(null));

  Future<void> loadUser(int userId) async {
    try {
      _ref.read(debugLogsProvider.notifier).addLog('👤 Loading user: $userId');
      state = const AsyncValue.loading();
      final user = await _userRepository.getUser(userId);
      if (user != null) {
        _ref.read(debugLogsProvider.notifier).addLog('✅ User found: ${user.firstName}');
        state = AsyncValue.data(user);
      } else {
        _ref.read(debugLogsProvider.notifier).addLog('❌ User not found: $userId');
        // Here we could create the user if it doesn't exist
        // For now, just indicate that no user was found.
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      _ref.read(loggerProvider).e('Failed to load user', error: e, stackTrace: stack);
      _ref.read(debugLogsProvider.notifier).addLog('❌ Load user error: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createUser(AppUser user) async {
    try {
      await _userRepository.createUser(user);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      _ref.read(loggerProvider).e('Failed to create user', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }

  void clearUser() {
    state = const AsyncValue.data(null);
  }

  void setUser(AppUser user) {
    _ref.read(debugLogsProvider.notifier).addLog('👤 Setting user: ${user.firstName}');
    state = AsyncValue.data(user);
  }
} 