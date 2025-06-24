import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:miniapp/core/config/admin_config.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required int id,
    String? firebaseId,
    required String firstName,
    String? lastName,
    String? username,
    String? languageCode,
    String? photoUrl,
    @Default(false) bool isAdmin,
    @Default({}) Map<String, dynamic> settings,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  static AppUser fromTelegramData(WebAppUser user) {
    return AppUser(
      id: user.id,
      firebaseId: user.id.toString(),
      firstName: user.firstName ?? '',
      lastName: user.lastName,
      username: user.username,
      languageCode: user.languageCode,
      photoUrl: user.photoUrl,
      isAdmin: AdminConfig.isAdmin(user.id),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
} 