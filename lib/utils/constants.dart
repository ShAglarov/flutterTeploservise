class AppConstants {
  // ============================================================
  // Dynamic server URLs — обновляются при смене сервера
  // ============================================================
  
  /// Текущий baseUrl. По умолчанию дефолтный продакшн-сервер.
  /// Обновляется из ServerManager при инициализации и смене сервера.
  static String baseUrl = 'https://api.teploservis05.ru/api/v1';
  static String wsBaseUrl = 'wss://api.teploservis05.ru/api/v1/sync/ws';
  
  // Auth Endpoints (ensure they start with a slash)
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String heartbeat = '/auth/heartbeat';
  static const String logout = '/auth/logout';
  static const String currentUser = '/users/me';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userProfileKey = 'user_profile';
}

