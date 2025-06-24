import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miniapp/shared/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/shared/widgets/debug_log_screen.dart';
import 'package:miniapp/core/di/di.dart';

abstract class IUserRepository {
  Future<AppUser?> getUser(int userId);
  Future<AppUser?> getUserByFirebaseUid(String firebaseUid);
  Future<void> createUser(AppUser user);
  Future<void> createUserWithFirebaseUid(String firebaseUid, AppUser user);
  Future<void> updateUser(AppUser user);
  Future<List<AppUser>> getUsers();
}

class UserRepository implements IUserRepository {
  UserRepository(this._firestore, this._ref);

  final FirebaseFirestore _firestore;
  final Ref _ref;

  CollectionReference<AppUser> get _usersCollection =>
      _firestore.collection('users').withConverter<AppUser>(
            fromFirestore: (snapshot, _) {
              try {
                final data = snapshot.data();
                if (data == null) {
                  throw Exception('Document data is null');
                }
                
                // Безопасное создание объекта с проверкой типов
                return AppUser.fromJson({
                  'id': data['id'] ?? 0,
                  'firebaseId': data['firebaseId'],
                  'firstName': data['firstName'] ?? '',
                  'lastName': data['lastName'],
                  'username': data['username'],
                  'languageCode': data['languageCode'],
                  'photoUrl': data['photoUrl'],
                  'isAdmin': data['isAdmin'] ?? false,
                  'settings': data['settings'] ?? {},
                  'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
                  'updatedAt': data['updatedAt'] ?? DateTime.now().toIso8601String(),
                });
              } catch (e) {
                throw Exception('Error parsing user document: $e');
              }
            },
            toFirestore: (user, _) => user.toJson(),
          );

  @override
  Future<AppUser?> getUser(int userId) async {
    try {
      _ref.read(debugLogsProvider.notifier).addLog('🔍 Querying Firestore for user: $userId');
      final snapshot = await _usersCollection.doc(userId.toString()).get();
      _ref.read(debugLogsProvider.notifier).addLog('📡 Firestore query completed');
      final user = snapshot.data();
      if (user != null) {
        _ref.read(debugLogsProvider.notifier).addLog('📄 User document found in Firestore');
      } else {
        _ref.read(debugLogsProvider.notifier).addLog('📄 User document not found in Firestore');
      }
      _ref.read(debugLogsProvider.notifier).addLog('🔄 Returning from getUser method');
      return user;
    } catch (e) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Firestore query error: $e');
      print(e);
      // НЕ возвращаем null, а выбрасываем исключение, чтобы увидеть проблему
      rethrow;
    }
  }

  @override
  Future<AppUser?> getUserByFirebaseUid(String firebaseUid) async {
    try {
      _ref.read(debugLogsProvider.notifier).addLog('🔍 Querying Firestore for Firebase UID: $firebaseUid');
      final snapshot = await _usersCollection.doc(firebaseUid).get();
      final user = snapshot.data();
      if (user != null) {
        _ref.read(debugLogsProvider.notifier).addLog('📄 User document found by Firebase UID');
      } else {
        _ref.read(debugLogsProvider.notifier).addLog('📄 User document not found by Firebase UID');
      }
      return user;
    } catch (e) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Firestore query by Firebase UID error: $e');
      print(e);
      return null;
    }
  }

  @override
  Future<void> createUser(AppUser user) async {
    try {
      _ref.read(debugLogsProvider.notifier).addLog('💾 Creating user in Firestore: ${user.firstName}');
      await _usersCollection.doc(user.id.toString()).set(user);
      _ref.read(debugLogsProvider.notifier).addLog('✅ User created successfully in Firestore');

      // Если пользователь админ, создаем документ в коллекции admins для правил Firestore
      if (user.isAdmin && user.firebaseId != null) {
        await _firestore
            .collection('admins')
            .doc(user.firebaseId!)
            .set({
          'telegramId': user.id,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Create user error: $e');
      print(e);
    }
  }

  @override
  Future<void> createUserWithFirebaseUid(String firebaseUid, AppUser user) async {
    try {
      _ref.read(debugLogsProvider.notifier).addLog('💾 Creating user with Firebase UID: ${user.firstName}');
      await _usersCollection.doc(firebaseUid).set(user);
      _ref.read(debugLogsProvider.notifier).addLog('✅ User created successfully with Firebase UID');
    } catch (e) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Create user with Firebase UID error: $e');
      print(e);
    }
  }

  @override
  Future<void> updateUser(AppUser user) async {
    try {
      _ref.read(debugLogsProvider.notifier).addLog('💾 Updating user in Firestore: ${user.firstName}');
      _ref.read(debugLogsProvider.notifier).addLog('  - PhotoUrl: ${user.photoUrl}');
      await _usersCollection.doc(user.id.toString()).set(user, SetOptions(merge: true));
      _ref.read(debugLogsProvider.notifier).addLog('✅ User updated successfully in Firestore');
    } catch (e) {
      _ref.read(debugLogsProvider.notifier).addLog('❌ Update user error: $e');
      print(e);
    }
  }

  @override
  Future<List<AppUser>> getUsers() async {
    try {
      final snapshot = await _usersCollection.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      // TODO: Add logging
      print(e);
      return [];
    }
  }
} 