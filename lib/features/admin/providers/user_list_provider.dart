import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miniapp/shared/models/user.dart';

class UserListNotifier extends StateNotifier<AsyncValue<List<AppUser>>> {
  UserListNotifier() : super(const AsyncValue.loading()) {
    loadUsers();
  }

  final _firestore = FirebaseFirestore.instance;

  Future<void> loadUsers() async {
    try {
      state = const AsyncValue.loading();
      
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      final users = snapshot.docs
          .map((doc) => AppUser.fromJson({
                ...doc.data(),
                'id': int.parse(doc.id),
              }))
          .toList();

      state = AsyncValue.data(users);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<AppUser?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return AppUser.fromJson({
          ...doc.data()!,
          'id': int.parse(doc.id),
        });
      }
      return null;
    } catch (error) {
      throw Exception('Ошибка получения пользователя: $error');
    }
  }

  Future<void> updateUserAdminStatus(String userId, bool isAdmin) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
            'isAdmin': isAdmin,
            'updatedAt': DateTime.now().toIso8601String(),
          });
      
      await loadUsers();
    } catch (error) {
      throw Exception('Ошибка обновления статуса администратора: $error');
    }
  }

  List<AppUser> getAdminUsers() {
    final currentState = state.value;
    if (currentState != null) {
      return currentState.where((user) => user.isAdmin).toList();
    }
    return [];
  }

  List<AppUser> getRegularUsers() {
    final currentState = state.value;
    if (currentState != null) {
      return currentState.where((user) => !user.isAdmin).toList();
    }
    return [];
  }
}

final userListProvider = StateNotifierProvider<UserListNotifier, AsyncValue<List<AppUser>>>(
  (ref) => UserListNotifier(),
);

// Provider для получения конкретного пользователя по ID
final userProfileProvider = FutureProvider.family<AppUser?, int>((ref, userId) async {
  final userListNotifier = ref.read(userListProvider.notifier);
  return await userListNotifier.getUserById(userId.toString());
});

 