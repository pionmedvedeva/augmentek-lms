import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:miniapp/core/di/di.dart';
import '../../../shared/models/user.dart';

final logger = Logger();

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AppUser?>>((ref) {
  return AuthNotifier(
    ref.watch(loggerProvider),
    firebase_auth.FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
});

class AuthNotifier extends StateNotifier<AsyncValue<AppUser?>> {
  final Logger _logger;
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthNotifier(this._logger, this._auth, this._firestore) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      _auth.authStateChanges().listen((firebase_auth.User? firebaseUser) async {
        if (firebaseUser == null) {
          state = const AsyncValue.data(null);
          return;
        }

        try {
          final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
          if (doc.exists) {
            state = AsyncValue.data(AppUser.fromJson(doc.data()!));
          } else {
            state = const AsyncValue.data(null);
          }
        } catch (e, stack) {
          _logger.e('Error fetching user data', error: e, stackTrace: stack);
          state = AsyncValue.error(e, stack);
        }
      });
    } catch (e, stack) {
      _logger.e('Error initializing auth state', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> signInWithTelegram(WebAppUser telegramUser) async {
    try {
      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: await _getCustomToken(telegramUser),
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final user = AppUser.fromTelegramData(telegramUser);
        await _firestore.collection('users').doc(userCredential.user!.uid).set(user.toJson());
      }
    } catch (e, stack) {
      _logger.e('Error signing in with Telegram', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e, stack) {
      _logger.e('Error signing out', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<String> _getCustomToken(WebAppUser telegramUser) async {
    // TODO: Implement custom token generation
    throw UnimplementedError('Custom token generation not implemented');
  }
} 