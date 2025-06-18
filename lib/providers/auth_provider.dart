import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? username;
  final bool isAdmin;

  AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.username,
    this.isAdmin = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? username,
    bool? isAdmin,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final webApp = TelegramWebApp.instance;
      final initData = webApp.initData;
      if (initData != null) {
        final user = webApp.initDataUnsafe;
        if (user != null) {
          state = state.copyWith(
            isAuthenticated: true,
            userId: user.id?.toString(),
            username: user.username,
            // TODO: Check if user is admin
            isAdmin: false,
          );
        }
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  Future<void> signOut() async {
    state = AuthState();
  }
} 