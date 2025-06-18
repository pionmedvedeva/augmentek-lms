import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../../../shared/models/user.dart';

final logger = Logger();

final settingsProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<UserSettings>>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AsyncValue<UserSettings>> {
  SettingsNotifier() : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = UserSettings(
        theme: prefs.getString('theme') ?? 'system',
        language: prefs.getString('language') ?? 'en',
        notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
        autoPlayEnabled: prefs.getBool('autoplay_enabled') ?? true,
        downloadQuality: prefs.getString('download_quality') ?? 'high',
      );
      state = AsyncValue.data(settings);
      logger.i('Settings initialized: $settings');
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      logger.e('Error initializing settings', e, stack);
    }
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    try {
      state = const AsyncValue.loading();
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('theme', newSettings.theme);
      await prefs.setString('language', newSettings.language);
      await prefs.setBool('notifications_enabled', newSettings.notificationsEnabled);
      await prefs.setBool('autoplay_enabled', newSettings.autoPlayEnabled);
      await prefs.setString('download_quality', newSettings.downloadQuality);
      
      state = AsyncValue.data(newSettings);
      logger.i('Settings updated: $newSettings');
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      logger.e('Error updating settings', e, stack);
      rethrow;
    }
  }

  Future<void> resetSettings() async {
    try {
      state = const AsyncValue.loading();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      final defaultSettings = UserSettings(
        theme: 'system',
        language: 'en',
        notificationsEnabled: true,
        autoPlayEnabled: true,
        downloadQuality: 'high',
      );
      
      state = AsyncValue.data(defaultSettings);
      logger.i('Settings reset to defaults');
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      logger.e('Error resetting settings', e, stack);
      rethrow;
    }
  }
}

class UserSettings {
  final String theme;
  final String language;
  final bool notificationsEnabled;
  final bool autoPlayEnabled;
  final String downloadQuality;

  const UserSettings({
    required this.theme,
    required this.language,
    required this.notificationsEnabled,
    required this.autoPlayEnabled,
    required this.downloadQuality,
  });

  UserSettings copyWith({
    String? theme,
    String? language,
    bool? notificationsEnabled,
    bool? autoPlayEnabled,
    String? downloadQuality,
  }) {
    return UserSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoPlayEnabled: autoPlayEnabled ?? this.autoPlayEnabled,
      downloadQuality: downloadQuality ?? this.downloadQuality,
    );
  }

  @override
  String toString() {
    return 'UserSettings(theme: $theme, language: $language, notificationsEnabled: $notificationsEnabled, autoPlayEnabled: $autoPlayEnabled, downloadQuality: $downloadQuality)';
  }
} 