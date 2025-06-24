import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:miniapp/features/home/presentation/screens/home_screen.dart';
import 'package:miniapp/features/auth/repositories/user_repository.dart';
import 'package:miniapp/features/course/repositories/course_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';

final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
  return firebase_auth.FirebaseAuth.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final sharedPreferencesProvider = StateProvider<SharedPreferences?>((ref) => null);

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instanceFor(region: 'us-central1');
});

final userRepositoryProvider = Provider<IUserRepository>((ref) {
  return UserRepository(ref.watch(firebaseFirestoreProvider), ref);
});

final courseRepositoryProvider = Provider<ICourseRepository>((ref) {
  return CourseRepository(ref.watch(firebaseFirestoreProvider));
});

Future<void> initializeDependencies() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer();
    container.read(sharedPreferencesProvider.notifier).state = prefs;
    Logger().i('Dependencies initialized successfully');
  } catch (e) {
    print('Error initializing dependencies: $e');
    rethrow;
  }
}

Future<void> disposeDependencies() async {
  try {
    final container = ProviderContainer();
    container.dispose();
    Logger().i('Dependencies disposed successfully');
  } catch (e, stack) {
    Logger().e('Error disposing dependencies', error: e, stackTrace: stack);
    rethrow;
  }
} 