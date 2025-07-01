import 'package:shared_preferences/shared_preferences.dart';
import 'app_logger.dart';

/// Сервис для сохранения и восстановления состояния навигации
/// Позволяет пользователю попадать на последнюю открытую страницу при перезагрузке
class NavigationStateService {
  static const String _lastRouteKey = 'last_route';
  static const String _routeParamsKey = 'route_params';
  static const String _lastVisitedKey = 'last_visited_timestamp';
  
  // Время жизни сохраненного маршрута (1 час)
  static const Duration _routeLifetime = Duration(hours: 1);

  /// Сохраняет текущий маршрут
  static Future<void> saveCurrentRoute(String route, {Map<String, String>? params}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(_lastRouteKey, route);
      await prefs.setInt(_lastVisitedKey, DateTime.now().millisecondsSinceEpoch);
      
      if (params != null && params.isNotEmpty) {
        // Сохраняем параметры в формате key1=value1&key2=value2
        final paramsString = params.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        await prefs.setString(_routeParamsKey, paramsString);
      } else {
        await prefs.remove(_routeParamsKey);
      }
      
      AppLogger.info('🧭 Navigation state saved: $route');
    } catch (e) {
      AppLogger.error('❌ Error saving navigation state: $e');
    }
  }

  /// Получает последний сохраненный маршрут
  static Future<String?> getLastRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final lastVisited = prefs.getInt(_lastVisitedKey);
      if (lastVisited == null) return null;
      
      final lastVisitedTime = DateTime.fromMillisecondsSinceEpoch(lastVisited);
      final now = DateTime.now();
      
      // Проверяем, не истек ли срок жизни маршрута
      if (now.difference(lastVisitedTime) > _routeLifetime) {
        AppLogger.info('🧭 Saved route expired, returning to home');
        await clearSavedRoute();
        return null;
      }
      
      final route = prefs.getString(_lastRouteKey);
      if (route != null) {
        AppLogger.info('🧭 Restored navigation state: $route');
      }
      
      return route;
    } catch (e) {
      AppLogger.error('❌ Error getting last route: $e');
      return null;
    }
  }

  /// Получает параметры последнего маршрута
  static Future<Map<String, String>?> getLastRouteParams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paramsString = prefs.getString(_routeParamsKey);
      
      if (paramsString == null || paramsString.isEmpty) return null;
      
      final params = <String, String>{};
      final pairs = paramsString.split('&');
      
      for (final pair in pairs) {
        final parts = pair.split('=');
        if (parts.length == 2) {
          final key = Uri.decodeComponent(parts[0]);
          final value = Uri.decodeComponent(parts[1]);
          params[key] = value;
        }
      }
      
      return params.isNotEmpty ? params : null;
    } catch (e) {
      AppLogger.error('❌ Error getting last route params: $e');
      return null;
    }
  }

  /// Очищает сохраненное состояние навигации
  static Future<void> clearSavedRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastRouteKey);
      await prefs.remove(_routeParamsKey);
      await prefs.remove(_lastVisitedKey);
      
      AppLogger.info('🧭 Navigation state cleared');
    } catch (e) {
      AppLogger.error('❌ Error clearing navigation state: $e');
    }
  }

  /// Проверяет, нужно ли сохранять данный маршрут
  static bool shouldSaveRoute(String route) {
    // Не сохраняем некоторые маршруты
    const excludedRoutes = [
      '/',
      '/login',
      '/error',
    ];
    
    // Не сохраняем маршруты с временными параметрами
    if (route.contains('temp=') || route.contains('redirect=')) {
      return false;
    }
    
    return !excludedRoutes.contains(route);
  }

  /// Создает полный URL с параметрами
  static String buildRouteWithParams(String route, Map<String, String>? params) {
    if (params == null || params.isEmpty) return route;
    
    final uri = Uri.parse(route);
    final newParams = Map<String, String>.from(uri.queryParameters);
    newParams.addAll(params);
    
    return uri.replace(queryParameters: newParams).toString();
  }
} 