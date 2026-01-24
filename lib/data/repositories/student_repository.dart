import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:me_plus/core/constants/api_constants.dart';
import 'package:me_plus/data/services/token_storage_service.dart';
import 'package:me_plus/core/services/debug_log_service.dart';
import 'package:me_plus/data/models/student_profile.dart';
import 'package:me_plus/data/models/behavior_model.dart';
import 'package:me_plus/data/models/behavior_streak_model.dart';
import 'package:me_plus/data/models/store_model.dart';
import 'package:me_plus/data/models/activity_model.dart';
import 'package:me_plus/core/services/translation_service.dart';

class StudentRepository {
  final TokenStorageService _tokenStorage = TokenStorageService();
  final TranslationService _translationService = TranslationService();
  final http.Client _client = http.Client();
  final DebugLogService _debugLog = DebugLogService();
  
  static const Duration _timeout = Duration(seconds: 20);

  /// Get headers with Bearer token - Same pattern as AuthService
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenStorage.getToken();
    
    // Log to UI debug screen
    _debugLog.logToken(token);
    debugPrint('🔑 [StudentRepo] Token from iOS Keychain: ${token != null ? 'EXISTS' : 'NULL'}');
    if (token != null && token.length > 20) {
      debugPrint('🔑 [StudentRepo] Token preview: ${token.substring(0, 20)}... (length: ${token.length})');
    } else {
      debugPrint('🚨 [StudentRepo] WARNING: Token is null or too short: $token');
      _debugLog.logError('Token is null or invalid');
    }
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  /// Handle HTTP response - Same pattern as AuthService
  dynamic _handleResponse(http.Response response, {String operation = 'Request'}) {
    debugPrint('📡 [$operation] Status: ${response.statusCode}');
    _debugLog.logApiCall(operation, response.statusCode);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        debugPrint('⚠️ [$operation] Response not JSON: ${response.body}');
        return response.body;
      }
    } else {
      String error = '$operation فشل';
      try {
        final data = jsonDecode(response.body);
        if (data is Map) {
          error = data['message'] ?? data['error'] ?? error;
        }
      } catch (_) {
        if (response.body.isNotEmpty) error = response.body;
      }
      throw Exception(error);
    }
  }

  // ==================== Profile ====================
  Future<StudentProfile> getProfile() async {
    debugPrint('📱 [GetProfile] Starting...');
    _debugLog.logInfo('GetProfile: Starting API call...');
    final url = '${ApiConstants.baseUrl}/api/me';
    final headers = await _getHeaders();
    
    debugPrint('📡 [GetProfile] URL: $url');
    debugPrint('📡 [GetProfile] Headers: $headers');
    _debugLog.logInfo('GetProfile: URL = /api/me');
    
    final response = await _client.get(
      Uri.parse(url),
      headers: headers,
    ).timeout(_timeout);
    
    final data = _handleResponse(response, operation: 'GetProfile');
    return StudentProfile.fromJson(data);
  }

  Future<StudentProfile> updateProfile(Map<String, dynamic> data) async {
    final url = '${ApiConstants.baseUrl}/api/me';
    final headers = await _getHeaders();
    
    await _client.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(data),
    ).timeout(_timeout);

    return await getProfile();
  }

  // ==================== Behavior ====================
  Future<BehaviorStreakResponse> getBehaviorStreak() async {
    final url = '${ApiConstants.baseUrl}/api/behavior-streak';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetBehaviorStreak');
    return BehaviorStreakResponse.fromJson(data);
  }

  Future<Map<String, dynamic>> claimBehaviorReward() async {
    final url = '${ApiConstants.baseUrl}/api/behavior-streak/claim-reward';
    final headers = await _getHeaders();
    final response = await _client.post(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'ClaimBehaviorReward');
    return data as Map<String, dynamic>;
  }

  Future<List<WeekDetailBehavior>> getWeekDetails(int weekNumber) async {
    final url = '${ApiConstants.baseUrl}/api/behavior-streak/weeks/$weekNumber';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetWeekDetails');
    return (data as List)
        .map((item) => WeekDetailBehavior.fromJson(item))
        .toList();
  }

  Future<List<BehaviorWeek>> getBehaviorThisMonth({
    required int schoolId,
    required int classId,
    required int childId,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    final url = '${ApiConstants.baseUrl}/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/this-month?pageSize=$pageSize&pageNumber=$pageNumber';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetBehaviorThisMonth');

    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List)
          .map((week) => BehaviorWeek.fromJson(week))
          .toList();
    } else if (data is List) {
      return data.map((week) => BehaviorWeek.fromJson(week)).toList();
    }
    return [];
  }

  Future<BehaviorReport> getBehaviorReport({
    required int schoolId,
    required int classId,
    required int childId,
    required DateTime date,
  }) async {
    final dateStr = '${date.year}-${date.month}-${date.day}';
    final url = '${ApiConstants.baseUrl}/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/report?date=$dateStr';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetBehaviorReport');
    return BehaviorReport.fromJson(data);
  }

  Future<List<DateTime>> getStartOfWeeks({
    required int schoolId,
    required int classId,
    required int childId,
  }) async {
    final url = '${ApiConstants.baseUrl}/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/start-of-weeks';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetStartOfWeeks');

    final dates =
        (data as List?)
            ?.map((date) => DateTime.parse(date.toString()))
            .toList() ??
        [];

    return dates;
  }

  Future<List<BehaviorDetail>> getBehaviorByDay({
    required DateTime date,
  }) async {
    final dateStr = '${date.year}-${date.month}-${date.day}';
    final url = '${ApiConstants.baseUrl}/api/behaviors?date=$dateStr';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetBehaviorByDay');

    if (data is List) {
      return data
          .map((behavior) => BehaviorDetail.fromJson(behavior))
          .toList();
    }
    return [];
  }

  // ==================== Store ====================
  Future<List<StoreReward>> getStoreRewards({
    required int schoolId,
    required int classId,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    final url = '${ApiConstants.baseUrl}/api/schools/$schoolId/classes/$classId/store?pageSize=$pageSize&pageNumber=$pageNumber';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetStoreRewards');

    if (data is Map && data.containsKey('items')) {
      final items = (data['items'] as List)
          .map((reward) => StoreReward.fromJson(reward))
          .toList();
      return items;
    } else if (data is Map && data.containsKey('data')) {
      final items = (data['data'] as List)
          .map((reward) => StoreReward.fromJson(reward))
          .toList();
      return items;
    } else if (data is List) {
      final items = data.map((reward) => StoreReward.fromJson(reward)).toList();
      return items;
    }
    return [];
  }

  Future<void> purchaseReward({
    required int schoolId,
    required int classId,
    required int studentId,
    required int rewardId,
  }) async {
    final url = '${ApiConstants.baseUrl}/api/schools/$schoolId/classes/$classId/students/$studentId/store/$rewardId/purchase';
    final headers = await _getHeaders();
    await _client.post(Uri.parse(url), headers: headers).timeout(_timeout);
  }

  Future<void> confirmPurchaseReceived({
    required int studentId,
    required int purchaseId,
  }) async {
    final url = '${ApiConstants.baseUrl}/api/students/$studentId/purchases/$purchaseId/confirmation';
    final headers = await _getHeaders();
    await _client.post(Uri.parse(url), headers: headers).timeout(_timeout);
  }

  Future<List<Purchase>> getStudentPurchases({
    required int schoolId,
    required int classId,
    required int studentId,
  }) async {
    final url = '${ApiConstants.baseUrl}/api/schools/$schoolId/classes/$classId/students/$studentId/purchases';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetStudentPurchases');

    if (data is List) {
      return data
          .map((purchase) => Purchase.fromJson(purchase))
          .toList();
    }
    return [];
  }

  Future<List<Purchase>> getPurchasesThisMonth({
    required int schoolId,
    required int classId,
    required int studentId,
    int pageSize = 10,
    int pageNumber = 1,
  }) async {
    final url = '${ApiConstants.baseUrl}/api/schools/$schoolId/classes/$classId/students/$studentId/purchases/this-month?pageSize=$pageSize&pageNumber=$pageNumber';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetPurchasesThisMonth');

    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List)
          .map((purchase) => Purchase.fromJson(purchase))
          .toList();
    } else if (data is List) {
      return data.map((purchase) => Purchase.fromJson(purchase)).toList();
    }
    return [];
  }

  Future<List<Purchase>> getAllPurchases({
    required int schoolId,
    required int classId,
    required int studentId,
  }) async {
    final url = '${ApiConstants.baseUrl}/api/schools/$schoolId/classes/$classId/students/$studentId/purchases';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetAllPurchases');

    if (data is Map && data.containsKey('items')) {
      return (data['items'] as List)
          .map((purchase) => Purchase.fromJson(purchase))
          .toList();
    } else if (data is Map && data.containsKey('data')) {
      return (data['data'] as List)
          .map((purchase) => Purchase.fromJson(purchase))
          .toList();
    } else if (data is List) {
      return data.map((purchase) => Purchase.fromJson(purchase)).toList();
    }
    return [];
  }

  // ==================== Activity ====================
  Future<List<BehaviorDate>> getActivity({
    required String date,
  }) async {
    final url = '${ApiConstants.baseUrl}/api/activity?date=$date';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetActivity');

    if (data is Map && data.containsKey('dates')) {
      return (data['dates'] as List)
          .map((item) => BehaviorDate.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<List<Activity>> getBehaviorsByDay({
    required String date,
  }) async {
    final url = '${ApiConstants.baseUrl}/api/behaviors?date=$date';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetBehaviorsByDay');

    List<Activity> activities = [];

    if (data is Map && data.containsKey('items')) {
      activities = (data['items'] as List)
          .map((item) => Activity.fromJson(item))
          .toList();
    } else if (data is Map && data.containsKey('data')) {
      activities = (data['data'] as List)
          .map((item) => Activity.fromJson(item))
          .toList();
    } else if (data is List) {
      activities = data.map((item) => Activity.fromJson(item)).toList();
    }

    final translatedActivities = <Activity>[];
    for (var activity in activities) {
      translatedActivities.add(await _autoTranslateActivity(activity));
    }

    return translatedActivities;
  }

  Future<Activity> _autoTranslateActivity(Activity activity) async {
    String? titleAr = activity.titleAr;
    String? titleEn = activity.titleEn;
    String? descriptionAr = activity.descriptionAr;
    String? descriptionEn = activity.descriptionEn;

    if (titleAr == null && titleEn == null) {
      final detectedLang = _translationService.detectLanguage(activity.title);
      if (detectedLang == 'ar') {
        titleAr = activity.title;
        titleEn = await _translationService.translateToEnglish(activity.title);
      } else {
        titleEn = activity.title;
        titleAr = await _translationService.translateToArabic(activity.title);
      }
    } else if (titleAr == null && titleEn != null) {
      titleAr = await _translationService.translateToArabic(titleEn);
    } else if (titleEn == null && titleAr != null) {
      titleEn = await _translationService.translateToEnglish(titleAr);
    }

    if (descriptionAr == null && descriptionEn == null) {
      final detectedLang = _translationService.detectLanguage(
        activity.description,
      );
      if (detectedLang == 'ar') {
        descriptionAr = activity.description;
        descriptionEn = await _translationService.translateToEnglish(
          activity.description,
        );
      } else {
        descriptionEn = activity.description;
        descriptionAr = await _translationService.translateToArabic(
          activity.description,
        );
      }
    } else if (descriptionAr == null && descriptionEn != null) {
      descriptionAr = await _translationService.translateToArabic(
        descriptionEn,
      );
    } else if (descriptionEn == null && descriptionAr != null) {
      descriptionEn = await _translationService.translateToEnglish(
        descriptionAr,
      );
    }

    return activity.copyWith(
      titleAr: titleAr,
      titleEn: titleEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
    );
  }

  // ==================== Report Missing Reward ====================
  Future<void> reportMissingReward({
    required int schoolId,
    required int classId,
    required int studentId,
    required int purchaseId,
    required String reportDetails,
  }) async {
    final url = '${ApiConstants.baseUrl}/api/schools/$schoolId/classes/$classId/students/$studentId/purchases/$purchaseId/report-missing-reward';
    final headers = await _getHeaders();
    await _client.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({'ReportDetails': reportDetails}),
    ).timeout(_timeout);
  }

  // ==================== Honor List ====================
  Future<List<HonorListStudent>> getHonorList() async {
    final url = '${ApiConstants.baseUrl}/api/honor-list';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetHonorList');

    if (data is List) {
      return data
          .map((student) => HonorListStudent.fromJson(student))
          .toList();
    }
    return [];
  }

  // ==================== Notifications ====================
  Future<List<NotificationModel>> getNotifications() async {
    final url = '${ApiConstants.baseUrl}/api/notifications';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetNotifications');

    if (data is List) {
      final notifications = data
          .map((notification) => NotificationModel.fromJson(notification))
          .toList();

      final translatedNotifications = <NotificationModel>[];
      for (var notification in notifications) {
        translatedNotifications.add(
          await _autoTranslateNotification(notification),
        );
      }

      return translatedNotifications;
    }
    return [];
  }

  Future<NotificationModel> _autoTranslateNotification(
    NotificationModel notification,
  ) async {
    String? titleAr = notification.titleAr;
    String? titleEn = notification.titleEn;
    String? messageAr = notification.messageAr;
    String? messageEn = notification.messageEn;

    if (titleAr == null && titleEn == null && notification.title.isNotEmpty) {
      final detectedLang = _translationService.detectLanguage(
        notification.title,
      );
      if (detectedLang == 'ar') {
        titleAr = notification.title;
        titleEn = await _translationService.translateToEnglish(
          notification.title,
        );
      } else {
        titleEn = notification.title;
        titleAr = await _translationService.translateToArabic(
          notification.title,
        );
      }
    } else if (titleAr == null && titleEn != null) {
      titleAr = await _translationService.translateToArabic(titleEn);
    } else if (titleEn == null && titleAr != null) {
      titleEn = await _translationService.translateToEnglish(titleAr);
    }

    if (messageAr == null &&
        messageEn == null &&
        notification.message.isNotEmpty) {
      final detectedLang = _translationService.detectLanguage(
        notification.message,
      );
      if (detectedLang == 'ar') {
        messageAr = notification.message;
        messageEn = await _smartTranslateMessage(
          notification.message,
          'ar',
          'en',
        );
      } else {
        messageEn = notification.message;
        messageAr = await _smartTranslateMessage(
          notification.message,
          'en',
          'ar',
        );
      }
    } else if (messageAr == null && messageEn != null) {
      messageAr = await _smartTranslateMessage(messageEn, 'en', 'ar');
    } else if (messageEn == null && messageAr != null) {
      messageEn = await _smartTranslateMessage(messageAr, 'ar', 'en');
    }

    return notification.copyWith(
      titleAr: titleAr,
      titleEn: titleEn,
      messageAr: messageAr,
      messageEn: messageEn,
    );
  }

  Future<String> _smartTranslateMessage(
    String message,
    String fromLang,
    String toLang,
  ) async {
    final orderPattern = RegExp(r'^(.+?)\s+has been ordered from\s+(.+)$');
    final orderMatch = orderPattern.firstMatch(message);

    if (orderMatch != null) {
      final itemName = orderMatch.group(1)?.trim() ?? '';
      final studentName = orderMatch.group(2)?.trim() ?? '';

      if (toLang == 'ar') {
        return 'لقد تم طلب $itemName من قبل $studentName';
      }
    }

    final requestPattern = RegExp(
      r'You requested a\s+(.+?),\s*Did you receive it\??',
      caseSensitive: false,
    );
    final requestMatch = requestPattern.firstMatch(message);

    if (requestMatch != null) {
      final itemName = requestMatch.group(1)?.trim() ?? '';

      if (toLang == 'ar') {
        return 'لقد طلبت $itemName، هل استلمتها؟';
      }
    }

    final arabicOrderPattern = RegExp(r'لقد تم طلب\s+(.+?)\s+من قبل\s+(.+)$');
    final arabicOrderMatch = arabicOrderPattern.firstMatch(message);

    if (arabicOrderMatch != null && toLang == 'en') {
      final itemName = arabicOrderMatch.group(1)?.trim() ?? '';
      final studentName = arabicOrderMatch.group(2)?.trim() ?? '';
      return '$itemName has been ordered from $studentName';
    }

    final arabicRequestPattern = RegExp(r'لقد طلبت\s+(.+?)،\s*هل استلمتها؟');
    final arabicRequestMatch = arabicRequestPattern.firstMatch(message);

    if (arabicRequestMatch != null && toLang == 'en') {
      final itemName = arabicRequestMatch.group(1)?.trim() ?? '';
      return 'You requested a $itemName, Did you receive it?';
    }

    if (toLang == 'ar') {
      return await _translationService.translateToArabic(message);
    } else {
      return await _translationService.translateToEnglish(message);
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    final url = '${ApiConstants.baseUrl}/api/notifications/mark-as-read/$notificationId';
    final headers = await _getHeaders();
    await _client.post(Uri.parse(url), headers: headers).timeout(_timeout);
  }

  Future<void> deleteNotification(int notificationId) async {
    final url = '${ApiConstants.baseUrl}/api/notifications/$notificationId';
    final headers = await _getHeaders();
    await _client.delete(Uri.parse(url), headers: headers).timeout(_timeout);
  }

  Future<Map<String, dynamic>> getNotificationSettings() async {
    final url = '${ApiConstants.baseUrl}/api/notification_settings';
    final headers = await _getHeaders();
    final response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    final data = _handleResponse(response, operation: 'GetNotificationSettings');
    return data as Map<String, dynamic>;
  }
}