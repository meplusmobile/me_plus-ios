import 'package:flutter/foundation.dart';
import 'package:me_plus/data/services/api_service.dart';
import 'package:me_plus/data/models/user_profile.dart';
import 'package:me_plus/data/models/activity_model.dart';
import 'package:me_plus/data/models/store_model.dart';
import 'package:me_plus/data/models/child_model.dart';
import 'package:me_plus/data/models/behavior_model.dart';
import 'package:me_plus/data/models/child_reward_model.dart';
import 'package:me_plus/core/services/translation_service.dart';

class ParentRepository {
  final ApiService _apiService = ApiService();
  final TranslationService _translationService = TranslationService();

  // Get all children for the parent
  Future<List<Child>> getChildren() async {
    final response = await _apiService.get('/parent/children');
    
    if (!response.success) {
      debugPrint('Failed to get children: ${response.error}');
      return [];
    }

    if (response.data is List) {
      return (response.data as List)
          .map((child) => Child.fromJson(child))
          .toList();
    }
    return [];
  }

  // Get waiting children (pending approval)
  Future<List<Child>> getWaitingChildren() async {
    final response = await _apiService.get('/parent/waiting-children');
    
    if (!response.success) {
      debugPrint('Failed to get waiting children: ${response.error}');
      return [];
    }

    if (response.data is List) {
      return (response.data as List)
          .map((child) => Child.fromJson(child))
          .toList();
    }
    return [];
  }

  // Get child activity for a specific month (calendar markers)
  Future<List<BehaviorDate>> getChildActivity({
    required int schoolId,
    required int classId,
    required String childId,
    required String date, // Format: "YYYY-MM"
  }) async {
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/childs/$childId/activity?date=$date',
    );

    if (!response.success) {
      debugPrint('Failed to get child activity: ${response.error}');
      return [];
    }

