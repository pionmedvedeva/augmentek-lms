import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:miniapp/core/config/admin_config.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required int id,
    required String firstName,
    String? lastName,
    String? username,
    String? languageCode,
    @Default(false) bool isAdmin,
    @Default({}) Map<String, dynamic> settings,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  static AppUser fromTelegramData(WebAppUser user) {
    final username = user.username;
    return AppUser(
      id: user.id,
      firstName: user.firstName ?? '',
      lastName: user.lastName,
      username: username,
      languageCode: user.languageCode,
      isAdmin: AdminConfig.isAdmin(username),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
} 