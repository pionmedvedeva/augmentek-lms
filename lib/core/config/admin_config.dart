class AdminConfig {
  // Список Telegram-хендлов администраторов
  // Чтобы добавить админа, просто добавьте его username в этот список
  // Например: 'yasoda108i' (без символа @)
  static const List<String> adminUsernames = [
    'pionmedvedeva', // Пример, замените на свой username
  ];

  // Проверка, является ли пользователь админом
  static bool isAdmin(String? username) {
    if (username == null) return false;
    return adminUsernames.contains(username.toLowerCase());
  }
} 