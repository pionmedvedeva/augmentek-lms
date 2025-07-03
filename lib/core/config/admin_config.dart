import 'package:miniapp/shared/models/user.dart';

// Test user for development purposes when running outside of Telegram
final mockUser = AppUser(
  id: 12345678,
  firebaseId: '12345678',
  firstName: 'Dev',
  lastName: 'User',
  username: 'dev_user',
  isAdmin: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

class AdminConfig {
  // Список Telegram ID администраторов
  // Чтобы добавить админа, просто добавьте его ID в этот список
  static const List<int> adminIds = [
    142170313, // Pion
    1286895675, //Sofa
    227243517, //Elza
    322888610, //Soifer
  ];

  // Проверка, является ли пользователь админом по ID
  static bool isAdmin(int userId) {
    return adminIds.contains(userId);
  }
} 