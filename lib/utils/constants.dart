class AppConstants {
  // Use the production domain. The backend expects URLs without double slashes.
  static const String baseUrl = 'https://api.teploservis05.ru/api/v1';
  static const String wsBaseUrl = 'wss://api.teploservis05.ru/api/v1/sync/ws';
  
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
