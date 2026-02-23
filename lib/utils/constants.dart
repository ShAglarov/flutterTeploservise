class AppConstants {
  static const String baseUrl = 'https://api.teploservis05.ru/api/v1';
  static const String wsBaseUrl = 'wss://api.teploservis05.ru/api/v1/sync/ws';
  
  // Auth Endpoints
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
