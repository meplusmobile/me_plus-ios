class ApiConstants {
  // Base URL
  static const String baseUrl =
      'https://meplus3-hjfehnfpfyg2gyau.israelcentral-01.azurewebsites.net';

  // Auth Endpoints
  static const String signup = '/signup';
  static const String login = '/login';
  static const String googleLogin = '/google-login';
  static const String googleSignup = '/google-signup';
  static const String forgetPassword = '/forget-password';
  static const String validateResetCode = '/validate-reset-code';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String checkToken = '/check';

  // User Endpoints
  static const String profile = '/api/me';
  static const String updateProfile = '/api/me';

  // School Endpoints
  static const String schools = '/api/schools';
  static const String schoolInfo = '/api/school_info';

  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
