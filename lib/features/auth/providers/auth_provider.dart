import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:miniapp/core/di/di.dart';
import 'package:miniapp/features/auth/providers/user_provider.dart';
import 'package:miniapp/features/auth/repositories/user_repository.dart';
import 'package:miniapp/shared/models/user.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:flutter/foundation.dart';
import 'package:miniapp/core/config/admin_config.dart';
import 'package:miniapp/shared/widgets/debug_log_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

final authStateProvider = StreamProvider<firebase_auth.User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncValue.data(null));

  firebase_auth.FirebaseAuth get _auth => _ref.read(firebaseAuthProvider);
  IUserRepository get _userRepository => _ref.read(userRepositoryProvider);
  FirebaseFunctions get _functions => _ref.read(firebaseFunctionsProvider);

  Future<void> signInAutomatically() async {
    state = const AsyncValue.loading();
    try {
      _ref.read(loggerProvider).i('Starting automatic sign-in…');
      _ref.read(debugLogsProvider.notifier).addLog('🚀 Starting automatic sign-in');

      // Проверяем инициализацию Firebase
      if (!_auth.app.options.projectId.isNotEmpty) {
        throw Exception('Firebase is not properly initialized');
      }

      // Если пользователь уже залогинен – просто загружаем его данные
      if (_auth.currentUser != null) {
        _ref.read(loggerProvider).i('User already signed in: ${_auth.currentUser!.uid}');
        _ref.read(debugLogsProvider.notifier).addLog('🔄 User already signed in, skipping auth flow');
        // TODO: Implement proper user loading for already signed in users
        // For now, continue with the normal flow
        _ref.read(debugLogsProvider.notifier).addLog('⚠️ Continuing with normal auth flow...');
      }

      // Подготавливаем данные пользователя (Telegram или mock)
      final webApp = TelegramWebApp.instance;
      final tgUser = webApp.initDataUnsafe?.user;
      final rawInitData = webApp.initData;
      
      final AppUser appUser = tgUser == null
          ? mockUser
          : AppUser.fromTelegramData(tgUser);
          
      // Логируем данные от Telegram
      if (tgUser != null) {
        _ref.read(debugLogsProvider.notifier).addLog('🔍 Telegram user raw data:');
        _ref.read(debugLogsProvider.notifier).addLog('  - id: ${tgUser.id}');
        _ref.read(debugLogsProvider.notifier).addLog('  - firstName: ${tgUser.firstName}');
        _ref.read(debugLogsProvider.notifier).addLog('  - photoUrl: "${tgUser.photoUrl}"');
        _ref.read(debugLogsProvider.notifier).addLog('📱 AppUser created with photoUrl: "${appUser.photoUrl}"');
      }

      // Определяем initData для отправки
      String initDataToSend;
      if (tgUser == null || rawInitData == null) {
        // Используем mock данные
        initDataToSend = 'mock_init_data_for_${appUser.id}';
        _ref.read(loggerProvider).i('Using mock initData: $initDataToSend');
      } else {
        // Используем реальные Telegram данные - получаем raw поле
        final rawString = rawInitData.raw;
        if (rawString == null || rawString.isEmpty || rawString == 'null') {
          initDataToSend = 'mock_init_data_for_${appUser.id}';
          _ref.read(loggerProvider).i('Raw initData is empty, using mock: $initDataToSend');
        } else {
          initDataToSend = rawString;
          _ref.read(loggerProvider).i('Using real Telegram raw initData (length: ${rawString.length})');
          _ref.read(debugLogsProvider.notifier).addLog('📡 Sending Telegram data (${rawString.length} chars)');
        }
      }

      _ref.read(debugLogsProvider.notifier).addLog('🌐 Calling Firebase Function...');
      // Вызываем HTTP cloud function
      final url = 'https://getcustomtoken-fqitgxgsza-uc.a.run.app';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'initData': initDataToSend,
        }),
      );

      _ref.read(loggerProvider).i('📡 HTTP Response: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        _ref.read(loggerProvider).e('❌ HTTP Error: ${response.statusCode}: ${response.body}');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final result = json.decode(response.body);
      _ref.read(loggerProvider).i('📦 Response data: ${result.toString().substring(0, 100)}...');
      
      // Проверяем, есть ли custom token
      if (result.containsKey('token')) {
        final token = result['token'];
        if (token == null) {
          throw Exception('Custom token is null');
        }

        _ref.read(loggerProvider).i('🔑 Custom token received, length: ${token.length}');
        _ref.read(debugLogsProvider.notifier).addLog('🔑 Custom token received (${token.length} chars)');
        _ref.read(loggerProvider).i('🔐 Attempting Firebase signInWithCustomToken...');
        _ref.read(debugLogsProvider.notifier).addLog('🔐 Signing in to Firebase...');
        
        // Логинимся кастомным токеном
        final cred = await _auth.signInWithCustomToken(token);
        if (cred.user == null) {
          throw Exception('Firebase user is null after sign-in');
        }
        
        _ref.read(loggerProvider).i('✅ Успешная аутентификация через custom token');
        _ref.read(debugLogsProvider.notifier).addLog('✅ Firebase sign-in successful!');
        _ref.read(loggerProvider).i('👤 Firebase User UID: ${cred.user!.uid}');
        _ref.read(debugLogsProvider.notifier).addLog('👤 User UID: ${cred.user!.uid}');
        
      } else if (result.containsKey('success') && result['success'] == true) {
        // Альтернативный метод - пользователь уже создан в Firebase Auth
        final userData = result['user'];
        final uid = userData['uid'] as String;
        
        _ref.read(loggerProvider).i('✅ Пользователь аутентифицирован через Telegram');
        _ref.read(loggerProvider).i('User ID: $uid');
        _ref.read(loggerProvider).i('Message: ${result['message']}');
        
        // Пытаемся войти как анонимный пользователь для доступа к Firebase
        try {
          final cred = await _auth.signInAnonymously();
          _ref.read(loggerProvider).i('✅ Анонимный вход выполнен: ${cred.user?.uid}');
        } catch (e) {
          _ref.read(loggerProvider).w('⚠️ Ошибка анонимного входа: $e');
          // Продолжаем без Firebase Auth
        }
        
      } else {
        throw Exception('Неожиданный формат ответа от сервера: $result');
      }

      _ref.read(debugLogsProvider.notifier).addLog('✨ Firebase Auth completed, moving to Firestore...');
      _ref.read(debugLogsProvider.notifier).addLog('🔄 About to check Firestore data...');
      
      // Проверяем, что состояние еще loading
      _ref.read(debugLogsProvider.notifier).addLog('📊 Current state: ${state.runtimeType}');
      
      _ref.read(loggerProvider).i('💾 Checking user data in Firestore...');
      _ref.read(debugLogsProvider.notifier).addLog('💾 Checking user data in Firestore...');
      
      // Сохраняем / получаем данные пользователя в Firestore по Telegram User ID
      _ref.read(debugLogsProvider.notifier).addLog('🔍 Calling getUser for ID: ${appUser.id}');
      
      AppUser? existing;
      try {
        existing = await _userRepository.getUser(appUser.id);
        _ref.read(debugLogsProvider.notifier).addLog('📋 getUser completed successfully');
      } catch (e) {
        _ref.read(debugLogsProvider.notifier).addLog('💥 getUser threw exception: $e');
        rethrow;
      }
      
      _ref.read(debugLogsProvider.notifier).addLog('📋 getUser result: ${existing != null ? "found" : "null"}');
      AppUser finalUser;
      
      if (existing == null) {
        _ref.read(loggerProvider).i('👤 Creating new user in Firestore...');
        _ref.read(debugLogsProvider.notifier).addLog('👤 Creating new user: ${appUser.firstName}');
        
        // Добавляем Firebase UID к пользователю если есть
        final userWithFirebaseId = _auth.currentUser != null
            ? appUser.copyWith(firebaseId: _auth.currentUser!.uid)
            : appUser;
        
        await _userRepository.createUser(userWithFirebaseId);
        finalUser = userWithFirebaseId;
        _ref.read(loggerProvider).i('✅ New user created');
        _ref.read(debugLogsProvider.notifier).addLog('✅ New user created and set');
      } else {
        _ref.read(loggerProvider).i('👤 Loading existing user from Firestore...');
        _ref.read(debugLogsProvider.notifier).addLog('👤 Loading existing user: ${existing.firstName}');
        
        // Проверяем, нужно ли обновить данные пользователя
        bool needsUpdate = false;
        AppUser updatedUser = existing;
        
        // Обновляем firebaseId если его не было
        if (existing.firebaseId == null && _auth.currentUser != null) {
          updatedUser = updatedUser.copyWith(firebaseId: _auth.currentUser!.uid);
          needsUpdate = true;
          _ref.read(debugLogsProvider.notifier).addLog('📝 Will update Firebase ID');
        }
        
        // Логируем текущие данные для сравнения
        _ref.read(debugLogsProvider.notifier).addLog('🔍 Comparing user data:');
        _ref.read(debugLogsProvider.notifier).addLog('  - Existing photoUrl: "${existing.photoUrl}"');
        _ref.read(debugLogsProvider.notifier).addLog('  - New photoUrl: "${appUser.photoUrl}"');
        _ref.read(debugLogsProvider.notifier).addLog('  - PhotoUrl equal: ${existing.photoUrl == appUser.photoUrl}');
        
        // Обновляем данные из Telegram если они изменились
        if (existing.firstName != appUser.firstName ||
            existing.lastName != appUser.lastName ||
            existing.username != appUser.username ||
            existing.languageCode != appUser.languageCode ||
            existing.photoUrl != appUser.photoUrl) {
          
          _ref.read(debugLogsProvider.notifier).addLog('📝 Telegram data changed, updating user...');
          _ref.read(debugLogsProvider.notifier).addLog('  - firstName changed: ${existing.firstName} -> ${appUser.firstName}');
          _ref.read(debugLogsProvider.notifier).addLog('  - lastName changed: ${existing.lastName} -> ${appUser.lastName}');
          _ref.read(debugLogsProvider.notifier).addLog('  - photoUrl changed: ${existing.photoUrl} -> ${appUser.photoUrl}');
          
          updatedUser = updatedUser.copyWith(
            firstName: appUser.firstName,
            lastName: appUser.lastName,
            username: appUser.username,
            languageCode: appUser.languageCode,
            photoUrl: appUser.photoUrl,
            updatedAt: DateTime.now(),
          );
          needsUpdate = true;
        }
        
        if (needsUpdate) {
          await _userRepository.updateUser(updatedUser);
          finalUser = updatedUser;
          _ref.read(debugLogsProvider.notifier).addLog('✅ User data updated');
        } else {
          finalUser = existing;
          _ref.read(debugLogsProvider.notifier).addLog('✅ No updates needed');
        }
        
        _ref.read(loggerProvider).i('✅ Existing user loaded');
        _ref.read(debugLogsProvider.notifier).addLog('✅ Existing user loaded and set');
      }

      // Если пользователь админ, убеждаемся что документ в коллекции admins существует
      if (finalUser.isAdmin && finalUser.firebaseId != null) {
        await _ensureAdminDocumentExists(finalUser.firebaseId!, finalUser.id);
      }

      _ref.read(userProvider.notifier).setUser(finalUser);
      _ref.read(loggerProvider).i('🎉 Authentication flow completed successfully!');
      _ref.read(debugLogsProvider.notifier).addLog('🎉 Authentication completed!');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      _ref.read(loggerProvider).e('Automatic sign-in failed', error: e, stackTrace: st);
      _ref.read(debugLogsProvider.notifier).addLog('❌ Error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _ensureAdminDocumentExists(String firebaseId, int telegramId) async {
    try {
      _ref.read(debugLogsProvider.notifier).addLog('🔍 Checking admin document for: $firebaseId');
      
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(firebaseId)
          .get();
      
      if (!adminDoc.exists) {
        _ref.read(debugLogsProvider.notifier).addLog('📝 Creating admin document...');
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(firebaseId)
            .set({
          'telegramId': telegramId,
          'createdAt': DateTime.now().toIso8601String(),
        });
        _ref.read(debugLogsProvider.notifier).addLog('✅ Admin document created in admins collection');
      } else {
        _ref.read(debugLogsProvider.notifier).addLog('✅ Admin document already exists in admins collection');
      }
    } catch (e) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Error ensuring admin document: $e');
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _auth.signOut();
      _ref.read(userProvider.notifier).clearUser();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      _ref.read(loggerProvider).e('Error signing out', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
} 