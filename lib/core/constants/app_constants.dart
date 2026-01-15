class AppConstants {
  // API Configuration
  static const String apiTimeout = 'API_TIMEOUT';
  static const int defaultTimeout = 30000; // 30 seconds

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String isLoggedInKey = 'is_logged_in';

  // Error Messages
  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';

  // Private constructor to prevent instantiation
  AppConstants._();
}