    if (response.data != null && response.data['dates'] is List) {
      return (response.data['dates'] as List)
          .map((dateItem) => BehaviorDate.fromJson(dateItem))
          .toList();
    }
    return [];
  }

  // Get last 4 days activities for a child
  Future<List<BehaviorDate>> getLastWeekActivities({
    required int schoolId,
    required int classId,
    required String childId,
  }) async {
    try {
      final now = DateTime.now();
      final fourDaysAgo = now.subtract(const Duration(days: 4));
      final needsPreviousMonth = fourDaysAgo.month != now.month;

      final List<BehaviorDate> allDates = [];

      // Fetch current month
      final currentMonthStr = '${now.year}-${now.month}';
      final currentResponse = await _apiService.get(
        '/api/schools/$schoolId/classes/$classId/childs/$childId/activity?date=$currentMonthStr',
      );

      if (currentResponse.success && currentResponse.data != null &&
          currentResponse.data['dates'] is List) {
        allDates.addAll(
          (currentResponse.data['dates'] as List)
              .map((dateItem) => BehaviorDate.fromJson(dateItem))
              .toList(),
        );
      }

      // Fetch previous month if needed
      if (needsPreviousMonth) {
        final previousMonthStr = '${fourDaysAgo.year}-${fourDaysAgo.month}';
        final previousResponse = await _apiService.get(
          '/api/schools/$schoolId/classes/$classId/childs/$childId/activity?date=$previousMonthStr',
        );

        if (previousResponse.success && previousResponse.data != null &&
            previousResponse.data['dates'] is List) {
          allDates.addAll(
            (previousResponse.data['dates'] as List)
                .map((dateItem) => BehaviorDate.fromJson(dateItem))
                .toList(),
          );
        }
      }

      final lastFourDays = allDates.where((behaviorDate) {
        final daysDifference = now.difference(behaviorDate.date).inDays;
        return daysDifference >= 1 && daysDifference <= 4;
      }).toList();

      lastFourDays.sort((a, b) => a.date.compareTo(b.date));
      return lastFourDays;
    } catch (e) {
      debugPrint('Error getting last week activities: $e');
      return [];
    }
  }

  // Get child behaviors for a specific day
  Future<List<Activity>> getChildBehaviorsByDay({
    required int schoolId,
    required int classId,
    required String childId,
    required String date, // Format: "YYYY-M-D"
  }) async {
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/childs/$childId/behaviors',
      queryParameters: {'date': date},
    );

    if (!response.success) {
      debugPrint('Failed to get child behaviors: ${response.error}');
      return [];
    }

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

    if (titleAr == null && titleEn == null && activity.title.isNotEmpty) {
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

    if (descriptionAr == null &&
        descriptionEn == null &&
        activity.description.isNotEmpty) {
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
      titleAr: titleAr ?? activity.title,
      titleEn: titleEn ?? activity.title,
      descriptionAr: descriptionAr ?? activity.description,
      descriptionEn: descriptionEn ?? activity.description,
    );
  }

  // Get child behavior for this month
  Future<List<BehaviorRecord>> getChildBehaviorThisMonth({
    required int schoolId,
    required int classId,
    required String childId,
  }) async {
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/this-month',
    );

    if (!response.success) {
      debugPrint('Failed to get child behavior this month: ${response.error}');
      return [];
    }

    if (response.data is List) {
      return (response.data as List)
          .map((behavior) => BehaviorRecord.fromJson(behavior))
          .toList();
    }
    return [];
  }

  // Get child behavior for last month
  Future<List<BehaviorRecord>> getChildBehaviorLastMonth({
    required int schoolId,
    required int classId,
    required String childId,
  }) async {
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/last-month',
    );

    if (!response.success) {
      debugPrint('Failed to get child behavior last month: ${response.error}');
      return [];
    }

    if (response.data is List) {
      return (response.data as List)
          .map((behavior) => BehaviorRecord.fromJson(behavior))
          .toList();
    }
    return [];
  }

  Future<UserProfile> getParentProfile() async {
    final response = await _apiService.get('/parent/profile');
    if (!response.success) {
      throw Exception(response.error ?? 'Error fetching parent profile');
    }
    return UserProfile.fromJson(response.data);
  }

  Future<UserProfile> updateParentProfile(Map<String, dynamic> data) async {
    final response = await _apiService.put('/api/me', data: data);
    if (!response.success) {
      throw Exception(response.error ?? 'Error updating parent profile');
    }
    return await getParentProfile();
  }

  // Notification methods
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiService.get('/api/notifications');

    if (!response.success) {
      debugPrint('Failed to get notifications: ${response.error}');
      return [];
    }

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

    return NotificationModel(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      titleAr: titleAr ?? notification.title,
      titleEn: titleEn ?? notification.title,
      messageAr: messageAr ?? notification.message,
      messageEn: messageEn ?? notification.message,
      createdAt: notification.createdAt,
      isRead: notification.isRead,
      type: notification.type,
      imageUrl: notification.imageUrl,
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

    final behaviorPattern = RegExp(
      r'A new behavior has been assigned to your child\s+(.+?)\s+by teacher\s+(.+)$',
      caseSensitive: false,
    );
    final behaviorMatch = behaviorPattern.firstMatch(message);

    if (behaviorMatch != null) {
      final studentName = behaviorMatch.group(1)?.trim() ?? '';
      final teacherName = behaviorMatch.group(2)?.trim() ?? '';

      if (toLang == 'ar') {
        return 'تم تعيين سلوك جديد لطفلك $studentName من قبل المعلم $teacherName';
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

    final arabicBehaviorPattern = RegExp(
      r'تم تعيين سلوك جديد لطفلك\s+(.+?)\s+من قبل المعلم\s+(.+)$',
    );
    final arabicBehaviorMatch = arabicBehaviorPattern.firstMatch(message);

    if (arabicBehaviorMatch != null && toLang == 'en') {
      final studentName = arabicBehaviorMatch.group(1)?.trim() ?? '';
      final teacherName = arabicBehaviorMatch.group(2)?.trim() ?? '';
      return 'A new behavior has been assigned to your child $studentName by teacher $teacherName';
    }

    if (toLang == 'ar') {
      return await _translationService.translateToArabic(message);
    } else {
      return await _translationService.translateToEnglish(message);
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    final response = await _apiService.post('/api/notifications/mark-as-read/$notificationId');
    if (!response.success) {
      debugPrint('Failed to mark notification as read: ${response.error}');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    final response = await _apiService.delete('/api/notifications/$notificationId');
    if (!response.success) {
      debugPrint('Failed to delete notification: ${response.error}');
    }
  }

  // Mocked method for child purchases
  Future<List<Purchase>> getChildPurchases({required int studentId}) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Purchase(
        id: 1,
        studentId: studentId,
        rewardId: 1,
        rewardName: 'Pen',
        pointsSpent: 200,
        status: 'Delivered',
        purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
        image: '',
        market: 'School Store',
        marketAddress: 'Room 101',
      ),
      Purchase(
        id: 2,
        studentId: studentId,
        rewardId: 2,
        rewardName: 'Notebook',
        pointsSpent: 300,
        status: 'Pending',
        purchaseDate: DateTime.now().subtract(const Duration(days: 5)),
        image: '',
        market: 'School Store',
        marketAddress: 'Room 101',
      ),
      Purchase(
        id: 3,
        studentId: studentId,
        rewardId: 3,
        rewardName: 'Eraser',
        pointsSpent: 50,
        status: 'Rejected',
        purchaseDate: DateTime.now().subtract(const Duration(days: 10)),
        image: '',
        market: 'School Store',
        marketAddress: 'Room 101',
      ),
    ];
  }

  // ==================== Child Report APIs ====================

  Future<double> getChildTotalPointsExchanged({
    required int schoolId,
    required int classId,
    required String childId,
    required String date,
  }) async {
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/total-points-exchanged',
      queryParameters: {'date': date},
    );

    if (!response.success) {
      debugPrint('Failed to get total points exchanged: ${response.error}');
      return 0.0;
    }

    final value = response.data['totalPointsExchanged'];
    return value != null
        ? (value is double ? value : (value as num).toDouble())
        : 0.0;
  }

  Future<double> getChildTotalCreditsExchanged({
    required int schoolId,
    required int classId,
    required String childId,
    required String date,
  }) async {
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/total-credits-exchanged',
      queryParameters: {'date': date},
    );

    if (!response.success) {
      debugPrint('Failed to get total credits exchanged: ${response.error}');
      return 0.0;
    }

    final value = response.data['totalCreditsExchanged'];
    return value != null
        ? (value is double ? value : (value as num).toDouble())
        : 0.0;
  }

  Future<int> getChildTotalPointsGiven({
    required int schoolId,
    required int classId,
    required String childId,
    required String date,
  }) async {
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/total-points-given',
      queryParameters: {'date': date},
    );

    if (!response.success) {
      debugPrint('Failed to get total points given: ${response.error}');
      return 0;
    }

    final value = response.data['totalPointsGiven'];
    return value != null
        ? (value is int ? value : (value as num).toInt())
        : 0;
  }

  Future<int> getChildTotalCreditsGiven({
    required int schoolId,
    required int classId,
    required String childId,
    required String date,
  }) async {
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/total-credits-given',
      queryParameters: {'date': date},
    );

    if (!response.success) {
      debugPrint('Failed to get total credits given: ${response.error}');
      return 0;
    }

    final value = response.data['totalCreditsGiven'];
    return value != null
        ? (value is int ? value : (value as num).toInt())
        : 0;
  }

  Future<Map<String, int>> getChildBehaviorCounts({
    required int schoolId,
    required int classId,
    required String childId,
    required String date,
  }) async {
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/counts',
      queryParameters: {'date': date},
    );

    if (!response.success) {
      debugPrint('Failed to get behavior counts: ${response.error}');
      return {'positiveCount': 0, 'negativeCount': 0};
    }

    return {
      'positiveCount': response.data['positiveCount'] ?? 0,
      'negativeCount': response.data['negativeCount'] ?? 0,
    };
  }

  Future<List<ChildReward>> getChildRewardInfo({
    required int schoolId,
    required int classId,
    required String childId,
    required String date,
  }) async {
    final response = await _apiService.get(
      '/api/schools/$schoolId/classes/$classId/childs/$childId/behavior/reward-info',
      queryParameters: {'date': date},
    );

    if (!response.success) {
      debugPrint('Failed to get reward info: ${response.error}');
      return [];
    }

    if (response.data != null && response.data['rewardImages'] is List) {
      return (response.data['rewardImages'] as List)
          .map((rewardItem) => ChildReward.fromJson(rewardItem))
          .toList();
    }
    return [];
  }
}
