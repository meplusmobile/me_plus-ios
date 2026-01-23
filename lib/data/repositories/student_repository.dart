import 'package:me_plus/data/services/api_service.dart';
import 'package:me_plus/data/models/student_profile.dart';
import 'package:me_plus/data/models/behavior_model.dart';
import 'package:me_plus/data/models/behavior_streak_model.dart';
import 'package:me_plus/data/models/store_model.dart';
import 'package:me_plus/data/models/activity_model.dart';
import 'package:me_plus/core/services/translation_service.dart';

class StudentRepository {
  final ApiService _apiService = ApiService();
  final TranslationService _translationService = TranslationService();

  // ==================== Profile ====================
  Future<StudentProfile> getProfile() async {
    final response = await _apiService.get('/student/profile');
    return StudentProfile.fromJson(response.data);
  }

  // Update profile - FIXED: استخدام isMultipart بدل isFormData
  Future<StudentProfile> updateProfile(Map<String, dynamic> data) async {
    // Send update request with multipart flag
    await _apiService.put(
      '/api/me', 
      data: data, 
      isMultipart: true,  // ✅ FIXED: استخدام isMultipart
    );

    // Fetch full profile data from /student/profile endpoint
    final profileResponse = await _apiService.get('/student/profile');
    return StudentProfile.fromJson(profileResponse.data);
  }

  // ==================== Behavior ====================
  Future<BehaviorStreakResponse> getBehaviorStreak() async {
    final response = await _apiService.get('/api/behavior-streak');
    return BehaviorStreakResponse.fromJson(response.data);
  }

  Future<Map<String, dynamic>> claimBehaviorReward() async {
    final response = await _apiService.post(
      '/api/behavior-streak/claim-reward',
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<WeekDetailBehavior>> getWeekDetails(int weekNumber) async {
    final response = await _apiService.get(
      '/api/behavior-streak/weeks/$weekNumber',
    );
    return (response.data as List)
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
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/this-month',
      queryParameters: {'pageSize': pageSize, 'pageNumber': pageNumber},
    );

    final data = response.data;
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
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/report',
      queryParameters: {'date': '${date.year}-${date.month}-${date.day}'},
    );
    return BehaviorReport.fromJson(response.data);
  }

  Future<List<DateTime>> getStartOfWeeks({
    required int schoolId,
    required int classId,
    required int childId,
  }) async {
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/start-of-weeks',
    );

    final dates =
        (response.data as List?)
            ?.map((date) => DateTime.parse(date.toString()))
            .toList() ??
        [];

    return dates;
  }

  Future<List<BehaviorDetail>> getBehaviorByDay({
    required DateTime date,
  }) async {
    final response = await _apiService.get(
      '/api/behaviors',
      queryParameters: {'date': '${date.year}-${date.month}-${date.day}'},
    );

    if (response.data is List) {
      return (response.data as List)
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
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/store',
      queryParameters: {'pageSize': pageSize, 'pageNumber': pageNumber},
    );

    final data = response.data;
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
    await _apiService.post(
      '/api/schools/$schoolId/classes/$classId/students/$studentId/store/$rewardId/purchase',
    );
  }

  Future<void> confirmPurchaseReceived({
    required int studentId,
    required int purchaseId,
  }) async {
    await _apiService.post(
      '/api/students/$studentId/purchases/$purchaseId/confirmation',
    );
  }

  Future<List<Purchase>> getStudentPurchases({
    required int schoolId,
    required int classId,
    required int studentId,
  }) async {
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/students/$studentId/purchases',
    );

    if (response.data is List) {
      return (response.data as List)
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
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/students/$studentId/purchases/this-month',
      queryParameters: {'pageSize': pageSize, 'pageNumber': pageNumber},
    );

    final data = response.data;
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
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/students/$studentId/purchases',
    );

    final data = response.data;
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
    final response = await _apiService.get(
      '/api/activity',
      queryParameters: {'date': date},
    );

    final data = response.data;
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
    final response = await _apiService.get(
      '/api/behaviors',
      queryParameters: {'date': date},
    );

    final data = response.data;
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
    await _apiService.post(
      '/api/schools/$schoolId/classes/$classId/students/$studentId/purchases/$purchaseId/report-missing-reward',
      data: {'ReportDetails': reportDetails},
    );
  }

  // ==================== Honor List ====================
  Future<List<HonorListStudent>> getHonorList() async {
    final response = await _apiService.get('/api/honor-list');

    if (response.data is List) {
      return (response.data as List)
          .map((student) => HonorListStudent.fromJson(student))
          .toList();
    }
    return [];
  }

  // ==================== Notifications ====================
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiService.get('/api/notifications');

    if (response.data is List) {
      final notifications = (response.data as List)
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
    await _apiService.post('/api/notifications/mark-as-read/$notificationId');
  }

  Future<void> deleteNotification(int notificationId) async {
    await _apiService.delete('/api/notifications/$notificationId');
  }

  Future<Map<String, dynamic>> getNotificationSettings() async {
    final response = await _apiService.get('/api/notification_settings');
    return response.data as Map<String, dynamic>;
  }
}